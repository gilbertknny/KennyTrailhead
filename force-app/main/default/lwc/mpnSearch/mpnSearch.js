import { LightningElement, track, api} from 'lwc';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import searchBillingMPN from '@salesforce/apex/SCC_BillingMPN_Ctrl.searchBillingMPN';  
import updateCaseMPNId from '@salesforce/apex/SCC_BillingMPN_Ctrl.updateCaseMPNId';  
  
export default class MpnSearch extends LightningElement {  
    @api recordId;
    @track currency = 'IDR';  
    @track idSetoran = '';  
    @track responseData;  
    @track error;  
    @track dataExist = false;  
  
    get currencyOptions() {  
        return [  
            { label: 'IDR', value: 'IDR' },  
            // { label: 'USD', value: 'USD' },  
        ];  
    }  

    connectedCallback() {  
        console.log('Component initialized with recordId:', this.recordId);  
    } 

    handleCurrencyChange(event) {  
        this.currency = event.detail.value;  
        console.log('Currency changed to:', this.currency);  
    }  
  
    handleIdSetoranChange(event) {  
        this.idSetoran = event.detail.value;  
        console.log('Id Setoran changed to:', this.idSetoran);  
    }  
  
    get isSearchDisabled() {  
        return !this.idSetoran;  
    }  
  
    handleSearch() {  
        console.log('Searching for Id Setoran:', this.idSetoran);  
        searchBillingMPN({ idSetoran: this.idSetoran, transactionCurrencyCode: this.currency, csId: this.recordId })  
            .then(result => {  
                console.log('Apex response received:', result.responseMessage);  
                console.log('Response Message:', result.responseMessage);  
                if (result && result.Data) {  
                    this.responseData = result.Data;
                    this.dataExist = true;  
                    this.error = undefined;  
  
                    // Update field MPN_ID__c dan scc_Billing_Number__c pada record Case  
                    this.updateCaseMPNId(this.recordId, this.responseData.kodeNTPN, this.responseData.idSetoran);  
                } else {  
                    // Data tidak ditemukan, tetapi tetap update scc_Billing_Number__c dengan nilai input user
                    // this.error = 'Data yang Anda cari tidak ditemukan';
                    if(result.responseMessage){
                        this.error = 'Data yang Anda cari tidak ditemukan / ' + result.responseMessage;
                    }
                    else{
                        this.error = 'Data yang Anda cari tidak ditemukan';
                    }
                    this.responseData = undefined;  
                    this.dataExist = false;
                    
                    // Update hanya scc_Billing_Number__c, kirim null untuk mpnId
                    this.updateCaseMPNId(this.recordId, null, this.idSetoran);
                    this.showToast('Info', 'Data tidak ditemukan. Billing Number telah disimpan.', 'info');
                }  
            })  
            .catch(error => {  
                console.error('Error received from Apex:', error);  
                this.error = error.body.message;  
                this.responseData = undefined;  
                this.dataExist = false;  
            });  
    }  
  
    handleClose() {  
        this.dataExist = false;  
        this.responseData = undefined;  
        this.error = undefined;  
        console.log('Search results cleared.');  
    }  
  
    updateCaseMPNId(caseId, mpnId, billingNumber) {  
        updateCaseMPNId({ caseId: caseId, mpnId: mpnId, billingNumber: billingNumber })  
            .then(() => {  
                console.log('Case updated successfully');
                if (mpnId) {
                    this.showToast('Success', 'MPN ID dan Billing Number berhasil diupdate', 'success');
                }
                
                // Refresh only the record data
                getRecordNotifyChange([{recordId: this.recordId}]);
            })  
            .catch(error => {  
                console.error('Error updating Case:', error);  
                this.showToast('Error', 'Gagal mengupdate data Case', 'error');  
            });  
    }  
  
    showToast(title, message, variant) {  
        const event = new ShowToastEvent({  
            title: title,  
            message: message,  
            variant: variant  
        });  
        this.dispatchEvent(event);  
    }  
}