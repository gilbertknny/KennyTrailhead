import { LightningElement,api, track } from 'lwc';

export default class LwcMainCeriaCasePage extends LightningElement {
    @api recordId;
    isCeriaExpanded = false;


    handleAccordionSectionToggle(event) {
        this.isCeriaExpanded = event.detail.openSections.includes('ceria');
        if (this.isCeriaExpanded) {
            if (this.recordId) {
                console.log('recordId : ', this.recordId);
            }
        }
    }
}