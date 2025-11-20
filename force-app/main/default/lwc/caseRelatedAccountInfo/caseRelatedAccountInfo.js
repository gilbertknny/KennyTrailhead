// CaseRelatedAccountInfo.js
import { LightningElement, wire, api, track } from 'lwc';
import getCaseAssociatedAccount from '@salesforce/apex/CaseRelatedAccountInfoController.getCaseAssociatedAccount';


export default class CaseRelatedAccountInfo extends LightningElement {
    @api recordId;
    @api checkAgeValue;
    @api iconName;
    @api accountName;
    @api age;

    @wire(getCaseAssociatedAccount, { recordId: '$recordId'})
    caseAssociatedAccount(result){
        if (result.data) {
            this.accountName = result.data.Account.Name;
            if(result.data.Account.RecordType.Name=='Person Account'){
                this.iconName = 'utility:user';
            }else{
                this.iconName = 'standard:account';
            }

            if(result.data.Account.SCC_TanggalLahir__c != undefined){
                this.age = result.data.Account.SCC_TanggalLahir__c;
                this.checkAgeValue = true;
            }
            //this.makeCalloutAndUpdateAccount();
        } else if (result.error) {
            console.error('Error:', result.error);
        }
    }    
}