/** 
    LWC Name    : wFMUpload.js
    Created Date       : 00 - 2024
    @description       : This is class ..
    @author            : Bung Femy
    Modification Log :
    Ver   Date         Author                            Modification
    //release 3
    1.0   00/00/2024   Bung Femy                         Initial Version
    1.0   14/01/2025   Rakeyan Nuramria                  Adjust to show error per row/checking & validating input data
    1.0   16/01/2025   Rakeyan Nuramria                  Adjust logic behaviour submit button
    1.0   21/01/2025   Rakeyan Nuramria                  Adjust validation for file type & size & Kode in Jadwal Karyawan
    1.0   22/01/2025   Rakeyan Nuramria                  Adjust validation for empty column & trim cell & code upload
    1.0   11/02/2025   Rakeyan Nuramria                  Adjust logic to include "," or "." in the score validation
    1.0   17/02/2025   Rakeyan Nuramria                  Adjust validation to check missing column & error message, adjust uploadFile() toast based on result
    1.0   19/02/2025   Rakeyan Nuramria                  Add logic to check delimiter file based what user choose
    **/

import {LightningElement,api,track, wire} from 'lwc';
import { generateUrl } from "lightning/fileDownload";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import uploadFile from '@salesforce/apex/SCC_WFM_Upload.uploadFile';
import templatecuti from "@salesforce/resourceUrl/WFM_Upload_Cuti_Tahunan";
import templatepoin from "@salesforce/resourceUrl/WFM_Upload_Penambahan_Poin";
import templatejadwal from "@salesforce/resourceUrl/WFM_Upload_Jadwal_Karyawan";

// Import the Object API name
import JADWAL_KARYAWAN_OBJECT from '@salesforce/schema/Jadwal_Karyawan__c';
import LOKASI_FIELD from '@salesforce/schema/Jadwal_Karyawan__c.Lokasi__c';

import getKodeValues from '@salesforce/apex/SCC_WFM_Upload.getKodeValues';

// import { loadStyle } from 'lightning/platformResourceLoader';
// import 	lwcUploadFileLargeStyle from '@salesforce/resourceUrl/lwcUploadFileLargeStyle';

/** v1 */
// export default class WFMUpload extends LightningElement {
//     type = 'Jadwal Karyawan';
//     @track isAttributeRequired = false;
//     @track fieldLabelName = 'Template '+this.type;
//     filecuti = templatecuti;
//     filepoin = templatepoin;
//     filejadwal = templatejadwal;
//     value = ';';
//     get optionstype() {
//         return [
//             { label: 'Jadwal Karyawan', value: 'Jadwal Karyawan' },
//             { label: 'Cuti Karyawan', value: 'Cuti Karyawan' },
//             { label: 'Poin Karyawan', value: 'Poin Karyawan' },
//         ];
//     }

//     handleChangetype(event) {
//         this.type = event.detail.value;
//         this.fieldLabelName = 'Template '+this.type;
//     }
    
//     get options() {
//         return [
//             { label: ';', value: ';' },
//             { label: ',', value: ',' },
//             { label: '|', value: '|' },
//         ];
//     }

//     handleChange(event) {
//         this.value = event.detail.value;
//     }

//     handleDownload() {
//         const link = document.createElement('a');
//         link.href = '';
//         if(this.type=='Jadwal Karyawan'){
//             link.href = this.filejadwal;
//         }
//         else if(this.type=='Cuti Karyawan'){
//             link.href = this.filecuti;
//         }
//         else if(this.type=='Poin Karyawan'){
//             link.href = this.filepoin;
//         }
//         link.setAttribute('download', this.type+'.csv');
//         document.body.appendChild(link);
//         link.click();
//         document.body.removeChild(link);
//     }
    
//     fileData
//     openfileUpload(event) {
//         const file = event.target.files[0]
//         var reader = new FileReader()
//         reader.onload = () => {
//             var base64 = reader.result.split(',')[1]
//             this.fileData = {
//                 'filename': file.name,
//                 'base64': base64
//             }
//         }
//         reader.readAsDataURL(file)
//     }
    
//     handleSubmit(){
//         const {filename, base64} = this.fileData;
//         uploadFile({ base64, delimiter: this.value, type : this.type }).then(result=>{
//             this.fileData = null
//             let title = 'Success'
//             let message = result
//             let variant = 'success'
//             this.showToast(title, message,variant)
//         }).catch(error => {
//             console.error('Error downloading file: ', error);
//             this.fileData = null
//             let title = 'Error'
//             let message = error.body.message
//             let variant = 'error'
//             this.showToast(title, message,variant)
//             // Handle error
//         });
//     }

//     showToast(title, message, variant) {
//         const event = new ShowToastEvent({
//             title,
//             message,
//             variant
//         });
//         this.dispatchEvent(event);
//     }
// }


/** EXPERIMENT WITH CHECKING PER ROW AND THE COLUMN */
// export default class WFMUpload extends LightningElement {
//     type = 'Jadwal Karyawan';
//     @track isAttributeRequired = false;
//     @track fieldLabelName = 'Template ' + this.type;
//     filecuti = templatecuti;
//     filepoin = templatepoin;
//     filejadwal = templatejadwal;
//     value = ';';
//     fileData = null;

//     get optionstype() {
//         return [
//             { label: 'Jadwal Karyawan', value: 'Jadwal Karyawan' },
//             { label: 'Cuti Karyawan', value: 'Cuti Karyawan' },
//             { label: 'Poin Karyawan', value: 'Poin Karyawan' },
//         ];
//     }

//     handleChangetype(event) {
//         this.type = event.detail.value;
//         this.fieldLabelName = 'Template ' + this.type;
//     }

