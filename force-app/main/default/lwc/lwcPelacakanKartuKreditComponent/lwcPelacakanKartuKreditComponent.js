/** 
    LWC Name           : lwcPelacakanKartuKreditComponent.js
    Created Date       : 08 Januari 2025
    @description       : This is class for logic pelacakan kartu kredit
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    Release 3
    1.0   08/01/2025   Rakeyan Nuramria                  Initial Version
    1.0   20/01/2025   Rakeyan Nuramria                  Add API functionality
    1.0   04/02/2025   Rakeyan Nuramria                  Add Validation input
    1.0   03/03/2025   Rakeyan Nuramria                  Add logic to censor no kartu based on feedback UAT
**/

import { LightningElement, api, wire, track } from 'lwc';
import getPelacakanCC from '@salesforce/apex/SCC_CaseBRICare.getPelacakanCC';

export default class LwcPelacakanKartuKreditComponent extends LightningElement {
    @api caseId;

    @track namaLengkap = '';
    @track nomorKredit = '';
    @track nomorHp = '';
    @track data = [];

    @track disableSearchButton = true;
    @track disableNamaLengkapField = false;
    @track disableNomorKreditField = false;
    @track disableNomorHandphoneField = false;

    @track isLoading = false;
    @track hasError = false;
    errorMsg = '';
    nomorKartuError;
    nomorHpError;
    @track hasResult = false;

    get visibleData() {
        return this.data.filter(item => !item.isHidden);
    }

    handleNamaLengkapChange(event) {
        this.namaLengkap = event.target.value;
        this.toggleFields('namaLengkap');
        this.handleInputChange();
    }

    handleNomorKreditChange(event) {
        this.nomorKredit = event.target.value;
        this.toggleFields('nomorKredit');
        this.validateCardNumber();
        this.handleInputChange();
    }

    handleNomorHandphoneChange(event) {
        this.nomorHp = event.target.value;
        this.toggleFields('nomorHp');
        this.validatePhoneNumber();
        this.handleInputChange();
    }

    handleInputChange() {
        if ((this.namaLengkap || this.nomorKredit || this.nomorHp) && !this.nomorKartuError && !this.nomorHpError)  {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
            this.clearData(); // Clear all results when no inputs are filled
        }
    }

    validateCardNumber() {
        if (this.nomorKredit) {
            const regex = /^\d{16}$/; // Regex for exactly 16 digits
            if (!regex.test(this.nomorKredit)) {
                this.nomorKartuError = 'Nomor Kartu harus memiliki 16 digit angka.';
            } else {
                this.nomorKartuError = '';
            }
        } else {
            this.nomorKartuError = ''; 
        }
    }

    validatePhoneNumber() {
        if (this.nomorHp) {
            const regex = /^\d{10,14}$/; // Regex for 10-14 digits
            if (!regex.test(this.nomorHp)) {
                this.nomorHpError = 'Nomor Handphone harus memiliki 10-14 digit angka.';
            } else {
                this.nomorHpError = '';
            }
        } else {
            this.nomorHpError = ''; 
        }
    }

    toggleFields(inputField) {
        if (inputField === 'namaLengkap') {
            this.disableNomorKreditField = !!this.namaLengkap;
            this.disableNomorHandphoneField = !!this.namaLengkap;
        } else if (inputField === 'nomorKredit') {
            this.disableNamaLengkapField = !!this.nomorKredit;
            this.disableNomorHandphoneField = !!this.nomorKredit;
        } else if (inputField === 'nomorHp') {
            this.disableNamaLengkapField = !!this.nomorHp;
            this.disableNomorKreditField = !!this.nomorHp;
        }
    }

    handleSearch() {
        this.fetchDataPelacakanKredit();
    }

