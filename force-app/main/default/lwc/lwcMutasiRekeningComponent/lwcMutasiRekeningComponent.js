/** 
    LWC Name    : lwcMutasiRekeningComponent.js
    Created Date       : 03 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   03/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   06/09/2024   Rakeyan Nuramria                  Move the isSelected & isDisabled to processedData function
    1.0   07/09/2024   Rakeyan Nuramria                  Adjusting functionality for checkbox & handleClear
    1.0   07/09/2024   Rakeyan Nuramria                  Add logic spinner
    1.0   21/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   30/09/2024   Rakeyan Nuramria                  change parameter getMutation
    1.0   01/10/2024   Rakeyan Nuramria                  Adjust logic create case in Account & update in Case
    1.0   07/10/2024   Rakeyan Nuramria                  Adjust logic to input TID
    1.0   09/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to input Nomor Kartu Rekening
    1.0   31/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show nominal/price/saldo number
    1.0   29/11/2024   Rakeyan Nuramria                  [FROM SIT] Fix validating start date & end date mutasi
    1.0   02/12/2024   Rakeyan Nuramria                  [FROM SIT] Fix jam transaksi mutasi + cleansing code
    //release 3
    1.0   05/12/2024   Rakeyan Nuramria                  [FROM SIT] Adjust UI for combination remarks column using logic
    1.0   11/02/2025   Rakeyan Nuramria                  Add API 5 latest transaction & Adjust logic
    1.1   14/02/2025   Rakeyan Nuramria                  Add function to pass update latest transaction when different noRek being clicked
    1.1   17/02/2025   Rakeyan Nuramria                  [FROM SIT] Add updateGrandchildHoldDetails()

**/

