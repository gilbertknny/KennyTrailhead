/** 
    LWC Name    : lwcBlockedBankingInformationComponent.js
    Created Date       : ?? September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   ??/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   30/09/2024   Rakeyan Nuramria                  Adjust API functionality
    1.0   31/10/2024   Rakeyan Nuramria                  Adjust format amount currency

**/

import { LightningElement,track, api, wire } from 'lwc';
import getHoldStatus from '@salesforce/apex/SCC_CaseBRICare.getHoldStatus';

export default class LwcBlockedBankingInformationComponent extends LightningElement {
    @api recordId;
    @api noRekening;
    
    @track isLoading = false;
    @track hasError = false;
    @track errorMsg = '';
    @track errorMessage = '';
    @track data = [];

    generateDummyData(){
        return [
            {
                id: '1',
                status_blokir: 'Blocked',
                nominal_blokir: '210000',
                unit_kerja: 'Finance',
                tanggal_blokir: '2024-09-01',
                keterangan_blokir: 'Dummy Initial block'
            },
            {
                id: '2',
                status_blokir: 'Unblocked',
                nominal_blokir: '1000000',
                unit_kerja: 'HR',
                tanggal_blokir: '2024-09-15',
                keterangan_blokir: 'Dummy Resolved issue'
            }
        ]
    }

    connectedCallback(){

        this.fetchDataHoldStatus();

        // try {
        //     // this.data = this.generateDummyData();

        //     // Format
        //     this.data = this.data.map(item => ({
        //         ...item,
        //         nominal_blokir: this.formatCurrency(item.nominal_blokir)
        //     }));

        // } catch (error) {
        //     this.errorMessage = 'An error occurred while fetching data.';
        // }

    }

    fetchDataHoldStatus() {

        this.isLoading = true;

        console.log('function fetchDataHoldStatus called..');
    
        const requestPayload = {
            norek: this.noRekening,
            idcs: this.recordId
        };
    
        console.log('Request Hold Status payload:', JSON.stringify(requestPayload));
    
        getHoldStatus(requestPayload)
            .then(result => {
                console.log('Response result fetchDataHoldStatus received:', result);
                console.log('Response result fetchDataHoldStatus received:', JSON.stringify(result));
    
                if (result) {
                    const responseInquiryHoldStatus = result?.inquiryHoldStatus;
                    console.log('fetchDataHoldStatus ', responseInquiryHoldStatus);
                    this.errorMsg = '';
                    this.hasError = false;
    
                    // Process inquiryHoldStatus data
                    if (responseInquiryHoldStatus && responseInquiryHoldStatus.data && responseInquiryHoldStatus.data.length > 0) {
                        this.data = responseInquiryHoldStatus.data.map(item => ({
                            ...item,
                            holdAmt: this.formatNumber(item.holdAmt)
                        }));
    
                        // this.showSearchResults = true;
    
                        console.log('Formatted inquiryHoldStatus Data:', JSON.stringify(this.data));
                    } else {
                        this.handleSearchError('Informasi Hold Rekening kosong.');
                    }
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search fetchDataHoldStatus:', error.message);
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
        this.isLoading = false;
        this.data = [];
        console.log('Error Message:', errorMessage);
    }

    //if want tp use IDR format
    formatCurrency(value) {
        const formatter = new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        });
        return formatter.format(value);
    }

    //for formatting number
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

}