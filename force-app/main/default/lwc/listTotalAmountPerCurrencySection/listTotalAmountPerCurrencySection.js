import { LightningElement, api, wire } from 'lwc';
import getAssetSummary from '@salesforce/apex/ListTotalAmountPerCurrency_Controller.getAssetSummary';

export default class ListTotalAmountPerCurrencySection extends LightningElement {
    @api recordId; // Risk__c Id
    summaries = [];
    error;

    @wire(getAssetSummary, { riskId: '$recordId' })
    wiredSummary({ data, error }) {
        if (data) {
            this.summaries = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summaries = [];
        }
    }

    get hasData() {
        return this.summaries && this.summaries.length > 0;
    }

    // optional: grand total
    get grandTotalIDR() {
        return this.summaries.reduce((sum, row) => sum + (row.totalAmountIDR || 0), 0);
    }

    get summariesWithKey() {
        return this.summaries.map(row => ({
            ...row,
            key: `${row.sectionId}-${row.currencyId}`
        }));
    }
}