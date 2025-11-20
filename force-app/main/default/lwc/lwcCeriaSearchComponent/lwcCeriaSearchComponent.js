/** 
    LWC Name           : lwcCeriaSearchComponent.js
    Created Date       : 09 Januari 2025
    @description       : This is class for logic search data ceria
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    Release 3
    1.0   09/01/2025   Rakeyan Nuramria                  Initial Version
    1.0   22/01/2025   Rakeyan Nuramria                  Add API Functionality
    1.0   23/01/2025   Rakeyan Nuramria                  Adjust error handling
    1.0   04/02/2025   Rakeyan Nuramria                  [FROM SIT] Add validation for nomor rekening & Mapping field history
    1.0   03/03/2025   Rakeyan Nuramria                  Adjust validation for nomor rekening == ceriaId based on feedback UAT
**/

import { LightningElement, api, track } from 'lwc';
import getCeria from '@salesforce/apex/SCC_CaseBRICare.getCeria';

export default class LwcCeriaSearchComponent extends LightningElement {
    activeSections = ['dataDiri', 'dataDetail'];

    @api caseId;
    @api recordId;

    @track nomorRekening = '';
    @track nik = '';

    @track showResult = false;
    @track showDetail = false;
    @track showHistoryPembayaran = false;
    @track showDataTransaksi = false;

    @track disableNomorRekeningField = false;
    @track disableNikField = false;

    @track isLoading = false;
    @track hasError = false;
    @track hasErrorTransaksi = false;
    @track hasTransactions = false;
    @track hasNoTransactions = false;
    @track hasResult = false;
    @track hasInputError = false; // Utilized to keep the search button state inline if there's an input error

    // Data placeholders
    @track ceriaData = [];
    @track detailData = {};
    @track historyData = [];
    @track transactionData = [];

    @track currentDetailData = {}; // To hold the processed data
    @track currentHistoryData = {}; // To hold the processed data

    errorMsg = '';
    errorMessage = '';
    nikError = '';
    nomorRekeningError = '';

    scrollToDetail = false;
    scrollToHistory = false;
    scrollToTransaction = false;

    mockupResponse = {
        "CERIA_MASTER_DATA": [
            {
                "ceriaId": "1895121000001732",
                "noHP": "087772839705",
                "nama": "AGUS RIYADI",
                "tanggalPembukaanRekening": "2020-01-02 17:00:00",
                "sisaOutstanding": "0.0000",
                "sisaLimit": "20000000.0000",
                "tanggalPenerbitanBilling": "2024-08-08 17:00:00",
                "tanggalJatuhTempo": "2024-08-25",
                "nominalPembayaranTerakhir": "103230.0000",
                "tanggalPembayaranTerakhir": "2024-08-14 17:00:00",
                "nominalTagihan": "103230.0000",
                "statusKolektibilitas": "1.0",
                "blockCodeKolektibilitas": "WW",
                "blockCodeSystem": "QQ",
                "metodeBayar": "AUTODEBET",
                "nomorRekeningPendebetan": "207401009872508",
                "status": "AKTIF",
                "remarks": null,
                "referenceNumberPembayaranTerakhir": "1723717895993",
                "statusPembayaranTagihan": "SUCCESS_FUND_TRANSFER",
                "transactionData": [
                    {
                        "reffNum": "3f7df995a7a9c989",
                        "tanggalTrx": "2023-08-24 17:00:00",
                        "nominalTransaksi": "1000000.0000",
                        "namaMerchant": "CASHOUT BRI",
                        "jenisTransaksi": "cashout",
                        "tenorCicilan": "12",
                        "sisaBulanCicilan": null,
                        "rincianPembayaran": null,
                        "statusTransaksi": "success"
                    },
                    {
                        "reffNum": "41ce6af0db61885c",
                        "tanggalTrx": "2023-02-03 17:00:00",
                        "nominalTransaksi": "4200000.0000",
                        "namaMerchant": "CASHOUT BRI",
                        "jenisTransaksi": "cashout",
                        "tenorCicilan": "12",
                        "sisaBulanCicilan": null,
                        "rincianPembayaran": null,
                        "statusTransaksi": "success"
                    }
                ]
            },
            {
                "ceriaId": "1895121000001738",
                "noHP": "087772839705",
                "nama": "AGUS RIYADI",
                "tanggalPembukaanRekening": "2020-01-02 18:00:00",
                "sisaOutstanding": "10.0000",
                "sisaLimit": "10000000.0000",
                "tanggalPenerbitanBilling": "2024-08-08 18:00:00",
                "tanggalJatuhTempo": "2024-08-25",
                "nominalPembayaranTerakhir": "103230.0000",
                "tanggalPembayaranTerakhir": "2024-08-14 18:00:00",
                "nominalTagihan": "103230.0000",
                "statusKolektibilitas": "2.0",
                "blockCodeKolektibilitas": "Q",
                "blockCodeSystem": "B",
                "metodeBayar": "AUTODEBET",
                "nomorRekeningPendebetan": "207401009872508",
                "status": "AKTIF",
                "remarks": null,
                "referenceNumberPembayaranTerakhir": "1723717895993",
                "statusPembayaranTagihan": "SUCCESS_FUND_TRANSFER",
                "transactionData": [
                    
                ]
            }
        ]
    }

