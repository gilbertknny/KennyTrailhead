/** 
    LWC Name    : lwcDataPengajuanKreditComponent.js
    Created Date       : 12 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   12/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   24/09/2024   Rakeyan Nuramria                  Add API Functionality

**/

import { LightningElement, track, api, wire } from 'lwc';
import getPengajuanKartu from '@salesforce/apex/SCC_CaseBRICare.getPengajuanKartu';

export default class LwcDataPengajuanKreditComponent extends LightningElement {

    @api caseId
    @track nik = '';
    @track nikNumberError = '';
    @track isLoading = false;
    @track disableNIKField = false;
    @track showResult = false;
    @track hasError = false;
    @track errorMsg = '';
    @track data = [];


    @track cardInfo = {
        namaNasabah: 'John Doe',
        nik: '1234567890123456',
        tglLahir: '01 Januari 1999',
        kodePengajuan: '123456',
        tglPengajuan: '01 Januari 2024',
        channelPengajuan: 'Marketing/Online',
        nomorKartu: '123456789012-456',
        progressPengajuan: 'Dalam Proses'
    };

    connectedCallback(){
        console.log('pengajuan caseId from parent : ', this.caseId);
    }

    get isCariButtonDisabled() {
        return !(this.nik);
    }

    fetchDataPengajuanKredit() {
        console.log('function fetchDataPengajuanKredit called..');
        this.isLoading = true;
    
        const requestPayload = {
            idNumber: this.nik,
            idcs: this.caseId
        };
    
        console.log('Request pengajuan payload:', JSON.stringify(requestPayload));
    
        getPengajuanKartu(requestPayload)
        .then(result => {
            console.log('Response card detail received:', JSON.stringify(result));
    
            const response = result?.CUSTPERSONAL;
    
            // Check if response is an array and has at least one element
            if (Array.isArray(response) && response.length > 0) {
                this.data = response[0]; // Access the first element of the array
                console.log('custpersonal:', JSON.stringify(this.data));
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
            console.log('Loading state set to false.');
        });
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.nikNumberError = '';
        this.data = [];
        this.isLoading = false;
        console.log('Error Message:', errorMessage);
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

            if (this.nik.length > 16) {
                this.nikNumberError = 'NIK tidak boleh melebihi 16 digit angka.';
            }
        }
        else {
            this.nikNumberError = null;
        }
    }

    handleSearch() {
        this.isLoading = true;
        this.showResult = false;
        this.fetchDataPengajuanKredit();
    }

    clearInputFields() {
        this.nik = '';
        this.debitNumber = '';
        this.errorMsg = '';
        this.nikNumberError = '';
        this.isLoading = false;
        this.showResult = false;
        this.data = [];

    }
}