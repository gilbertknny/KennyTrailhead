import { LightningElement, api, track, wire } from 'lwc';
import getCustomerDataByPhone from '@salesforce/apex/SCC_GetCustomerDataByPhone.getCustomerDataByPhone';
import { getRecord } from 'lightning/uiRecordApi';
import getMutasiRekening from '@salesforce/apex/SCC_SavingStatement.getSavingStatement';
import getCardData from '@salesforce/apex/SCC_GetCardDetails.getCardData';
import getHistoryData from '@salesforce/apex/SCC_GetCardDetails.getHistoryData';
import getAddressSuggestions from '@salesforce/apex/SCC_MachineDataByAddress.getAddressSuggestions';
import getInquiryStatus from '@salesforce/apex/SCC_InquiryHoldStatus.getInquiryStatus';
import getCustomerbyAccCard from '@salesforce/apex/SCC_GetCustomerDatabyAccCard.getCustomerDataByAccCard';

export default class RegularBanking extends LightningElement {
    @api recordId;
    @track error;
    @track errormsg;
    @track errormsgPortfolio;
    @track errorMessage;
    @track errorCard;
    @track errorCardPortfolio;
    @track errorAddress;
    @track errorInquiry;
    @track errorInquiryPortfolio;
    @track customerData = [];
    @track customerSearchData = [];
    phoneNumber;
    @track accountNumber= '';
    @track debitNumber= '';
    isCustomerPortfolioExpanded = false;
    @track isRestrictedProfile = false;
    @track showMutasiRekening = false;
    @track showMutasiRekeningPortfolio = false;
    @track startDate;
    @track endDate;
    @track mutasiRekeningData = [];
    @track mutasiRekeningDataPortfolio = [];
    @track selectedAccountNumber;
    @track cardNumber = '';
    @track dataKartuResult = [];
    @track dataKartuResultPortfolio = [];
    @track historyKartu = [];
    @track showDataKartu = false;
    @track showDataKartuPortfolio = false;
    @track address = '';
    @track addressSuggestions = [];
    @track inquiryStatus;
    @track inquiryStatusPortfolio;
    @track showHistoryKartu = false;
    @track showHistoryKartuPortfolio = false;
    @track historyKartuPortfolio = [];
    @track showSearchResults = false;
    @track showCustomerData = false;
    @track showaddressSuggestions = false;
    @track showMutasiRekeningData = false;
    @track showMutasiRekeningDataPortfolio = false;
    @track isFormPortfolioVisible = false;
    @track isFormSearchVisible = false;

    @wire(getRecord, { recordId: '$recordId'})
    caseRecord({ error, data }) {
        if (data) {
            if (this.recordId) {
                this.error = undefined;
                // Fetch customer data if section is expanded and phone number is available
                if (this.isCustomerPortfolioExpanded) {
                    this.fetchCustomerData(this.recordId);
                }
            } else {
                this.error = 'Nomor telepon untuk memanggil API tidak ditemukan';
                this.customerData = [];
            }
        } else if (error) {
            this.error = error.body.message;
            this.customerData = [];
        }
    }

    get isCariButtonDisabled() {
        return !(this.accountNumber || this.debitNumber);
    }

    get isMutasiCariButtonDisabled() {
        return !(this.startDate && this.endDate);
    }

    get isCardCariButtonDisabled() {
        return !this.cardNumber;
    }

    get isAddressCariButtonDisabled() {
        return !this.address;
    }


    handleAccordionSectionToggle(event) {
        this.isCustomerPortfolioExpanded = event.detail.openSections.includes('customerPortfolio');
        if (this.isCustomerPortfolioExpanded) {
            if (this.recordId) {
                this.fetchCustomerData(this.recordId);
            }
        }
    }

    handleAccountName(event) {
        this.accountNumber = event.target.value;
        this.debitNumber = '';
        this.toggleFields('account');
        if (!this.accountNumber) {
            this.clearInputFields();
        }
    }

    handleDebitNo(event) {
        this.debitNumber = event.target.value;
        this.accountNumber = '';
        this.toggleFields('debitNumber');
        if (!this.debitNumber) {
            this.clearInputFields();
        }
    }

    handleMutasiRekening(event) {

        this.startDate = '';
        this.endDate = '';
        this.selectedAccountNumber = '';
        
        
        const newAccountNumber = event.currentTarget.value;
        const sectionName = event.currentTarget.getAttribute('data-section');
        
        if (sectionName === 'customerPortfolio') {
            this.mutasiRekeningDataPortfolio = [];
            this.showMutasiRekeningDataPortfolio = false;
            this.inquiryStatusPortfolio = undefined;
            this.errorInquiryPortfolio = undefined;
            this.showDataKartuPortfolio = false;
            this.dataKartuResultPortfolio = null;
            this.isFormPortfolioVisible = false;
            this.showMutasiRekeningPortfolio = true;
        } else if (sectionName === 'customerSearch') {
            this.mutasiRekeningData = [];
            this.showMutasiRekeningData = false;
            this.inquiryStatus = undefined;
            this.errorInquiry = undefined;
            this.showDataKartu = false;
            this.dataKartuResult = null;
            this.isFormSearchVisible = false;
            this.showMutasiRekening = true;
        }

        this.selectedAccountNumber = newAccountNumber;
    }

