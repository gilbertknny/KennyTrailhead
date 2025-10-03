// lwcMaterialNavigator.js
import { LightningElement, api } from 'lwc';

export default class LwcMaterialNavigator extends LightningElement {
    @api moduleName;
    @api materialId;
    @api currentPage;

    get showBackToModules() {
        return this.currentPage === 'materials' || this.currentPage === 'detail';
    }

    get showBackToMaterials() {
        return this.currentPage === 'detail' && this.moduleName;
    }

    get showBackToList() {
        return this.currentPage === 'detail';
    }

    navigateToModules() {
        this.dispatchEvent(new CustomEvent('navigatetomodules'));
    }

    navigateToMaterials() {
        this.dispatchEvent(new CustomEvent('navigatetomaterials', {
            detail: { moduleName: this.moduleName }
        }));
    }

    navigateToList() {
        this.dispatchEvent(new CustomEvent('navigatetolist', {
            detail: { moduleName: this.moduleName }
        }));
    }
}