import { LightningElement, track, wire, api } from 'lwc';
import getSubCaseReferenceFromCaseType from '@salesforce/apex/SCC_MultiPicklistController.getSubCaseReferenceFromCaseType';
import getSubCaseReferenceFromCase from '@salesforce/apex/SCC_MultiPicklistController.getSubCaseReferenceFromCase';
import saveSelectedValuesOnCase from '@salesforce/apex/SCC_MultiPicklistController.saveSelectedValuesOnCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange, getRecord } from 'lightning/uiRecordApi';
import { subscribe, MessageContext } from 'lightning/messageService';
import RECORD_CHANGE_CHANNEL from '@salesforce/messageChannel/recordChangeNotification__c';
// import { RefreshEvent } from "lightning/refresh";

export default class PicklistComponent extends LightningElement {
    @api recordId;
    @track selectedValue = '';
    @track picklistOptions = [];
    @track masterSubCase = [];
    @track error;
    @track errorMessage = '';
    @track errorCheck = false;
    @track nom = 0;
    @track currentSubCase = '';
    @track currentCaseType = '';
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$recordId', fields: ['Case.SCC_Sub_Case__c', 'Case.SCC_Call_Type__c'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.errorMessage = '';
            this.errorCheck = false;
            this.nom = this.nom + 1;

            this.fetchPicklistOptions();

            // Fetch and set the picklist options based on the record's value
            // if (this.nom > 1 && (this.currentSubCase != data.fields.SCC_Sub_Case__c.value || this.currentCaseType != data.fields.SCC_Call_Type__c.value)) {
            //     this.dispatchEvent(new RefreshEvent());
            //     window.location.reload();
            //     this.navigateToRecord(this.recordId);
            // }

            // Ambil nilai SCC_Call_Type__c dan panggil handleMessage jika nilainya berubah
            if (this.currentCaseType !== data.fields.SCC_Call_Type__c.value) {
                // Simpan nilai baru
                this.currentCaseType = data.fields.SCC_Call_Type__c.value;
                this.handleMessage({ callType: this.currentCaseType });
            }
            
            this.selectedValue = data.fields.SCC_Sub_Case__c.value;
            this.currentSubCase = data.fields.SCC_Sub_Case__c.value;
            // this.currentCaseType = data.fields.SCC_Call_Type__c.value;

        } else if (error) {
            console.error('Error fetching record:', error);
            this.error = error;
        }
    }

    connectedCallback() {
        this.subscription = subscribe(
            this.messageContext,
            RECORD_CHANGE_CHANNEL,
            (message) => this.handleMessage(message)
        );
    }   

    handleMessage(message) {
        if (message.callType) {
            this.resetPicklistOptions(); // Clear existing options
            getSubCaseReferenceFromCaseType({ recordId: message.callType })
                .then((data) => {

                    this.picklistOptions = Object.keys(data).map(key => ({
                        label: data[key],
                        value: key
                    }));
                    this.error = undefined;
                    this.errorCheck = false;

                    // this.initializePicklistOptions(data);
                })
                .catch(error => {
                    console.error('Error fetching picklist options:', error);
                    this.error = error;
                });
        }
    }

    fetchPicklistOptions() {
        this.resetPicklistOptions(); // Clear existing options
        getSubCaseReferenceFromCase({ recordId: this.recordId })
            .then((data) => {
                if (data["error"] != null) {
                    console.log(data["error"]);
                    this.errorMessage = data["error"];
                    this.errorCheck = true;
                }
                this.picklistOptions = Object.keys(data).map(key => ({
                    label: data[key],
                    value: key
                }));

                this.error = undefined;
            })
            .catch(error => {
                console.error('Error fetching picklist options:', error);
                this.errorMessage = error;
                this.errorCheck = true;
            });
    }

    initializePicklistOptions(data) {
        if (data) {
            const picklistValues = data.split(';').filter(value => value.trim() !== ''); // Filter out empty values

            this.picklistOptions = picklistValues.map(item => ({
                label: item,
                value: item
            }));
            // Optionally reset the selected value if no options are available
            if (this.picklistOptions.length === 0) {
                this.selectedValue = '';
            }
        } else {
            this.resetPicklistOptions(); // Handle no data scenario
        }
    }


    resetPicklistOptions() {
        this.picklistOptions = [];
        this.selectedValue = '';
        //  this.error='Tidak Ada Subcase di Case Type ini'
    }

    handlePicklistChange(event) {
        this.selectedValue = event.detail.value;
        console.log('tes lwc');
        console.log(this.recordId);
        console.log(this.selectedValue);
        saveSelectedValuesOnCase({ recordId: this.recordId, selectedValue: this.selectedValue })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Selected value saved successfully',
                        variant: 'success'
                    })
                );

                // Notify Salesforce that the record has been updated
                getRecordNotifyChange([{ recordId: this.recordId }]);

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving value',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }

    @track baseUri;
    navigateToRecord(recordId) {
        this.baseUri = window.location.origin;
        if (this.baseUri && recordId) {
            const recordUrl = `${this.baseUri}/lightning/r/Case/${recordId}/view`;
            window.location.href = recordUrl;
        } else {
            console.error('Base URI or recordId is invalid');
        }
    }
}