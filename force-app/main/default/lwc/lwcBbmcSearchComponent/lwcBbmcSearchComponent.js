/** 
    LWC Name    : lwcBbmcSearchComponent.js
    Created Date       : 07 Januari 2025
    @description       : This is class for logic BBMC
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    Release 3
    1.0   07/01/2025   Rakeyan Nuramria                  Initial Version
    1.0   20/01/2025   Rakeyan Nuramria                  Add functionality to call API
    1.0   04/02/2025   Rakeyan Nuramria                  Add validation for input
    1.0   03/03/2025   Rakeyan Nuramria                  Add masking field username & hp based on feedback UAT
**/

import { LightningElement, api, wire, track } from 'lwc';
import getBCCM from '@salesforce/apex/SCC_CaseBRICare.getBCCM';

export default class LwcBbmcSearchComponent extends LightningElement {
    @api caseId;

    @track nomorKartu = '';
    @track username = '';
    @track nomorHp = '';
    @track data = [];

    @track disableSearchButton = true;
    @track disableNomorKartuField = false;
    @track disableUsernameField = false;
    @track disableNomorHandphoneField = false;

    @track isLoading = false;
    @track hasError = false;
    error;
    errorMsg;
    nomorKartuError;
    nomorHpError;
    @track hasSearched = false;  // To control the visibility of the result card


    get isSearchDisabled() {
        return!!this.errorMsg || 
                !!this.nomorKartuError ||
                !!this.nomorHpError
                    || 
                        !(this.nomorKartu||this.nomorHp);
    }

    disableFields(disable) {
        this.disableNomorKartuField = disable;
        this.disableNomorHandphoneField = disable;
    }


    // Input Change Handlers
    handleNomorKartuChange(event){
        this.nomorKartu = event.target.value.trim();
        this.toggleFields('nomorKartu');
        this.validateCardNumber();
        this.handleInputChange();
    }

    handleUsernameChange(event){
        this.username = event.target.value.trim();
        this.toggleFields('username');
        this.handleInputChange();
    }

    handleNomorHandphoneChange(event){
        this.nomorHp = event.target.value.trim();
        this.toggleFields('nomorHp');
        this.validatePhoneNumber();
        this.handleInputChange();
    }

    handleInputChange(){
        // Check if all input fields have values & doesnt error
        if ((this.nomorKartu || this.username || this.nomorHp) && !this.nomorKartuError && !this.nomorHpError) {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
            // this.handleClose();
        }
    }

    validateCardNumber() {
        if (this.nomorKartu) {
            const regex = /^\d{16}$/; // Regex for exactly 16 digits
            if (!regex.test(this.nomorKartu)) {
                this.nomorKartuError = 'Nomor Kartu harus memiliki 16 digit angka.';
            } else {
                this.nomorKartuError = '';
            }
        } else {
            this.nomorKartuError = ''; 
        }
    }

    validatePhoneNumber() {
        if (this.nomorHp) {
            const regex = /^\d{10,14}$/; // Regex for 10-14 digits
            if (!regex.test(this.nomorHp)) {
                this.nomorHpError = 'Nomor Handphone harus memiliki 10-14 digit angka.';
            } else {
                this.nomorHpError = '';
            }
        } else {
            this.nomorHpError = ''; 
        }
    }

    toggleFields(inputField) {
        if (inputField === 'nomorKartu') {
            this.disableUsernameField = !!this.nomorKartu;
            this.disableNomorHandphoneField = !!this.nomorKartu;
        } else if (inputField === 'username') {
            this.disableNomorKartuField = !!this.username;
            this.disableNomorHandphoneField = !!this.username;
        } else if (inputField === 'nomorHp'){
            this.disableNomorKartuField = !!this.nomorHp;
            this.disableUsernameField = !!this.nomorHp;
        }
    }

    // Search Handler
    handleSearch(){
        this.hasSearched = true;  // Set hasSearched to true to show the result card
        this.fetchDataBBMC();
    }

