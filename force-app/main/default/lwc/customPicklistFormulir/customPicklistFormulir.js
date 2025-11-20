import { LightningElement, track, wire, api } from 'lwc';
import getMasterPicklist from '@salesforce/apex/Ctrl_picklistFormulir.getMasterPicklist';
import saveSelectedValues from '@salesforce/apex/Ctrl_picklistFormulir.saveSelectedValues';
import getFieldValues from '@salesforce/apex/Ctrl_picklistFormulir.getFieldValues';
import getCase from '@salesforce/apex/Ctrl_picklistFormulir.getCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import LightningConfirm from 'lightning/confirm';
import { getRecord } from 'lightning/uiRecordApi';

export default class CustomPicklistFormulir extends LightningElement {
    @api recordId; // Record Id provided by the record page
    @api label;
    @track options = [];
    @track error = '';
    @track selectedValue = '';
    @track isSpinner = false;
    @track isClosed = false;
    @track isDisabled = false;
    @track errorCheck = false;
    @track description = '';
    @track calltype;
    FIELDS = ['Case.SCC_Call_Type__c'];

    @wire(getRecord, { recordId: '$recordId', fields: '$FIELDS' })
    wiredRecord({ error, data }) {
        if (error) {
            console.error('error:'+error);
        } else if (data) {
           this.calltype = data.fields.SCC_Call_Type__c.value;
           this.fetchPicklistOptions();
        }
    }

    fetchPicklistOptions() {
        console.log('picklist formulir');
        console.log('calltype:'+this.calltype);
        getMasterPicklist({ recordId: this.recordId , idCallType : this.calltype})
            .then((data) => {
                this.options = Object.keys(data).map(key => ({
                    label: data[key],
                    value: key
                }));
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error fetching picklist options:', error);
                this.error = error;
                this.options = [];
            });
    }

    // Fetch existing field values when recordId is available
    @wire(getFieldValues, { recordId: '$recordId' })
    wiredFieldValues({ error, data }) {
        console.log('picklist-data:'+data);
        if (data) {
            this.selectedValue = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.selectedValue = '';
        }
    }

    @wire(getCase, { recordId: '$recordId' })
    wiredCase({ error, data }) {
        this.isClosed = false;
        this.isDisabled = false;
        if (data) {
            this.description = data.Description;
            if(data.isClosed == true){
                this.isClosed = true;
                this.isDisabled = true;
            }
        } 
    }

    async handleChange(event) {
        const result = await LightningConfirm.open({
            message: 'Detail Informasi yang sebelumnya akan hilang dan digantikan template baru.',
            variant: 'header',
            label: 'Halaman Konfirmasi',
            theme: 'info',
        });
        console.log('result:'+result);

        if(result == true){
            this.selectedValue = event.detail.value;
            console.log('recordId:'+this.recordId);
            console.log('selectedValue:'+this.selectedValue);
            this.isSpinner = true;
            saveSelectedValues({ recordId: this.recordId, selectedValue: this.selectedValue })
            .then(result => {
                console.log('result:'+JSON.stringify(result));
                this.isSpinner = false;
                if(result.message=='Success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Data Berhasil disimpan.',
                            variant: 'success'
                        })
                    );
                    getRecordNotifyChange([{recordId: this.recordId }]);
                    this.description = result.Description;

                    // Force a refresh of the record data after notification
                    refreshApex(this.description); // Trigger UI refresh
                    
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result.message,
                            variant: 'error'
                        })
                    );
                }
                
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: JSON.stringify(error),
                        variant: 'error'
                    })
                );
                this.isSpinner = false;
                console.log('error:'+JSON.stringify(error));
            });
        }else{
            const startSelect = this.template.querySelector('.start-select');
            if (startSelect) {
                startSelect.value = this.selectedValue;
            }
        }
    }
}