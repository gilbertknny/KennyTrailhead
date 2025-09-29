// lwcMaterialList.js
import { LightningElement, api, wire, track } from 'lwc';
import getMaterialsByModule from '@salesforce/apex/MaterialController.getMaterialsByModule';

export default class LwcMaterialList extends LightningElement {
    @api moduleName;
    @track materials = [];
    @track isLoading = false;
    @track error;

    get listTitle() {
        return `Materials for Module: ${this.moduleName || 'All Modules'}`;
    }

    get hasNoMaterials() {
        return !this.isLoading && this.materials.length === 0;
    }

    @wire(getMaterialsByModule, { moduleName: '$moduleName' })
    wiredMaterials({ error, data }) {
        this.isLoading = false;
        if (data) {
            this.materials = data.map(item => ({
                Id: item.material.Id,
                Name: item.material.Name,
                Description__c: item.material.Description__c,
                Module__c: item.material.Module__c,
                presenterName: item.presenterName,
                Date__c: item.material.Date__c
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.materials = [];
            console.error('Error loading materials:', error);
        }
    }

    connectedCallback() {
        this.isLoading = true;
    }

    handleViewDetail(event) {
        const materialId = event.target.dataset.id;
        this.dispatchEvent(new CustomEvent('materialselected', {
            detail: { materialId: materialId },
            bubbles: true,
            composed: true
        }));
    }
}