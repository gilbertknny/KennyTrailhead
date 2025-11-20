/** 
    LWC Name    : lwcCreditPortofolioComponent.js
    Created Date       : 11 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   11/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   26/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   27/09/2024   Rakeyan Nuramria                  Add & Use API Portofolio to show portofolio kredit + fetchDataCardlink by Id
    1.0   07/10/2024   Rakeyan Nuramria                  Adjust logic if the button data kartu being clicked when the data kartu is being open(bug because when click again it show undefined/change data)
    1.0   10/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic action mutasi refresh data
    release 3
    [POST DEPLOYMENT R3]
    1.1   21/03/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic for fetch data API getCustomer based on the condition.

**/

import { LightningElement, track, api, wire  } from 'lwc';
import getPortofolio from '@salesforce/apex/SCC_CaseBRICare.getPortofolio';
import getCardLink from '@salesforce/apex/SCC_CaseBRICare.getCardLink';
import getCardLinkbyCardNumber from '@salesforce/apex/SCC_CaseBRICare.getCardLinkbyCardNumber';

import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

const CASE_FIELDS = ['Case.AccountId'];
const ACCOUNT_FIELDS = ['Account.SCC_cifno__c'];

export default class LwcCreditPortofolioComponent extends LightningElement {

    @api caseId;
    @api recordId;
    @api iscloseHidden = false;

    @track selectedNomorRekening;
    @track selectedNomorKartu;
    @track showMutasiKredit = false;
    @track showDataKartu = false;

    scrollToMutasiKredit = false;
    scrollToDataKartu = false;

    @track data = [];
    @track portofolioData = [];
    @track customerData = [];
    @track cardData = [];
    @track additionalData = [];

    errorMsgAcc;

