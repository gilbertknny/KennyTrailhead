/** 
    LWC Name    : cfCustomerSearch2.html
    Created Date       : 15 August 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   15/08/2024   Ardyta Yudianto                   Initial Version
    1.1   20/08/2024   Rakeyan Nuramria                  Adjust disable Nomor Id
    1.1   23/08/2024   Rakeyan Nuramria                  Adjust function for OutletID, MID Merchant
    1.1   03/09/2024   Rakeyan Nuramria                  Implements integration functions
    1.1   18/09/2024   Rakeyan Nuramria                  Fix API implementation
    1.1   19/09/2024   Rakeyan Nuramria                  Add clear result if input empty
    1.1   30/09/2024   Rakeyan Nuramria                  adjust label in options
    1.1   14/10/2024   Rakeyan Nuramria                  Add another options + Bug fixing for clear input/disable if move to banking section
    1.2   29/11/2024   Rakeyan Nuramria                  [FROM SIT] Adjust showing name for all category (Adjusting to the new logic)
**/

import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import makeCallout from '@salesforce/apex/SCC_CustomerProfileSearch.makeCallout';
import getCustomerProfile from '@salesforce/apex/SCC_HomePageSearch.getCustomerProfile'; // for Banking
import getCardLink from '@salesforce/apex/SCC_HomePageSearch.getCardLink'; // for Kredit
import getBRILink from '@salesforce/apex/SCC_HomePageSearch.getBRILink'; // for BRILink
import getMerchant from '@salesforce/apex/SCC_HomePageSearch.getMerchant'; // for Merchant
import getDPLK from '@salesforce/apex/SCC_HomePageSearch.getDPLK'; // for DPLK
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

const FIELDS = ['User.EmployeeNumber'];
export default class cfCustomerSearch2 extends NavigationMixin(LightningElement) {
    employeeNumber;
    
    @track isLoading;
    @track isLoadingBanking;
    @track isLoadingKredit;
    @track isLoadingBRILink;
    @track isLoadingMerchant;
    @track isLoadingDPLK;
    @track searchDataBanking = [];
    @track searchDataKredit = [];
    @track searchDataBRILink = [];
    @track searchDataMerchant = [];
    @track searchDataDPLK = [];
    @track customerProfiles = [];
    @track errorMsg = '';
    @track idValue = '';
    @track accountNumber = '';
    @track debitCardNumber = '';
    @track creditCardNumber = '';
    @track phoneNumber = '';
    @track tipeId = '';
    @track brilinkTID = '';
    @track brilinkMID = '';
    @track outletID = '';
    @track merchantTID = '';
    @track merchantMID = '';
    @track dplkNumber = '';
    @track disableAccountField = false;
    @track disableDebitCardField = false;
    @track disableCreditCardField = false;
    @track disableIdField = false;
    @track disablePhoneField = false;
    @track disableTipeIdField = false;
    @track disableBrilinkTIDField = false;
    @track disableBrilinkMIDField = false;
    @track disableOutletIDField = false;
    @track disableMerchantTIDField = false;
    @track disableMerchantMIDField = false;
    @track disableDPLKNumberField = false;
    accountNumberError;
    cardNumberError = '';
    creditCardNumberError = '';
    nikNumberError = '';
    phoneNumberError = '';
    brilinkTIDError = '';
    brilinkMIDError = '';
    outletIDError = '';
    merchantTIDError = '';
    merchantMIDError = '';
    dplkNumberError = '';
    tabContent = ''; //for tracking tab
    @track tipeIdOptions = [
        { label: 'Pilih Tipe ...', value: '' },
        { label: 'Kartu Tanda Penduduk (KTP)', value: 'KT' },
        { label: 'Akta Pengenal Impor (API)', value: 'AI' },
        { label: 'Akta Pengenal Impor Terbatas (APIT)', value: 'AK' },
        { label: 'Akta Kelahiran', value: 'AL' },
        { label: 'Akta Pendirian Perusahaan', value: 'AP' },
        { label: 'Akta Perubahan Terakhir', value: 'AR' },
        { label: 'Bank ID Number', value: 'BI' },
        { label: 'Nomor Buku Pensiun', value: 'BK' },
        { label: 'Nomor Pembayaran Pensiun', value: 'BY' },
        { label: 'Kartu Identitas Anak', value: 'KA' },
        { label: 'Kartu Izin Menetap Sementara (KIMS)', value: 'KI' },
        { label: 'Kartu Keluarga', value: 'KK'},
        { label: 'Kartu Izin Menetap Tetap (KITAP)', value: 'KM' },
        { label: 'Kartu Pelajar', value: 'KP' },
        { label: 'Nomor Pokok Wajib Pajak (NPWP)', value: 'NP' },
        { label: 'Persetujuan Menteri Kehakiman', value: 'PK' },
        { label: 'Izin Penanaman Modal Asing (PMA)', value: 'PM' },
        { label: 'Paspor', value: 'PP' },
        { label: 'Surat Keterangan Domisili', value: 'SD' },
        { label: 'Surat Izin Usaha Perdagangan (SIUP)', value: 'SI' },
        { label: 'Surat Nomor Keputusan', value: 'SK' },
        { label: 'Surat Kenal Lahir', value: 'SL' },
        { label: 'Surat Izin Mengemudi (SIM)', value: 'SM' },
        { label: 'Surat Pendirian Kelompok', value: 'SP' },
        { label: 'Surat Keterangan / Izin Tempat Usaha (SITU/SKITU) TD | Tanda Daftar Perusahaan (TDP)', value: 'ST' },
        { label: 'Non Customer Product', value: 'ZZ' },
        { label: 'Lain-lain', value: 'LL' }
    ];

