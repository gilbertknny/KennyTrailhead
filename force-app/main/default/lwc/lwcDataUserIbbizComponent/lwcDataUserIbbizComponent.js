/** 
    LWC Name           : lwcDataUserIbizComponent.js
    Created Date       : 25 November 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   25/11/2024   Rakeyan Nuramria                  Initial Version
    1.0   30/01/2025   Rakeyan Nuramria                  Adjust Logic & API Functionality
    1.0   31/01/2025   Rakeyan Nuramria                  Adjust Error Handling & Censored Field & API Functionality
**/

import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getIbbiz from '@salesforce/apex/SCC_CaseBRICare.getIbbiz';

export default class LwcDataUserIbbizComponent extends LightningElement {
    @api caseId;
    @api recordId;
    @api isCloseHidden;
    @api noKartu;
    @api noRekening;
    @api corporateId;

    @track selectedNomorKartu;
    @track selectedNomorRekening;

    @track ibbizData = [];
    @track clientData = {};
    @track userData = [];
    @track listRekening = [];

    @track isLoading = false;
    @track hasError= false;
    @track errorMessage;
    @track errorMsg;
    @track userDataError = false; // Track error for user data section
    @track listRekeningError = false; // Track error for list rekening section

    mockupResponse = {
        
        extensions: {
            responseCode: "00",
            responseDesc: "success",
            responseMessage: "OK"
        },
        message: "OK",
        response: {
            data: {
                clientData: {
                    // accNumber: "022501000538564",
                    // branchCode: "",
                    // cardNumber: "5221847700392232",
                    // createdAt: "2024-10-23T04=03=21+07=00",
                    // handle: "IBBIZUIUX",
                    // id: 10001361,
                    // // "id": "",
                    // name: "SIGNER"
                },
                clientId: 10001361,
                listRekening: {
                    listData: [
                    {
                        accountName: "LAM SUN ON (haz3l)",
                        accountNumber: "020601005578533",
                        accountType: "S",
                        productType: "S6",
                        status: 1
                    },
                    {
                        accountName: "",
                        accountNumber: "",
                        accountType: "",
                        productType: "",
                        status: ""
                    }
                    ]
                },
                responseCode: "00",
                responseDesc: "success",
                responseMessage: "OK",
                userData: {
                    listData: [
                    {
                        email: "sitikhairaninasution31@gmail.com",
                        handphone: "0895613333786",
                        id: 10002343,
                        lastLogin: "0001-01-01T00=00=00Z",
                        lastLogout: "1970-01-01T08=00=00+07=00",
                        name: "Bil Nasution",
                        userType: 1
                    },
                    {
                        email: "",
                        handphone: "",
                        id: "",
                        lastLogin: "",
                        lastLogout: "",
                        name: "",
                        userType: ""
                    }
                    ]
                }
            }
        }
    }

    connectedCallback(){
        console.log('nomor kartu from parent : ', this.noKartu);
        console.log('nomor Rekening from parent : ', this.noRekening);

        this.selectedNomorKartu = this.noKartu;
        this.selectedNomorRekening = this.noRekening;

        this.fetchDataIbbiz();
        // this.processedData();

    }

    renderedCallback(){

    }

    // Mock function simulating API response
    simulateApiCallWithMockupResponse() {
        return new Promise((resolve, reject) => {
            // Simulate a delay like an actual API call
            setTimeout(() => {
                // Use the mockupResponse directly here
                const mockResponse = this.mockupResponse;
                resolve(mockResponse); // Return mock data as if it came from the API
            }, 1000); // Simulate a delay of 1 second
        });
    }

