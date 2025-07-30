const test = require('node:test');
const assert = require('assert/strict');
const path = require('node:path');

// This is the mock of our C++ addon.
// We can control its behavior for different test cases.
const mockAddon = {
    printDirect: (data, printer, docname, type, options) => {
        if (printer === 'FAIL') {
            throw new Error('Printer not found');
        }
        return 123; // Return a mock job ID on success
    },
    getDefaultPrinterName: () => 'DefaultPrinter',
    // Mock other addon functions as needed for more tests
    getPrinters: () => [],
    getPrinter: (name) => ({ name, isDefault: false }),
    getSupportedPrintFormats: () => ['RAW', 'TEXT'],
    printFile: () => 456,
    SayMyName: () => 'Hello, From C++ !',
};

// This is the key part for mocking. We intercept Node's `require` mechanism.
// When `lib/index.js` tries to load the compiled `.node` file, we give it our mock object instead.
const addonPath1 = path.resolve(__dirname, '../lib/electron-printer.node');
const addonPath2 = path.resolve(__dirname, '../build/Release/electron-printer.node');
require('module')._cache[addonPath1] = { exports: mockAddon };
require('module')._cache[addonPath2] = { exports: mockAddon };

// Now that the mock is in place, we can safely require the main library file.
const printer = require('../lib');

test.describe('Printing Tests with Mock', () => {
    test('should print successfully with printDirect', async () => {
        const jobId = await printer.printDirect({ data: 'test data' });
        assert.strictEqual(jobId, 123, 'The job ID should be the one returned by the mock addon');
    });

    test('should reject with an error if the native call fails', async () => {
        await assert.rejects(
            () => printer.printDirect({ data: 'test data', printer: 'FAIL' }),
            { message: 'Printer not found' },
            'Should reject when the mock addon throws an error'
        );
    });

    test('should throw a TypeError if options are not provided', async () => {
        await assert.rejects(
            () => printer.printDirect(),
            new TypeError('An options object is required.')
        );
    });
});