    fetchDataPelacakanKredit() {
        this.clearData();
        this.isLoading = true;
        this.hasError = false;
        this.errorMsg = '';
    
        const requestPayload = {
            namaLengkap: this.namaLengkap,
            cardNumber: this.nomorKredit,
            phoneNumber: this.nomorHp
        };
    
        const reqId = this.caseId;
    
        console.log('Request Payload Pelacakan:', JSON.stringify({ req: requestPayload, recid: reqId }));
    
        // Call the API
        getPelacakanCC({ req: requestPayload, recid: reqId })
            .then(response => {
                console.log('API Pelacakan Response:', JSON.stringify(response, null, 2));
    
                // Check if response and EMBOSS_DATA exist
                if (!response || !response.EMBOSS_DATA || response.EMBOSS_DATA.length === 0) {
                    this.handleError('Data tidak ditemukan');
                    return;
                }
    
                // Map data and ensure DELIVERY_DATA is always an array
                this.data = response.EMBOSS_DATA.map((user, index) => ({
                    ...user,
                    cardId: `card-${index}`,
                    isHidden: false,
                    nomorHandphone: this.sanitizeValue(user.nomorHandphone),
                    namaNasabahLengkap: this.sanitizeValue(user.namaNasabahLengkap),
                    nomorKartu: this.sanitizeValue(user.nomorKartu),
                    nomorKartuV2: this.censorCardNumber(user.nomorKartu),
                    DELIVERY_DATA: Array.isArray(user.DELIVERY_DATA) ? user.DELIVERY_DATA.map(delivery => ({
                        ...delivery,
                        alamatPengirimanCC1: this.sanitizeValue(delivery.alamatPengirimanCC1),
                        alamatPengirimanCC2: this.sanitizeValue(delivery.alamatPengirimanCC2),
                        alamatPengirimanCC3: this.sanitizeValue(delivery.alamatPengirimanCC3),
                        namaVendorPengirim: this.sanitizeValue(delivery.namaVendorPengirim),
                        tanggalPengirimanKartu: this.sanitizeValue(delivery.tanggalPengirimanKartu),
                        namaPenerima: this.sanitizeValue(delivery.namaPenerima),
                        statusPengirimanKartu: this.sanitizeValue(delivery.statusPengirimanKartu),
                        tanggalPenerimaKartu: this.sanitizeValue(delivery.tanggalPenerimaKartu),
                        trackingPengirimanBarang: this.sanitizeValue(delivery.trackingPengirimanBarang)
                    })) : []
                }));
    
                // Set appropriate flags for rendering
                this.isLoading = false;
                this.hasResult = true;
            })
            .catch(error => {
                // Log the error if the API call fails
                console.error('API Error:', error.message);
                this.handleError('Terjadi kesalahan saat mengambil data.');
            });
    }

    handleError(message) {
        this.isLoading = false;
        this.hasError = true;
        this.errorMsg = message;
        this.hasResult = false;
    }

    handleCardClose(event) {
        const cardId = event.target.dataset.id;
        const cardIndex = this.data.findIndex(item => item.cardId === cardId);
        
        if (cardIndex !== -1) {
            // Create a new array with the updated item
            this.data = [
                ...this.data.slice(0, cardIndex),
                { ...this.data[cardIndex], isHidden: true },
                ...this.data.slice(cardIndex + 1)
            ];
        }

        // Check if all cards are hidden
        if (this.visibleData.length === 0) {
            this.hasResult = false;
        }
    }

    clearData() {
        this.data = [];
        this.hasResult = false;
        this.hasError = false;
        this.isLoading = false;
    }

    // Helper function to sanitize values, ensuring empty strings or whitespace return "-"
    sanitizeValue(value) {
        // Return "-" if the value is null, undefined, empty string, or consists of only spaces
        return (value === null || value === undefined || value.trim() === "") ? "-" : value;
    }

    sanitizeField(field) {
        return (String(field).trim() !== "") ? String(field).trim() : "N/A";
    }

    // Format the card number by splitting into 4-digit blocks
    formatCardNumber(cardNumber) {
        const numStr = cardNumber.replace(/\D/g, ''); // Remove non-digit characters
        return numStr.match(/.{1,4}/g).join(' '); // Split into blocks of 4 digits
    }

    // Censor card number (after formatting, censor middle blocks)
    censorCardNumber(cardNumber) {
        
        cardNumber = this.sanitizeField(cardNumber);
        
        if (!cardNumber || cardNumber === "N/A") return "N/A";
        
        // Card number into blocks of 4 digits
        const formatted = this.formatCardNumber(cardNumber);

        // Censorship
        const blocks = formatted.split(' ');

        // Censor middle blocks and return
        const censored = blocks.map((block, index) => {
            if (index === 0 || index === blocks.length - 1) {
                return block; // Keep first and last blocks
            }
            return 'xxxx'; // Censor the middle blocks
        }).join(' ');

        return censored;
    }

}