    renderedCallback() {
        //for focus to the content
        if (this.scrollToDetail) {
            this.scrollToComponent('scrollable-detail-container', 'data-detail-component');
            this.scrollToDetail = false;
        }

        if (this.scrollToHistory) {
            this.scrollToComponent('scrollable-history-container', 'data-history-component');
            this.scrollToHistory = false;
        }

        if (this.scrollToTransaction) {
            this.scrollToComponent('scrollable-transaksi-container', 'data-transaksi-component');
            this.scrollToTransaction = false;
        }
        //end for focus to the content
    
    }

    get isSearchDisabled() {
        return!!this.errorMsg || 
                !!this.nikError ||
                !!this.nomorRekeningError
                    || 
                        !(this.nomorRekening||this.nik);
    }

    disableFields(disable) {
        this.disableNomorRekeningField = disable;
        this.disableNikField = disable;
    }

    handleNomorRekeningChange(event) {
        // this.clearErrorsAndResults();
        this.nomorRekening = event.target.value.trim();
        this.nik = '';
        this.validateAccountNumber();
        this.toggleFields('NomorRekening');
        if (!this.nomorRekening) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    }

    handleNikChange(event) {
        // this.clearErrorsAndResults();
        this.nik = event.target.value.trim();
        this.nomorRekening = '';
        this.validateNIKNumber();
        this.toggleFields('NIK');
        if (!this.nik) {
            this.clearInputFields();
            this.clearErrorsAndResults();
        }
    
    }

    toggleFields(inputField) {
        if (inputField === 'NomorRekening') {
            this.disableNikField = !!this.nomorRekening;
        } else if (inputField === 'NIK') {
            this.disableNomorRekeningField = !!this.nik;
        }
    }

    handleSearch() {
        // if (!this.disableSearchButton) {

        console.log('handleSearch Ceria called..');
            
        this.fetchDataCeria();
        // this.showResult = true;

        // }
    }

    /** 
    fetchDataCeria(){
        console.log('fetchDataCeria called..');

        this.isLoading = true;
        this.hasError = false;
        this.errorMsg = '';

        const requestPayload = {
            idNumber: this.nik,
            acctNo: this.nomorRekening
        };

        const recId = this.recordId || this.caseId;

        console.log('request ceria payload : ', JSON.stringify({ req: requestPayload, recid: recId }));

        getCeria({ req: requestPayload, recid: recId })
            .then(response => {
                console.log('API Ceria Response:', JSON.stringify(response, null, 2));
                this.isLoading = false;
            })
            .catch(error => {
                console.error('API Ceria Error:', error);
                this.handleError('Terjadi kesalahan saat mengambil data.');
                this.isLoading = false;
            });

    }
    */

    // Mock function simulating API response
    simulateApiCallWithMockupResponse() {
        return new Promise((resolve, reject) => {
            // Simulate a delay like an actual API call
            setTimeout(() => {
                // Use the mockupResponse directly here
                const mockResponse = this.mockupResponse;
                resolve(mockResponse); // Return mock data as if it came from the API
            }, 1000); // Simulate a delay of 1 second
        });
    }

