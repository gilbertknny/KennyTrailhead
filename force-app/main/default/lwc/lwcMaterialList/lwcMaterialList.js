// lwcMaterialList.js
import { LightningElement, api, wire, track } from 'lwc';
import getMaterialsByModule from '@salesforce/apex/MaterialController.getMaterialsByModule';

export default class LwcMaterialList extends LightningElement {
    @api moduleName;
    @track materials = [];
    @track filteredMaterials = [];
    @track searchTerm = '';
    @track isLoading = false;
    @track error;

    get listTitle() {
        return `Materials for Module: ${this.moduleName || 'All Modules'}`;
    }

    get hasNoResults() {
        return !this.isLoading && this.filteredMaterials.length === 0;
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
            this.filteredMaterials = [...this.materials];
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.materials = [];
            this.filteredMaterials = [];
            console.error('Error loading materials:', error);
        }
    }

    connectedCallback() {
        this.isLoading = true;
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
        this.filterMaterials();
    }

    filterMaterials() {
        if (!this.searchTerm) {
            this.filteredMaterials = [...this.materials];
            return;
        }

        const searchLower = this.searchTerm.toLowerCase();
        this.filteredMaterials = this.materials.filter(material => 
            material.Name.toLowerCase().includes(searchLower) ||
            (material.Description__c && material.Description__c.toLowerCase().includes(searchLower)) ||
            material.presenterName.toLowerCase().includes(searchLower)
        );
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