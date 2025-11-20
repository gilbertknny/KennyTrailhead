import { LightningElement, wire } from 'lwc';
import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_ID_FIELD from '@salesforce/schema/Case.Id';
import getCardDetails from '@salesforce/apex/SCC_CardAndDigitalLandingLWCController.getCardDetails';
import { getRecord } from 'lightning/uiRecordApi';

// Define the fields to retrieve from the Case record
const FIELDS = ['Case.Id'];

export default class MyLWC extends LightningElement {
    expandedSection = false;
    cardDetails;
    caseId;

    // Wire method to fetch the case ID dynamically
    @wire(getRecord, { recordId: '$recordId' })
    wiredCase({ error, data }) {
        if (data) {
            // Assign the Case subject to a property to use in the component
            console.log('caseId', this.recordId);
        } else if (error) {
            console.error('Error fetching Case record', error);
        }
    }

    handleExpandSection() {
        this.expandedSection = !this.expandedSection;
        if (this.expandedSection) {
            // Fetch the card details only if the section is expanded
            this.retrieveCardDetails();
        }
    }

    async retrieveCardDetails() {
        try {
            // Check if case ID is available
            if (!this.caseId) {
                console.error('Case ID not available.');
                return;
            }
            // Fetch card details using the case ID
            this.cardDetails = await getCardDetails({ caseId: this.caseId });
            console.log('Card Details:', this.cardDetails);
        } catch (error) {
            console.error('Error retrieving card details:', error);
        }
    }

    // Function to compute the status based on the cardHolder status
    getStatus(status) {
        return status === '1' ? 'Active' : 'Inactive';
    }
}