    /*
    // Simulate fetching data from an API
    fetchDataBBMC(){
        this.clearData();

        console.log('Function fetchDataBBMC called..');

        this.isLoading = true;
        this.hasError = false;

        // Prepare the request payload
        const requestPayload = {
            nomorKartu: this.nomorKartu,
            username: this.username,
            nomorHp: this.nomorHp
        };

        // Simulating an asynchronous API call
        setTimeout(() => {
            try {
                const response = {
                    USER_ACCESS: [
                        {
                            userName: 'roy01',
                            securityQuestion: 'kucing',
                            nomorKartuCC: '5475820107245108',
                            nomorHandphone: '089611715088',
                            tanggalRegistrasi: '2022-03-22 10:40:41'
                        },
                        {
                            userName: 'roy02',
                            securityQuestion: 'trex',
                            nomorKartuCC: '5475820107245109',
                            nomorHandphone: '089611715089',
                            tanggalRegistrasi: '2022-03-23 11:45:22'
                        }
                    ]
                };

                // Store the result in the data array
                this.data = response.USER_ACCESS;
                this.isLoading = false;
                console.log('Data fetched successfully:', this.data);

            } catch (error) {
                this.isLoading = false;
                this.hasError = true; 
                this.errorMsg = 'Failed to fetch data';
                console.error('Error fetching data:', error);
            }
        }, 2000);  // Simulate a 2-second delay for the API call
    }
    */

    fetchDataBBMC(){
        this.clearData();
    
        console.log('Calling getBCCM Apex method...');
    
        this.isLoading = true;
        this.hasError = false;
    
        // Prepare the request payload
        const requestPayload = {
            cardNumber: this.nomorKartu,
            userName: this.username,
            phoneNumber: this.nomorHp
        };

        const recId = this.caseId;

        console.log('Request payload with recId:', JSON.stringify({ req: requestPayload, recid: recId }));
        // Call the Apex method
        getBCCM({ req: requestPayload, recid : recId})
            .then((response) => {
                // Check if the response contains USER_ACCESS data
                if (response && response.USER_ACCESS && response.USER_ACCESS.length > 0) {
                    // If data exists, process it
                    this.data = response.USER_ACCESS.map(item => ({
                        userName: this.censorUsername(item.userName),
                        securityQuestion: item.securityQuestion || 'N/A',
                        nomorKartuCC: this.formatCardNumber(item.nomorKartuCC) || 'N/A',
                        nomorHandphone: this.censorPhone(item.nomorHandphone),
                        tanggalRegistrasi: item.tanggalRegistrasi || 'N/A',
                    }));
                } else {
                    // No data available, show the "Data tidak ditemukan" error message
                    this.hasError = true;
                    this.errorMsg = 'Data tidak ditemukan';
                    this.data = []; // Clear the data in case it's previously populated
                }
                this.isLoading = false;
                console.log('Data fetched successfully:', this.data);
            })
            .catch((error) => {
                this.isLoading = false;
                this.hasError = true; 
                // this.errorMsg = 'Failed to fetch data: ' + (error.body ? error.body.message : error.message);
                this.errorMsg = 'Data tidak ditemukan';
                console.error('Error fetching data:', error);
            });
    }
    

    // Clear the data and reset loading/error flags
    clearData() {
        this.data = [];  
        this.isLoading = true;  
        this.hasError = false;
        this.errorMsg = ''; 
    }

    // Reset the form and hide the result card when the "Close" button is clicked
    handleClose() {
        this.clearData();
        this.hasSearched = false;  // Hide the result card
        this.nomorKartu = '';
        this.username = '';
        this.nomorHp = '';
        this.disableSearchButton = true;
        this.disableNomorKartuField = false;
        this.disableUsernameField = false;
        this.disableNomorHandphoneField = false;
    }

    sanitizeField(field) {
        return (String(field).trim() !== "") ? String(field).trim() : "N/A";
    }

    // Censor phone number (show only last 4 digits)
    censorPhone(phoneNumber) {
        
        phoneNumber = this.sanitizeField(phoneNumber);
        
        if (!phoneNumber || phoneNumber === "N/A") return "N/A";

        const numStr = phoneNumber.toString();
        return numStr.slice(0, -4).replace(/./g, 'x') + numStr.slice(-4); // Keep last 4 digits
    }

    // Mask username (show first letter and last 2 digits)
    censorUsername(username) {
        username = this.sanitizeField(username);

        if (!username || username === "N/A") return "N/A";

        const usernameStr = username.toString();
        
        // Ensure the username is long enough to be masked
        if (usernameStr.length < 3) return usernameStr; // If too short, return as is

        const firstLetter = usernameStr.charAt(0);
        const lastTwoLetters = usernameStr.slice(-2);
        const maskedMiddle = 'x'.repeat(usernameStr.length - 3); // Mask the middle part

        return firstLetter + maskedMiddle + lastTwoLetters;
    }

    // Format the card number by splitting into 4-digit blocks
    formatCardNumber(cardNumber) {
        const numStr = cardNumber.replace(/\D/g, ''); // Remove non-digit characters
        return numStr.match(/.{1,4}/g).join(' '); // Split into blocks of 4 digits
    }

}