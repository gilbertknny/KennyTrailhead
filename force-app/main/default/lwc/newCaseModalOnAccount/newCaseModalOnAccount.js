import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class NewCaseModalOnAccount extends NavigationMixin(LightningElement) {
    @api recordId;

    handleSuccess(event) {
        const caseId = event.detail.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: caseId,
                objectApiName: 'Case',
                actionName: 'view',
            },
        });
    }

    handleCancel() {
        // Close the quick action
        this.dispatchEvent(new CustomEvent('close'));
    }
}