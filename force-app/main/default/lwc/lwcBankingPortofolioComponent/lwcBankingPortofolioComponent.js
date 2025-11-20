/** 
 * !! READ NOTE, IMPORTANT !! => If there any changes in here check/must mirror it to the lwcCustomerSearchBankingComponent too.
 * 
    LWC Name    : lwcBankingPortofolioComponent.js
    Created Date       : 10 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   10/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   23/09/2024   Rakeyan Nuramria                  Add API functionality
    1.0   24/09/2024   Rakeyan Nuramria                  Adjust API functionality
    1.0   26/09/2024   Rakeyan Nuramria                  [From SIT] Bug fixing
    1.0   27/09/2024   Rakeyan Nuramria                  [From SIT] Bug fixing for showing status
    1.0   01/10/2024   Rakeyan Nuramria                  Adjust for Blokir Kartu (BL/PL)
    1.0   07/10/2024   Rakeyan Nuramria                  Adjust logic if the button data kartu being clicked when the data kartu is being open(bug because when click again it show undefined/change data)
    1.0   09/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to pass cardNo to mutasi
    release 3
    1.1   10/01/2025   Rakeyan Nuramria                  Add Logic to show UI Data Ibbiz component
    1.1   13/01/2025   Rakeyan Nuramria                  Add Logic to show Blokir saldo component
    1.1   16/01/2025   Rakeyan Nuramria                  Adjust functionality to close Blokir saldo component
    1.1   28/01/2025   Rakeyan Nuramria                  Add Action param to pass data to BRIMO component
    1.1   03/02/2025   Rakeyan Nuramria                  Add param to pass CIF & Phone Number data to BRIMO component
    1.1   14/02/2025   Rakeyan Nuramria                  Add logic to update latest transaction when different noRek being clicked
    1.1   17/02/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic to update hold rekening component when different noRek being clicked in mutasi & blokir saldo
    1.0   18/02/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show blokir saldo based on custom permission
    1.0   07/03/2025   Rakeyan Nuramria                  Adjust logic visibility BRIMO based on custom permission (Alternative to wait surrounding(BRI) go live to prod)
    [POST DEPLOYMENT R3]
    1.1   20/03/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic for fetch data API getCustomer based on the condition.


**/


import { LightningElement, track, api, wire } from 'lwc';
import getPortofolio from '@salesforce/apex/SCC_CaseBRICare.getPortofolio';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

//import custom permission
import hasBlokirPermission from '@salesforce/customPermission/Blokir_Saldo';
import hasBrimoPermission from '@salesforce/customPermission/Brimo_Data';

const CASE_FIELDS = ['Case.AccountId'];
const ACCOUNT_FIELDS = ['Account.SCC_cifno__c'];

export default class LwcBankingPortofolioComponent extends LightningElement {
    @track forBlokir = 'BL';
    @api recordId
    @api caseId
    @api iscloseHidden = false;

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

    isFirstRender = true;
    pendingMutasiAction = false;
    pendingBlokirAction = false;

    @track hasBlockPermission = false;

    @track isLoading = false;
    errorMessage;
    errorMsg;
    hasError;
    

    //USING LDS

    @track bankingData = [];

