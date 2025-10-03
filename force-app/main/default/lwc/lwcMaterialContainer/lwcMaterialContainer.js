// lwcMaterialContainer.js
import { LightningElement, track } from 'lwc';

export default class LwcMaterialContainer extends LightningElement {
    @track currentModuleName = null;
    @track currentMaterialId = null;
    @track currentPage = 'modules';

    get showModules() {
        return this.currentPage === 'modules';
    }

    get showMaterials() {
        return this.currentPage === 'materials';
    }

    get showDetail() {
        return this.currentPage === 'detail';
    }

    handleModuleSelected(event) {
        console.log('Module selected:', event.detail);
        this.currentModuleName = event.detail.moduleName;
        this.currentPage = 'materials';
        this.currentMaterialId = null;
    }

    handleMaterialSelected(event) {
        console.log('Material selected:', event.detail);
        this.currentMaterialId = event.detail.materialId;
        this.currentPage = 'detail';
    }

    handleNavigateToModules() {
        this.currentPage = 'modules';
        this.currentModuleName = null;
        this.currentMaterialId = null;
    }

    handleNavigateToMaterials() {
        this.currentPage = 'materials';
        this.currentMaterialId = null;
    }

    handleNavigateToList() {
        this.currentPage = 'materials';
        this.currentMaterialId = null;
    }
}