//     get options() {
//         return [
//             { label: ';', value: ';' },
//             { label: ',', value: ',' },
//             { label: '|', value: '|' },
//         ];
//     }

//     handleChange(event) {
//         this.value = event.detail.value;
//     }

//     handleDownload() {
//         const link = document.createElement('a');
//         link.href = '';
//         if (this.type == 'Jadwal Karyawan') {
//             link.href = this.filejadwal;
//         } else if (this.type == 'Cuti Karyawan') {
//             link.href = this.filecuti;
//         } else if (this.type == 'Poin Karyawan') {
//             link.href = this.filepoin;
//         }
//         link.setAttribute('download', this.type + '.csv');
//         document.body.appendChild(link);
//         link.click();
//         document.body.removeChild(link);
//     }

//     openfileUpload(event) {
//         const file = event.target.files[0];
//         const reader = new FileReader();
//         reader.onload = () => {
//             const base64 = reader.result.split(',')[1];
//             this.fileData = {
//                 'filename': file.name,
//                 'base64': base64
//             };
//         };
//         reader.readAsDataURL(file);
//     }

//     handleSubmit() {
//         const { filename, base64 } = this.fileData;

//         // Read and parse the CSV
//         const fileContent = atob(base64); // Decode the base64 content
//         const rows = this.parseCSV(fileContent, this.value); // Parse the CSV based on the delimiter

//         // Validate the CSV rows
//         const { invalidRows, invalidColumns } = this.validateCSV(rows);

//         if (invalidRows.length > 0) {
//             let errorMessage = `Total Invalid Rows: ${invalidRows.length}\n`;
//             invalidRows.forEach((rowIndex) => {
//                 const rowData = rows[rowIndex - 1]; // Get the actual row data
//                 errorMessage += `Row ${rowIndex}: `;
                
//                 // Include column names of the invalid row
//                 const columnNames = this.getColumnNames(rowIndex);
//                 columnNames.forEach((columnName, colIndex) => {
//                     if (!rowData[colIndex]) {
//                         errorMessage += `Missing value in "${columnName}" column. `;
//                     }
//                 });

//                 // Check for specific issues like TAHUN validation
//                 if (this.type === 'Cuti Karyawan' && rowData[2] && !/^\d{4}$/.test(rowData[2])) {
//                     errorMessage += `Invalid value in "TAHUN" column. Value must be a 4-digit year. `;
//                 }

//                 errorMessage += '\n'; // Ensure each error message starts on a new line
//             });

//             // Show the toast message with multi-line error message
//             this.showToast('Error', errorMessage, 'error');
//             return; // Prevent further submission if there are invalid rows
//         }

//         // If validation passes, upload the file
//         uploadFile({ base64, delimiter: this.value, type: this.type }).then(result => {
//             this.fileData = null;
//             this.showToast('Success', result, 'success');
//         }).catch(error => {
//             console.error('Error uploading file: ', error);
//             this.fileData = null;
//             this.showToast('Error', error.body.message, 'error');
//         });
//     }

//     // Function to parse CSV content into rows
//     parseCSV(content, delimiter) {
//         const lines = content.split('\n');
        
//         // Filter out empty rows or rows with only whitespace
//         return lines
//             .map(line => line.trim())
//             .filter(line => line.length > 0)  // Only include non-empty rows
//             .map(line => line.split(delimiter));
//     }

//     // Function to validate the CSV data
//     validateCSV(rows) {
//         const invalidRows = [];
//         const invalidColumns = [];
//         let requiredColumns;

//         // Determine the number of columns required based on the template type
//         switch (this.type) {
//             case 'Cuti Karyawan':
//                 requiredColumns = 3;
//                 break;
//             case 'Jadwal Karyawan':
//                 requiredColumns = 4;
//                 break;
//             case 'Poin Karyawan':
//                 requiredColumns = 2;
//                 break;
//             default:
//                 requiredColumns = 0;
//         }

//         // Validate each row starting from row 2 (skipping the header row)
//         rows.forEach((row, index) => {
//             // Row index is zero-based, so we add 1 to match the expected 1-based row numbers
//             const rowNumber = index + 1;

//             // Skip the first row (column names) and empty rows
//             if (rowNumber === 1 || row.every(cell => !cell.trim())) {
//                 return;
//             }

//             // Check if the number of columns in the row matches the required columns for the selected template
//             if (row.length !== requiredColumns) {
//                 invalidRows.push(rowNumber); // Save the 1-based row number
//             }

//             // Additional validation for TAHUN (4-digit year)
//             if (this.type === 'Cuti Karyawan' && row[2] && !/^\d{4}$/.test(row[2])) {
//                 invalidRows.push(rowNumber);
//             }
//         });

//         return { invalidRows, invalidColumns };
//     }

//     // Function to return the column names for each template
//     getColumnNames(rowIndex) {
//         let columnNames = [];
//         switch (this.type) {
//             case 'Cuti Karyawan':
//                 columnNames = ['NIP', 'TOTAL CUTI', 'TAHUN'];
//                 break;
//             case 'Jadwal Karyawan':
//                 columnNames = ['NIP', 'KODE', 'TANGGAL', 'LOKASI'];
//                 break;
//             case 'Poin Karyawan':
//                 columnNames = ['NIP', 'SCORE ACHIVMENT'];
//                 break;
//         }
//         return columnNames;
//     }

//     showToast(title, message, variant) {
//         const event = new ShowToastEvent({
//             title,
//             message,
//             variant
//         });
//         this.dispatchEvent(event);
//     }
// }


/** */
export default class WFMUpload extends LightningElement {
    
    type = 'Jadwal Karyawan';
    @track fieldLabelName = 'Template ' + this.type;
    filecuti = templatecuti;
    filepoin = templatepoin;
    filejadwal = templatejadwal;
    value = ';';
    fileData = null;
    totalRows = 0;
    validRows = 0;
    invalidRows = [];
    errorMessages = [];
    showModal = false;

