/** 
    LWC Name    : lwcBlokirSaldoBankingComponent.js
    Created Date       : 13 Januari 2025
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    release 3
    1.0   13/01/2025   Rakeyan Nuramria                  Intial Version
    1.0   17/02/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic response for API holdAmount, refresh data hold logic
    1.0   19/02/2025   Rakeyan Nuramria                  Adjust Logic for UI in input section
    1.0   21/02/2025   Rakeyan Nuramria                  Adjust Logic validation for UI v2 in input section

**/

import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getHoldStatusCASA from '@salesforce/apex/SCC_CaseBRICare.getHoldStatusCASA';

export default class LwcBlokirSaldoBankingComponent extends LightningElement {
    @api recordId;
    @api isCloseHidden;
    // @api noRekening;

    @api 
    get noRekening() {
        return this._noRekening;
    }
    set noRekening(value) {
        this._noRekening = value;
        this.selectedNomorRekening = value; // Update selectedNomorRekening whenever noRekening changes
    }

    @api noKartu;

    _noRekening;
    @track data = [];
    @track holdAmount = '';
    @track tglJatuhTempo = '';
    @track remarkHold = '';
    @track tglDitempatkan = '';
    @track selectedNomorRekening;

    @track isBlockProcessDone;
    @track errors = {
        remarkHold: '',
        // tglDitempatkan: '',
        // tglJatuhTempo: '',
        holdAmount: ''
    };

    @track errorClasses = {
        remarkHold: '',
        // tglDitempatkan: '',
        // tglJatuhTempo: '',
        holdAmount:''
    };

    @track showConfirmationModal = false; // Controls the visibility of the modal
    @track isProcessingBlokir = false;
    timeoutDuration = 30000; // Timeout duration in ms (30 seconds)

    

    connectedCallback() {

        console.log('nomor rekening blokir from parent : ', this.noRekening);
        console.log('nomor kartu blokir from parent : ', this.noKartu);
        this.selectedNomorRekening = this.noRekening;
    }

    renderedCallback() {
    }

    @api updateGrandchildHoldDetails() {

        // Use setTimeout to ensure component rendering is complete
        setTimeout(() => {
            const blockedBankingComponent = this.template.querySelector('c-lwc-blocked-banking-information-component');
            if (blockedBankingComponent) {
                blockedBankingComponent.noRekening = this.selectedNomorRekening;
                blockedBankingComponent.updateCardHoldDetails();
            } else {
                console.error('🚫 Blokir Child: Grandchild component not found!');
            }
        }, 0);
    }

    handleHoldAmountChange(event) {
        this.holdAmount = event.target.value;
        this.validateHoldAmount();
    }
    
    handleRemarkHoldChange(event) {
        this.remarkHold = event.target.value;
        this.validateRemarkHold();
    }
    
    handleTglJatuhTempoChange(event) {
        this.tglJatuhTempo = event.target.value;
        // this.validateTglJatuhTempo();
    }
    
    handleTglDitempatkanChange(event) {
        this.tglDitempatkan = event.target.value;
        // this.validateTglDitempatkan();
    }
    
    // Individual field validations
    validateHoldAmount() {
        const digitPattern = /^\d+$/; // Regex to allow only digits
        
        if (!this.errors) {
            this.errors = {};
        }
        if (!this.errorClasses) {
            this.errorClasses = {};
        }
        
        // Clear previous error for this field
        delete this.errors.holdAmount;
        this.errorClasses.holdAmount = '';
        
        // Check if holdAmount is empty
        if (!this.holdAmount) {
            this.errors.holdAmount = 'Hold Amount harus diisi.';
            this.errorClasses.holdAmount = 'slds-has-error';
            return false;
        }

        // Check if holdAmount or a valid number
        if (this.holdAmount && !digitPattern.test(this.holdAmount)) {
            this.errors.holdAmount = 'Hanya dapat menerima angka, contoh : 10000.';
            this.errorClasses.holdAmount = 'slds-has-error';
            return false;
        }
        return true;
    }
    
