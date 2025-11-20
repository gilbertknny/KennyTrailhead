/** 
 * !! READ NOTE, IMPORTANT !! => If there any changes in here check/must mirror it to the lwcBankingPortofolioComponent too.
 * 
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
    //release 3
    1.2   10/12/2024   Rakeyan Nuramria                  [CANCEL NOT BEING USED BUT CODE STILL EXIST][FROM SIT] UST-042, Add capability Search by Phone Number in Banking Logic
    1.2   19/02/2025   Rakeyan Nuramria                  Add logic for Ibbiz, brimo, and blokir saldo section
    1.0   07/03/2025   Rakeyan Nuramria                  Adjust logic visibility BRIMO based on custom permission (Alternative to wait surrounding(BRI) go live to prod)


**/

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCustomer from '@salesforce/apex/SCC_CaseBRICare.getCustomer';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

//import custom permission
import hasBlokirPermission from '@salesforce/customPermission/Blokir_Saldo';
import hasBrimoPermission from '@salesforce/customPermission/Brimo_Data';


export default class LwcCustomerSearchBankingComponent extends LightningElement {
    @track forBlokir = 'PL';
    @api iscloseHidden = false;
    @api recordId;
    @api caseId;

    @track isLoading = false;

    @track userPhoneNumber;
    @track selectedNomorCif;
    @track selectedNomorRekening;
    @track selectedNomorKartu;
    @track showMutasiBanking = false;
    @track showDataKartu = false;
    @track showDataIbbiz = false;
    @track showBlokirSaldo = false;
    @track showDataBrimo = false;

    scrollToMutasiBanking = false;
    scrollToDataKartu = false;
    scrollToDataIbbiz = false;
    scrollToDataBrimo = false;
    scrollToBlokirSaldo = false;

    @track showSearchResults = false;
    @track accountNumber= '';
    @track debitNumber= '';
    @track errorMessage;
    @track customerData = [];
    @track data = [];

    @track phoneNumber = '';
    phoneNumberError = '';

    @track employeeNumber;

    isFirstRender = true;
    pendingMutasiAction = false;
    pendingBlokirAction = false;

    @track hasBlockPermission = false;
      

    generateDummyData(){
        return [
            { id: 1, nama: 'John Doe', nomorRekening: '12345678901234567890', nomorKartu: '9876543210123456', cif: 'CIF001', produk: 'Savings Product A', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2021-01-01' }
        ]
    }

    
    get isCariButtonDisabled() {
        return !(this.accountNumber || this.debitNumber || this.phoneNumber);
    }

    // Component visibility flags directly tied to permissions
    get showComponentBlokir() { return this.isAdmin || hasBlokirPermission; }
    get showComponentBrimo() { return this.isAdmin || hasBrimoPermission; }
    
    isAdmin = false;

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            const profileName = data.fields.Profile.value.fields.Name.value;
            this.isAdmin = profileName === 'System Administrator';
        } else if (error) {
            console.error('Error loading user profile:', error);
        }
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
        
        if (this.scrollToDataIbbiz) {
            this.scrollToComponent('scrollable-data-ibbiz-container', 'data-ibbiz-component');
            this.scrollToDataIbbiz = false;
        }

        if (this.scrollToBlokirSaldo) {
            this.scrollToComponent('scrollable-blokir-saldo-container', 'blokir-saldo-component');
            this.scrollToBlokirSaldo = false;
        }

        if (this.scrollToDataBrimo) {
            this.scrollToComponent('scrollable-data-brimo-container', 'data-brimo-component');
            this.scrollToDataBrimo = false;
        }
        //end for focus to the content

        if (this.pendingMutasiAction) {
            const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-component');
            if (childComponent) {
                childComponent.noRekening = this.selectedNomorRekening;
                childComponent.updateLatestCardDetails();   
                childComponent.updateGrandchildHoldDetails();
                
                this.pendingMutasiAction = false; // Reset flag
            } else {
                console.error('🚫 Parent: Mutasi Child component not found in renderedCallback!');
            }
        }

