/** 
    LWC Name    : lwcCustomerSearchKreditComponent.js
    Created Date       : 16 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   12/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   25/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   27/09/2024   Rakeyan Nuramria                  Adjust API Functionality
    1.0   07/10/2024   Rakeyan Nuramria                  [ON GOING] Adjust API Functionality to using getCardLink
    1.0   08/10/2024   Rakeyan Nuramria                  Adjust API Functionality to using getCardLink

**/

import { LightningElement, wire, api, track } from 'lwc';
import getCustomer from '@salesforce/apex/SCC_CaseBRICare.getCustomer';
import getCardLinkbyCardNumber from '@salesforce/apex/SCC_CaseBRICare.getCardLinkbyCardNumber';

export default class LwcCustomerSearchKreditComponent extends LightningElement {

    @api iscloseHidden = false;
    @api caseId;
    @api recordId;

    @track isLoading = false;
    @track noKredit = '';
    @track errorMessage;
    @track showSearchResults = false;
    @track isLoading = false;

    @track selectedNomorRekening;
    @track selectedNomorKartu;
    @track showMutasiKredit = false;
    @track showDataKartu = false;

    scrollToMutasiKredit = false;
    scrollToDataKartu = false;

    @track data =[];
    @track customerData = [];

    //for API Cardlink
    @track dataKredit = [];
    @track portofolioData = [];
    @track customerKreditData = [];
    @track cardData = [];
    @track additionalData = [];
    @track cardInfo = {};

    generateDummyData(){
        return [
            { id: 1, nomorKartu: '2453252312123555', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},]
    }

    connectedCallback(){
        // this.data = this.generateDummyData();
        console.log('cardlink caseId from parent : ', this.caseId);
    }

    renderedCallback() {
        //for focus to the content
        if (this.scrollToMutasiKredit) {
            this.scrollToComponent('scrollable-kredit-container', 'mutasi-kredit-component');
            this.scrollToMutasiKredit = false;
        }

        if (this.scrollToDataKartu) {
            this.scrollToComponent('scrollable-data-kartu-container', 'data-kartu-component');
            this.scrollToDataKartu = false;
        }
        
        //end for focus to the content
    
    }

    get isHandleSearchDisabled() {
        return !(this.noKredit);
    }

    handleKreditChange(event) {
        this.noKredit = event.target.value;
        this.mid = '';
        this.toggleFields('noKredit');
       
        if (!this.noKredit) {
            this.clearInputFields();
            this.handleSearchError();
        }
    }

    // handleSearch() {
    //     //for data from dummy
    //     this.showSearchResults=true;
    //     this.data = this.generateDummyData();
    //     //end for data from dummy
    // }

