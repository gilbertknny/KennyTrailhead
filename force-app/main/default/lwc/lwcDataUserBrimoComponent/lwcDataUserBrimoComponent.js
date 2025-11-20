/** 
    LWC Name    : lwcDataUserBrimoComponent.js
    Created Date       : 26 November 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    //release 3
    1.0   26/11/2024   Rakeyan Nuramria                  Initial Version
    1.0   03/02/2025   Rakeyan Nuramria                  Adjust functionality for API & Error handling
    1.0   04/02/2025   Rakeyan Nuramria                  Add functionality to delete BRIMO
    1.0   18/02/2025   Rakeyan Nuramria                  Adjust logic response handling for delete API
    1.0   21/02/2025   Rakeyan Nuramria                  Change req ChannelId to NBMB
    1.0   26/02/2025   Rakeyan Nuramria                  Adjust to show concat fields for Task based on feedback
    1.0   26/02/2025   Rakeyan Nuramria                  Adjust request parameter & data to show in the UI & status rekening/user
    1.0   26/02/2025   Rakeyan Nuramria                  Adjust logic new requirment : multi-step modal
    1.0   27/02/2025   Rakeyan Nuramria                  Adjust logic for access to delete brimo

**/

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchUserBrimo from '@salesforce/apex/SCC_CaseBRICare.searchUserBrimo';
import deleteUserBrimo from '@salesforce/apex/SCC_CaseBRICare.deleteUserBrimo';
import getHapusBrimoPermission from '@salesforce/customPermission/Hapus_Akun_Brimo';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';


export default class LwcDataUserBrimoComponent extends LightningElement {

    @api recordId
    @api isCloseHidden;
    @api caseId;
    @api noKartu;
    @api noRekening;
    @api noCif;
    @api noTelp;

    @track selectedNomorHp;
    @track selectedNomorCif;
    @track selectedNomorRekening;
    @track selectedNomorKartu;

    @track showMainCard = false;
    @track showHistoryKartu = false;
    @track showInquiryKartu = false;
    @track showConfirmationModal = false;

    @track dataBrimo = [];

    @track isLoading = false;
    @track hasError= false;
    @track hasAccountError= false;
    @track hasActivityError= false;
    @track errorMessage;
    @track errorMsg;
    @track errorAccountMsg;
    @track errorActivityMsg;

    @track isProcessing = false;  // Controls whether the deletion process is ongoing
    timeoutDuration = 30000; // Timeout duration in ms (30 seconds)

    mockupResponse = {
        "message": "",
        "response_code": "00",
        "response_data": {
            "account_list": [
            {
                "account": "0206********552",
                "account_name": "Revamp asuransi",
                "card_number": "5221********1940",
                "finansial_status": "1",
                "product_type": "Simpedes",
                "status": "1",
                "type_account": "SA"
            },
            {
                "account": "0206********552",
                "account_name": "Revamp asuransi 2",
                "card_number": "5221********1940",
                "finansial_status": "1",
                "product_type": "Simpedes",
                "status": "2",
                "type_account": "SA"
            }
            ],
            "activity_history": [
            {
                "activity_date": "15 Jul 2024",
                "activity_dest": "Klaim - 12271229",
                "activity_icon": "icon_dplk.png",
                "activity_status": "Sukses",
                "activity_time": "15:14",
                "activity_type": "DPLK",
                "id": "323477257205",
                "reference_num": "323477257205",
                "total_amount": "Rp2.145.678,99",
                "trx_type": "PaymentUpdateStatusClaimDPLK"
            },
            {
                "activity_date": "16 Jul 2024",
                "activity_dest": "Klaim - 12271230",
                "activity_icon": "icon_dplk.png",
                "activity_status": "Sukses",
                "activity_time": "15:14",
                "activity_type": "DPLK",
                "id": "323477257205",
                "reference_num": "323477257205",
                "total_amount": "Rp2.145.678,99",
                "trx_type": "PaymentUpdateStatusClaimDPLK"
            }
            ],
            "cellphone_number": "08128709****",
            "email_address": "farr****************@gmail.com",
            "financial_status": "1",
            "last_login_attempt": {
            "last_login": "",
            "login_status": ""
            },
            "registered_date": "2010-10-10 10:10:10",
            "status": "3",
            "user_alias": "usergans005",
            "username": "usersbn005"
        },
        "response_description": "Success",
        "response_id": "b42a4c4b18054dd5816454d64da07190",
        "response_refnum": "123456789192"
    }