    fetchDataCeria(){
        console.log('fetchDataCeria called..');

        this.isLoading = true;
        this.hasError = false;
        this.errorMsg = '';

        const requestPayload = {
            idNumber: this.nik,
            acctNo: this.nomorRekening
        };

        const recId = this.recordId || this.caseId;

        console.log('request ceria payload : ', JSON.stringify({ req: requestPayload, recid: recId }));

        // Simulate API call with mockupResponse instead of the real API
        // this.simulateApiCallWithMockupResponse()

        getCeria({ req: requestPayload, recid: recId })
            .then(result => {
                console.log('API Ceria Response:', JSON.stringify(result, null, 2));
                
                if(result){
                    const responseCeria = result?.CERIA_MASTER_DATA;
                    console.log('response ceria : ', responseCeria);
                    this.isLoading = false;
                    this.hasResult = true;
                    
                    if(responseCeria && responseCeria.length > 0){
                        this.ceriaData = responseCeria.map(item => ({
                            ...item,
                            periode: item.periode ? item.periode.trim() : '-'
                        }));

                        this.showResult = true;

                        console.log('Formatted responseCeria Data:', JSON.stringify(this.ceriaData));

                    } else {
                        this.handleError('Data tidak ditemukan');
                    }
                

                } else {
                    this.handleError('Data tidak ditemukan');
                }


            })
            .catch(error => {
                console.error('API Ceria Error:', error.message);
                this.handleError('Terjadi kesalahan saat mengambil data.');
                this.showResult = false;

            })
            .finally(() => {
                this.isLoading = false;
                console.log('Loading state set to false.');
            });

    }

    // processDetailData(event) {
    //     console.log('processDetailData called..');
    
    //     const ceriaId = event.target.dataset.id;
    //     console.log('ceriaId : ', ceriaId);
    
    //     const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
    
    //     if (selectedData) {
    //         // Set showSection for each data item
    //         this.ceriaData.forEach(data => {
    //             data.showSection = data.ceriaId === ceriaId;
    //         });
    
    //         // Process data: replace null, empty, 'NULL', 'null', or undefined values with "N/A"
    //         this.currentDetailData = Object.fromEntries(
    //             Object.entries(selectedData).map(([key, value]) => {
    //                 // If value is null, empty, 'NULL', 'null', or undefined, replace with 'N/A'
    //                 return [key, (value === null || value === '' || value === 'NULL' || value === 'null' || value === undefined) ? 'N/A' : value];
    //             })
    //         );

    //         // Handle missing keys by setting them to "N/A" if not present
    //         Object.keys(selectedData).forEach(key => {
    //             if (!(key in this.currentDetailData)) {
    //                 this.currentDetailData[key] = 'N/A';
    //             }
    //         });
    
    //         this.showDetail = true;
    //         console.log('Detail data to show:', JSON.stringify(this.currentDetailData));  // Ensure you use `this.currentDetailData` here
    //     } else {
    //         console.log('No data found for the provided ceriaId.');
    //         this.showDetail = false;
    //     }
    // }

    /** 
    processDetailData(event) {
        console.log('processDetailData called..');
    
        const ceriaId = event.target.dataset.id;
        console.log('ceriaId : ', ceriaId);
    
        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
    
        if (selectedData) {
            // Set showSection for each data item
            this.ceriaData.forEach(data => {
                data.showSection = data.ceriaId === ceriaId;
            });
    
            // Process data: replace null, empty, 'NULL', 'null', or undefined values with "N/A"
            this.currentDetailData = Object.fromEntries(
                Object.entries(selectedData).map(([key, value]) => {
                    // If value is null, empty, 'NULL', 'null', or undefined, replace with 'N/A'
                    return [key, (value === null || value === '' || value === 'NULL' || value === 'null' || value === undefined) ? 'N/A' : value];
                })
            );
    
            // Ensure that all keys that should exist in currentDetailData (based on selectedData) return "N/A" if not present
            const expectedKeys = Object.keys(selectedData); // You can modify this if you have a set of expected keys
            expectedKeys.forEach(key => {
                if (!(key in this.currentDetailData)) {
                    this.currentDetailData[key] = 'N/A';
                }
            });
    
            this.showDetail = true;
            console.log('Detail data to show:', JSON.stringify(this.currentDetailData));  // Ensure you use `this.currentDetailData` here
        } else {
            console.log('No data found for the provided ceriaId.');
            this.showDetail = false;
        }
    }
    */