    validateRemarkHold() {
        if (!this.errors) {
            this.errors = {};
        }
        if (!this.errorClasses) {
            this.errorClasses = {};
        }
        
        // Clear previous error for this field
        delete this.errors.remarkHold;
        this.errorClasses.remarkHold = '';
        
        if (!this.remarkHold) {
            this.errors.remarkHold = 'Remark Hold harus diisi.';
            this.errorClasses.remarkHold = 'slds-has-error';
            return false;
        }
        return true;
    }
    
    validateTglJatuhTempo() {
        if (!this.errors) {
            this.errors = {};
        }
        if (!this.errorClasses) {
            this.errorClasses = {};
        }
        
        // Clear previous error for this field
        delete this.errors.tglJatuhTempo;
        this.errorClasses.tglJatuhTempo = '';
        
        if (!this.tglJatuhTempo) {
            this.errors.tglJatuhTempo = 'Tanggal Jatuh Tempo is required';
            this.errorClasses.tglJatuhTempo = 'slds-has-error';
            return false;
        }
        return true;
    }
    
    validateTglDitempatkan() {
        if (!this.errors) {
            this.errors = {};
        }
        if (!this.errorClasses) {
            this.errorClasses = {};
        }
        
        // Clear previous error for this field
        delete this.errors.tglDitempatkan;
        this.errorClasses.tglDitempatkan = '';
        
        if (!this.tglDitempatkan) {
            this.errors.tglDitempatkan = 'Tanggal Ditempatkan is required';
            this.errorClasses.tglDitempatkan = 'slds-has-error';
            return false;
        }
        return true;
    }
    
    // Complete validation for all fields (used for form submission)
    validateFields() {
        let isValid = true;
        
        // Initialize error objects if they don't exist
        if (!this.errors) {
            this.errors = {};
        }
        if (!this.errorClasses) {
            this.errorClasses = {};
        }
        
        // Validate each field and collect results
        if (!this.validateHoldAmount()) {
            isValid = false;
        }
        
        if (!this.validateRemarkHold()) {
            isValid = false;
        }
        
        // if (!this.validateTglJatuhTempo()) {
        //     isValid = false;
        // }
        
        // if (!this.validateTglDitempatkan()) {
        //     isValid = false;
        // }
        
        return isValid;
    }

    /**
    handleSubmitBlokir() {
        console.log('handleSubmitBlokir called..');

        // Validate fields before submitting
        if (!this.validateFields()) {
            return;
        }


        // Convert dates to ddmmyy format before submitting
        const formattedTglJatuhTempo = this.formatDate(this.tglJatuhTempo);
        const formattedTglDitempatkan = this.formatDate(this.tglDitempatkan);

        const reqBlokirData = {
            accountNumber: this.noRekening,
            holdAmount: this.holdAmount,
            remarkHold: this.remarkHold,
            expirationDate: formattedTglJatuhTempo,
            datePlaced: formattedTglDitempatkan,
        };

        console.log('dsa reqBlokirData : ', JSON.stringify(reqBlokirData, null, 2));

        getHoldStatusCASA({ reqdt: reqBlokirData })
            .then(result => {
                console.log('dsa res result: ', JSON.stringify(result, null, 2));
                this.isBlockProcessDone = true;
            })
            .catch(error => {
                console.log('dsa error : ', error);
                this.isBlockProcessDone = false;

            });
    }
     */

    handleSubmitBlokir() {
        // Validate fields before showing the confirmation modal
        if (!this.validateFields()) {
            return;
        }
        this.showConfirmationModal = true;  // Show the confirmation modal
    }