    @track hasError = false;

    get isSearchDisabled() {
        return !!this.errorMsg || !!this.accountNumberError || !!this.cardNumberError || !!this.creditCardNumberError || !!this.phoneNumberError || !!this.brilinkTIDError || !!this.outletIDError || !!this.merchantTIDError ||!!this.merchantMIDError || !!this.dplkNumberError
                || !(this.dplkNumber||this.merchantMID||this.merchantTID||this.outletID||this.brilinkTID||this.brilinkMID||this.phoneNumber||this.tipeId||this.creditCardNumber||this.debitCardNumber||this.accountNumber||this.idValue);
    }

    connectedCallback() {
        this.clearInputFields();
        this.clearErrorsAndResults();
    }

    //wire to get current user employee number
    @wire(getRecord, { recordId: USER_ID, fields: FIELDS })
    loadUser({ error, data }) {
        if (data) {
            this.employeeNumber = data.fields.EmployeeNumber.value;
            console.log('employee number : ', this.employeeNumber);
        } else if (error) {
            console.error('Error retrieving Employee Number:', error);
        }
    }

    disableFields(disable) {
        this.disableAccountField = disable;
        this.disableDebitCardField = disable;
        this.disableCreditCardField = disable;
        this.disableIdField = disable;
        this.disablePhoneField = disable;
        this.disableTipeIdField = disable;
        this.disableBrilinkTIDField = disable;
        this.disableBrilinkMIDField = disable;
        this.disableOutletIDField = disable;
        this.disableMerchantTIDField = disable;
        this.disableMerchantMIDField = disable;
        this.disableDPLKNumberField = disable;
    }

    handleActive(event){
        this.clearInputFields();
        this.clearErrorsAndResults();

        const tab = event.target;
        this.tabContent = `${event.target.value}`;
        console.log(this.tabContent);
        if (this.tabContent !== '1') {
            this.clearInputFields()
            this.disableFields(false);

            // Clear search results and error message
            this.clearErrorsAndResults();

        } else if(this.tabContent === '1'){
            this.clearInputFields()
            this.disableFields(false);
            this.disableIdField = true;
            // Clear search results and error message
            this.clearErrorsAndResults();

        }

        return console.log(this.tabContent);
    }

