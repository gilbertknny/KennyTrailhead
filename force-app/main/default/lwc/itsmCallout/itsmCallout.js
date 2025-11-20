import { LightningElement, track } from 'lwc';
import makeCallout from '@salesforce/apex/SCC_ITSMCalloutController.makeCallout';

export default class SCC_ITSMCalloutController extends LightningElement {
    @track caseId = '';
    @track response;

    handleCaseIdChange(event) {
        this.caseId = event.target.value;
    }

    handleCallout() {
        makeCallout({ caseId: this.caseId })
            .then(result => {
                this.response = result;
            })
            .catch(error => {
                this.response = `Error: ${error.body.message}`;
            });
    }
}