    @track lokasiOptions = [];
    @track kodeOptions = [];
    @track isSubmitting = false;  // Control the loading state
    @track submitButtonLabel = 'Submit';  // Default button label


    // async connectedCallback() {
    //     await this.loadKodeValues();
    // }
    
    // async loadKodeValues() {
    //     try {
    //         console.log('Loading kode values...');
    //         const data = await getKodeValues();
            
    //         if (data) {
    //             // Filter out empty strings or null values
    //             this.kodeOptions = data.filter(kode => kode != null && kode.trim() !== '');
                
    //             this.isDataLoaded = true;
    //             console.log('Kode values loaded successfully:', JSON.stringify(this.kodeOptions));
    //         } else {
    //             throw new Error('No data received from getKodeValues');
    //         }
    //     } catch (error) {
    //         console.error('Error loading Kode values:', error);
    //         this.showToast('Error', 'Failed to load reference data', 'error');
    //         this.isDataLoaded = false;
    //         this.kodeOptions = [];
    //     }
    // }

          // Wire to get object metadata for 'Jadwal_Karyawan__c' object
    @wire(getObjectInfo, { objectApiName: JADWAL_KARYAWAN_OBJECT })
    objectInfo;

    // Wire to get picklist values for 'Lokasi__c' field on 'Jadwal_Karyawan__c' object
    @wire(getPicklistValues, {
        fieldApiName: LOKASI_FIELD,
        recordTypeId: '$objectInfo.data.defaultRecordTypeId'
    })
    wiredPicklistValues({ data, error }) {
        if (data) {
            this.lokasiOptions = data.values.map(option => option.label); // Get the label of each picklist value
        } else if (error) {
            this.showToast('Error', 'Failed to fetch Lokasi picklist values', 'error');
            console.error(error);
        }
    }

    
    @wire(getKodeValues)
    wiredKodeValues({ error, data }) {
        if (data) {
            // Filter out empty strings or null values from the returned data
            this.kodeOptions = data.filter(kode => kode != null && kode.trim() !== '');
            this.isDataLoaded = true;
            console.log('Kode values loaded successfully:', JSON.stringify(this.kodeOptions));
        } else if (error) {
            // Handle errors
            this.error = error;
            this.showToast('Error', 'Failed to load reference data', 'error');
            this.isDataLoaded = false;
            this.kodeOptions = [];
            console.error('Error loading Kode values:', error);
        }
    }

    get optionstype() {
        return [
            { label: 'Jadwal Karyawan', value: 'Jadwal Karyawan' },
            { label: 'Cuti Karyawan', value: 'Cuti Karyawan' },
            { label: 'Poin Karyawan', value: 'Poin Karyawan' },
        ];
    }

    handleChangetype(event) {
        this.type = event.detail.value;
        this.fieldLabelName = 'Template ' + this.type;
    }

    get options() {
        return [
            { label: ';', value: ';' },
            { label: ',', value: ',' },
            { label: '|', value: '|' },
        ];
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleDownload() {
        const link = document.createElement('a');
        link.href = '';
        if (this.type == 'Jadwal Karyawan') {
            link.href = this.filejadwal;
        } else if (this.type == 'Cuti Karyawan') {
            link.href = this.filecuti;
        } else if (this.type == 'Poin Karyawan') {
            link.href = this.filepoin;
        }
        link.setAttribute('download', this.type + '.csv');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
    /** DEFAULT FUNCTION */
    // openfileUpload(event) {
    //     const file = event.target.files[0];
    //     const reader = new FileReader();
    //     reader.onload = () => {
    //         const base64 = reader.result.split(',')[1];
    //         this.fileData = {
    //             'filename': file.name,
    //             'base64': base64
    //         };
    //     };
    //     reader.readAsDataURL(file);
    // }

    //With validation only csv and max 2mb
    // openfileUpload(event) {
    //     const file = event.target.files[0];
    
    //     // Check if a file is selected
    //     if (!file) {
    //         this.showToast('Error', 'No file selected. Please select a file to upload.', 'error');
    //         return;
    //     }
    
    //     // Validate file type
    //     if (file.type !== 'text/csv') {
    //         this.showToast('Error', 'Invalid file type. Please upload a .csv file.', 'error');
    //         return;
    //     }
    
    //     // Validate file size (2MB = 2 * 1024 * 1024 bytes)
    //     const maxSize = 2 * 1024 * 1024;
    //     if (file.size > maxSize) {
    //         this.showToast('Error', 'File size exceeds 2MB. Please upload a smaller file.', 'error');
    //         return;
    //     }
    
    //     // If validations pass, read the file
    //     const reader = new FileReader();
    //     reader.onload = () => {
    //         const base64 = reader.result.split(',')[1];
    //         this.fileData = {
    //             filename: file.name,
    //             base64: base64
    //         };
    //     };
    //     reader.readAsDataURL(file);
    // }

    // openFileUpload(event) {
    //     const file = event.target.files[0];
    //     const reader = new FileReader();
    
    //     if (file) {
    //         reader.onload = () => {
    //             const base64 = reader.result.split(',')[1];
    //             this.fileData = {
    //                 'filename': file.name,
    //                 'base64': base64,
    //                 'size': file.size, // File size in bytes
    //                 'type': file.type // MIME type of the file
    //             };
    //         };
    //         reader.readAsDataURL(file);
    //     } else {
    //         this.fileData = null; // Clear fileData if no file is selected
    //         this.showToast('Warning', 'No file selected.', 'warning');
    //     }
    // }

    openFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.processFile(file);
        } else {
            this.showToast('Warning', 'No file selected.', 'warning');
        }
    }

