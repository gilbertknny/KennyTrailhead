/** 
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

**/


import { LightningElement, track, api,  } from 'lwc';
import getPortofolio from '@salesforce/apex/SCC_CaseBRICare.getPortofolio';

export default class LwcBankingPortofolioComponent extends LightningElement {
    @track forBlokir = 'BL';
    @api recordId
    @api caseId
    @api iscloseHidden = false;

    @track selectedNomorRekening;
    @track selectedNomorKartu;
    @track showMutasiBanking = false;
    @track showDataKartu = false;

    scrollToMutasiBanking = false;
    scrollToDataKartu = false;
    

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

    connectedCallback(){
        // this.BankingData = this.generateDummyData();
        // console.log('recordId : ', this.recordId);
        console.log('caseId from parent : ', this.caseId);
        // console.log('forBlokir from parent : ', this.forBlokir);
        this.fetchInformasiPortofolio();
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
            // .finally(() => {
            //     this.isLoadingBanking = false;
            //     console.log('Loading state set to false.');
            // });
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
                    namaSesuaiIdentitas: demografiData.namaSesuaiIdentitas || demografiData.nama1 + ' ' + demografiData.nama2+ ' ' + demografiData.nama3
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

    handleMutasiAction(event){
        console.log('handleMutasiAction called..');
        this.handleClearChildBanking();

        // Set the selected nomorRekening
        const nomorRekening = event.currentTarget.dataset.nomorRekening;
        this.selectedNomorRekening = nomorRekening;
        console.log(`Select Nomor Rekening : ${this.selectedNomorRekening}`);

         // Set the selected nomorKartu
         const nomorKartu = event.currentTarget.dataset.nomorKartu;
         this.selectedNomorKartu = nomorKartu;
         console.log(`Select Nomor Kartu : ${this.selectedNomorKartu}`);

        this.showMutasiBanking = true;
        this.scrollToMutasiBanking = true;

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

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        // this.bankingData = [];
        console.log('Error Message:', errorMessage);
    }

    handleCloseMutasiBanking(event) {
        console.log(event.detail.message);
        this.showMutasiBanking = false;
    }
    handleCloseDataKartu(event) {
        console.log(event.detail.message);
        this.showDataKartu = false;
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
















    // columns = [
    //     { label: 'Name', fieldName: 'name', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'Nomor Rekening', fieldName: 'nomorRekening', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'Nomor Kartu', fieldName: 'nomorKartu', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'CIF', fieldName: 'cif', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'Produk', fieldName: 'produk', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'Tipe Produk', fieldName: 'tipeProduk', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'Status', fieldName: 'status', type: 'text', cellAttributes: { class: 'truncate-cell center-text' } },
    //     { label: 'Tanggal Buka Rekening', fieldName: 'tanggalBuka', type: 'date', cellAttributes: { class: 'center-text' } },
    //     {
    //         type: 'action',
    //         typeAttributes: {
    //             rowActions: [
    //                 { label: 'Mutasi Rekening', name: 'mutasi_rekening' },
    //                 { label: 'Data Kartu', name: 'data_kartu' }
    //             ]
    //         }
    //     }
    // ];

    // data = [
    //     { id: '1', name: 'John Doe', nomorRekening: '12345678901234567890', nomorKartu: '9876543210123456', cif: 'CIF001', produk: 'Savings Product A', tipeProduk: 'Individual', status: 'Active', tanggalBuka: '2021-01-01' },
    //     { id: '2', name: 'Jane Smith', nomorRekening: '23456789012345678901', nomorKartu: '8765432101234567', cif: 'CIF002', produk: 'Current Product B', tipeProduk: 'Business', status: 'Inactive', tanggalBuka: '2020-05-15' },
    //     { id: '3', name: 'Alice Johnson', nomorRekening: '34567890123456789012', nomorKartu: '7654321012345678', cif: 'CIF003', produk: 'Fixed Deposit C', tipeProduk: 'Individual', status: 'Active', tanggalBuka: '2019-11-20' },
    //     { id: '4', name: 'Bob Brown', nomorRekening: '45678901234567890123', nomorKartu: '6543210123456789', cif: 'CIF004', produk: 'Credit Card D', tipeProduk: 'Individual', status: 'Active', tanggalBuka: '2018-09-10' },
    //     { id: '5', name: 'Charlie Davis', nomorRekening: '56789012345678901234', nomorKartu: '5432101234567890', cif: 'CIF005', produk: 'Loan Product E', tipeProduk: 'Business', status: 'Inactive', tanggalBuka: '2017-07-05' },
    //     { id: '6', name: 'Diana Evans', nomorRekening: '67890123456789012345', nomorKartu: '4321012345678901', cif: 'CIF006', produk: 'Mortgage Product F', tipeProduk: 'Individual', status: 'Active', tanggalBuka: '2016-06-18' },
    //     { id: '7', name: 'Eve Foster', nomorRekening: '78901234567890123456', nomorKartu: '3210123456789012', cif: 'CIF007', produk: 'Savings Product G', tipeProduk: 'Individual', status: 'Active', tanggalBuka: '2021-11-23' },
    //     { id: '8', name: 'Frank Green', nomorRekening: '89012345678901234567', nomorKartu: '2101234567890123', cif: 'CIF008', produk: 'Current Product H', tipeProduk: 'Business', status: 'Inactive', tanggalBuka: '2020-08-13' },
    //     { id: '9', name: 'Grace Hall', nomorRekening: '90123456789012345678', nomorKartu: '1012345678901234', cif: 'CIF009', produk: 'Fixed Deposit I', tipeProduk: 'Individual', status: 'Active', tanggalBuka: '2019-03-25' },
    //     { id: '10', name: 'Henry Irving', nomorRekening: '01234567890123456789', nomorKartu: '0123456789012345', cif: 'CIF010', produk: 'Loan Product J', tipeProduk: 'Business', status: 'Inactive', tanggalBuka: '2018-10-09' }
    // ];

    // handleRowAction(event) {
    //     const actionName = event.detail.action.name;
    //     const row = event.detail.row;
    //     if (actionName === 'mutasi_rekening') {
    //         this.handleMutasiRekening(row);
    //     } else if (actionName === 'data_kartu') {
    //         this.handleDataKartu(row);
    //     }
    // }

    // handleMutasiRekening(row) {
    //     console.log('Mutasi Rekening for', row.name, row.nomorRekening);
    // }

    // handleDataKartu(row) {
    //     console.log('Data Kartu for', row.name, row.nomorKartu);
    // }