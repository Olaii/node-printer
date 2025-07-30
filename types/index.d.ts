export function getPrinters(): PrinterDetails[];
export function getPrinter(printerName: string): PrinterDetails;
export function getDefaultPrinterName(): string | undefined;
export function printDirect(options: PrintDirectOptions): Promise<number>;
export function printFile(options: PrintFileOptions): Promise<number>;
export function getSupportedPrintFormats(): string[];

export interface PrintDirectOptions {
    data: string | Buffer;
    printer?: string | undefined;
    docname?: string | undefined;
    type?: 'RAW' | 'TEXT' | 'PDF' | 'JPEG' | 'POSTSCRIPT' | 'COMMAND' | 'AUTO' | undefined;
    options?: { [key: string]: string } | undefined;
}

export interface PrintFileOptions {
    filename: string;
    printer?: string | undefined;
    docname?: string | undefined;
    options?: { [key: string]: string } | undefined;
}

export interface PrinterDetails {
    name: string;
    isDefault: boolean;
    options: { [key: string]: string; };
}

export interface PrinterDriverOptions {
    [key: string]: { [key: string]: boolean; };
}

export interface JobDetails {
    id: number;
    name: string;
    printerName: string;
    user: string;
    format: string;
    priority: number;
    size: number;
    status: JobStatus[];
    completedTime: Date;
    creationTime: Date;
    processingTime: Date;
}

export type JobStatus = 'PAUSED' | 'PRINTING' | 'PRINTED' | 'CANCELLED' | 'PENDING' | 'ABORTED';