    handleTransaksiAction(event){
        console.log('handleTransaksiAction called..');
        this.handleClearChildKredit();

        const nomorKartu = event.currentTarget.dataset.nomorKartu;

        // Set the selected nomorKartu
        this.selectedNomorKartu = nomorKartu;
        console.log(`Select Nomor Kartu : ${this.selectedNomorKartu}`);

        this.showMutasiKredit = true;
        this.scrollToMutasiKredit = true;

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

    handleCloseMutasiKredit(event) {
        console.log(event.detail.message);
        this.showMutasiKredit = false;
    }

    handleCloseDataKartu(event) {
        console.log(event.detail.message);
        this.showDataKartu = false;
    }

    handleClearChildKredit(){
        console.log('handleClearChildKredit called..');
        const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-kredit-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }

    handleClearChildDataKartu(){
        console.log('handleClearChildDataKartu called..');
        const childComponent = this.template.querySelector('c-lwc-data-kartu-kredit-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }

    toggleFields(inputField) {
        if (inputField === 'noKredit') {
            this.disableMidField = !!this.noKredit;
        }
    }

    clearSearchResults() {
        this.data = null;
        this.errorMessage = '';
        this.customerData = [];
        this.dataKredit = [];
        this.showSearchResults = false;
        this.error = '';
    }

    clearInputFields() {
        this.data = [];
        this.customerData = [];
        this.dataKredit = [];
        this.noKredit='';
        this.disableKreditField = false;
        this.showSearchResults = false;
        this.errorMessage = '';

        this.portofolioData = [];
        this.customerKreditData = [];
        this.cardData = [];
        this.additionalData = [];
        this.cardInfo = {};
    }

    handleSearch() {
        this.isLoading = true;
        // for dumy data
            // this.data = this.generateDummyData();
            // this.showSearchResults = true;
        // end for dummy data

        console.log('Function handleSearch kredit called..');

        // this.isLoading = true;
    
        const requestPayload = {
            acctNo: "",
            cardNo: this.noKredit,
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

    handleSearchByCardlink(){
        this.isLoading = true;
        console.log('qwe Function fetchDataDetailKredit called...');

        const requestPayload = { 
            CardNumber : this.noKredit, //add this if using getCardLinkbyCardNumber
            idcs: this.recordId
        };

        console.log('qwe Request cardlink payload:', JSON.stringify(requestPayload));

        getCardLinkbyCardNumber(requestPayload)
        .then(result => {
            console.log('qwe Response result getCardLink received:', result);
            console.log('qwe Response result getCardLink received:', JSON.stringify(result));

            // Check if result is defined and has data
            if (result && result.response && result.response.data && result.response.data.length > 0) {
                const responseData = result.response.data;

                // Initialize a temporary array to hold processed entries
                this.dataKredit = responseData.map(item => {
                    return {
                        customerData: item.customerData || [],
                        cardData: item.cardHolderData || [],
                        additionalData: item.additionalData || []
                    };
                });

                // Iterate through each entry in the response data
                responseData.forEach(item => {
                    const responseCustomerData = item.customerData;
                    const responseCardData = item.cardHolderData;
                    const responseAdditionalData = item.additionalData;

                    // Process responseCustomerData data
                    if (responseCustomerData && responseCustomerData.length > 0) {
                        this.customerKreditData.push(...responseCustomerData.map(customer => ({
                            ...customer,
                        })));
                    } else {
                        this.handleSearchError('qwe Data tidak ditemukan for responseCustomerData');
                    }

                    // Process responseCardData data
                    if (responseCardData && responseCardData.length > 0) {

                        //for input customerName into cardData
                        const customerMap = new Map(
                            this.customerKreditData.map(customer => [customer.customerNumber, customer.namaLengkap])
                        );

                        this.cardData.push(...responseCardData.map(card => ({
                            ...card,
                            customerName: customerMap.get(card.customerNumber) || 'N/A'
                        })));
                        console.log('qwe Combined Card Data:', JSON.stringify(this.cardData));
                    } else {
                        this.handleSearchError('Data tidak ditemukan for responseCardData');
                    }

                    // Process responseAdditionalData data
                    if (responseAdditionalData && responseAdditionalData.length > 0) {
                        this.additionalData.push(...responseAdditionalData.map(additional => ({
                            ...additional,
                        })));
                    } else {
                        this.handleSearchError('Data tidak ditemukan for responseAdditionalData');
                    }
                });

                // Log the processed data
                console.log('qwe Formatted responseCustomerData Data:', JSON.stringify(this.customerKreditData, null, 2));
                console.log('qwe Formatted responseCardData Data:', JSON.stringify(this.cardData, null, 2));
                console.log('qwe Formatted responseAdditionalData Data:', JSON.stringify(this.additionalData, null, 2));

                this.processedDataKredit();

                this.errorMsg = '';
                this.hasError = false;
                this.isLoading = false;
            } else {
                console.log('qwe Data tidak ditemukan')
                this.handleSearchError('Data tidak ditemukan');
            }
            
        })
        .catch(error => {
            console.error('qwe Error during search:', error.message);
            // this.handleSearchError('An error occurred: ' + error.message);
        })
        .finally(() => {
            this.isLoading = false;
            console.log('qwe Loading state set to false.');
        });
    }

    processedDataKredit() {
        if (this.dataKredit && this.dataKredit.length > 0) {
            const data = this.dataKredit[0];
    
            // Assuming customerData is an array with one object
            if (data.customerData && data.customerData.length > 0) {
                this.customerKreditData = data.customerData[0]; // Directly assign the first customer
            }
    
            // Filter cardData to find the relevant card based on noKartu
            if (data.cardData && data.cardData.length > 0) {
                // const matchingCard = data.cardData.find(card => card.customerNumber === this.selectedNomorKartu);
                // if (matchingCard) {
                //     this.cardData = matchingCard; // Assign the matched card
                // }

                this.cardData = data.cardData[0]
            }
    
            // Assuming additionalData is an array with one object
            if (data.additionalData && data.additionalData.length > 0) {
                this.additionalData = data.additionalData[0]; // Directly assign the first additional
            }
    
            // Consolidate data into cardInfo
            this.cardInfo = {
                // From customerData
                namaLengkap: `${this.customerKreditData.namaDepan} ${this.customerKreditData.namaBelakang}`,
                tanggalLahir: this.customerKreditData.tanggalLahir || '-',
                noHandphone: this.customerKreditData.nomorHandphoneTerdaftar || '-',
                noKantor: this.customerKreditData.nomorTelephoneKantor || '-',
                noRumah: this.customerKreditData.nomorTelephoneRumah || '-',
                noKerabat: this.customerKreditData.nomorTelephoneKerabatTidakSerumah || '-',
                namaKerabat: this.customerKreditData.namaKerabatTidakSerumah || '-',
                noNIK: this.customerKreditData.nomorNik || '-',
                noNPWP: this.customerKreditData.nomorNpwp || '-',
                jenisKelamin: this.customerKreditData.jenisKelamin || '-',
                jabatanKerja: this.customerKreditData.jabatanKerja || '-',
                sisaLimit: this.customerKreditData.sisaLimitNasabah || '-',
                limitCicilan: this.customerKreditData.limitCicilanNasabah || '-',
                alamatBilling: this.customerKreditData.alamatBilling || '-',
                alamatEmail: this.customerKreditData.alamatEmail || '-',
                alamatPengirimanKartu: this.customerKreditData.alamatPengirimanKartu || '-', // This needs to be set properly
                alamatKantor: `${this.customerKreditData.alamatKantorDepan}, ${this.customerKreditData.alamatKantorTengah}, ${this.customerKreditData.alamatKantorBelakang}`  || '-',
                alamatRumah: `${this.customerKreditData.alamatRumahDepan}, ${this.customerKreditData.alamatRumahBelakang}`  || '-',
                // From cardData
                limitKartu: this.formatCurrencyIDR(this.cardData.limitKartuKredit)  || this.formatCurrencyIDR(0),
                expiredKartu: this.cardData.expiredKartu  || '-',
                customerNumber: this.cardData.customerNumber  || '-',
                tglCetak: this.cardData.tanggalCetakCycle  || '-',
                tglJatuhTempo: this.cardData.tanggalJatuhTempo  || '-',
                nominalFullPayment: this.cardData.nominalFullPayment  || '-',
                nominalMinPayment: this.cardData.nominalMinimumPayment  || '-',
                nominalTagihanBerjalan: this.cardData.nominalTagihanBerjalan  || '-',
                nominalPembayaranTerakhir: this.cardData.nominalPembayaranTerakhir  || '-',
                noKartu: this.cardData.customerNumber  || '-',
                namaCetak: this.cardData.namaCetakKartu  || '-',
                tglTerkahirMaintenance: this.cardData.tanggalTerakhirMaintenanceKartu  || '-',
                noRekening: this.cardData.noRekening  || '-',
                jenisKartu: this.cardData.jenisKartu || '-',
                status: this.cardData.status || '-',
                // From additionalData
                nominalGaji: this.additionalData.nominalPendapatanPerBulan  || '-',
                namaIbuKandung: this.additionalData.namaLengkapIbuKandung  || '-',
            };

            console.log('qwe cardInfo : ', JSON.stringify(this.cardInfo, null, 2));
        }
    }


    // get processedCustomerData() {
    //     console.log('search processedCardlink being processed..');
    //     return this.customerData.map((result, index) => {
    //         const cardlinkArray = result?.data?.[0]?.portofolioPerbankan?.cardlink || [];
    //         const demografiData = result?.data?.[0]?.demografi || {};
    
    //         // Log the entire result.data for debugging
    //         console.log('result.data:', JSON.stringify(result.data));
    
    //         // Process each cardlink
    //         const processedCardlink = cardlinkArray.map(cardlink => {
    //             // Log the entire cardlink object
    //             console.log('search cardlink:', JSON.stringify(cardlink));
    
    //             // console.log('cardList:', JSON.stringify(cardList));
    
    //             return {
    //                 ...cardlink
    //             };
    //         });
    
    //         console.log('search cardlinkArray : ', JSON.stringify(cardlinkArray));
    //         console.log('search processedCardlink : ', JSON.stringify(processedCardlink));
    //         console.count('search Processed Cardlink Data Called');
    
    //         return {
    //             ...result,
    //             no: index + 1,
    //             cardlink: processedCardlink,
    //             demografi: demografiData
    //         };
    //     });
    // }

    get processedCustomerData() {
        console.log('Processing processedCustomerData...');
        return this.customerData.map((result, index) => {
            const portofolio = result?.data?.[0]?.portofolioPerbankan;
            const demografiData = result?.data?.[0]?.demografi || {};
            
            const cardlinkArray = portofolio?.cardlink || [];
            const hasCardlink = cardlinkArray.length > 0;
    
            // Log the structure for debugging
            console.log('result.data:', JSON.stringify(result.data));
            
            const processedCardlink = cardlinkArray.map(cardlink => {
                console.log('Processing cardlink:', JSON.stringify(cardlink));
                return { 
                    ...cardlink,
                    status:  cardlink.status === undefined || cardlink.status === null ? '-' : (cardlink.status === '1' ? 'Aktif' : 'Nonaktif')
                };
            });
    
            return {
                ...result,
                no: index + 1,
                cardlink: processedCardlink,
                demografi: demografiData,
                hasCardlink: hasCardlink // New property to check for cardlinks
            };
        });
    }
    
    formatCurrencyIDR(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
        }).format(amount);
    }

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        this.customerData = []
        this.data = []
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