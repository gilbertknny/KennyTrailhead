/** 
    LWC Name    : lwcCustomerSearchBankingComponent.js
    Created Date       : 11 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   11/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   24/09/2024   Rakeyan Nuramria                  Adjust API Functionality
    1.0   26/09/2024   Rakeyan Nuramria                  [From SIT] Bug fixing
    1.0   01/10/2024   Rakeyan Nuramria                  Adjust for Blokir Kartu (BL/PL)
    1.0   02/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust data showing & adjust API to show data based on input
    1.0   04/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust data showing & adjust API to show data based on input by Nomor rekening

**/

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCustomer from '@salesforce/apex/SCC_CaseBRICare.getCustomer';


export default class LwcCustomerSearchBankingComponent extends LightningElement {
    @track forBlokir = 'PL';
    @api iscloseHidden = false;
    @api recordId;
    @api caseId;

    @track isLoading = false;
    @track selectedNomorRekening;
    @track selectedNomorKartu;
    @track showMutasiBanking = false;
    @track showDataKartu = false;

    scrollToMutasiBanking = false;
    scrollToDataKartu = false;

    @track showSearchResults = false;
    @track accountNumber= '';
    @track debitNumber= '';
    @track errorMessage;
    @track customerData = [];
    @track data = [];

    @track employeeNumber;
    

