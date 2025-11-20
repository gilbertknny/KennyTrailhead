import { LightningElement,api, track, wire } from 'lwc';

export default class LwcMainWholeSaleCasePage extends LightningElement {
    @api recordId;
    isMerchantExpanded = false;


    handleAccordionSectionToggle(event) {
        this.isMerchantExpanded = event.detail.openSections.includes('merchant');
        if (this.isMerchantExpanded) {
            if (this.recordId) {
                console.log('recordId : ', this.recordId);
            }
        }
    }
}