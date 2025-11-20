import { LightningElement, track, wire, api } from 'lwc';
import getMasterPicklist from '@salesforce/apex/Ctrl_mpCaseReason.getMasterPicklist';
import saveSelectedValues from '@salesforce/apex/Ctrl_mpCaseReason.saveSelectedValues';
import getFieldValues from '@salesforce/apex/Ctrl_mpCaseReason.getFieldValues';
import getIsClosed from '@salesforce/apex/Ctrl_mpCaseReason.getIsClosed';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import casereason from "@salesforce/label/c.Case_Reason";
import casereasonsection from "@salesforce/label/c.Case_Reason_Section";

export default class mpCaseReason extends LightningElement {
    @api recordId; // Record Id provided by the record page
    @api label;
    @track options = [];
    @track error;
    @track value = [];
    @track isSpinner = false;
    @track isClosed = false;
    @track isDisabled = false;

    clabel = {
        casereason,
        casereasonsection,
        };

    @wire(getMasterPicklist)
    wiredOptions({ error, data }) {
        if (data) {
            this.options = Object.keys(data).map(key => ({
                label: data[key],
                value: key
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.options = [];
        }
    }

    // Fetch existing field values when recordId is available
    @wire(getFieldValues, { recordId: '$recordId' })
    wiredFieldValues({ error, data }) {
        if (data) {
            this.value = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.value = [];
        }
    }

    @wire(getIsClosed, { recordId: '$recordId' })
    wiredFieldValues({ error, data }) {
        this.isClosed = false;
        this.isDisabled = true;
        if (data == false) {
            this.isClosed = true;
            this.isDisabled = false;
        } 
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    get selectedValues() {
        return this.value.join(',');
    }

    handleSave() {
        if(this.value.length == 0){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Silahkan pilih salah satu alasan.',
                    variant: 'error'
                })
            );
        }else{
            this.isSpinner = true;
            saveSelectedValues({ recordId: this.recordId, selectedValues: this.value })
            .then(result => {
                console.log('result:'+result);
                if(result=='Success'){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Data Berhasil disimpan.',
                            variant: 'success'
                        })
                    );
                    getRecordNotifyChange([{recordId: this.recordId }]);
                }else{
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: result,
                            variant: 'error'
                        })
                    );
                }
                this.isSpinner = false;
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
            
        }
    }
}