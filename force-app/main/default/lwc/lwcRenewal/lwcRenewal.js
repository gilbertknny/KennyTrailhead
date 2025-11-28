import LightningModal from 'lightning/modal';
import { track } from 'lwc';
import saveData from '@salesforce/apex/ClsRenewal.saveData';
import LightningAlert from 'lightning/alert';
import getPicklistSTD from '@salesforce/apex/ClsRenewal.getPicklist';
import getUserId from '@salesforce/apex/ClsRenewal.getUserId';

export default class LwcRenewal extends LightningModal {
    @track refPolNumberId;
    @track opportunityTypeId;
    @track isLoading;
    @track showRN;
    @track showED;
    @track statusRenewal = [];
    @track statusRenewalId;
    @track description;
    @track insuranceEndorseDate;
    @track endorseNoteChange = [];
    @track endorseNoteChangeId;
    @track endorsementDescription;
    @track filter;

    get opportunityType() {
        return [
            { label: 'Renewal', value: 'RN' },
            { label: 'Endorsement', value: 'ED' },
        ];
    }

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['Additional__c'],
    };

    matchingInfoPolicy = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
    };

    connectedCallback() {
        getUserId({})
        .then(result => {
            if(result != ''){
                this.filter = {
                    criteria: [
                        { fieldPath: 'OwnerId',operator: 'eq',value: result },
                    ],
                    filterLogic: '1'
                };
            }
        })
        .catch(error => {
            console.log('error-getUserId:'+ error.message);
        });
    }

    getPicklistStatusRenewal(){
        getPicklistSTD({
            objectName : 'InsurancePolicy',
            fieldName : 'Status_Renewal__c'
        })
        .then(result => {
            this.statusRenewal = [];
            for (var key in result) {
                this.statusRenewal.push({label:result[key], value:key});
            }
            return this.statusRenewal;
        })
        .catch(error => {
            console.log('error-getPicklistStatusRenewal:'+ error.message);
        });
    }

    getPicklistEndorseNoteChange(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Endorse_Note_Change__c'
        })
        .then(result => {
            this.endorseNoteChange = [];
            for (var key in result) {
                this.endorseNoteChange.push({label:result[key], value:key});
            }
            return this.endorseNoteChange;
        })
        .catch(error => {
            console.log('error-getPicklistStatusRenewal:'+ error.message);
        });
    }

    handleOpportunityType(e){
        this.opportunityTypeId = e.detail.value;
        this.showRN = false;
        this.showED = false;
        if(this.opportunityTypeId == 'RN') {
            this.showRN = true;
            this.getPicklistStatusRenewal();
        }else if(this.opportunityTypeId == 'ED') {
            this.showED = true;
            this.getPicklistEndorseNoteChange();
        }
        
    }

    handleRefPolNumber(e){
        this.refPolNumberId = e.detail.recordId;
    }

    handleStatusRenewal(e){
        this.statusRenewalId = e.detail.value;
    }

    handleDescription(e){
        this.description = e.detail.value;
    }

    handleInsuranceEndorseDate(e){
        this.insuranceEndorseDate = e.detail.value;
    }

    handleEndorseNoteChange(e){
        this.endorseNoteChangeId = e.detail.value;
    }

    handleEndorsementDescription(e){
        this.endorsementDescription = e.detail.value;
    }

    handleCancel(e) {
        this.close('cancel');
    }

    handleSave(e){
        console.log('save');
        if(this.opportunityTypeId === undefined || this.opportunityTypeId === ''){
            LightningAlert.open({message: 'Please Select Opportunity Type!',theme: 'error',label: 'Error!'});
        }else if(this.refPolNumberId === undefined || this.refPolNumberId === ''){
            LightningAlert.open({message: 'Please Select Policy Number!',theme: 'error',label: 'Error!'});
        }else if(this.opportunityTypeId == 'RN' && (this.statusRenewalId === undefined || this.statusRenewalId === '')){
            LightningAlert.open({message: 'Please Select Status Renewal!',theme: 'error',label: 'Error!'});
        }else if(this.opportunityTypeId == 'RN' && (this.description === undefined || this.description === '')){
            LightningAlert.open({message: 'Please Fill Description!',theme: 'error',label: 'Error!'});
        }else if(this.opportunityTypeId == 'ED' && (this.insuranceEndorseDate === undefined || this.insuranceEndorseDate === '')){
            LightningAlert.open({message: 'Please Select Insurance Endorse Date!',theme: 'error',label: 'Error!'});
        }else if(this.opportunityTypeId == 'ED' && (this.endorseNoteChangeId === undefined || this.endorseNoteChangeId === '')){
            LightningAlert.open({message: 'Please Select Endorse Note Change!',theme: 'error',label: 'Error!'});
        }else if(this.opportunityTypeId == 'ED' && (this.endorsementDescription === undefined || this.endorsementDescription === '')){
            LightningAlert.open({message: 'Please Fill Endorsement Description!',theme: 'error',label: 'Error!'});    
        }else{
            this.isLoading = true;
            let desc = null;
            if(this.opportunityTypeId == 'RN'){ desc = this.description;}
            else if(this.opportunityTypeId == 'ED'){ desc = this.endorsementDescription;}

            saveData({ 
                opptype: this.opportunityTypeId,
                refid: this.refPolNumberId,
                statusrenewalid : this.statusRenewalId,
                description : desc,
                insuranceEndorseDate : this.insuranceEndorseDate,
                endorseNoteChangeId : this.endorseNoteChangeId
            })
            .then(result => {
                this.isLoading = false;
                this.close(result);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error:'+error.body.message);
                LightningAlert.open({message: error.body.message,theme: 'error',label: 'Error!'}); 
            });
        }
    }

}