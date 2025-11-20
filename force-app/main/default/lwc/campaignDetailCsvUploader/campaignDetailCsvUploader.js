// documentUploader.js
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadCsvFile from '@salesforce/apex/SCC_CampaignDetailCsvUploaderController.uploadCsvFile';
import downloadTemplate from '@salesforce/apex/SCC_CampaignDetailCsvUploaderController.downloadTemplate';
import getCampaignDetailFieldApiNames from '@salesforce/apex/SCC_CampaignDetailCsvUploaderController.getCampaignDetailFieldApiNames';

export default class campaignDetailCsvUploader extends LightningElement {
    @api recordId;
    @track isLoading = false;
    @track selectedCategory = '';
    @track isTemplateDownloadDisabled = true;
    fieldNameMap = {};
    isFieldMapReady = false;

    connectedCallback() {
    getCampaignDetailFieldApiNames()
        .then(names => {
        this.fieldNameMap = names.reduce((acc, api) => {
            acc[api.toLowerCase()] = api; 
            return acc;
        }, {});
        this.isFieldMapReady = true;
        console.log('Field API map loaded, count:', Object.keys(this.fieldNameMap).length);
        })
        .catch(err => {
        console.error('Failed loading field API names', err);
        this.isFieldMapReady = false;
        });
    }


    MAX_FILE_SIZE = 25 * 1024 * 1024;
    MAX_ROWS = 45000;

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
        downloadTemplate({ templateName })
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
            throw new Error(`Jumlah baris melebihi ${this.MAX_ROWS.toLocaleString()}. File Anda memiliki ${dataRows.toLocaleString()} baris.`);
        }
        return true;
    }

    processFile(file) {
        if (!file.name.endsWith('.csv')) {
            this.showToast('Error', 'Please upload a valid CSV file', 'error');
            this.resetFileInput();
            return;
        }

        if (file.size > this.MAX_FILE_SIZE) {
            this.showToast('Error', 'File yang di upload tidak bisa lebih dari 25MB', 'error');
            this.resetFileInput();
            return;
        }

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
                this.validateRowCount(fileContent);
                const records = this.parseCsv(fileContent);
                this.uploadFileToServer(records);
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

    parseCsv(fileContent) {
        if (!this.isFieldMapReady || !this.fieldNameMap || !Object.keys(this.fieldNameMap).length) {
            console.warn('fieldNameMap belum siap. Aborting parse.');
            return [];
        }

        const rows = fileContent.split(/\r\n|\n/).filter(r => r.trim() !== '');
        if (!rows.length) return [];

        const headersRaw = rows[0].split(';').map(h => h.trim());

        const headerMapDebug = headersRaw.map(h => {
            let normalized = h.toLowerCase().replace(/\s+/g, '_').replace(/[^a-z0-9_]/g, '');
            if (normalized !== 'campaign__c') {
                normalized = normalized.endsWith('__c') ? normalized : normalized + '__c';
            }
            const proper = this.fieldNameMap[normalized.toLowerCase()] || null;
            return { raw: h, normalized, proper };
        });

        console.table(headerMapDebug); 

        // Hanya ambil header yang benar-benar ada di object (proper != null)
        const apiHeaders = headerMapDebug.map(x => x.proper);

        const data = [];
        for (let i = 1; i < rows.length; i++) {
            const cols = rows[i].split(';').map(c => c.trim());
            const record = {};

            apiHeaders.forEach((apiName, idx) => {
                if (!apiName || idx >= cols.length) return; 
                let value = cols[idx];
                if (!value) return;

                // Auto-convert tanggal dd/MM/yy atau dd/MM/yyyy → yyyy-MM-dd
                if (/^\d{1,2}\/\d{1,2}\/\d{2,4}$/.test(value)) {
                    const parts = value.split('/');
                    const day = parts[0].padStart(2, '0');
                    const month = parts[1].padStart(2, '0');
                    let year = parts[2];
                    if (year.length === 2) year = '20' + year;
                    value = `${year}-${month}-${day}`;
                }

                record[apiName] = value;
            });

            record['Campaign__c'] = this.recordId;

            if (Object.keys(record).length > 1) data.push(record);
        }

        console.log('Parsed Records (Cased + Date Adj):', JSON.stringify(data));
        return data;
    }

    uploadFileToServer(records) {
        uploadCsvFile({ records })
            .then(() => {
                this.showToast('Success', 'File uploaded successfully', 'success');
                this.isLoading = false;
                this.resetFileInput();
                this.dispatchEvent(new CustomEvent('uploadcomplete'));
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
                this.isLoading = false;
                this.resetFileInput();
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}