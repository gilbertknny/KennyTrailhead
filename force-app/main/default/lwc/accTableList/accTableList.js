import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation'; // [1] IMPORT NAV MIXIN

const COLUMNS = [
    { 
        label: 'Policy Number', 
        fieldName: 'policy_number', 
        type: 'button', 
        typeAttributes: { 
            label: { fieldName: 'policy_number' }, 
            name: 'view_policy', // Action name ini yang akan kita cek nanti
            variant: 'base' 
        },
        initialWidth: 220 
    },
    { label: 'The Insured', fieldName: 'insured_name', type: 'text', wrapText: true, initialWidth: 180 },
    { label: 'Requestor', fieldName: 'requestor_name', type: 'text', wrapText: true, initialWidth: 180 },
    { label: 'Premi Amount', fieldName: 'displayAmount', type: 'text', wrapText: true, initialWidth: 180 },
    { label: 'Effective Date', fieldName: 'effective_date', type: 'date-local' },
    { label: 'Expired Date', fieldName: 'expired_date', type: 'date-local' }
];

// [2] WRAP CLASS DENGAN NavigationMixin
export default class PolicyHistoryTable extends NavigationMixin(OmniscriptBaseMixin(LightningElement)) {
    @track columns = COLUMNS;
    @track processedData = [];
    @track hasData = false;
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

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        console.log('DEBUG: Row Action Triggered', actionName);
        console.log('DEBUG: Row Data', JSON.stringify(row));

        if (actionName === 'view_policy') {
            this.navigateToOmniScript(row);
        }
    }

    navigateToOmniScript(rowData) {
        const targetOmniScript = 'c:policyAndClaim360English'; 
        
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'omnistudio__vlocityLWCOmniWrapper' 
            },
            state: {
                c__target: targetOmniScript,
                c__layout: 'lightning',
                c__tabLabel: 'Policy Detail', 
                c__ContextId: rowData.policy_number 
            }
        });
    }

    formatData(rawValue) {
        // ... (Biarkan logika formatData Anda seperti semula, tidak perlu diubah) ...
        let targetFieldData = null;
        let finalArray = [];

        if (Array.isArray(rawValue) && rawValue.length > 0) {
            let firstItem = rawValue[0];
            if (firstItem && firstItem.SFAWT912_The_Insured__c) {
                targetFieldData = firstItem.SFAWT912_The_Insured__c;
            } else if (firstItem && firstItem.SFAWT912_Requestor__c) {
                targetFieldData = firstItem.SFAWT912_Requestor__c;
            }
        } 
        else if (rawValue && (rawValue.SFAWT912_The_Insured__c || rawValue.SFAWT912_Requestor__c)) {
             targetFieldData = rawValue.SFAWT912_The_Insured__c || rawValue.SFAWT912_Requestor__c;
        }
        else {
            targetFieldData = rawValue;
        }

        let parsedObj = null;
        if (targetFieldData) {
            try {
                if (typeof targetFieldData === 'string') {
                    parsedObj = JSON.parse(targetFieldData);
                } else {
                    parsedObj = JSON.parse(JSON.stringify(targetFieldData));
                }
            } catch (error) {
                console.error('Error parsing:', error);
            }
        }

        if (parsedObj && Array.isArray(parsedObj.data)) {
            finalArray = parsedObj.data;
        } else if (Array.isArray(parsedObj)) {
            finalArray = parsedObj;
        }

        let flattenedData = [];

        if (Array.isArray(finalArray)) {
            finalArray.forEach((policy, policyIndex) => {
                if (policy.amounts && Array.isArray(policy.amounts) && policy.amounts.length > 0) {
                    policy.amounts.forEach((amt, amtIndex) => {
                        const val = amt.premium_amount ? amt.premium_amount.toLocaleString('en-US') : '0';
                        flattenedData.push({
                            ...policy, 
                            displayAmount: `${amt.currency} ${val}`, 
                            uid: `${policy.policy_number}_${policyIndex}_${amtIndex}` 
                        });
                    });
                } else {
                    flattenedData.push({
                        ...policy,
                        displayAmount: '-',
                        uid: `${policy.policy_number}_${policyIndex}_0`
                    });
                }
            });
        }

        this.processedData = flattenedData;
        this.hasData = this.processedData.length > 0;
    }
}