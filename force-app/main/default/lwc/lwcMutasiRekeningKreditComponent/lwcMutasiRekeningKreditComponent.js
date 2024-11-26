/** 
    LWC Name    : lwcMutasiRekeningKreditComponent.js
    Created Date       : 06 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   06/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   07/09/2024   Rakeyan Nuramria                  Adjusting functionality for checkbox & handleClear
    1.0   09/09/2024   Rakeyan Nuramria                  Add logic spinner
    1.0   21/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   01/10/2024   Rakeyan Nuramria                  Adjust logic create case in Account & update in Case
    1.0   03/10/2024   Rakeyan Nuramria                  Adjust parameter for mutasi kartu kredit
    1.0   03/10/2024   Rakeyan Nuramria                  [SIT - ON GOING] Adjust logic show/get data to save/update case
    1.0   07/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic date & show/get data to save/update case
    1.0   09/10/2024   Rakeyan Nuramria                  [FROM SIT] remove mapping for nomor rekening for create/update case
    1.0   10/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show message if data mutasi empty & refresh data
    1.0   31/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show nominal/price/saldo number
**/

import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMutasiKartu from '@salesforce/apex/SCC_Account_UI.getMutasiKartu';
import getTrxCredit from '@salesforce/apex/SCC_CaseBRICare.getTrxCredit';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';

export default class LwcMutasiRekeningKreditComponent extends  NavigationMixin(LightningElement) {

    @api recordId
    @api accountId;
    @api noKartu;
    @api noRekening;
    @api isCloseHidden;
    @track selectedNomorKartu;
    @track recordTypeId;
    @track selectedRow;
    @track isCreateButtonDisabled = true;
    @track isUpdateButtonDisabled = true;
    @track showTable = false;
    @track isLoading = false;
    @track isLoadingCreateCase = false;
    @track isLoadingUpdateCase = false;
    @track showCreateCaseButton = false;
    @track showUpdateCaseButton = false;
    @track data = [];
    
    @track errorMsg = '';
    @track hasError = false;
    @track errorMessage = '';
    // @track data = [
    //     { id: '1', tglTransaksi: '2024-09-01', tglPosting: '2024-09-02', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 500000, kodeTransaksi: 1001, refNumber: 2121, approvalCode: 123456, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '2', tglTransaksi: '2024-09-02', tglPosting: '2024-09-04', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 2000000, kodeTransaksi: 1002, refNumber: 2121, approvalCode: 654321, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '3', tglTransaksi: '2024-09-03', tglPosting: '2024-09-06', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 1500000, kodeTransaksi: 1003, refNumber: 2121, approvalCode: 789012, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '4', tglTransaksi: '2024-09-03', tglPosting: '2024-09-08', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 300000, kodeTransaksi: 1004, refNumber: 2121, approvalCode: 345678, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '5', tglTransaksi: '2024-09-04', tglPosting: '2024-09-10', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 100000, kodeTransaksi: 1005, refNumber: 2121, approvalCode: 987654, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '6', tglTransaksi: '2024-09-04', tglPosting: '2024-09-12', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 1200000, kodeTransaksi: 1006, refNumber: 2121, approvalCode: 112233, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '7', tglTransaksi: '2024-09-05', tglPosting: '2024-09-14', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 800000, kodeTransaksi: 1007, refNumber: 2121, approvalCode: 445566, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '8', tglTransaksi: '2024-09-05', tglPosting: '2024-09-16', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 3000000, kodeTransaksi: 1008, refNumber: 2121, approvalCode: 778899, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '9', tglTransaksi: '2024-09-05', tglPosting: '2024-09-18', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 600000, kodeTransaksi: 1009, refNumber: 2121, approvalCode: 990011, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' },
    //     { id: '10', tglTransaksi: '2024-09-06', tglPosting: '2024-09-20', descTransaksi: 'J-CO Mangga Dua', nominalTransaksi: 250000, kodeTransaksi: 1010, refNumber: 2121, approvalCode: 223344, ketResponse: 'Approved', statusTransaksi: 'Tercetak', waktuPenagihan: '0' }
    // ];
    
    columns = [
        { label: 'Tanggal Transaksi ', fieldName: 'tglTransaksi', type: 'date' },
        { label: 'Tanggal Posting', fieldName: 'tglPosting', type: 'date' },
        { label: 'Deskripsi Transaksi', fieldName: 'descTransaksi', type: 'text' },
        { label: 'Nominal Transaksi', fieldName: 'nominalTransaksi', type: 'number' },
        { label: 'Kode Transaksi', fieldName: 'kodeTransaksi', type: 'number' },
        { label: 'Ref Number', fieldName: 'refNumber', type: 'number' },
        { label: 'Approval Code', fieldName: 'approvalCode', type: 'number' },
        { label: 'Keterangan Response', fieldName: 'ketResponse', type: 'text' },
        { label: 'Status Transaksi', fieldName: 'statusTransaksi', type: 'text' },
        { label: 'Waktu Sisa Penagihan Merchant', fieldName: 'waktuPenagihan', type: 'text' }
    ];