    /** Check delimiter and the expected column */
    // checkFileDelimiter(content) {
    //     const firstLine = content.split('\n')[0].trim();
    //     const selectedDelimiter = this.value;
        
    //     // Get the expected number of columns based on the template type
    //     const expectedColumns = this.getExpectedColumns();
        
    //     // Split the first line with the user-selected delimiter
    //     const columnsWithSelectedDelimiter = firstLine.split(selectedDelimiter).filter(col => col.trim());
        
    //     // Check if using the selected delimiter gives us the expected number of columns
    //     if (columnsWithSelectedDelimiter.length !== expectedColumns) {
    //         // Try other delimiters to give a helpful error message
    //         const otherDelimiters = [';', ',', '|'].filter(d => d !== selectedDelimiter);
            
    //         for (const delimiter of otherDelimiters) {
    //             const columns = firstLine.split(delimiter).filter(col => col.trim());
    //             if (columns.length === expectedColumns) {
    //                 this.showToast(
    //                     'Error', 
    //                     `Delimiter yang dipilih tidak sesuai. File menggunakan '${delimiter}' sebagai pemisah, tetapi Anda memilih '${selectedDelimiter}'. Silakan pilih pemisah yang sesuai.`,
    //                     'error'
    //                 );
    //                 return false;
    //             }
    //         }
            
    //         this.showToast(
    //             'Error',
    //             `Format file tidak valid atau delimiter yang dipilih tidak sesuai. Diharapkan ${expectedColumns} kolom dengan pemisah '${selectedDelimiter}'.`,
    //             'error'
    //         );
    //         return false;
    //     }
        
    //     return true;
    // }

    /** Only check delimiter */
    checkFileDelimiter(content) {
        const firstLine = content.split('\n')[0].trim();
        const selectedDelimiter = this.value;
        
        // Try other delimiters to see if they give different column counts
        const otherDelimiters = [';', ',', '|'].filter(d => d !== selectedDelimiter);
        
        for (const delimiter of otherDelimiters) {
            // Compare split results between selected and other delimiters
            const columnsWithSelected = firstLine.split(selectedDelimiter).filter(col => col.trim());
            const columnsWithOther = firstLine.split(delimiter).filter(col => col.trim());
            
            // If another delimiter gives a different column count, it's likely the actual delimiter
            if (columnsWithOther.length > columnsWithSelected.length) {
                this.showToast(
                    'Error', 
                    `Delimiter yang dipilih tidak sesuai. File menggunakan '${delimiter}' sebagai pemisah, tetapi Anda memilih '${selectedDelimiter}'. Silakan pilih delimiter yang sesuai.`,
                    'error'
                );
                return false;
            }
        }
        
        return true;
    }
    
    getExpectedColumns() {
        switch (this.type) {
            case 'Jadwal Karyawan':
                return 4;
            case 'Cuti Karyawan':
                return 3;
            case 'Poin Karyawan':
                return 2;
            default:
                return 0;
        }
    }
    

    /** DEFAULT */
    // processFile(file) {
    //     const reader = new FileReader();
    
    //     reader.onload = () => {
    //         const base64 = reader.result.split(',')[1];  // Extract base64 data from the result
    //         this.fileData = {
    //             filename: file.name,
    //             base64: base64,
    //             size: file.size,
    //             type: file.type
    //         };
    
    //         console.log('File processed:', this.fileData);  // Log the file data
    //     };
    
    //     reader.onerror = () => {
    //         console.error('Error reading file');
    //         this.showToast('Error', 'Failed to read the file.', 'error');
    //     };
    
    //     reader.readAsDataURL(file);
    // }

    /** v2 - With checking delimiter */
    processFile(file) {
        const reader = new FileReader();
        
        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            const content = atob(base64);
            
            // Check delimiter before proceeding
            if (!this.checkFileDelimiter(content)) {
                // this.fileData = null;  // Opptional Clear file data
                return; // Stop processing if delimiter is incorrect
            }
            
            // If delimiter is correct, proceed with file processing
            this.fileData = {
                filename: file.name,
                base64: base64,
                size: file.size,
                type: file.type
            };
            
            console.log('File diproses:', this.fileData);
        };
        
        reader.onerror = () => {
            console.error('Error membaca file');
            this.showToast('Error', 'Gagal membaca file.', 'error');
        };
        
