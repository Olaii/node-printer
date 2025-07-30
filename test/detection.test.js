const assert = require('assert/strict');
const { test, describe, beforeEach } = require('node:test');

let printer;

beforeEach(() => {
  // This loads the actual native addon
  printer = require('../lib');
});

describe('Printer Detection Integration Tests', () => {
  test('getPrinters should return an array of printers', (t) => {
    const printers = printer.getPrinters();

    assert.ok(Array.isArray(printers), 'getPrinters() should return an array.');
    console.log(`Found ${printers.length} printers.`);

    if (printers.length > 0) {
      console.log('List of detected printers:');
      printers.forEach(p => {
        console.log(`- ${p.name}`);
        assert.strictEqual(typeof p.name, 'string', 'Each printer should have a name property of type string.');
      });
    }
  });

  test('getDefaultPrinterName should return a string or undefined', (t) => {
    const defaultPrinterName = printer.getDefaultPrinterName();

    assert.ok(
      typeof defaultPrinterName === 'string' || typeof defaultPrinterName === 'undefined',
      'getDefaultPrinterName() should return a string or undefined.'
    );

    if (typeof defaultPrinterName === 'string' && defaultPrinterName.length > 0) {
      console.log(`Default printer is: "${defaultPrinterName}"`);
    } else {
      console.log('No default printer is configured on this system.');
    }
  });

  test('getPrinter should return details for a specific printer', (t) => {
    const printers = printer.getPrinters();
    if (printers.length === 0) {
      t.skip('Skipping test: No printers are installed on this system.');
      return;
    }

    const printerToTest = printers[0].name;
    console.log(`Testing getPrinter with: "${printerToTest}"`);
    const details = printer.getPrinter(printerToTest);

    assert.ok(details, 'getPrinter should return an object for an existing printer.');
    assert.strictEqual(typeof details, 'object', 'getPrinter should return an object.');
    assert.strictEqual(details.name, printerToTest, 'The returned printer details should have the correct name.');
  });
});