    @track filteredData = [...this.data];
    @track filteredData = [];
    @track startDate = this.getTodayDate();
    @track endDate = this.getTodayDate();
    

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    wireCaseData({ data, error }) {
        if (data) {

            const recordTypeInfo = data.recordTypeInfos;

            if (recordTypeInfo) {
                console.log('Available Record Types:', recordTypeInfo);
                // Find the record type 
                const briOpenCaseRecType = Object.keys(recordTypeInfo).find(rtype => 
                    recordTypeInfo[rtype].name === 'BRI Open Case'
                );

                if (briOpenCaseRecType) {
                    this.recordTypeId = briOpenCaseRecType;
                    console.log('Found Record Type Id:', this.recordTypeId);
                } else {
                    console.error('Record Type BRI Open Case not found.');
                }
            }
        } else if (error) {
            this.error = error;
            console.error('Error fetching Case metadata:', error);
        }
    }

    connectedCallback(){
        this.handleClear();
        console.log('start date : ', this.startDate);
        console.log('end date : ', this.endDate);
        console.log('nomor kartu from parent : ', this.noKartu);
        console.log('accountId from parent : ', this.accountId);
        console.log('recordId from parent : ', this.recordId);
        this.selectedNomorKartu = this.noKartu;
        this.fetchDataMutasiKartu();

        if (this.recordId.startsWith('001')) {  //account prefix
            this.showCreateCaseButton = true;
        } else if(this.recordId.startsWith('500')){ //case prefix
            this.showUpdateCaseButton = true;
        }
    }

    getTodayDate() {
        const today = new Date();
        const yyyy = today.getFullYear();
        const mm = String(today.getMonth() + 1).padStart(2, '0');
        const dd = String(today.getDate()).padStart(2, '0');
        return `${yyyy}-${mm}-${dd}`;
    }

    handleStartDateChange(event) {
        this.startDate = event.target.value;
        this.validateDateRange();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.validateDateRange();
    }

    validateDateRange() {
        const today = this.getTodayDate();
        
        if (this.startDate > today) {
            this.showToast('Error', 'Tanggal Awal tidak boleh melebihi hari ini.', 'error');
            this.startDate = today;
        }

        if (this.endDate > today) {
            this.showToast('Error', 'Tanggal Akhir tidak boleh melebihi hari ini.', 'error');
            this.endDate = today; 
        }

        if (this.startDate && this.endDate) {
            const start = new Date(this.startDate);
            const end = new Date(this.endDate);
            const diffDays = (end - start) / (1000 * 60 * 60 * 24);

            if (diffDays > 31) {
                this.showToast('Error', 'Jarak tanggal tidak boleh lebih dari 31 hari.', 'error');
                // this.endDate = ''; 
            }
        }
    }

    // handleCheckboxChange(event) {
    //     const selectedId = event.target.dataset.id;
    
    //     console.log(`Checkbox clicked with ID: ${selectedId}`);
    
    //     // Update the state of the checkboxes
    //     this.filteredData = this.filteredData.map(row => {
    //         if (row.id === selectedId) {
    //             return { ...row, isSelected: !row.isSelected };
    //         } else {
    //             return { ...row, isSelected: false };
    //         }
    //     });
    
    //     // Check if any checkbox is selected
    //     const isAnySelected = this.filteredData.some(row => row.isSelected);
    
    //     // Disable or enable the Create Case button based on the checkbox selection
    //     this.isCreateButtonDisabled = !isAnySelected;
    // }

    handleCheckboxChange(event) {
        const selectedId = event.target.dataset.id;
    
        console.log(`Checkbox clicked with ID: ${selectedId}`);

        this.selectedRow = this.selectedRow === selectedId ? null : selectedId;
    
        this.filteredData = this.processedData();
    
        // this.isCreateButtonDisabled = !this.filteredData.some(row => row.isSelected);

        if (this.recordId.startsWith('001')) { //account prefix
            
            this.isCreateButtonDisabled = !this.filteredData.some(row => row.isSelected);
        } else if(this.recordId.startsWith('500')) { //case prefix
            
            this.isUpdateButtonDisabled = !this.filteredData.some(row => row.isSelected);
        }
    }

