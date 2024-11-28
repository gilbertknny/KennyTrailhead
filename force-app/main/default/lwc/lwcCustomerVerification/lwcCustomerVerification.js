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
    1.1   30/10/2024   Rakeyan Nuramria                  [FROM SIT - ON GOING] Add logic based on Case Status for showing the data & disabled checkbox
    1.1   08/11/2024   Rakeyan Nuramria                  Cleansing code + Adjust logic for show data based on the new category (Banking/Credit => Non/Individual)
**/

import { LightningElement, wire, api,track } from 'lwc';
import getPortofolio from '@salesforce/apex/SCC_CaseBRICare.getPortofolio';
import getCardLinkbyCardNumber from '@salesforce/apex/SCC_CaseBRICare.getCardLinkbyCardNumber';
import UpdateVerification from '@salesforce/apex/SCC_CaseBRICare.UpdateVerification';
import getCustomerVerification from '@salesforce/apex/SCC_CaseBRICare.getCustomerVerification';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//for Case object
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Case.Status';


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

    @track checkboxStates = this.getDefaultCheckboxStates();

    @track isDataVisible = true; // New property to control data visibility

    @track isInputHidden = false; // property to control extra text input

    //for show data by category
    @track isBankingIndividual = false;
    @track isBankingNonIndividual = false;
    @track isKreditIndividual = false;
    @track isKreditNonIndividual = false;

    // Wire the Case record to get its status
    @wire(getRecord, { recordId: '$recordId', fields: [STATUS_FIELD] })
    caseRecord;

    // Get the current case status
    get caseStatus() {
        return this.caseRecord.data ? getFieldValue(this.caseRecord.data, STATUS_FIELD) : null;
    }

    // Check if the component should be disabled
    get isComponentDisabled() {
        const disabledStatuses = ['Waiting Document', 'Escalated', 'Closed'];
        return disabledStatuses.includes(this.caseStatus);
    }

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
            kontakDarurat: false,

            //added in 09-11-2024
            tglBerdiri: false,
            namaPIC1: false,
            namaPIC2: false,
            namaPIC3: false,
            jabatanPIC1: false,
            jabatanPIC2: false,
            jabatanPIC3: false,
            alamatKantor: false,
            noKantor: false
        };
    }

    get selectedSimpanan() {
        // Find the simpanan that matches the selected rekening
        return this.simpananData.find(simpan => simpan.accountNumber === this.selectedNomorRekening);
    }

    get isCheckboxDisabled() {

        if (this.isComponentDisabled) {
            return true;
        }

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
        
        // this.fetchListCardCustomer();
        this.fetchDataCustomer();
        // this.handleClearBankingResult();
        console.log('zxc init');
    }

    fetchListCardCustomer() {

        this.isLoading = true;

        console.log('zxc Function fetchListCardCustomer called...');

        this.isLoading = true;

        const requestPayload = { 
            idcs: this.recordId 
        };

        getPortofolio(requestPayload)
            .then(result => {
                console.log('zxc Response fetchListCardCustomer received:', result);
                console.log('zxc Response fetchListCardCustomer received:', JSON.stringify(result, null, 2));

                const response = result?.data?.[0]; 
                if (response && response.portofolioPerbankan) {
                    
                    //for card list
                    this.listKartuBanking = response.portofolioPerbankan.simpanan || [];
                    this.listKartuKredit = response.portofolioPerbankan.cardlink || [];

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

                    //logic to show data based on Customer Type
                    const customerType = this.demografiData.tipeNasabahDesc;
                    if (customerType && (customerType.toLowerCase().includes("non") || customerType.toLowerCase().includes("corp"))) {
                        // If the customer type includes "non" or "corp", it's a non-individual banking type
                        this.isBankingNonIndividual = true;
                        this.isBankingIndividual = false;
                    } else {
                        // Otherwise, it's an individual banking type
                        this.isBankingNonIndividual = false;
                        this.isBankingIndividual = true;
                    }
                    //End logic to show data based on Customer Type

                    this.setDefaultSelectedOption();
                    this.fetchDataCustomerVerification();

                    if (!this.validateCaseStatusState()) {
                        return;
                    }

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

                // logic to show data based on Customer Type
                    let isFound = false;
                    this.cardData.forEach(card => {
                        const customerType = card.customerNumber;  // Access the customerNumber for each card
                        console.log('poi customerType ', customerType);

                        if (customerType && customerType.substring(0, 4) === '5534') {
                            this.isKreditNonIndividual = true;
                            this.isKreditIndividual = false;
                            isFound = true;
                        }
                    });

                    if (!isFound) {
                        this.isKreditIndividual = true;
                        this.isKreditNonIndividual = false;
                    }

                    console.log('poi isKreditNonIndividual ', this.isKreditNonIndividual);
                    console.log('poi isKreditIndividual ', this.isKreditIndividual);
                // End logic to show data based on Customer Type
    
                this.processedData();
                this.fetchDataCustomerVerification();

                if (!this.validateCaseStatusState()) {
                    return;
                }

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

            //newly added 09-11-2024
            tglBerdiri: data.Tanggal_Berdiri__c || false,
            namaPIC1: data.Nama_PIC_1__c || false,
            namaPIC2: data.Nama_PIC_2__c || false,
            namaPIC3: data.Nama_PIC_3__c || false,
            jabatanPIC1: data.Jabatan_PIC_1__c || false,
            jabatanPIC2: data.Jabatan_PIC_2__c || false,
            jabatanPIC3: data.Jabatan_PIC_3__c || false,
            alamatKantor: data.Alamat_Kantor__c || false,
            noKantor: data.Nomor_Telepon_Instansi__c || false
        };

        this.updateButtonState();
        console.log('Checkbox states updated:', JSON.stringify(this.checkboxStates, null, 2));
    }
    
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
                namaLengkap: `${(this.customerData.namaDepan || '').trim()}${this.customerData.namaTengah ? ' ' + this.customerData.namaTengah.trim() : ''}${this.customerData.namaBelakang ? ' ' + this.customerData.namaBelakang.trim() : ''}`,
                tanggalLahir: (this.customerData.tanggalLahir || '').trim(),
                noHandphone: (this.customerData.nomorHandphoneTerdaftar || '').trim(),
                noKantor: (this.customerData.nomorTelephoneKantor || '').trim(),
                noRumah: (this.customerData.nomorTelephoneRumah || '').trim(),
                noKerabat: (this.customerData.nomorTelephoneKerabatTidakSerumah || '').trim(),
                namaKerabat: (this.customerData.namaKerabatTidakSerumah || '').trim(),
                kontakDarurat: `${(this.customerData.namaKerabatTidakSerumah || '').trim()}${this.customerData.namaKerabatTidakSerumah && this.customerData.nomorTelephoneKerabatTidakSerumah ? ' | ' : ''}${(this.customerData.nomorTelephoneKerabatTidakSerumah || '').trim()}`,
                noNIK: (this.customerData.nomorNik || '').trim(),
                noNPWP: (this.customerData.nomorNpwp || '').trim(),
                jenisKelamin: (this.customerData.jenisKelamin || '').trim(),
                jabatanKerja: (this.customerData.jabatanKerja || '').trim(),
                sisaLimit: (this.customerData.sisaLimitNasabah || '').trim(),
                limitCicilan: (this.customerData.limitCicilanNasabah || '').trim(),
                alamatBilling: (this.customerData.alamatBilling || '').trim(),
                alamatEmail: (this.customerData.alamatEmail || '').trim(),
                alamatPengirimanKartu: (this.customerData.alamatPengirimanKartu || '').trim(), 
                alamatKantor: `${(this.customerData.alamatKantorDepan || '').trim()}${this.customerData.alamatKantorTengah ? ', ' + this.customerData.alamatKantorTengah.trim() : ''}${this.customerData.alamatKantorBelakang ? ', ' + this.customerData.alamatKantorBelakang.trim() : ''}`,
                alamatRumah: `${(this.customerData.alamatRumahDepan || '').trim()}${this.customerData.alamatRumahBelakang ? ', ' + this.customerData.alamatRumahBelakang.trim() : ''}`,
               
                // From cardData
                limitKartu: this.formatNumber(this.cardData.limitKartuKredit) || this.formatNumber(0),
                expiredKartu: (this.cardData.expiredKartu || '').trim(),
                tglCetak: (this.cardData.tanggalCetakCycle || '').trim(),
                tglJatuhTempo: (this.cardData.tanggalJatuhTempo || '').trim(),
                nominalFullPayment: (this.cardData.nominalFullPayment || '').trim(),
                nominalMinPayment: (this.cardData.nominalMinimumPayment || '').trim(),
                nominalTagihanBerjalan: (this.cardData.nominalTagihanBerjalan || '').trim(),
                nominalPembayaranTerakhir: (this.cardData.nominalPembayaranTerakhir || '').trim(),
                noKartu: (this.cardData.customerNumber || '').trim(),
                namaCetak: (this.cardData.namaCetakKartu || '').trim(),
                tglTerkahirMaintenance: (this.cardData.tanggalTerakhirMaintenanceKartu || '').trim(),
                noRekening: (this.cardData.noRekening || '').trim(),
                
                // From additionalData
                nominalGaji: (this.additionalData.nominalPendapatanPerBulan || '').trim(),
                namaIbuKandung: (this.additionalData.namaLengkapIbuKandung || '').trim(),
            };
    
            console.log('zxc cardInfo:', JSON.stringify(this.cardInfo, null, 2));
        } else {
            console.warn('zxc Warning: detailKreditData is empty or undefined.');
        }
    }

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

    validateCaseStatusState() {
        if (this.isComponentDisabled) {
            this.clearAllData();
            this.isInputHidden = true;
            this.errorMsg = 'Data tidak dapat ditampilkan karena status case tidak sesuai';
            console.log('Data tidak dapat ditampilkan karena status case tidak sesuai');
            this.hasError = true;
            return false;
        }
        return true;
    }

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

            //added in 09-11-2024
            tglBerdiri: false,
            namaPIC1: false,
            namaPIC2: false,
            namaPIC3: false,
            jabatanPIC1: false,
            jabatanPIC2: false,
            jabatanPIC3: false,
            alamatKantor: false,
            noKantor: false
        };
        this.updateButtonState(); // Update button state after clearing
    }

    clearAllData() {
        this.demografiData = {};
        this.simpananData = [];
        this.kreditData = [];
        // this.listKartuBanking = [];
        // this.listKartuKredit = [];
        this.concatenatedAlamatKantor = '';
        this.demografiKreditData = {};
        this.cardInfo = {};
        this.detailKreditData = [];
        this.customerData = [];
        this.cardData = [];
        this.additionalData = [];
        // this.clearCheckboxStates();
    }
    updateButtonState() {

        // Enable or disable buttons based on any checkbox being checked
        // this.isSubmitDisabled = !Object.values(this.checkboxStates).some(value => value);
        // this.isCancelDisabled = this.isSubmitDisabled;

        // console.log(`Submit button is ${this.isSubmitDisabled ? 'disabled' : 'enabled'}.`);
        // console.log(`Cancel button is ${this.isCancelDisabled ? 'disabled' : 'enabled'}.`);

        if(this.isComponentDisabled){
            this.isSubmitDisabled = true;
            this.isCancelDisabled = true;
        } else {

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
                this.checkboxStates.kontakDarurat ||

                //added in 09-11-2024
                this.checkboxStates.tglBerdiri ||
                this.checkboxStates.namaPIC1 ||
                this.checkboxStates.namaPIC2 ||
                this.checkboxStates.namaPIC3 ||
                this.checkboxStates.jabatanPIC1 ||
                this.checkboxStates.jabatanPIC2 ||
                this.checkboxStates.jabatanPIC3 ||
                this.checkboxStates.alamatKantor ||
                this.checkboxStates.noKantor
            );
            this.isCancelDisabled = this.isSubmitDisabled;

        }

        
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
            Tanggal_Berdiri__c: this.checkboxStates.tglBerdiri ? true : false,
            Nama_PIC_1__c: this.checkboxStates.namaPIC1 ? true : false,
            Nama_PIC_2__c: this.checkboxStates.namaPIC2 ? true : false,
            Nama_PIC_3__c: this.checkboxStates.namaPIC3 ? true : false,
            Jabatan_PIC_1__c: this.checkboxStates.jabatanPIC1 ? true : false,
            Jabatan_PIC_2__c: this.checkboxStates.jabatanPIC2 ? true : false,
            Jabatan_PIC_3__c: this.checkboxStates.jabatanPIC3 ? true : false,
            Alamat_Kantor__c: this.checkboxStates.alamatKantor ? true : false,
            Nomor_Telepon_Instansi__c: this.checkboxStates.noKantor ? true : false,
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

    formatCurrencyIDR(amount) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
        }).format(amount);
    }

    formatCurrency(value) {
        const parsedValue = parseFloat(value);
        const formatterCurrency = new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 2,
        });
        return formatterCurrency.format(parsedValue);
    }

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

}