    handleDataKartu(event) {
        const sectionName = event.currentTarget.getAttribute('data-section');

        if (sectionName === 'customerPortfolio') {
            this.showDataKartu = false;
            this.isFormPortfolioVisible = false;
            this.showMutasiRekeningPortfolio = false;
            this.mutasiRekeningDataPortfolio = null;
            this.inquiryStatusPortfolio = null;
            this.showDataKartuPortfolio = true;
            this.errorInquiryPortfolio = undefined;
            this.errorInquiry = undefined;
        } else if (sectionName === 'customerSearch') {
            this.showDataKartuPortfolio = false;
            this.isFormPortfolioVisible = false;
            this.showMutasiRekening = false;
            this.mutasiRekeningData = null;
            this.inquiryStatus = null;
            this.showDataKartu = true;
            this.errorInquiryPortfolio = undefined;
            this.errorInquiry = undefined;
        }
        this.cardNumber = ''; 
        this.clearCardData(sectionName); 
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
    }

    handleMutasiRekeningSearch(event) {
        const sectionName = event.target.getAttribute('data-section');
        const startDateString = this.startDate ? this.startDate.toString() : '';
        const endDateString = this.endDate ? this.endDate.toString() : '';
        
        getMutasiRekening({
            accountNumber: this.selectedAccountNumber,
            startDate: startDateString,
            endDate: endDateString
        })
        .then(result => {
            if (sectionName === 'customerPortfolio') {
                this.mutasiRekeningDataPortfolio = result;
                this.showMutasiRekeningDataPortfolio = true;
                this.errormsgPortfolio = undefined; 
            } else if (sectionName === 'customerSearch') {
                this.mutasiRekeningData = result;
                this.showMutasiRekeningData = true;
                this.errormsg = undefined; 
            }
        })
        .catch(error => {
            
            if (sectionName === 'customerPortfolio') {
                this.errormsgPortfolio = 'Data tidak ditemukan.';
                this.mutasiRekeningDataPortfolio = [];
                this.showMutasiRekeningDataPortfolio = false;
            } else if (sectionName === 'customerSearch') {
                this.errormsg = 'Data tidak ditemukan.';
                this.mutasiRekeningData = [];
                this.showMutasiRekeningData = false;
            }
        });
        this.callInquiryStatusApi(sectionName);
    }

    handleCardNumberChange(event) {
        this.cardNumber = event.target.value;

        if (!this.cardNumber) {
            const sectionName = event.currentTarget.getAttribute('data-section');
    
            if (sectionName === 'customerPortfolio') {
                this.dataKartuResultPortfolio = [];
                this.errorCardPortfolio = undefined;
                this.historyKartuPortfolio = []; 
                this.isFormSearchVisible = false;
                this.showHistoryKartuPortfolio = false;
            } else if (sectionName === 'customerSearch') {
                this.dataKartuResult = [];
                this.errorCard = undefined;
                this.historyKartu = []; 
                this.showHistoryKartu = false;
                this.isFormSearchVisible = false;
            }
        }
    }

    handleAddressChange(event) {
        this.address = event.target.value;
        if (!this.address) {
            this.clearAddressResults();
        }
    }

    toggleFields(inputField) {
        if (inputField === 'account') {
            this.disableDebitField = !!this.accountNumber;
        } else if (inputField === 'debitNumber') {
            this.disableAccountField = !!this.debitNumber;
        } 
    }

    clearInputFields() {
        this.accountNumber = '';
        this.debitNumber = '';
        this.disableAccountField = false;
        this.disableDebitField = false;
        this.customerSearchData = [];
        this.errorMessage = '';
    }

    fetchCustomerData(caseId) {
        getCustomerDataByPhone({  
            caseId: caseId
        })
            .then(result => {
                if (result && result.length > 0) {
                    this.customerData = result;
                    this.showCustomerData = true;
                    this.error = undefined;
                } else {
                    this.error = 'Data Customer tidak ditemukan.';
                    this.customerData = [];
                }
            })
            .catch(error => {
                this.error = error.body.message;
                this.customerData = [];
            });
    }

    handleSearch() {
        // Clear any previous error
        this.errormsg = '';
        getCustomerbyAccCard({
            accountNumber: this.accountNumber,
            debitNumber: this.debitNumber
        })
        .then(result => {
            if (result && result.length > 0) {
                this.customerSearchData = result;
                this.showSearchResults = true;
                this.errorMessage = undefined;
            } else {
                this.errorMessage = 'Data Customer tidak ditemukan.';
                this.customerSearchData = [];
            }
        })
        .catch(error => {
            this.errorMessage = error.body.message;
            this.customerSearchData = [];
        });
    }

