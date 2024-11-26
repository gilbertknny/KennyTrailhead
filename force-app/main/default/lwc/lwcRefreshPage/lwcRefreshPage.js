/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 11-18-2024
 * @last modified by  : Ardyta Yudianto, Alvin Vigo
**/

import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Case.SCC_Call_Type__c'];

export default class LwcRefreshPage extends LightningElement {
    @api recordId;
    @track previousFieldValue;
    @track isModalOpen = false;
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    recordHandler({ data, error }) {
        if (data) {
            const currentFieldValue = data.fields.SCC_Call_Type__c.value;

            // Pop-up cuma muncul kalo value sebelumnya ada (not null) & beda sama value sebelumnya
            if (this.previousFieldValue !== undefined && 
                this.previousFieldValue !== null && 
                this.previousFieldValue !== currentFieldValue) {
                this.isModalOpen = true;
            }

            this.previousFieldValue = currentFieldValue;
        } else if (error) {
            console.error('Error retrieving record data:', error);
        }
    }

    handleNext() {
        this.isModalOpen = false;
        this.refreshPage();
    }

    refreshPage() {
        window.location.reload();
    }
}