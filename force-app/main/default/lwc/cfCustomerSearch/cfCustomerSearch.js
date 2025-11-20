import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import makeCallout from '@salesforce/apex/SCC_CustomerProfileSearch.makeCallout';
import { refreshApex } from '@salesforce/apex';


export default class CustomSearchInLWC extends NavigationMixin(LightningElement) {
    @track searchData = [];
    @track errorMsg = '';
    @track idValue= '';
    @track accountNumber= '';
    @track debitCreditNumber= '';
    @track phoneNumber = '';
    @track disableAccountField = false;
    @track disableDebitCreditField = false;
    @track disableIdField = false;
    @track disablePhoneField = false;
    accountNumberError;
    cardNumberError = '';
    phoneNumberError = '';

    get formattedSearchData() {
        return this.searchData.map((record, index) => ({
            ...record,
            columnNumber: index + 1,// Start column number from 1
            phoneNumber: this.phoneNumber
        }));
    }

    get isSearchDisabled() {
        return !!this.errorMsg || !!this.accountNumberError || !!this.cardNumberError || !!this.phoneNumberError;
    }

    handleAccountName(event) {
        this.clearErrorsAndResults();
        this.accountNumber = event.target.value;
        this.debitCreditNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.validateAccountNumber();
        this.toggleFields('account');
        if (!this.accountNumber) {
            this.clearInputFields();
        }
    }

    handleDebitCreditNo(event) {
        this.clearErrorsAndResults();
        this.debitCreditNumber = event.target.value;
        this.idValue = '';
        this.phoneNumber = '';
        this.accountNumber = '';
        this.validateCardNumber();
        this.toggleFields('debitCredit');
        if (!this.debitCreditNumber) {
            this.clearInputFields();
        }
    }

    handleNIK(event) {
        this.clearErrorsAndResults();
        this.idValue = event.target.value;
        this.phoneNumber = '';
        this.accountNumber = '';
        this.debitCreditNumber = '';
        this.toggleFields('id');
        if (!this.idValue) {
            this.clearInputFields();
        }
    }

    handlePhone(event) {
        this.clearErrorsAndResults();
        this.phoneNumber = event.target.value;
        this.accountNumber = '';
        this.debitCreditNumber = '';
        this.idValue = '';
        this.validatePhoneNumber();
        this.toggleFields('phone');
        if (!this.phoneNumber) {
            this.clearInputFields();
        }
    }

    toggleFields(inputField) {
        if (inputField === 'account') {
            this.disableDebitCreditField = !!this.accountNumber;
            this.disableIdField = !!this.accountNumber;
            this.disablePhoneField = !!this.accountNumber;
        } else if (inputField === 'debitCredit') {
            this.disableAccountField = !!this.debitCreditNumber;
            this.disableIdField = !!this.debitCreditNumber;
            this.disablePhoneField = !!this.debitCreditNumber;
        } else if (inputField === 'id') {
            this.disableAccountField = !!this.idValue;
            this.disableDebitCreditField = !!this.idValue;
            this.disablePhoneField = !!this.idValue;
        } else if (inputField === 'phone') {
            this.disableAccountField = !!this.phoneNumber;
            this.disableDebitCreditField = !!this.phoneNumber;
            this.disableIdField = !!this.phoneNumber;
        }
    }

    validateAccountNumber() {
        const accountNumberRegex = /^[0-9]{15,18}$/;
        if(this.accountNumber == ''){
            this.accountNumberError = '';
        }else if (accountNumberRegex.test(this.accountNumber)) {
            this.accountNumberError = '';
        } else {
            this.accountNumberError = 'Account number must be between 15 and 18 digits numeric value.';
        }
    }

    validateCardNumber() {
        const cardNumberRegex = /^[0-9]{16}$/;
        if(this.debitCreditNumber == ''){
            this.cardNumberError = '';
        }else if (cardNumberRegex.test(this.debitCreditNumber)) {
            this.cardNumberError = '';
        } else {
            this.cardNumberError = 'Credit card number must be between 16 digits numeric value.';
        }
    }

    validatePhoneNumber() {
        const phoneNumberRegex = /^[0-9]{10,14}$/;
        if(this.phoneNumber == ''){
            this.phoneNumberError = '';
        }else if (phoneNumberRegex.test(this.phoneNumber)) {
            this.phoneNumberError = '';
        } else {
            this.phoneNumberError = 'Phone number must be between 10 and 14 digits numeric value.';
        }
    }


    handleSearch() {
        makeCallout({ 
            accountNumber: this.accountNumber,
            debitCreditNumber: this.debitCreditNumber,
            idValue: this.idValue,
            phoneNumber: this.phoneNumber
        })
        .then(result => {
            if (result && !result.errorMessage) {
                if (Array.isArray(result)) {
                    this.searchData = result;
                } else {
                    this.searchData = [result]; // Convert single record to array
                }
            } else if (result && result.errorMessage) {
                this.errorMsg = result.errorMessage;
            } else {
                this.errorMsg = 'Data tidak ditemukan';
            }
        })
        .catch(error => {
            this.error = 'Data tidak ditemukan';
        });
        
    }

    clearInputFields() {
        this.accountNumber = '';
        this.debitCreditNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.disableAccountField = false;
        this.disableDebitCreditField = false;
        this.disableIdField = false;
        this.disablePhoneField = false;
        this.searchData = [];
    }

    clearErrorsAndResults() {
        this.accountNumberError = '';
        this.cardNumberError = '';
        this.phoneNumberError = '';
        this.errorMsg = '';
        this.searchData = [];
    }

    navigateToAccountDetail(event) {
        const accountId = event.currentTarget.dataset.accountid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                actionName: 'view'
            }
        }).then(() => {
            refreshApex(this.searchData);
        });
    }
}