    fetchDataIbbiz() {
        console.log('function fetchDataIbbiz called..');

        this.isLoading = true;
        this.hasError = false;
        this.errorMsg = '';

        const requestPayload = {
            corporateId: this.corporateId,
            acctNo: this.selectedNomorRekening
        };

        const recId = this.recordId || this.caseId;

        console.log('request ibbiz payload : ', JSON.stringify({ req: requestPayload, recid: recId }));


        // Simulate API call with mockupResponse instead of the real API
        // this.simulateApiCallWithMockupResponse()

        //Call real API
        getIbbiz({req: requestPayload, recid:recId})
            .then(result => {
                console.log('API Ibbiz Response:', JSON.stringify(result, null, 2));

                // if (result) {
                //     this.processData(result.response.data);
                // } else {
                //     this.handleError('Data tidak ditemukan');
                // }

                if (result && result.response && result.response.data) {
                    const responseData = result.response.data;
        
                    // Check if client data exists
                    // if (responseData.clientData) {
                    //     this.processData(responseData);
                    // } else {
                    //     this.handleError('Data tidak ditemukan'); // General error if client data is missing
                    // }

                    // Check if clientData exists and is not empty
                    if (!responseData.clientData || this.isEmptyResponse(responseData.clientData)) {
                        this.handleError('Data tidak ditemukan'); // Show error if client data is missing or empty
                        return; // Prevent further processing
                    }

                    // Process valid data
                    this.processData(responseData);
        
                    // Check if userData section is empty
                    if (this.isEmptyResponse(responseData.userData)) {
                        this.userDataError = true;
                    }
        
                    // Check if listRekening section is empty
                    if (this.isEmptyResponse(responseData.listRekening)) {
                        this.listRekeningError = true;
                    }
                } else {
                    this.handleError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('API Ibbiz Error:', error.message);
                this.handleError('Terjadi kesalahan saat mengambil data.');
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });
    }

    // Method to process data from the API response
    processData(responseData) {
        if (responseData.clientData) {
            this.clientData = {
                accNumber: this.censorAccountNumber(responseData.clientData.accNumber),
                branchCode: this.sanitizeFieldClientData(responseData.clientData.branchCode),
                cardNumber: this.censorCardNumber(responseData.clientData.cardNumber),
                createdAt: this.sanitizeFieldClientData(responseData.clientData.createdAt),
                handle: this.sanitizeFieldClientData(responseData.clientData.handle),
                id: this.sanitizeFieldClientData(responseData.clientData.id),
                name: this.sanitizeFieldClientData(responseData.clientData.name),
            };
        }
    
        // Censor userData (email, phone) and sanitize other fields
        if (responseData.userData && responseData.userData.listData) {
            this.userData = responseData.userData.listData.map(user => ({
                email: this.censorEmail(user.email),
                handphone: this.censorPhone(user.handphone),
                id: this.sanitizeField(user.id),
                lastLogin: this.sanitizeField(user.lastLogin),
                lastLogout: this.sanitizeField(user.lastLogout),
                name: this.sanitizeField(user.name),
                userType: this.getUserTypeLabel(String(user.userType)),
            }));
        }
    
        // Censor listRekening (account number) and sanitize other fields
        if (responseData.listRekening && responseData.listRekening.listData) {
            this.listRekening = responseData.listRekening.listData.map((account, index) => ({
                no: index + 1,
                accountName: this.sanitizeField(account.accountName),
                accountNumber: this.censorAccountNumber(account.accountNumber),
                accountType: this.sanitizeField(account.accountType),
                productType: this.sanitizeField(account.productType),
                status: this.sanitizeField(account.status) === '1' ? 'Aktif' : 'Nonaktif',
                customStatus: this.sanitizeField(account.status) === '1' ? 'status-aktif' : 'status-nonaktif'
            }));
        }
    
        // Set the processed data (now includes sanitized and censored fields)
        this.ibbizData = {
            clientData: this.clientData,
            userData: this.userData,
            listRekening: this.listRekening
        };
    
        console.log('Processed Data:', this.ibbizData);
    }

    handleCloseDataIbbiz() {
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        this.handleClear();
        this.dispatchEvent(closeEvent);
    }

    @api handleClear() {
        // this.noKartu = '';
        // this.noRekening = '';

        this.isLoading = false;
        this.errorMsg = '';
        this.hasError = false;

    }

    @api updateCardDetails() {
        // Only update if the card number is different
        // if (this.noKartu && this.noKartu !== this.selectedNomorKartu) {
        //     this.selectedNomorKartu = this.noKartu;
        //     this.fetchDataIbbiz(); // Fetch new card details
        // }

        // Only update if the card number is different
        if (this.noRekening && this.noRekening !== this.selectedNomorRekening) {
            this.selectedNomorRekening = this.noRekening;
            console.log(`Fetching data for new card number: ${this.selectedNomorRekening}`);
            this.fetchDataIbbiz(); // Fetch new card details
        }
    }

    handleError(message) {
        this.hasError = true;
        this.errorMsg = message;
        this.isLoading = false;
        this.data = [];
        console.error('Error Ceria Message:', this.errorMsg);
    }

    clearErrorsAndResults() {
        this.errorMsg = '';
        this.nikError = '';
        this.data = [];
        this.hasError = false;
        this.showResult = false;

    }

    // Method to check if response data is empty or missing key fields
    // isEmptyResponse(data) {
    //     return !data || (Array.isArray(data) && data.length === 0) || Object.keys(data).length === 0;
    // }

    isEmptyResponse(data) {
        // Check if 'data' is null, undefined, or an empty object
        if (!data || Object.keys(data).length === 0) {
            return true;
        }
    
        // If the data is an object and contains a 'listData' property, check if it's empty
        if (data.listData && Array.isArray(data.listData) && data.listData.length === 0) {
            return true;
        }
    
        // Return false if no empty conditions are met
        return false;
    }

    // Helper function to map userType number to its string representation
    getUserTypeLabel(userTypeValue) {
        const userTypeMap = {
            '1': 'Maker',
            '2': 'Checker',
            '3': 'Signer',
            '4': 'Admin'
        };
        return userTypeMap[userTypeValue] || '-'; // Return '-' for undefined values
    }

    // Helper function to sanitize fields for clientData (set "N/A" for empty values)
    sanitizeFieldClientData(field) {
        return (String(field).trim() !== "") ? String(field).trim() : "N/A";
    }

    // Helper function to sanitize fields for listRekening and userData (set "-" for empty values)
    sanitizeField(field) {
        return (String(field).trim() !== "") ? String(field).trim() : "-";
    }

    // Censor email by replacing part before "@" with 'x'
    censorEmail(email) {
        // Use the sanitizeFieldClientData to ensure "N/A" for empty values
        email = this.sanitizeFieldClientData(email);
        
        if (!email || email === "N/A") return "N/A"; // If email is empty or "N/A", return "N/A"

        const [local, domain] = email.split('@');
        const censoredLocal = local.slice(0, -2).replace(/./g, 'x') + local.slice(-2); // Keep last 2 characters
        return `${censoredLocal}@${domain}`;
    }

    // Censor phone number (show only last 4 digits)
    censorPhone(phoneNumber) {
        
        phoneNumber = this.sanitizeField(phoneNumber);
        
        if (!phoneNumber || phoneNumber === "-") return "-";

        const numStr = phoneNumber.toString();
        return numStr.slice(0, -4).replace(/./g, 'x') + numStr.slice(-4); // Keep last 4 digits
    }

    // Censor account number (show only last 4 digits)
    censorAccountNumber(accountNumber) {

        accountNumber = this.sanitizeField(accountNumber);
        
        if (!accountNumber || accountNumber === "-") return "-";
        const numStr = accountNumber.toString();
        return numStr.slice(0, -4).replace(/./g, 'x') + numStr.slice(-4); // Keep last 4 digits
    }

    // Format the card number by splitting into 4-digit blocks
    formatCardNumber(cardNumber) {
        const numStr = cardNumber.replace(/\D/g, ''); // Remove non-digit characters
        return numStr.match(/.{1,4}/g).join(' '); // Split into blocks of 4 digits
    }

    // Censor card number (after formatting, censor middle blocks)
    censorCardNumber(cardNumber) {
        
        cardNumber = this.sanitizeField(cardNumber);
        
        if (!cardNumber || cardNumber === "-") return "-";
        
        // Card number into blocks of 4 digits
        const formatted = this.formatCardNumber(cardNumber);

        // Censorship
        const blocks = formatted.split(' ');

        // Censor middle blocks and return
        const censored = blocks.map((block, index) => {
            if (index === 0 || index === blocks.length - 1) {
                return block; // Keep first and last blocks
            }
            return 'xxxx'; // Censor the middle blocks
        }).join(' ');

        return censored;
    }

    //END MAIN LOGIC

    /** UTILITIES/MISC FUNCTION */

    // Helper function to check if the response or listRekening is empty or undefined
    // isEmptyResponse(responseData) {
    //     return !responseData || 
    //         !responseData.clientData || 
    //         !responseData.listRekening || 
    //         !Array.isArray(responseData.listRekening.listData) || 
    //         responseData.listRekening.listData.length === 0;
    // }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }



}