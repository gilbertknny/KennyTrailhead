import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getAvailableTemplates from '@salesforce/apex/CSVUploadController.getAvailableTemplates';
import previewCSVData from '@salesforce/apex/CSVUploadController.previewCSVData';
import processCSVUpload from '@salesforce/apex/CSVUploadController.processCSVUpload';

export default class CsvUploader extends NavigationMixin(LightningElement) {
    @track templateOptions = [];
    @track selectedTemplateId = '';
    @track selectedTemplate = null;
    @track fileContent = '';
    @track fileName = 'No file selected';
    @track previewData = null;
    @track processResult = null;
    @track isProcessing = false;

    // Wire method to get available templates
    @wire(getAvailableTemplates)
    wiredTemplates({ error, data }) {
        if (data) {
            this.templateOptions = data.map(template => ({
                label: template.label,
                value: template.id,
                caseType: template.caseType,
                fieldNames: template.fieldNames
            }));
        } else if (error) {
            this.showToast('Error', 'Error loading templates: ' + error.body.message, 'error');
        }
    }

    // Handle template selection change
    handleTemplateChange(event) {
        this.selectedTemplateId = event.detail.value;
        this.selectedTemplate = this.templateOptions.find(
            option => option.value === this.selectedTemplateId
        );
        this.resetUploadState();
    }

    // Handle download template
    // handleDownloadTemplate() {
    //     if (!this.selectedTemplate) {
    //         this.showToast('Warning', 'Silahkan pilih template terlebih dahulu', 'warning');
    //         return;
    //     }

    //     try {
    //         // Create CSV content with headers
    //         const headers = this.selectedTemplate.fieldNames.split(',')
    //             .map(field => field.trim());
    //         const csvContent = headers.join(',') + '\n';
            
    //         // Create and download file
    //         const element = document.createElement('a');
    //         const file = new Blob([csvContent], { type: 'text/csv' });
    //         element.href = URL.createObjectURL(file);
    //         element.download = `Template_${this.selectedTemplate.label}.csv`;
    //         document.body.appendChild(element);
    //         element.click();
    //         document.body.removeChild(element);
            
    //         this.showToast('Success', 'Template downloaded successfully', 'success');
    //     } catch (error) {
    //         this.showToast('Error', 'Error downloading template: ' + error.message, 'error');
    //     }
    // }

    handleDownloadTemplate() {
    if (!this.selectedTemplate) {
        this.showToast('Warning', 'Silahkan pilih template terlebih dahulu', 'warning');
        return;
    }

    try {
        // Prepare CSV content
        const headers = this.selectedTemplate.fieldNames
            .split(',')
            .map(field => field.trim());
        const csvContent = headers.join(',') + '\n';

        // Encode as Base64 to bypass LWS restrictions
        const base64Data = btoa(unescape(encodeURIComponent(csvContent)));

        // Create a data URL for download
        const element = document.createElement('a');
        element.href = `data:text/csv;charset=utf-8;base64,${base64Data}`;
        element.download = `Template_${this.selectedTemplate.label}.csv`;
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);

        this.showToast('Success', 'Template downloaded successfully', 'success');
    } catch (error) {
        this.showToast('Error', 'Error downloading template: ' + error.message, 'error');
    }
}


    // Handle file selection change
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            if (!file.name.endsWith('.csv')) {
                this.showToast('Error', 'Please select a CSV file', 'error');
                return;
            }
            
            this.fileName = file.name;
            const reader = new FileReader();
            
            reader.onload = (e) => {
                this.fileContent = e.target.result;
            };
            
            reader.onerror = () => {
                this.showToast('Error', 'Error reading file', 'error');
            };
            
            reader.readAsText(file);
        }
    }

    // Handle lightning-file-upload finished
    handleUploadFinished(event) {
        // This is for the lightning-file-upload component
        // In practice, you might want to handle this differently
        // as lightning-file-upload typically uploads to Salesforce Files
        this.showToast('Info', 'Please use the manual file selector below', 'info');
    }

    // Handle upload click with confirmation
    async handleUploadClick() {
        // Validation: check if template is selected
        if (!this.selectedTemplateId) {
            this.showToast('Warning', 'Silahkan pilih template terlebih dahulu', 'warning');
            return;
        }

        // Validation: check if file is selected
        if (!this.fileContent) {
            this.showToast('Warning', 'Please select a CSV file first', 'warning');
            return;
        }

        // Show confirmation dialog
        const result = await this.showConfirmationDialog();
        if (!result) {
            return;
        }

        // Proceed with upload
        this.isProcessing = true;
        this.previewData = null;
        this.processResult = null;

        try {
            const result = await previewCSVData({
                csvData: this.fileContent,
                templateId: this.selectedTemplateId
            });

            this.previewData = result;
            
            if (result.success) {
                this.showToast('Success', 'CSV preview generated successfully', 'success');
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Error processing CSV: ' + error.body.message, 'error');
            this.previewData = null;
        } finally {
            this.isProcessing = false;
        }
    }

    // Getter to transform preview data with unique keys for LWC rendering
    get previewDataWithKeys() {
        if (!this.previewData || !this.previewData.previewData) {
            return [];
        }
        
        return this.previewData.previewData.map((row, rowIndex) => ({
            id: `row-${rowIndex}`,
            cells: row.map((cell, cellIndex) => ({
                id: `cell-${rowIndex}-${cellIndex}`,
                value: cell
            }))
        }));
    }

    // Handle process data
    async handleProcessData() {
        this.isProcessing = true;
        this.processResult = null;

        try {
            const result = await processCSVUpload({
                csvData: this.fileContent,
                templateId: this.selectedTemplateId
            });

            this.processResult = result;
            
            if (result.success) {
                this.showToast('Success', result.message, 'success');
                // Reset form after successful processing
                setTimeout(() => {
                    this.handleReset();
                }, 3000);
            } else {
                this.showToast('Error', result.message, 'error');
            }
        } catch (error) {
            this.showToast('Error', 'Error processing data: ' + error.body.message, 'error');
            this.processResult = {
                success: false,
                message: error.body.message,
                recordsProcessed: 0,
                errors: [error.body.message]
            };
        } finally {
            this.isProcessing = false;
        }
    }

    // Handle reset
    handleReset() {
        this.selectedTemplateId = '';
        this.selectedTemplate = null;
        this.fileContent = '';
        this.fileName = 'No file selected';
        this.previewData = null;
        this.processResult = null;
        this.isProcessing = false;
        
        // Reset file input
        const fileInput = this.template.querySelector('#file-input');
        if (fileInput) {
            fileInput.value = '';
        }
    }

    // Reset upload state when template changes
    resetUploadState() {
        this.fileContent = '';
        this.fileName = 'No file selected';
        this.previewData = null;
        this.processResult = null;
        
        // Reset file input
        const fileInput = this.template.querySelector('#file-input');
        if (fileInput) {
            fileInput.value = '';
        }
    }

    // Show confirmation dialog
    showConfirmationDialog() {
        return new Promise((resolve) => {
            const result = confirm('Are you sure you want to upload this file?');
            resolve(result);
        });
    }

    // Utility method to show toast messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    // Getter for checking if there are errors
    get hasErrors() {
        return this.processResult && 
               this.processResult.errors && 
               this.processResult.errors.length > 0;
    }
}