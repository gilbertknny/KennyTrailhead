/** 
    LWC Name    : lwcDataPengajuanKreditComponent.js
    Created Date       : 12 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   12/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   24/09/2024   Rakeyan Nuramria                  Add API Functionality
    release 3
    1.1   ??/12?01/2024?25   Rakeyan Nuramria            Adjust API Functionality
    1.0   04/03/2025   Rakeyan Nuramria                  Add logic to Censor/Masking for nomor kartu based on feedback UAT


**/

import { LightningElement, track, api } from 'lwc';
import pengajuanCC from '@salesforce/apex/SCC_CaseBRICare.pengajuanCC';

export default class LwcDataPengajuanKreditComponent extends LightningElement {

    @api caseId;
    @track nik = '';
    @track nikNumberError = '';
    @track isLoading = false;
    @track disableNIKField = false;
    @track showResult = false;
    @track hasError = false;
    @track errorMsg = '';
    @track dataNasabah = [];

    connectedCallback() {
        console.log('pengajuan caseId from parent : ', this.caseId);
    }

    get isCariButtonDisabled() {
        return !(this.nik && !this.nikNumberError);
    }

    // Alternative function to simulate fetching data for testing
    fetchDataPengajuanKreditMock() {
        console.log('Mock function fetchDataPengajuanKreditMock called..');
        this.isLoading = true;

        // Mocked response based on the example JSON provided
        const mockResponse = {
            dataNasabah: [
                {
                    namaNasabahLengkap: "NIKMATUL AKBAR                ",
                    nik: "1871050901890003    ",
                    tanggalLahir: "1989-01-09T00:00:00",
                    dataPengajuan: [
                        {
                            kodeAplikasiPengajuan: "00002024000091",
                            tanggalPengajuan: "2024-12-02T15:13:35.033",
                            channelPengajuan: "BR",
                            CUSTPRO: [],
                            APPFLAG: [
                                {
                                    progresPengajuan: "1.1",
                                    Deskripsi: {
                                        deskripsiPengajuan: "Document Checking"
                                        // deskripsiPengajuan: ""
                                    }
                                }
                            ]
                        },
                        {
                            kodeAplikasiPengajuan: "RX3565100100000206",
                            tanggalPengajuan: "2012-05-13T00:00:00",
                            channelPengajuan: "BR",
                            CUSTPRO: [
                                {
                                    nomorKartuKredit: "3565100100000206"
                                }
                            ],
                            APPFLAG: [
                                {
                                    progresPengajuan: "9.0",
                                    Deskripsi: {
                                        deskripsiPengajuan: "Booked"
                                    }
                                }
                            ]
                        }
                    ]
                }
            ]
        };

        // Simulate a delay to mimic server behavior
        setTimeout(() => {
            try {
                const response = mockResponse.dataNasabah;

                if (Array.isArray(response) && response.length > 0) {
                    this.dataNasabah = response.map(nasabah => this.processNasabahData(nasabah));
                    this.errorMsg = '';
                    this.hasError = false;
                    this.showResult = true;
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            } catch (error) {
                console.error('Error occurred during mock search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            } finally {
                this.isLoading = false;
            }
        }, 1000); // Simulate a 1-second server response delay
    }

    // Scenario 2: Empty data (Data tidak ditemukan)
    fetchDataPengajuanKreditMockEmpty() {
        console.log('Mock function fetchDataPengajuanKreditMockEmpty called..');
        this.isLoading = true;

        const mockResponse = {
            dataNasabah: []
        };

        setTimeout(() => {
            try {
                const response = mockResponse.dataNasabah;

                if (Array.isArray(response) && response.length > 0) {
                    this.dataNasabah = response.map(nasabah => this.processNasabahData(nasabah));
                    this.errorMsg = '';
                    this.hasError = false;
                    this.showResult = true;
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            } catch (error) {
                console.error('Error occurred during mock search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            } finally {
                this.isLoading = false;
            }
        }, 1000);
    }

    // Scenario 3: Nasabah exists but no pengajuan data
    fetchDataPengajuanKreditMockNoPengajuan() {
        console.log('Mock function fetchDataPengajuanKreditMockNoPengajuan called..');
        this.isLoading = true;

        const mockResponse = {
            dataNasabah: [
                {
                    namaNasabahLengkap: "NIKMATUL AKBAR                ",
                    nik: "1871050901890003    ",
                    tanggalLahir: "1989-01-09T00:00:00",
                    dataPengajuan: [] // Empty pengajuan data
                }
            ]
        };

        setTimeout(() => {
            try {
                const response = mockResponse.dataNasabah;

                if (Array.isArray(response) && response.length > 0) {
                    this.dataNasabah = response.map(nasabah => this.processNasabahData(nasabah));
                    this.errorMsg = '';
                    this.hasError = false;
                    this.showResult = true;
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            } catch (error) {
                console.error('Error occurred during mock search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            } finally {
                this.isLoading = false;
            }
        }, 1000);
    }


    fetchDataPengajuanKredit() {
        console.log('function fetchDataPengajuanKredit called..');
        this.isLoading = true;

        const requestPayload = {
            idNumber: this.nik,
        };

        const recId = this.caseId

        console.log('Request pengajuan payload:', JSON.stringify({req : requestPayload, recid : recId}));

        pengajuanCC({req : requestPayload, recid : recId})
            .then(result => {
                console.log('Response pengajuan received:', JSON.stringify(result, null, 2));

                const response = result?.dataNasabah;

                if (Array.isArray(response) && response.length > 0) {
                    this.dataNasabah = response.map(nasabah => this.processNasabahData(nasabah));
                    this.errorMsg = '';
                    this.hasError = false;
                    this.showResult = true;
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
            });
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.nikNumberError = '';
        this.dataNasabah = [];
        this.isLoading = false;
    }

    handleNIKChange(event) {
        this.nik = event.target.value;
        this.validateNIKNumber();
        if (!this.nik) {
            this.clearInputFields();
        }
    }

    validateNIKNumber() {
        const regex = /^\d{16}$/;

        if (!regex.test(this.nik)) {
            this.nikNumberError = 'NIK harus memiliki 16 digit angka.';
        } else {
            this.nikNumberError = null;
        }
    }

    handleSearch() {
        this.isLoading = true;
        this.showResult = false;
        
        // Choose which scenario to test:
        
        // Original mock with complete data
        // this.fetchDataPengajuanKreditMock();
        
        // Scenario 2: Empty data
        // this.fetchDataPengajuanKreditMockEmpty();
        
        // Scenario 3: No pengajuan data
        // this.fetchDataPengajuanKreditMockNoPengajuan();
        
        // Real API call
        this.fetchDataPengajuanKredit();
    }

    clearInputFields() {
        this.nik = '';
        this.errorMsg = '';
        this.nikNumberError = '';
        this.isLoading = false;
        this.showResult = false;
        this.dataNasabah = [];
    }

    // Helper method to safely handle empty/null values
    safeValue(value) {
        if (value === null || value === undefined || String(value).trim() === '') {
            return '-';
        }
        return String(value).trim();
    }

    // Helper method to safely handle dates
    safeDate(dateString) {
        if (!dateString) return '-';
        const trimmed = String(dateString).trim();
        return trimmed === '' ? '-' : trimmed;
    }

    // Helper method to replace null, undefined, or empty strings with '-'
    processNasabahData(nasabah) {
        if (!nasabah) return null;

        const cardNumber = this.getNomorKartuKredit(nasabah.dataPengajuan);

        return {
            namaNasabahLengkap: this.safeValue(nasabah.namaNasabahLengkap),
            nik: this.safeValue(nasabah.nik),
            tanggalLahir: this.safeDate(nasabah.tanggalLahir),
            // dataPengajuan: Array.isArray(nasabah.dataPengajuan),
            // nomorKartuKredit: this.getNomorKartuKredit(nasabah.dataPengajuan),

            // Adjust/Added in 04/03/2025
            nomorKartuKredit: cardNumber,
            nomorKartuKreditCensored: this.censorCardNumber(cardNumber),

            dataPengajuan: Array.isArray(nasabah.dataPengajuan) 
                ? nasabah.dataPengajuan.map(pengajuan => this.processPengajuanData(pengajuan))
                : []
        };
    }

    // Helper method to process pengajuan data
    processPengajuanData(pengajuan) {
        if (!pengajuan) return null;

        return {
            kodeAplikasiPengajuan: this.safeValue(pengajuan.kodeAplikasiPengajuan),
            tanggalPengajuan: this.safeDate(pengajuan.tanggalPengajuan),
            channelPengajuan: this.safeValue(pengajuan.channelPengajuan),
            CUSTPRO: this.processCustProData(pengajuan.CUSTPRO),
            APPFLAG: this.processAppFlagData(pengajuan.APPFLAG)
        };
    }

    // Helper method to process CUSTPRO data
    processCustProData(custPro) {
        if (!Array.isArray(custPro) || custPro.length === 0) {
            return [{
                nomorKartuKredit: '-',
                nomorKartuKreditCensored: '-'
            }];
        }

        // return custPro.map(cust => ({
        //     nomorKartuKredit: this.safeValue(cust?.nomorKartuKredit)
        // }));

        return custPro.map(cust => {
            const cardNumber = this.safeValue(cust?.nomorKartuKredit);
            return {
                nomorKartuKredit: cardNumber,
                nomorKartuKreditCensored: this.censorCardNumber(cardNumber)
            };
        });
    }

    // Helper method to process APPFLAG data
    processAppFlagData(appFlag) {
        if (!Array.isArray(appFlag) || appFlag.length === 0) {
            return [{
                progresPengajuan: '-',
                Deskripsi: {
                    deskripsiPengajuan: '-'
                }
            }];
        }

        return appFlag.map(flag => ({
            progresPengajuan: this.safeValue(flag?.progresPengajuan),
            Deskripsi: {
                deskripsiPengajuan: this.safeValue(flag?.Deskripsi?.deskripsiPengajuan)
            }
        }));
    }
    
    // Helper method to get the first valid 'nomorKartuKredit' from CUSTPRO
    getNomorKartuKredit(dataPengajuan) {
        if (!Array.isArray(dataPengajuan)) return '-';

        for (const pengajuan of dataPengajuan) {
            // Check if CUSTPRO exists and is an array
            if (pengajuan?.CUSTPRO && Array.isArray(pengajuan.CUSTPRO)) {
                // Look for the first valid card number in CUSTPRO array
                for (const cust of pengajuan.CUSTPRO) {
                    const cardNumber = cust?.nomorKartuKredit;
                    // Only return if we find a non-empty card number
                    if (cardNumber && cardNumber.trim() !== '') {
                        return cardNumber.trim();
                    }
                }
            }
        }
        // Return '-' if no valid card number is found
        return '-';
    }

    // Format the card number by splitting into 4-digit blocks
    formatCardNumber(cardNumber) {
        const numStr = cardNumber.replace(/\D/g, ''); // Remove non-digit characters
        return numStr.match(/.{1,4}/g).join(' '); // Split into blocks of 4 digits
    }

    // Censor card number (after formatting, censor middle blocks)
    censorCardNumber(cardNumber) {
        
        // cardNumber = this.sanitizeField(cardNumber);
        
        if (!cardNumber || cardNumber === "-") return "-";
        
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