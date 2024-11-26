import { LightningElement, api, track, wire } from 'lwc';

export default class LwcMainCreditCasePage extends LightningElement {
    @api recordId;
    isKartuKreditExpanded = false;


    handleAccordionSectionToggle(event) {
        this.isKartuKreditExpanded = event.detail.openSections.includes('kartuKredit');
        if (this.isKartuKreditExpanded) {
            if (this.recordId) {
                console.log('recordId : ', this.recordId);
            }
        }
    }
}