    @track hasHapusBrimoPermission = false;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.value.fields.Name.value;
            // Check if user is System Administrator OR has custom permission
            this.hasHapusBrimoPermission = profileName === 'System Administrator' || getHapusBrimoPermission;
        } else if (error) {
            console.error('Error loading user profile:', error);
            // Fallback to just custom permission check if profile load fails
            this.hasHapusBrimoPermission = getHapusBrimoPermission;
        }
    }

    
    /* MAIN LOGIC */

    // Mapping Status Rekening => AccountList
    getStatusRekening(statusCode) {
        switch (statusCode) {
            case "1": return "Active";
            case "2": return "Closed";
            case "3": return "Matured but not Closed";
            case "4": return "New Today";
            case "5": return "Zero Actual";
            // case "6": return "Frozen with Accrual (Restricted, bisa setor, gabisa tarik)";
            // case "7": return "Frozen witn no Accrual (Frozen, gabisa setor, gabisa tarik)";
            case "6": return "Frozen with Accrual (Restricted)";
            case "7": return "Frozen witn no Accrual (Frozen)";
            case "8": return "Charge Off";
            case "9": return "Dormant";
            default: return "Unknown";
        }
    }

    // Mapping Status User
    getStatusUser(statusCode) {
        switch (statusCode) {
            case "0": return "Blocked";
            case "1": return "Active without Alias";
            case "2": return "Disable";
            case "3": return "Active with Alias";
            default: return "Unknown";

        }
    }


    connectedCallback() {
        console.log('nomor Rekening BRIMO from parent: ', this.noRekening);
        console.log('nomor kartu BRIMO from parent: ', this.noKartu);
        console.log('nomor cif from parent: ', this.noCif);
        console.log('nomor telepon from parent: ', this.noTelp);
        console.log('recordId from parent: ', this.recordId);
        console.log('caseId from parent: ', this.caseId);
    
        this.selectedNomorRekening = this.noRekening;
        this.selectedNomorKartu = this.noKartu;
        this.selectedNomorCif = this.noCif;
        this.selectedNomorHp = this.noTelp;
        this.fetchDataBrimo();
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
    
    /** 
    fetchDataBrimo() {
        this.clearErrorsAndResults();
        console.log("fetchDataBrimo called...");
        this.isLoading = true;  // Set loading state to true

        const recId = this.recordId || this.caseId;
        const requestPayload = {
            client: "",
            request_refnum: "",
            account_number: this.selectedNomorRekening,
            cellphone_number: this.userPhoneNumber,
            channel_id: "CHMS",
            cif: this.selectedNomorCif
        };

        console.log('Request Payload BRIMO: ', JSON.stringify({ req: requestPayload, recid: recId }));

        // Simulate API call with mockupResponse instead of the real API
        this.simulateApiCallWithMockupResponse()

        // Call Apex method or use mockup API response
        // searchUserBrimo({ req: requestPayload, recid: recId })
            .then(result => {
                console.log('fetchDataBrimo received:', JSON.stringify(result, null, 2));

                // Check if the response is empty or invalid
                if (!result || !result.response_data) {
                    this.handleError('Data tidak ditemukan');
                } else {
                    this.processData(result.response_data);
                }
            })
            .catch(error => {
                console.error('fetchDataBrimo Error occurred during search:', error.message);
                this.handleError('Terjadi kesalahan saat mengambil data.');
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });
    }

    processData(responseData) {
        console.log("Processing Data...");
    
        this.dataBrimo = { ...responseData };
    
        // Account List: Process account information
        if (!responseData.account_list || responseData.account_list.length === 0) {
            this.hasAccountError = true;
            this.errorAccountMsg = 'Data akun kosong.';
            this.accountList = [];
        } else {
            this.accountList = responseData.account_list.map(account => ({
                account: account.account,
                accountName: account.account_name,
                cardNumber: account.card_number,
                productType: account.product_type,
                status: account.status === "1" ? "Aktif" : "Nonaktif",
                typeAccount: account.type_account
            }));
            this.hasAccountError = false;
        }
    
        // Activity History: Process activity history data
        if (!responseData.activity_history || responseData.activity_history.length === 0) {
            this.hasActivityError = true;
            this.errorActivityMsg = 'Data aktivitas kosong.';
            this.history = [];
        } else {
            this.history = responseData.activity_history.map(item => ({
                date: item.activity_date,
                dest: item.activity_dest,
                icon: item.activity_icon,
                status: item.activity_status,
                time: item.activity_time,
                type: item.activity_type,
                referenceNum: item.reference_num,
                totalAmount: item.total_amount,
                trxType: item.trx_type
            }));
            this.hasActivityError = false;  // Clear any error
        }
    
        // Directly assign the user details from responseData using spread operator
        Object.assign(this, {
            userPhoneNumber: responseData.cellphone_number,
            email: responseData.email_address,
            userAlias: responseData.user_alias,
            username: responseData.username,
            registeredDate: responseData.registered_date,
            financialStatus: responseData.financial_status,
            status: responseData.status === "1" ? "Aktif" : "Nonaktif"
        });
    }
    */

    fetchDataBrimo() {
        this.clearErrorsAndResults();
        console.log("fetchDataBrimo called...");
        this.isLoading = true;  // Set loading state to true
    
        const recId = this.recordId || this.caseId;
        const requestPayload = {
            client: "BRIMON",
            request_refnum: "",
            account_number: this.selectedNomorRekening,
            cellphone_number: this.selectedNomorHp,
            // channel_id: "CHMS",
            channel_id: "NBMB",
            cif: this.selectedNomorCif
        };
    
        console.log('Request Payload BRIMO: ', JSON.stringify({ req: requestPayload, recid: recId }));
    
        // Simulate API call with mockupResponse instead of the real API
        // this.simulateApiCallWithMockupResponse()
    
        // Call Apex method or use mockup API response
        searchUserBrimo({ req: requestPayload, recid: recId })
        .then(result => {
            console.log('fetchDataBrimo received:', JSON.stringify(result, null, 2));
    
            // Check if the response is empty or invalid
            if (!result || !result.response_data || 
                (Object.keys(result.response_data).length === 0 && result.response_data.constructor === Object)) {
                this.handleError('Data tidak ditemukan');
            } else {
                this.processData(result.response_data);  // Proceed only if data is valid
            }
        })
        .catch(error => {
            console.error('fetchDataBrimo Error occurred during search:', error.message);
            this.handleError('Terjadi kesalahan saat mengambil data.');
        })
        .finally(() => {
            this.isLoading = false;
            console.log('Loading state set to false.');
        });
    }

    processData(responseData) {
        console.log("Processing Data...");
    
        this.dataBrimo = { ...responseData };
    
        // Account List: Process account information
        if (!responseData.account_list || responseData.account_list.length === 0) {
            this.hasAccountError = true;
            this.errorAccountMsg = 'Data akun kosong.';
            this.accountList = [];
        } else {
            this.accountList = responseData.account_list.map(account => ({
                account: account.account,
                accountName: account.account_name,
                cardNumber: account.card_number,
                productType: account.product_type,
                status: this.getStatusRekening(account.status),
                financialStatus: account.finansial_status === "1" ? "Aktif" : "Nonaktif",
                typeAccount: account.type_account
            }));
            this.hasAccountError = false;
        }
    
        // Activity History: Process activity history data
        if (!responseData.activity_history || responseData.activity_history.length === 0) {
            this.hasActivityError = true;
            this.errorActivityMsg = 'Data aktivitas kosong.';
            this.history = [];
        } else {
            this.history = responseData.activity_history.map(item => ({
                date: item.activity_date,
                dest: item.activity_dest,
                icon: item.activity_icon,
                status: item.activity_status,
                time: item.activity_time,
                type: item.activity_type,
                referenceNum: item.reference_num,
                totalAmount: item.total_amount,
                trxType: item.trx_type,
                concatTask : `${(item.activity_type?.trim() || '-')} | ${(item.activity_dest?.trim() || '-')} | ${(item.trx_type?.trim() || '-')}`
            }));
            this.hasActivityError = false;  // Clear any error
        }
    
        // Directly assign the user details from responseData using spread operator
        Object.assign(this, {
            userPhoneNumber: responseData.cellphone_number,
            email: responseData.email_address,
            userAlias: responseData.user_alias,
            username: responseData.username,
            registeredDate: responseData.registered_date,
            financialStatus: responseData.financial_status === "1" ? "Aktif" : "Nonaktif",
            status: this.getStatusUser(responseData.status)
        });
    }
    
    
    // handleSubmitDeletion(){
    //     // Disable the modal buttons and show the spinner
    //     this.isProcessing = true;

    //     console.log('handleSubmitDeletion called..');

    //     const requestPayload = {
    //         client: "BRIMON",
    //         request_refnum: "",
    //         channel_id : "NBMB",
    //         // user_id : "",
    //         username : this.username,
    //         // card_number : this.noKartu,
    //         account_number : this.selectedNomorRekening,
    //         cellphone_number : this.selectedNomorHp

    //     };

    //     console.log('request deleteBrimo : ', JSON.stringify(requestPayload, null, 2));

    //     const reqRecordId = this.recordId;

    //     // Create a timeout promise
    //     const timeoutPromise = new Promise((_, reject) =>
    //         setTimeout(() => reject(new Error('Request timed out')), this.timeoutDuration)
    //     );

    //     // Race the API call against the timeout
    //     Promise.race([
    //         deleteUserBrimo({ req: requestPayload, recid: reqRecordId }),
    //         timeoutPromise
    //     ])
    //         .then(result => {
    //             console.log('Response  handleSubmitDeletion received:', JSON.stringify(result, null, 2));

    //             const desc = result?.response_desc || result?.response_description;
    //             if (result.response_code === '00' || (desc && desc.toLowerCase().includes('succes'))) {
    //                 // Success case
    //                 this.showToast('Success', `BRIMO data for ${this.noRekening} deleted successfully.`, 'success');
    //                 this.fetchDataBrimo();
    //                 this.handleCancelModal();
    //             } else {
    //                 // Any non-00 response code is treated as an error
    //                 const errorMessage = `${result.response_code} - ${result.response_description || result.response_desc}`;
    //                 this.showToast('Error', errorMessage, 'error');
    //             }
    //         })
    //         .catch(error => {
    //             console.error('Error occurred during handleDeleteBlokir:', error);

    //             // Check if the error is a timeout
    //             if (error.message === 'Request timed out') {
    //                 this.showToast('Error', 'The request took too long to complete. Please try again later.', 'error');
    //             } else {
    //                 // Show the error message if it was not a timeout
    //                 const errorMessage = error.body ? error.body.message : 'An unknown error occurred.';
    //                 console.error("delete Brimo error : ", error.message)
    //                 this.showToast('Error', `Failed to delete the BRIMO data: ${errorMessage}`, 'error');
    //             }
    //         })
    //         .finally(() => {
    //             // Stop the spinner and re-enable the buttons after the deletion process is complete
    //             this.isProcessing = false;
    //         });
    // }
    

    // handleConfirmDeletionModal(){
    //     this.showConfirmationModal = true;
    // }

    // handleCancelModal() {
    //     this.showConfirmationModal = false;
    // }
    
    handleCloseDataBrimo(){
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });

        this.dispatchEvent(closeEvent);

    }

    handleOpenHistoryKartu(){
        this.showHistoryKartu = true;
    }

    handleOpenInquiryAccount(){

        this.showInquiryKartu = true;

    }

    handleCloseHistoryKartu(){

        this.showHistoryKartu = false;

    }

    handleCloseInquiryAccount(){

        this.showInquiryKartu = false;

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
            this.fetchDataBrimo(); // Fetch new card details
        }
    }

    handleError(message) {
        this.hasError = true;
        this.errorMsg = message;
        this.isLoading = false;  // Ensure loading state is false when an error occurs
        this.accountList = [];  // Clear the account list on error
        this.history = [];      // Clear activity history
        this.dataBrimo = [];

        console.error('Error Message:', this.errorMsg);
        // this.showToast('Error', this.errorMsg, 'error');
    }

    clearErrorsAndResults() {
        this.errorMsg = '';
        this.nikError = '';
        this.dataBrimo = [];
        this.hasError = false;
        this.showResult = false;

    }
    
    /* END MAIN LOGIC */

    /** UTILITIES FUNCTION */

    @api handleClear(){

        this.isLoading = false;
        this.errorMsg = '';
        this.hasError = false;

    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    /** PoC v2 - with multi-step modal */

    // Properties for two-step modal
    @track currentStep = 1;
    @track usernameInput = '';
    @track usernameErrorMessage = '';
    @track hasUsernameError = false;
    @track showModal = false;
    @track isProcessing = false;

    // Computed properties
    get isStepOne() {
        return this.currentStep === 1;
    }
    
    get isStepTwo() {
        return this.currentStep === 2;
    }
    
    get modalTitle() {
        return this.isStepOne ? 'Step 1 : Masukan Username' : 'Step 2 : Konfirmasi Hapus';
    }
    
    get isNextDisabled() {
        // Fix logic to properly validate username and enable button
        return !this.usernameInput || this.usernameInput.trim() === '' || this.hasUsernameError;
    }
    
    get usernameInputClass() {
        return `slds-input username-input ${this.hasUsernameError ? 'slds-has-error' : ''}`;
    }
    
    // Helper for lightning-progress-indicator component
    get currentStepString() {
        // The component expects a string value
        return this.currentStep.toString();
    }
    
    // Event handlers
    handleConfirmDeletionModal() {
        this.currentStep = 1;
        // Clear username when opening the modal
        this.usernameInput = '';
        this.hasUsernameError = false;
        this.usernameErrorMessage = '';
        this.showModal = true;
    }
    
    handleCancelModal() {
        this.showModal = false;
        this.resetModalState();
    }
    
    handleUsernameChange(event) {
        this.usernameInput = event.target.value;
        this.validateUsername();
    }
    
    validateUsername() {
        if (!this.usernameInput || this.usernameInput.trim() === '') {
            this.hasUsernameError = true;
            this.usernameErrorMessage = 'Username tidak boleh kosong';
            return false;
        } else if (this.usernameInput.length < 3) {
            this.hasUsernameError = true;
            this.usernameErrorMessage = 'Username minimal 3 karakter';
            return false;
        } else {
            this.hasUsernameError = false;
            this.usernameErrorMessage = '';
            return true;
        }
    }
    
    handleNext() {
        if (this.validateUsername()) {
            this.currentStep = 2;
        }
    }
    
    handleBack() {
        this.currentStep = 1;
        // Username is preserved
    }
    
    goToStep1() {
        // Only allow going back to step 1 if we're not processing
        if (!this.isProcessing) {
            this.currentStep = 1;
        }
    }
    
    handleSubmitDeletion() {
        // Disable the modal buttons and show the spinner
        this.isProcessing = true;

        console.log('handleSubmitDeletion called..');

        const requestPayload = {
            client: "BRIMON",
            request_refnum: "",
            channel_id: "NBMB",
            username: this.usernameInput,
            account_number: this.selectedNomorRekening,
            cellphone_number: this.selectedNomorHp
        };

        console.log('request deleteBrimo : ', JSON.stringify(requestPayload, null, 2));

        const reqRecordId = this.recordId;

        // Create a timeout promise
        const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('Request timed out')), this.timeoutDuration)
        );

        // Race the API call against the timeout
        Promise.race([
            deleteUserBrimo({ req: requestPayload, recid: reqRecordId }),
            timeoutPromise
        ])
            .then(result => {
                console.log('Response handleSubmitDeletion received:', JSON.stringify(result, null, 2));

                const desc = result?.response_desc || result?.response_description;
                if (result.response_code === '00' || (desc && desc.toLowerCase().includes('succes'))) {
                    // Success case
                    this.showToast('Success', `BRIMO data for ${this.selectedNomorRekening} deleted successfully.`, 'success');
                    this.fetchDataBrimo();
                    this.handleCancelModal();
                } else {
                    // Any non-00 response code is treated as an error
                    const errorMessage = `${result.response_code} - ${result.response_description || result.response_desc}`;
                    this.showToast('Error', errorMessage, 'error');
                }
            })
            .catch(error => {
                console.error('Error occurred during handleDeleteBlokir:', error);

                // Check if the error is a timeout
                if (error.message === 'Request timed out') {
                    this.showToast('Error', 'The request took too long to complete. Please try again later.', 'error');
                } else {
                    // Show the error message if it was not a timeout
                    const errorMessage = error.body ? error.body.message : 'An unknown error occurred.';
                    console.error("delete Brimo error : ", error.message);
                    this.showToast('Error', `Failed to delete the BRIMO data: ${errorMessage}`, 'error');
                }
            })
            .finally(() => {
                // Stop the spinner and re-enable the buttons after the deletion process is complete
                this.isProcessing = false;
            });
    }
    
    resetModalState() {
        this.currentStep = 1;
        this.usernameInput = '';
        this.hasUsernameError = false;
        this.usernameErrorMessage = '';
    }
}