    fetchDataMutasiKartu(){
        this.handleClearResult();

        this.isLoading = true;
        this.showTable = false;

        // if (this.startDate && this.endDate) {
            let requestPayload;
            // const requestPayload = {
            //     noKar: this.noKartu,
            //     idacc: this.accountId
            // };

            if (this.recordId.startsWith('001')) { // Account prefix
                console.log('hit by account');
                requestPayload = {
                    nokar: this.noKartu,
                    idacc: this.recordId
                };
                console.log('Request Payload for Account:', JSON.stringify(requestPayload));
                
                getMutasiKartu(requestPayload)
                .then(result => {
                    console.log('Response mutasi rekening received:', result);

                    // if (result && result.CPAHF) {
                    //     this.data = result.CPAHF;
                    //     this.filteredData = this.processedData();
                    //     console.log('Filtered Data:', this.filteredData);
                    //     this.showTable = true;
                    // } else {
                    //     this.handleSearchError('Data mutasi kartu kosong.');
                    //     this.showToast('Error', 'Data tidak ditemukan', 'error', '','');
                    // }

                    if (result && result.CPAHF && Array.isArray(result.CPAHF) && result.CPAHF.length > 0) {
                        this.data = result.CPAHF;
                        this.filteredData = this.processedData();
                        console.log('Filtered Data:', this.filteredData);
                        this.showTable = true;
                    } else {
                        this.handleSearchError('Data mutasi kartu kosong.');
                        // this.showToast('Error', 'Data mutasi kartu kosong', 'error', '', '');
                    }
                })
                .catch(error => {
                    this.handleSearchError('Terjadi kesalahan saat pencarian, ', error.message);
                    this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error', '','');
                    console.error('Error occurred during search:', error.message);

                })
                .finally(() => {
                    this.isLoading = false;
                    console.log('Loading state set to false.');
                });

            } else if (this.recordId.startsWith('500')){ // Case prefix
                console.log('hit by case');
                requestPayload = {
                    cardNumber: this.noKartu,
                    idcs: this.recordId
                };
                console.log('Request Payload for Case:', JSON.stringify(requestPayload));
                
                getTrxCredit(requestPayload)
                .then(result => {
                    console.log('Response mutasi rekening received:', result);
                    console.log('Response mutasi rekening received:', JSON.stringify(result, null, 2));

                    // if (result && result.CPAHF) {
                    //     this.data = result.CPAHF;
                    //     this.filteredData = this.processedData();
                    //     console.log('Filtered Data:', this.filteredData);
                    //     this.showTable = true;
                    // } else {
                    //     this.handleSearchError('Data mutasi kartu kosong.');
                    //     this.showToast('Error', 'Data tidak ditemukan', 'error', '','');
                    // }

                    if (result && result.CPAHF && Array.isArray(result.CPAHF) && result.CPAHF.length > 0) {
                        this.data = result.CPAHF;
                        this.filteredData = this.processedData();
                        console.log('Filtered Data:', this.filteredData);
                        this.showTable = true;
                    } else {
                        this.handleSearchError('Data mutasi kartu kosong.');
                        // this.showToast('Error', 'Data mutasi kartu kosong', 'error', '', '');
                    }
                })
                .catch(error => {
                    this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error', '','');
                    console.error('Error occurred during search:', error.message);
                })
                .finally(() => {
                    this.isLoading = false;
                    console.log('Loading state set to false.');
                });
            }
        // } else {
        //     this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error', '','');
        // }
    }

