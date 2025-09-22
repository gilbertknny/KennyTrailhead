// lwcMaterialList.js
import { LightningElement, api, wire, track } from 'lwc';
import getMaterialsByModule from '@salesforce/apex/MaterialController.getMaterialsByModule';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
    { label: 'Description', fieldName: 'Description__c', type: 'text', sortable: true },
    { label: 'Presenter', fieldName: 'Presenter__c', type: 'text', sortable: true },
    { 
        label: 'Date', 
        fieldName: 'Date__c', 
        type: 'date', 
        sortable: true,
        typeAttributes: {
            year: 'numeric',
            month: 'short',
            day: '2-digit'
        }
    },
    {
        type: 'button',
        typeAttributes: {
            label: 'View Details',
            name: 'view',
            variant: 'neutral'
        }
    }
];

export default class LwcMaterialList extends LightningElement {
    @api moduleName;
    @track materials = [];
    @track error;
    @track isLoading = false;
    @track sortedBy = 'Date__c';
    @track sortedDirection = 'desc';

    columns = COLUMNS;

    get listTitle() {
        return `Materials for Module: ${this.moduleName || 'All Modules'}`;
    }

    @wire(getMaterialsByModule, { moduleName: '$moduleName' })
    wiredMaterials({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.materials = data;
            this.error = undefined;
            console.log('Materials loaded:', data.length);
        } else if (error) {
            this.error = error;
            this.materials = [];
            console.error('Error loading materials:', error);
        }
    }

    connectedCallback() {
        this.isLoading = true;
        console.log('MaterialsList connected with moduleName:', this.moduleName);
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        if (action.name === 'view') {
            console.log('Material selected for detail:', row.Id);
            this.dispatchEvent(new CustomEvent('materialselected', {
                detail: { materialId: row.Id },
                bubbles: true,
                composed: true
            }));
        }
    }

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
    }
}