    processDetailData(event) {
        console.log('processDetailData called..');
      
        const ceriaId = event.target.dataset.id;
        console.log('ceriaId : ', ceriaId);
      
        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
    
        console.log('selectedData: ', JSON.stringify(selectedData));
    
        // If no matching data found, exit early
        if (!selectedData) {
            console.error('No matching data found for ceriaId: ', ceriaId);
            return;
        }
      
        // Set showSection for each data item
        this.ceriaData.forEach(data => {
            data.showSection = data.ceriaId === ceriaId;
        });
      
        // Update currentDetailData with the fields you want to show in the detail view
        this.currentDetailData = {
            tanggalPenerbitanBilling: selectedData.tanggalPenerbitanBilling ? selectedData.tanggalPenerbitanBilling.trim() : 'N/A',
            tanggalJatuhTempo: selectedData.tanggalJatuhTempo ? selectedData.tanggalJatuhTempo.trim() : 'N/A',
            nominalTagihan: selectedData.nominalTagihan ? selectedData.nominalTagihan.trim() : 'N/A',
            statusKolektibilitas: selectedData.statusKolektibilitas ? selectedData.statusKolektibilitas.trim() : 'N/A',
            tanggalHoldTerakhir: selectedData.tanggalHoldTerakhir ? selectedData.tanggalHoldTerakhir.trim() : 'N/A',
            nominalHold: selectedData.nominalHold ? selectedData.nominalHold.trim() : 'N/A',
            tanggalPembayaranTerakhir: selectedData.tanggalPembayaranTerakhir ? selectedData.tanggalPembayaranTerakhir.trim() : 'N/A',
            nominalPembayaranTerakhir: selectedData.nominalPembayaranTerakhir ? selectedData.nominalPembayaranTerakhir.trim() : 'N/A',
            blockCodeKolektibilitas: selectedData.blockCodeKolektibilitas ? selectedData.blockCodeKolektibilitas.trim() : 'N/A',
            blockCodeSystem: selectedData.blockCodeSystem ? selectedData.blockCodeSystem.trim() : 'N/A'
        };
      
        this.showDetail = true;
        console.log('Detail data to show:', JSON.stringify(this.currentDetailData));  
    }
    

    processHistoryData(event) {
        console.log('processHistoryData called..');
      
        const ceriaId = event.target.dataset.id;
        console.log('ceriaId : ', ceriaId);
      
        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);

        console.log('selectedData: ', JSON.stringify(selectedData));

        // If no matching data found, exit early
        if (!selectedData) {
            console.error('No matching data found for ceriaId: ', ceriaId);
            return;
        }
      
