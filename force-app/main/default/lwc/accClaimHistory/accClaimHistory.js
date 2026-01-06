import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

const COLUMNS = [
    { label: 'REGISTRATION NUMBER', fieldName: 'registration_number', type: 'text', initialWidth: 220 },
    { label: 'REGISTRATION DATE', fieldName: 'registration_date', type: 'date-local' },
    { label: 'DATE OFF LOSS', fieldName: 'date_off_loss', type: 'date-local' },
    { label: 'CURRENCY', fieldName: 'currency', type: 'text', initialWidth: 100 },
    { 
        label: 'LOSS EST OR CLAIM PAID', 
        fieldName: 'loss_est_orclaim_paid', 
        type: 'currency', 
        typeAttributes: { currencyCode: { fieldName: 'currency' } },
        initialWidth: 200
    },
    { label: 'STATUS', fieldName: 'status', type: 'text' }
];

export default class ClaimHistoryTable extends OmniscriptBaseMixin(LightningElement) {
    @track columns = COLUMNS;
    @track processedData = [];
    
    // Variable internal
    _tabledata;

    @api
    get tabledata() {
        return this._tabledata;
    }

    set tabledata(value) {
        this._tabledata = value;
        this.formatData(value);
    }

    connectedCallback() {
        if (this._tabledata) {
            this.formatData(this._tabledata);
        }
    }

    formatData(rawClaims) {
        let dataToProcess = [];

        // 1. Sanitizing Data (Handle Proxy & String JSON)
        if (rawClaims) {
            try {
                if (typeof rawClaims === 'string') {
                    dataToProcess = JSON.parse(rawClaims);
                } else {
                    dataToProcess = JSON.parse(JSON.stringify(rawClaims));
                }
            } catch (error) {
                console.error('Error parsing claim data:', error);
            }
        }

        // 2. Validasi Array
        if (!Array.isArray(dataToProcess)) {
            this.processedData = [];
            return;
        }

        // 3. Mapping Data (Direct mapping karena struktur flat)
        this.processedData = dataToProcess;
    }
}