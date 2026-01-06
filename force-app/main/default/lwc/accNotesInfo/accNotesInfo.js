import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

const COLUMNS = [
    { label: 'ED.', fieldName: 'ed', type: 'text', initialWidth: 60 },
    { label: 'DOCUMENT NUMBER', fieldName: 'document_number', type: 'text' },
    { label: 'TYPE', fieldName: 'type', type: 'text', initialWidth: 100 },
    { label: 'TRN. DATE', fieldName: 'trn_date', type: 'date-local' },
    { label: 'STATUS', fieldName: 'status', type: 'text', initialWidth: 80 },
    { label: 'CURRENCY', fieldName: 'currency', type: 'text', initialWidth: 80 },
    { label: 'AMOUNT', fieldName: 'amount', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'currency' } } },
    { label: 'PAID AMOUNT', fieldName: 'paidAmount', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'currency' } } },
    { label: 'PAYMENT DATE', fieldName: 'paymentDate', type: 'date-local' },
    { label: 'PAYMENT DOC NUMBER', fieldName: 'paymentDocNumber', type: 'text' }
];

export default class AccNotesInfo extends OmniscriptBaseMixin(LightningElement) {
    @track columns = COLUMNS;
    @track processedData = [];
    
    // Variable internal
    _tabledata;

    // --- PERBAIKAN DI SINI (Gunakan huruf kecil semua: tabledata) ---
    @api
    get tabledata() {
        return this._tabledata;
    }

    set tabledata(value) {
        // Debugging akan muncul sekarang karena property name sudah cocok
        console.log('DEBUG: Masuk ke Setter tabledata'); 
        console.log('DEBUG: Value yang diterima:', JSON.stringify(value));
        
        this._tabledata = value;
        this.formatData(value);
    }
    // ---------------------------------------------------------------

    connectedCallback() {
        if (this._tabledata) {
            this.formatData(this._tabledata);
        }
    }

    formatData(rawNotes) {
        let dataToProcess = [];

        // Sanitizing Data (Handle Proxy & String)
        if (rawNotes) {
            try {
                if (typeof rawNotes === 'string') {
                    dataToProcess = JSON.parse(rawNotes);
                } else {
                    dataToProcess = JSON.parse(JSON.stringify(rawNotes));
                }
            } catch (error) {
                console.error('Error parsing data:', error);
            }
        }

        if (!Array.isArray(dataToProcess)) {
            console.warn('DEBUG: Data kosong atau bukan array');
            this.processedData = [];
            return;
        }

        // Mapping Data
        this.processedData = dataToProcess.map(note => {
            const payments = Array.isArray(note.payments) ? note.payments : [];
            const hasPayment = payments.length > 0;
            const firstPayment = hasPayment ? payments[0] : {};

            return {
                ...note,
                paidAmount: firstPayment.amount || 0,
                paymentDate: firstPayment.payment_date || null,
                paymentDocNumber: firstPayment.payment_doc_number || ''
            };
        });
    }
}