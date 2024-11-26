import { LightningElement, api, track, wire } from 'lwc';

export default class LwcMainBankingCasePage extends LightningElement {
    @api recordId;
    isCustomerPortfolioExpanded = false;


    handleAccordionSectionToggle(event) {
        this.isCustomerPortfolioExpanded = event.detail.openSections.includes('customerPortfolio');
        if (this.isCustomerPortfolioExpanded) {
            if (this.recordId) {
                console.log('recordId : ', this.recordId);
            }
        }
    }
}