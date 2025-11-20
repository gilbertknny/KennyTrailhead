/** 
    LWC Name    : lwcWholeSaleSearchComponent.js
    Created Date       : 16 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   16/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   27/09/2024   Rakeyan Nuramria                  [FROM SIT] Bug fixing for Toast & remove 31 days validation (adding import)
    1.0   30/09/2024   Rakeyan Nuramria                  Fix fetch API & Show data
    1.0   31/09/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show format nominal number

**/


import { LightningElement, api, wire, track } from 'lwc';
import getDomainBrimola from '@salesforce/apex/SCC_GetDomainBrimolaOnCase.getDomainBrimola';
import getWholeSaleBRIMola from '@salesforce/apex/SCC_CaseBRICare.getWholeSaleBRIMola';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LwcWholeSaleSearchComponent extends LightningElement {
    @api caseId;
    @track disableSearchButton = true;
    @track idPangkalan = '';
    @track startDate = this.getTodayDate();
    @track endDate = this.getTodayDate();
    @track hasParsedData = false;
    @track isLoading = false;
    @track hasError = false;
    @track hasErrorTrx = false;
    @track errorMsg = '';
    
    @track parsedData;
    @track inqueryTableData;
    error;
    errorMessage;

    // Dummy data
    dummyParsedData = {
        agenName: 'Agen A',
        pangkalanName: 'Pangkalan A',
        agenId: 'AgenID001',
        agenAlamat: 'Alamat A',
        pangkalanId: 'IDP001',
        agenNorek: '1234567890',
        corpBriva: 'Corp A',
        corpClientBriva: 'Client Corp A'
    };

    dummyInqueryTableData = [
        { orderId: 'ORD001', jenisPembayaran: 'Tunai', noBriva: 'BRIVA001', agenName: 'Agen A', pangkalanName: 'Pangkalan A', jumlahTabung: 10, hargaTabung: 100000, totalHarga: 1000000, biayaAdmin: 10000, statusBayar: 'Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD002', jenisPembayaran: 'Kartu Kredit', noBriva: 'BRIVA002', agenName: 'Agen B', pangkalanName: 'Pangkalan B', jumlahTabung: 5, hargaTabung: 150000, totalHarga: 750000, biayaAdmin: 7500, statusBayar: 'Belum Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD003', jenisPembayaran: 'Transfer', noBriva: 'BRIVA003', agenName: 'Agen C', pangkalanName: 'Pangkalan C', jumlahTabung: 8, hargaTabung: 120000, totalHarga: 960000, biayaAdmin: 9600, statusBayar: 'Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD004', jenisPembayaran: 'Tunai', noBriva: 'BRIVA004', agenName: 'Agen D', pangkalanName: 'Pangkalan D', jumlahTabung: 7, hargaTabung: 110000, totalHarga: 770000, biayaAdmin: 7700, statusBayar: 'Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD005', jenisPembayaran: 'Kartu Kredit', noBriva: 'BRIVA005', agenName: 'Agen E', pangkalanName: 'Pangkalan E', jumlahTabung: 12, hargaTabung: 130000, totalHarga: 1560000, biayaAdmin: 15600, statusBayar: 'Belum Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD006', jenisPembayaran: 'Transfer', noBriva: 'BRIVA006', agenName: 'Agen F', pangkalanName: 'Pangkalan F', jumlahTabung: 6, hargaTabung: 140000, totalHarga: 840000, biayaAdmin: 8400, statusBayar: 'Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD007', jenisPembayaran: 'Tunai', noBriva: 'BRIVA007', agenName: 'Agen G', pangkalanName: 'Pangkalan G', jumlahTabung: 9, hargaTabung: 125000, totalHarga: 1125000, biayaAdmin: 11250, statusBayar: 'Belum Lunas', tanggalOrder: '2024-09-16' },
        { orderId: 'ORD008', jenisPembayaran: 'Kartu Kredit', noBriva: 'BRIVA008', agenName: 'Agen H', pangkalanName: 'Pangkalan H', jumlahTabung: 11, hargaTabung: 105000, totalHarga: 1155000, biayaAdmin: 11550, statusBayar: 'Lunas', tanggalOrder: '2024-09-16' }
    ];

    connectedCallback() {
        console.log('case Id in WholeSale : ' , this.caseId);
    }

    // fetchDataWholeSale() {
    //     console.log('function fetchDataWholeSale called..');
    //     this.isLoading = true;
    
    //     const requestPayload = {
    //         idPangkalan: this.idPangkalan,
    //         startDate: this.startDate,
    //         endDate: this.endDate,
    //         idcs: this.caseId
    //     };
    
    //     console.log('Request WholeSale payload:', JSON.stringify(requestPayload));
    
    //     getWholeSaleBRIMola(requestPayload)
    //     .then(result => {
    //         console.log('Response result WholeSale received:', result);
    //         console.log('Response result WholeSale received:', JSON.stringify(result));
    
    //         if (result) {
    //             const responseAgen = result?.chmGraphql?.inquiryBrimolaPangkalan?.data;
    //             console.log('responseAgen ', responseAgen);
    //             this.errorMsg = '';
    //             this.hasError = false;
    //             this.isLoading = false;
    //             this.hasParsedData  = true;
    
    //             // Process responseAgen data
    //             if (responseAgen) {
    //                 this.parsedData = responseAgen.map(item => ({
    //                     ...item,
    //                     // Additional formatting if needed
    //                 }));
                    
    //                 console.log('Formatted responseAgen Data:', JSON.stringify(this.parsedData));
    
    //                 // Now handle responseTrxAgen for each agent
    //                 const trxData = responseAgen.reduce((acc, item) => {
    //                     const transactions = item.BrilinkTrxByIdKeagenan?.data || [];
    //                     return acc.concat(transactions);
    //                 }, []);
    
    //                 if (trxData.length > 0) {
    //                     this.inqueryTableData = trxData.map(item => ({
    //                         ...item,
    //                         // Additional formatting if needed
    //                     }));
    
    //                     console.log('Formatted responseTrxAgen Data:', JSON.stringify(this.inqueryTableData));
    //                 } else {
    //                     this.handleSearchError('Data transaksi tidak ditemukan');
    //                 }
    //             } else {
    //                 this.handleSearchError('Data tidak ditemukan');
    //             }
    //         } else {
    //             this.handleSearchError('Data tidak ditemukan');
    //         }
    //     })
    //     .catch(error => {
    //         console.error('Error occurred during search WholeSale:', error.message);
    //         this.handleSearchError('Data tidak ditemukan');
    //     })
    //     .finally(() => {
    //         this.isLoading = false;
    //         console.log('Loading state set to false.');
    //     });
    // }

    fetchDataWholeSale() {
        console.log('function fetchDataWholeSale called..');
        this.isLoading = true;
    
        const requestPayload = {
            idPangkalan: this.idPangkalan,
            startDate: this.startDate,
            endDate: this.endDate,
            idcs: this.caseId
        };
    
        console.log('Request WholeSale payload:', JSON.stringify(requestPayload));
    
        getWholeSaleBRIMola(requestPayload)
        .then(result => {
            console.log('Response result WholeSale received:', result);
            console.log('Response result WholeSale received:', JSON.stringify(result));
    
            if (result) {
                const responseAgen = result?.chmGraphql?.inquiryBrimolaPangkalan?.data;
                console.log('responseAgen ', responseAgen);
                this.errorMsg = '';
                this.hasError = false;
                this.isLoading = false;
                this.hasParsedData = true;
    
                // Process responseAgen data
                if (responseAgen) {
                    // Map the agent data to the desired format
                    this.parsedData = {
                        agenAlamat: responseAgen.agenAlamat,
                        agenId: responseAgen.agenId,
                        agenName: responseAgen.agenName,
                        agenNorek: responseAgen.agenNorek,
                        pangkalanId: responseAgen.pangkalanId,
                        pangkalanName: responseAgen.pangkalanName,
                        corpBriva: responseAgen.corpBriva,
                        corpClientBriva: responseAgen.corpClientBriva,
                    };
    
                    console.log('Formatted responseAgen Data:', JSON.stringify(this.parsedData));
    
                    // Now handle responseTrxAgen
                    const trxData = responseAgen.BrilinkTrxByIdKeagenan?.data || [];
    
                    if (trxData.length > 0) {
                        this.inqueryTableData = trxData.map(item => ({
                            agenName: item.agenName,
                            biayaAdmin: this.formatNumber(item.biayaAdmin),
                            hargaTabung: this.formatNumber(item.hargaTabung),
                            jenisPembayaran: item.jenisPembayaran,
                            jumlahTabung: item.jumlahTabung,
                            noBriva: item.noBriva,
                            orderId: item.orderId,
                            pangkalanName: item.pangkalanName,
                            statusBayar: item.statusBayar,
                            tanggalOrder: item.tanggalOrder,
                            totalHarga: this.formatNumber(item.totalHarga),
                        }));
    
                        console.log('Formatted responseTrxAgen Data:', JSON.stringify(this.inqueryTableData));
                    } else {
                        this.handleSearchTrxError('Data transaksi kosong.');
                    }
                } else {
                    this.handleSearchTrxError('Data tidak ditemukan');
                }
            } else {
                this.handleSearchTrxError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error occurred during search WholeSale:', error.message);
            this.handleSearchError('Data tidak ditemukan');
        })
        .finally(() => {
            this.isLoading = false;
            console.log('Loading state set to false.');
        });
    }
    

    getTodayDate() {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}`;
    }

    handleIdPangkalanChange(event){
        this.idPangkalan = event.target.value;
        this.handleInputChange();
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.validateDateRange();
        this.handleInputChange();

    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.validateDateRange();
        this.handleInputChange();

    }

    handleInputChange(){
        // Check if all input fields have values
        if (this.idPangkalan && this.startDate && this.endDate) {
            this.disableSearchButton = false;
        } else {
            this.disableSearchButton = true;
        }
    }

    validateDateRange() {
        const today = this.getTodayDate();
        
        if (this.startDate > today) {
            this.showToast('Error', 'Tanggal Awal tidak boleh melebihi hari ini.', 'error');
            this.disableSearchButton = true;
            this.startDate = today;
        }

        // if (this.endDate > today) {
        //     this.showToast('Error', 'Tanggal Akhir tidak boleh melebihi hari ini.', 'error');
        //     this.disableSearchButton = true;
        //     this.endDate = today; 
        // }
    }

    // handleSearch(){
    //     getDomainBrimola({ idPangkalan: this.idPangkalan, startDate: this.startDate, endDate: this.endDate })
    //     .then((result) => {
    //         if (result.errorMessage == 'No Error') {
    //             this.parsedData = result;
    //             this.inqueryTableData = result.data;
    //             this.errorMessage = '';
    //         } else {
    //             this.errorMessage = 'Data tidak ditemukan.';
    //             this.parsedData = undefined;
    //         }
    //         this.idPangkalan = '';
    //         this.startDate = '';
    //         this.endDate = '';
    //         this.error = undefined;
    //         this.disableSearchButton = true;
    //     })
    //     .catch((error) => {
    //         this.error = error;
    //         this.parsedData = undefined;
    //     });
    // }

    // Using dummy data
    handleSearch(){

        this.fetchDataWholeSale();
        // this.parsedData = this.dummyParsedData;
        // this.inqueryTableData = this.dummyInqueryTableData;
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.parsedData = null;
        this.isLoading = false;
        console.log('Error Message:', errorMessage);
    }
    handleSearchTrxError(errorMessage) {
        this.hasErrorTrx = true;
        this.errorMsg = errorMessage;
        this.inqueryTableData = null;
        this.isLoading = false;
        console.log('Error Message:', errorMessage);
    }

    clearInputFields(){
        this.errorMessage = '';
        this.idPangkalan = '';
        this.startDate = '';
        this.endDate = '';
        this.error = undefined;
        this.disableSearchButton = true;
    }

    // get hasParsedData() {
    //     return Array.isArray(this.parsedData) && this.parsedData.length > 0;
    // }

    formatCurrency(value) {
        const formatter = new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        });
        return formatter.format(value);
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

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

}