# @addble/node-printer

**No recompilation required when upgrading Node.js versions, thanks to N-API!** 🎉

Native bind printers on Windows, Mac OS, and Linux from Node.js, Electron, and node-webkit.
Supports following architectures:
* Windows - ia32, x64, arm64
* Mac - x64 & arm64 (Apple Silicon)
* Linux - ia32, x64, arm7l, arm64


[![npm version](https://badge.fury.io/js/%40addble%2Fnode-printer.svg)](https://badge.fury.io/js/%40addble%2Fnode-printer)
[![CI & Prebuilds](https://github.com/addble/electron-printer/actions/workflows/ci.yml/badge.svg)](https://github.com/addble/electron-printer/actions/workflows/ci.yml)

> Supports Node.js versions from 8.0.0 onwards, including the latest versions, thanks to the transition to N-API.

> Prebuild and CI integration courtesy of @ekoeryanto in his [FORK](https://github.com/ekoeryanto/node-printer)

If you have a problem, please find or create a new [GitHub issue](https://github.com/addble/electron-printer/issues).

### Supported Features

* No dependencies on NAN or V8;
* Native method wrappers for Windows and POSIX (which uses CUPS 1.4/MAC OS X 10.6) APIs;
* Compatible with Node.js versions that support N-API, ensuring long-term stability and compatibility;
* Compatible with Electron versions that support N-API, reducing the need for frequent recompilation;
* `getPrinters()` to enumerate all installed printers with current jobs and statuses;
* `getPrinter(printerName)` to get info for a specific printer;
* `getDefaultPrinterName()` returns the default printer name;
* `printDirect(options)` to send raw data to a printer. Returns a Promise.
* `printFile(options)` to print a file (POSIX only, e.g., macOS, Linux). Returns a Promise.
* `getSupportedPrintFormats()` to get supported data formats like 'RAW' and 'TEXT'.

### Pre-compiled Binaries

This package ships with pre-compiled binaries for a wide range of Node.js and Electron versions on Windows, macOS, and Linux for various architectures.

While N-API provides forward compatibility (meaning a binary built for an older version may work on a newer one), we provide pre-builds for these major versions to ensure a smooth installation experience without requiring a local compiler toolchain:

*   **Node.js**: 16, 18, 20, 22
*   **Electron**: 15, 19, 22, 25, 27, 28, 29, 30, 31

If you are using a version not covered by our pre-compiled binaries, the installer will attempt to build the addon from source. This requires a proper C/C++ compiler toolchain to be installed on your system.

### How to install:
```
npm install @addble/electron-printer

___
### **Below is the original README**
___
### Reason:

I was involved in a project where I needed to print from Node.js. This is the reason why I created this project and I want to share my code with others.

### Features:

* No dependencies on NAN or V8;
* Native method wrappers for Windows and POSIX (which uses CUPS 1.4/MAC OS X 10.6) APIs;
* Compatible with Node.js versions that support N-API, ensuring long-term stability and compatibility;
* Compatible with Electron versions that support N-API, reducing the need for frequent recompilation;
* `getPrinters()` to enumerate all installed printers with current jobs and statuses;
* `getPrinter(printerName)` to get a specific/default printer info with current jobs and statuses;
* `getPrinterDriverOptions(printerName)` (POSIX only) to get a specific/default printer driver options such as supported paper size and other info;
* `getSelectedPaperSize(printerName)` (POSIX only) to get a specific/default printer default paper size from its driver options;
* `printDirect(options)` to send a job to a specific/default printer, now supports CUPS options passed in the form of a JS object (see `cancelJob.js` example). To print a PDF from Windows, it is possible by using node-pdfium module to convert a PDF format into EMF and then send it to the printer as EMF;
* `printFile(options)` (POSIX only) to print a file;
* `getSupportedPrintFormats()` to get all possible print formats for the `printDirect` method, which depends on the OS. `RAW` and `TEXT` are supported on all OSes;
* `getJob(printerName, jobId)` to get specific job info including job status;
* `setJob(printerName, jobId, command)` to send a command to a job (e.g., `'CANCEL'` to cancel the job);
* `getSupportedJobCommands()` to get supported job commands for `setJob()`, depending on the OS. The `'CANCEL'` command is supported on all OSes.


### How to use:

See examples

### Author(s):

* Ion Lupascu, ionlupascu@gmail.com

### Contributors:

* Thiago Lugli, @thiagoelg
* Eko Eryanto, @ekoeryanto
* Sudheer Gupta, @susheer

### Project History:

This project was originally written by Ion Lupascu using NAN and V8. It has been rewritten by @susheer to use N-API exclusively, removing dependencies on NAN and V8 to ensure better stability and compatibility with future Node.js and Electron versions.

### Node.js Version Support:

This project supports Node.js versions from 8.0.0 onwards. N-API ensures that native addons do not require recompilation when upgrading Node.js versions. For more details, refer to the [Node.js N-API documentation](https://nodejs.org/api/n-api.html)¹(https://nodejs.org/api/n-api.html).

Feel free to download, test, and propose new features.

### License:
 The MIT License (MIT)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on GitHub.

## License

This project is licensed under the MIT License.

### Keywords:

* node-printer
* nodejs-printer
* printer
* electron-printer
* node-addon-api
* POSIX printer
* Windows printer
* CUPS printer
* print job
* printer driver
* Mac OS printer
* Raspberry PI printer


---