    processedData() {
        // return this.filteredData.map(row => {
        //     return {
        //         ...row,
        //         isSelected: this.selectedRow === row.id,
        //         // isDisabled: this.selectedRow && this.selectedRow !== row.id
        //     };
        // });

        const formatterCurrency = new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0, // Adjust as needed
            maximumFractionDigits: 2, // Adjust as needed
        });


        // return this.data.map((row, index) => {
        //     const dateTransaksi = new Date(row.tanggalTransaksi);
        //     const datePostingan = new Date(row.tanggalPostingTransaksi);
        //     const cstmTglTransaksi = dateTransaksi.toISOString().split('T')[0]; 
        //     const cstmTglPostingan = datePostingan.toISOString().split('T')[0]; 

        //     // const customTime = dateObject.toTimeString().split(' ')[0];

        //     return {
        //         ...row,
        //         id: index + 1,
        //         cstmTglTransaksi,
        //         cstmTglPostingan,
        //         nominalTransaksi: formatterCurrency.format(row.nominalTransaksi),
        //         // waktuTransaksi: row.waktuTransaksi,
        //         // isSelected: this.selectedRow === (index + 1).toString() ,
        //         isSelected: this.selectedRow === (index + 1).toString(),
        //         // isDisabled: row.isProcessed || false //for disabled after case being created
        //     };
        // });

        return this.data.map((row, index) => {
            // Convert 'YYYYMMDD' format to 'YYYY-MM-DD' for valid Date parsing
            const formatDateString = (dateString) => {
                if (dateString && dateString.length === 10 && dateString.includes('-')) {
                    return dateString; // Already formatted
                }
                if (dateString && dateString.length === 8) {
                    return `${dateString.slice(0, 4)}-${dateString.slice(4, 6)}-${dateString.slice(6, 8)}`;
                }
                return null;
            };
    
            const tanggalTransaksiFormatted = formatDateString(row.tanggalTransaksi);
            const tanggalPostingFormatted = formatDateString(row.tanggalPostingTransaksi);
    
            // Create Date objects and check for validity
            const dateTransaksi = tanggalTransaksiFormatted ? new Date(tanggalTransaksiFormatted) : null;
            const datePostingan = tanggalPostingFormatted ? new Date(tanggalPostingFormatted) : null;
    
            const cstmTglTransaksi = dateTransaksi && !isNaN(dateTransaksi) 
                ? dateTransaksi.toISOString().split('T')[0] 
                : 'Invalid date';
            const cstmTglPostingan = datePostingan && !isNaN(datePostingan) 
                ? datePostingan.toISOString().split('T')[0] 
                : 'Invalid date';
    
            return {
                ...row,
                id: index + 1,
                cstmTglTransaksi,
                cstmTglPostingan,
                // nominalTransaksi: formatterCurrency.format(row.nominalTransaksi),
                deskripsiTransaksi: row.deskripsiTransaksi ? row.deskripsiTransaksi.trim() || '-' : '-',
                // nominalTransaksi: row.nominalTransaksi ? formatterCurrency.format(row.nominalTransaksi) : '-',
                nominalTransaksi: row.nominalTransaksi ? this.formatNumber(row.nominalTransaksi) : '-',
                kodeTransaksi: row.kodeTransaksi ? row.kodeTransaksi.trim() || '-' : '-',
                refferenceNumber: row.refferenceNumber ? row.refferenceNumber.trim() || '-' : '-',
                refferenceNumber: row.refferenceNumber ? row.refferenceNumber.trim() || '-' : '-',
                approvalCode: row.approvalCode ? row.approvalCode.trim() || '-' : '-',
                keteranganTransaksi: row.detailTransaksi ? row.detailTransaksi.trim() || '-' : '-',
                statusTransaksi: row.statusTransaksi ? row.statusTransaksi.trim() || '-' : '-',
                waktuSisaPenagihanMerchant: row.waktuSisaPenagihanMerchant ? row.waktuSisaPenagihanMerchant.trim() || '-' : '-',
                isSelected: this.selectedRow === (index + 1).toString(),
            };
        });
    }

    handleCreateCase() {
        // Handle case creation logic based on selected row
        // const selectedRow = this.filteredData.find(row => row.isSelected);
        // if (selectedRow) {
        //     console.log('Creating case for row : ', selectedRow);
        // }

        this.isLoadingCreateCase = true;

        const selectedRow = this.filteredData.find(row => row.isSelected);
        console.log('handleCreateCase clicked..');
        
        if (selectedRow) {
            const fields = {};

            fields['RecordTypeId'] = this.recordTypeId;

           // Format the date field (SCC_Transaction_Date__c)
            const formattedDate = new Date(selectedRow.cstmTglTransaksi).toISOString().split('T')[0];
            fields['SCC_Transaction_Date__c'] = formattedDate || null;

            // Combine date and time to create the datetime field (SCC_Waktu_Transaksi__c)
            // if (selectedRow.cstmTglTransaksi && selectedRow.waktuTransaksi) {
            //     const date = new Date(selectedRow.cstmTglTransaksi);

            //     const timeParts = selectedRow.waktuTransaksi.split(':');
            //     const hours = parseInt(timeParts[0], 10);
            //     const minutes = parseInt(timeParts[1], 10);
            //     const seconds = timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0; // Default to 0 if seconds are not provided

            //     date.setHours(hours, minutes, seconds);

            //     // Convert the updated date (with time) to ISO 8601 format
            //     const formattedDateTime = date.toISOString(); // format YYYY-MM-DDTHH:mm:ss.sssZ

            //     fields['SCC_Waktu_Transaksi__c'] = formattedDateTime || null;
            // } else {
            //     fields['SCC_Waktu_Transaksi__c'] = null; // Handle the case where either date or time is missing
            // }


             //v1, use this if using the IDR Formatter Currency
            // const rawNominal = selectedRow.nominalTransaksi.replace(/[^0-9,-]/g, '').replace(',', '.');
            // const mutasiTransaksi = Number(rawNominal);
            // fields['SCC_Amount__c'] = parseFloat(mutasiTransaksi.toFixed(2));
            //END v1, use this if using the IDR Formatter Currency

            // v2, use this if using formatNumber method
            const rawNominal = selectedRow.nominalTransaksi.replace(/[^0-9,-]/g, '').replace(',', '.');

            console.log('Nominal Debet:', rawNominal);

            // Convert raw strings to numbers
            const mutasiTransaksi = Number(rawNominal);

            console.log('Nominal Debet:', mutasiTransaksi);

            // Format the output to the desired currency format
            fields['SCC_Amount__c'] = mutasiTransaksi; // No need to use toFixed here
            console.log('Formatted Kredit Amount:', this.formatNumber(fields['SCC_Amount__c'].toString()));
            // END v2, use this if using formatNumber method


            // fields['SCC_Account_Number__c'] = String(this.noRekening) || null; 
            fields['SCC_Account_Number__c'] = null; 
            fields['SCC_Card_Number__c'] = String(this.noKartu) || null;
            // fields['SCC_Terminal_ID__c'] = String(selectedRow.kodeTransaksi) || null; //temp using kodeTransaksi, waiting to confirmation field
            fields['AccountId'] = this.accountId;

            const recordInput = { apiName: 'Case', fields };

            createRecord(recordInput)
                .then(caseRecord => {
                    console.log('Successfully created record:', caseRecord);
                    console.log('Created Case ID:', caseRecord.id);
                    this.showToast(
                        'Sukses', 
                        'Record berhasil ditambahkan! ', 
                        'success', 
                        caseRecord.id, 
                        'Case' // Change this to 'Case' or whatever your object API name is
                    );

                    // Optionally delete the selected row from the data
                    // this.deleteSelectedRow(selectedRow.noRek);

                    this.selectedRow = null;
                    this.filteredData = this.processedData();
                    this.isCreateButtonDisabled = true;

                    // Refresh the Apex data after creating the record
                    // return refreshApex(this.filteredData); // Adjust based on where you store the data

                })
                .catch(error => {
                    const errorMessage = error.message || 'An unknown error occurred.';
                    console.log('Error dalam pembuatan case:', errorMessage);
                    // console.log('Error.message dalam pembuatan case:', error.message);
                    this.showToast('Error', `Error dalam pembuatan case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingCreateCase = false;
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to create a case.', 'error');
        }
    }

    // handleCreateCase() {
    //     // Handle case creation logic based on selected row
    //     // const selectedRow = this.filteredData.find(row => row.isSelected);
    //     // if (selectedRow) {
    //     //     console.log('Creating case for row : ', selectedRow);

    //     // }

    //     this.isLoadingCreateCase = true;

    //     const selectedRow = this.filteredData.find(row => row.isSelected);
    //     console.log('handleCreateCase clicked..');
        
    //     if (selectedRow) {
    //         const fields = {};

    //         fields['RecordTypeId'] = this.recordTypeId;

    //        // Format the date field (SCC_Transaction_Date__c)
    //         const formattedDate = new Date(selectedRow.customDate).toISOString().split('T')[0];
    //         fields['SCC_Transaction_Date__c'] = formattedDate || null;

    //         // Combine date and time to create the datetime field (SCC_Waktu_Transaksi__c)
    //         if (selectedRow.cstmTglTransaksi && selectedRow.waktuTransaksi) {
    //             const date = new Date(selectedRow.cstmTglTransaksi);

    //             const timeParts = selectedRow.customTime.split(':');
    //             const hours = parseInt(timeParts[0], 10);
    //             const minutes = parseInt(timeParts[1], 10);
    //             const seconds = timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0; // Default to 0 if seconds are not provided

    //             date.setHours(hours, minutes, seconds);

    //             // Convert the updated date (with time) to ISO 8601 format
    //             const formattedDateTime = date.toISOString(); // format YYYY-MM-DDTHH:mm:ss.sssZ

    //             fields['SCC_Waktu_Transaksi__c'] = formattedDateTime || null;
    //         } else {
    //             fields['SCC_Waktu_Transaksi__c'] = null; // Handle the case where either date or time is missing
    //         }

            
    //         // const mutasiDebet = Number(selectedRow.mutasiDebet);
    //         // const mutasiKredit = Number(selectedRow.mutasiKredit); 

    //         // console.log('Nominal Debet:', mutasiDebet);
    //         // console.log('Nominal Kredit:', mutasiKredit);

    //         const rawDebet = selectedRow.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
    //         const rawKredit = selectedRow.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.'); 

    //         console.log('Nominal Debet:', rawDebet);
    //         console.log('Nominal Kredit:', rawKredit);

    //         const mutasiDebet = Number(rawDebet);
    //         const mutasiKredit = Number(rawKredit);

    //         console.log('Nominal Debet:', mutasiDebet);
    //         console.log('Nominal Kredit:', mutasiKredit);
            
    //         if (mutasiDebet === 0 && mutasiKredit !== 0) {
    //             fields['SCC_Amount__c'] = parseFloat(mutasiKredit.toFixed(2)); 
    //         } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
    //             fields['SCC_Amount__c'] = parseFloat(mutasiDebet.toFixed(2)); 
    //         }
    
    //         fields['SCC_Account_Number__c'] = String(selectedRow.noKartu) || null; 
    //         fields['SCC_Card_Number__c'] = String(selectedRow.noKartu) || null;
    //         // fields['SCC_Terminal_ID__c'] = String(selectedRow.trremk) || null;
    //         fields['AccountId'] = this.accountId;

    //         const recordInput = { apiName: 'Case', fields };

    //         createRecord(recordInput)
    //             .then(caseRecord => {
    //                 console.log('Successfully created record:', caseRecord);
    //                 console.log('Created Case ID:', caseRecord.id);
    //                 this.showToast(
    //                     'Sukses', 
    //                     'Record berhasil ditambahkan! ', 
    //                     'success', 
    //                     caseRecord.id, 
    //                     'Case' // Change this to 'Case' or whatever your object API name is
    //                 );

    //                 // Optionally delete the selected row from the data
    //                 // this.deleteSelectedRow(selectedRow.noRek);

    //                 this.selectedRow = null;
    //                 this.filteredData = this.processedData();
    //                 this.isCreateButtonDisabled = true;

    //                 // Refresh the Apex data after creating the record
    //                 // return refreshApex(this.filteredData); // Adjust based on where you store the data

    //             })
    //             .catch(error => {
    //                 const errorMessage = error.body?.message || 'An unknown error occurred.';
    //                 console.log('Error dalam pembuatan case:', errorMessage);
    //                 this.showToast('Error', `Error dalam pembuatan case: ${errorMessage}`, 'error');
    //             })
    //             .finally(() => {
    //                 this.isLoadingCreateCase = false;
    //             });
    //     } else {
    //         this.showToast('Error', 'No row selected. Please select a row to create a case.', 'error');
    //     }
    // }

    /**
    handleUpdateCase() {
        // Handle case update logic based on selected row
        this.isLoadingUpdateCase = true;
    
        const selectedRow = this.filteredData.find(row => row.isSelected);
        console.log('handleUpdateCase clicked..');
        
        if (selectedRow) {
            const fields = {};
    
            fields['Id'] = this.recordId;
    
            // Format the date field (SCC_Transaction_Date__c)
            const formattedDate = new Date(selectedRow.customDate).toISOString().split('T')[0];
            fields['SCC_Transaction_Date__c'] = formattedDate || null;
    
            // Combine date and time to create the datetime field (SCC_Waktu_Transaksi__c)
            if (selectedRow.cstmTglTransaksi && selectedRow.waktuTransaksi) {
                const date = new Date(selectedRow.cstmTglTransaksi);
    
                const timeParts = selectedRow.customTime.split(':');
                const hours = parseInt(timeParts[0], 10);
                const minutes = parseInt(timeParts[1], 10);
                const seconds = timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0;
    
                date.setHours(hours, minutes, seconds);
                const formattedDateTime = date.toISOString();
    
                fields['SCC_Waktu_Transaksi__c'] = formattedDateTime || null;
            } else {
                fields['SCC_Waktu_Transaksi__c'] = null;
            }
    
            const rawDebet = selectedRow.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
            const rawKredit = selectedRow.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');
    
            console.log('Nominal Debet:', rawDebet);
            console.log('Nominal Kredit:', rawKredit);
    
            const mutasiDebet = Number(rawDebet);
            const mutasiKredit = Number(rawKredit);
    
            console.log('Nominal Debet:', mutasiDebet);
            console.log('Nominal Kredit:', mutasiKredit);
    
            if (mutasiDebet === 0 && mutasiKredit !== 0) {
                fields['SCC_Amount__c'] = parseFloat(mutasiKredit.toFixed(2)); 
            } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
                fields['SCC_Amount__c'] = parseFloat(mutasiDebet.toFixed(2)); 
            }
    
            fields['SCC_Account_Number__c'] = String(selectedRow.noKartu) || null; 
            fields['SCC_Card_Number__c'] = String(selectedRow.noKartu) || null;
            fields['AccountId'] = this.accountId;
    
            const recordInput = { fields };
    
            updateRecord(recordInput)
                .then(caseRecord => {
                    console.log('Successfully updated record:', caseRecord);
                    this.showToast(
                        'Sukses', 
                        'Record berhasil diperbarui.', 
                        'success', 
                        caseRecord.id, 
                        'Case'
                    );
    
                    // Optionally refresh the data
                    this.selectedRow = null;
                    this.filteredData = this.processedData();
                    this.isUpdateButtonDisabled = true;
    
                })
                .catch(error => {
                    const errorMessage = error.body?.message || 'An unknown error occurred.';
                    console.log('Error dalam pembaruan case:', errorMessage);
                    this.showToast('Error', `Error dalam pembaruan case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingUpdateCase = false;
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to update a case.', 'error');
        }
    }
    */

    handleUpdateCase() {
        this.isLoadingUpdateCase = true;
    
        const selectedRow = this.filteredData.find(row => row.isSelected);
        console.log('handleUpdateCase clicked..');
    
        if (selectedRow) {
            const fields = {};

            fields['Id'] = this.recordId;
    
            // fields['RecordTypeId'] = this.recordTypeId;
    
            // Format the date field (SCC_Transaction_Date__c)
            const formattedDate = new Date(selectedRow.cstmTglTransaksi).toISOString().split('T')[0];
            fields['SCC_Transaction_Date__c'] = formattedDate || null;
    
            // Combine date and time to create the datetime field (SCC_Waktu_Transaksi__c)
            // if (selectedRow.cstmTglTransaksi && selectedRow.waktuTransaksi) {
            //     const date = new Date(selectedRow.cstmTglTransaksi);
    
            //     const timeParts = selectedRow.waktuTransaksi.split(':');
            //     const hours = parseInt(timeParts[0], 10);
            //     const minutes = parseInt(timeParts[1], 10);
            //     const seconds = timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0;
    
            //     date.setHours(hours, minutes, seconds);
            //     fields['SCC_Waktu_Transaksi__c'] = date.toISOString() || null;
            // } else {
            //     fields['SCC_Waktu_Transaksi__c'] = null;
            // }
    
            //v1, use this if using the IDR Formatter Currency
            // const rawNominal = selectedRow.nominalTransaksi.replace(/[^0-9,-]/g, '').replace(',', '.');
            // const mutasiTransaksi = Number(rawNominal);
            // fields['SCC_Amount__c'] = parseFloat(mutasiTransaksi.toFixed(2));
            //END v1, use this if using the IDR Formatter Currency

            // v2, use this if using formatNumber method
            const rawNominal = selectedRow.nominalTransaksi.replace(/[^0-9,-]/g, '').replace(',', '.');

            console.log('Nominal Debet:', rawNominal);

            // Convert raw strings to numbers
            const mutasiTransaksi = Number(rawNominal);

            console.log('Nominal Debet:', mutasiTransaksi);

            // Format the output to the desired currency format
            fields['SCC_Amount__c'] = mutasiTransaksi; // No need to use toFixed here
            console.log('Formatted Kredit Amount:', this.formatNumber(fields['SCC_Amount__c'].toString()));
            // END v2, use this if using formatNumber method

            // fields['SCC_Account_Number__c'] = String(this.noKartu) || null;
            fields['SCC_Account_Number__c'] = null;
            fields['SCC_Card_Number__c'] = String(this.noKartu) || null;
            fields['AccountId'] = this.accountId;
    
            const recordInput = { fields };
    
            updateRecord(recordInput)
                .then(updatedCaseRecord => {
                    console.log('Successfully updated record:', updatedCaseRecord);
                    this.showToast(
                        'Sukses',
                        'Record berhasil diperbarui. ',
                        'success',
                        updatedCaseRecord.id,
                        'Case'
                    );
    
                    this.selectedRow = null;
                    this.filteredData = this.processedData();
                    this.isUpdateButtonDisabled = true;
    
                    // Optionally refresh data here
                })
                .catch(error => {
                    const errorMessage = error.message || 'An unknown error occurred.';
                    console.log('Error during case update:', errorMessage);
                    this.showToast('Error', `Error during case update: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingUpdateCase = false;
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to update a case.', 'error');
        }
    }
    

    // handleSearch() {
    //     if (this.startDate && this.endDate) {
    //         const start = new Date(this.startDate);
    //         const end = new Date(this.endDate);

    //         this.filteredData = this.data.filter(record => {
    //             const recordDate = new Date(record.tglTransaksi);
    //             return recordDate >= start && recordDate <= end;
    //         });

    //         if (this.filteredData.length > 0) {
    //             this.showTable = true;
    //         } else {
    //             this.showTable = false;
    //             this.showToast('Info', 'Data tidak ditemukan untuk rentang tanggal yang dipilih.', 'info');
    //         }
    //     } else {
    //         this.showTable = false; 
    //         this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error');
    //     }
    // }

    //HandleSearch with spinner
    // handleSearch() {
    //     this.isLoading = false;
    //     this.showTable = false;
    //     if (this.startDate && this.endDate) {
    //         this.isLoading = true;
    //         const start = new Date(this.startDate);
    //         const end = new Date(this.endDate);

    //         // Simulating data processing with a delay
    //         setTimeout(() => {
    //             this.filteredData = this.data.filter(record => {
    //                 const recordDate = new Date(record.tglTransaksi);
    //                 return recordDate >= start && recordDate <= end;
    //             });

    //             if (this.filteredData.length > 0) {
    //                 this.showTable = true;
    //             } else {
    //                 this.showTable = false;
    //                 this.showToast('Info', 'Data tidak ditemukan untuk rentang tanggal yang dipilih.', 'info');
    //             }
                
    //             this.isLoading = false; // Hide spinner after processing
    //         }, 1000); // Simulating a delay of 1 second
    //     } else {
    //         this.showTable = false;
    //         this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error');
    //     }
    // }

    handleSearchError(errorMessage) {
        this.showUpdateCaseButton = false;
        this.showCreateCaseButton = false;
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.data = [];
        this.filteredData = [];
        // this.hasError = true;
        // this.isLoadingBanking = false;
        // this.isLoadingKredit = false;
        // this.isLoadingBRILink = false;
        // this.isLoadingMerchant = false;
        // this.isLoadingDPLK = false;
        console.log('Error Message:', errorMessage);
    }
    

    @api handleClear() {
        this.startDate = this.getTodayDate();
        this.endDate = this.getTodayDate();
        this.selectedRow = null; 
        this.isCreateButtonDisabled = true; 
        this.isUpdateButtonDisabled = true; 
        this.showTable = false;
        this.isLoading = false;

        this.filteredData = [...this.data];
    
        //this.showToast('Info', 'Filters have been cleared.', 'info');
    }

    handleClearResult(){
        this.data = [];
        this.filteredData = [];
        this.hasError = false;
        this.errMsg = '';
    }

    @api updateMutasiDetails() {
        // Only update if the card number is different
        if (this.noKartu && this.noKartu !== this.selectedNomorKartu) {
            this.selectedNomorKartu = this.noKartu;
            this.fetchDataMutasiKartu();
        }
    }

    handleCloseMutasiRek() {
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        this.handleClear();
        this.dispatchEvent(closeEvent);
    }

    // v2, adjusting for the input to SF, Function to format the number with commas
    // formatNumber(numberString) {
    //     // Parse the input string to a float
    //     const parsedNumber = parseFloat(numberString);
    //     if (isNaN(parsedNumber)) return '0';
        
    //     // Convert to string and add commas, replace the last comma with a dot for decimal
    //     return parsedNumber.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".").replace(/,/, '.');
    // }

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

    // formatter using the IDR Currency
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

    showToast(title, message, variant, recordId = null, objectApiName = null) {
        // Check if both recordId and objectApiName are provided for generating a link
        if (recordId && objectApiName) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: objectApiName,
                    actionName: 'view',
                },
            }).then((url) => {
                const event = new ShowToastEvent({
                    title: title,
                    message: message + '{0}',
                    // message: message + ' <a href="' + url + '" target="_blank">Klik disini untuk melihat data</a>',
                    // message: message + '. Tekan Ctrl + Klik untuk membuka tab baru.',
                    variant: variant,
                    messageData: [
                        {
                            url: url,
                            label: 'Klik disini untuk melihat data.',
                        }
                    ],
                    duration: 5000
                });
                this.dispatchEvent(event);
                // // Open the link in a new tab after the toast is shown
                // setTimeout(() => {
                //     window.open(url, '_blank');
                // }, 5000); // Delay to give the user time to click the toast link
            }).catch((error) => {
                console.error('Error generating URL:', error);
            });
        } else {
            // Just show a basic toast without a link
            const event = new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
                duration:5000,
            });
            this.dispatchEvent(event);
        }
    }
}