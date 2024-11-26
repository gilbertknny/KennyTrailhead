/** 
    LWC Name    : lwcDatakartuKreditComponent.js
    Created Date       : 11 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   11/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   27/09/2024   Rakeyan Nuramria                  Adjust to use API to get the data
    1.0   07/10/2024   Rakeyan Nuramria                  Adjust logic if the button data kartu being clicked when the data kartu is being open(bug because when click again it show undefined/change data)
    1.0   09/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show another fields
    1.0   23/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust bug for show different data in parent
    1.0   31/10/2024   Rakeyan Nuramria                  [FROM SIT] Add logic format number for nominal2
    1.0   04/11/2024   Rakeyan Nuramria                  [FROM SIT] Add logic format date & jenis kelamin to show data

**/

import { LightningElement, api, track, wire } from 'lwc';
import getCardLinkbyCardNumber from '@salesforce/apex/SCC_CaseBRICare.getCardLinkbyCardNumber';

export default class LwcDataKartuKreditComponent extends LightningElement {
    @api caseId;
    @api isCloseHidden;
    @api noKartu;
    @api noRekening;
    @api kartuData;

    @track selectedNomorKartu;

    @track cardInfo = {};

    @track data = [];
    @track customerData = [];
    @track cardData = [];
    @track additionalData = [];

    @track isLoading = false;
    @track hasError= false;
    @track errorMessage;
    @track errorMsg;

    //MAIN LOGIC
    connectedCallback(){
        console.log('nomor kartu from parent : ', this.noKartu);
        console.log('data kartu from parent : ', JSON.stringify(this.kartuData));
        this.selectedNomorKartu = this.noKartu;

        this.fetchDataCardlink();
        // this.processedData();

    }

    renderedCallback(){

    }

