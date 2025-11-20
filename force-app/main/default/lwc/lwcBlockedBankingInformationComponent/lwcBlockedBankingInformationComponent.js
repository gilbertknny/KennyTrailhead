/** 
    LWC Name    : lwcBlockedBankingInformationComponent.js
    Created Date       : ?? September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   ??/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   30/09/2024   Rakeyan Nuramria                  Adjust API functionality
    1.0   31/10/2024   Rakeyan Nuramria                  Adjust format amount currency
    release 3
    1.0   16/01/2025   Rakeyan Nuramria                  Add Functionality to delete the blocked amount + adjust show blocked data based on the latest date
    1.0   31/01/2025   Rakeyan Nuramria                  Add logic to show toast & confirmation deletion
    1.0   17/02/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show format date and latest, refresh hold data logic
    1.0   18/02/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic to action hapus based on custom permission
    1.0   21/02/2025   Rakeyan Nuramria                  Adjust error handling for format date
    1.0   27/08/2025   Rakeyan Nuramria                  Adjust logic format date (fix changes from support/prod) + clansing code

**/

import { LightningElement,track, api, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getHoldStatus from '@salesforce/apex/SCC_CaseBRICare.getHoldStatus';
import getUnHoldStatusCASA from '@salesforce/apex/SCC_CaseBRICare.getUnHoldStatusCASA';
import getBukaBlokirPermission from '@salesforce/customPermission/Buka_Blokir_Saldo';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

export default class LwcBlockedBankingInformationComponent extends LightningElement {
    @api recordId;
    @api noRekening;

    @track selectedNomorRekening;
    
    @track isLoading = false;
    @track hasError = false;
    @track errorMsg = '';
    @track errorMessage = '';
    @track data = [];

    @track selectedHoldAmount;
    @track holdSeqToDelete = null;
    @track showConfirmationModal;

    @track isProcessing = false;  // Controls whether the deletion process is ongoing
    timeoutDuration = 30000; // Timeout duration in ms (30 seconds)

    @track hasUnblockPermission = false;

    // Toggle inside this component only (no parent changes)
    useMock = false; // change this to true => if want to use mock data

    // Unified router for real or mock
    invokeHoldStatus(payload) {
        return this.useMock ? this.getHoldStatusMock() : getHoldStatus(payload);
    }

    getHoldStatusMock() {
        const acctNoValue = this.selectedNomorRekening;
        return Promise.resolve({
            inquiryHoldStatus: {
                errorCode: 'AS-000',
                responseCode: '00',
                responseMessage: 'Transaction Successfully',
                data: [
                    { acctNo: acctNoValue, acctType:'S', expdate:'0240428', holdAmt:'15000333', holdBranch:'00286', holdDate:'0120123', holdRemark:'DUUMY BRITAMA RENCANA 2018(0206)', holdSeq:'3', holdType:'HG', recordId:'' },
                    { acctNo: acctNoValue, acctType:'S', expdate:'0100333', holdAmt:'4236800',  holdBranch:'00354', holdDate:'0100323', holdRemark:'DUUMY BLOKIR 1X ANGSURAN KC AH NASUTION', holdSeq:'4', holdType:'HG', recordId:'' },
                    { acctNo: acctNoValue, acctType:'S', expdate:'0040439', holdAmt:'1706000',  holdBranch:'00056', holdDate:'0050424', holdRemark:'DUUMY BRIGDIG', holdSeq:'5', holdType:'HG', recordId:'' },
                    { acctNo: acctNoValue, acctType:'S', expdate:'0040925', holdAmt:'1756000',  holdBranch:'00056', holdDate:'0240825', holdRemark:'DUUMY BRIGDIG', holdSeq:'7', holdType:'HG', recordId:'' }
                ]
            }
        });
    }


    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.value.fields.Name.value;
            // Check if user is System Administrator OR has custom permission
            this.hasUnblockPermission = profileName === 'System Administrator' || getBukaBlokirPermission;
        } else if (error) {
            console.error('Error loading user profile:', error);
            // Fallback to just custom permission check if profile load fails
            this.hasUnblockPermission = getBukaBlokirPermission;
        }
    }

    connectedCallback(){
        // this.hasUnblockPermission = getBukaBlokirPermission;

        this.selectedNomorRekening = this.noRekening;

        this.fetchDataHoldStatus();

    }

    //v2.1 - using async
    @api async fetchDataHoldStatus() {
        try {
            this.isLoading = true;
            console.log('function fetchDataHoldStatus called..');

            // Clear previous result and error states
            this.clearResultAndError();
            
            const requestPayload = { 
                norek: this.selectedNomorRekening, 
                idcs: this.recordId 
            };
            console.log('Request Hold Status payload:', JSON.stringify(requestPayload));

            // const result = await getHoldStatus(requestPayload);

            // unified router decides: mock or real
            const result = await this.invokeHoldStatus(requestPayload);

            console.log('Response result fetchDataHoldStatus received:', result);

            if (result) {
                const responseInquiryHoldStatus = result?.inquiryHoldStatus;
                this.errorMsg = '';
                this.hasError = false;

                if (responseInquiryHoldStatus?.data?.length > 0) {
                    this.data = responseInquiryHoldStatus.data
                        .map(item => ({
                            ...item,
                            holdDate: item.holdDate.replace(/^0/, ''),
                            holdAmt: this.formatNumber(item.holdAmt),
                            formattedHoldDate: this.formatIndonesianDate(item.holdDate.replace(/^0/, '')),
                            formattedExpDate: this.formatIndonesianDate(item.expdate.replace(/^0/, '')),
                            // Convert holdSeq to number for proper numeric sorting
                            sortHoldSeq: parseInt(item.holdSeq, 10)
                        }))
                        .sort((a, b) => {
                            // Sort by holdSeq in descending order (higher = more recent)
                            return b.sortHoldSeq - a.sortHoldSeq;
                        });

                    console.log('Formatted and sorted data:', this.data);
                } else if(responseInquiryHoldStatus?.responseCode !== '00' || !responseInquiryHoldStatus?.responseMessage?.toLowerCase().includes('success') || responseInquiryHoldStatus?.responseMessage?.toLowerCase().includes('fail')) {
                    this.handleSearchError('Terjadi kesalahan dalam mengambil data.');
                } else {
                    this.handleSearchError('Informasi Hold Rekening kosong.');
                }
            } else {
                this.handleSearchError('Data tidak ditemukan');
            }
        } catch (error) {
            console.error('Error during fetchDataHoldStatus:', error.message);
            this.handleSearchError('Data tidak ditemukan');
        } finally {
            this.isLoading = false;
            console.log('Loading state set to false.');
        }
    }

    @api async updateCardHoldDetails() {
        // Only update if the card number is different

        const rekNumberChanged = this.noRekening && this.noRekening !== this.selectedNomorRekening;

        // If noRekening changed or this is after a successful operation
        if (rekNumberChanged) {
            console.log('📍 Grandchild: Account number changed, updating to new value');
            this.selectedNomorRekening = this.noRekening;
            console.log(`📍 Grandchild: Updated selectedNomorRekening to: ${this.selectedNomorRekening}`);
        } else {
            console.log('📍 Grandchild: No account number change detected');
        }
        
        // Always fetch fresh data when called
        try {
            console.log('📍 Grandchild: Starting fetchDataHoldStatus for account:', this.selectedNomorRekening);
            await this.fetchDataHoldStatus(); // Fetch new card details
            console.log('📍 Grandchild: fetchDataHoldStatus completed successfully');
        } catch (error) {
            console.error('🚫 Grandchild: Error in fetchDataHoldStatus:', error);
        }
        
    }

    handleConfirmDeletionModal(event){
        this.showConfirmationModal = true;

        const row = event.target.closest('tr');
        const holdSeq = row ? row.dataset.holdSeq : null;
        
        // Find the holdAmt (Nominal Blokir Saldo)
        const holdAmt = row ? row.cells[1].innerText : null;  // Assuming holdAmt is in the second column

        this.holdSeqToDelete = holdSeq;
        this.selectedHoldAmount = holdAmt;
    }

    handleCancelModal() {
        this.showConfirmationModal = false;
    }

    /** New Function to handle the deletion */ 
    handleDeleteBlokir() {
        if (!this.holdSeqToDelete) {
            console.error('Hold Sequence not found.');
            this.showToastMessage('Error', 'Hold Sequence not found.', 'error');
            return;
        }

        // Disable the modal buttons and show the spinner
        this.isProcessing = true;

        console.log('handleDeleteBlokir called..');
        console.log('Deleting record with holdSeq:', this.holdSeqToDelete, 'and account number:', this.noRekening);

        const reqDeleteBlokirPayload = {
            accountNumber: this.noRekening,
            holdSeq: this.holdSeqToDelete
        };

        const reqRecordId = this.recordId;

        // Create a timeout promise
        const timeoutPromise = new Promise((_, reject) =>
            setTimeout(() => reject(new Error('Request timed out')), this.timeoutDuration)
        );

        // Race the API call against the timeout
        Promise.race([
            getUnHoldStatusCASA({ reqdt: reqDeleteBlokirPayload, idacc: reqRecordId }),
            timeoutPromise
        ])
            .then(result => {
                console.log('Response result handleDeleteBlokir received:', JSON.stringify(result, null, 2));

                // Show success toast message after successful deletion
                this.showToastMessage('Success', `Hold data for ${this.selectedHoldAmount} deleted successfully.`, 'success');

                // Fetch updated hold status after deletion
                this.fetchDataHoldStatus();

                // Close the modal after deletion
                this.handleCancelModal();
            })
            .catch(error => {
                console.error('Error occurred during handleDeleteBlokir:', error);

                // Check if the error is a timeout
                if (error.message === 'Request timed out') {
                    this.showToastMessage('Error', 'The request took too long to complete. Please try again later.', 'error');
                } else {
                    // Show the error message if it was not a timeout
                    const errorMessage = error.body ? error.body.message : 'An unknown error occurred.';
                    this.showToastMessage('Error', `Failed to delete the hold data: ${errorMessage}`, 'error');
                }
            })
            .finally(() => {
                // Stop the spinner and re-enable the buttons after the deletion process is complete
                this.isProcessing = false;
            });
    }
    

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.isLoading = false;
        this.data = [];
        console.log('Error Message:', errorMessage);
    }

    clearResultAndError() {
        this.data = [];
        this.hasError = false;
        this.errorMsg = '';
    }

    /** UTILITIES FUNCTIONS */

    // Format function for Indonesian dates
    formatIndonesianDate(dateStr) {
        // Clean and pad to ensure 6-digit format
        const cleanDateStr = dateStr.replace(/^0/, '').padStart(6, '0');
    
        if (!dateStr || cleanDateStr === '000000') {
            return '-';
        }
    
        const day = cleanDateStr.substring(0, 2);
        const month = cleanDateStr.substring(2, 4);
        const year = cleanDateStr.substring(4, 6);
    
        const dayNum = parseInt(day, 10);
        const monthNum = parseInt(month, 10);
        const yearNum = parseInt(year, 10);
    
        if (dayNum < 1 || dayNum > 31 || monthNum < 1 || monthNum > 12 || yearNum < 0 || yearNum > 99) {
            return '-';
        }
    
        const indonesianMonths = [
            'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
            'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
        ];
        const monthName = indonesianMonths[monthNum - 1];
    
        // Always use current century
        const currentYear = new Date().getFullYear();
        const currentCentury = Math.floor(currentYear / 100) * 100;
        const fullYear = currentCentury + yearNum;
    
        return `${day} ${monthName} ${fullYear}`;
    }
    
    
    

    //if want to use IDR format
    formatCurrency(value) {
        const formatter = new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        });
        return formatter.format(value);
    }

    //for formatting number
    formatNumber(numberString) {
        // Parse the input string to a float
        const parsedNumber = parseFloat(numberString);
        if (isNaN(parsedNumber)) return '0';
    
        // Convert to string with two decimal places
        const fixedNumber = parsedNumber.toFixed(2);
        
        // Split into integer and decimal parts
        const [integerPart, decimalPart] = fixedNumber.split('.');
    
        // Format the integer part with dots as thousands separators
        const formattedIntegerPart = integerPart.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
    
        // If decimal part is zero, return just the integer part
        if (decimalPart === '00') {
            return formattedIntegerPart;
        }
    
        // Return formatted currency string with comma for the decimal part
        return `${formattedIntegerPart},${decimalPart}`;
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