    handleAccountName(event) {
        this.clearErrorsAndResults();
        this.accountNumber = event.target.value;
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.validateAccountNumber();
        this.toggleFields('account');
        if (!this.accountNumber) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleDebitCreditNo(event) {
        this.clearErrorsAndResults();
        this.debitCardNumber = event.target.value;
        this.accountNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.validateCardNumber();
        this.toggleFields('debitCredit');
        if (!this.debitCardNumber) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleCreditCardNo(event) {
        this.clearErrorsAndResults();
        this.creditCardNumber = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.validateCreditCardNumber();
        this.toggleFields('creditCard');
        if (!this.creditCardNumber) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleNIK(event) {
        this.clearErrorsAndResults();
        this.idValue = event.target.value;
        this.phoneNumber = '';
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        if (this.tabContent == '2'){
            this.validateNIKNumber();
        }
        this.toggleFields('id');
        if (!this.idValue) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handlePhone(event) {
        this.clearErrorsAndResults();
        this.phoneNumber = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.idValue = '';
        this.creditCardNumber = ''; 
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.validatePhoneNumber();
        this.toggleFields('phone');
        if (!this.phoneNumber) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleTipeId(event) {
        this.clearErrorsAndResults();
        this.tipeId = event.detail.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.toggleFields('tipeId');
        if (!this.tipeId) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
        console.log(this.tipeId);
        if (this.tipeId == '') {
            this.disableIdField = true;
        } else {
            this.disableIdField = false;
        }

    }

    handleBrilinkID(event) {
        this.clearErrorsAndResults();
        this.brilinkTID = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.outletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.toggleFields('brilinkTID');
        if (!this.brilinkTID) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleBrilinkMID(event) {
        this.clearErrorsAndResults();
        this.brilinkMID = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.brilinkTID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.toggleFields('brilinkMID');
        if (!this.brilinkMID) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleOutletID(event) {
        this.clearErrorsAndResults();
        this.outletID = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.brilinkTID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        this.toggleFields('outletID');
        if (!this.outletID) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleMerchantTID(event) {
        this.clearErrorsAndResults();
        this.merchantTID = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.brilinkTID = '';
        this.merchantMID = '';
        this.OutletID = '';
        this.dplkNumber = '';
        this.toggleFields('merchantTID');
        if (!this.merchantTID) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleMerchantMID(event) {
        this.clearErrorsAndResults();
        this.merchantMID = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.brilinkTID = '';
        this.merchantTID = '';
        this.OutletID = '';
        this.dplkNumber = '';
        this.toggleFields('merchantMID');
        if (!this.merchantMID) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleDPLKNumber(event) {
        this.clearErrorsAndResults();
        this.dplkNumber = event.target.value;
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.brilinkTID = '';
        this.OutletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.toggleFields('dplkNumber');
        if (!this.dplkNumber) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    toggleFields(inputField) {
        if (inputField === 'account') {
            this.disableDebitCardField = !!this.accountNumber;
            this.disableCreditCardField = !!this.accountNumber;
            this.disableIdField = !!this.accountNumber;
            this.disablePhoneField = !!this.accountNumber;
            this.disableTipeIdField = !!this.accountNumber;
            this.disableBrilinkTIDField = !!this.accountNumber;
            this.disableBrilinkMIDField = !!this.accountNumber;
            this.disableOutletIDField = !!this.accountNumber;
            this.disableMerchantTIDField = !!this.accountNumber;
            this.disableMerchantMIDField = !!this.accountNumber;
            this.disableDPLKNumberField = !!this.accountNumber;
        } else if (inputField === 'debitCredit') {
            this.disableAccountField = !!this.debitCardNumber;
            this.disableCreditCardField = !!this.debitCardNumber;
            this.disableIdField = !!this.debitCardNumber;
            this.disablePhoneField = !!this.debitCardNumber;
            this.disableTipeIdField = !!this.debitCardNumber;
            this.disableBrilinkTIDField = !!this.debitCardNumber;
            this.disableBrilinkMIDField = !!this.debitCardNumber;
            this.disableOutletIDField = !!this.debitCardNumber;
            this.disableMerchantTIDField = !!this.debitCardNumber;
            this.disableMerchantMIDField = !!this.debitCardNumber;
            this.disableDPLKNumberField = !!this.debitCardNumber;
        } else if (inputField === 'creditCard') {
            this.disableAccountField = !!this.creditCardNumber;
            this.disableDebitCardField = !!this.creditCardNumber;
            this.disableIdField = !!this.creditCardNumber;
            this.disablePhoneField = !!this.creditCardNumber;
            this.disableTipeIdField = !!this.creditCardNumber;
            this.disableBrilinkTIDField = !!this.creditCardNumber;
            this.disableBrilinkMIDField = !!this.creditCardNumber;
            this.disableOutletIDField = !!this.creditCardNumber;
            this.disableMerchantTIDField = !!this.creditCardNumber;
            this.disableMerchantMIDField = !!this.creditCardNumber;
            this.disableDPLKNumberField = !!this.creditCardNumber;
        } else if (inputField === 'id') {
            this.disableAccountField = !!this.idValue;
            this.disableDebitCardField = !!this.idValue;
            this.disableCreditCardField = !!this.idValue;
            this.disablePhoneField = !!this.idValue;
            // this.disableTipeIdField = !!this.idValue;
            this.disableBrilinkTIDField = !!this.idValue;
            this.disableBrilinkMIDField = !!this.idValue;
            this.disableOutletIDField = !!this.idValue;
            this.disableMerchantTIDField = !!this.idValue;
            this.disableMerchantMIDField = !!this.idValue;
            this.disableDPLKNumberField = !!this.idValue;
        } else if (inputField === 'phone') {
            this.disableAccountField = !!this.phoneNumber;
            this.disableDebitCardField = !!this.phoneNumber;
            this.disableCreditCardField = !!this.phoneNumber;
            this.disableIdField = !!this.phoneNumber;
            this.disableTipeIdField = !!this.phoneNumber;
            this.disableBrilinkTIDField = !!this.phoneNumber;
            this.disableBrilinkMIDField = !!this.phoneNumber;
            this.disableOutletIDField = !!this.phoneNumber;
            this.disableMerchantTIDField = !!this.phoneNumber;
            this.disableMerchantMIDField = !!this.phoneNumber;
            this.disableDPLKNumberField = !!this.phoneNumber;
        } else if (inputField === 'tipeId') {
            this.disableAccountField = !!this.tipeId;
            this.disableDebitCardField = !!this.tipeId;
            this.disableCreditCardField = !!this.tipeId;
            // this.disableIdField = !!this.tipeId;
            this.disablePhoneField = !!this.tipeId;
            this.disableBrilinkTIDField = !!this.tipeId;
            this.disableBrilinkMIDField = !!this.tipeId;
            this.disableOutletIDField = !!this.tipeId;
            this.disableMerchantTIDField = !!this.tipeId;
            this.disableMerchantMIDField = !!this.tipeId;
            this.disableDPLKNumberField = !!this.tipeId;
        } else if (inputField === 'brilinkTID') {
            this.disableAccountField = !!this.brilinkTID;
            this.disableDebitCardField = !!this.brilinkTID;
            this.disableCreditCardField = !!this.brilinkTID;
            this.disableIdField = !!this.brilinkTID;
            this.disablePhoneField = !!this.brilinkTID;
            this.disableTipeIdField = !!this.brilinkTID;
            this.disableBrilinkMIDField = !!this.brilinkTID;
            this.disableOutletIDField = !!this.brilinkTID;
            this.disableMerchantTIDField = !!this.brilinkTID;
            this.disableMerchantMIDField = !!this.brilinkTID;
            this.disableDPLKNumberField = !!this.brilinkTID;
        } else if (inputField === 'brilinkMID') {
            this.disableAccountField = !!this.brilinkMID;
            this.disableDebitCardField = !!this.brilinkMID;
            this.disableCreditCardField = !!this.brilinkMID;
            this.disableIdField = !!this.brilinkMID;
            this.disablePhoneField = !!this.brilinkMID;
            this.disableTipeIdField = !!this.brilinkMID;
            this.disableBrilinkTIDField = !!this.brilinkMID;
            this.disableOutletIDField = !!this.brilinkMID;
            this.disableMerchantTIDField = !!this.brilinkMID;
            this.disableMerchantMIDField = !!this.brilinkMID;
            this.disableDPLKNumberField = !!this.brilinkMID;
        } else if (inputField === 'outletID'){
            this.disableAccountField = !!this.outletID;
            this.disableDebitCardField = !!this.outletID;
            this.disableCreditCardField = !!this.outletID;
            this.disableIdField = !!this.outletID;
            this.disablePhoneField = !!this.outletID;
            this.disableTipeIdField = !!this.outletID;
            this.disableBrilinkTIDField = !!this.outletID;
            this.disableBrilinkMIDField = !!this.outletID;
            this.disableMerchantTIDField = !!this.outletID;
            this.disableMerchantMIDField = !!this.outletID;
            this.disableDPLKNumberField = !!this.outletID;
        } else if (inputField === 'merchantTID') {
            this.disableAccountField = !!this.merchantTID;
            this.disableDebitCardField = !!this.merchantTID;
            this.disableCreditCardField = !!this.merchantTID;
            this.disableIdField = !!this.merchantTID;
            this.disablePhoneField = !!this.merchantTID;
            this.disableTipeIdField = !!this.merchantTID;
            this.disableBrilinkTIDField = !!this.merchantTID;
            this.disableBrilinkMIDField = !!this.merchantTID;
            this.disableOutletIDField = !!this.merchantTID;
            this.disableMerchantMIDField = !!this.merchantTID;
            this.disableDPLKNumberField = !!this.merchantTID;
        } else if(inputField === 'merchantMID'){
            this.disableAccountField = !!this.merchantMID;
            this.disableDebitCardField = !!this.merchantMID;
            this.disableCreditCardField = !!this.merchantMID;
            this.disableIdField = !!this.merchantMID;
            this.disablePhoneField = !!this.merchantMID;
            this.disableTipeIdField = !!this.merchantMID;
            this.disableBrilinkTIDField = !!this.merchantMID;
            this.disableBrilinkMIDField = !!this.merchantMID;
            this.disableOutletIDField = !!this.merchantMID;
            this.disableMerchantTIDField = !!this.merchantMID;
            this.disableDPLKNumberField = !!this.merchantMID;
        } else if (inputField === 'dplkNumber') {
            this.disableAccountField = !!this.dplkNumber;
            this.disableDebitCardField = !!this.dplkNumber;
            this.disableCreditCardField = !!this.dplkNumber;
            this.disableIdField = !!this.dplkNumber;
            this.disablePhoneField = !!this.dplkNumber;
            this.disableTipeIdField = !!this.dplkNumber;
            this.disableBrilinkTIDField = !!this.dplkNumber;
            this.disableBrilinkMIDField = !!this.dplkNumber;
            this.disableOutletIDField = !!this.dplkNumber;
            this.disableMerchantTIDField = !!this.dplkNumber;
            this.disableMerchantMIDField = !!this.dplkNumber;
        }
    }

    validateAccountNumber() {
        
        const regex = /^\d{15,18}$/;

        if (!regex.test(this.accountNumber)) {
            this.accountNumberError = 'Nomor Rekening harus memiliki 15 hingga 18 digit angka.';
        } else {
            this.accountNumberError = null;
        }
    }

    validateCardNumber() {
        // if (this.debitCardNumber.length < 6) {
        //     this.cardNumberError = 'Debit Card Number must be at least 6 characters.';
        // }

        const regex = /^\d{16}$/;

        if (!regex.test(this.debitCardNumber)) {
            this.cardNumberError = 'Nomor Kartu Debit harus memiliki 16 digit angka.';
        } else {
            this.cardNumberError = null;
        }


    }

    validateCreditCardNumber() {
        // if (this.creditCardNumber.length < 16) {
        //     this.creditCardNumberError = 'Nomor Kartu Kredit harus memiliki 16 digit.';
        // } else if (this.creditCardNumber.length > 16) {
        //     this.creditCardNumberError = 'Nomor Kartu Kredit tidak boleh melebihi 16 digit.';
        // }

        const regex = /^\d{16}$/;

        if (!regex.test(this.creditCardNumber)) {
            this.creditCardNumberError = 'Nomor Kartu Kredit harus memiliki 16 digit angka.';
        } else {
            this.creditCardNumberError = null;
        }
    }

    validateNIKNumber() {

        const regex = /^\d{16}$/;

        if (!regex.test(this.idValue)) {
            this.nikNumberError = 'Nomor ID (NIK) harus memiliki 16 digit angka.';
        } else {
            this.nikNumberError = null;
        }
    }

    validatePhoneNumber() {
        const phoneRegex = /^[0-9]{10,13}$/;
        if (!phoneRegex.test(this.phoneNumber)) {
            this.phoneNumberError = 'Nomor Telepon harus memiliki 10 hingga 13 digit angka.';
        }
    }

    // handleSearch() {
    //     makeCallout({ 
    //         accountNumber: this.accountNumber,
    //         debitCreditNumber: this.debitCardNumber,
    //         idValue: this.idValue,
    //         phoneNumber: this.phoneNumber
    //     })
    //     .then(result => {
    //         if (result && !result.errorMessage) {
    //             // if (Array.isArray(result)) {
    //             //     this.searchData = result;
    //             // } else {
    //             //     this.searchData = [result]; // Convert single record to array
    //             // }
    //             this.searchData = Array.isArray(result) ? result : [result];

    //             this.errorMsg = '';
    //             this.hasError = false;
    //         } else if (result && result.errorMessage) {
    //             this.errorMsg = result.errorMessage;
    //             this.searchData = [];
    //             this.hasError = true;
    //         } else {
    //             this.errorMsg = 'Data tidak ditemukan';
    //             this.searchData = [];
    //             this.hasError = true;
    //         }
    //         console.log('Search Data:', JSON.stringify(this.searchData));
    //         console.log('Formatted Search Data:', JSON.stringify(this.formattedSearchData));
    //         console.log('hasError : ', this.hasError);
    //     })
    //     .catch(error => {
    //         this.errorMsg = 'Data tidak ditemukan';
    //         this.searchData = [];
    //         this.hasError = true;
    //     });
    //     console.log('Error:', error);
        
    // }


    // handleSearch v2 for hide result card before click/data error, ON TESTING [26/08/2024 - BY RAKEYAN]
    
    // handleSearch() {
    //     makeCallout({ 
    //         accountNumber: this.accountNumber,
    //         debitCreditNumber: this.debitCardNumber,
    //         idValue: this.idValue,
    //         phoneNumber: this.phoneNumber
    //     })
    //     .then(result => {
    //         if (result && !result.errorMessage) {
    //             this.searchData = Array.isArray(result) ? result : [result];
    //             this.errorMsg = '';
    //             this.hasError = false;
    //         } else if (result && result.errorMessage) {
    //             this.errorMsg = result.errorMessage;
    //             this.searchData = [];
    //             this.hasError = true;
    //         } else {
    //             this.errorMsg = 'Data tidak ditemukan';
    //             this.searchData = [];
    //             this.hasError = true;
    //         }
    
    //         console.log('Search Data:', JSON.stringify(this.searchData));
    //         console.log('Formatted Search Data:', JSON.stringify(this.formattedSearchData));
    //         console.log('hasError : ', this.hasError);
    //     })
    //     .catch(error => {
    //         this.errorMsg = 'Data tidak ditemukan';
    //         this.searchData = [];
    //         this.hasError = true;
    //         console.log('Error:', error);
    //     });
    // }

    //handleSearchBanking - Using new hit API
    /** before adjust error use
    handleSearchBanking() {
        console.log('function search called..');
        this.isLoadingBanking = true;
    
        const requestPayload = {
            cardNo: this.debitCardNumber,
            acctNo: this.accountNumber,
            cifNo: '',
            phoneNumber: this.phoneNumber,
            idType: this.tipeId,
            idValue: this.idValue,
            personalNumber: this.employeeNumber,
            channelId: 'CHMS',
            feature: ''
        };
    
        console.log('Request Payload:', JSON.stringify(requestPayload));
    
        getCustomerProfile({ req: requestPayload })
            .then(result => {
                if (result && !result.errorMessage) {
                    this.searchDataBanking = Array.isArray(result) ? result : [result];
                    this.errorMsg = '';
                    this.hasError = false;
                    this.isLoadingBanking = false;

                    console.log('Data:', JSON.stringify(this.searchDataBanking));
                } else {
                    this.handleSearchError(result?.errorMessage || 'Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('Data tidak ditemukan');
                console.log('Error:', error);
                
            });
    }
    */

    //adjusted error handling
    /** 
    handleSearchBanking() {
        console.log('Function search called..');
        this.isLoadingBanking = true;
        console.log('Loading state set to true.');
    
        const requestPayload = {
            cardNo: this.debitCardNumber || null,
            acctNo: this.accountNumber || null,
            cifNo: '' || null,
            phoneNumber: this.phoneNumber || null,
            idType: this.tipeId || null,
            idValue: this.idValue || null,
            personalNumber: this.employeeNumber || null,
            channelId: 'CHMS',
            feature: '' || null
        };
    
        console.log('Request Payload:', JSON.stringify(requestPayload));
    
        getCustomerProfile({ req: requestPayload })
            .then(result => {
                console.log('Response received:', result);
                if (result && result.length > 0) {
                    const response = result[0];
                    console.log('First result item:', response);
    
                    if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        console.log('Valid response received.');
                        this.searchDataBanking = response;
                        this.errorMsg = '';
                        this.hasError = false;
                        console.log('valid searchDataBanking : ' , JSON.stringify(this.searchDataBanking));
                        // console.log('valid formattedSearchDataBanking : ' , JSON.stringify(this.formattedSearchDataBanking));
                    } else {
                        console.log('Invalid response received, handling error.');
                        this.handleSearchError(response.res.responseMessage || 'Data tidak ditemukan');
                    }
                } else {
                    console.log('No results found, handling error.');
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingBanking = false;
                console.log('Loading state set to false.');
            });
    }
    */

    //New adjusted for error handling - ON USE
    handleSearchBanking() {
        console.log('Function search called..');
        this.isLoadingBanking = true;
        console.log('Loading state set to true.');
    
        const requestPayload = {
            cardNo: this.debitCardNumber || null,
            acctNo: this.accountNumber || null,
            cifNo: '' || null,
            phoneNumber: this.phoneNumber || null,
            idType: this.tipeId || null,
            idValue: this.idValue || null,
            personalNumber: this.employeeNumber || null,
            channelId: 'CHMS',
            feature: '' || null
        };
    
        console.log('Request Payload:', JSON.stringify(requestPayload));
    
        getCustomerProfile({ req: requestPayload })
            .then(result => {
                console.log('Response received:', result);
                if (result && result.length > 0) {
                    if (Array.isArray(result)) {
                        // Handle array of results
                        const response = result[0];
                        if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                            this.searchDataBanking = result; // Use the array directly
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.res.responseMessage || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    } else {
                        // Handle single object result
                        const response = result;
                        if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                            this.searchDataBanking = [response]; // Wrap single result in an array
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.res.responseMessage || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    }
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingBanking = false;
                console.log('Loading state set to false.');
            });
    }
    
/** 
    handleSearchKredit() {
        console.log('function handleSearchKredit called..');
        this.isLoadingKredit = true;
    
        const requestPayload = {
            cardNo: this.creditCardNumber,
            phoneNumber: this.phoneNumber,
            customerNumber: '',
            nik: this.idValue
        };
    
        console.log('Request Payload:', JSON.stringify(requestPayload));
    
        getCardLink(requestPayload)
            .then(result => {
                if (result && !result.errorMessage) {
                    console.log('response Kredit : ', JSON.stringify(result));
                    this.searchDataKredit = Array.isArray(result) ? result : [result];
                    this.errorMsg = '';
                    this.hasError = false;
                    this.isLoadingKredit = false;

                    console.log('Data:', JSON.stringify(this.searchData));
                } else {
                    this.handleSearchError(result?.errorMessage || 'Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('Data tidak ditemukan');
                console.log('Error:', error);
                
            });
    }
*/
    handleSearchKredit() {
        console.log('function handleSearchKredit called..');
        this.isLoadingKredit = true;
        console.log('Loading state set to true.');
    
        const requestPayload = {
            cardNo: this.creditCardNumber || null,
            phoneNumber: this.phoneNumber || null,
            customerNumber: '' || null,
            nik: this.idValue || null
        };
    
        console.log('Request Payload:', JSON.stringify(requestPayload));
    
        getCardLink(requestPayload)
            .then(result => {
                console.log('Response received:', result);
                if (result && result.length > 0) {
                    if (Array.isArray(result)) {
                        // Handle array of results
                        const response = result[0];
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.cld) {
                            this.searchDataKredit = result; // Use the array directly
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    } else {
                        // Handle single object result
                        const response = result;
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.cld) {
                            this.searchDataKredit = [response]; // Wrap single result in an array
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    }
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingKredit = false;
                console.log('Loading state set to false.');
            });
    }

    /** 
   handleSearchBRILink() {
        console.log('function handleSearchBRILink called..');
        this.isLoadingBRILink = true;
        const requestPayload = {
            tid: this.brilinkTID,
            mid: this.outletID
        };

        console.log('Request Payload:', JSON.stringify(requestPayload));

        getBRILink(requestPayload)
            .then(result => {
                if (result && !result.errorMessage) {
                    console.log('response BRILink : ', result);
                    console.log('response BRILink : ', JSON.stringify(result));
                    this.searchDataBRILink = Array.isArray(result) ? result : [result];
                    this.errorMsg = '';
                    this.isLoadingBRILink = false;
                    this.hasError = false;
                } else {
                    this.handleSearchError(result?.errorMessage || 'Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('Data tidak ditemukan');
                console.log('Error:', error);
            });
    }
    */
    handleSearchBRILink() {
        console.log('function handleSearchBRILink called..');
        this.isLoadingBRILink = true;
        console.log('Loading state set to true.');

        const requestPayload = {
            tid: this.brilinkTID,
            // mid: this.outletID
            mid: this.brilinkMID
        };

        console.log('Request Payload:', JSON.stringify(requestPayload));

        getBRILink(requestPayload)
            .then(result => {
                console.log('Response received:', result);
                if (result && result.length > 0) {
                    if (Array.isArray(result)) {
                        // Handle array of results
                        const response = result[0];
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.bp) {
                            this.searchDataBRILink = result; // Use the array directly
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    } else {
                        // Handle single object result
                        const response = result;
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.bp) {
                            this.searchDataBRILink = [response]; // Wrap single result in an array
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    }
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingBRILink = false;
                console.log('Loading state set to false.');
            });
    }

    /**
    handleSearchMerchant(){
        console.log('function handleSearchMerchant called..');
        this.isLoadingMerchant = true;
        const requestPayload = {
            tid: this.merchantTID,
            mid: this.merchantMID
        };

        console.log('Request Payload:', JSON.stringify(requestPayload));

        getMerchant(requestPayload)
            .then(result => {
                if (result && !result.errorMessage) {
                    console.log('response Merchant : ', result);
                    console.log('response Merchant : ', JSON.stringify(result));
                    this.searchDataMerchant = Array.isArray(result) ? result : [result];
                    this.errorMsg = '';
                    this.isLoadingMerchant = false;
                    this.hasError = false;
                } else {
                    this.handleSearchError(result?.errorMessage || 'Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('Data tidak ditemukan');
                console.log('Error:', error);
            });
    }
    */

    handleSearchMerchant(){
        console.log('function handleSearchMerchant called..');
        this.isLoadingMerchant = true;
        const requestPayload = {
            tid: this.merchantTID,
            mid: this.merchantMID
        };

        console.log('Request Payload:', JSON.stringify(requestPayload));

        getMerchant(requestPayload)
            .then(result => {
                console.log('Response received:', result);
                if (result && result.length > 0) {
                    if (Array.isArray(result)) {
                        // Handle array of results
                        const response = result[0];
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.mp) {
                            this.searchDataMerchant = result; // Use the array directly
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    } else {
                        // Handle single object result
                        const response = result;
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.mp) {
                            this.searchDataMerchant = [response]; // Wrap single result in an array
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    }
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingMerchant = false;
                console.log('Loading state set to false.');
            });
    }

    /**
    handleSearchDPLK() {
        console.log('function handleSearchDPLK called..');
        this.isLoadingDPLK = true;
        const requestPayload = {
            idNumber: this.idValue,
            acctNo: this.dplkNumber
        };

        console.log('Request Payload:', JSON.stringify(requestPayload));

        getDPLK(requestPayload)
            .then(result => {
                if (result && !result.errorMessage) {
                    console.log('response DPLK : ', result);
                    console.log('response DPLK : ', JSON.stringify(result));
                    this.searchDataDPLK = Array.isArray(result) ? result : [result];
                    this.errorMsg = '';
                    this.isLoadingDPLK = false;
                    this.hasError = false;
                } else {
                    this.handleSearchError(result?.errorMessage || 'Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('Data tidak ditemukan');
                console.log('Error:', error);
            });
    }
    */

    handleSearchDPLK() {
        console.log('function handleSearchDPLK called..');
        this.isLoadingDPLK = true;
        const requestPayload = {
            idNumber: this.idValue,
            acctNo: this.dplkNumber
        };

        console.log('Request Payload:', JSON.stringify(requestPayload));

        getDPLK(requestPayload)
            .then(result => {
                console.log('Response received:', result);
                if (result && result.length > 0) {
                    if (Array.isArray(result)) {
                        // Handle array of results
                        const response = result[0];
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.si) {
                            this.searchDataDPLK = result; // Use the array directly
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    } else {
                        // Handle single object result
                        const response = result;
                        // if (response.res.errorCode === '000' && response.res.responseCode === '00') {
                        if (response.si) {
                            this.searchDataDPLK = [response]; // Wrap single result in an array
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            // this.handleSearchError(response.msg || 'Data tidak ditemukan');
                            this.handleSearchError('Data tidak ditemukan');
                        }
                    }
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingDPLK = false;
                console.log('Loading state set to false.');
            });
    }

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        this.searchData = [];
        this.hasError = true;
        this.isLoadingBanking = false;
        this.isLoadingKredit = false;
        this.isLoadingBRILink = false;
        this.isLoadingMerchant = false;
        this.isLoadingDPLK = false;
        console.log('Error Message:', errorMessage);
    }
    
    // get formattedSearchDataBanking() {
    //     if (this.hasError) {
    //         console.log('Error detected, clearing data.');
    //         return []; // Return an empty array if there's an error
    //     }
    //     return this.searchDataBanking.map((record, index) => ({
    //         ...record,
    //         columnNumber: index + 1, // Start column number from 1
    //         // acc: record
    //     }));

    // }

    get formattedSearchDataBanking() {
        if (this.hasError) {
            console.log('Error detected, clearing data.');
            return []; // Return an empty array if there's an error
        }
    
        // Ensure searchDataBanking is an array before mapping
        const dataArray = Array.isArray(this.searchDataBanking) ? this.searchDataBanking : [this.searchDataBanking];
    
        return dataArray.map((record, index) => ({
            ...record,
            columnNumber: index + 1,
            formattedName: record.acc.Name || record.acc.LastName
        }));
    }
    

    get formattedSearchDataKredit() {
        // if (this.hasError) {
        //     console.log('Error detected, clearing data.');
        //     return []; // Return an empty array if there's an error
        // }
        // return this.searchDataKredit.map((record, index) => ({
        //     ...record,
        //     columnNumber: index + 1, // Start column number from 1
        //     // phoneNumber: this.phoneNumber
        // }));

        if (this.hasError) {
            console.log('Error detected, clearing data.');
            return []; // Return an empty array if there's an error
        }
    
        // Ensure searchDataKredit is an array before mapping
        const dataArrayKredit = Array.isArray(this.searchDataKredit) ? this.searchDataKredit : [this.searchDataKredit];
    
        return dataArrayKredit.map((record, index) => ({
            ...record,
            columnNumber: index + 1,
            formattedName: record.acc.Name || record.acc.LastName
        }));
    }

    get formattedSearchDataBRILink() {
        // if (this.hasError) {
        //     console.log('Error detected, clearing data.');
        //     return []; // Return an empty array if there's an error
        // }
        // return this.searchDataBRILink.map((record, index) => ({
        //     ...record,
        //     columnNumber: index + 1, // Start column number from 1
        //     // phoneNumber: this.phoneNumber
        // }));

        if (this.hasError) {
            console.log('Error detected, clearing data.');
            return []; // Return an empty array if there's an error
        }
    
        // Ensure searchDataBRILink is an array before mapping
        const dataArray = Array.isArray(this.searchDataBRILink) ? this.searchDataBRILink : [this.searchDataBRILink];
    
        return dataArray.map((record, index) => ({
            ...record,
            columnNumber: index + 1,
            formattedName: record.acc.Name || record.acc.LastName
        }));
    }

    get formattedSearchDataMerchant() {
        // if (this.hasError) {
        //     console.log('Error detected, clearing data.');
        //     return []; // Return an empty array if there's an error
        // }
        // return this.searchDataMerchant.map((record, index) => ({
        //     ...record,
        //     columnNumber: index + 1, // Start column number from 1
        //     // phoneNumber: this.phoneNumber
        // }));

        if (this.hasError) {
            console.log('Error detected, clearing data.');
            return []; // Return an empty array if there's an error
        }
    
        // Ensure searchDataMerchant is an array before mapping
        const dataArray = Array.isArray(this.searchDataMerchant) ? this.searchDataMerchant : [this.searchDataMerchant];
    
        return dataArray.map((record, index) => ({
            ...record,
            columnNumber: index + 1,
            formattedName: record.acc.Name || record.acc.LastName
        }));
    }
    
    get formattedSearchDataDPLK() {
        // if (this.hasError) {
        //     console.log('Error detected, clearing data.');
        //     return []; // Return an empty array if there's an error
        // }
        // return this.searchDataDPLK.map((record, index) => ({
        //     ...record,
        //     columnNumber: index + 1, // Start column number from 1
        //     // phoneNumber: this.phoneNumber
        // }));

        if (this.hasError) {
            console.log('Error detected, clearing data.');
            return []; // Return an empty array if there's an error
        }
    
        // Ensure searchDataDPLK is an array before mapping
        const dataArray = Array.isArray(this.searchDataDPLK) ? this.searchDataDPLK : [this.searchDataDPLK];
    
        return dataArray.map((record, index) => ({
            ...record,
            columnNumber: index + 1,
            formattedName: record.acc.Name || record.acc.LastName
        }));
    }
    

    clearInputFields() {
        this.accountNumber = '';
        this.debitCardNumber = '';
        this.creditCardNumber = '';
        this.idValue = '';
        this.phoneNumber = '';
        this.tipeId = '';
        this.brilinkTID = '';
        this.brilinkMID = '';
        this.outletID = '';
        this.merchantTID = '';
        this.merchantMID = '';
        this.dplkNumber = '';
        if (this.tabContent == '1') {
            this.disableIdField = true;
        }
    }

    clearErrorsAndResults() {
        this.errorMsg = '';
        this.accountNumberError = '';
        this.cardNumberError = '';
        this.creditCardNumberError = '';
        this.nikNumberError = '';
        this.phoneNumberError = '';
        this.brilinkTIDError = '';
        this.brilinkMIDError = '';
        this.outletID = '';
        this.merchantTIDError = '';
        this.merchantMIDError = '';
        this.dplkNumberError = '';
        this.searchDataBanking = [];
        this.searchDataKredit = [];
        this.searchDataBRILink = [];
        this.searchDataMerchant = [];
        this.searchDataDPLK = [];
        this.searchData = [];
        // this.formattedSearchData = [];
        this.hasError = false;

    }
    
    // navigateToAccountDetail(event) {
    //     const accountId = event.currentTarget.dataset.accountid;
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__recordPage',
    //         attributes: {
    //             recordId: accountId,
    //             actionName: 'view'
    //         }
    //     }).then(() => {
    //         refreshApex(this.searchData);
    //     });
    // }

    navigateToAccountDetail(event) {
        event.preventDefault();

        const accountId = event.currentTarget.dataset.accountid;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account', // The API name of the object
                actionName: 'view'
            }
        });

        // Refresh the Account list
        refreshApex(this.searchData);
        this.clearErrorsAndResults();
    }
}