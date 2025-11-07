# @Olaii/node-printer

**No recompilation required when upgrading Node.js versions, thanks to N-API!** 🎉

Native bind printers on Windows, Mac OS, and Linux from Node.js, Electron, and node-webkit.
Supports following architectures:
* Windows - ia32, x64, arm64
* Mac - x64 & arm64 (Apple Silicon)
* Linux - ia32, x64, arm7l, arm64

> Supports Node.js versions from 8.0.0 onwards, including the latest versions, thanks to the transition to N-API.

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

*   **Node.js**: 24
*   **NW.js**: 0.105.0

If you are using a version not covered by our pre-compiled binaries, the installer will attempt to build the addon from source. This requires a proper C/C++ compiler toolchain to be installed on your system.

### How to install:
```
npm install github:Olaii/node-printer

```


### DEV

On windows you will need to go to `node_modules\@mapbox\node-pre-gyp\lib\util\compile.js` and change the line 80
from:

```js
  const cmd = cp.spawn(shell_cmd, final_args, { cwd: undefined, env: process.env, stdio: [0, 1, 2] });

```

to:

```js
  const cmd = cp.spawn(shell_cmd, final_args, { cwd: undefined, env: process.env, stdio: [0, 1, 2], shell: true });
```

Adding the `shell: true` so it works on Node 24 LTS version.


To create prebuilt binaries for NW.js run:

```bash
npm run prebuild --runtime=node-webkit --target=0.105.0 --target_arch=ia32
npm run prebuild --runtime=node-webkit --target=0.105.0 --target_arch=x64
```