        reader.readAsDataURL(file);
    }
    
    /** 
    handleSubmit() {
        if (!this.fileData) {
            this.showToast('Peringatan', 'Tolong upload file terlebih dahulu.', 'warning');
            return; // Prevent further action if no file is uploaded
        }
        
        this.isSubmitting = true;  // Start submission process
        this.submitButtonLabel = 'Processing...';  // Change button label

        const { filename, base64 } = this.fileData;

        // Read and parse the CSV
        const fileContent = atob(base64); // Decode the base64 content
        const rows = this.parseCSV(fileContent, this.value); // Parse the CSV based on the delimiter

        // Validate the CSV rows
        const { invalidRows, errorMessages } = this.validateCSV(rows);

        // Update total rows, valid and invalid rows
        this.totalRows = rows.length;
        this.invalidRows = invalidRows;
        this.validRows = this.totalRows - this.invalidRows.length;

        if (invalidRows.length > 0) {
            this.errorMessages = errorMessages;
            this.showModal = true;
            this.isSubmitting = false;  // Stop the spinner and reset button
            this.submitButtonLabel = 'Submit';  // Reset button label
            return; // Prevent further submission if there are invalid rows
        }

        // Directly proceed to upload if all rows are valid
        this.uploadFileData();
    }
    */

    handleSubmit() {
        // Check if a file is selected
        if (!this.fileData) {
            this.showToast('Error', 'Silakan pilih/masukan file terlebih dahulu sebelum submit.', 'error');
            return;
        }
    
        // Validate file type
        const fileName = this.fileData.filename.toLowerCase();
        if (!fileName.endsWith('.csv')) {
            this.showToast('Error', 'Tipe file tidak valid. Silakan unggah file .csv', 'error');
            return;
        }
    
        // Validate file size (2MB = 2 * 1024 * 1024 bytes)
        const maxFileSize = 2 * 1024 * 1024; // 2MB
        if (this.fileData.size > maxFileSize) {
            this.showToast('Error', 'Ukuran file melebihi 2MB. Silakan unggah file yang lebih kecil.', 'error');
            return;
        }
    
        // Start the submission process
        this.isSubmitting = true;
        this.submitButtonLabel = 'Processing...';
    
        const { filename, base64 } = this.fileData;
    
        try {
            // Decode and parse the CSV content
            const fileContent = atob(base64); // Decode the base64 content

            // First check the delimiter before proceeding
            if (!this.checkFileDelimiter(fileContent)) {
                this.isSubmitting = false;
                this.submitButtonLabel = 'Submit';
                // this.fileData = null; // Opptional Clear file data
                return;
            }

            // const rows = this.parseCSV(fileContent, this.value); // Parse the CSV using the specified delimiter

            let rows = this.parseCSV(fileContent, this.value); // Parse the CSV using the specified delimiter

            // Trim all rows and cells to remove extra whitespace
            rows = rows.map(row => row.map(cell => cell.trim())); // Trim each cell in each row
            rows = rows.filter(row => row.some(cell => cell.trim().length > 0)); // Remove rows where all cells are empty after trimming

            // Trim the first row (header row) from the CSV
            // rows = rows.slice(1); // Removes the first row
    
            // Validate the parsed CSV rows
            const { invalidRows, errorMessages } = this.validateCSV(rows);
    
            // Update row counts
            this.totalRows = rows.length;
            this.invalidRows = invalidRows;
            this.validRows = this.totalRows - this.invalidRows.length;
    
            // If there are invalid rows, display errors and stop submission
            if (invalidRows.length > 0) {
                this.errorMessages = errorMessages;
                this.showModal = true;
                this.isSubmitting = false; // Reset the spinner
                this.submitButtonLabel = 'Submit'; // Reset button label
                return;
            }
    
            // Proceed to upload if all rows are valid
            this.uploadFileData();

            // Reset the spinner and button after upload completion
            // this.isSubmitting = false;
            // this.submitButtonLabel = 'Submit';
        } catch (error) {
            // Handle unexpected errors during file processing
            console.error('Error during file submission:', error);
            this.showToast('Error', 'An unexpected error occurred during file submission.', 'error');
            // Ensure the button state is reset
            this.isSubmitting = false;
            this.submitButtonLabel = 'Submit';
        }
    }
    

    // Function to parse CSV content into rows
    // parseCSV(content, delimiter) {
    //     const lines = content.split('\n');
        
    //     // Filter out empty rows or rows with only whitespace
    //     return lines
    //         .map(line => line.trim())
    //         .filter(line => line.length > 0)  // Only include non-empty rows
    //         .map(line => line.split(delimiter));
    // }

    parseCSV(content, delimiter) {
        const lines = content.split('\n'); // Split by line breaks
    
        return lines
            .map(line => line.trim()) // Trim the line to avoid leading/trailing spaces
            .filter(line => line.length > 0) // Remove empty lines
            .map(line => {
                // Split by the delimiter
                const cells = line.split(delimiter).map(cell => {
                    // Remove any surrounding quotes and trim extra spaces
                    return cell.replace(/^"|"$/g, '').trim();
                });
                return cells;
            });
    }

    // Function to parse CSV content into rows, handling quoted values and delimiters
    // parseCSV(content, delimiter) {
    //     const lines = content.split('\n'); // Split by line breaks
        
    //     return lines
    //         .map(line => {
    //             let insideQuotes = false;
    //             let cell = '';
    //             const cells = [];
    //             const trimmedLine = line.trim(); // Trim the line to avoid leading/trailing spaces
    
    //             for (let i = 0; i < trimmedLine.length; i++) {
    //                 const char = trimmedLine[i];
    
    //                 if (char === '"') {
    //                     // Toggle insideQuotes when encountering a quote character
    //                     insideQuotes = !insideQuotes;
    //                 } else if (char === delimiter && !insideQuotes) {
    //                     // If the delimiter is outside of quotes, split the cell
    //                     cells.push(cell.trim()); // Trim the value to avoid spaces
    //                     cell = ''; // Reset cell for the next value
    //                 } else {
    //                     cell += char; // Add the character to the current cell
    //                 }
    //             }
    
    //             // Add the last cell for the line (after finishing the loop)
    //             if (cell.length > 0 || cells.length === 0) {
    //                 cells.push(cell.trim()); // Trim each value in case of spaces
    //             }
    
    //             return cells;
    //         })
    //         .filter(row => row.some(cell => cell.length > 0)); // Remove empty rows
    // }
    

    // Function to validate the CSV data and generate error messages
    // validateCSV(rows) {
    //     const invalidRows = [];
    //     const errorMessages = [];
    //     let requiredColumns;

    //     // Determine the number of columns required based on the template type
    //     switch (this.type) {
    //         case 'Cuti Karyawan':
    //             requiredColumns = 3;
    //             break;
    //         case 'Jadwal Karyawan':
    //             requiredColumns = 4;
    //             break;
    //         case 'Poin Karyawan':
    //             requiredColumns = 2;
    //             break;
    //         default:
    //             requiredColumns = 0;
    //     }

    //     // Validate each row starting from row 2 (skipping the header row)
    //     rows.forEach((row, index) => {
    //         const rowNumber = index + 1;
    //         let rowErrors = []; // This will hold all errors for this row

    //         if (rowNumber === 1 || row.every(cell => !cell.trim())) {
    //             return;
    //         }

    //         if (row.length !== requiredColumns) {
    //             invalidRows.push(rowNumber); // Save the 1-based row number
    //             rowErrors.push(`Jumlah kolom tidak valid. Diharapkan ${requiredColumns}, ditemukan ${row.length}.`);
    //         }

    //         if (this.type === 'Cuti Karyawan') {
    //             if (!/^\d{8}$/.test(row[0])) { // NIP validation
    //                 rowErrors.push(`[NIP] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
    //             }
    //             if (!/^\d+$/.test(row[1])) { // TOTAL CUTI validation
    //                 rowErrors.push(`[TOTAL CUTI] tidak valid. Harus berupa angka`);
    //             }
    //             if (!/^\d{4}$/.test(row[2])) { // TAHUN validation
    //                 rowErrors.push(`[TAHUN] tidak valid. Harus berupa angka 4 digit (yyyy)`);
    //             }
    //         } else if (this.type === 'Jadwal Karyawan') {
    //             if (!/^\d{8}$/.test(row[0])) { // NIP validation
    //                 rowErrors.push(`[NIP] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
    //             }
    //             // if (row[1] && !this.kodeOptions.includes(row[1])) { // KODE validation
    //             //     rowErrors.push(`[KODE] tidak valid. Nilai yang valid adalah salah satu dari: ${this.kodeOptions.join(', ')} (*perhatikan case-sensitive)`);
    //             // }
    //             if (this.kodeOptions && this.kodeOptions.length > 0) {
    //                 if (row[1] && !this.kodeOptions.includes(row[1])) { // KODE validation
    //                     rowErrors.push(`[KODE] tidak valid. Nilai yang valid adalah salah satu dari: ${this.kodeOptions.join(', ')} (*perhatikan case-sensitive)`);
    //                 }
    //             }
    //             if (row[2] && !/^\d{4}-\d{2}-\d{2}$/.test(row[2])) { // Tanggal validation
    //                 rowErrors.push(`[TANGGAL] tidak valid. Harus dalam format yyyy-mm-dd`);
    //             }
    //             // const validLocations = ['KB-KEBAYORAN', 'KP-KANTOR PUSAT', 'WB-WARUNG BUNCIT', 'SEMARANG'];
    //             // if (row[3] && !validLocations.includes(row[3])) { // LOKASI validation
    //             //     rowErrors.push(`[LOKASI] tidak valid. Nilai yang valid adalah KB-KEBAYORAN, KP-KANTOR PUSAT, WB-WARUNG BUNCIT, SEMARANG`);
    //             // }
    //             if (row[3] && !this.lokasiOptions.includes(row[3])) {
    //                 rowErrors.push(`[LOKASI] tidak valid. Nilai yang valid adalah salah satu dari: ${this.lokasiOptions.join(', ')} (*perhatikan case-sensitive)`);
    //             }
                
    //         } else if (this.type === 'Poin Karyawan') {
    //             if (!/^\d{8}$/.test(row[0])) { // NIP validation
    //                 rowErrors.push(`[NIP] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
    //             }
    //             if (!/^\d{1,3}$/.test(row[1]) || Number(row[1]) < 0 || Number(row[1]) > 100) { // SCORE ACHIEVEMENT validation
    //                 rowErrors.push(`[SCORE ACHIEVEMENT] tidak valid. Harus berupa angka antara 0 dan 100`);
    //             }
    //         }

    //         // if (rowErrors.length > 0) {
    //         //     // Only append a comma if there are multiple errors, If there is only one error, add a dot at the end
    //         //     // const errorMessage = `Baris ${rowNumber}: ${rowErrors.length === 1 ? rowErrors[0] + '.' : rowErrors.join(', ')}`;
    //         //     const errorMessage = `Baris ${rowNumber}: ${rowErrors.length === 1 ? rowErrors[0] + '.' : rowErrors.join(', ') + '.'}`;
    //         //     errorMessages.push(errorMessage);
    //         //     invalidRows.push(rowNumber); // Only mark the row as invalid once
    //         // }

    //         // If there are any errors for the row, format them and push to errorMessages
    //         if (rowErrors.length > 0) {
    //             errorMessages.push({
    //                 row: rowNumber,
    //                 errors: rowErrors
    //             });
    //             invalidRows.push(rowNumber); // Mark the row as invalid
    //         }
    //         });

    //     return { invalidRows, errorMessages };
    // }

    // validateCSV(rows) {
    //     const invalidRows = [];
    //     const errorMessages = [];
    //     let requiredColumns;

    //     switch (this.type) {
    //         case 'Cuti Karyawan':
    //             requiredColumns = 3;
    //             break;
    //         case 'Jadwal Karyawan':
    //             requiredColumns = 4;
    //             break;
    //         case 'Poin Karyawan':
    //             requiredColumns = 2;
    //             break;
    //         default:
    //             requiredColumns = 0;
    //     }

    //     rows.forEach((row, index) => {
    //         const rowNumber = index + 1;
    //         let rowErrors = [];

    //         if (rowNumber === 1 || row.every(cell => !cell.trim())) {
    //             return;
    //         }

    //         if (row.length !== requiredColumns) {
    //             invalidRows.push(rowNumber);
    //             rowErrors.push(`Jumlah kolom tidak valid. Diharapkan ${requiredColumns}, ditemukan ${row.length}.`);
    //         }

    //         if (this.type === 'Jadwal Karyawan') {
    //             if (!/^\d{8}$/.test(row[0])) {
    //                 rowErrors.push(`[NIP] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
    //             }
                
    //             // Improved KODE validation with proper error message
    //             if (row[1]) {
    //                 if (this.kodeOptions && this.kodeOptions.length > 0) {
    //                     if (!this.kodeOptions.includes(row[1])) {
    //                         // Format the kode values list with proper spacing and quotes
    //                         const validKodesList = this.kodeOptions
    //                             .map(kode => `"${kode}"`)
    //                             .join(', ');
    //                         rowErrors.push(`[KODE] tidak valid. Nilai yang valid adalah salah satu dari: ${validKodesList} (*perhatikan case-sensitive)`);
    //                     }
    //                 } else {
    //                     rowErrors.push(`[KODE] tidak valid. Tidak dapat memverifikasi kode karena data referensi tidak tersedia.`);
    //                 }
    //             }

    //             if (row[2] && !/^\d{4}-\d{2}-\d{2}$/.test(row[2])) {
    //                 rowErrors.push(`[TANGGAL] tidak valid. Harus dalam format yyyy-mm-dd`);
    //             }

    //             if (row[3] && !this.lokasiOptions.includes(row[3])) {
    //                 const validLocationsList = this.lokasiOptions.join(', ');
    //                 rowErrors.push(`[LOKASI] tidak valid. Nilai yang valid adalah salah satu dari: ${validLocationsList} (*perhatikan case-sensitive)`);
    //             }
    //         } else if (this.type === 'Cuti Karyawan') {
    //             if (!/^\d{8}$/.test(row[0])) {
    //                 rowErrors.push(`[NIP] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
    //             }
    //             if (!/^\d+$/.test(row[1])) {
    //                 rowErrors.push(`[TOTAL CUTI] tidak valid. Harus berupa angka`);
    //             }
    //             if (!/^\d{4}$/.test(row[2])) {
    //                 rowErrors.push(`[TAHUN] tidak valid. Harus berupa angka 4 digit (yyyy)`);
    //             }
    //         } else if (this.type === 'Poin Karyawan') {
    //             if (!/^\d{8}$/.test(row[0])) {
    //                 rowErrors.push(`[NIP] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
    //             }
    //             if (!/^\d{1,3}$/.test(row[1]) || Number(row[1]) < 0 || Number(row[1]) > 100) {
    //                 rowErrors.push(`[SCORE ACHIEVEMENT] tidak valid. Harus berupa angka antara 0 dan 100`);
    //             }
    //         }

    //         if (rowErrors.length > 0) {
    //             errorMessages.push({
    //                 row: rowNumber,
    //                 errors: rowErrors
    //             });
    //             invalidRows.push(rowNumber);
    //         }
    //     });

    //     return { invalidRows, errorMessages };
    // }

    validateCSV(rows) {
        const invalidRows = [];
        const errorMessages = [];
        let requiredColumns;

        switch (this.type) {
            case 'Cuti Karyawan':
                requiredColumns = 3;
                break;
            case 'Jadwal Karyawan':
                requiredColumns = 4;
                break;
            case 'Poin Karyawan':
                requiredColumns = 2;
                break;
            default:
                requiredColumns = 0;
        }

        rows.forEach((row, index) => {
            const rowNumber = index + 1;
            let rowErrors = [];

            if (rowNumber === 1 || row.every(cell => !cell.trim())) {
                return; // Skip the first row or any row with only empty cells
            }

            // // Check for the correct number of columns
            // if (row.length !== requiredColumns) {
            //     invalidRows.push(rowNumber);
            //     rowErrors.push(`Jumlah kolom tidak valid. Diharapkan ${requiredColumns}, ditemukan ${row.length}.`);
            // }

            // Get the column names for the current type
            const columnNames = this.getColumnNames();

            // Newly added 17/02/2025, Check for missing columns
            if (row.length !== requiredColumns) {
                invalidRows.push(rowNumber);
                if (row.length < requiredColumns) {
                    // Identify which columns are missing
                    const missingColumns = columnNames.slice(row.length);
                    rowErrors.push(`Kolom yang hilang: ${missingColumns.join(', ')} (*perhatikan case-sensitive)`);
                } else {
                    // If there are extra columns
                    rowErrors.push(`Terlalu banyak kolom. Hanya diperlukan: ${columnNames.join(', ')} (*perhatikan case-sensitive)`);
                }
            }

            // Check for any empty cells in the row
            row.forEach((cell, colIndex) => {
                if (cell.trim().length === 0) {
                    rowErrors.push(`Baris ${rowNumber}, kolom [${columnNames[colIndex]}] kosong`);
                }
            });

            // Additional validations based on the template type
            if (this.type === 'Jadwal Karyawan') {
                if (!/^\d{8}$/.test(row[0])) {
                    rowErrors.push(`[NIP - ${row[0]}] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
                }
                
                if (row[1]) {
                    const availableKodes = this.kodeOptions.join(', ');
                    if (!this.kodeOptions.includes(row[1])) { 
                        rowErrors.push(`[KODE - ${row[1]}] tidak valid. Nilai yang tersedia: ${availableKodes} (*perhatikan case-sensitive)`);
                    }
                }

                if (row[2] && !/^\d{4}-\d{2}-\d{2}$/.test(row[2])) {
                    rowErrors.push(`[TANGGAL - ${row[2]}] tidak valid. Harus dalam format yyyy-mm-dd`);
                }

                if (row[3] && !this.lokasiOptions.includes(row[3])) {
                    const validLocationsList = this.lokasiOptions.join(', ');
                    rowErrors.push(`[LOKASI - ${row[3]}] tidak valid. Nilai yang tersedia: ${validLocationsList} (*perhatikan case-sensitive)`);
                }
            } else if (this.type === 'Cuti Karyawan') {
                if (!/^\d{8}$/.test(row[0])) {
                    rowErrors.push(`[NIP - ${row[0]}] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
                }
                if (!/^\d+$/.test(row[1])) {
                    rowErrors.push(`[TOTAL CUTI - ${row[1]}] tidak valid. Harus berupa angka`);
                }
                if (!/^\d{4}$/.test(row[2])) {
                    rowErrors.push(`[TAHUN - ${row[2]}] tidak valid. Harus berupa angka 4 digit (yyyy)`);
                }
            } else if (this.type === 'Poin Karyawan') {
                if (!/^\d{8}$/.test(row[0])) {
                    rowErrors.push(`[NIP - ${row[0]}] tidak valid. Harus berupa angka dengan panjang maksimal 8 digit`);
                }

                // Check if the score contains a comma, and if so, replace it with a dot
                let score = row[1].includes(',') ? row[1].replace(',', '.') : row[1];

                // Validate if the score is a valid number and within the 0-100 range (inclusive)
                if (!/^\d{1,3}(\.\d+)?$/.test(score) || Number(score) < 0 || Number(score) > 100) {
                    rowErrors.push(`[SCORE ACHIEVEMENT - ${row[1]}] tidak valid. Harus berupa angka antara 0 dan 100`);
                }

            }

            if (rowErrors.length > 0) {
                errorMessages.push({
                    row: rowNumber,
                    errors: rowErrors
                });
                invalidRows.push(rowNumber);
            }
        });

        return { invalidRows, errorMessages };
    }

    // uploadFileData() {
    //     const { base64 } = this.fileData;

    //     uploadFile({
    //         base64,
    //         delimiter: this.value,
    //         type: this.type
    //     })
    //     .then(result => {
    //         this.fileData = null;  // Reset fileData after successful upload
    //         this.showToast('Success', result, 'success');  // Show success toast message
    //         this.isSubmitting = false;  // Stop spinner after successful upload
    //         this.submitButtonLabel = 'Submit';  // Reset button label
    //     })
    //     .catch(error => {
    //         console.error('Error uploading file: ', error);
    //         this.fileData = null;  // Reset fileData in case of error
    //         this.showToast('Error', error.body.message, 'error');  // Show error toast message
    //         this.isSubmitting = false;  // Stop the spinner if error occurs
    //         this.submitButtonLabel = 'Submit';  // Reset button label
    //     })
    
    // }

    uploadFileData() {
        const { base64 } = this.fileData;
        uploadFile({
            base64,
            delimiter: this.value,
            type: this.type
        })
        .then(result => {
            this.fileData = null;  // Reset fileData after upload
            
            const message = `Diproses = ${result.berhasil} & Gagal = ${result.gagal}, ${result.deskripsi}`;
            let toastType;
            let toastHeader;
            
            if (result.gagal === 0 && result.berhasil > 0) {
                // All successful
                toastType = 'success';
            } else if (result.berhasil === 0 && result.gagal > 0) {
                // All failed
                toastType = 'error';
            } else if (result.berhasil > 0 && result.gagal > 0) {
                // Partial success
                toastType = 'warning';
            }
            
            this.showToast('Process Result', message, toastType);
            this.isSubmitting = false;
            this.submitButtonLabel = 'Submit';
        })
        .catch(error => {
            console.error('Error uploading file: ', error);
            this.fileData = null;
            this.showToast('Error', error.body.message, 'error');
            this.isSubmitting = false;
            this.submitButtonLabel = 'Submit';
        });
    }

    // Function to return the column names for each template
    getColumnNames(rowIndex) {
        let columnNames = [];
        switch (this.type) {
            case 'Cuti Karyawan':
                columnNames = ['NIP', 'TOTAL CUTI', 'TAHUN'];
                break;
            case 'Jadwal Karyawan':
                columnNames = ['NIP', 'KODE', 'TANGGAL', 'LOKASI'];
                break;
            case 'Poin Karyawan':
                columnNames = ['NIP', 'SCORE ACHIEVEMENT'];
                break;
        }
        return columnNames;
    }

    handleModalClose() {
        this.showModal = false;
    }

    handleModalProceed() {
        this.showModal = false;
        this.uploadFileData();
    }

    /** FUNCTION FOR ATTACHMENT INPUT */

    // Handle when a file is dragged over the drop zone
    handleDragOver(event) {
        event.preventDefault(); // Prevent the default behavior (e.g., opening the file)
        this.template.querySelector('.custom-dropzone').classList.add('hovered'); // Add hover effect
    }

    // Handle when a file is dragged into the drop zone
    handleDragEnter(event) {
        event.preventDefault(); // Prevent the default behavior
        this.template.querySelector('.custom-dropzone').classList.add('hovered'); // Add hover effect
    }

    // Handle when a file is dragged out of the drop zone
    handleDragLeave() {
        this.template.querySelector('.custom-dropzone').classList.remove('hovered'); // Remove hover effect
    }

    // Handle when a file is dropped in the drop zone
    handleDrop(event) {
        event.preventDefault(); // Prevent the default behavior
        this.template.querySelector('.custom-dropzone').classList.remove('hovered'); // Remove hover effect

        // const file = event.dataTransfer.files[0]; // Get the dropped file
        // if (file) {
        //     const reader = new FileReader();
        //     reader.onload = () => {
        //         const base64 = reader.result.split(',')[1]; // Get base64 string from the reader result
        //         this.fileData = {
        //             'filename': file.name,
        //             'base64': base64
        //         };
        //         console.log('File dropped:', this.fileData);
        //     };
        //     reader.readAsDataURL(file);
        // }

        const file = event.dataTransfer.files[0];
        if (file) {
            this.processFile(file);
        }
    }
    /** END FUNCTION FOR ATTACHMENT INPUT */

    /** UTILITIES FUNCTION */
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
    /** END UTILITIES FUNCTION */

}