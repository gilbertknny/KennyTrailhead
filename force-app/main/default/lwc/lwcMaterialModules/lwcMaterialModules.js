// lwcMaterialModules.js
import { LightningElement, wire } from 'lwc';
import getModules from '@salesforce/apex/MaterialController.getModules';

export default class LwcMaterialModules extends LightningElement {
    @wire(getModules)
    modules;

    handleModuleClick(event) {
        const moduleName = event.currentTarget.dataset.name;
        console.log('Module clicked:', moduleName);
        
        this.dispatchEvent(new CustomEvent('moduleselected', {
            detail: { moduleName: moduleName },
            bubbles: true,
            composed: true
        }));
    }
}