        if (this.pendingBlokirAction) {
            const childComponent = this.template.querySelector('c-lwc-blokir-saldo-banking-component');
            if (childComponent) {
                childComponent.noRekening = this.selectedNomorRekening;
                childComponent.updateGrandchildHoldDetails();
                
                this.pendingBlokirAction = false; // Reset flag
            } else {
                console.error('🚫 Parent: Blokir Child component not found in renderedCallback!');
            }
        }
    
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

    handleClearChildDataIbbiz(){
        console.log('handleClearChildDataIbbiz called..');
        const childComponent = this.template.querySelector('c-lwc-data-user-ibbiz-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }
    handleClearChildBlokirSaldo(){
        console.log('handleClearChildBlokirSaldo called..');
        const childComponent = this.template.querySelector('c-lwc-blokir-saldo-banking-component');
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

        const nomorKartu = event.currentTarget.dataset.nomorKartu;
        this.selectedNomorKartu = nomorKartu;

        this.showMutasiBanking = true;
        this.scrollToMutasiBanking = true;
        this.pendingMutasiAction = true; // Set flag for pending action


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

        const childComponent = this.template.querySelector('c-lwc-data-kartu-banking-component');
        if (childComponent) {
            childComponent.noKartu = this.selectedNomorKartu; // Pass the selected card number
            childComponent.updateCardDetails(); // Trigger the fetch based on the new noKartu
        }

    }

    handleDataIbbizAction(event){
        console.log('handleDataIbbizAction called..');
        this.handleClearChildDataIbbiz();

        const nomorRekening = event.currentTarget.dataset.nomorRekening;
        this.selectedNomorRekening = nomorRekening;
        console.log(`Select Nomor Rekening Blokir : ${this.selectedNomorRekening}`);

         // Set the selected nomorKartu
         const nomorKartu = event.currentTarget.dataset.nomorKartu;
         this.selectedNomorKartu = nomorKartu;
         console.log(`Select Nomor Kartu Blokir : ${this.selectedNomorKartu}`);

        this.showDataIbbiz = true;
        this.scrollToDataIbbiz = true;

        const childComponent = this.template.querySelector('c-lwc-data-user-ibbiz-component');
        if (childComponent) {
            childComponent.noRekening = this.selectedNomorRekening; // Pass the selected card number
            childComponent.updateCardDetails(); // Trigger the fetch based on the new noKartu
        }

    }

    handleBlokirSaldoAction(event){
        console.log('handleBlokirSaldoAction called..');
        // this.handleClearChildBlokirSaldo();

        // Set the selected nomorRekening
        const nomorRekening = event.currentTarget.dataset.nomorRekening;
        this.selectedNomorRekening = nomorRekening;
        console.log(`Select Nomor Rekening Blokir : ${this.selectedNomorRekening}`);

         // Set the selected nomorKartu
         const nomorKartu = event.currentTarget.dataset.nomorKartu;
         this.selectedNomorKartu = nomorKartu;
         console.log(`Select Nomor Kartu Blokir : ${this.selectedNomorKartu}`);

        this.showBlokirSaldo = true;
        this.scrollToBlokirSaldo = true;
        this.pendingBlokirAction = true; // Set flag for pending action

        // const childComponent = this.template.querySelector('c-lwc-blokir-saldo-banking-component');
        // if (childComponent) {
        //     childComponent.noRekening = this.selectedNomorRekening; // Pass the selected card number
        //     childComponent.updateHoldCardDetails(); // Trigger the fetch based on the new noKartu
        // }

    }

    handleDataBrimoAction(event){
        console.log('handleDataBrimoAction called..');
        // this.handleClearChildDataBrimo();

        // Set the selected nomorRekening
        const nomorRekening = event.currentTarget.dataset.nomorRekening;
        this.selectedNomorRekening = nomorRekening;
        console.log(`Select Nomor Rekening Brimo : ${this.selectedNomorRekening}`);

        // Set the selected nomorKartu
         const nomorKartu = event.currentTarget.dataset.nomorKartu;
         this.selectedNomorKartu = nomorKartu;
         console.log(`Select Nomor Kartu Brimo : ${this.selectedNomorKartu}`);

        // Set the selected nomorCif
        const nomorCif = event.currentTarget.dataset.nomorCif;
        this.selectedNomorCif = nomorCif;
        console.log(`Select Nomor Kartu Blokir : ${this.selectedNomorCif}`);

        // Set the selected userPhoneNumber
        const userPhoneNumber = event.currentTarget.dataset.userPhoneNumber;
        this.userPhoneNumber = userPhoneNumber;
        console.log(`Select Nomor Kartu Blokir : ${this.userPhoneNumber}`);

        this.showDataBrimo = true;
        this.scrollToDataBrimo = true;

        const childComponent = this.template.querySelector('c-lwc-data-user-brimo-component');
        if (childComponent) {
            childComponent.noRekening = this.selectedNomorRekening; // Pass the selected card number
            childComponent.updateCardDetails(); // Trigger the fetch based on the new noKartu
        }

    }

    handleCloseMutasiBanking(event) {
        console.log(event.detail.message);
        this.showMutasiBanking = false;
    }
    handleCloseDataKartu(event) {
        console.log(event.detail.message);
        this.showDataKartu = false;
    }

    handleCloseDataIbbiz(event) {
        console.log(event.detail.message);
        this.showDataIbbiz = false;
    }
    handleCloseBlokirSaldo(event) {
        console.log(event.detail.message);
        this.showBlokirSaldo = false;
    }

    handleCloseDataBrimo(event) {
        console.log(event.detail.message);
        this.showDataBrimo = false;
    }

    
    toggleFields(inputField) {
        if (inputField === 'account') {
            this.disableDebitField = !!this.accountNumber;
            this.disablePhoneNumberField = !!this.accountNumber;
        } else if (inputField === 'debitNumber') {
            this.disableAccountField = !!this.debitNumber;
            this.disablePhoneNumberField = !!this.debitNumber;
        } else if (inputField === 'phoneNumber') {
            this.disableAccountField = !!this.phoneNumber;
            this.disableDebitField = !!this.phoneNumber;
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
        this.phoneNumber = '';

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
        this.phoneNumber = '';
        this.toggleFields('account');
        if (!this.accountNumber) {
            this.clearInputFields();
        }
    }

    handleDebitNo(event) {
        this.debitNumber = event.target.value;
        this.accountNumber = '';
        this.phoneNumber = '';

        this.toggleFields('debitNumber');
        if (!this.debitNumber) {
            this.clearInputFields();
        }
    }
    handlePhoneNumber(event) {
        this.phoneNumber = event.target.value;
        // console.log('Phone number:', this.phoneNumber);
        this.accountNumber = '';
        this.debitNumber = '';
        this.validatePhoneNumber(this.phoneNumber, 'phoneNumberError');
        this.toggleFields('phoneNumber');
        if (!this.phoneNumber) {
            this.clearInputFields();
        }
    }

    validatePhoneNumber(phoneValue, errorField) {
        // console.log('Validating phone number:', phoneValue);
        
        // Regex that ensures only digits & 10 - 13 length
        // const phoneRegex = /^[0-9]{10,13}$/;
        // if (!phoneRegex.test(phoneValue)) {
        //     this[errorField] = 'Nomor Telepon harus memiliki 10 hingga 13 digit angka.';
        // }

        // Regex that ensures the string does not contain any alphabetic characters
        if (!phoneValue) {
            this[errorField] = ''; // Clear error if the phone number is empty
            return;
        }
    
        // Regex that ensures the string does not contain any alphabetic characters
        const phoneRegex = /[a-zA-Z]/;
    
        if (phoneRegex.test(phoneValue)) {
            this[errorField] = 'Nomor Telepon tidak boleh mengandung huruf.';
        } else {
            this[errorField] = ''; // Clear error if the phone number is valid
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
            notelp : this.phoneNumber,
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