    generateDummyData(){
        return [
            { id: 1, nama: 'John Doe', nomorRekening: '12345678901234567890', nomorKartu: '9876543210123456', cif: 'CIF001', produk: 'Savings Product A', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2021-01-01' }
        ]
    }

    
    get isCariButtonDisabled() {
        return !(this.accountNumber || this.debitNumber);
    }

    connectedCallback(){
        // this.data = this.generateDummyData();
        console.log('caseId from parent : ', this.caseId);
    }

    renderedCallback() {
        //for focus to the content
        if (this.scrollToMutasiBanking) {
            this.scrollToComponent('scrollable-banking-container', 'mutasi-banking-component');
            this.scrollToMutasiBanking = false;
        }

        if (this.scrollToDataKartu) {
            this.scrollToComponent('scrollable-data-kartu-container', 'data-kartu-component');
            this.scrollToDataKartu = false;
        }
        //end for focus to the content
    
    }

    handleClearChildBanking(){
        console.log('handleClearChildBanking called..');
        const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }

    handleClearChildDataKartu(){
        console.log('handleClearChildDataKartu called..');
        const childComponent = this.template.querySelector('c-lwc-data-kartu-banking-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }

    handleMutasiAction(event){
        console.log('handleMutasiAction called..');
        this.handleClearChildBanking();

        const nomorRekening = event.currentTarget.dataset.nomorRekening;

        this.selectedNomorRekening = nomorRekening;
        console.log(`Select Nomor Rekening : ${this.selectedNomorRekening}`);

        this.showMutasiBanking = true;
        this.scrollToMutasiBanking = true;

    }

    handleCloseMutasiBanking(event) {
        console.log(event.detail.message);
        this.showMutasiBanking = false;
    }
    handleCloseDataKartu(event) {
        console.log(event.detail.message);
        this.showDataKartu = false;
    }

    handleDataKartuAction(event){
        console.log('handleKartuAction called..');
        this.handleClearChildDataKartu();

        const nomorKartu = event.currentTarget.dataset.nomorKartu;

        // Set the selected nomorKartu
        this.selectedNomorKartu = nomorKartu;
        console.log(`Select Nomor Kartu : ${this.selectedNomorKartu}`);

        this.showDataKartu = true;
        this.scrollToDataKartu = true;

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
        this.customerData = [];
        this.data = [];
        this.errorMessage = '';
        this.hasError = false;
        this.errorMsg = '';
        this.showSearchResults = false;
        this.showMutasiBanking = false;
        this.showDataKartu = false;
    }

    handleClearResult(){
        // this.disableAccountField = false;
        // this.disableDebitField = false;
        this.customerData = [];
        this.data = [];
        this.errorMessage = '';
        this.hasError = false;
        this.errorMsg = '';
        this.showSearchResults = false;
        this.showMutasiBanking = false;
        this.showDataKartu = false;
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

    handleSearch() {
        this.handleClearResult();
        this.isLoading = true;
        // for dumy data
            // this.data = this.generateDummyData();
            // this.showSearchResults = true;
        // end for dummy data

        console.log('Function handleSearch called..');

        // this.isLoading = true;
    
        const requestPayload = {
            acctNo: this.accountNumber,
            cardNo: this.debitNumber,
            idcs: this.caseId
        };
    
        console.log('Request card search Payload:', JSON.stringify(requestPayload));
    
        getCustomer(requestPayload)
            .then(result => {
                console.log('Response portofolio received:', result);

                // if (result && result.length > 0) {
                if (result) {
                    const response = Array.isArray(result) ? result[0] : result;
                    console.log('masuk sini..');
                    console.log('response : ', JSON.stringify(response));
                    console.log('response.data : ', JSON.stringify(response.data));
                    console.log('response.data.portofolioPerbankan : ', JSON.stringify(response.data[0].portofolioPerbankan));

                    if (response.errorCode === '000' && response.responseCode === '00') {
                        
                        this.customerData = Array.isArray(result) ? result : [response];

                        this.errorMsg = '';
                        this.hasError = false;
                    } else {
                        this.handleSearchError(response.responseMessage || 'Data tidak ditemukan');
                    }
                } else { 
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });

    }

    get processedCustomerData() {
        console.log('search processedSimpanan being processed..');
        return this.customerData.map((result, index) => {
            const simpananArray = result?.data?.[0]?.portofolioPerbankan?.simpanan || [];
            const demografiData = result?.data?.[0]?.demografi || {};
    
            // Log the entire result.data for debugging
            console.log('result.data:', JSON.stringify(result.data));
    
            // Process each simpanan
            // const processedSimpanan = simpananArray.map(simpanan => {
            //     // Log the entire simpanan object
            //     console.log('search simpanan:', JSON.stringify(simpanan));
            //     console.log('search simpanan cardList:', JSON.stringify(simpanan.cardList));
    
            //     // const cardList = simpanan.cardlink || []; // Verify if 'cardlink' is correct
            //     // console.log('cardList:', JSON.stringify(cardList));
    
            //     return {
            //         ...simpanan,
            //         cardList: simpanan.cardList, // Include the cardList array from the simpanan
            //         cardNo: simpanan.cardNo || '-', 
            //         cifno: simpanan.cifno || '-',
            //         product: simpanan.product || '-', 
            //         productType: simpanan.productType || '-',
            //         // status: simpanan.status || '-', 
            //         status:  simpanan.status === undefined || simpanan.status === null ? '-' : (simpanan.status === '1' ? 'Aktif' : 'Nonaktif'), 
            //         openAccountDate: simpanan.openAccountDate || '-', 
            //     };
            // });

            const processedSimpanan = simpananArray
            // .filter(simpanan => 
            //     (this.accountNumber && simpanan.acctNo === this.accountNumber) ||
            //     (this.debitNumber && simpanan.cardNo === this.debitNumber)
            // )
            .filter(simpanan => {
                const isAcctNoMatch = this.accountNumber && simpanan.accountNumber === this.accountNumber;
                const isCardNoMatch = this.debitNumber && simpanan.cardNo === this.debitNumber;
        
                // Logging to see which condition is being matched
                console.log(`search Filtering simpanan: ${JSON.stringify(simpanan)}, Account match: ${isAcctNoMatch}, Card match: ${isCardNoMatch}`);
        
                return isAcctNoMatch || isCardNoMatch;
            })
            .map(simpanan => {
                // Log the entire simpanan object
                console.log('search simpanan:', JSON.stringify(simpanan));
                console.log('search simpanan cardList:', JSON.stringify(simpanan.cardList));
                
                return {
                    ...simpanan,
                    cardList: simpanan.cardList, // Include the cardList array from the simpanan
                    cardNo: simpanan.cardNo || '-', 
                    cifno: simpanan.cifno || '-',
                    product: simpanan.product || '-', 
                    productType: simpanan.productType || '-',
                    status: simpanan.status === undefined || simpanan.status === null ? '-' : (simpanan.status === '1' ? 'Aktif' : 'Nonaktif'), 
                    openAccountDate: simpanan.openAccountDate || '-', 
                };
            });
    
            console.log('search simpananArray : ', JSON.stringify(simpananArray));
            console.log('search processedSimpanan : ', JSON.stringify(processedSimpanan));
            console.count('search Processed Simpanan Data Called');
    
            return {
                ...result,
                no: index + 1,
                simpanan: processedSimpanan,
                demografi: {
                    ...demografiData,
                    namaSesuaiIdentitas: demografiData.namaSesuaiIdentitas || demografiData.nama1 + ' ' + demografiData.nama2+ ' ' + demografiData.nama3
                }
            };
        });
    }

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        this.customerData = []
        this.hasError = true;
        this.isLoading = false;
        // this.bankingData = [];
        console.log('Error Message:', errorMessage);
    }

    scrollToComponent(containerClass, componentClass) {
        requestAnimationFrame(() => {
            setTimeout(() => {
                const scrollableContainer = this.template.querySelector(`.${containerClass}`);
                if (scrollableContainer) {
                    const target = scrollableContainer.querySelector(`.${componentClass}`);
                    if (target) {
                        // Scroll target to the center of the container
                        target.scrollIntoView({ behavior: 'smooth', block: 'center', inline: 'nearest' });
                    } else {
                        console.error(`Target component with class ${componentClass} not found`);
                    }
                } else {
                    console.error(`Scrollable container with class ${containerClass} not found`);
                }
            }, 0); // Adjust delay if needed
        });
    }
}