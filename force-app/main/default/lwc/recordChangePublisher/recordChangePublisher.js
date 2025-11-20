import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { publish, MessageContext } from 'lightning/messageService';
import RECORD_CHANGE_CHANNEL from '@salesforce/messageChannel/recordChangeNotification__c';

export default class RecordChangeMonitor extends LightningElement {
    @api recordId;
    @api objectApiName;

    @wire(MessageContext)
    messageContext;

    // Specify the fields you want to monitor
    fieldsToMonitor = ['Case.SCC_Call_Type__c', 'Case.SCC_Sub_Escalation_Level__c', 'Case.Id']; // Adjust to your needs

    @wire(getRecord, { recordId: '$recordId', fields: '$fieldsToMonitor' })
    wiredRecord({ error, data }) {
        if (data) {
            this.handleRecordChange(data);
        } else if (error) {
            console.error('Error fetching record:', error);
        }
    }

    handleRecordChange(data) {
        this.publishChangeMessage({ 
            changedField: 'CaseUpdated', 
            callType: data.fields.SCC_Call_Type__c.value, 
            subEscalationLevel: data.fields.SCC_Sub_Escalation_Level__c.value, 
            caseId: data.fields.Id.value 
        });
    }

    publishChangeMessage(payload) {
        publish(this.messageContext, RECORD_CHANGE_CHANNEL, payload);
        //console.log('Record change detected and published:', payload);
    }
}