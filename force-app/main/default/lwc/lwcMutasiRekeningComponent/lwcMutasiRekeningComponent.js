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
    // @track data = [
    //     { id: '1', nomorRekening: 123456789, tglTransaksi: '2024-09-01', jamTransaksi: '08:00:00', remarkTransaksi: 'Admin Fee', jenisTransaksi: 'VT', mutasiDebit: '10000', mutasiKredit: '0', userId: '12345' },
    //     { id: '2', nomorRekening: 123456789, tglTransaksi: '2024-09-01', jamTransaksi: '09:00:00', remarkTransaksi: 'Service Fee', jenisTransaksi: 'TX', mutasiDebit: '20000', mutasiKredit: '0', userId: '12345' },
    //     { id: '3', nomorRekening: 123456789, tglTransaksi: '2024-09-02', jamTransaksi: '10:00:00', remarkTransaksi: 'Refund', jenisTransaksi: 'RT', mutasiDebit: '0', mutasiKredit: '5000', userId: '12345' },
    //     { id: '4', nomorRekening: 123456789, tglTransaksi: '2024-09-03', jamTransaksi: '11:00:00', remarkTransaksi: 'Transfer', jenisTransaksi: 'TR', mutasiDebit: '15000', mutasiKredit: '0', userId: '12345' },
    //     { id: '5', nomorRekening: 123456789, tglTransaksi: '2024-09-04', jamTransaksi: '12:00:00', remarkTransaksi: 'Deposit', jenisTransaksi: 'DP', mutasiDebit: '0', mutasiKredit: '20000', userId: '12345' },
    //     { id: '6', nomorRekening: 123456789, tglTransaksi: '2024-09-04', jamTransaksi: '13:00:00', remarkTransaksi: 'Withdraw', jenisTransaksi: 'WD', mutasiDebit: '5000', mutasiKredit: '0', userId: '12345' },
    //     { id: '7', nomorRekening: 123456789, tglTransaksi: '2024-09-04', jamTransaksi: '14:00:00', remarkTransaksi: 'Interest', jenisTransaksi: 'IN', mutasiDebit: '0', mutasiKredit: '1000', userId: '12345' },
    //     { id: '8', nomorRekening: 123456789, tglTransaksi: '2024-09-05', jamTransaksi: '15:00:00', remarkTransaksi: 'Fee', jenisTransaksi: 'FE', mutasiDebit: '2000', mutasiKredit: '0', userId: '12345' },
    //     { id: '9', nomorRekening: 123456789, tglTransaksi: '2024-09-05', jamTransaksi: '16:00:00', remarkTransaksi: 'Payment', jenisTransaksi: 'PM', mutasiDebit: '8000', mutasiKredit: '0', userId: '123545' },
    //     { id: '10', nomorRekening: 123456789, tglTransaksi: '2024-09-05', jamTransaksi: '17:00:00', remarkTransaksi: 'Charge', jenisTransaksi: 'CH', mutasiDebit: '3000', mutasiKredit: '0', userId: '12345' },
    // ];
    
    /** 
    columns = [
        { label: 'Nomor Rekening', fieldName: 'nomorRekening', type: 'text' },
        { label: 'Tanggal Transaksi ', fieldName: 'tglTransaksi', type: 'date' },
        { label: 'Jam Transaksi', fieldName: 'jamTransaksi', type: 'datetime' },
        { label: 'Remark Transaksi', fieldName: 'remarkTransaksi', type: 'text' },
        { label: 'Jenis Transaksi', fieldName: 'jenisTransaksi', type: 'text' },
        { label: 'Mutasi Debit', fieldName: 'mutasiDebit', type: 'text' },
        { label: 'Mutasi Kredit', fieldName: 'mutasiKredit', type: 'text' },
        { label: 'User Id', fieldName: 'userId', type: 'text' },
    ];
    */

    // @track filteredData = [...this.data];
    @track filteredData = [];
    @track startDate = this.getTodayDate();
    @track endDate = this.getTodayDate();
    @track checkedData = {};
    @track tidValue;


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
        console.log('nomor rekening from parent : ', this.noRekening);
        console.log('nomor kartu from parent : ', this.noKartu);
        console.log('accountId from parent : ', this.accountId);
        console.log('recordId from parent : ', this.recordId);

        if (this.recordId.startsWith('001')) {  //account prefix
            this.showCreateCaseButton = true;
        } else if(this.recordId.startsWith('500')){ //case prefix
            this.showUpdateCaseButton = true;
        }
    }

    // renderedCallback(){
        
    // }

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
        
        // if (this.startDate > today) {
        //     this.showToast('Error', 'Tanggal Awal tidak boleh melebihi hari ini.', 'error', '','');
        //     this.startDate = today;
        // }

        // if (this.endDate > today) {
        //     this.showToast('Error', 'Tanggal Akhir tidak boleh melebihi hari ini.', 'error', '','');
        //     this.endDate = today; 
        // }

        // if (this.startDate && this.endDate) {
        //     const start = new Date(this.startDate);
        //     const end = new Date(this.endDate);
        //     const diffDays = (end - start) / (1000 * 60 * 60 * 24);

        //     if (diffDays > 31) {
        //         this.showToast('Error', 'Jarak tanggal tidak boleh lebih dari 31 hari.', 'error', '','');
        //         // this.endDate = ''; 
        //     }
        // }

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

            // Validate the range between start and end dates
            // if (this.startDate && this.endDate) {
            //     const start = new Date(this.startDate);
            //     const end = new Date(this.endDate);
            //     const diffDays = (end - start) / (1000 * 60 * 60 * 24);

            //     if (diffDays > 31) {
            //         this.showToast('Error', 'Jarak tanggal tidak boleh lebih dari 31 hari.', 'error', '', '');
            //     }
            // }
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
    


    // handleCheckboxChange(event) {
    //     const selectedId = event.target.dataset.id;

    //     console.log(`Checkbox clicked with ID: ${selectedId}`);

    //     // Update the state of the checkboxes
    //     this.filteredData = this.processedData().map(row => {
    //         if (row.id === selectedId) {
    //             return { ...row, isSelected: !row.isSelected };
    //         } else {
    //             return { ...row, isSelected: false };
    //         }
    //     });

    //     // Enable the Create Case button if a row is selected
    //     this.isCreateButtonDisabled = !this.filteredData.some(row => row.isSelected);
    // }

    // Not using ProcessedData() - WORKING
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

    //default USE
    
    /**
    handleCheckboxChange(event) {
        const selectedId = event.target.dataset.id;
    
        console.log(`Checkbox clicked with ID: ${selectedId}`);
    
        this.selectedRow = this.selectedRow === selectedId ? null : selectedId;
    
        this.filteredData = this.processedData();
    
        this.isCreateButtonDisabled = !this.filteredData.some(row => row.isSelected);
    }
    */

    handleCheckboxChange(event) {
        const selectedId = event.target.dataset.id;
    
        console.log(`Checkbox clicked with ID: ${selectedId}`);
    
        // Toggle selection: if the same checkbox is clicked, deselect it; otherwise, select the new one
        this.selectedRow = this.selectedRow === selectedId ? null : selectedId;
    
        // Update filteredData based on the new selectedRow
        this.filteredData = this.processedData(); //default use
        console.log('asd checked filteredData : ', JSON.stringify(this.filteredData, null,2))

        // GET TID LOGIC - Get only the data where isSelected is true
        this.checkedData = this.filteredData.find(row => row.isSelected);
        console.log('asd Checked data:', JSON.stringify(this.checkedData, null, 2));

        if (this.checkedData) {
            const savingMutationData = {
                idNum: this.checkedData.idNum || 0,
                idNum2: this.checkedData.idNum2 || 0,
                idNum3: this.checkedData.idNum3 || 0,
                seq: this.checkedData.seq || 0,
                noRek: parseFloat(this.checkedData.noRek) || 0, // Convert to Decimal
                tglTran: this.checkedData.tglTran || '',
                tglEfektif: this.checkedData.tglEfektif || '',
                jamTran: parseFloat(this.checkedData.jamTran) || 0, // Convert to Decimal
                kodeTran: this.checkedData.kodeTran || '',
                deskTran: this.checkedData.deskTran || '',
                saldoAwalMutasi: parseFloat(this.checkedData.saldoAwalMutasi) || 0, // Convert to Decimal
                mutasiDebet: parseFloat(this.checkedData.mutasiDebet) || 0, // Convert to Decimal
                mutasiKredit: parseFloat(this.checkedData.mutasiKredit) || 0, // Convert to Decimal
                saldoAkhirMutasi: parseFloat(this.checkedData.saldoAkhirMutasi) || 0, // Convert to Decimal
                truser: this.checkedData.truser || '',
                glsign: this.checkedData.glsign || '',
                terbilang: this.checkedData.terbilang || '',
                trremk: this.checkedData.trremk || '',
                auxtrc: this.checkedData.auxtrc || '',
                serial: this.checkedData.serial || '',
                tlbds1: this.checkedData.tlbds1 || '',
                tlbds2: this.checkedData.tlbds2 || ''
            };
            // Call Apex method and pass the checked data
            getTID({ data: savingMutationData})
                .then(result => {
                    this.tidValue = result;
                    console.log('asd TID results:', result);
                    // Handle the result from Apex
                })
                .catch(error => {
                    console.error('asd Error calling Apex method:', error);
                });
        }
        //END GET TID LOGIC

        // this.updateFilteredData();
    
        // Enable or disable the create button based on whether a row is selected
        if (this.recordId.startsWith('001')) { //account prefix
            
            this.isCreateButtonDisabled = !this.filteredData.some(row => row.isSelected);
        } else if(this.recordId.startsWith('500')) { //case prefix
            
            this.isUpdateButtonDisabled = !this.filteredData.some(row => row.isSelected);
        }
    }

    updateFilteredData() {
        this.filteredData = this.processedData();
    }

    processedData() {
        // return this.filteredData.map((row, index) => {

        //     const dateObject = new Date(item.tglTran);
    
        //     // Format the date and time
        //     const customDate = dateObject.toISOString().split('T')[0]; // 'YYYY-MM-DD'
        //     const customTime = dateObject.toTimeString().split(' ')[0]; // 'HH:MM:SS'

        //     return {
        //         ...row,
        //         // id: `${index + 1}`,
        //         id: index + 1,
        //         customDate, // Assign formatted date
        //         customTime,  // Assign formatted time
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


        return this.data.map((row, index) => {
            const dateObject = new Date(row.tglTran);
            const customDate = dateObject.toISOString().split('T')[0]; 
            const customTime = dateObject.toTimeString().split(' ')[0];

            return {
                ...row,
                id: index + 1,
                customDate,
                customTime,
                // mutasiDebet: formatterCurrency.format(row.mutasiDebet),
                // mutasiKredit: formatterCurrency.format(row.mutasiKredit),
                mutasiDebet: this.formatNumber(row.mutasiDebet),
                mutasiKredit: this.formatNumber(row.mutasiKredit),
                // isSelected: this.selectedRow === (index + 1).toString() ,
                isSelected: this.selectedRow === (index + 1).toString(),
                // isDisabled: row.isProcessed || false //for disabled after case being created
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
        console.log('jkl selectedRow', JSON.stringify(this.selectedRow, null, 2));
        console.log('handleCreateCase clicked..');
        
        if (selectedRow) {
            const fields = {};

            fields['RecordTypeId'] = this.recordTypeId;

           // Format the date field (SCC_Transaction_Date__c)
            const formattedDate = new Date(selectedRow.customDate).toISOString().split('T')[0];
            fields['SCC_Transaction_Date__c'] = formattedDate || null;

            // Combine date and time to create the datetime field (SCC_Waktu_Transaksi__c)
            if (selectedRow.customDate && selectedRow.customTime) {
                const date = new Date(selectedRow.customDate);

                const timeParts = selectedRow.customTime.split(':');
                const hours = parseInt(timeParts[0], 10);
                const minutes = parseInt(timeParts[1], 10);
                const seconds = timeParts.length > 2 ? parseInt(timeParts[2], 10) : 0; // Default to 0 if seconds are not provided

                date.setHours(hours, minutes, seconds);

                // Convert the updated date (with time) to ISO 8601 format
                const formattedDateTime = date.toISOString(); // format YYYY-MM-DDTHH:mm:ss.sssZ

                fields['SCC_Waktu_Transaksi__c'] = formattedDateTime || null;
            } else {
                fields['SCC_Waktu_Transaksi__c'] = null; // Handle the case where either date or time is missing
            }
            
            //v1, use this if using the IDR Formatter Currency
            // const rawDebet = selectedRow.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
            // const rawKredit = selectedRow.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');
    
            // console.log('Nominal Debet:', rawDebet);
            // console.log('Nominal Kredit:', rawKredit);
    
            // const mutasiDebet = Number(rawDebet);
            // const mutasiKredit = Number(rawKredit);
    
            // console.log('Nominal Debet:', mutasiDebet);
            // console.log('Nominal Kredit:', mutasiKredit);
    
            // if (mutasiDebet === 0 && mutasiKredit !== 0) {
            //     fields['SCC_Amount__c'] = parseFloat(mutasiKredit.toFixed(2)); 
            // } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
            //     fields['SCC_Amount__c'] = parseFloat(mutasiDebet.toFixed(2)); 
            // }
            //END v1, use this if using the IDR Formatter Currency

            // v2, use this if using formatNumber method
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
            // END v2, use this if using formatNumber method
    
            fields['SCC_Account_Number__c'] = String(selectedRow.noRek) || null;

            // fields['SCC_Card_Number__c'] = String(selectedRow.noKartu) || null;
            fields['SCC_Card_Number__c'] = this.noKartu || null;

            // fields['SCC_Terminal_ID__c'] = String(this.tidValue) || null;
            // console.log('asd tid for input create case : ', this.tidValue);
            fields['SCC_Terminal_ID__c'] = this.tidValue || null;
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
                    const errorMessage = error.body?.message || 'An unknown error occurred.';
                    console.log('Error dalam pembuatan case:', errorMessage);
                    this.showToast('Error', `Error dalam pembuatan case: ${errorMessage}`, 'error');
                })
                .finally(() => {
                    this.isLoadingCreateCase = false;
                });
        } else {
            this.showToast('Error', 'No row selected. Please select a row to create a case.', 'error');
        }
    }

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
    
            //v1, use this if using the IDR Formatter Currency
            // const rawDebet = selectedRow.mutasiDebet.replace(/[^0-9,-]/g, '').replace(',', '.');
            // const rawKredit = selectedRow.mutasiKredit.replace(/[^0-9,-]/g, '').replace(',', '.');
    
            // console.log('Nominal Debet:', rawDebet);
            // console.log('Nominal Kredit:', rawKredit);
    
            // const mutasiDebet = Number(rawDebet);
            // const mutasiKredit = Number(rawKredit);
    
            // console.log('Nominal Debet:', mutasiDebet);
            // console.log('Nominal Kredit:', mutasiKredit);
    
            // if (mutasiDebet === 0 && mutasiKredit !== 0) {
            //     fields['SCC_Amount__c'] = parseFloat(mutasiKredit.toFixed(2)); 
            // } else if (mutasiKredit === 0 && mutasiDebet !== 0) {
            //     fields['SCC_Amount__c'] = parseFloat(mutasiDebet.toFixed(2)); 
            // }
            //END v1, use this if using the IDR Formatter Currency

            // v2, use this if using formatNumber method
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
            // END v2, use this if using formatNumber method
    
            fields['SCC_Account_Number__c'] = String(selectedRow.noRek) || null; 
            // fields['SCC_Card_Number__c'] = String(selectedRow.noKartu) || null;
            fields['SCC_Card_Number__c'] = this.noKartu || null;
            // console.log('asd tid for input create case : ', this.tidValue);
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
    

    deleteSelectedRow(rowId) {
        // Remove the selected row from data
        this.data = this.data.filter(row => row.noRek !== rowId); // Use a unique identifier

        // Update the filteredData based on the new data
        this.updateFilteredData();
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

    //HandleSearch with spinner - ON USE (WORKING PROPERLY)
    
    /** 
    handleSearch() {
        this.isLoading = false;
        this.showTable = false;
        if (this.startDate && this.endDate) {
            this.isLoading = true;
            const start = new Date(this.startDate);
            const end = new Date(this.endDate);

            // Simulating data processing with a delay
            setTimeout(() => {
                this.filteredData = this.data.filter(record => {
                    const recordDate = new Date(record.tglTransaksi);
                    return recordDate >= start && recordDate <= end;
                });

                if (this.filteredData.length > 0) {
                    this.showTable = true;
                } else {
                    this.showTable = false;
                    this.showToast('Info', 'Data tidak ditemukan untuk rentang tanggal yang dipilih.', 'info');
                }
                
                this.isLoading = false; // Hide spinner after processing
            }, 1000); // Simulating a delay of 1 second
        } else {
            this.showTable = false;
            this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error');
        }
    }
    */

    //with integration
    /**
    handleSearch() {
        this.isLoading = false;
        this.showTable = false;
        if (this.startDate && this.endDate) {
            this.isLoading = true;
            const start = new Date(this.startDate);
            const end = new Date(this.endDate);

            // // Simulating data processing with a delay
            // setTimeout(() => {
            //     this.filteredData = this.data.filter(record => {
            //         const recordDate = new Date(record.tglTransaksi);
            //         return recordDate >= start && recordDate <= end;
            //     });

            //     if (this.filteredData.length > 0) {
            //         this.showTable = true;
            //     } else {
            //         this.showTable = false;
            //         this.showToast('Info', 'Data tidak ditemukan untuk rentang tanggal yang dipilih.', 'info');
            //     }
                
            //     this.isLoading = false; // Hide spinner after processing
            // }, 1000); // Simulating a delay of 1 second

            console.log('Function handleSearch called..');
    
            const requestPayload = {
                norek: this.noRekening,
                tglawal: this.startDate,
                tglakhr: this.endDate,
                idacc: this.accountId
    
            };
        
            console.log('Request Payload:', JSON.stringify(requestPayload));
        
            getMutasiRekening(requestPayload)
                .then(result => {
                    console.log('Response mutasi rekening received:', result);
        
                    // if (result && result.length > 0) {
                    if (result) {
                        const response = Array.isArray(result) ? result[0] : result;
                        console.log('masuk sini..');
                        console.log('response : ', JSON.stringify(response));
                        console.log('response.data : ', JSON.stringify(response.data));
        
                        // if (response.errorCode === '000' && response.responseCode === '00') {
                        if (response.data) {
                            this.data = Array.isArray(result) ? result : [response];
                            // this.filteredData = this.processedData();
                            // console.log('filtered data : ', JSON.stringify(this.filteredData));
                            this.showTable = true;
                            this.errorMsg = '';
                            this.hasError = false;
                        } else {
                            this.handleSearchError(response.responseMessage || 'Data tidak ditemukan');
                            this.showTable = false;
                            this.showToast('Error', 'Data tidak ditemukan', 'error');

                        }
                    } else { 
                        this.handleSearchError('Data tidak ditemukan');
                        this.showTable = false;
                        this.showToast('Error', 'Data tidak ditemukan', 'error');
                    }
                })
                .catch(error => {
                    this.showToast('Error', 'Terjadi kesalahan saat pencarian.', 'error');
                    console.error('Error occurred during search:', error.message);
                    this.handleSearchError('Data tidak ditemukan');
                })
                .finally(() => {
                    this.isLoading = false;
                    console.log('Loading state set to false.');
                });

        } else {
            this.showTable = false;
            this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error');
        }
    

    } 
    */

    handleSearch() {
        this.isLoading = true;
        this.showTable = false;

        if (this.startDate && this.endDate) {

            // Call range validation method
            if (!this.validateDateRange(this.startDate, this.endDate)) {
                // If validation fails, return early
                this.isLoading = false;
                return;
            }

            let requestPayload = '';

            // const requestPayload = {
            //     norek: this.noRekening,
            //     tglawal: this.startDate,
            //     tglakhr: this.endDate,
            //     idacc: this.accountId
            // };

            console.log('Request Payload:', JSON.stringify(requestPayload));

            if (this.recordId.startsWith('001')) { // Account prefix
                requestPayload = {
                    norek: this.noRekening,
                    tglawal: this.startDate,
                    tglakhr: this.endDate,
                    idacc: this.accountId
                };
                console.log('Request Payload for Account:', JSON.stringify(requestPayload));
                getMutasiRekening(requestPayload)
                .then(result => {
                    console.log('Response mutasi rekening received:', result);
                    console.log('Response JSON mutasi rekening received:', JSON.stringify(result));

                    if (result && result.data) {
                        this.data = result.data;
                        console.log('asd result data : ', JSON.stringify(this.data, null, 2));
                        this.filteredData = this.processedData();
                        console.log('Filtered Data:', this.filteredData);
                        this.showTable = true;
                    } else {
                        this.handleSearchError('Data tidak ditemukan');
                        this.showToast('Error', 'Data tidak ditemukan', 'error', '','');
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
                
            } else if (this.recordId.startsWith('500')) { // Case prefix
                requestPayload = {
                    norekVarchar: this.noRekening, // Use norekVarchar for Case
                    tanggalAwalDatetime: this.startDate,
                    tanggalAkhirDatetime: this.endDate,
                    idacc: this.accountId
                };
                console.log('Request Payload for Case:', JSON.stringify(requestPayload));
                getMutation(requestPayload)
                .then(result => {
                    console.log('Response mutasi rekening received:', result);
                    console.log('Response JSON mutasi rekening received:', JSON.stringify(result));

                    if (result && result.data) {
                        this.data = result.data;
                        this.filteredData = this.processedData();
                        console.log('Filtered Data:', this.filteredData);
                        this.showTable = true;
                    } else {
                        this.handleSearchError('Data tidak ditemukan');
                        this.showToast('Error', 'Data tidak ditemukan', 'error', '','');
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
        } else {
            this.showToast('Error', 'Pilih tanggal terlebih dahulu.', 'error', '','');
        }
    }
    

    // get filteredData() {
    //     return this.data.map((item, index) => {
    //         const dateObject = new Date(item.tglTran);
    
    //         // Format the date and time
    //         const customDate = dateObject.toISOString().split('T')[0]; // 'YYYY-MM-DD'
    //         const customTime = dateObject.toTimeString().split(' ')[0]; // 'HH:MM:SS'
    
    //         return {
    //             ...item,
    //             id: `${index + 1}`,
    //             customDate, // Assign formatted date
    //             customTime  // Assign formatted time
    //         };
    //     });
    // }

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

    @api handleClear() {
        this.startDate = this.getTodayDate();
        this.endDate = this.getTodayDate();
        this.selectedRow = null; 
        this.isCreateButtonDisabled = true; 
        this.isUpdateButtonDisabled = true; 
        this.showTable = false;

        this.filteredData = [...this.data];
    
        //this.showToast('Info', 'Filters have been cleared.', 'info');
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