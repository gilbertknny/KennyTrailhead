import { LightningElement, track, api, wire } from 'lwc';
import getShares from '@salesforce/apex/Aswata_ApproveOffering_Controller.getShares';
import { CurrentPageReference } from 'lightning/navigation';
import approveOffering from '@salesforce/apex/Aswata_ApproveOffering_Controller.approveOffering';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class ApproveFacultativeOffering extends LightningElement {

    @api recordId; // Quote Id (auto from record page)
    @track data;
    @track error;

    @track draftValues = [];
    @track updatedFields = [];


    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text', initialWidth: 200 },
        { label: 'Co Insurer Name', fieldName: 'coInsurerName', type: 'text', initialWidth: 200 },
        { label: 'Origin Risk', fieldName: 'originRiskName', type: 'text', initialWidth: 200 }, 
        {
            label: 'Share Offered (%)',
            fieldName: 'Share_Offered__c',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: 0,
                maximumFractionDigits: 4
            },
            initialWidth: 150,
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'Share Accepted (%)',
            fieldName: 'Share_Accepted_Approved__c',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: 0,
                maximumFractionDigits: 4
            },
            editable: true,
            initialWidth: 150,
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'Rate (%)',
            fieldName: 'Rate__c',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: 0,
                maximumFractionDigits: 4
            },
            editable: true,
            initialWidth: 150,
            cellAttributes: { alignment: 'right' }
        },
        {
            label: 'Commission (%)',
            fieldName: 'Commission__c',
            type: 'number',
            typeAttributes: {
                minimumFractionDigits: 0,
                maximumFractionDigits: 4
            },
            editable: true,
            initialWidth: 150,
            cellAttributes: { alignment: 'right' }
        },
        { label: 'Subjectivity Clause', fieldName: 'Subjectivity_Clauses__c', type: 'text', editable: true, initialWidth: 500  }

        
    ];

    selectedRows = [];

    

    connectedCallback() {
        if (!this.recordId) {
            this.recordId = this.getRecordIdFromUrl();
            console.log('RecordId from URL:', this.recordId);
        }
        
        if (this.recordId) {
            console.log('Final RecordId:', this.recordId);
            this.loadShares(); // 🔥 call Apex ONLY when recordId exists
        }
    }

    getRecordIdFromUrl() {
        const path = window.location.pathname;

        // Example:
        // /lightning/r/Quote/0Q0MS000000k08H0AQ/view
        const match = path.match(/\/lightning\/r\/[^/]+\/([a-zA-Z0-9]{15,18})/);

        return match ? match[1] : null;
    }

    renderedCallback() {
        console.log('RecordId (rendered):', this.recordId);
    }

    @wire(CurrentPageReference)
    getPageRef(pageRef) {
        if (!this.recordId && pageRef?.attributes?.recordId) {
            this.recordId = pageRef.attributes.recordId;
            console.log('RecordId from Page Reference:', this.recordId);
        }
    }

    loadShares() {
        getShares({ quoteId: this.recordId })
            .then(result => {
                
                this.data = result.map(row => ({
                    ...row,
                    originRiskName: row.Origin_Risk__r?.Name,
                    coInsurerName: row.Co_Insurer_Name__r?.Name
                    //shareOfferedPercent: row.Share_Offered__c / 100,
                    //shareAcceptedPercent: row.Share_Accepted_Approved__c / 100
                }));
                console.log('Apex result:', JSON.stringify(this.data));
                this.error = undefined;
            })
            .catch(err => {
                this.error = err;
                this.data = undefined;
                console.error('Apex error:', err);
            });
    }


    handleSave(event) {
        console.log('Draft values on save:', JSON.stringify(event.detail.draftValues));
        const updatedFields = event.detail.draftValues;

        // Merge drafts into displayed data (NO DB CALL)
        this.data = this.data.map(row => {
            const draft = updatedFields.find(d => d.Id === row.Id);
            return draft ? { ...row, ...draft } : row;
        });

        // Keep draft for Approve
        this.draftValues = [];
    }
    /*
    handleApprove() {
        approveOffering({ quoteId: this.recordId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Opportunity has been closed successfully',
                        variant: 'success'
                    })
                );

                // Optional: close quick action modal
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || error.message,
                        variant: 'error'
                    })
                );
            });
    }*/

    handleApprove() {
        //console.log('Draft values on save:', JSON.stringify(this.updatedFields));
        console.log('Current data before save:', JSON.stringify(this.data));
        const payload = this.data.map(d => ({
            Id: d.Id, // must match sObject Id field
            Share_Accepted_Approved__c: Number(d.Share_Accepted_Approved__c),
            Rate__c: Number(d.Rate__c),
            Commission__c: Number(d.Commission__c),
            Subjectivity_Clauses__c: d.Subjectivity_Clauses__c || ''
        }));
        console.log('Payload for approval:', JSON.stringify(payload));

        approveOffering({
            quoteId: this.recordId,
            draftShares: payload
        })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Offering approved',
                        variant: 'success'
                    })
                );
                this.draftValues = [];
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body?.message || error.message,
                        variant: 'error'
                    })
                );
            });
    }


}