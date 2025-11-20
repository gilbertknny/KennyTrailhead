/**
    LWC Name    : lwcBlokirKartuHandler.html
    Created Date       : 17 September 2024
    @description       : This is Component to handle Blokir Kartu BL
    @author            : Suherbing Septian
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   17/09/2024   Suherbing Septian                 Initial Version
**/

// lwcBlokirKartuHandler.js
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendBlokirBL from '@salesforce/apex/SCC_HttpReq_BlokirBL.sendBlokir';
import sendBlokirPL from '@salesforce/apex/SCC_HttpReq_BlokirPL.sendBlokir';
import getUserPermissionSets from '@salesforce/apex/SCC_BlokirKartu.getUserPermissionSets';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = [
    'Case.SCC_Call_Type__r.Name'
];

export default class LwcBlokirKartuHandler extends LightningElement {
    @track isModalOpen = false;
    @api cardNumber;
    @api terminalId;
    @api isBlokir;
    @api userMaintain;
    @api cardStatus;
    @track caseData;
    channelID = 'CHM';
    Password = 'CHMp@55180924';
    Action = 'CardPL';

    @track blokirKartu = '';
    @api recordId; // The Case record Id (passed in when using the component in record pages)

    // caseData; // Holds the case data

    permissionSets = [];
    error;

    @wire(getUserPermissionSets)
    wiredPermissionSets({ error, data }) {
        if (data) {
            this.permissionSets = data;
            this.error = undefined;
            console.log('permission set 1 :',this.permissionSets = data);
        } else if (error) {
            this.error = error;
            this.permissionSets = undefined;
            console.log('permission set 2 :',this.permissionSets = data);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.caseData = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.caseData = undefined;
        }
    }

    get isDisable() {
        if (this.permissionSets.length == 0) {
            console.log('disable 1');
            return true; // Disable if permission set is empty
        }

        if (!this.caseData || !this.caseData.fields || !this.caseData.fields.SCC_Call_Type__r) {
            console.log('Case data not loaded yet');
            return true; // Disable if case data is not loaded yet
        }

        const caseType = this.caseData.fields.SCC_Call_Type__r.value?.fields?.Name?.value;
        console.log('Case type:', caseType);

        if (this.isBlokir == 'PL') {
            console.log('disable 3');
            return !((this.cardStatus == 'AA' || 
            this.cardStatus == 'NA' || 
            this.cardStatus == 'DS' || 
            this.cardStatus == 'PS') && (this.userMaintain != '' || this.userMaintain != null) && this.permissionSets.includes('CC Agent Leader') && caseType == '8704');
        } else {
            console.log('disable 2');
            console.log('user PN :',this.terminalId);
            return !((this.cardStatus == 'AA' || 
            this.cardStatus == 'NA' || 
            this.cardStatus == 'DS' || 
            this.cardStatus == 'PS' || 
            this.cardStatus == 'TL' || 
            this.cardStatus == 'CL') && this.terminalId != null && caseType == '8405' && (this.permissionSets.includes('CC Agent Leader') || this.permissionSets.includes('SCC_CC_Maker') || this.permissionSets.includes('CC Maker')));
        }
    }

    connectedCallback(){
        console.log('asd cardNumber from parent:', this.cardNumber);
        console.log('asd terminalId from parent:', this.terminalId);
        console.log('asd isBlokir :', this.isBlokir);
        console.log('asd userMaintain :', this.userMaintain);
        console.log('asd cardStatus :', this.cardStatus);
        console.log('asd channelID :', this.channelID);
        console.log('asd Password :', this.Password);
        console.log('asd Action :', this.Action);
        console.log('asd recordId :', this.recordId);
        if (this.isBlokir == 'PL'){
            console.log('button PL');
            this.blokirKartu = 'Blokir Kartu PL';
        }else{
            console.log('button BL');
            this.blokirKartu = 'Blokir Kartu BL';
        }
    }

    handleBlokir() {
        console.log('munculkan modal..');
        this.isModalOpen = true;
        console.log('Modal state:', this.isModalOpen);
    }

    handleBlokirSuccess(event) {
        const { cardNumber, newStatus, newStatusDescription } = event.detail;
        this.cardInfo.cardStatus = newStatus;
        this.cardInfo.ketStatusKartu = newStatusDescription;
    }

    handleBlokirError(event) {
        console.error('Error blocking card:', event.detail.error);
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleConfirmationBlock() {
        console.log('Called Handle blokir');
        this.isModalOpen = false;
        if (this.isBlokir == 'PL'){
            console.log('Blokir PL');
            this.sendBlokirPLRequest();
        }else{
            console.log('Blokir BL');
            this.sendBlokirBLRequest();
        }
    }

    sendBlokirBLRequest() {
        console.log('Run Send Blokir BL Request');
        console.log('cardNumber: ' + this.cardNumber);
        console.log('terminalId: ' + this.terminalId);
        console.log('channelID: ' + this.channelID);
        sendBlokirBL({ cardNumber: this.cardNumber, terminalId: this.terminalId })
            .then(() => {
                this.showToast('Success', 'Data kartu BL sudah diblokir', 'success');
                this.dispatchEvent(new CustomEvent('blokirsuccess', {
                    detail: { 
                        cardNumber: this.cardNumber,
                        newStatus: 'BL',
                        newStatusDescription: 'Kartu Diblokir'
                    }
                }));
            })
            .catch(error => {
                this.showToast('Error', 'Gagal memblokir kartu BL: ' + (error.body.message || error.message), 'error');
                this.dispatchEvent(new CustomEvent('blokirerror', {
                    detail: { error: error.body.message || error.message }
                }));
            });
    }

    sendBlokirPLRequest() {
        console.log('Run Send Blokir PL Request');
        console.log('User Maintain :',this.userMaintain);
        sendBlokirPL({ ChannelID : this.channelID, Password : this.Password, Action : this.Action, CardNo: this.cardNumber, UserMaintain: this.userMaintain })
            .then(() => {
                this.showToast('Success', 'Data kartu PL sudah diblokir', 'success');
                this.dispatchEvent(new CustomEvent('blokirsuccess', {
                    detail: { 
                        cardNumber: this.cardNumber,
                        newStatus: 'PL',
                        newStatusDescription: 'Kartu Diblokir'
                    }
                }));
            })
            .catch(error => {
                this.showToast('Error', 'Gagal memblokir kartu PL: ' + (error.body.message || error.message), 'error');
                this.dispatchEvent(new CustomEvent('blokirerror', {
                    detail: { error: error.body.message || error.message }
                }));
            });
    }
}