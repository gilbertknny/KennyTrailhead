import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';

export default class ClaimSummary extends OmniscriptBaseMixin(LightningElement) {
    
    @track totalClaims = '0';
    @track openClaims = '0';
    @track totalClaimAmount = '0';
    @track totalClaimPaid = '0';
    @track hasData = false;

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

        // 1. Ambil data SFAWT913__c dari Array Acc
        if (Array.isArray(rawValue) && rawValue.length > 0) {
            let firstItem = rawValue[0];
            if (firstItem && firstItem.SFAWT913__c) {
                targetFieldData = firstItem.SFAWT913__c;
            }
        } else if (rawValue && rawValue.SFAWT913__c) {
            targetFieldData = rawValue.SFAWT913__c;
        }

        // 2. Parsing JSON String (jika string) atau Object
        let parsedData = null;
        if (targetFieldData) {
            try {
                if (typeof targetFieldData === 'string') {
                    parsedData = JSON.parse(targetFieldData);
                } else {
                    parsedData = JSON.parse(JSON.stringify(targetFieldData));
                }
            } catch (error) {
                console.error('DEBUG: Parsing Claim Summary Error', error);
            }
        }

        // 3. Mapping Data
        // JSON Source: { data: { total_claim, open_claim, total_claim_amount, total_claim_settle } }
        if (parsedData && parsedData.data) {
            const dataObj = parsedData.data;

            this.totalClaims = dataObj.total_claim || '0';
            this.openClaims = dataObj.open_claim || '0';

            // Format Currency
            const amountVal = dataObj.total_claim_amount || 0;
            this.totalClaimAmount = new Intl.NumberFormat('id-ID', { 
                style: 'currency', 
                currency: 'IDR',
                minimumFractionDigits: 0
            }).format(amountVal);

            const paidVal = dataObj.total_claim_settle || 0;
            this.totalClaimPaid = new Intl.NumberFormat('id-ID', { 
                style: 'currency', 
                currency: 'IDR',
                minimumFractionDigits: 0
            }).format(paidVal);

            this.hasData = true;
        } else {
            this.hasData = false;
        }
    }
}