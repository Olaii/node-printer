#include "node_printer.hpp"
#include <cups/cups.h>
#include <string>
#include <vector>
#include <cups/ipp.h>
#include <cstdlib>
#include <cstring>

// This file provides the implementation for POSIX-compliant systems (macOS, Linux) using CUPS.

namespace {

// Helper to convert Napi::Object to cups_option_t.
// The caller is responsible for freeing the returned cups_option_t array using cupsFreeOptions.
int napi_object_to_cups_options(Napi::Env env, Napi::Object napi_options, cups_option_t **cups_options) {
    Napi::Array keys = napi_options.GetPropertyNames();
    uint32_t num_options = 0;
    *cups_options = NULL;

    for (uint32_t i = 0; i < keys.Length(); i++) {
        Napi::Value key_val = keys.Get(i);
        std::string key = key_val.As<Napi::String>().Utf8Value();
        Napi::Value value_val = napi_options.Get(key_val);
        
        std::string value;
        if (value_val.IsString()) {
            value = value_val.As<Napi::String>().Utf8Value();
        } else if (value_val.IsNumber()) {
            value = std::to_string(value_val.As<Napi::Number>().Int64Value());
        } else if (value_val.IsBoolean()) {
            value = value_val.As<Napi::Boolean>().Value() ? "true" : "false";
        } else {
            // Skip non-primitive types
            continue;
        }
        
        num_options = cupsAddOption(key.c_str(), value.c_str(), num_options, cups_options);
    }
    return num_options;
}

} // anonymous namespace

MY_NODE_MODULE_CALLBACK(getPrinters)
{
    MY_NODE_MODULE_HANDLESCOPE;
    
    cups_dest_t *dests;
    int num_dests = cupsGetDests(&dests);

    if (num_dests <= 0) {
        MY_NODE_MODULE_RETURN_VALUE(Napi::Array::New(env));
    }

    Napi::Array result = Napi::Array::New(env, num_dests);

    for (int i = 0; i < num_dests; i++) {
        Napi::Object printer = Napi::Object::New(env);
        printer.Set("name", Napi::String::New(env, dests[i].name));
        if (dests[i].instance) {
            printer.Set("instance", Napi::String::New(env, dests[i].instance));
        }
        printer.Set("is_default", Napi::Boolean::New(env, dests[i].is_default));

        Napi::Object options = Napi::Object::New(env);
        for (int j = 0; j < dests[i].num_options; j++) {
            options.Set(dests[i].options[j].name, Napi::String::New(env, dests[i].options[j].value));
        }
        printer.Set("options", options);

        const char* state_str = cupsGetOption("printer-state", dests[i].num_options, dests[i].options);
        if (state_str) {
            int state = atoi(state_str);
            std::string status_string;
            switch (state) {
                case IPP_PRINTER_IDLE: status_string = "IDLE"; break;
                case IPP_PRINTER_PROCESSING: status_string = "PRINTING"; break;
                case IPP_PRINTER_STOPPED: status_string = "STOPPED"; break;
                default: status_string = "UNKNOWN"; break;
            }
            printer.Set("status", Napi::String::New(env, status_string));
        }

        result.Set(i, printer);
    }

    cupsFreeDests(num_dests, dests);
    MY_NODE_MODULE_RETURN_VALUE(result);
}

MY_NODE_MODULE_CALLBACK(getDefaultPrinterName)
{
    MY_NODE_MODULE_HANDLESCOPE;

    // Using cupsGetDests is a more modern and reliable way to find the default printer,
    // especially on newer versions of macOS where cupsGetDefault might be deprecated or behave differently.
    cups_dest_t *dests;
    int num_dests = cupsGetDests(&dests);
    const char* default_printer_name = NULL;

    if (num_dests > 0) {
        for (int i = 0; i < num_dests; i++) {
            if (dests[i].is_default) {
                default_printer_name = dests[i].name;
                break; // Found it
            }
        }
    }

    if (default_printer_name) {
        Napi::String result = Napi::String::New(env, default_printer_name);
        cupsFreeDests(num_dests, dests); // Free the memory allocated by cupsGetDests
        MY_NODE_MODULE_RETURN_VALUE(result);
    }

    if (num_dests > 0) {
        cupsFreeDests(num_dests, dests);
    }

    MY_NODE_MODULE_RETURN_VALUE(Napi::String::New(env, ""));
}

