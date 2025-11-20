import { LightningElement, track } from 'lwc';
import fetchDataFromAPI from '@salesforce/apex/SSC_FetchCustomerProfileInformation.fetchDataFromAPI';

const columns = [
    { label: 'Nama', fieldName: 'Nama', type: 'text' }
    // Add more columns as needed
];

export default class CustomerProfileSearch extends LightningElement {
    @track accountNumber = '';
    @track creditCardNumber = '';
    @track nikNumber = '';
    @track phoneNumber = '';
    @track data;
    accountNumberError;
    cardNumberError = '';
    phoneNumberError = '';
    @track disableAccountField = false;
    @track disableDebitCreditField = false;
    @track disableIdField = false;
    @track disablePhoneField = false;


    handleInputChange(event) {
        const fieldName = event.target.label.toLowerCase().replace(' ', '');
        const fieldValue = event.target.value;
        if (fieldName == 'nomorrekening') {
            this.accountNumber = fieldValue;
            this.validateAccountNumber();
        } else if (fieldName == 'nomorkartu kredit / kartu debit') {
            this.creditCardNumber = fieldValue;
            this.validateCardNumber();
        } else if (fieldName == 'nomorid') {
            this.nikNumber = fieldValue;
        } else if (fieldName == 'nomorhandphone') {
            this.phoneNumber = fieldValue;
            this.validatePhoneNumber();
        }
    }

    validateAccountNumber() {
        const accountNumberRegex = /^[0-9]{16}$/;
        if(this.accountNumber == ''){
            this.accountNumberError = '';
        }else if (accountNumberRegex.test(this.accountNumber)) {
            this.accountNumberError = '';
        } else {
            this.accountNumberError = 'Nomor rekening harus terdiri dari 16 digit angka.';
        }
    }

    validateCardNumber() {
        const cardNumberRegex = /^[0-9]{16}$/;
        if(this.creditCardNumber == ''){
            this.cardNumberError = '';
        }else if (cardNumberRegex.test(this.creditCardNumber)) {
            this.cardNumberError = '';
        } else {
            this.cardNumberError = 'Nomor kartu kredit harus terdiri dari 16 digit angka.';
        }
    }

    validatePhoneNumber() {
        const phoneNumberRegex = /^[0-9]{14,16}$/;
        if(this.phoneNumber == ''){
            this.phoneNumberError = '';
        }else if (phoneNumberRegex.test(this.phoneNumber)) {
            this.phoneNumberError = '';
        } else {
            this.phoneNumberError = 'Nomor telepon harus terdiri dari 14 hingga 16 digit angka.';
        }
    }

    handleSearch() {
        // Call Apex method to search SPI
        fetchDataFromAPI({
            accountNumber: this.accountNumber,
            creditCardNumber: this.creditCardNumber,
            nikNumber: this.nikNumber,
            phoneNumber: this.phoneNumber
        })
            .then(result => {
                this.data = result.namaSesuaiIdentitas;
            })
            .catch(error => {
                // Handle error
                console.error('Error fetching SPI data: ', error);
            });
    }

    get columns() {
        return columns;
    }
}