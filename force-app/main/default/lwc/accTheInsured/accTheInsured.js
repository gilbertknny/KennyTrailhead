import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class InsuredSummary extends OmniscriptBaseMixin(LightningElement) {
    
    @track premiumAmount = '0';
    @track noOfPolicies = '0';
    @track upForRenewal = '0';
    @track hasData = false;

    // PROPERTY YANG DISET DARI OMNISCRIPT
    @api cardTitle = 'Summary'; // Judul Kartu
    @api jsonField;             // Nama Field JSON (misal: SFAWT911_The_Insured__c)

    _summarydata;

    @api
    get summarydata() {
        return this._summarydata;
    }

    set summarydata(value) {
        this._summarydata = value;
        this.formatData(value);
    }

    connectedCallback() {
        if (this._summarydata) {
            this.formatData(this._summarydata);
        }
    }

    formatData(rawValue) {
        let targetFieldData = null;
        
        // Gunakan field yang direquest, atau default ke Insured jika kosong
        const fieldToFind = this.jsonField || 'SFAWT911_The_Insured__c';
        
        console.log(`DEBUG: Mencari data untuk "${this.cardTitle}" di field: ${fieldToFind}`);

        // 1. Logika Pengambilan Data (Array vs Object)
        if (Array.isArray(rawValue) && rawValue.length > 0) {
            let firstItem = rawValue[0];
            if (firstItem && firstItem[fieldToFind]) {
                targetFieldData = firstItem[fieldToFind];
            }
        } else if (rawValue) {
            targetFieldData = rawValue[fieldToFind] || rawValue;
        }

        // 2. Parsing JSON String
        let parsedData = null;
        if (targetFieldData) {
            try {
                if (typeof targetFieldData === 'string') {
                    parsedData = JSON.parse(targetFieldData);
                } else {
                    parsedData = JSON.parse(JSON.stringify(targetFieldData));
                }
            } catch (error) {
                console.error('DEBUG: Parsing Error', error);
            }
        }

        // 3. Mapping Data
        if (parsedData && parsedData.data) {
            const dataObj = parsedData.data;

            // Format Currency
            const premiumVal = dataObj.premium_amount || 0;
            this.premiumAmount = new Intl.NumberFormat('id-ID', { 
                style: 'currency', 
                currency: 'IDR',
                minimumFractionDigits: 0
            }).format(premiumVal);

            this.noOfPolicies = dataObj.no_of_policies || '0';
            this.upForRenewal = dataObj.up_for_renewal || '0';
            this.hasData = true;
        } else {
            this.hasData = false;
            console.warn(`DEBUG: Data kosong untuk field ${fieldToFind}`);
        }
    }
}