    handleCardSearch(event) {
        const sectionName = event.currentTarget.getAttribute('data-section');
        getCardData({ cardNumber: this.cardNumber })
            .then(result => {
                if (sectionName === 'customerPortfolio') {
                    if (result) {
                        this.dataKartuResultPortfolio = result;
                        this.isFormPortfolioVisible = true;
                        this.errorCardPortfolio = undefined;
                        this.historyKartuPortfolio = []; 
                        this.showHistoryKartuPortfolio = false;
                    } else {
                        this.dataKartuResultPortfolio = null;
                        this.errorCardPortfolio = 'Data tidak ditemukan.';
                        this.showHistoryKartuPortfolio = false;
                    }
                } else if (sectionName === 'customerSearch') {
                    if (result) {
                        this.dataKartuResult = result;
                        this.isFormSearchVisible = true;
                        this.errorCard = undefined;
                        this.historyKartu = []; // Clear history data
                        this.showHistoryKartu = false;
                    } else {
                        this.dataKartuResult = null;
                        this.errorCard = 'Data tidak ditemukan.';
                        this.showHistoryKartu = false;
                    }
                }
            })
            .catch(error => {
                if (sectionName === 'customerPortfolio') {
                    this.errorCardPortfolio = 'Data tidak ditemukan.';
                    this.dataKartuResultPortfolio = null;
                    this.isFormPortfolioVisible = false;
                } else if (sectionName === 'customerSearch') {
                    this.errorCard = 'Data tidak ditemukan.';
                    this.dataKartuResult = null;
                    this.isFormSearchVisible = false;
                }
            });
    }

    handleAddressSearch() {
        getAddressSuggestions({ address: this.address })
            .then((result) => {
                if (result.length === 0) {
                    // No data received
                    this.errorAddress = 'Data tidak ditemukan.';
                    this.addressSuggestions = [];
                    this.showaddressSuggestions = false;
                } else {
                    // Data received
                    this.addressSuggestions = result.map((record, index) => ({
                        ...record,
                        rowNumber: index + 1
                    }));
                    this.showaddressSuggestions = true;
                    this.errorAddress = undefined;
                }
            })
            .catch((error) => {
                // Error occurred
                this.errorAddress = 'An error occurred while fetching address suggestions';
                this.addressSuggestions = [];
                this.showaddressSuggestions = false;
            });
    }

    callInquiryStatusApi(sectionName) {
        getInquiryStatus({ accountNumber: this.selectedAccountNumber })
            .then((data) => {
                if (data && Object.keys(data).length > 0) { // Check if data is not null and not empty
                    if (sectionName === 'customerPortfolio') {
                        this.inquiryStatusPortfolio = data;
                        this.errorInquiryPortfolio = undefined;
                    } else if (sectionName === 'customerSearch') {
                        this.inquiryStatus = data;
                        this.errorInquiry = undefined;
                    }
                } else {
                    if (sectionName === 'customerPortfolio') {
                        this.inquiryStatusPortfolio = undefined;
                        this.errorInquiryPortfolio = 'Tidak ada data yang tersedia untuk status inquiry';
                    } else if (sectionName === 'customerSearch') {
                        this.inquiryStatus = undefined;
                        this.errorInquiry = 'Tidak ada data yang tersedia untuk status inquiry';
                    }
                }
            })
            .catch((error) => {
                if (sectionName === 'customerPortfolio') {
                    this.errorInquiryPortfolio = error.body.message;
                    this.inquiryStatusPortfolio = undefined;
                } else if (sectionName === 'customerSearch') {
                    this.errorInquiry = error.body.message;
                    this.inquiryStatus = undefined;
                }
            });
    }

    handleHistorySearch(event) {
        const sectionName = event.currentTarget.getAttribute('data-section');
        
        getHistoryData({ cardNumber: this.cardNumber })
            .then(result => {
                if (sectionName === 'customerPortfolio') {
                    this.historyKartuPortfolio = result;
                    this.showHistoryKartuPortfolio = true;
                    this.errorCardPortfolio = undefined;
                } else if (sectionName === 'customerSearch') {
                    this.historyKartu = result;
                    this.showHistoryKartu = true;
                    this.errorCard = undefined;
                }
            })
            .catch(error => {
                if (sectionName === 'customerPortfolio') {
                    this.errorCardPortfolio = error.body.message;
                    this.historyKartuPortfolio = [];
                } else if (sectionName === 'customerSearch') {
                    this.errorCard = error.body.message;
                    this.historyKartu = [];
                }
            });
    }

    clearAddressResults() {
        this.addressSuggestions = [];
        this.showaddressSuggestions = false;
        this.errorAddress = undefined;
    }

    clearCardData(sectionName) {
        if (sectionName === 'customerPortfolio') {
            this.dataKartuResultPortfolio = [];
            this.isFormPortfolioVisible = false;
            this.errorCardPortfolio = undefined;
            this.historyKartuPortfolio = [];
            this.showHistoryKartuPortfolio = false;
            this.errorCardPortfolio = undefined;
        } else if (sectionName === 'customerSearch') {
            this.dataKartuResult = [];
            this.isFormSearchVisible = false;
            this.errorCard = undefined;
            this.historyKartu = [];
            this.showHistoryKartu = false;
            this.errorCard = undefined;
        }
    }
}