    generateJSONDummyData(requestPayload) {
        return new Promise((resolve) => {
            const dummyData = {
                response: {
                    data: [
                        {
                            customerData: [
                                {
                                    customerNumber: "4336830000006103",
                                    namaDepan: "SHIMON ATMAJAYA HALIM",
                                    namaTengah: "",
                                    namaBelakang: "JL JERUK VI NO 41 RT004 RW010",
                                    namaLengkap: "SHIMON ATMAJAYA HALIM",
                                    nomorHandphoneTerdaftar: "089697206505",
                                    tipeNasabah: "001",
                                    nomorTelephoneKerabatTidakSerumah: "(089)697208371",
                                    nomorTelephoneRumah: "(0896)97206505",
                                    nomorTelephoneKantor: "(089)697206505",
                                    namaKerabatTidakSerumah: "DIANA",
                                    nomorNik: "3515181410850004",
                                    nomorNpwp: "265525857643000",
                                    sisaLimitNasabah: "00049510800",
                                    limitTarikTunaiNasabah: "000600000",
                                    sisaLimitTarikTunaiNasabah: "00060000000",
                                    limitCicilanNasabah: "001000000",
                                    sisaLimitCicilanNasabah: "00083333334",
                                    jenisKelamin: "1",
                                    jabatanKerja: "4",
                                    alamatKantorDepan: "RED JADE",
                                    alamatKantorTengah: "JL JERUK VI NO 41 RT 04 RW 10",
                                    alamatKantorBelakang: "TAMBAK SUMUR WARU",
                                    alamatRumahDepan: "PONDOK CANDRA INDAH",
                                    alamatRumahBelakang: "TAMBAK SUMUR WARU",
                                    alamatEmail: "JAYAHALIM88@GMAIL.COM",
                                    alamatPengirimanKartu: "1",
                                    tanggalLahir: "19851014",
                                    kota1: "SIDOARJO",
                                    kota2: "SIDOARJO",
                                    kodePos: "61256",
                                    kodePosExp: "999936561256",
                                    financialInformation: [
                                        {
                                            tagihanBulanLalu: "00000000000",
                                            totalTagihanBulanIni: "00000000000",
                                            nominalTransaksiTarikTunai: "00000000000",
                                            bungaDitagihkan: "00000000000"
                                        },
                                        {
                                            tagihanBulanLalu: "00000000000",
                                            totalTagihanBulanIni: "00000000000",
                                            nominalTransaksiTarikTunai: "00000000000",
                                            bungaDitagihkan: "00000000000"
                                        },
                                        {
                                            tagihanBulanLalu: "00000000000",
                                            totalTagihanBulanIni: "00000000000",
                                            nominalTransaksiTarikTunai: "00000000000",
                                            bungaDitagihkan: "00000000000"
                                        }
                                    ]
                                }
                            ],
                            cardHolderData: [
                                {
                                    limitKartuKredit: "001000000",
                                    expiredKartu: "0828",
                                    tanggalCetakCycle: "20",
                                    tanggalJatuhTempo: "013",
                                    sisaLimitKartu: "00054510800",
                                    limitTarikTunaiKartu: "0100000",
                                    sisaLimitTarikTunaiKartu: "010000000",
                                    limitCicilanKartu: "001000000",
                                    sisaLimitCicilanKartu: "00083333334",
                                    customerNumber: "4336830000006103",
                                    tanggalTerakhirMaintenanceKartu: "2023241",
                                    namaCetakKartu: "SHIMON ATMAJAYA HAL",
                                    nominalFullPayment: "00000000000",
                                    nominalFullPaymentRtl: "00017148367",
                                    nominalMinimumPayment: "00000857418",
                                    nominalTagihanBerjalan: "00033822534",
                                    nominalPembayaranTerakhir: "029180000",
                                    tanggalPembayaranTerakhir: "2024194",
                                    alasanPemblokiran: "",
                                    fixPayment: "00000000000",
                                    jenisKartu: "408",
                                    namaDataKartuTambahan: "SHIMON ATMAJAYA",
                                    noKartuTambahan: "4336830000006103",
                                    postingFlag: "PP",
                                    tagihanTercetakBulanIni: "2024233"
                                }
                            ],
                            additionalData: [
                                {
                                    namaLengkapIbuKandung: "****",
                                    nominalPendapatanPerBulan: "125472853"
                                }
                            ]
                        }
                    ]
                }
            };
    
            // Resolve with dummy data
            resolve(dummyData);
        });
    }
    
    
    generateDummyData(){
        return [
            { id: 1, nomorKartu: '2453252312123555', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 2, nomorKartu: '2352352324242342', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 3, nomorKartu: '2131252365474888', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 4, nomorKartu: '1232434634732322', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 5, nomorKartu: '8797546424246622', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 6, nomorKartu: '1234658845664332', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 7, nomorKartu: '1135674325786543', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 8, nomorKartu: '1245322456788886', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 9, nomorKartu: '2143545654433333', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
            { id: 10, nomorKartu:'4356668868754435', nama: 'John Doe', cif: 'CIF001', jenisKartu: 'Britama', status: 'Active'},
        ]
    }

    // [21/03/2025 - RKYN] Post Deployment r3, add to handle fetch if no Account
    // @wire(getRecord, { recordId: '$caseId', fields: ['Case.AccountId'] })
    // wiredCase({ error, data }) {
    //     if (data) {
    //         const accountId = data.fields.AccountId?.value;
    //         if (accountId) {
    //             // AccountId exists, proceed with API call
    //             this.fetchKreditPortofolio();
    //             this.errorMsgAcc = undefined;
    //         } else {
    //             // No AccountId found, just return
    //             this.errorMsgAcc = 'Tidak ada Account pada Case Record, pilih terlebih dahulu.'
    //             console.warn('No AccountId found in the Case record, skipping API call for Customer Credit Portofolio');
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
                this.errorMsgAcc = undefined; // Clear any previous error message
            } else {
                // If no AccountId found in the Case record, show an error message
                this.errorMsgAcc = 'Tidak ada Account pada Case Record, pilih terlebih dahulu.';
                console.warn('No AccountId found in the Case record. Skipping API call for Customer Credit Portofolio');
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
                this.fetchKreditPortofolio();
                this.errorMsgAcc = undefined; // Clear any previous error message
            } else {
                // If SCC_cifno__c is missing in the Account, show an error message
                this.errorMsgAcc = 'CIF tidak ditemukan di Account, periksa data Account.';
                console.warn('CIF not found in the Account record. Skipping API call for Customer Credit Portofolio');
            }
        } else if (error) {
            console.error('Error fetching Account record:', error);
            this.errorMsg = 'Terjadi kesalahan saat memuat data Account.';
        }
    }
 
    connectedCallback(){
        // this.data = this.generateDummyData();
        console.log('cardlink caseId from parent : ', this.caseId);
        // this.fetchKreditPortofolio(); //[21/03/2025 - RKYN] Post Deployment r3, commented because move to the wire method
        
        // this.fetchDataCardlink();
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

    fetchKreditPortofolio() {
        console.log('Function fetchInformasiFinansial Kredit called..');
    
        const requestPayload = {
            idcs: this.caseId
        };
    
        console.log('Request portofolio Kredit Payload:', JSON.stringify(requestPayload));
    
        getPortofolio(requestPayload)
            .then(result => {
                console.log('Response portofolio Kredit received:', result);
    
                // if (result && result.length > 0) {
                if (result) {
                    const response = Array.isArray(result) ? result[0] : result;
                   
                    if (response.errorCode === '000' && response.responseCode === '00') {

                        this.portofolioData = Array.isArray(result) ? result : [response];

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

    get processedKreditData() {
        return this.portofolioData.map((result, index) => {
            const kreditArray = result?.data?.[0]?.portofolioPerbankan?.cardlink || [];
            const demografiData = result?.data?.[0]?.demografi || {};
    
            // Log the entire result.data for debugging
            console.log('result.data:', JSON.stringify(result.data));
    
            // Process each simpanan
            const processedKredit = kreditArray.map(kredit => {
                // Log the entire kredit object
                console.log('kredit:', JSON.stringify(kredit));
    
                return {
                    ...kredit,
                    cardNumber: kredit.cardNumber || '-', 
                    cifno: kredit.cifno || '-',
                    product: kredit.product || '-', 
                    // productType: kredit.productType || '-',
                    // status: kredit.status || '-', 
                    status:  kredit.status === undefined || kredit.status === null ? '-' : (kredit.status === '1' ? 'Aktif' : 'Nonaktif'), 
                };
            });
    
            console.log('kreditArray : ', JSON.stringify(kreditArray));
            console.log('processedkredit : ', JSON.stringify(processedKredit));
            console.count('Processed kredit Data Called');
    
            return {
                ...result,
                no: index + 1,
                kredit: processedKredit,
                demografi: {
                    ...demografiData,
                    namaSesuaiIdentitas: demografiData.namaSesuaiIdentitas || demografiData.nama1 + ' ' + demografiData.nama2+ ' ' + demografiData.nama3
                }
            };
        });
    }

    fetchDataCardlink() {
        console.log('function fetchDataCardlink called..');
    
        const requestPayload = {
            cardNumber : this.selectedNomorKartu, //add this if using getCardLinkbyCardNumber
            idcs: this.caseId
        };
    
        console.log('Request cardlink payload:', JSON.stringify(requestPayload));
    
        // Use the mock data generator
        // this.generateJSONDummyData(requestPayload)
        // getCardLink(requestPayload)
        getCardLinkbyCardNumber(requestPayload)
            .then(result => {
                console.log('Response result getCardLink received:', result);
                console.log('Response result getCardLink received:', JSON.stringify(result));
    
                // Check if result is defined and has data
                if (result && result.response && result.response.data && result.response.data.length > 0) {
                    const responseData = result.response.data;

                    // Initialize a temporary array to hold processed entries
                    this.data = responseData.map(item => {
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
                            this.customerData.push(...responseCustomerData.map(customer => ({
                                ...customer,
                            })));
                        } else {
                            this.handleSearchError('Data tidak ditemukan for responseCustomerData');
                        }
    
                        // Process responseCardData data
                        if (responseCardData && responseCardData.length > 0) {

                            //for input customerName into cardData
                            const customerMap = new Map(
                                this.customerData.map(customer => [customer.customerNumber, customer.namaLengkap])
                            );

                            this.cardData.push(...responseCardData.map(card => ({
                                ...card,
                                customerName: customerMap.get(card.customerNumber) || 'N/A'
                            })));
                            console.log('Combined Card Data:', JSON.stringify(this.cardData));
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
                    console.log('Formatted responseCustomerData Data:', JSON.stringify(this.customerData));
                    console.log('Formatted responseCardData Data:', JSON.stringify(this.cardData));
                    console.log('Formatted responseAdditionalData Data:', JSON.stringify(this.additionalData));
    
                    this.errorMsg = '';
                    this.hasError = false;
                    this.isLoading = false;
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('An error occurred: ' + error.message);
            });
    }
    
    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.customerData = [];
        this.cardData = [];
        this.additionalData = [];
        this.isLoading = false;
        console.log('Error Message:', errorMessage);
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

    // handleClearChildDataKartu(){
    //     console.log('handleClearChildDataKartu called..');
    //     const childComponent = this.template.querySelector('c-lwc-data-kartu-kredit-component');
    //     if (childComponent) {
    //         childComponent.handleClear();
    //     }
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

        const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-kredit-component');
        if (childComponent) {
            childComponent.noKartu = this.selectedNomorKartu; // Pass the selected card number
            childComponent.updateMutasiDetails(); // Trigger the fetch based on the new noKartu
        }

    }

    handleDataKartuAction(event){
        console.log('handleKartuAction called..');
        this.handleClearChildDataKartu();

        const nomorKartu = event.currentTarget.dataset.nomorKartu;

        // Set the selected nomorKartu
        this.selectedNomorKartu = nomorKartu;
        console.log(`Select Nomor Kartu : ${this.selectedNomorKartu}`);

        // this.fetchDataCardlink();

        this.showDataKartu = true;
        this.scrollToDataKartu = true;

        const childComponent = this.template.querySelector('c-lwc-data-kartu-kredit-component');
        if (childComponent) {
            childComponent.noKartu = this.selectedNomorKartu; // Pass the selected card number
            childComponent.updateCardDetails(); // Trigger the fetch based on the new noKartu
        }

    }

    handleCloseMutasiKredit(event) {
        console.log(event.detail.message);
        this.showMutasiKredit = false;
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