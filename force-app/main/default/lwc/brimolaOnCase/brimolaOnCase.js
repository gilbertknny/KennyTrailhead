import { LightningElement, api, wire, track } from 'lwc';
import getDomainBrimola from '@salesforce/apex/SCC_GetDomainBrimolaOnCase.getDomainBrimola';

export default class BrimolaOnCase extends LightningElement {
    columnsInqueryTable = [
        { label: 'ID Order', fieldName: 'orderId' },
        { label: 'Jenis Pembayaran', fieldName: 'jenisPembayaran' },
        { label: 'No BRIVA', fieldName: 'noBriva' },
        { label: 'Agen', fieldName: 'agenName' },
        { label: 'Pangkalan', fieldName: 'pangkalanName' },
        { label: 'Jumlah Tabung', fieldName: 'jumlahTabung' },
        { label: 'Harga Tabung', fieldName: 'hargaTabung' },
        { label: 'Total Harga', fieldName: 'totalHarga' },
        { label: 'Biaya Admin', fieldName: 'biayaAdmin' },
        { label: 'Status Bayar', fieldName: 'statusBayar' },
        { label: 'Tanggal Order', fieldName: 'tanggalOrder' }
    ];

    parsedData;
    columnsInqueryTableData;
    error;
    errorMessage;
    @track idPangkalan = '';
    @track startDate = '';
    @track endDate = '';
    @track disableSearchButton = true;

    /*
    handleTextChange(event) {
        this.idPangkalan = event.target.value;
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }
    */

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;

        // Check if all input fields have values
        if (this.idPangkalan && this.startDate && this.endDate) {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
        }
    }

    handleSearch() {
        getDomainBrimola({ idPangkalan: this.idPangkalan, startDate: this.startDate, endDate: this.endDate })
            .then((result) => {
                if (result.errorMessage == 'No Error') {
                    this.parsedData = result;
                    this.columnsInqueryTableData = result.data;
                    this.errorMessage = '';
                } else {
                    this.errorMessage = 'Data tidak ditemukan.';
                    this.parsedData = undefined;
                }
                this.idPangkalan = '';
                this.startDate = '';
                this.endDate = '';
                this.error = undefined;
                this.disableSearchButton = true;
            })
            .catch((error) => {
                this.error = error;
                this.parsedData = undefined;
            });
    }

    get hasParsedData() {
        return this.parsedData;
    }
}