import { LightningElement, api, track,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMutasiRekening from '@salesforce/apex/SCC_Account_UI.getMutasiRekening';
import getMutation from '@salesforce/apex/SCC_CaseBRICare.getMutation';
import getTID from '@salesforce/apex/SCC_CaseBRICare.getTID';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import getLastTransaction from '@salesforce/apex/SCC_CaseBRICare.getLastTransaction';

export default class LwcMutasiRekeningComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api accountId;
    @api noKartu;
    @api noRekening;
    @api isCloseHidden;
    @track recordTypeId;
    @track selectedRow;
    @track isCreateButtonDisabled = true;
    @track isUpdateButtonDisabled = true;
    @track showTable = false;
    @track showBlockedInformation = false;
    @track isLoading = false;
    @track isLoadingCreateCase = false;
    @track isLoadingUpdateCase = false;
    @track showCreateCaseButton = false;
    @track showUpdateCaseButton = false;
    @track data = [];
    // @track filteredData = [...this.data];
    @track filteredData = [];
    @track startDate = this.getTodayDate();
    @track endDate = this.getTodayDate();
    @track checkedData = {};
    @track tidValue;

    @track latestTransactions = [];
    @track showLatestTransactions = true;
    @track isLoadingSearch = false;  // For search functionality
    @track isLoadingLatest = false;  // For latest transactions
    @track hasLatestTransactionError = false;
    @track hasSearchError = false;
    @track errorLatestTransactionMsg = '';
    @track errorSearchMsg = '';

    @track selectedNomorRekening;


    get hasLatestTransactionData() {
        return this.latestTransactions && this.latestTransactions.length > 0;
    }
    
    get hasSearchData() {
        return this.filteredData && this.filteredData.length > 0;
    }

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

    async connectedCallback(){
    // connectedCallback(){
        this.handleClear();
        console.log('start date : ', this.startDate);
        console.log('end date : ', this.endDate);
        console.log('nomor rekening from parent : ', this.noRekening);
        console.log('nomor kartu from parent : ', this.noKartu);
        console.log('accountId from parent : ', this.accountId);
        console.log('recordId from parent : ', this.recordId);

        this.selectedNomorRekening = this.noRekening;


        // Condtion to show button based on the record page
        if (this.recordId.startsWith('001')) {  //account prefix
            this.showCreateCaseButton = true;
        } else if(this.recordId.startsWith('500')){ //case prefix
            this.showUpdateCaseButton = true;
        }

        await this.fetchLatestTransactions();
        // this.fetchLatestTransactions();
    }

    // Method to normalize the latest transaction data
    normalizeLatestTransaction(transaction) {
        return {
            id: `${transaction.Trdate2}-${transaction.Timent}-${transaction.Tracct}-${transaction.Amt}`,
            noRek: transaction.Tracct ? transaction.Tracct : '-',
            customDate: transaction.Trdate ? this.formatDateString(transaction.Trdate) : '-',
            customTime: transaction.Timent ? this.formatTime(transaction.Timent) : '-',
            // customRemark: transaction.RemarkCustom || transaction.Trremk,
            customRemark:`${(transaction.trremk?.trim() || '-') } | ${(transaction.remarkCustom?.trim() || '-')}`,
            glsign: transaction.Dorc ? transaction.Dorc : '-',
            mutasiDebet: transaction.Amt ? this.formatNumber(transaction.Amt) : '0',
            mutasiKredit: '0',
            truser: '-',
            isSelected: false
        };
    }

    async fetchLatestTransactions() {
        console.log('fetchLatestTransactions called..');

        this.isLoadingLatest = true;
        this.hasLatestTransactionError = false;
        try {
            const requestPayload = {
                // norek: this.noRekening,
                norek: this.selectedNomorRekening,
                jt: "",
                recid: this.recordId
            };

            console.log('LatestTransaction request : ', JSON.stringify(requestPayload, null, 2));

            const result = await getLastTransaction(requestPayload);

            console.log('LatestTransaction response : ', JSON.stringify(result, null, 2));
            if (result && result.data && result.data.length > 0) {
                this.latestTransactions = result.data.map(trans => 
                    this.normalizeLatestTransaction(trans)
                );
                this.hasLatestTransactionError = false;
                console.log('LatestTransactions result : ', JSON.stringify(result, null, 2));
            } else {
                this.latestTransactions = [];
                this.hasLatestTransactionError = true;
                this.errorLatestTransactionMsg = 'Data tidak ditemukan';
            }
        } catch (error) {
            console.error('Error fetching latest transactions:', error.message);
            this.hasLatestTransactionError = true;
            this.errorLatestTransactionMsg = 'Terjadi kesalahan saat pencarian.';
        } finally {
            this.isLoadingLatest = false;
        }
    }

    // fetchLatestTransactions() {

    //     this.clearLatestTransactionResults();

    //     console.log('fetchLatestTransactions called..');

    //     this.isLoadingLatest = true;
    //     this.hasLatestTransactionError = false;

    //     const requestPayload = {
    //         norek: this.noRekening,
    //         jt: "",
    //         recid: this.recordId
    //     };

    //     console.log('LatestTransaction request : ', JSON.stringify(requestPayload, null, 2));

    //     getLastTransaction(requestPayload)
    //         .then(result => {

    //             console.log('LatestTransaction response : ', JSON.stringify(result, null, 2));
    //             if (result && result.data && result.data.length > 0) {
    //                 this.latestTransactions = result.data.map(trans => 
    //                     this.normalizeLatestTransaction(trans)
    //                 );
    //                 this.hasLatestTransactionError = false;
    //                 console.log('LatestTransactions result : ', JSON.stringify(result, null, 2));
    //             } else {
    //                 this.latestTransactions = [];
    //                 this.hasLatestTransactionError = true;
    //                 this.errorLatestTransactionMsg = 'Data tidak ditemukan';
    //             }
                
    //         })
    //         .catch(error => {
    //             console.error('Error fetching latest transactions:', error.message);
    //             this.hasLatestTransactionError = true;
    //             this.errorLatestTransactionMsg = 'Terjadi kesalahan saat pencarian.';
    //         })
    //         .finally(() => {
    //             this.isLoadingLatest = false;
    //             console.log('Loading state set to false.');
    //         });
    // }
    
    @api async updateLatestCardDetails() {
        console.log('aq 👉 Child: updateLatestCardDetails started...');

        console.log('aq Current noRekening:', this.noRekening);
        console.log('aq Selected noRekening:', this.selectedNomorRekening);
        
        // Always update if noRekening exists, regardless of previous selection
        // if (this.noRekening) {
        //     this.selectedNomorRekening = this.noRekening;
        //     console.log(`Fetching data for rekening: ${this.selectedNomorRekening}`);
        //     await this.fetchLatestTransactions(); // Wait for the fetch to complete
        // }

        // Only update if the card number is different
        if (this.noRekening && this.noRekening !== this.selectedNomorRekening) {
            this.selectedNomorRekening = this.noRekening;
            console.log(`Fetching data for new card number: ${this.selectedNomorRekening}`);
            await this.fetchLatestTransactions(); // Fetch new card details
        }
    }

    
    @api updateGrandchildHoldDetails() {
        setTimeout(() => {
            const blockedBankingComponent = this.template.querySelector('c-lwc-blocked-banking-information-component');
            if (blockedBankingComponent) {
                blockedBankingComponent.noRekening = this.selectedNomorRekening; // Pass the noRekening
                blockedBankingComponent.updateCardHoldDetails();
            } else {
                console.error('🚫 Child: Grandchild component not found!');
            }
        }, 0);
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
        this.validateDateField();
    }

    handleEndDateChange(event) {
        this.endDate = event.target.value;
        this.validateDateField();
    }

    validateDateField() {
        const today = this.getTodayDate();

         // Use setTimeout to allow for state change processing
         setTimeout(() => {
            if (this.startDate > today) {
                this.showToast('Error', 'Tanggal Awal tidak boleh melebihi hari ini.', 'error', '', '');
                this.startDate = today;
                // After setting the date to today, manually reset the input value
                this.template.querySelector('lightning-input[label="Tanggal Awal"]').value = today;
            }

            if (this.endDate > today) {
                this.showToast('Error', 'Tanggal Akhir tidak boleh melebihi hari ini.', 'error', '', '');
                this.endDate = today;
                // After setting the date to today, manually reset the input value
                this.template.querySelector('lightning-input[label="Tanggal Akhir"]').value = today;
            }
        }, 0); // Set to 0 to delay the reset to the next event loop iteration
    }

    validateDateRange(startDate, endDate) {
        const start = new Date(startDate);
        const end = new Date(endDate);
        const diffDays = (end - start) / (1000 * 60 * 60 * 24);
    
        // If the difference exceeds 31 days, return false and show an error
        if (diffDays > 31) {
            this.showToast('Error', 'Jarak tanggal tidak boleh lebih dari 31 hari.', 'error', '', '');
            return false;  // Invalid date range
        }
        return true;  // Valid date range
    }

    /** Default Release 2 */
    // handleCheckboxChange(event) {
    //     const selectedId = event.target.dataset.id;
    
    //     console.log(`Checkbox clicked with ID: ${selectedId}`);
    
    //     // Toggle selection: if the same checkbox is clicked, deselect it; otherwise, select the new one
    //     this.selectedRow = this.selectedRow === selectedId ? null : selectedId;
    
    //     // Update filteredData based on the new selectedRow
    //     this.filteredData = this.processedData(); //default use
    //     console.log('asd checked filteredData : ', JSON.stringify(this.filteredData, null,2))

    //     // GET TID LOGIC - Get only the data where isSelected is true
    //     this.checkedData = this.filteredData.find(row => row.isSelected);
    //     console.log('asd Checked data:', JSON.stringify(this.checkedData, null, 2));

    //     if (this.checkedData) {
    //         const savingMutationData = {
    //             idNum: this.checkedData.idNum || 0,
    //             idNum2: this.checkedData.idNum2 || 0,
    //             idNum3: this.checkedData.idNum3 || 0,
    //             seq: this.checkedData.seq || 0,
    //             noRek: parseFloat(this.checkedData.noRek) || 0, // Convert to Decimal
    //             tglTran: this.checkedData.tglTran || '',
    //             tglEfektif: this.checkedData.tglEfektif || '',
    //             jamTran: parseFloat(this.checkedData.jamTran) || 0, // Convert to Decimal
    //             kodeTran: this.checkedData.kodeTran || '',
    //             deskTran: this.checkedData.deskTran || '',
    //             saldoAwalMutasi: parseFloat(this.checkedData.saldoAwalMutasi) || 0, // Convert to Decimal
    //             mutasiDebet: parseFloat(this.checkedData.mutasiDebet) || 0, // Convert to Decimal
    //             mutasiKredit: parseFloat(this.checkedData.mutasiKredit) || 0, // Convert to Decimal
    //             saldoAkhirMutasi: parseFloat(this.checkedData.saldoAkhirMutasi) || 0, // Convert to Decimal
    //             truser: this.checkedData.truser || '',
    //             glsign: this.checkedData.glsign || '',
    //             terbilang: this.checkedData.terbilang || '',
    //             trremk: this.checkedData.trremk || '',
    //             auxtrc: this.checkedData.auxtrc || '',
    //             serial: this.checkedData.serial || '',
    //             tlbds1: this.checkedData.tlbds1 || '',
    //             tlbds2: this.checkedData.tlbds2 || ''
    //         };
    //         // Call Apex method and pass the checked data
    //         getTID({ data: savingMutationData})
    //             .then(result => {
    //                 this.tidValue = result;
    //                 console.log('asd TID results:', result);
    //                 // Handle the result from Apex
    //             })
    //             .catch(error => {
    //                 console.error('asd Error calling Apex method:', error);
    //             });
    //     }
    //     //END GET TID LOGIC

    //     // this.updateFilteredData();
    
    //     // Enable or disable the create button based on whether a row is selected
    //     if (this.recordId.startsWith('001')) { //account prefix
            
    //         this.isCreateButtonDisabled = !this.filteredData.some(row => row.isSelected);
    //     } else if(this.recordId.startsWith('500')) { //case prefix
            
    //         this.isUpdateButtonDisabled = !this.filteredData.some(row => row.isSelected);
    //     }
    // }

    /** v2 - For Release 3 with latest transaction */

    // Handle checkbox selection
    handleCheckboxChange(event) {
        const selectedId = event.target.dataset.id;
        const source = event.target.dataset.source;
        console.log(`Checkbox clicked with ID: ${selectedId} from source: ${source}`);

        // Reset previous selection
        this.selectedRow = this.selectedRow === selectedId ? null : selectedId;

        // Update selection based on source
        if (source === 'latest') {
            this.latestTransactions = this.latestTransactions.map(trans => ({
                ...trans,
                isSelected: trans.id === selectedId
            }));
            this.filteredData = this.filteredData.map(row => ({
                ...row,
                isSelected: false
            }));
            this.checkedData = this.latestTransactions.find(row => row.isSelected);
        } else {
            this.filteredData = this.processedData();
            this.latestTransactions = this.latestTransactions.map(trans => ({
                ...trans,
                isSelected: false
            }));
            this.checkedData = this.filteredData.find(row => row.isSelected);
        }

        // Get TID for selected transaction
        if (this.checkedData) {
            const savingMutationData = source === 'latest' ? 
                this.prepareLatestTransactionData(this.checkedData) :
                this.prepareRegularTransactionData(this.checkedData);

            getTID({ data: savingMutationData })
                .then(result => {
                    this.tidValue = result;
                    console.log('TID results:', result);
                })
                .catch(error => {
                    console.error('Error calling Apex method:', error);
                });
        }

        // Update button states
        if (this.recordId.startsWith('001')) {
            this.isCreateButtonDisabled = !this.checkedData;
        } else if (this.recordId.startsWith('500')) {
            this.isUpdateButtonDisabled = !this.checkedData;
        }
    }
    
    prepareLatestTransactionData(transaction) {
        const jamTran = transaction.customTime.replace(/:/g, '');
        return {
            idNum: 0,
            idNum2: 0,
            idNum3: 0,
            seq: 0,
            noRek: parseFloat(transaction.noRek) || 0,
            tglTran: transaction.customDate || '',
            tglEfektif: transaction.customDate || '',
            jamTran: parseFloat(jamTran) || 0,
            kodeTran: '',
            deskTran: transaction.customRemark || '',
            saldoAwalMutasi: 0,
            mutasiDebet: transaction.Amt  || 0,
            mutasiKredit: 0,
            saldoAkhirMutasi: 0,
            truser: transaction.truser || '',
            glsign: transaction.glsign || '',
            terbilang: '',
            trremk: transaction.trremk || '',
            auxtrc: '',
            serial: '',
            tlbds1: '',
            tlbds2: ''
        };
    }

    prepareRegularTransactionData(transaction) {
        return {
            idNum: transaction.idNum || 0,
            idNum2: transaction.idNum2 || 0,
            idNum3: transaction.idNum3 || 0,
            seq: transaction.seq || 0,
            noRek: parseFloat(transaction.noRek) || 0, // Convert to Decimal
            tglTran: transaction.tglTran || '',
            tglEfektif: transaction.tglEfektif || '',
            jamTran: parseFloat(transaction.jamTran) || 0, // Convert to Decimal
            kodeTran: transaction.kodeTran || '',
            deskTran: transaction.deskTran || '',
            saldoAwalMutasi: parseFloat(transaction.saldoAwalMutasi) || 0, // Convert to Decimal
            mutasiDebet: parseFloat(transaction.mutasiDebet) || 0, // Convert to Decimal
            mutasiKredit: parseFloat(transaction.mutasiKredit) || 0, // Convert to Decimal
            saldoAkhirMutasi: parseFloat(transaction.saldoAkhirMutasi) || 0, // Convert to Decimal
            truser: transaction.truser || '',
            glsign: transaction.glsign || '',
            terbilang: transaction.terbilang || '',
            trremk: transaction.trremk || '',
            auxtrc: transaction.auxtrc || '',
            serial: transaction.serial || '',
            tlbds1: transaction.tlbds1 || '',
            tlbds2: transaction.tlbds2 || ''
        };
    } 
    
    /** End v2 - For Release 3 with latest transaction */

    updateFilteredData() {
        this.filteredData = this.processedData();
    }

    processedData() {

        const formatterCurrency = new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0, // Adjust as needed
            maximumFractionDigits: 2, // Adjust as needed
        });


        return this.data.map((row, index) => {
            const dateObject = new Date(row.tglTran);
            const customDate = dateObject.toISOString().split('T')[0]; 
            // const customTime = dateObject.toTimeString().split(' ')[0];
            const customTime = this.formatTime(row.jamTran);

            return {
                ...row,
                // id: index + 1,
                // customDate,
                // customTime,
                // // mutasiDebet: formatterCurrency.format(row.mutasiDebet),
                // // mutasiKredit: formatterCurrency.format(row.mutasiKredit),
                // mutasiDebet: this.formatNumber(row.mutasiDebet),
                // mutasiKredit: this.formatNumber(row.mutasiKredit),
                // customRemark: `${(row.trremk?.trim() || '-') } | ${(row.tlbds1?.trim() || '-') } | ${(row.remarkCustom?.trim() || '-')}`,
                // // isSelected: this.selectedRow === (index + 1).toString() ,
                // isSelected: this.selectedRow === (index + 1).toString(),
                // // isDisabled: row.isProcessed || false //for disabled after case being created

                id: index + 1,
                customDate: customDate || '-',
                customTime: customTime || '-',
                noRek: row.noRek || '-',
                tglTran: row.tglTran || '-',
                tglEfektif: row.tglEfektif || '-',
                jamTran: row.jamTran || '-',
                kodeTran: row.kodeTran || '-',
                deskTran: row.deskTran || '-',
                saldoAwalMutasi: row.saldoAwalMutasi || '0',
                mutasiDebet: this.formatNumber(row.mutasiDebet || '0'),
                mutasiKredit: this.formatNumber(row.mutasiKredit || '0'),
                saldoAkhirMutasi: row.saldoAkhirMutasi || '0',
                truser: row.truser || '-',
                glsign: row.glsign || '-',
                terbilang: row.terbilang || '-',
                customRemark: `${(row.trremk?.trim() || '-')} | ${(row.tlbds1?.trim() || '-')} | ${(row.remarkCustom?.trim() || '-')}`,
                auxtrc: row.auxtrc || '-',
                serial: row.serial || '-',
                isSelected: this.selectedRow === (index + 1).toString()

            };
        });
        
    }

    /** v2 - Enchanced function for created Case created in 02 Desember 2024 */
    /** 
    handleCreateCase() {
        this.isLoadingCreateCase = true;

        const selectedRow = this.filteredData.find(row => row.isSelected);
        console.log('Selected Row:', JSON.stringify(selectedRow, null, 2));

        if (selectedRow) {
            console.log('Selected Row Data:', selectedRow);
            const fields = {};

            fields['RecordTypeId'] = this.recordTypeId;

            // Format the date field (SCC_Transaction_Date__c)
            const formattedDate = new Date(selectedRow.customDate).toISOString().split('T')[0];
            if (!formattedDate) {
                console.error('Invalid customDate:', selectedRow.customDate);
                this.showToast('Error', 'Invalid transaction date', 'error');
                this.isLoadingCreateCase = false;
                return; // Abort the process if date is invalid
            }
            fields['SCC_Transaction_Date__c'] = formattedDate;

            // Combine date and time to create the datetime field (SCC_Waktu_Transaksi__c)
            if (formattedDate && selectedRow.customTime) {
                console.log('Custom Date and Time:', formattedDate, selectedRow.customTime);

                // Ensure time is correctly formatted (HH:mm:ss)
                const formattedTime = selectedRow.customTime;
                if (!formattedTime) {
                    console.error('Invalid customTime:', selectedRow.customTime);
                    this.showToast('Error', 'Invalid transaction time', 'error');
                    this.isLoadingCreateCase = false;
                    return; // Abort the process if time is invalid
                }

                // Combine formattedDate and formattedTime to form the DateTime string
                const combinedDateTime = `${formattedDate}T${formattedTime}`;

                // Convert the combined string into a Date object
                const dateTimeObject = new Date(combinedDateTime);

                // Ensure the DateTime object is valid
                if (isNaN(dateTimeObject)) {
                    console.error('Invalid DateTime:', combinedDateTime);
                    this.showToast('Error', 'Invalid transaction datetime', 'error');
                    this.isLoadingCreateCase = false;
                    return; // Abort the process if DateTime is invalid
                }

                fields['SCC_Waktu_Transaksi__c'] = dateTimeObject.toISOString(); // Convert to ISO string format
            } else {
                console.error('Missing customDate or customTime');
                this.showToast('Error', 'Transaction date or time is missing', 'error');
                this.isLoadingCreateCase = false;
                return; // Abort the process if either date or time is missing
            }

            // Handle the currency fields (mutasiDebet and mutasiKredit)
            const rawDebet = selectedRow.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
            const rawKredit = selectedRow.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');

            console.log('Nominal Debet:', rawDebet);
            console.log('Nominal Kredit:', rawKredit);

            // Convert raw strings to numbers
            const mutasiDebet = Number(rawDebet);
            const mutasiKredit = Number(rawKredit);

            console.log('Nominal Debet (Number):', mutasiDebet);
            console.log('Nominal Kredit (Number):', mutasiKredit);

            // Format the output to the desired currency format
            if (mutasiDebet === 0 && mutasiKredit !== 0) {
                fields['SCC_Amount__c'] = mutasiKredit;
            } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
                fields['SCC_Amount__c'] = mutasiDebet;
            }

            fields['SCC_Account_Number__c'] = String(selectedRow.noRek) || null;
            fields['SCC_Card_Number__c'] = this.noKartu || null;
            fields['SCC_Terminal_ID__c'] = this.tidValue || null;
            fields['AccountId'] = this.accountId;

            // Prepare record input
            const recordInput = { apiName: 'Case', fields };

            // Create the case record
            createRecord(recordInput)
                .then(caseRecord => {
                    console.log('Successfully created record:', caseRecord);
                    console.log('Created Case ID:', caseRecord.id);
                    this.showToast(
                        'Sukses',
                        'Record berhasil ditambahkan! anda akan diarahkan ke halaman Case. Atau ',
                        'success',
                        caseRecord.id,
                        'Case' // Change this to 'Case' or whatever your object API name is
                    );

                    // Clear the selected row and update the filtered data
                    this.selectedRow = null;
                    this.filteredData = this.processedData();
                    this.isCreateButtonDisabled = true;

                    setTimeout(() => {
                    // Navigate to the newly created record after the delay
                    this.navigateToRecord(caseRecord.id, 'Case'); // Pass 'Case' as the objectApiName
                    }, 700);
                })
                .catch(error => {
                    const errorMessage = error.body?.message || 'An unknown error occurred.';
                    console.error('Error creating case:', errorMessage);
                    this.showToast('Error', `Error creating case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingCreateCase = false; // Make sure loading is turned off after the process is done
                });

        } else {
            // Show an error if no row is selected
            this.showToast('Error', 'No row selected. Please select a row to create a case.', 'error');
            this.isLoadingCreateCase = false; // Turn off the loading state if no row is selected
        }
    } */   
    /** End v2 - Enchanced function created in 02 Desember 2024 */

    /** v3 - Create Case For Release 3 with latest transaction */
    handleCreateCase() {
        this.isLoadingCreateCase = true;
    
        const selectedData = this.showLatestTransactions ? 
            this.latestTransactions.find(row => row.isSelected) :
            this.filteredData.find(row => row.isSelected);
    
        if (selectedData) {
            console.log('Selected Data:', selectedData);
            const fields = {};
    
            fields['RecordTypeId'] = this.recordTypeId;
    
            // Format date field
            const formattedDate = new Date(selectedData.customDate).toISOString().split('T')[0];
            if (!formattedDate) {
                this.showToast('Error', 'Invalid transaction date', 'error');
                this.isLoadingCreateCase = false;
                return;
            }
            fields['SCC_Transaction_Date__c'] = formattedDate;
    
            // Handle datetime field
            if (formattedDate && selectedData.customTime) {
                const combinedDateTime = `${formattedDate}T${selectedData.customTime}`;
                const dateTimeObject = new Date(combinedDateTime);
    
                if (isNaN(dateTimeObject)) {
                    this.showToast('Error', 'Invalid transaction datetime', 'error');
                    this.isLoadingCreateCase = false;
                    return;
                }
    
                fields['SCC_Waktu_Transaksi__c'] = dateTimeObject.toISOString();
            }
    
            // Handle amount based on transaction type
            if (this.showLatestTransactions) {
                const rawDebet = selectedData.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
                const mutasiDebet = Number(rawDebet);
                fields['SCC_Amount__c'] = mutasiDebet || 0;  // Use amt directly
            } else {
                const rawDebet = selectedData.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
                const rawKredit = selectedData.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');
                const mutasiDebet = Number(rawDebet);
                const mutasiKredit = Number(rawKredit);
    
                if (mutasiDebet === 0 && mutasiKredit !== 0) {
                    fields['SCC_Amount__c'] = mutasiKredit;
                } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
                    fields['SCC_Amount__c'] = mutasiDebet;
                }
            }
    
            fields['SCC_Account_Number__c'] = String(selectedData.noRek) || null;
            fields['SCC_Card_Number__c'] = this.noKartu || null;
            fields['SCC_Terminal_ID__c'] = this.tidValue || null;
            fields['AccountId'] = this.accountId;
    
            const recordInput = { apiName: 'Case', fields };
    
            createRecord(recordInput)
                .then(caseRecord => {
                    console.log('Successfully created record:', caseRecord);
                    this.showToast(
                        'Sukses',
                        'Record berhasil ditambahkan! anda akan diarahkan ke halaman Case. Atau ',
                        'success',
                        caseRecord.id,
                        'Case'
                    );
    
                    this.clearSelections();
                    this.isCreateButtonDisabled = true;
    
                    setTimeout(() => {
                        this.navigateToRecord(caseRecord.id, 'Case');
                    }, 700);
                })
                .catch(error => {
                    const errorMessage = error.body?.message || 'An unknown error occurred.';
                    console.error('Error creating case:', errorMessage);
                    this.showToast('Error', `Error creating case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingCreateCase = false;
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to create a case.', 'error');
            this.isLoadingCreateCase = false;
        }
    }
    /** End v3 - Create Case For Release 3 with latest transaction */

  
    /** v2 - Enchanced function for created Case created in 02 Desember 2024 */
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
            if (selectedRow.customDate && selectedRow.customTime) {
                const date = new Date(selectedRow.customDate);
    
                // Use the formatTime function to ensure time is correctly formatted
                const formattedTime = selectedRow.customTime;
                const timeParts = formattedTime.split(':');
                const hours = parseInt(timeParts[0], 10);
                const minutes = parseInt(timeParts[1], 10);
                const seconds = timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0;
    
                date.setHours(hours, minutes, seconds);
                const formattedDateTime = date.toISOString();
    
                fields['SCC_Waktu_Transaksi__c'] = formattedDateTime || null;
            } else {
                fields['SCC_Waktu_Transaksi__c'] = null;
            }
    
            // Handle currency fields (mutasiDebet and mutasiKredit)
            const rawDebet = selectedRow.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
            const rawKredit = selectedRow.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');
    
            console.log('Nominal Debet:', rawDebet);
            console.log('Nominal Kredit:', rawKredit);
    
            // Convert raw strings to numbers
            const mutasiDebet = Number(rawDebet);
            const mutasiKredit = Number(rawKredit);
    
            console.log('Nominal Debet:', mutasiDebet);
            console.log('Nominal Kredit:', mutasiKredit);
    
            // Format the output to the desired currency format
            if (mutasiDebet === 0 && mutasiKredit !== 0) {
                fields['SCC_Amount__c'] = mutasiKredit; // No need to use toFixed here
                console.log('Formatted Kredit Amount:', this.formatNumber(fields['SCC_Amount__c'].toString()));
            } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
                fields['SCC_Amount__c'] = mutasiDebet; // No need to use toFixed here
                console.log('Formatted Debet Amount:', this.formatNumber(fields['SCC_Amount__c'].toString()));
            }
    
            fields['SCC_Account_Number__c'] = String(selectedRow.noRek) || null;
            fields['SCC_Card_Number__c'] = this.noKartu || null;
            fields['SCC_Terminal_ID__c'] = this.tidValue || null;
            fields['AccountId'] = this.accountId;
    
            const recordInput = { fields };
    
            updateRecord(recordInput)
                .then(caseRecord => {
                    console.log('Successfully updated record: ', caseRecord);
                    this.showToast(
                        'Sukses', 
                        'Record berhasil diperbarui. ', 
                        'success', 
                        caseRecord.id, 
                        'Case'
                    );
    
                    // Optionally refresh the data
                    this.selectedRow = null;
                    this.filteredData = this.processedData();
                    this.isUpdateButtonDisabled = true;
    
                    // delay before navigating
                    // setTimeout(() => {
                    //     // Navigate to the updated record after the delay
                    //     this.navigateToRecord(caseRecord.id, 'Case'); // Pass 'Case' as the objectApiName
                    // }, 700);
                })
                .catch(error => {
                    const errorMessage = error.body?.message || 'An unknown error occurred.';
                    console.log('Error dalam pembaruan case:', errorMessage);
                    this.showToast('Error', `Error dalam pembaruan case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingUpdateCase = false; // Ensure loading state is turned off
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to update a case.', 'error');
        }
    }*/
    /** End v2 - Enchanced function for created Case created in 02 Desember 2024 */

    /** v3 - Update Case For Release 3 with latest transaction */
    handleUpdateCase() {
        this.isLoadingUpdateCase = true;
    
        const selectedData = this.showLatestTransactions ? 
            this.latestTransactions.find(row => row.isSelected) :
            this.filteredData.find(row => row.isSelected);
    
        if (selectedData) {
            const fields = {};
            fields['Id'] = this.recordId;
    
            // Format date field
            const formattedDate = new Date(selectedData.customDate).toISOString().split('T')[0];
            fields['SCC_Transaction_Date__c'] = formattedDate || null;
    
            // Handle datetime field
            if (selectedData.customDate && selectedData.customTime) {
                const date = new Date(selectedData.customDate);
                const formattedTime = selectedData.customTime;
                const timeParts = formattedTime.split(':');
                date.setHours(
                    parseInt(timeParts[0], 10),
                    parseInt(timeParts[1], 10),
                    timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0
                );
                fields['SCC_Waktu_Transaksi__c'] = date.toISOString();
            }
    
            // Handle amount based on transaction type
            if (this.showLatestTransactions) {
                const rawDebet = selectedData.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
                const mutasiDebet = Number(rawDebet);
                fields['SCC_Amount__c'] = mutasiDebet || 0;  // Use amt directly for latest transactions
            } else {
                // For search results, use the existing logic
                const rawDebet = selectedData.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
                const rawKredit = selectedData.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');
                const mutasiDebet = Number(rawDebet);
                const mutasiKredit = Number(rawKredit);
    
                if (mutasiDebet === 0 && mutasiKredit !== 0) {
                    fields['SCC_Amount__c'] = mutasiKredit;
                } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
                    fields['SCC_Amount__c'] = mutasiDebet;
                }
            }
    
            fields['SCC_Account_Number__c'] = String(selectedData.noRek) || null;
            fields['SCC_Card_Number__c'] = this.noKartu || null;
            fields['SCC_Terminal_ID__c'] = this.tidValue || null;
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
    
                    // Clear selections in both views
                    this.clearSelections();
                    this.isUpdateButtonDisabled = true;
    
                    // Update the view state
                    if (this.showLatestTransactions) {
                        this.fetchLatestTransactions(); // Refresh latest transactions
                    } else {
                        this.filteredData = this.filteredData.map(row => ({
                            ...row,
                            isSelected: false
                        }));
                    }
                })
                .catch(error => {
                    const errorMessage = error.body?.message || 'An unknown error occurred.';
                    console.error('Error updating case:', errorMessage);
                    this.showToast('Error', `Error dalam pembaruan case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingUpdateCase = false;
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to update the case.', 'error');
            this.isLoadingUpdateCase = false;
        }
    }
    /** End v3 - Update Case For Release 3 with latest transaction */


    deleteSelectedRow(rowId) {
        // Remove the selected row from data
        this.data = this.data.filter(row => row.noRek !== rowId); // Use a unique identifier

        // Update the filteredData based on the new data
        this.updateFilteredData();
    }

    /** Default Release 2 */
    // handleSearch() {
    //     this.isLoading = true;
    //     this.showTable = false;

    //     if (this.startDate && this.endDate) {

    //         // Call range validation method
    //         if (!this.validateDateRange(this.startDate, this.endDate)) {
    //             // If validation fails, return early
    //             this.isLoading = false;
    //             return;
    //         }

    //         let requestPayload = '';

    //         // const requestPayload = {
    //         //     norek: this.noRekening,
    //         //     tglawal: this.startDate,
    //         //     tglakhr: this.endDate,
    //         //     idacc: this.accountId
    //         // };

    //         console.log('Request Payload:', JSON.stringify(requestPayload));

    //         if (this.recordId.startsWith('001')) { // Account prefix
    //             requestPayload = {
    //                 norek: this.noRekening,
    //                 tglawal: this.startDate,
    //                 tglakhr: this.endDate,
    //                 idacc: this.accountId
    //             };
    //             console.log('Request Payload for Account:', JSON.stringify(requestPayload));
    //             getMutasiRekening(requestPayload)
    //             .then(result => {
    //                 console.log('Response mutasi rekening received:', result);
    //                 console.log('Response JSON mutasi rekening received:', JSON.stringify(result));

    //                 if (result && result.data) {
    //                     this.data = result.data;
    //                     console.log('asd result data : ', JSON.stringify(this.data, null, 2));
    //                     this.filteredData = this.processedData();
    //                     console.log('Filtered Data:', this.filteredData);
    //                     this.showTable = true;
    //                 } else {
    //                     this.handleSearchError('Data tidak ditemukan');
    //                     this.showToast('Error', 'Data tidak ditemukan', 'error', '','');
    //                 }
    //             })
    //             .catch(error => {
    //                 this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error', '','');
    //                 console.error('Error occurred during search:', error.message);
    //             })
    //             .finally(() => {
    //                 this.isLoading = false;
    //                 console.log('Loading state set to false.');
    //             });
                
    //         } else if (this.recordId.startsWith('500')) { // Case prefix
    //             requestPayload = {
    //                 norekVarchar: this.noRekening, // Use norekVarchar for Case
    //                 tanggalAwalDatetime: this.startDate,
    //                 tanggalAkhirDatetime: this.endDate,
    //                 idacc: this.accountId
    //             };
    //             console.log('Request Payload for Case:', JSON.stringify(requestPayload));
    //             getMutation(requestPayload)
    //             .then(result => {
    //                 console.log('Response mutasi rekening received:', result);
    //                 console.log('Response JSON mutasi rekening received:', JSON.stringify(result));

    //                 if (result && result.data) {
    //                     this.data = result.data;
    //                     this.filteredData = this.processedData();
    //                     console.log('Filtered Data:', this.filteredData);
    //                     this.showTable = true;
    //                 } else {
    //                     this.handleSearchError('Data tidak ditemukan');
    //                     this.showToast('Error', 'Data tidak ditemukan', 'error', '','');
    //                 }
    //             })
    //             .catch(error => {
    //                 this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error', '','');
    //                 console.error('Error occurred during search:', error.message);
    //             })
    //             .finally(() => {
    //                 this.isLoading = false;
    //                 console.log('Loading state set to false.');
    //             });
    //         }          
    //     } else {
    //         this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error', '','');
    //     }
    // }
    
    /** v2 - For Release 3 with latest transaction */
    handleSearch() {
        this.isLoadingSearch = true;
        this.showLatestTransactions = false;
        this.showTable = false;
        this.hasSearchError = false;

        if (this.startDate && this.endDate) {
            if (!this.validateDateRange(this.startDate, this.endDate)) {
                this.isLoadingSearch = false;
                return;
            }

            let requestPayload = '';

            if (this.recordId.startsWith('001')) {
                requestPayload = {
                    norek: this.noRekening,
                    tglawal: this.startDate,
                    tglakhr: this.endDate,
                    idacc: this.accountId
                };

                getMutasiRekening(requestPayload)
                    .then(result => {
                        if (result && result.data) {
                            console.log("result mutasi : ", JSON.stringify(result, null, 2))
                            this.data = result.data;
                            this.filteredData = this.processedData();
                            this.showTable = true;
                            this.hasSearchError = false;
                        } else {
                            this.data = [];
                            this.filteredData = [];
                            this.showTable = true;
                            this.hasSearchError = true;
                            this.errorSearchMsg = 'Data tidak ditemukan';
                            this.handleSearchError('Data tidak ditemukan');
                            this.showToast('Error', 'Data tidak ditemukan', 'error');
                        }
                    })
                    .catch(error => {
                        this.hasSearchError = true;
                        this.errorSearchMsg = 'Terjadi kesalahan saat pencarian.';
                        this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error');
                        console.error('Error occurred during search:', error.message);
                    })
                    .finally(() => {
                        this.isLoadingSearch = false;
                    });

            } else if (this.recordId.startsWith('500')) {
                requestPayload = {
                    norekVarchar: this.noRekening,
                    tanggalAwalDatetime: this.startDate,
                    tanggalAkhirDatetime: this.endDate,
                    idacc: this.accountId
                };

                getMutation(requestPayload)
                    .then(result => {
                        if (result && result.data) {
                            this.data = result.data;
                            this.filteredData = this.processedData();
                            this.showTable = true;
                            this.hasSearchError = false;
                        } else {
                            this.data = [];
                            this.filteredData = [];
                            this.showTable = true;
                            this.hasSearchError = true;
                            this.errorSearchMsg = 'Data tidak ditemukan';
                            this.handleSearchError('Data tidak ditemukan');
                            this.showToast('Error', 'Data tidak ditemukan', 'error');
                        }
                    })
                    .catch(error => {
                        this.hasSearchError = true;
                        this.errorSearchMsg = 'Terjadi kesalahan saat pencarian.';
                        this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error');
                        console.error('Error occurred during search:', error.message);
                    })
                    .finally(() => {
                        this.isLoadingSearch = false;
                    });
            }
        } else {
            this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error');
            this.isLoadingSearch = false;
        }
    }
    /** End v2 - For Release 3 with latest transaction */

    handleSearchError(errorMessage) {
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

    // @api handleClear() {
    //     this.startDate = this.getTodayDate();
    //     this.endDate = this.getTodayDate();
    //     this.selectedRow = null; 
    //     this.isCreateButtonDisabled = true; 
    //     this.isUpdateButtonDisabled = true; 
    //     this.showTable = false;

    //     this.filteredData = [...this.data];
    
    //     //this.showToast('Info', 'Filters have been cleared.', 'info');
    // }

    // Handle switching between views
    handleClearSearch() {
        // Reset search-related states
        this.showTable = false;
        this.data = [];
        this.filteredData = [];
        this.hasSearchError = false;
        this.errorSearchMsg = '';
        this.isLoadingSearch = false;

        // Reset selections
        this.selectedRow = null;
        this.isCreateButtonDisabled = true;
        this.isUpdateButtonDisabled = true;

        // Reset dates to today
        this.startDate = this.getTodayDate();
        this.endDate = this.getTodayDate();

        // Switch back to latest transactions view
        this.showLatestTransactions = true;
        
        // Refresh latest transactions
        this.fetchLatestTransactions();
    }

    // Enhanced handle clear
    @api handleClear() {
        this.hasLatestTransactionError = false;
        this.hasSearchError = false;
        this.errorLatestTransactionMsg = '';
        this.errorSearchMsg = '';
        this.startDate = this.getTodayDate();
        this.endDate = this.getTodayDate();
        this.selectedRow = null;
        this.isCreateButtonDisabled = true;
        this.isUpdateButtonDisabled = true;
        this.showTable = false;
        this.showLatestTransactions = true;
        this.data = [];
        this.filteredData = [];
        this.clearSelections();
        // this.fetchLatestTransactions(); // Refresh latest transactions
    }

    clearLatestTransactionResults() {
        console.log('Clearing latest transaction results...');
        
        // Clear the transaction array
        this.latestTransactions = [];
        
        // Reset error states
        this.hasLatestTransactionError = false;
        this.errorLatestTransactionMsg = '';
        
        // Reset loading state
        this.isLoadingLatest = false;
        
        // Reset selection tracking if needed
        this.selectedNomorRekening = null;
        
        console.log('Latest transaction results cleared');
    }

    // Clear selections helper
    clearSelections() {
        this.selectedRow = null;
        
        this.latestTransactions = this.latestTransactions.map(trans => ({
            ...trans,
            isSelected: false
        }));
        
        this.filteredData = this.filteredData.map(row => ({
            ...row,
            isSelected: false
        }));
    }

    handleError(error, context) {
        console.error(`Error in ${context}:`, error);
        let errorMessage = 'An unknown error occurred.';
        
        if (error.body && error.body.message) {
            errorMessage = error.body.message;
        } else if (typeof error === 'string') {
            errorMessage = error;
        }
    
        this.showToast('Error', errorMessage, 'error');
    
        // Reset loading states based on context
        switch (context) {
            case 'latestTransactions':
                this.latestTransactions = [];
                break;
            case 'search':
                this.isLoading = false;
                this.data = [];
                this.filteredData = [];
                break;
            case 'createCase':
                this.isLoadingCreateCase = false;
                break;
            case 'updateCase':
                this.isLoadingUpdateCase = false;
                break;
        }
    }

    handleCloseMutasiRek() {
        const closeEvent = new CustomEvent('close', {
            detail: { message: 'Close button clicked' }
        });
        this.handleClear();
        this.dispatchEvent(closeEvent);
    }

    // v1,Function to format the number with commas
    // formatNumber(numberString) {
    //     // Parse the input string to a float
    //     const parsedNumber = parseFloat(numberString);
    //     // Convert to string and add commas
    //     return parsedNumber.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    // }

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

     // Helper function to format time like 'jamTran' (e.g., '173705' => '17:37:05')
    formatTime(jamTran) {
        // Convert the jamTran number to a string
        let timeStr = jamTran.toString();

        // Ensure the time string has 6 digits, padding with zeros if necessary
        while (timeStr.length < 6) {
            timeStr = '0' + timeStr;
        }

        // Extract hours, minutes, and seconds
        const hours = timeStr.substring(0, 2);
        const minutes = timeStr.substring(2, 4);
        const seconds = timeStr.substring(4, 6);

        // Format the time as HH:mm:ss
        return `${hours}:${minutes}:${seconds}`;
    }

    formatDateString(dateStr) {
        const [day, month, year] = dateStr.split('/');
        return `${year}-${month}-${day}`;
    }

    formatTimeString(timeStr) {
        return `${timeStr.slice(0, 2)}:${timeStr.slice(2, 4)}:${timeStr.slice(4)}`;
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
                duration:6000,
            });
            this.dispatchEvent(event);
        }
    }

    // function to navigate to a record with dynamic objectApiName
    navigateToRecord(recordId, objectApiName) {
        // Use the NavigationMixin to navigate to the record's page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: objectApiName, // Use dynamic objectApiName
                actionName: 'view'
            }
        });
    }
}