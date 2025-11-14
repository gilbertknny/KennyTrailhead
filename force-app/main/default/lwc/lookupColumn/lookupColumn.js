import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import LWCDatatablePicklist from '@salesforce/resourceUrl/LWCDatatablePicklist';
import { getRecord } from "lightning/uiRecordApi";
 
export default class LookupColumn extends LightningElement {
    @api value;
    @api fieldName;
    @api object;
    @api context;
    @api name;
    @api fields;
    @api target;
    @api user;
    @api newuserid;
    @track showLookup = false;
    @track filter = {};
    @track record;
 
    //get the sobject record info with fields to show as url navigation text
    @wire(getRecord, { recordId: '$value', fields: '$fields' })
    wiredRecord({error,data}){
        if(data) {
            //console.log('value:'+this.value);
            //console.log('fields:'+this.fields);
            this.record = data;   
            //console.log('this.record:'+JSON.stringify(this.record));   
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['Additional__c'],
    };

    matchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
        additionalFields: [{ fieldPath: 'Email' }],
    };
 
    getFieldName() {
        let fieldName = this.fields[0];
        fieldName = fieldName.substring(fieldName.lastIndexOf('.') + 1, fieldName.length);
        return fieldName;
    }
 
   //label of formatted url
    get lookupName() {
        //console.log('lookup:'+JSON.stringify(this.record.data));
        return (this.value != undefined && this.value != '' && this.record != null) ?  this.record.fields[this.getFieldName()].value : '';
    }
 
    //value of formatted url
    get lookupValue() {
        return (this.value != undefined && this.value != '' && this.record != null && this.record.fields[this.getFieldName()].value) ? '/' + this.value : '';
    }

    connectedCallback() {
        //if(this.newuserid != undefined) this.value = this.newuserid;
    }
 
    renderedCallback() {
        Promise.all([
            loadStyle(this, LWCDatatablePicklist),
        ]).then(() => { });
 
        let container = this.template.querySelector('div.container');
        container?.focus();
 
        window.addEventListener('click', (evt) => {
           if(container == undefined){
               this.showLookup = false;
           }
        });

        //console.log('user:'+JSON.stringify(this.user));
        //console.log('newuserid:'+this.newuserid);
    }
 
    /*closeLookup(event) {
        if (!event.currentTarget.contains(event.relatedTarget)) {
            this.showLookup = false;
        }
    }*/
 
    handleChange(event) {
        //show the selected value on UI
        this.value = event.detail.recordId;
        if(this.value == undefined){
            this.record = null;
        }
        //fire event to send context and selected value to the data table
        this.dispatchEvent(new CustomEvent('lookupchanged', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {
                data: { context: this.context, value: this.value }
            }
        }));
    }
 
    handleClick(event) {
        //wait to close all other lookup edit 
        setTimeout(() => {
            this.showLookup = true;
            if(this.user != undefined && this.showLookup == true){
                this.filter = {
                    criteria : [
                        {
                            fieldPath : 'IsActive',
                            operator : 'eq',
                            value : true
                        },
                        {
                            fieldPath : 'Branch__c',
                            operator : 'eq',
                            value : this.user.Branch__c 
                        },
                        {
                            fieldPath : 'UserLicense__c',
                            operator : 'eq',
                            value : 'Salesforce'
                        }
                    ],
                    filterLogic: '1 AND 2 AND 3', 
                    orderBy: [{fieldPath: 'Name', direction: 'asc'}]
                };
            }
        }, 100);
    }
}