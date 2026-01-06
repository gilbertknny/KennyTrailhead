import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'omnistudio/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';

const COLUMNS = [
    { 
        label: 'Insurance Policy', 
        fieldName: 'policy_number', 
        type: 'button', 
        typeAttributes: { 
            label: { fieldName: 'policy_number' }, 
            name: 'view_policy', 
            variant: 'base' 
        }
    },
    { 
        label: 'Premi Amount', 
        fieldName: 'displayAmount', 
        type: 'text', 
        wrapText: true 
    },
    { 
        label: 'Role', 
        fieldName: 'role', 
        type: 'text',
        wrapText: true 
    },
    { 
        label: 'Primary', 
        fieldName: 'is_primary', 
        type: 'boolean' 
    }
];

export default class RequestorRoleTable extends NavigationMixin(OmniscriptBaseMixin(LightningElement)) {
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
        let targetFieldData = null;
        let finalArray = [];
        
        let isSource911 = false; 

        if (Array.isArray(rawValue) && rawValue.length > 0) {
            let firstItem = rawValue[0];
            
            if (firstItem && firstItem.SFAWT912_Requestor__c) {
                targetFieldData = firstItem.SFAWT912_Requestor__c;
                isSource911 = false; // Bukan dari 911
            } 
            else if (firstItem && firstItem.SFAWT911_Requestor__c) {
                targetFieldData = firstItem.SFAWT911_Requestor__c;
                isSource911 = true; // Tandai data dari 911
                console.log('DEBUG: Data Source is SFAWT911 (Primary = True)');
            }
        } 
        else if (rawValue) {
            if (rawValue.SFAWT912_Requestor__c) {
                targetFieldData = rawValue.SFAWT912_Requestor__c;
            } else if (rawValue.SFAWT911_Requestor__c) {
                targetFieldData = rawValue.SFAWT911_Requestor__c;
                isSource911 = true;
            } else {
                targetFieldData = rawValue;
            }
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
                console.error('DEBUG: Error parsing Requestor JSON:', error);
            }
        }

        if (parsedObj && Array.isArray(parsedObj.data)) {
            finalArray = parsedObj.data;
        } else if (Array.isArray(parsedObj)) {
            finalArray = parsedObj;
        } 
        else if (parsedObj && typeof parsedObj === 'object') {
             finalArray = [parsedObj]; 
        }

        let flattenedData = [];

        if (Array.isArray(finalArray)) {
            finalArray.forEach((item, itemIndex) => {
                let policyNum = item.policy_number || 'NO_POLICY_NUM';
                let roleValue = item.requestor_type || 'GENERAL'; 

                let primaryValue = isSource911; 

                if (item.amounts && Array.isArray(item.amounts) && item.amounts.length > 0) {
                    item.amounts.forEach((amt, amtIndex) => {
                        const val = amt.premium_amount ? amt.premium_amount.toLocaleString('en-US') : '0';
                        
                        flattenedData.push({
                            ...item,
                            policy_number: policyNum,
                            displayAmount: `${amt.currency || ''} ${val}`,
                            role: roleValue,
                            is_primary: primaryValue, 
                            uid: `${policyNum}_${itemIndex}_${amtIndex}`
                        });
                    });
                } else {
                    flattenedData.push({
                        ...item,
                        policy_number: policyNum,
                        displayAmount: '-', 
                        role: roleValue,
                        is_primary: primaryValue, 
                        uid: `${policyNum}_${itemIndex}_0`
                    });
                }
            });
        }

        this.processedData = flattenedData;
        this.hasData = this.processedData.length > 0;
    }
}