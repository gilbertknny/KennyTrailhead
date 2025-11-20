/** 
    LWC Name    : lwcTIDSearchBankingComponent.js
    Created Date       : 11 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   11/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   11/09/2024   Rakeyan Nuramria                  Add API Functionality

**/


import { LightningElement, api, track, wire } from 'lwc';
import getAddressSuggestions from '@salesforce/apex/SCC_MachineDataByAddress.getAddressSuggestions';
import getMachine from '@salesforce/apex/SCC_CaseBRICare.getMachine';

export default class LwcTIDSearchBankingComponent extends LightningElement {
    @api caseId;
    @track hasError = false;
    @track errorMsg = '';
    @track isLoading = false;
    @track address = '';
    @track errorAddress;
    @track showAddressSuggestions = false;
    @track data = [];

    generateDummyData(){
        return [
            { number: 1, tid: '12345', nomorKartu: '1234567890', alamatMesin: 'Jakarta', kontakld: '02212328137'}
        ]
    }

    connectedCallback(){
        console.log('caseId from parent : ', this.caseId);
    }

    get isAddressCariButtonDisabled() {
        return !this.address;
    }

    handleAddressChange(event) {
        this.address = event.target.value;
        if (!this.address) {
            this.clearAddressResults();
        }
    }

    clearAddressResults() {
        this.addressSuggestions = [];
        this.data = [];
        this.isLoading = false;
        this.showaddressSuggestions = false;
        this.errorMsg = undefined;
    }

    handleAddressSearch() {
        //for dummy data
        // this.showAddressSuggestions = true;
        // this.data = this.generateDummyData();
        //End for dummy data

        console.log('Function handleSearch called..');

        this.isLoading = true;
    
        const requestPayload = {
            alamatMesin: this.address,
            tid: null,
            idcs: this.caseId
        };
    
        console.log('Request machine Payload:', JSON.stringify(requestPayload));
    
        // getMachine(requestPayload)
        //     .then(result => {
        //         console.log('Response machine received:', result);
        //         console.log('Response machine received:', JSON.stringify(result));
        //         console.log('Response result.machineDataByAddress received:', result.machineDataByAddress);

        //         // if (result && result.length > 0) {
        //         if (result) {
        //             const response = Array.isArray(result) ? result[0] : result;
        //             console.log('masuk sini..');
        //             if (response) {
        //                 this.data = Array.isArray(result) ? result : [response];
        //                 this.errorMsg = '';
        //                 this.showAddressSuggestions = true;
        //                 this.hasError = false;
        //             } else {
        //                 this.handleSearchError(response.responseMessage || 'Data tidak ditemukan');
        //             }
        //         } else { 
        //             this.handleSearchError('Data tidak ditemukan');
        //         }
        //     })
        //     .catch(error => {
        //         console.error('Error occurred during search:', error.message);
        //         this.handleSearchError('Data tidak ditemukan');
        //     })
        //     .finally(() => {
        //         this.isLoading = false;
        //         console.log('Loading state set to false.');
        //     });

        getMachine(requestPayload)
        .then(result => {
            if (result && result.machineDataByAddress) {
                this.data = result.machineDataByAddress.map((machine, index) => ({
                    ...machine,
                    no: index + 1
                }));
                this.showAddressSuggestions = true;
                this.errorMsg = '';
                this.hasError = false;
            } else {
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            this.handleSearchError('Data tidak ditemukan');
        })
        .finally(() => {
            this.isLoading = false;
        });
        


        // getAddressSuggestions({ address: this.address })
        //     .then((result) => {
        //         if (result.length === 0) {
        //             // No data received
        //             this.errorAddress = 'Data tidak ditemukan.';
        //             this.data = [];
        //             this.showdata = false;
        //         } else {
        //             // Data received
        //             this.data = result.map((record, index) => ({
        //                 ...record,
        //                 rowNumber: index + 1
        //             }));
        //             this.showdata = true;
        //             this.errorAddress = undefined;
        //         }
        //     })
        //     .catch((error) => {
        //         // Error occurred
        //         this.errorAddress = 'An error occurred while fetching address suggestions';
        //         this.data = [];
        //         this.showdata = false;
        //     });
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.data = []
        this.hasError = true;
        this.isLoading = false;
        // this.bankingData = [];
        console.log('Error Message:', errorMessage);
    }

}