    generateDummyData(){
        return [
            { id: 1, nama: 'John Doe', nomorRekening: '12345678901234567890', nomorKartu: '9876543210123456', cif: 'CIF001', produk: 'Savings Product A', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2021-01-01' },
            { id: 2, nama: 'Jane Smith', nomorRekening: '23456789012345678901', nomorKartu: '8765432101234567', cif: 'CIF002', produk: 'Current Product B', tipeProduk: 'Business', status: 'Inactive', tglBukaRekening: '2020-05-15' },
            { id: 3, nama: 'Alice Johnson', nomorRekening: '34567890123456789012', nomorKartu: '7654321012345678', cif: 'CIF003', produk: 'Fixed Deposit C', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2019-11-20' },
            { id: 4, nama: 'Bob Brown', nomorRekening: '45678901234567890123', nomorKartu: '6543210123456789', cif: 'CIF004', produk: 'Credit Card D', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2018-09-10' },
            { id: 5, nama: 'Charlie Davis', nomorRekening: '56789012345678901234', nomorKartu: '5432101234567890', cif: 'CIF005', produk: 'Loan Product E', tipeProduk: 'Business', status: 'Inactive', tglBukaRekening: '2017-07-05' },
            { id: 6, nama: 'Diana Evans', nomorRekening: '67890123456789012345', nomorKartu: '4321012345678901', cif: 'CIF006', produk: 'Mortgage Product F', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2016-06-18' },
            { id: 7, nama: 'Eve Foster', nomorRekening: '78901234567890123456', nomorKartu: '3210123456789012', cif: 'CIF007', produk: 'Savings Product G', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2021-11-23' },
            { id: 8, nama: 'Frank Green', nomorRekening: '89012345678901234567', nomorKartu: '2101234567890123', cif: 'CIF008', produk: 'Current Product H', tipeProduk: 'Business', status: 'Inactive', tglBukaRekening: '2020-08-13' },
            { id: 9, nama: 'Grace Hall', nomorRekening: '90123456789012345678', nomorKartu: '1012345678901234', cif: 'CIF009', produk: 'Fixed Deposit I', tipeProduk: 'Individual', status: 'Active', tglBukaRekening: '2019-03-25' },
            { id: 10, nama: 'Henry Irving', nomorRekening: '01234567890123456789', nomorKartu: '0123456789012345', cif: 'CIF010', produk: 'Loan Product J', tipeProduk: 'Business', status: 'Inactive', tglBukaRekening: '2018-10-09' }
        ]
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
    

    // @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    // wiredUser({ error, data }) {
    //     if (data) {
    //         const profileName = data.fields.Profile.value.fields.Name.value;
    //         // Check if user is System Administrator OR has custom permission
    //         this.hasBlockPermission = profileName === 'System Administrator' || getBlokirPermission;
    //     } else if (error) {
    //         console.error('Error loading user profile:', error);
    //         // Fallback to just custom permission check if profile load fails
    //         this.hasBlockPermission = getBlokirPermission;
    //     }
    // }

    // [20/03/2025 - RKYN] Post Deployment r3, add to handle fetch if no Account
    // @wire(getRecord, { recordId: '$caseId', fields: ['Case.AccountId'] })
    // wiredCase({ error, data }) {
    //     if (data) {
    //         const accountId = data.fields.AccountId?.value;
    //         if (accountId) {
    //             // AccountId exists, proceed with API call
    //             this.fetchInformasiPortofolio();
    //             this.errorMsg = undefined;
    //         } else {
    //             // No AccountId found, just return
    //             // this.handleSearchError('Tidak ada Account pada Case Record, pilih terlebih dahulu.');
    //             // this.hasError = true;
    //             this.errorMsg = 'Tidak ada Account pada Case Record, pilih terlebih dahulu.'
    //             console.warn('No AccountId found in the Case record, skipping API call for Customer Portofolio');
    //         }
    //     } else if (error) {
    //         console.error('Error fetching Case record:', error);
    //     }
    // }

    accountId; // To store AccountId from the Case record
    cifNo; // To store SCC_cifno__c from the Account record
    @wire(getRecord, { recordId: '$caseId', fields: CASE_FIELDS })
    wiredCase({ error, data }) {
        if (data) {
            this.accountId = data.fields.AccountId?.value;

            if (this.accountId) {
                // If AccountId exists, the next wire will fetch Account record to validate SCC_cifno__c
                this.errorMsg = undefined; // Clear any previous error message
            } else {
                // If no AccountId found in the Case record, show an error message
                this.errorMsg = 'Tidak ada Account pada Case Record, pilih terlebih dahulu.';
                console.warn('No AccountId found in the Case record. Skipping API call for Customer Portofolio');
            }
        } else if (error) {
            console.error('Error fetching Case record:', error);
            this.errorMsg = 'Terjadi kesalahan saat memuat data Case.';
        }
    }

    // Wire to fetch Account record using AccountId and validate SCC_cifno__c
    @wire(getRecord, { recordId: '$accountId', fields: ACCOUNT_FIELDS })
    wiredAccount({ error, data }) {
        if (data) {
            this.cifNo = data.fields.SCC_cifno__c?.value;

            if (this.cifNo) {
                // If SCC_cifno__c exists, proceed with the fetch function
                this.fetchInformasiPortofolio();
                this.errorMsg = undefined; // Clear any previous error message
            } else {
                // If SCC_cifno__c is missing in the Account, show an error message
                this.errorMsg = 'CIF tidak ditemukan di Account, periksa data Account.';
                console.warn('CIF not found in the Account record. Skipping API call for Customer Portofolio');
            }
        } else if (error) {
            console.error('Error fetching Account record:', error);
            this.errorMsg = 'Terjadi kesalahan saat memuat data Account.';
        }
    }


    connectedCallback(){
        // this.hasBlockPermission = getBlokirPermission;

        // this.BankingData = this.generateDummyData();
        // console.log('recordId : ', this.recordId);
        console.log('caseId from parent : ', this.caseId);
        // console.log('forBlokir from parent : ', this.forBlokir);

        // this.fetchInformasiPortofolio(); //[20/03/2025 - RKYN] Post Deployment r3, commented because move to the wire method
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

    // handleRowAction(event) {
    //     const actionName = event.target.value;
    //     const rowId = event.target.closest('tr').key;
    //     const row = this.data.find(record => record.id === rowId);

    //     console.log(`actionName : ${actionName}`);
    //     console.log(`rowId : ${rowId}`);
    //     console.log(`row : ${row}`);

    //     if (actionName === 'mutasi_rekening') {
    //         console.log('Mutasi Rekening for', row.nama, row.nomorRekening);
    //         this.handleClearChildSimpanan();
    //         this.showMutasiBanking();
    //     } else if (actionName === 'data_kartu') {
    //         console.log('Data Kartu for', row.nama, row.nomorKartu);
    //     }
    // }

    async fetchInformasiPortofolio() {
        console.log('Function fetchInformasiFinansial called..');
        this.isLoading = true;
    
        const requestPayload = {
            idcs: this.caseId
        };
    
        console.log('Request portofolio Payload:', JSON.stringify(requestPayload));
    
        getPortofolio(requestPayload)
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
                        // Always set simpananData to an array
                        this.bankingData = Array.isArray(result) ? result : [response];

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
                // this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });
    }

    // get processedSimpananData() {
    //     return this.bankingData.map((result, index) => {
    //         const simpananArray = result?.data?.[0]?.portofolioPerbankan?.simpanan || [];
    //         const demografiData = result?.data?.[0]?.demografi || {}; // Adjust this line based on your actual data structure
    
    //         // Process each simpanan
    //         const processedSimpanan = simpananArray.map(simpanan => {
    
    //             const cardList = simpanan?.cardlink || []; // Corrected this line
    
    //             console.log('cardList:', JSON.stringify(cardList));

    //             return {
    //                 ...simpanan,
    //                 cardList, // Include the cardList array from the simpanan
    //                 // Add any other processing you need for simpanan here
    //             };
    //         });
    
    //         console.log('simpananArray : ', JSON.stringify(simpananArray));
    //         console.log('processedSimpanan : ', JSON.stringify(processedSimpanan));
    //         console.count('Processed Simpanan Data Called');
    
    //         return {
    //             ...result,
    //             no: index + 1,
    //             simpanan: processedSimpanan, // Include the processed simpanan array
    //             demografi: demografiData // Include the demographic data
    //         };
    //     });
    // }
    
    get processedSimpananData() {
        return this.bankingData.map((result, index) => {
            const simpananArray = result?.data?.[0]?.portofolioPerbankan?.simpanan || [];
            const demografiData = result?.data?.[0]?.demografi || {};
    
            // Log the entire result.data for debugging
            console.log('result.data:', JSON.stringify(result.data));
    
            // Process each simpanan
            const processedSimpanan = simpananArray.map(simpanan => {
                // Log the entire simpanan object
                console.log('simpanan:', JSON.stringify(simpanan));
                console.log('simpanan cardList:', JSON.stringify(simpanan.cardList));
    
                // const cardList = simpanan.cardlink || []; // Verify if 'cardlink' is correct
                // console.log('cardList:', JSON.stringify(cardList));
    
                return {
                    ...simpanan,
                    cardList: simpanan.cardList, // Include the cardList array from the simpanan
                    cardNo: simpanan.cardNo || '-', 
                    cifno: simpanan.cifno || '-',
                    product: simpanan.product || '-', 
                    productType: simpanan.productType || '-',
                    // status: simpanan.status || '-', 
                    status:  simpanan.status === undefined || simpanan.status === null ? '-' : (simpanan.status === '1' ? 'Aktif' : 'Nonaktif'), 
                    openAccountDate: simpanan.openAccountDate || '-', 
                };
            });
    
            console.log('simpananArray : ', JSON.stringify(simpananArray));
            console.log('processedSimpanan : ', JSON.stringify(processedSimpanan));
            console.count('Processed Simpanan Data Called');
    
            return {
                ...result,
                no: index + 1,
                simpanan: processedSimpanan,
                demografi: {
                    ...demografiData,
                    namaSesuaiIdentitas: demografiData.namaSesuaiIdentitas || demografiData.nama1 + ' ' + demografiData.nama2+ ' ' + demografiData.nama3,
                    handphone: demografiData.handphone
                }
            };
        });
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

    //default
    /** 
    handleMutasiAction(event){
        console.log('aq 🎯 Parent: handleMutasiAction started...');
        this.handleClearChildBanking();

        // Set the selected nomorRekening
        const nomorRekening = event.currentTarget.dataset.nomorRekening;
        this.selectedNomorRekening = nomorRekening;
        console.log(`aq 🎯 Parent: Selected Nomor Rekening : ${this.selectedNomorRekening}`);

         // Set the selected nomorKartu
         const nomorKartu = event.currentTarget.dataset.nomorKartu;
         this.selectedNomorKartu = nomorKartu;
         console.log(`aq 🎯 Parent: Selected Nomor Kartu : ${this.selectedNomorKartu}`);

        this.showMutasiBanking = true;
        this.scrollToMutasiBanking = true;

        // const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-component');
        // if (childComponent) {
        //     childComponent.noRekening = this.selectedNomorRekening; // Pass the selected card number
        //     childComponent.updateLatestCardDetails(); // Trigger the fetch based on the new noRekening
        // }

        // Add setTimeout to wait for component to render
        setTimeout(() => {
            const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-component');
            if (childComponent) {
                console.log('🎯 Parent: Child component found');
                childComponent.noRekening = this.selectedNomorRekening;
                console.log('🎯 Parent: noRekening passed to child');
                
                childComponent.updateLatestCardDetails();
                console.log('🎯 Parent: updateLatestCardDetails called on child');
                
                childComponent.updateGrandchildHoldDetails();
                console.log('🎯 Parent: updateGrandchildHoldDetails called on child');
            } else {
                console.error('🚫 Parent: Child component not found!');
            }
        }, 0);
        
    }
    */

    //if using renderedCallback for pass data to child/grandchild component
    handleMutasiAction(event){
        this.handleClearChildBanking();
    
        const nomorRekening = event.currentTarget.dataset.nomorRekening;
        this.selectedNomorRekening = nomorRekening;
    
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

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        // this.bankingData = [];
        console.log('Error Message:', errorMessage);

        this.hasError = true;
        this.isLoading = false;
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