import { LightningElement, track } from 'lwc';
import getModules from '@salesforce/apex/MaterialController.getModules';
import getMaterialsByModule from '@salesforce/apex/MaterialController.getMaterialsByModule';
import getMaterialDetail from '@salesforce/apex/MaterialController.getMaterialDetail';

export default class MaterialNavigator extends LightningElement {
    @track page = 'modules'; // modules | records | detail
    @track modules = [];
    @track materials = [];
    @track selectedMaterial;
    @track selectedModule;

    connectedCallback() {
        this.loadModules();
    }

    async loadModules() {
        this.modules = await getModules();
    }

    async handleModuleClick(event) {
        this.selectedModule = event.target.dataset.value;
        this.materials = await getMaterialsByModule({ moduleName: this.selectedModule });
        this.page = 'records';
    }

    async handleRecordClick(event) {
        const recordId = event.target.dataset.id;
        this.selectedMaterial = await getMaterialDetail({ recordId });
        this.page = 'detail';
    }

    handleBack() {
        if (this.page === 'detail') {
            this.page = 'records';
        } else if (this.page === 'records') {
            this.page = 'modules';
        }
    }

    get pageIsModules() { return this.page === 'modules'; }
    get pageIsRecords() { return this.page === 'records'; }
    get pageIsDetail() { return this.page === 'detail'; }
}