        if (selectedData) {

            // Set showHistorySection for each data item
            this.ceriaData.forEach(data => {
                data.showHistorySection = data.ceriaId === ceriaId;

            });
      
            // Update currentHistoryData with the fields you want to show in the history table
            this.currentHistoryData = {
                ceriaId: selectedData.ceriaId ? selectedData.ceriaId.trim() : '-',
                tanggalPembayaranTerakhir: selectedData.tanggalPembayaranTerakhir ? selectedData.tanggalPembayaranTerakhir.trim() : '-',
                metodeBayar: selectedData.metodeBayar ? selectedData.metodeBayar.trim() : '-',
                nominalPembayaranTerakhir: selectedData.nominalPembayaranTerakhir ? selectedData.nominalPembayaranTerakhir.trim() : '-',
                nomorRekeningPendebetan: selectedData.nomorRekeningPendebetan ? selectedData.nomorRekeningPendebetan.trim() : '-',
                status: selectedData.status ? selectedData.status.trim() : '-',
                remarks: selectedData.remarks ? selectedData.remarks.trim() : '-',
                referenceNumberPembayaranTerakhir: selectedData.referenceNumberPembayaranTerakhir ? selectedData.referenceNumberPembayaranTerakhir.trim() : '-'
            };
      
            this.showHistoryPembayaran = true;
            console.log('History data to show:', JSON.stringify(this.currentHistoryData));  
        } else {
            console.log('No data found for the provided ceriaId.');
            this.showHistoryPembayaran = false;
        }
    }

    processTransactionData(event) {
        console.log('processTransactionData called..');
    
        // Get ceriaId from the event
        const ceriaId = event.target.dataset.id;
        console.log('ceriaId : ', ceriaId);
    
        // Find the selected data object based on ceriaId
        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
    
        console.log('selectedData: ', JSON.stringify(selectedData));
    
        // If no matching data found, exit early
        if (!selectedData || !selectedData.transactionData) {
            console.error('No matching transaction data found for ceriaId: ', ceriaId);
            this.showDataTransaksi = false; // Ensure the transaction section is hidden if no data is found
            return;
        }

        if (selectedData) {

            // Set showHistorySection for each data item
            this.ceriaData.forEach(data => {
                data.showTransactionSection = data.ceriaId === ceriaId;

            });
    
            // Process the transaction data
            const transactions = selectedData.transactionData.map(transaction => {
                return {
                    llaId: transaction.llaId ? transaction.llaId : '-',
                    reffNum: transaction.reffNum ? transaction.reffNum : '-',
                    tanggalTrx: transaction.tanggalTrx ? transaction.tanggalTrx.trim() : '-',
                    nominalTransaksi: transaction.nominalTransaksi ? transaction.nominalTransaksi.trim() : '-',
                    namaMerchant: transaction.namaMerchant ? transaction.namaMerchant : '-',
                    jenisTransaksi: transaction.jenisTransaksi ? transaction.jenisTransaksi : '-',
                    tenorCicilan: transaction.tenorCicilan ? transaction.tenorCicilan : '-',
                    sisaBulanCicilan: transaction.sisaBulanCicilan ? transaction.sisaBulanCicilan : '-',
                    rincianPembayaran: transaction.rincianPembayaran ? transaction.rincianPembayaran : '-',
                    statusTransaksi: transaction.statusTransaksi ? transaction.statusTransaksi : '-',
                    sisaTagihan: transaction.sisaTagihan ? transaction.sisaTagihan : '-',
                };
            });
        
            // Set the processed transaction data to be displayed
            this.transactionData = transactions;
        
            // Show the transaction section
            this.showDataTransaksi = true;
            console.log('Transaction data to show:', JSON.stringify(this.transactionData));
        }
    }

    

    handleDetailAction(event){
        this.processDetailData(event);
        this.scrollToDetail = true;

    }

    handleHistoryPembayaranAction(event){
        this.processHistoryData(event);
        this.scrollToHistory = true;
        // this.showHistoryPembayaran = true;
    }

    handleDataTransaksiAction(event){
        this.processTransactionData(event);
        this.scrollToTransaction = true;

       
    }

    handleCloseDetail(event){
        console.log('handleCloseDetail called..');
        const ceriaId = event.target.dataset.id;

        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
        if (selectedData) {
            console.log('if handleCloseDetail called..');
            selectedData.showSection = false; // Hide the detail section
        }

        // Reassign data to trigger reactivity
        this.ceriaData = [...this.ceriaData]; // This helps in re-rendering the component

        // Optionally, if want to hide all detail sections
        // this.data.forEach(item => item.showSection = false);

    }

    handleCloseHistoryPembayaran(event){
        console.log('handleCloseDetail called..');
        const ceriaId = event.target.dataset.id;

        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
        if (selectedData) {
            console.log('if handleCloseDetail called..');
            selectedData.showHistorySection = false; // Hide the detail section
        }

        // Reassign data to trigger reactivity
        this.ceriaData = [...this.ceriaData]; // This helps in re-rendering the component

        // Optionally, if want to hide all detail sections
        // this.data.forEach(item => item.showSection = false);
    }

    handleCloseDataTransaksi(event){
        console.log('handleCloseDetail called..');
        const ceriaId = event.target.dataset.id;

        const selectedData = this.ceriaData.find(item => item.ceriaId === ceriaId);
        if (selectedData) {
            console.log('if handleCloseDetail called..');
            selectedData.showTransactionSection = false; // Hide the detail section
        }

        // Reassign data to trigger reactivity
        this.ceriaData = [...this.ceriaData]; // This helps in re-rendering the component

        // Optionally, if want to hide all detail sections
        // this.data.forEach(item => item.showSection = false);
    }

    validateNIKNumber() {
        if (this.nik) {
            const regex = /^\d{16}$/; // Regex for exactly 16 digits
            if (!regex.test(this.nik)) {
                this.nikError = 'NIK harus memiliki 16 digit angka.';
            } else {
                this.nikError = '';
            }
        } else {
            this.nikError = ''; 
        }
    }

    validateAccountNumber() {
        if (this.nomorRekening) {
            // const regex = /^\d{15,18}$/; // Regex for 15-18 digits
            const regex = /^\d{16}$/; // v2, Regex for exactly 16 digits using label "Ceria ID"
            if (!regex.test(this.nomorRekening)) {
                // this.nomorRekeningError = 'Nomor Rekening harus memiliki 15-18 digit angka.';
                this.nomorRekeningError = 'Ceria ID harus memiliki 16 digit angka.';
            } else {
                this.nomorRekeningError = '';
            }
        } else {
            this.nomorRekeningError = ''; 
        }
    }

    // clearData() {
    //     this.data = [];
    //     this.errorMsg = '';
    //     this.nikError = '';
    // }

    // Handle error messages
    handleError(message) {
        this.hasError = true;
        this.errorMsg = message;
        this.isLoading = false;
        this.ceriaData = [];
        console.error('Error Ceria Message:', this.errorMsg);
    }

    clearErrorsAndResults() {
        this.errorMsg = '';
        this.nikError = '';
        this.nomorRekeningError = '';
        this.ceriaData = [];
        this.transactionData = [];
        this.currentDetailData = {};
        this.currentHistoryData = {};
        this.hasError = false;
        this.showResult = false;

    }

    clearInputFields() {
        this.nomorRekening = '';
        this.nik = '';
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