MY_NODE_MODULE_CALLBACK(printDirect)
{
    MY_NODE_MODULE_HANDLESCOPE;
    REQUIRE_ARGUMENTS(env, info, 5);
    
    std::string data;
    if (!getStringOrBufferFromNapiValue(info[0], data)) {
        RETURN_EXCEPTION(env, "Argument 0 must be a string or a Buffer.");
    }

    ARG_CHECK_STRING(env, info, 1); // printer
    ARG_CHECK_STRING(env, info, 2); // docname
    ARG_CHECK_STRING(env, info, 3); // type
    if (!info[4].IsObject()) {
        RETURN_EXCEPTION(env, "Argument 4 must be an object.");
    }

    std::string printer_name = info[1].As<Napi::String>().Utf8Value();
    std::string doc_name = info[2].As<Napi::String>().Utf8Value();
    std::string type = info[3].As<Napi::String>().Utf8Value();
    Napi::Object js_options = info[4].As<Napi::Object>();

    cups_option_t *options = NULL;
    int num_options = napi_object_to_cups_options(env, js_options, &options);

    if (type == "RAW") {
        num_options = cupsAddOption("raw", "true", num_options, &options);
    }

    int job_id = cupsCreateJob(CUPS_HTTP_DEFAULT, printer_name.c_str(), doc_name.c_str(), num_options, options);

    if (job_id > 0) {
        const char* format = (type == "TEXT") ? "text/plain" : "application/octet-stream";
        http_t *http = httpConnect2(cupsServer(), ippPort(), NULL, 0, HTTP_ENCRYPTION_IF_REQUESTED, 1, 30000, NULL);
        if (!http) {
            cupsFreeOptions(num_options, options);
            RETURN_EXCEPTION_STR(env, "Failed to connect to CUPS server");
        }

        if (cupsStartDocument(http, printer_name.c_str(), job_id, doc_name.c_str(), format, 1) == HTTP_STATUS_CONTINUE) {
            cupsWriteRequestData(http, data.c_str(), data.length());
            ipp_status_t status = cupsFinishDocument(http, printer_name.c_str());
            if (status > IPP_STATUS_OK_CONFLICTING) {
                std::string error_msg = "Failed to send document: ";
                error_msg += cupsLastErrorString();
                httpClose(http);
                cupsFreeOptions(num_options, options);
                RETURN_EXCEPTION_STR(env, error_msg.c_str());
            }
        } else {
            std::string error_msg = "Failed to start document: ";
            error_msg += cupsLastErrorString();
            httpClose(http);
            cupsFreeOptions(num_options, options);
            RETURN_EXCEPTION_STR(env, error_msg.c_str());
        }
        httpClose(http);
    } else {
        std::string error_msg = "Failed to create CUPS job: ";
        error_msg += cupsLastErrorString();
        cupsFreeOptions(num_options, options);
        RETURN_EXCEPTION_STR(env, error_msg.c_str());
    }

    cupsFreeOptions(num_options, options);
    MY_NODE_MODULE_RETURN_VALUE(Napi::Number::New(env, job_id));
}

MY_NODE_MODULE_CALLBACK(getPrinter)
{
    MY_NODE_MODULE_HANDLESCOPE;
    REQUIRE_ARGUMENTS(env, info, 1);
    ARG_CHECK_STRING(env, info, 0);

    std::string printer_name = info[0].As<Napi::String>().Utf8Value();
    cups_dest_t *dest = cupsGetNamedDest(CUPS_HTTP_DEFAULT, printer_name.c_str(), NULL);

    if (!dest) {
        MY_NODE_MODULE_RETURN_VALUE(env.Undefined());
    }

    Napi::Object printer = Napi::Object::New(env);
    printer.Set("name", Napi::String::New(env, dest->name));
    if (dest->instance) {
        printer.Set("instance", Napi::String::New(env, dest->instance));
    }
    printer.Set("is_default", Napi::Boolean::New(env, dest->is_default));

    Napi::Object options = Napi::Object::New(env);
    for (int j = 0; j < dest->num_options; j++) {
        options.Set(dest->options[j].name, Napi::String::New(env, dest->options[j].value));
    }
    printer.Set("options", options);

    const char* state_str = cupsGetOption("printer-state", dest->num_options, dest->options);
    if (state_str) {
        int state = atoi(state_str);
        std::string status_string;
        switch (state) {
            case IPP_PRINTER_IDLE: status_string = "IDLE"; break;
            case IPP_PRINTER_PROCESSING: status_string = "PRINTING"; break;
            case IPP_PRINTER_STOPPED: status_string = "STOPPED"; break;
            default: status_string = "UNKNOWN"; break;
        }
        printer.Set("status", Napi::String::New(env, status_string));
    }

    cupsFreeDests(1, dest);
    MY_NODE_MODULE_RETURN_VALUE(printer);
}

MY_NODE_MODULE_CALLBACK(printFile)
{
    MY_NODE_MODULE_HANDLESCOPE;
    REQUIRE_ARGUMENTS(env, info, 4);
    ARG_CHECK_STRING(env, info, 0); // filename
    ARG_CHECK_STRING(env, info, 1); // docname
    ARG_CHECK_STRING(env, info, 2); // printer
    if (!info[3].IsObject()) {
        RETURN_EXCEPTION(env, "Argument 3 must be an object.");
    }

    std::string filename = info[0].As<Napi::String>().Utf8Value();
    std::string docname = info[1].As<Napi::String>().Utf8Value();
    std::string printer_name = info[2].As<Napi::String>().Utf8Value();
    Napi::Object js_options = info[3].As<Napi::Object>();

    cups_option_t *options = NULL;
    int num_options = napi_object_to_cups_options(env, js_options, &options);

    int job_id = cupsPrintFile(printer_name.c_str(), filename.c_str(), docname.c_str(), num_options, options);

    if (job_id == 0) {
        std::string error_msg = "Failed to print file: ";
        error_msg += cupsLastErrorString();
        cupsFreeOptions(num_options, options);
        RETURN_EXCEPTION_STR(env, error_msg.c_str());
    }

    cupsFreeOptions(num_options, options);
    MY_NODE_MODULE_RETURN_VALUE(Napi::Number::New(env, job_id));
}

MY_NODE_MODULE_CALLBACK(getSupportedPrintFormats)
{
    MY_NODE_MODULE_HANDLESCOPE;
    Napi::Array result = Napi::Array::New(env);
    result.Set(uint32_t(0), Napi::String::New(env, "RAW"));
    result.Set(uint32_t(1), Napi::String::New(env, "TEXT"));
    MY_NODE_MODULE_RETURN_VALUE(result);
}