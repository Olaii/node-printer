const path = require('path');
let addon;

try {
    // When installed via node-pre-gyp, the binary is placed in ./lib/binding/
    addon = require(path.join(__dirname, 'binding', 'node-printer.node'));
} catch (err) {
    // During development, the binary is in the standard build directory.
    // The `action_after_build` step in binding.gyp is not strictly necessary with this setup.
    addon = require(path.join(__dirname, '..', 'build', 'Release', 'node-printer.node'));
}

module.exports.sayMyName = addon.SayMyName
module.exports.getPrinters = addon.getPrinters
module.exports.printDirect = printDirect
module.exports.getDefaultPrinterName = addon.getDefaultPrinterName
module.exports.getPrinter = getPrinter;
/// send file to printer
module.exports.printFile = printFile;
/** Get supported print format for printDirect
 */
module.exports.getSupportedPrintFormats = addon.getSupportedPrintFormats;
/*
 * Print raw data to a printer. This function is asynchronous and returns a Promise.
 * @param {object} options The print options.
 * @param {Buffer|string} options.data The data to print.
 * @param {string} [options.printer] The name of the printer. If not provided, the default printer is used.
 * @param {string} [options.docname="node print job"] The name of the document as it appears in the print queue.
 * @param {string} [options.type="RAW"] The data type (e.g., 'RAW', 'TEXT').
 * @param {object} [options.options={}] CUPS-specific options.
 * @returns {Promise<number>} A promise that resolves with the job ID.
 */
async function printDirect(options) {
    if (typeof options !== 'object' || options === null) {
        throw new TypeError('An options object is required.');
    }

    // Explicitly extract and validate parameters to provide better error messages
    // and prevent invalid types from reaching the C++ addon.
    const data = options.data;
    const printer = options.printer || addon.getDefaultPrinterName();
    const docname = options.docname || 'node print job';
    const type = options.type || 'RAW';
    const printerOptions = options.options || {};

    if (!data) {
        throw new Error('A `data` field is required in the options object.');
    }

    if (!printer || typeof printer !== 'string') {
        throw new Error('A `printer` name is required, or a default printer must be set.');
    }

    if (typeof docname !== 'string') {
        throw new TypeError('The `docname` option, if provided, must be a string.');
    }

    if (typeof type !== 'string') {
        throw new TypeError('The `type` option, if provided, must be a string.');
    }

    return new Promise((resolve, reject) => {
        try {
            const jobId = addon.printDirect(data, printer, docname, type.toUpperCase(), printerOptions);
            resolve(jobId);
        } catch (e) {
            reject(e);
        }
    });
}

/** Get printer info with jobs
 * @param printerName printer name to extract the info
 * @return printer object info:
 *		TODO: to enum all possible attributes
 */
function getPrinter(printerName) {
    const targetPrinterName = printerName || addon.getDefaultPrinterName();
    if (!targetPrinterName) {
        return undefined;
    }

    const printer = addon.getPrinter(targetPrinterName);
    if (printer) {
        correctPrinterinfo(printer);
    }
    return printer;
}


function correctPrinterinfo(printer) {
    if (!printer || printer.status || !printer.options || !printer.options['printer-state']) {
        return;
    }

    var status = printer.options['printer-state'];
    // Add posix status
    if (status == '3') {
        status = 'IDLE'
    } else if (status == '4') {
        status = 'PRINTING'
    } else if (status == '5') {
        status = 'STOPPED'
    }

    // correct date type
    var k;
    for (k in printer.options) {
        if (/time$/.test(k) && printer.options[k] && !(printer.options[k] instanceof Date)) {
            printer.options[k] = new Date(printer.options[k] * 1000);
        }
    }

    printer.status = status;
}

/**
 * Print a file to a printer. This function is asynchronous and returns a Promise.
 * Note: This function is only supported on POSIX platforms (macOS, Linux).
 * @param {object} options The print options.
 * @param {string} options.filename The path to the file to be printed.
 * @param {string} [options.printer] The name of the printer. If not provided, the default printer is used.
 * @param {string} [options.docname] The name of the document. Defaults to the filename.
 * @param {object} [options.options={}] CUPS-specific options.
 * @returns {Promise<number>} A promise that resolves with the job ID.
 */
async function printFile(options) {
    if (typeof options !== 'object' || options === null) {
        throw new TypeError('An options object is required.');
    }

    if (!addon.printFile) {
        throw new Error('`printFile` is not supported on this platform (Windows).');
    }

    const filename = options.filename;
    const printer = options.printer || addon.getDefaultPrinterName();
    // Default docname to filename if it's not provided or is null/empty
    const docname = options.docname || filename;
    const printerOptions = options.options || {};

    if (!filename) {
        throw new Error('A `filename` is required in the options object.');
    }

    if (!printer || typeof printer !== 'string') {
        throw new Error('A `printer` name is required, or a default printer must be set.');
    }

    if (typeof docname !== 'string') {
        throw new TypeError('The `docname` option, if provided, must be a string.');
    }

    return new Promise((resolve, reject) => {
        try {
            const jobId = addon.printFile(filename, docname, printer, printerOptions);
            resolve(jobId);
        } catch (e) {
            reject(e);
        }
    });
}