    handleConfirmBlokir() {
        // Proceed with the block action
        // this.showConfirmationModal = false; // Close the modal

        // Disable the modal buttons and show the spinner
        this.isProcessingBlokir = true;

        // Convert dates to ddmmyy format before submitting
        // const formattedTglJatuhTempo = this.formatDate(this.tglJatuhTempo);
        // const formattedTglDitempatkan = this.formatDate(this.tglDitempatkan);
        //v2
        const formattedTglJatuhTempo = this.formatDate(this.tglJatuhTempo);
        const formattedTglDitempatkan = this.formatDate(new Date().toISOString().split('T')[0]); //today

        const reqBlokirData = {
            accountNumber: this.selectedNomorRekening,
            holdAmount: this.holdAmount,
            remarkHold: this.remarkHold,
            expirationDate: formattedTglJatuhTempo || '',
            datePlaced: formattedTglDitempatkan,
        };

        const reqRecordId = this.recordId;

        // Create a timeout promise
        const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('Request timed out')), this.timeoutDuration)
        );

        console.log('qwe blokir saldo request : ', JSON.stringify(reqBlokirData, null, 2))

        // Race the API call against the timeout
        Promise.race([
            getHoldStatusCASA({ reqdt: reqBlokirData, idacc: reqRecordId }),
            timeoutPromise
        ])
        // getHoldStatusCASA({ reqdt: reqBlokirData, idacc: reqRecordId })
            .then(result => {
                console.log('qwe blokir saldo response : ', JSON.stringify(result, null, 2))
                // this.showToastMessage('Success', 'Saldo has been blocked successfully.', 'success');
                // this.isBlockProcessDone = true;

                 // Check if response exists and has the expected structure
                if (result.response) {
                    const { responseCode, responseMessage } = result.response;
                    
                    // Check both responseCode and responseMessage for success
                    if (responseCode === '00' && responseMessage.toLowerCase().includes('success')) {
                        this.showToastMessage('Success','Saldo has been blocked successfully.' || responseMessage, 'success');
                        this.isBlockProcessDone = true;

                        // Call updateGrandchildHoldDetails after block process is successful
                        this.updateGrandchildHoldDetails();  // Call this function to refresh data

                        // Close the modal after deletion
                        this.handleCancelModal();

                        this.handleClearInput();

                    } else {
                        // If either condition indicates an error
                        this.showToastMessage('Error', responseMessage || 'There was an issue blocking the saldo.', 'error');
                        this.isBlockProcessDone = false;
                    }
                } else {
                    // If response structure is invalid
                    this.showToastMessage('Error', 'Invalid response received from server.', 'error');
                    this.isBlockProcessDone = false;
                }

            })
            .catch(error => {
                const errorMessage = error.message || 'There was an issue blocking the saldo.';
                this.showToastMessage('Error', errorMessage, 'error');
                this.isBlockProcessDone = false;
            })
            .finally(() => {
                // Stop the spinner and re-enable the buttons after the deletion process is complete
                this.isProcessingBlokir = false;
            });
    }

    handleCancelModal() {
        this.showConfirmationModal = false; // Close the modal without doing anything
    }

    handleCloseBlockSearch() {
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        this.handleClear();
        this.dispatchEvent(closeEvent);
    }

    handleClearInput(){
        this.holdAmount = '';
        this.tglJatuhTempo = '';
        this.remarkHold = '';
        this.tglDitempatkan = '';
    }

    handleClear() {
        // Reset all fields and errors
        this.holdAmount = '';
        this.tglJatuhTempo = '';
        this.remarkHold = '';
        this.tglDitempatkan = '';
        this.errors = {};
        this.errorClasses = { remarkHold: '', tglDitempatkan: '', tglJatuhTempo: '' }; // Reset error classes
    }

    /** UTILITIES FUNCTIONS */

    // function to format date from yyyy-mm-dd to ddmmyy
    formatDate(dateString) {
        if (!dateString) {
            return '';
        }
        const [year, month, day] = dateString.split('-');
        return `${day}${month}${year.slice(-2)}`; // Convert to ddmmyy format
    }

    showToastMessage(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // Options: 'error', 'success', 'warning', 'info'
        });
        this.dispatchEvent(event);
    }

    /** END UTILITIES FUNCTIONS */

}