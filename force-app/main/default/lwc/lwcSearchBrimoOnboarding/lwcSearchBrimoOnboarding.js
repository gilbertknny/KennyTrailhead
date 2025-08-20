/** 
    LWC Name    : lwcSearchBrimoOnboarding.js
    Created Date       : 14 July 2025
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   14/07/2025   Rakeyan Nuramria                  Initial Version
**/

import { LightningElement, track, wire, api } from 'lwc';

export default class LwcSearchBrimoOnboarding extends LightningElement {

    @track isLoading = false;
    @track showResult = false;
    @track nik = '';
    @track nikNumberError = '';
    @track hasError = false;
    @track errorMsg = '';
    @track responseData = {};

    get isSearchButtonDisabled(){
        return !(this.nik && !this.nikNumberError);
    }

    get disableNIKField(){
        return this.isLoading;
    }

    // Optional: Use getters only when you need data transformation or formatting
    // Example getter for status formatting (currently not needed for simple display)
    /*
    get displayStatus(){
        const status = this.responseData.status_description || '';
        return status ? `Status: ${status}` : 'No Status Available';
    }
    */

    fetchDataPengajuanKreditMock() {
        console.log('Mock function fetchDataPengajuanKreditMock called..');
        this.isLoading = true;
        this.hasError = false;
        this.showResult = false;
        
        // Mocked response based on the example JSON provided
        const mockResponse = {
            response_code: "00",
            response_refnum: "123456789192",
            response_id: "5ec1b4d33c1f4b6b9c5f06cc3b68d523",
            response_description: "Success",
            response_data: {
                account: "",
                name: "John Doe",
                nik: this.nik, // Use the searched NIK
                status: 3,
                status_description: "Validate phone"
            }
        };

        // Simulate a delay to mimic server behavior
        setTimeout(() => {
            try {
                const response = mockResponse;
                
                // Check if the response is successful
                if (response.response_code === "00" && response.response_data) {
                    this.responseData = response.response_data;
                    this.errorMsg = '';
                    this.hasError = false;
                    this.showResult = true;
                } else {
                    this.handleSearchError('Data tidak ditemukan atau terjadi kesalahan');
                }
            } catch (error) {
                console.error('Error occurred during mock search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            } finally {
                this.isLoading = false;
            }
        }, 1000); // Simulate a 1-second server response delay
    }

    // Mock function for empty response scenarios
    fetchDataEmptyResponseMock() {
        console.log('Mock function fetchDataEmptyResponseMock called..');
        this.isLoading = true;
        this.hasError = false;
        this.showResult = false;
        
        // Determine which type of empty response to return based on NIK
        const nikLastDigit = this.nik.charAt(this.nik.length - 1);
        let mockResponse;
        
        switch (nikLastDigit) {
            case '1': // Null response_data
                mockResponse = {
                    response_code: "00",
                    response_refnum: "123456789192",
                    response_id: "5ec1b4d33c1f4b6b9c5f06cc3b68d523",
                    response_description: "Success",
                    response_data: null
                };
                break;
            case '2': // Missing response_data
                mockResponse = {
                    response_code: "00",
                    response_refnum: "123456789192",
                    response_id: "5ec1b4d33c1f4b6b9c5f06cc3b68d523",
                    response_description: "Success"
                };
                break;
            case '3': // Error response code
                mockResponse = {
                    response_code: "01",
                    response_refnum: "123456789192",
                    response_id: "5ec1b4d33c1f4b6b9c5f06cc3b68d523",
                    response_description: "Data not found",
                    response_data: null
                };
                break;
            case '4': // Server error response
                mockResponse = {
                    response_code: "99",
                    response_refnum: "123456789192",
                    response_id: "5ec1b4d33c1f4b6b9c5f06cc3b68d523",
                    response_description: "Internal server error",
                    response_data: null
                };
                break;
            default: // Default case (including '0' and any other): Empty response_data
                mockResponse = {
                    response_code: "00",
                    response_refnum: "123456789192",
                    response_id: "5ec1b4d33c1f4b6b9c5f06cc3b68d523",
                    response_description: "Success",
                    response_data: {}
                };
                break;
        }

        // Simulate a delay to mimic server behavior
        setTimeout(() => {
            try {
                const response = mockResponse;
                
                // Check if response is completely empty (shouldn't happen in this function)
                if (Object.keys(response).length === 0) {
                    this.handleSearchError('Server tidak merespons');
                    return;
                }
                
                // Check response code
                if (response.response_code !== "00") {
                    const errorMsg = response.response_description || 'Terjadi kesalahan pada server';
                    this.handleSearchError(errorMsg);
                    return;
                }
                
                // Check if response_data exists and is not empty
                if (!response.response_data || 
                    (typeof response.response_data === 'object' && Object.keys(response.response_data).length === 0)) {
                    this.handleSearchError('Data tidak ditemukan untuk NIK yang dicari');
                    return;
                }
                
                // If all checks pass, display the data
                this.responseData = response.response_data;
                this.errorMsg = '';
                this.hasError = false;
                this.showResult = true;
                
            } catch (error) {
                console.error('Error occurred during mock search:', error.message);
                this.handleSearchError('Terjadi kesalahan saat memproses data');
            } finally {
                this.isLoading = false;
            }
        }, 1500); // Simulate a 1.5-second server response delay
    }

    // Helper function to check if object is empty
    isObjectEmpty(obj) {
        return obj === null || obj === undefined || 
               (typeof obj === 'object' && Object.keys(obj).length === 0);
    }

    handleSearch(){
        if (this.nik && !this.nikNumberError) {
            // Use different mock functions based on NIK pattern
            const nikLastDigit = this.nik.charAt(this.nik.length - 1);
            
            if (parseInt(nikLastDigit) >= 5) {
                // Use success mock for NIK ending with 5-9
                this.fetchDataPengajuanKreditMock();
            } else {
                // Use empty/error mock for NIK ending with 0-4
                this.fetchDataEmptyResponseMock();
            }
        }
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.showResult = false;
        this.responseData = {};
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
            this.nikNumberError = '';
        }
    }

    clearInputFields() {
        this.nik = '';
        this.errorMsg = '';
        this.nikNumberError = '';
        this.isLoading = false;
        this.showResult = false;
        this.responseData = {};
        this.hasError = false;
    }
    


}