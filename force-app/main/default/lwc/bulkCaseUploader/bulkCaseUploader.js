import { LightningElement } from 'lwc';
import uploadCases from '@salesforce/apex/BulkCaseUploaderController.uploadCases';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class BulkCaseUploader extends LightningElement {
    fileFormat = 'csv';
    fileContents = '';
    parsedData = [];
    showReminder = false;
    showTable = false;

    fileFormatOptions = [
        { label: 'CSV', value: 'csv' }
    ];

    columns = [
        { label: 'Subject', fieldName: 'Subject' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Priority', fieldName: 'Priority' }
    ];

    handleFormatChange(event) {
        this.fileFormat = event.detail.value;
    }

    handleFileChange(event) {
        const file = event.target.files[0];
        if (!file) {
            this.showToast('Error', 'File tidak ditemukan.', 'error');
            return;
        }

        const reader = new FileReader();
        reader.onload = () => {
            const content = reader.result;
            console.log('File content loaded:', content);
            this.fileContents = content;
        };
        reader.onerror = (e) => {
            console.error('FileReader error:', e);
            this.showToast('Error', 'Gagal membaca file.', 'error');
        };
        reader.readAsText(file);
    }

    handleParse() {
        if (!this.fileContents) {
            this.showToast('Error', 'Isi file kosong atau belum diupload.', 'error');
            return;
        }

        try {
            this.parsedData = [];

            const lines = this.fileContents.split('\n');
            const headers = lines[0].split(',').map(h => h.trim());

            const requiredColumns = ['Subject', 'Status', 'Priority'];
            const missingColumns = requiredColumns.filter(col => !headers.includes(col));
            if (missingColumns.length > 0) {
                this.showToast('Error', `Kolom wajib hilang: ${missingColumns.join(', ')}`, 'error');
                return;
            }

            for (let i = 1; i < lines.length; i++) {
                const row = lines[i].split(',');
                if (row.length !== headers.length) continue;
                const obj = {};
                headers.forEach((h, j) => {
                    obj[h] = row[j]?.trim();
                });
                this.parsedData.push(obj);
            }

            if (this.parsedData.length === 0) {
                this.showToast('Error', 'Tidak ada data yang valid ditemukan di file.', 'error');
                return;
            }

            this.showReminder = true;
            this.showTable = true;

        } catch (e) {
            this.showToast('Error', 'Terjadi kesalahan saat memproses file.', 'error');
            console.error(e);
        }
    }

    handleUpload() {
        uploadCases({ caseData: JSON.stringify(this.parsedData) })
            .then(() => {
                this.showToast('Sukses', 'Data berhasil diunggah ke Case.', 'success');
                this.parsedData = [];
                this.showTable = false;
                this.showReminder = false;
            })
            .catch(error => {
                this.showToast('Gagal Upload', error.body?.message || 'Terjadi kesalahan saat upload.', 'error');
                console.error('Upload error:', error);
            });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}