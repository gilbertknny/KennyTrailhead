import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccRecord from '@salesforce/apex/SCC_AccountInformationController.getAccountData'
import updateAccountFields from '@salesforce/apex/SCC_AccountInformationController.updateAccountFields'
import makeCallout from '@salesforce/apex/SCC_CustomerProfileSearchbyPhone.initiateCalloutUsingMobileNumber';

export default class AccountInformation extends LightningElement {
    @api recordId;
    @track accountData = {};
    @track isFacebookEditing = false;
    @track isInstagramEditing = false;
    @track isXEditing = false;
    @track wiredAccountResult;
    @api editedFaceBookValue;
    @api editedInstagramValue;
    @api editedXValue;
    @api iconName;
    @api checkAgeValue = false;

    connectedCallback() {
        this.makeCalloutAndUpdateAccount();
    }

    @wire(getAccRecord, { recordId: '$recordId' })
    wiredAccount(result) {
        this.wiredAccountResult = result;
        if (result.data) {
            if(result.data.RecordType.Name=='Person Account'){
                this.iconName = 'utility:user';
            }else{
                this.iconName = 'standard:account';
            }
            if(result.data.SCC_TanggalLahir__c != undefined){
                this.checkAgeValue = true;
            }
            this.accountData = result.data;
            this.editedFaceBookValue = result.data.SCC_Facebook__c;
            this.editedInstagramValue = result.data.SCC_Instagram__c;
            this.editedXValue = result.data.SCC_X__c;
        } else if (result.error) {
            this.error = error.body.message;
        }
    }

    editFacebook() {
        this.isFacebookEditing = !this.isFacebookEditing;
    }

    editInstagram() {
        this.isInstagramEditing = !this.isInstagramEditing;
    }

    editX() {
        this.isXEditing = !this.isXEditing;
    }

    handleFacebookChange(event) {
        this.editedFaceBookValue = event.target.value;
    }

    handleInstagramChange(event) {
        this.editedInstagramValue = event.target.value;
    }

    handleXChange(event) {
        this.editedXValue = event.target.value;
    }

    saveRecord() {
        updateAccountFields({
            accountId: this.recordId,
            instagram: this.editedInstagramValue, // Corrected parameter name
            facebook: this.editedFaceBookValue,
            x: this.editedXValue
        })
        .then(() => {
            this.isFacebookEditing = false;
            this.isInstagramEditing = false;
            this.isXEditing = false;
        })
        .catch(error => {
            this.error = error.body.message;
        });
    }
    

    get isEditing() {
        return this.isFacebookEditing || this.isInstagramEditing || this.isXEditing;
    }

    cancelEdit() {
        this.isFacebookEditing = false;
        this.isInstagramEditing = false;
        this.isXEditing = false;
    }

    async makeCalloutAndUpdateAccount() {
        try {
            const calloutResult = await makeCallout({ accountId: this.recordId });
            if (calloutResult.success) {
                this.successMessage = calloutResult.message;
                await refreshApex(this.wiredAccountResult);
            } else {
                this.error = calloutResult.message;
                await refreshApex(this.wiredAccountResult);
            }
        } catch (error) {
            this.error = error.body.message;
        }
    }
}