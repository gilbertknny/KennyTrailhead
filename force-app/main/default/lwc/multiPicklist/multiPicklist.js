import { LightningElement, track, wire, api } from 'lwc';
import getMasterSubCaseReference from '@salesforce/apex/SCC_MultiPicklistController.getMasterSubCaseReference';
import saveSelectedValues from '@salesforce/apex/SCC_MultiPicklistController.saveSelectedValues';
import getFieldValues from '@salesforce/apex/SCC_MultiPicklistController.getFieldValues';
import getLabels from '@salesforce/apex/SCC_MultiPicklistController.getLabels';
import getUserProfile from '@salesforce/apex/SCC_MultiPicklistController.getUserProfile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class MultiPicklist extends LightningElement {
    @api recordId; // Record Id provided by the record page
    @api label;
    @track options = [];
    @track selectedValues = [];
    @track selectedValues2=[];
    @track showSelect=false;
    @track error;

    @wire(getMasterSubCaseReference)
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

    connectedCallback() {
        getUserProfile({ })
        .then((data) => {
            if(data=='System Administrator'||data=='Data Administrator')
            {
                this.showSelect=true;
                this.iconClass= 'remove-icon';
            }
            else{
                this.iconClass='slds-hidden';
            }
        })
        .catch(error => {
            console.error('Error fetching picklist options:', error);
            this.error = error;
        });
    }

    // Fetch existing field values when recordId is available
    @wire(getFieldValues, { recordId: '$recordId' })
    wiredFieldValues({ error, data }) {
        if (data) {
            this.selectedValues = data;
            this.error = undefined;
            this.getLabelFromValues();
        } else if (error) {
            this.error = error;
            this.selectedValues = [];
        }
       
    }

    handleChange(event) {
        const selectedValue = event.detail.value;
        if (!this.selectedValues.includes(selectedValue)) {
            this.selectedValues = [...this.selectedValues, selectedValue];
        }
        this.getLabelFromValues();
    }

    removeItem(event) {
        const valueToRemove = event.currentTarget.dataset.value;
        let splitString=valueToRemove.split(' || ');
        console.log(splitString[1]);
        this.selectedValues = this.selectedValues.filter(value => value !== splitString[1]);//valueToRemove);
        this.getLabelFromValues();
    }
    getLabelFromValues()
    {
        getLabels({selectedValues:this.selectedValues})
        .then((data)=>{
            console.log('data : ', data);
            this.selectedValues2=data;
            console.log('selected values 2', JSON.stringify(this.selectedValues2));
            console.log('selected value ', this.selectedValues);
            this.error=undefined;
        
        }) .catch(error => {
        this.error=error;
        this.selectedValues2=[];
        console.log(error)
        });
        
    }
    handleSave() {
        saveSelectedValues({ recordId: this.recordId, selectedValues: this.selectedValues })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sukses',
                        message: 'Data sukses disimpan',
                        variant: 'success'
                    })
                );
                getRecordNotifyChange([{recordId: this.recordId }]);
                // Optionally clear selected values or perform other actions
                //this.selectedValues = [];
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error menyimpan data',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}