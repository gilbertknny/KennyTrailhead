// documentUploader.js
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadCsvFile from '@salesforce/apex/SCC_CampaignDetailCsvUploaderController.uploadCsvFile';
import downloadTemplate from '@salesforce/apex/SCC_CampaignDetailCsvUploaderController.downloadTemplate';

export default class DocumentUploader extends LightningElement {
    @api recordId; // Campaign ID
    @track isLoading = false;
    @track selectedCategory = '';
    @track isTemplateDownloadDisabled = true;
    
    // Constants
    MAX_FILE_SIZE = 25 * 1024 * 1024; // 25MB in bytes
    MAX_ROWS = 45000; // Maximum rows allowed for safe processing

    get categoryOptions() {
        return [
            { label: 'C1', value: 'C1' },
            { label: 'C2', value: 'C2' },
            { label: 'Privy', value: 'Privy' },
            { label: '4in1', value: '4in1' },
            { label: 'LOP', value: 'LOP' },
            { label: 'BRING', value: 'BRING' },
            { label: 'Briguna Digital', value: 'Briguna' },
            { label: 'Briguna Umum', value: 'Briguna_Umum' },
            { label: 'RDN', value: 'RDN' },
            { label: 'SBR', value: 'SBR' }
        ];
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.isTemplateDownloadDisabled = !this.selectedCategory;
    }

    handleTemplateDownload() {
        if (!this.selectedCategory) {
            this.showToast('Error', 'Please select a category first', 'error');
            return;
        }

        const templateName = 'JSM_' + this.selectedCategory;
        downloadTemplate({ templateName: templateName })
            .then(result => {
                const element = document.createElement('a');
                element.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(result);
                element.download = templateName + '.csv';
                element.style.display = 'none';
                document.body.appendChild(element);
                element.click();
                document.body.removeChild(element);
                
                this.showToast('Success', 'Template downloaded successfully', 'success');
            })
            .catch(error => {
                this.showToast('Error', 'Error downloading template: ' + error.body.message, 'error');
            });
    }

    handleDragOver(event) {
        event.preventDefault();
    }

    handleDrop(event) {
        event.preventDefault();
        const files = event.dataTransfer.files;
        if (files.length > 0) {
            this.processFile(files[0]);
        }
    }

    handleDropzoneClick() {
        const fileInput = this.template.querySelector('input[type="file"]');
        if (fileInput) {
            fileInput.click();
        }
    }

    resetFileInput() {
        const fileInput = this.template.querySelector('input[type="file"]');
        if (fileInput) {
            fileInput.value = '';
        }
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            this.processFile(file);
        }
    }

    validateRowCount(content) {
        const rows = content.split(/\r\n|\r|\n/);
        const dataRows = rows.length - 1;
        
        if (dataRows > this.MAX_ROWS) {
            throw new Error(`Jumlah baris melebihi batas maksimum ${this.MAX_ROWS.toLocaleString()} baris. File Anda memiliki ${dataRows.toLocaleString()} baris.`);
        }
        return true;
    }

    processFile(file) {
        // Validate file extension
        if (!file.name.endsWith('.csv')) {
            this.showToast('Error', 'Please upload a valid CSV file', 'error');
            this.resetFileInput();
            return;
        }

        // Validate file size
        if (file.size > this.MAX_FILE_SIZE) {
            this.showToast('Error', 'File yang di upload tidak bisa lebih dari 25MB', 'error');
            this.resetFileInput();
            return;
        }

        // Validate category selection
        // if (!this.selectedCategory) {
        //     this.showToast('Error', 'Please select a category before uploading', 'error');
        //     this.resetFileInput();
        //     return;
        // }

        // Validate Campaign ID
        if (!this.recordId) {
            this.showToast('Error', 'Campaign ID is required', 'error');
            this.resetFileInput();
            return;
        }

        this.isLoading = true;
        const reader = new FileReader();

        reader.onload = () => {
            const fileContent = reader.result;
            try {
                // Validate row count before proceeding
                this.validateRowCount(fileContent);
                this.uploadFileToServer(fileContent);
            } catch (error) {
                this.showToast('Error', error.message, 'error');
                this.isLoading = false;
                this.resetFileInput();
            }
        };

        reader.onerror = () => {
            this.showToast('Error', 'Error reading file', 'error');
            this.isLoading = false;
            this.resetFileInput();
        };

        reader.readAsText(file);
    }

    uploadFileToServer(fileContent) {
        uploadCsvFile({ 
            csvContent: fileContent, 
            campaignId: this.recordId
        })
            .then(() => {
                this.showToast('Success', 'File uploaded successfully', 'success');
                this.isLoading = false;
                this.resetFileInput();
                // Dispatch event to notify parent component
                this.dispatchEvent(new CustomEvent('uploadcomplete'));
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                this.isLoading = false;
                this.resetFileInput();
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}