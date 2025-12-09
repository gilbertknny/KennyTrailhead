import { LightningElement, api, wire, track } from 'lwc';
import getRelatedRisks from '@salesforce/apex/AccumulationRiskController.getRelatedRisks';
import { NavigationMixin } from 'lightning/navigation';

const ACTIONS = [
    { label: 'Edit', name: 'edit' }
];

const COLUMNS = [
    {
        label: 'Risk Name',
        fieldName: 'riskUrl',
        type: 'url',
        typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
    },
    { label: 'Serial Number', fieldName: 'SerialNumber' },
    { label: 'Install Date', fieldName: 'InstallDate', type: 'date' },
    { label: 'Account Name', fieldName: 'AccountName' }, 
    {
        type: 'action',
        typeAttributes: { rowActions: ACTIONS } 
    }
];

export default class AccumulationRelatedRisks extends NavigationMixin(LightningElement) {
    @api recordId; 
    @track data = [];
    @track error;
    columns = COLUMNS;

    @wire(getRelatedRisks, { accumulationId: '$recordId' })
    wiredRisks({ error, data }) {
        if (data) {
            this.data = data.map(row => {
                return {
                    ...row,
                    riskUrl: `/${row.Id}`, 
                    AccountName: row.Account ? row.Account.Name : '' 
                };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.data = [];
        }
    }

    get recordCount() {
        return this.data ? this.data.length : 0;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'edit') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: 'Asset', 
                    actionName: 'edit'
                }
            });
        }
    }

    // handleNew() {
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__objectPage',
    //         attributes: {
    //             objectApiName: 'Asset',
    //             actionName: 'new'
    //         },
    //         state: {
    //         }
    //     });
    // }
}