    fetchDataCardlink() {

        this.customerData = []; // Reset customerData
        this.cardData = [];     // Reset cardData
        this.additionalData = []; // Reset additionalData

        console.log('function fetchDataCardlink called..');

        this.isLoading = true;
    
        const requestPayload = {
            CardNumber : this.selectedNomorKartu, //add this if using getCardLinkbyCardNumber
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

                    this.processedData();

                    this.errorMsg = '';
                    this.hasError = false;
                    this.isLoading = false;
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                this.handleSearchError('An error occurred: ' + error.message);
            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });
    }

    processedData() {
        this.kartuData = this.data;

        if (this.kartuData && this.kartuData.length > 0) {
            const data = this.kartuData[0]; // Assuming we are working with the first record for customerData and additionalData
    
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

                this.cardData = data.cardData[0];
            }
    
            // Assuming additionalData is an array with one object
            if (data.additionalData && data.additionalData.length > 0) {
                this.additionalData = data.additionalData[0]; // Directly assign the first additional
            }
    
            // Consolidate data into cardInfo
            this.cardInfo = {
                // From customerData
                tanggalLahir: this.formatDateIndonesian(this.customerData.tanggalLahir) || 'N/A',
                noHandphone: this.customerData.nomorHandphoneTerdaftar || 'N/A',
                noKantor: this.customerData.nomorTelephoneKantor || 'N/A',
                noRumah: this.customerData.nomorTelephoneRumah || 'N/A',
                noKerabat: this.customerData.nomorTelephoneKerabatTidakSerumah || 'N/A',
                namaKerabat: this.customerData.namaKerabatTidakSerumah || 'N/A',
                noNIK: this.customerData.nomorNik || 'N/A',
                noNPWP: this.customerData.nomorNpwp || 'N/A',
                // jenisKelamin: this.customerData.jenisKelamin || 'N/A',
                jenisKelamin: this.customerData.jenisKelamin === '1' ? 'Laki - Laki' : this.customerData.jenisKelamin === '0' ? 'Perempuan' : 'N/A',
                jabatanKerja: this.customerData.jabatanKerja || 'N/A',
                sisaLimit: this.formatNumber(this.customerData.sisaLimitNasabah) || 'N/A',
                sisaLimitCicilan: this.formatNumber(this.customerData.sisaLimitCicilanNasabah) || 'N/A',
                limitCicilan: this.formatNumber(this.customerData.limitCicilanNasabah) || 'N/A',
                alamatBilling: this.customerData.alamatBilling || 'N/A',
                alamatEmail: this.customerData.alamatEmail || 'N/A',
                alamatPengirimanKartu: this.customerData.alamatPengirimanKartu || 'N/A', // This needs to be set properly
                alamatKantor: `${this.customerData.alamatKantorDepan}, ${this.customerData.alamatKantorTengah}, ${this.customerData.alamatKantorBelakang}`  || 'N/A',
                alamatRumah: `${this.customerData.alamatRumahDepan}, ${this.customerData.alamatRumahBelakang}`  || 'N/A',
                // From cardData
                alasanPemblokiran: this.cardData.alasanPemblokiran  || 'N/A',
                limitKartu: this.formatNumber(this.cardData.limitKartuKredit)  || 'N/A',
                // expiredKartu: this.cardData.expiredKartu  || 'N/A',
                expiredKartu: this.formatExpirationDate(this.cardData.expiredKartu)  || 'N/A',
                tglCetak: this.cardData.tanggalCetakCycle  || 'N/A',
                tglJatuhTempo: this.cardData.tanggalJatuhTempo  || 'N/A',
                nominalFullPayment: this.formatNumber(this.cardData.nominalFullPayment)  || 'N/A',
                // nominalMinPayment: this.cardData.nominalMinimumPayment  || 'N/A',
                nominalMinPayment: this.formatNumber(this.cardData.nominalMinimumPayment)  || 'N/A',
                nominalTagihanBerjalan: this.formatNumber(this.cardData.nominalTagihanBerjalan)  || 'N/A',
                nominalPembayaranTerakhir: this.formatNumber(this.cardData.nominalPembayaranTerakhir)  || 'N/A',
                noKartu: this.cardData.customerNumber  || 'N/A',
                namaCetak: this.cardData.namaCetakKartu  || 'N/A',
                // tglTerkahirMaintenance: this.cardData.tanggalTerakhirMaintenanceKartu  || 'N/A',
                tglTerkahirMaintenance: this.formatDateIndonesian(this.cardData.tanggalTerakhirMaintenanceKartu)  || 'N/A',
                noRekening: this.cardData.noRekening  || 'N/A',
                // From additionalData
                nominalGaji: this.formatNumber(this.additionalData.nominalPendapatanPerBulan)  || 'N/A',
                namaIbuKandung: this.additionalData.namaLengkapIbuKandung  || 'N/A',
            };
        }
    }

    handleCloseDataKartu() {
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        this.handleClear();
        this.dispatchEvent(closeEvent);
    }

    @api handleClear() {
        // this.noKartu = '';
        // this.noRekening = '';

        this.isLoading = false;
        this.errorMsg = '';
        this.hasError = false;

    }

    @api updateCardDetails() {
        // Only update if the card number is different
        // if (this.noKartu && this.noKartu !== this.selectedNomorKartu) {
        //     this.selectedNomorKartu = this.noKartu;
        //     this.fetchDataCardlink(); // Fetch new card details
        // }

        // Only update if the card number is different
        if (this.noKartu && this.noKartu !== this.selectedNomorKartu) {
            this.selectedNomorKartu = this.noKartu;
            console.log(`Fetching data for new card number: ${this.selectedNomorKartu}`);
            this.fetchDataCardlink(); // Fetch new card details
        }
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.cardInfo = {};
        this.data = [];
        this.customerData = [];
        this.cardData = [];
        this.additionalData = [];
        this.isLoading = false;
        console.log('Error Message:', errorMessage);
    }

    //END MAIN LOGIC

    //MISC
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
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

    formatDateIndonesian(dateString) {
        // Ensure the date string is at least 8 characters long
        // If it's shorter, pad it with leading zeros
        const paddedDateString = dateString.padStart(8, '0');
    
        const year = paddedDateString.slice(0, 4);
        let month = parseInt(paddedDateString.slice(4, 6), 10) - 1; // Convert to zero-based month
        let day = parseInt(paddedDateString.slice(6, 8), 10); // Convert to integer for day
    
        // Check if month or day is invalid
        if (month < 0 || month > 11 || day < 1 || day > 31) {
            return `Tanggal tidak valid: ${dateString}`; // Invalid
        }

        // Create a Date object
        const date = new Date(year, month, day);

        // Check if the created date is valid
        if (date.getFullYear() != year || date.getMonth() != month || date.getDate() != day) {
            return `Tanggal tidak valid: ${dateString}`; // Invalid
        }
            
    
        // Define an array of month names in Indonesian
        const monthNames = [
            "Januari", "Februari", "Maret", "April", "Mei", "Juni",
            "Juli", "Agustus", "September", "Oktober", "November", "Desember"
        ];
    
        // Format the date as needed
        return `${day} ${monthNames[month]} ${year}`;
    }

    formatExpirationDate(dateString) {
        if (dateString && dateString.length === 4) {
            return `${dateString.slice(0, 2)}/${dateString.slice(2)}`;
        }
        return '';
    }
}