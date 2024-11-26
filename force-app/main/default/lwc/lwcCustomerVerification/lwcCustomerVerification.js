/** 
    LWC Name    : lwcCustomerVerification.js
    Created Date       : 25 August 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   25/08/2024   Rakeyan Nuramria                  Initial Version
    1.1   26/08/2024   Rakeyan Nuramria                  Adjust ..
    1.1   02/10/2024   Rakeyan Nuramria                  [ON GOING] Dev functionality + API
    1.1   03/10/2024   Rakeyan Nuramria                  [DONE] Dev functionality + API
    1.1   04/10/2024   Rakeyan Nuramria                  Adjust logic checkbox
    1.1   29/10/2024   Rakeyan Nuramria                  Adjust request param for cardlink
    1.1   29/10/2024   Rakeyan Nuramria                  [FROM SIT] fix bug & just logic show data for Credit with edge case (on check for edge case)
**/

import { LightningElement, wire, api,track } from 'lwc';
import getPortofolio from '@salesforce/apex/SCC_CaseBRICare.getPortofolio';
import getCardLinkbyCardNumber from '@salesforce/apex/SCC_CaseBRICare.getCardLinkbyCardNumber';
import UpdateVerification from '@salesforce/apex/SCC_CaseBRICare.UpdateVerification';
import getCustomerVerification from '@salesforce/apex/SCC_CaseBRICare.getCustomerVerification';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class LwcCustomerVerification extends LightningElement {

    @api recordId;
    @track isLoading = false;
    @track customerType = 'Individu';
    @track categoryOptions;
    @track cardNumber;
    @track category = "Banking"; // Default to Banking
    @track selectedOption = ''; // This will hold the selected option value
    @track Banking = true; // Default to show the Banking template
    @track Credit = false; // Credit template is hidden by default
    @track errorMsg = '';
    @track hasError = false;

    @track selectedNomorKartu;
    @track selectedNomorRekening;
    @track selectedRekening = '';

    //for portofolio banking
    @track demografiData = {};
    @track simpananData = [];
    @track kreditData = [];
    @track listKartuBanking = [];
    @track listKartuKredit = [];
    @track concatenatedAlamatKantor = '';

    //for portofolio credit
    @track demografiKreditData = {};

    //for detail kartu kredit
    @track cardInfo = {};
    @track detailKreditData = [];
    @track customerData = [];
    @track cardData = [];
    @track additionalData = [];

    //for checkbox & submit
    @track customerVerificationData = {};
    @track isChecked = false;
    @track isSubmitDisabled = true;
    @track isCancelDisabled = true;
    // @track checkboxStates = {
    //     namaLengkap: false,
    //     tglLahir: false,
    //     ibuKandung: false,
    //     noHpBRINets: false,
    //     noHpWBS: false,
    //     trxTerakhir: false,
    //     nik: false,
    //     jenisRekening: false,
    //     kantorPembuka: false,
    //     npwp: false,
    //     expiredKartu: false,
    //     alamatRumah: false,
    //     limitKartu: false,
    //     alamatEmail: false,
    //     kontakDarurat: false


    // };

    @track checkboxStates = this.getDefaultCheckboxStates();

    getDefaultCheckboxStates() {
        return {
            namaLengkap: false,
            tglLahir: false,
            ibuKandung: false,
            noHpBRINets: false,
            noHpWBS: false,
            trxTerakhir: false,
            nik: false,
            jenisRekening: false,
            kantorPembuka: false,
            npwp: false,
            expiredKartu: false,
            alamatRumah: false,
            limitKartu: false,
            alamatEmail: false,
            kontakDarurat: false
        };
    }

    // Dynamic options for the rek/kartu combobox
    // get options() {
    //     if (this.category === 'Banking') {
    //         return this.simpananData.map(account => ({
    //             label: account.accountNumber, // Adjust according to your data structure
    //             value: account.accountNumber
    //         }));
    //     } else if (this.category === 'Credit') {
    //         return this.kreditData.map(card => ({
    //             label: card.cardNumber, // Adjust according to your data structure
    //             value: card.cardNumber
    //         }));
    //     }
    //     return []; // Return an empty array if no category is matched
    // }

    get selectedSimpanan() {
        // Find the simpanan that matches the selected rekening
        return this.simpananData.find(simpan => simpan.accountNumber === this.selectedNomorRekening);
    }

    get isCheckboxDisabled() {
        if (this.Banking) {
            return this.selectedNomorRekening === '';
        } else if (this.Credit) {
            return this.selectedNomorKartu === '';
        }
        return true; // Default to disabled if neither category applies
    }

    get options() {
        if (this.category === 'Banking') {
            const defaultOption = { label: 'Pilih salah satu...', value: '' };
            return [defaultOption, ...this.listKartuBanking.map(account => ({
                label: account.accountNumber,
                value: account.accountNumber
            }))];
        } else if (this.category === 'Credit') {
            const defaultOption = { label: 'Pilih salah satu...', value: '' };
            return [defaultOption, ...this.listKartuKredit.map(card => ({
                label: card.cardNumber,
                value: card.cardNumber
            }))];
        }
        return []; // Return an empty array if no category is matched
    }

    connectedCallback() {
        this.IsLoading = true;
        this.categoryOptions = [
            { label: "Banking", value: "Banking" },
            { label: "Credit", value: "Credit" }
        ];
        this.fetchDataCustomer();
        // this.handleClearBankingResult();
        console.log('zxc init');
    }

    fetchDataCustomer() {
        console.log('zxc Function fetchDataCustomer called...');

        this.isLoading = true;

        const requestPayload = { 
            idcs: this.recordId 
        };

        getPortofolio(requestPayload)
            .then(result => {
                console.log('zxc Response received:', result);
                console.log('zxc Response received:', JSON.stringify(result, null, 2));

                const response = result?.data?.[0]; 
                if (response && response.portofolioPerbankan) {
                    this.demografiData = response.demografi || [];

                     // Concatenate alamatKantor fields
                     const alamatKantor = [
                        this.demografiData.alamatKantor,
                        this.demografiData.alamatKantor2,
                    ].filter(Boolean).join(', ');

                    this.concatenatedAlamatKantor = alamatKantor;

                    this.demografiKreditData = response.demografi || [];
                    this.simpananData = response.portofolioPerbankan.simpanan || [];
                    this.kreditData = response.portofolioPerbankan.cardlink || [];

                    // Map through simpananData to add first four characters of accountNumber
                    this.simpananData = this.simpananData.map(simpan => ({
                        ...simpan,
                        kodeKantorCabang: simpan.accountNumber ? simpan.accountNumber.substring(0, 4) : null
                    }));

                    //for card list
                    this.listKartuBanking = response.portofolioPerbankan.simpanan || [];
                    this.listKartuKredit = response.portofolioPerbankan.cardlink || [];
                    
                    console.log('zxc Demografi Data:', JSON.stringify(this.demografiData, null, 2));
                    console.log('zxc Simpanan Data:', JSON.stringify(this.simpananData, null, 2));
                    console.log('zxc Kredit Data:', JSON.stringify(this.kreditData, null, 2));

                    this.errorMsg = '';
                    this.hasError = false;

                    this.setDefaultSelectedOption();
                    this.fetchDataCustomerVerification();
                } else {
                    console.warn('Portfolio perbankan not found');
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error during search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });
    }

    // fetchDataDetailKredit() {
    //     console.log('zxc Function fetchDataDetailKredit called...');

    //     const requestPayload = { 
    //         CardNumber : this.selectedNomorKartu, //add this if using getCardLinkbyCardNumber
    //         idcs: this.recordId
    //     };

    //     console.log('zxc Request cardlink payload:', JSON.stringify(requestPayload));

    //     getCardLinkbyCardNumber(requestPayload)
    //     .then(result => {
    //         console.log('zxc Response result getCardLink received:', result);
    //         console.log('zxc Response result getCardLink received:', JSON.stringify(result));

    //         // Check if result is defined and has data
    //         if (result && result.response && result.response.data && result.response.data.length > 0) {
    //             const responseData = result.response.data;

    //             // Initialize a temporary array to hold processed entries
    //             this.detailKreditData = responseData.map(item => {
    //                 return {
    //                     customerData: item.customerData || [],
    //                     cardData: item.cardHolderData || [],
    //                     additionalData: item.additionalData || []
    //                 };
    //             });

    //             // Iterate through each entry in the response data
    //             responseData.forEach(item => {
    //                 const responseCustomerData = item.customerData;
    //                 const responseCardData = item.cardHolderData;
    //                 const responseAdditionalData = item.additionalData;

    //                 // Process responseCustomerData data
    //                 if (responseCustomerData && responseCustomerData.length > 0) {
    //                     this.customerData.push(...responseCustomerData.map(customer => ({
    //                         ...customer,
    //                     })));
    //                 } else {
    //                     this.handleSearchError('zxc Data tidak ditemukan for responseCustomerData');
    //                 }

    //                 // Process responseCardData data
    //                 if (responseCardData && responseCardData.length > 0) {

    //                     //for input customerName into cardData
    //                     const customerMap = new Map(
    //                         this.customerData.map(customer => [customer.customerNumber, customer.namaLengkap])
    //                     );

    //                     this.cardData.push(...responseCardData.map(card => ({
    //                         ...card,
    //                         customerName: customerMap.get(card.customerNumber) || 'N/A'
    //                     })));
    //                     console.log('Combined Card Data:', JSON.stringify(this.cardData));
    //                 } else {
    //                     this.handleSearchError('Data tidak ditemukan for responseCardData');
    //                 }

    //                 // Process responseAdditionalData data
    //                 if (responseAdditionalData && responseAdditionalData.length > 0) {
    //                     this.additionalData.push(...responseAdditionalData.map(additional => ({
    //                         ...additional,
    //                     })));
    //                 } else {
    //                     this.handleSearchError('Data tidak ditemukan for responseAdditionalData');
    //                 }
    //             });

    //             // Log the processed data
    //             console.log('zxc Formatted responseCustomerData Data:', JSON.stringify(this.customerData, null, 2));
    //             console.log('zxc Formatted responseCardData Data:', JSON.stringify(this.cardData, null, 2));
    //             console.log('zxc Formatted responseAdditionalData Data:', JSON.stringify(this.additionalData, null, 2));

    //             this.processedData();
    //             this.fetchDataCustomerVerification();


    //             this.errorMsg = '';
    //             this.hasError = false;
    //             this.isLoading = false;
    //         } else {
    //             console.log('zxc Data tidak ditemukan')
    //             // this.handleSearchError('Data tidak ditemukan');
    //         }
    //     })
    //     .catch(error => {
    //         console.error('zxc Error during search:', error.message);
    //         // this.handleSearchError('An error occurred: ' + error.message);
    //     })
    //     .finally(() => {
    //         // this.isLoading = false;
    //         console.log('zxc Loading state set to false.');
    //     });
    // }

    
    fetchDataDetailKredit() {
        console.log('zxc Function fetchDataDetailKredit called...');
    
        this.isLoading = true;

        const requestPayload = { 
            CardNumber: this.selectedNomorKartu,
            idcs: this.recordId
        };

        console.log('zxc Request Payload:', JSON.stringify(requestPayload, null, 2));
    
        getCardLinkbyCardNumber(requestPayload)
        .then(result => {
            console.log('zxc Response result getCardLink received:', result);
    
            // Ensure result has valid data
            if (result && result.response && result.response.data && result.response.data.length > 0) {
                const responseData = result.response.data;
    
                this.detailKreditData = responseData.map(item => ({
                    customerData: item.customerData || [],
                    cardData: item.cardHolderData || [],
                    additionalData: item.additionalData || []
                }));
    
                // Initialize arrays for processing
                this.customerData = [];
                this.cardData = [];
                this.additionalData = [];
    
                responseData.forEach(item => {
                    // Ensure each data property is an array before pushing
                    const responseCustomerData = Array.isArray(item.customerData) ? item.customerData : [];
                    const responseCardData = Array.isArray(item.cardHolderData) ? item.cardHolderData : [];
                    const responseAdditionalData = Array.isArray(item.additionalData) ? item.additionalData : [];
    
                    // Append data safely
                    this.customerData.push(...responseCustomerData.map(customer => ({
                        ...customer
                    })));
    
                    // Prepare a customer map for cardData
                    const customerMap = new Map(
                        this.customerData.map(customer => [customer.customerNumber, customer.namaLengkap])
                    );
    
                    // Append card data safely
                    this.cardData.push(...responseCardData.map(card => ({
                        ...card,
                        customerName: customerMap.get(card.customerNumber) || 'N/A'
                    })));
    
                    // Append additional data safely
                    this.additionalData.push(...responseAdditionalData.map(additional => ({
                        ...additional
                    })));
                });
    
                this.processedData();
                this.fetchDataCustomerVerification();
                this.errorMsg = '';
                this.hasError = false;
                this.isLoading = false;
    
                console.log('zxc Customer Data:', JSON.stringify(this.customerData, null, 2));
                console.log('zxc Card Data:', JSON.stringify(this.cardData, null, 2));
                console.log('zxc Additional Data:', JSON.stringify(this.additionalData, null, 2));
            } else {
                console.log('zxc Data tidak ditemukan');
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('zxc Error during search:', error.message);
            this.handleSearchError('An error occurred: ' + error.message);
        })
        .finally(() => {
            this.isLoading = false;
            console.log('zxc Loading state set to false.');
        });
    }
    
    

    /**
    fetchDataDetailKredit() {
        console.log('zxc Function fetchDataDetailKredit called...');
        const requestPayload = { 
            CardNumber: this.selectedNomorKartu,
            idcs: this.recordId
        };
    
        console.log('Request Payload:', JSON.stringify(requestPayload));
    
        getCardLinkbyCardNumber(requestPayload)
        .then(result => {
            console.log('API Response:', JSON.stringify(result));
    
            // Reset variables to ensure no residual data
            this.customerData = [];
            this.cardData = [];
            this.additionalData = [];
    
            if (result?.response?.data?.length > 0) {
                const responseData = result.response.data;
    
                // Populate data arrays from the response
                this.customerData = responseData.flatMap(item => item.customerData || []);
                this.cardData = responseData.flatMap(item => {
                    const customerMap = new Map(
                        this.customerData.map(customer => [customer.customerNumber, customer.namaLengkap])
                    );
                    return (item.cardHolderData || []).map(card => ({
                        ...card,
                        customerName: customerMap.get(card.customerNumber) || 'N/A'
                    }));
                });
                this.additionalData = responseData.flatMap(item => item.additionalData || []);
    
                console.log('Formatted Customer Data:', JSON.stringify(this.customerData, null, 2));
                console.log('Formatted Card Data:', JSON.stringify(this.cardData, null, 2));
                console.log('Formatted Additional Data:', JSON.stringify(this.additionalData, null, 2));
    
                this.errorMsg = '';
                this.hasError = false;
                this.processedData();
            } else {
                console.log('No data found');
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error during search:', error.message);
            this.handleSearchError('An error occurred: ' + error.message);
        })
        .finally(() => {
            console.log('Completed fetchDataDetailKredit');
        });
    }
    */
    

    /**
    fetchDataDetailKredit() {
        console.log('zxc Function fetchDataDetailKredit called...');
    
        // Resetting state before fetching new data
        this.detailKreditData = [];
        this.customerData = [];
        this.cardData = [];
        this.additionalData = [];
        this.errorMsg = '';
        this.hasError = false;
        this.isLoading = true;
    
        const requestPayload = { 
            CardNumber: this.selectedNomorKartu,
            idcs: this.recordId
        };
    
        getCardLinkbyCardNumber(requestPayload)
        .then(result => {
            console.log('zxc Response result getCardLink received:', result);
    
            // Check if result has valid data
            if (result && result.response && result.response.data && Array.isArray(result.response.data) && result.response.data.length > 0) {
                const responseData = result.response.data;
    
                // Populate detailKreditData safely
                this.detailKreditData = responseData.map(item => ({
                    customerData: Array.isArray(item.customerData) ? item.customerData : [],
                    cardData: Array.isArray(item.cardHolderData) ? item.cardHolderData : [],
                    additionalData: Array.isArray(item.additionalData) ? item.additionalData : []
                }));
    
                responseData.forEach(item => {
                    // Append customer data safely
                    this.customerData.push(...(Array.isArray(item.customerData) ? item.customerData : []).map(customer => ({
                        ...customer
                    })));
    
                    // Prepare a customer map for cardData
                    const customerMap = new Map(
                        this.customerData.map(customer => [customer.customerNumber, customer.namaLengkap])
                    );
    
                    // Append card data safely
                    this.cardData.push(...(Array.isArray(item.cardHolderData) ? item.cardHolderData : []).map(card => ({
                        ...card,
                        customerName: customerMap.get(card.customerNumber) || 'N/A'
                    })));
    
                    // Append additional data safely
                    this.additionalData.push(...(Array.isArray(item.additionalData) ? item.additionalData : []).map(additional => ({
                        ...additional
                    })));
                });
    
                this.processedData();
                this.fetchDataCustomerVerification();
                this.errorMsg = '';
                this.hasError = false;
                this.isLoading = false;
    
                console.log('zxc Customer Data:', JSON.stringify(this.customerData, null, 2));
                console.log('zxc Card Data:', JSON.stringify(this.cardData, null, 2));
                console.log('zxc Additional Data:', JSON.stringify(this.additionalData, null, 2));
            } else {
                console.log('zxc Data tidak ditemukan');
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('zxc Error during search:', error.message);
            this.handleSearchError('An error occurred: ' + error.message);
        })
        .finally(() => {
            this.isLoading = false;
            console.log('zxc Loading state set to false.');
        });
    }
    */    
     
    

    fetchDataCustomerVerification() {
        console.log('zxc fetchDataCustomerVerification called..')
        const norek = this.selectedNomorRekening || this.selectedNomorKartu;
        const idcs = this.recordId;

        console.log('zxc fetchDataCustomerVerification norek : ', norek);
        console.log('zxc fetchDataCustomerVerification idcs : ', idcs);

        if (norek) {
            this.IsLoading = true;
            getCustomerVerification({ norek, idcs })
            .then(result => {
                console.log('getCustomerVerification called..')
                    this.IsLoading = false; 
                    if (result && result.length > 0) {
                        this.customerVerificationData = result[0];
                        this.errorMsg = '';
                        this.hasError = false;
                        console.log('zxcCustomer Verification Data:', JSON.stringify(this.customerVerificationData, null, 2));

                        // Map Apex data to checkbox states
                        this.mapDataToCheckboxStates(this.customerVerificationData);
                        this.updateButtonState();
                    } else {
                        this.handleSearchError('zxc Data tidak ditemukan');
                        this.clearCheckboxStates();
                    }
                })
                .catch(error => {
                    this.IsLoading = false;
                    this.clearCheckboxStates();
                    this.handleSearchError('Error fetching customer verification: ' + error.body.message);
                });
        }
    }

    mapDataToCheckboxStates(data) {
        this.checkboxStates = {
            namaLengkap: data.Nama_Nasabah__c || false,
            tglLahir: data.Tanggal_Lahir__c || false,
            ibuKandung: data.Nama_Ibu_Kandung__c || false,
            noHpBRINets: data.Nomor_HP_BRINets__c || false,
            noHpWBS: data.Nomor_HP_WBS__c || false,
            trxTerakhir: data.Transaksi_Terakhir__c || false,
            nik: data.NIK__c || false,
            jenisRekening: data.Jenis_Rekening__c || false,
            kantorPembuka: data.Kantor_Pembuka_Rekening__c || false,
            npwp: data.NPWP__c || false,
            expiredKartu: data.Expired_Date_Kartu__c || false,
            alamatRumah: data.Alamat_Rumah__c || false,
            limitKartu: data.Limit_Kartu_Kredit__c || false,
            alamatEmail: data.Alamat_Email__c || false,
            kontakDarurat: data.Kontak_Darurat__c || false,
        };

        this.updateButtonState();
        console.log('Checkbox states updated:', JSON.stringify(this.checkboxStates, null, 2));
    }

    /** 
    processedData() {
        if (this.detailKreditData && this.detailKreditData.length > 0) {
            const data = this.detailKreditData[0];
    
            // Assuming customerData is an array with one object
            if (data.customerData && data.customerData.length > 0) {
                this.customerData = data.customerData[0]; // Directly assign the first customer
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
                namaLengkap: `${this.customerData.namaDepan} ${this.customerData.namaBelakang}`,
                tanggalLahir: this.customerData.tanggalLahir || '',
                noHandphone: this.customerData.nomorHandphoneTerdaftar || '',
                noKantor: this.customerData.nomorTelephoneKantor || '',
                noRumah: this.customerData.nomorTelephoneRumah || '',
                noKerabat: this.customerData.nomorTelephoneKerabatTidakSerumah || '',
                namaKerabat: this.customerData.namaKerabatTidakSerumah || '',
                noNIK: this.customerData.nomorNik || '',
                noNPWP: this.customerData.nomorNpwp || '',
                jenisKelamin: this.customerData.jenisKelamin || '',
                jabatanKerja: this.customerData.jabatanKerja || '',
                sisaLimit: this.customerData.sisaLimitNasabah || '',
                limitCicilan: this.customerData.limitCicilanNasabah || '',
                alamatBilling: this.customerData.alamatBilling || '',
                alamatEmail: this.customerData.alamatEmail || '',
                alamatPengirimanKartu: this.customerData.alamatPengirimanKartu || '', // This needs to be set properly
                alamatKantor: `${this.customerData.alamatKantorDepan}, ${this.customerData.alamatKantorTengah}, ${this.customerData.alamatKantorBelakang}`  || '',
                alamatRumah: `${this.customerData.alamatRumahDepan}, ${this.customerData.alamatRumahBelakang}`  || '',
                // From cardData
                limitKartu: this.formatCurrencyIDR(this.cardData.limitKartuKredit)  || this.formatCurrencyIDR(0),
                expiredKartu: this.cardData.expiredKartu  || '',
                tglCetak: this.cardData.tanggalCetakCycle  || '',
                tglJatuhTempo: this.cardData.tanggalJatuhTempo  || '',
                nominalFullPayment: this.cardData.nominalFullPayment  || '',
                nominalMinPayment: this.cardData.nominalMinimumPayment  || '',
                nominalTagihanBerjalan: this.cardData.nominalTagihanBerjalan  || '',
                nominalPembayaranTerakhir: this.cardData.nominalPembayaranTerakhir  || '',
                noKartu: this.cardData.customerNumber  || '',
                namaCetak: this.cardData.namaCetakKartu  || '',
                tglTerkahirMaintenance: this.cardData.tanggalTerakhirMaintenanceKartu  || '',
                noRekening: this.cardData.noRekening  || '',
                // From additionalData
                nominalGaji: this.additionalData.nominalPendapatanPerBulan  || '',
                namaIbuKandung: this.additionalData.namaLengkapIbuKandung  || '',
            };

            console.log('zxc cardInfo : ', JSON.stringify(this.cardInfo, null, 2));
        }
    }
    */


    
    processedData() {
        // Check if detailKreditData exists and contains data
        if (this.detailKreditData && this.detailKreditData.length > 0) {
            const data = this.detailKreditData[0];
    
            // Populate customerData with first object if available, otherwise set to empty object
            this.customerData = (data.customerData && data.customerData.length > 0) ? data.customerData[0] : {};
    
            // Populate cardData with the first object if available, otherwise set to empty object
            this.cardData = (data.cardData && data.cardData.length > 0) ? data.cardData[0] : {};
    
            // Populate additionalData with first object if available, otherwise set to empty object
            this.additionalData = (data.additionalData && data.additionalData.length > 0) ? data.additionalData[0] : {};
    
            // Consolidate data into cardInfo
            this.cardInfo = {
                // From customerData
                namaLengkap: `${this.customerData.namaDepan || ''} ${this.customerData.namaBelakang || ''}`,
                tanggalLahir: this.customerData.tanggalLahir || '',
                noHandphone: this.customerData.nomorHandphoneTerdaftar || '',
                noKantor: this.customerData.nomorTelephoneKantor || '',
                noRumah: this.customerData.nomorTelephoneRumah || '',
                noKerabat: this.customerData.nomorTelephoneKerabatTidakSerumah || '',
                namaKerabat: this.customerData.namaKerabatTidakSerumah || '',
                noNIK: this.customerData.nomorNik || '',
                noNPWP: this.customerData.nomorNpwp || '',
                jenisKelamin: this.customerData.jenisKelamin || '',
                jabatanKerja: this.customerData.jabatanKerja || '',
                sisaLimit: this.customerData.sisaLimitNasabah || '',
                limitCicilan: this.customerData.limitCicilanNasabah || '',
                alamatBilling: this.customerData.alamatBilling || '',
                alamatEmail: this.customerData.alamatEmail || '',
                alamatPengirimanKartu: this.customerData.alamatPengirimanKartu || '',
                alamatKantor: `${this.customerData.alamatKantorDepan || ''}, ${this.customerData.alamatKantorTengah || ''}, ${this.customerData.alamatKantorBelakang || ''}`,
                alamatRumah: `${this.customerData.alamatRumahDepan || ''}, ${this.customerData.alamatRumahBelakang || ''}`,
                
                // From cardData
                limitKartu: this.formatCurrencyIDR(this.cardData.limitKartuKredit) || this.formatCurrencyIDR(0),
                expiredKartu: this.cardData.expiredKartu || '',
                tglCetak: this.cardData.tanggalCetakCycle || '',
                tglJatuhTempo: this.cardData.tanggalJatuhTempo || '',
                nominalFullPayment: this.cardData.nominalFullPayment || '',
                nominalMinPayment: this.cardData.nominalMinimumPayment || '',
                nominalTagihanBerjalan: this.cardData.nominalTagihanBerjalan || '',
                nominalPembayaranTerakhir: this.cardData.nominalPembayaranTerakhir || '',
                noKartu: this.cardData.customerNumber || '',
                namaCetak: this.cardData.namaCetakKartu || '',
                tglTerkahirMaintenance: this.cardData.tanggalTerakhirMaintenanceKartu || '',
                noRekening: this.cardData.noRekening || '',
                
                // From additionalData
                nominalGaji: this.additionalData.nominalPendapatanPerBulan || '',
                namaIbuKandung: this.additionalData.namaLengkapIbuKandung || '',
            };
    
            console.log('zxc cardInfo:', JSON.stringify(this.cardInfo, null, 2));
        } else {
            console.warn('zxc Warning: detailKreditData is empty or undefined.');
        }
    }
    

    

    // setDefaultSelectedOption() {
    //     if (this.category === 'Banking' && this.simpananData.length > 0) {
    //         this.selectedOption = this.simpananData[0].accountNumber; // Set default to first account number
        
    //         this.selectedNomorRekening = this.selectedOption;
    //         console.log("zxc initial selectedNomorRekening : ", this.selectedNomorRekening);
        
    //     }
    //         // } else if (this.category === 'Credit' && this.kreditData.length > 0) {
    //     //     this.selectedOption = this.kreditData[0].cardNumber; // Set default to first card number
    //     // }

    //     // this.selectedOption = '';
    // }

    setDefaultSelectedOption() {
        if (this.category === 'Banking' && this.simpananData.length > 0) {
            // Only set default if no account is currently selected
            if (!this.selectedNomorRekening) {
                this.selectedOption = this.simpananData[0].accountNumber;
                this.selectedNomorRekening = this.selectedOption;
                console.log("Initial selectedNomorRekening: ", this.selectedNomorRekening);
            }
        } else if (this.category === 'Credit') {
            // Set default for Credit category to an empty value
            this.selectedOption = '';
            this.selectedNomorKartu = '';
            console.log("Initial selectedNomorKartu set to empty for Credit category");
        }
    }

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        this.hasError = true;
        console.log('Error Message:', errorMessage);
    }

    // handleChange(event) {
    //     const { name, value } = event.target;

    //     /**
    //     if (name === 'category') {
    //         this.category = value;

    //         // Update visibility based on the selected category
    //         this.Banking = (value === 'Banking');
    //         this.Credit = (value === 'Credit');

    //         // Set default selected option based on the new category
    //         this.setDefaultSelectedOption();
    //     } else {
    //         this.selectedOption = value; // Store the selected option
    //     }
    //      */
        
    //     if (name === 'category') {
    //         this.category = value;
    //         this.Banking = (value === 'Banking');
    //         this.Credit = (value === 'Credit');

    //         this.setDefaultSelectedOption();

    //         // this.selectedOption = '';
    //         // this.handleClearBankingResult();
    //         // this.handleClearKreditResult();
    //     } else {
    //         this.selectedOption = value;

    //         if (this.category === 'Banking') {
    //             this.selectedNomorRekening = value;
    //             console.log('zxc selectedNomorRekening : ', this.selectedNomorRekening);
    //             // if (this.selectedNomorRekening != '') {
    //             //     this.fetchDataCustomer();
    //             // } else {
    //             //     this.handleClearBankingResult();
    //             // }

    //         } else if (this.category === 'Credit') {
    //             this.handleClearKreditResult();
    //             this.selectedNomorKartu = value;
    //             console.log('zxc selectedNomorKartu : ', this.selectedNomorKartu);
    //             if (this.selectedNomorKartu != '') {
    //                 this.fetchDataDetailKredit();
    //             } else {

    //                 this.handleClearKreditResult();
    //             }
    //         }
    //     }
    // }

    /** 
    handleChange(event) {
        const { name, value } = event.target;
    
        if (name === 'category') {
            this.category = value;
            this.Banking = (value === 'Banking');
            this.Credit = (value === 'Credit');
    
            this.setDefaultSelectedOption();
            this.clearCheckboxStates();
    
            // Clear previous selections if needed
            this.selectedNomorRekening = '';
            this.selectedNomorKartu = '';
            this.handleClearBankingResult();
            this.handleClearKreditResult();
            
        } else {
            this.selectedOption = value; // Store the selected option
    
            if (this.category === 'Banking') {
                this.selectedNomorRekening = value;
                console.log('Selected Nomor Rekening: ', this.selectedNomorRekening);
                // Fetch customer verification data if a valid selection is made
                if (this.selectedNomorRekening !== '') {
                    this.fetchDataCustomer();
                    this.fetchDataCustomerVerification(); // Fetch based on banking details
                } else {
                    this.selectedNomorRekening = '';
                    this.handleClearBankingResult();
                    this.clearCheckboxStates();

                }
    
            } else if (this.category === 'Credit') {
                this.selectedNomorKartu = value;
                console.log('Selected Nomor Kartu: ', this.selectedNomorKartu);
                // Fetch customer verification data if a valid selection is made
                if (this.selectedNomorKartu !== '') {
                    this.fetchDataDetailKredit();
                    this.fetchDataCustomerVerification(); // Fetch based on credit details
                } else {
                    this.selectedNomorKartu = '';
                    this.handleClearKreditResult();
                    tthis.clearCheckboxStates();
                }
            }
        }
    }
    */
    
    // DEFAULT USE
    // handleChange(event) {
    //     const { name, value } = event.target;
    
    //     if (name === 'category') {
    //         this.category = value;
    //         this.Banking = (value === 'Banking');
    //         this.Credit = (value === 'Credit');
    
    //         this.setDefaultSelectedOption();
    //         this.clearCheckboxStates();
    
    //         // Clear previous selections if needed
    //         this.concatenatedAlamatKantor = '';
    //         this.selectedNomorRekening = '';
    //         this.selectedNomorKartu = '';
    //         this.handleClearBankingResult();
    //         this.handleClearKreditResult();
    
    //     } else {
    //         this.selectedOption = value; // Store the selected option
    
    //         if (this.category === 'Banking') {
    //             this.selectedNomorRekening = value;
    //             if (value) {
    //                 console.log('Selected Nomor Rekening: ', this.selectedNomorRekening);
    //                 // Fetch data only if the value is not empty
    //                 this.fetchDataCustomer();
    //                 // this.fetchDataCustomerVerification(); 
    //             } else {
    //                 // Handle default value or empty selection case
    //                 this.selectedNomorRekening = '';
    //                 this.concatenatedAlamatKantor = '';
    //                 this.handleClearBankingResult();
    //                 this.clearCheckboxStates();
    //             }
    
    //         } else if (this.category === 'Credit') {
    //             this.selectedNomorKartu = value;
    //             if (value) {
    //                 console.log('Selected Nomor Kartu: ', this.selectedNomorKartu);
    //                 // Fetch data only if the value is not empty
    //                 this.fetchDataDetailKredit();
    //                 // this.fetchDataCustomerVerification(); 
    //             } else {
    //                 // Handle default value or empty selection case
    //                 this.selectedNomorKartu = '';
    //                 this.handleClearKreditResult();
    //                 this.clearCheckboxStates();
    //             }
    //         }
    //     }
    // }

    // NEW 29/10/2024 - ON TESTING
    // handleChange(event) {
    //     const { name, value } = event.target;
    
    //     if (name === 'category') {
    //         this.category = value;
    //         this.Banking = (value === 'Banking');
    //         this.Credit = (value === 'Credit');
    
    //         // Set default selected option only when switching category
    //         this.setDefaultSelectedOption();
    
    //         // Clear selections and reset only if the category changes
    //         this.clearCheckboxStates();
    //         this.concatenatedAlamatKantor = '';
    //         this.selectedNomorRekening = '';
    //         this.selectedNomorKartu = '';
    //         this.handleClearBankingResult();
    //         this.handleClearKreditResult();
    //     } else {
    //         // Handle account number selection
    //         this.selectedOption = value; // Store the selected option
    
    //         if (this.category === 'Banking') {
    //             this.selectedNomorRekening = value;
    //             if (value) {
    //                 console.log('Selected Nomor Rekening: ', this.selectedNomorRekening);
    //                 this.fetchDataCustomer(); // Fetch data for the selected account
    //             } else {
    //                 // Clear fields if no selection
    //                 this.selectedNomorRekening = '';
    //                 this.concatenatedAlamatKantor = '';
    //                 this.handleClearBankingResult();
    //                 this.clearCheckboxStates();
    //             }
    //         } else if (this.category === 'Credit') {
    //             this.selectedNomorKartu = value;
    //             if (value) {
    //                 console.log('Selected Nomor Kartu: ', this.selectedNomorKartu);
    //                 this.fetchDataDetailKredit(); // Fetch data for the selected card
    //             } else {
    //                 this.selectedNomorKartu = '';
    //                 this.handleClearKreditResult();
    //                 this.clearCheckboxStates();
    //             }
    //         }
    //     }
    // }

    /**
    handleChange(event) {
        const { name, value } = event.target;
    
        if (name === 'category') {
            // Update the category and reset selections
            this.category = value;
            this.Banking = (value === 'Banking');
            this.Credit = (value === 'Credit');
    
            // Set default selected option when switching category
            this.setDefaultSelectedOption();
    
            // Clear data based on the new category
            if (this.Banking) {
                this.handleClearKreditResult();
                this.handleClearBankingResult();
            } else if (this.Credit) {
                this.handleClearBankingResult();
                this.handleClearKreditResult();
            }
    
            // Clear checkbox states regardless of category switch
            this.clearCheckboxStates();
    
        } else {
            // Handle account/card selection
            this.selectedOption = value; // Store the selected option
    
            if (this.category === 'Banking') {
                this.selectedNomorRekening = value;
                if (value) {
                    console.log('Selected Nomor Rekening: ', this.selectedNomorRekening);
                    this.fetchDataCustomer();
                } else {
                    // Clear Banking data for empty selection
                    this.handleClearBankingResult();
                    this.clearCheckboxStates();
                }
            } else if (this.category === 'Credit') {
                this.selectedNomorKartu = value;
                if (value) {
                    console.log('Selected Nomor Kartu: ', this.selectedNomorKartu);
                    this.fetchDataDetailKredit();
                } else {
                    // Clear Credit data for empty selection
                    this.handleClearKreditResult();
                    this.clearCheckboxStates();
                }
            }
        }
    }
    */

    handleChange(event) {
        const { name, value } = event.target;
    
        if (name === 'category') {
            // Update the category and reset selections
            this.category = value;
            this.Banking = (value === 'Banking');
            this.Credit = (value === 'Credit');
    
            // Set default selected option when switching category
            this.setDefaultSelectedOption();
    
            // Clear data based on the new category
            if (this.Banking) {
                this.handleClearKreditResult();  // Clear any credit-related data
                this.handleClearBankingResult();  // Clear banking data as needed
            } else if (this.Credit) {
                this.handleClearBankingResult();  // Clear any banking-related data
                this.handleClearKreditResult();    // Clear credit data as needed
            }
    
            // Clear checkbox states regardless of category switch
            this.clearCheckboxStates();
    
        } else {
            // Handle account/card selection
            this.selectedOption = value; // Store the selected option
    
            // Clear any existing results before fetching new data
            this.handleClearKreditResult();
            this.handleClearBankingResult();
    
            if (this.category === 'Banking') {
                this.selectedNomorRekening = value;
                if (value) {
                    console.log('Selected Nomor Rekening: ', this.selectedNomorRekening);
                    this.fetchDataCustomer(); // Fetch customer data for selected account
                } else {
                    // Clear Banking data for empty selection
                    this.clearCheckboxStates();  // Clear checkbox states
                }
            } else if (this.category === 'Credit') {
                this.selectedNomorKartu = value;
                if (value) {
                    console.log('Selected Nomor Kartu: ', this.selectedNomorKartu);
                    this.fetchDataDetailKredit(); // Fetch credit detail data for selected card
                } else {
                    // Clear Credit data for empty selection
                    this.clearCheckboxStates();  // Clear checkbox states
                }
            }
        }
    }
    
    

    handleClearBankingResult(){
        //for portofolio
        this.demografiData = {};
        this.simpananData = [];
        this.kreditData = [];
    }

    handleClearKreditResult(){

        //for detail kartu kredit
        this.cardInfo = {};
        this.detailKreditData = [];
        this.customerData = [];
        this.cardData = [];
        this.additionalData = [];
    }

    clearCheckboxStates() {
        this.checkboxStates = {
            namaLengkap: false,
            tglLahir: false,
            ibuKandung: false,
            noHpBRINets: false,
            noHpWBS: false,
            trxTerakhir: false,
            nik: false,
            jenisRekening: false,
            kantorPembuka: false,
            npwp: false,
            expiredKartu: false,
            alamatRumah: false,
            limitKartu: false,
            alamatEmail: false,
            kontakDarurat: false,
        };
        this.updateButtonState(); // Update button state after clearing
    }

    // handleCheckboxChange(event) {
    //     const checkboxId = event.target.dataset.id; // Get the data-id of the checkbox
    //     const checked = event.target.checked; // Get the checked state

    //     // Update the corresponding checkbox state
    //     this.checkboxStates[checkboxId] = checked;

    //     // Enable or disable buttons based on any checkbox being checked
    //     this.isSubmitDisabled = !(this.checkboxStates.namaLengkap || 
    //         this.checkboxStates.tglLahir || 
    //         this.checkboxStates.ibuKandung ||
    //         this.checkboxStates.noHpBRINets ||
    //         this.checkboxStates.noHpWBS ||
    //         this.checkboxStates.trxTerakhir ||
    //         this.checkboxStates.nik ||
    //         this.checkboxStates.jenisRekening ||
    //         this.checkboxStates.kantorPembuka ||
    //         this.checkboxStates.npwp ||
    //         this.checkboxStates.expiredKartu ||
    //         this.checkboxStates.alamatRumah ||
    //         this.checkboxStates.limitKartu ||
    //         this.checkboxStates.alamatEmail ||
    //         this.checkboxStates.kontakDarurat
    //         );
    //     this.isCancelDisabled = this.isSubmitDisabled;

    //     // Log the checkbox state
    //     console.log(`zxc Checkbox "${checkboxId}" is now ${checked ? 'checked' : 'unchecked'}.`);
    //     // console.log(`zxc Submit button is ${this.isSubmitDisabled ? 'disabled' : 'enabled'}.`);
    //     // console.log(`zxc Cancel button is ${this.isCancelDisabled ? 'disabled' : 'enabled'}.`);
    //     console.log('zxc checkboxStates : ', JSON.stringify(this.checkboxStates, null, 2));
    // }

    updateButtonState() {
        // Enable or disable buttons based on any checkbox being checked
        // this.isSubmitDisabled = !Object.values(this.checkboxStates).some(value => value);
        // this.isCancelDisabled = this.isSubmitDisabled;

        // console.log(`Submit button is ${this.isSubmitDisabled ? 'disabled' : 'enabled'}.`);
        // console.log(`Cancel button is ${this.isCancelDisabled ? 'disabled' : 'enabled'}.`);

        this.isSubmitDisabled = !(this.checkboxStates.namaLengkap || 
            this.checkboxStates.tglLahir || 
            this.checkboxStates.ibuKandung ||
            this.checkboxStates.noHpBRINets ||
            this.checkboxStates.noHpWBS ||
            this.checkboxStates.trxTerakhir ||
            this.checkboxStates.nik ||
            this.checkboxStates.jenisRekening ||
            this.checkboxStates.kantorPembuka ||
            this.checkboxStates.npwp ||
            this.checkboxStates.expiredKartu ||
            this.checkboxStates.alamatRumah ||
            this.checkboxStates.limitKartu ||
            this.checkboxStates.alamatEmail ||
            this.checkboxStates.kontakDarurat
        );
        this.isCancelDisabled = this.isSubmitDisabled;
    }

    handleCheckboxChange(event) {
        const checkboxId = event.target.dataset.id; // Get the data-id of the checkbox
        const checked = event.target.checked; // Get the checked state

        // Update the corresponding checkbox state
        this.checkboxStates[checkboxId] = checked;

        console.log(`Updated checkboxStates: ${JSON.stringify(this.checkboxStates)}`);

        // Update button state
        this.updateButtonState();

        // Log button state
        console.log(`Submit button is ${this.isSubmitDisabled ? 'disabled' : 'enabled'}.`);
        console.log(`Cancel button is ${this.isCancelDisabled ? 'disabled' : 'enabled'}.`);
    }

    handleSubmit() {
        console.log('zxc handleSubmit clicked..');

        const customerVerification = this.wrapperCustomerVerification();
        UpdateVerification({ cv: customerVerification })
            .then(response => {
                console.log('zxc Create/Update successful:', response);
                this.errorMsg = '';
                this.hasError = false;
                this.showToast('Success', 'Verifikasi nasabah berhasil ditambah/diubah', 'success');
            })
            .catch(error => {
                this.showToast('Error', response.Message || 'Unknown error occurred.', 'error');
                // this.handleVerificationError('Error updating customer verification: ' + (error.body.message || error.message));
            });
    }

    handleCancel() {
        // Clear the checkboxes and disable buttons
        // this.checkboxStates = {
        //     namaLengkap: false,
        //     tglLahir: false,
        //     ibuKandung: false,
        //     noHpBRINets: false,
        //     noHpWBS: false,
        //     trxTerakhir: false,
        //     nik: false,
        //     jenisRekening: false,
        //     kantorPembuka: false,
        //     npwp: false,
        //     expiredKartu: false,
        //     alamatRumah: false,
        //     limitKartu: false,
        //     alamatEmail: false,
        //     kontakDarurat: false
        // };

        this.checkboxStates = this.getDefaultCheckboxStates();

        this.isSubmitDisabled = true;
        this.isCancelDisabled = true;

        // // Refresh the UI
        // const checkboxes = this.template.querySelectorAll('lightning-input[type="checkbox"]');
        // checkboxes.forEach(checkbox => {
        //     checkbox.checked = false;
        // });

        // Log the cancellation
        console.log('zxc Cancel button clicked. Resetting the form.');
        console.log('zxc Checkboxes have been unchecked, and buttons have been disabled.');
    }

    formatCurrencyIDR(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
        }).format(amount);
    }


    // Dynamically populate the options for either banking or credit
    // get options() {
    //     if (this.category === 'Banking') {
    //         return this.simpananData.map((simpanan, index) => {
    //             return { label: `${simpanan.accountNumber}`, value: simpanan.accountNumber };
    //         });
    //     } else if (this.category === 'Credit') {
    //         return this.kreditData.map((kredit, index) => {
    //             return { label: `${kredit.cardNumber}`, value: kredit.cardNumber };
    //         });
    //     }
    //     return [];
    // }

    // wrapperCustomerVerification() {
    //     const customerVerification = {
    //         Case__c: this.recordId,
    //         Name: this.selectedNomorRekening || this.selectedNomorKartu || '',
    //         Nama_Nasabah__c: this.checkboxStates.namaLengkap || false,
    //         Tanggal_Lahir__c: this.checkboxStates.tglLahir || false,
    //         Nama_Ibu_Kandung__c: this.checkboxStates.ibuKandung || false,
    //         Nomor_HP_BRINets__c: this.checkboxStates.noHpBRINets || false,
    //         Nomor_HP_WBS__c: this.checkboxStates.noHpWBS || false,
    //         Transaksi_Terakhir__c: this.checkboxStates.trxTerakhir || false,
    //         NIK__c: this.checkboxStates.nik || false,
    //         Jenis_Rekening__c: this.checkboxStates.jenisRekening || false,
    //         Kantor_Pembuka_Rekening__c: this.checkboxStates.kantorPembuka || false,
    //         NPWP__c: this.checkboxStates.npwp || false,
    //         Expired_Date_Kartu__c: this.checkboxStates.expiredKartu || false,
    //         Alamat_Rumah__c: this.checkboxStates.alamatRumah || false,
    //         Limit_Kartu_Kredit__c: this.checkboxStates.limitKartu || false,
    //         Alamat_Email__c: this.checkboxStates.alamatEmail || false,
    //         Kontak_Darurat__c: this.checkboxStates.kontakDarurat || false
    //     };
    
    //     return customerVerification;
    // }

    wrapperCustomerVerification() {
        const isNewRecord = !this.customerVerificationData || 
                        this.customerVerificationData?.Name !== (this.selectedNomorRekening || this.selectedNomorKartu);
        
        const customerVerification = {
            ...(isNewRecord ? {} : { Id: this.customerVerificationData?.Id }),
            Case__c: this.recordId,
            Name: this.selectedNomorRekening || this.selectedNomorKartu,
            Nama_Nasabah__c: this.checkboxStates.namaLengkap ? true : false,
            Tanggal_Lahir__c: this.checkboxStates.tglLahir ? true : false,
            Nama_Ibu_Kandung__c: this.checkboxStates.ibuKandung ? true : false,
            Nomor_HP_BRINets__c: this.checkboxStates.noHpBRINets ? true : false,
            Nomor_HP_WBS__c: this.checkboxStates.noHpWBS ? true : false,
            Transaksi_Terakhir__c: this.checkboxStates.trxTerakhir ? true : false,
            NIK__c: this.checkboxStates.nik ? true : false,
            Jenis_Rekening__c: this.checkboxStates.jenisRekening ? true : false,
            Kantor_Pembuka_Rekening__c: this.checkboxStates.kantorPembuka ? true : false,
            NPWP__c: this.checkboxStates.npwp ? true : false,
            Expired_Date_Kartu__c: this.checkboxStates.expiredKartu ? true : false,
            Alamat_Rumah__c: this.checkboxStates.alamatRumah ? true : false,
            Limit_Kartu_Kredit__c: this.checkboxStates.limitKartu ? true : false,
            Alamat_Email__c: this.checkboxStates.alamatEmail ? true : false,
            Kontak_Darurat__c: this.checkboxStates.kontakDarurat ? true : false,
        };

        return customerVerification;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(evt);
    }

}