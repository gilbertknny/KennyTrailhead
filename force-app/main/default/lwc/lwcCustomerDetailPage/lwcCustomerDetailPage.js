/** 
    LWC Name    : lwcCustomerDetailPage.js
    Created Date       : 25 August 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   26/08/2024   Rakeyan Nuramria                  Initial Version
    2.0   28/08/2024   Rakeyan Nuramria                  Adjust the functionality to UI v2
    2.1   03/09/2024   Rakeyan Nuramria                  Adjust to show empty string from social media not undefined
    2.1   09/09/2024   Rakeyan Nuramria                  Adjust logic save to accept empty string
    2.1   22/09/2024   Rakeyan Nuramria                  Adjust logic API using new connection
    2.1   09/10/2024   Rakeyan Nuramria                  [ON GOING] Add condition for show data if clcd in the JSON return
    2.1   10/10/2024   Rakeyan Nuramria                  [DONE] Add condition for show data if clcd in the JSON return
    2.1   14/10/2024   Rakeyan Nuramria                  Adjust show error
**/

import { LightningElement, wire, track, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAccRecord from '@salesforce/apex/SCC_AccountInformationController.getAccountData'
import updateAccountFields from '@salesforce/apex/SCC_AccountInformationController.updateAccountFields'
import makeCallout from '@salesforce/apex/SCC_CustomerProfileSearchbyPhone.initiateCalloutUsingMobileNumber';
import getInformasiCustomer from '@salesforce/apex/SCC_Account_UI.getInformasiCustomer';

export default class LwcCustomerDetailPage extends LightningElement {
    @api recordId;
    @api iconName;
    @track accountData = {};
    @track isFacebookEditing = false;
    @track isInstagramEditing = false;
    @track isXEditing = false;    
    @track isFacebookInputDisabled = true;
    @track isInstagramInputDisabled = true;
    @track isXInputDisabled = true;
    @track isSaving = false;
    @track preventBlur = false;

    // Current input fields
    @track namaNasabahInput = '';
    @track usiaInput = '';
    @track alamatInput = '';
    @track noHpInput = '';
    @track emailInput = '';
    @track facebookInput = '';
    @track instagramInput = '';
    @track xInput = '';
    @track jenisNasabahInput = '';
    @track tipeNasabahInput = '';
    @track sumberDataInput = '';

    // Original input fields
    @track originalFacebookInput = '';
    @track originalInstagramInput = '';
    @track originalXInput = '';

    //for PoC
    @track dataCustomer = [];

    //error
    @track errorMsg = '';
    @track hasErrorBrinets = false;
    @track hasErrorCardlink = false;

    connectedCallback(){
        // this.makeCalloutandUpdateAccount();
        this.fetchInformasiCustomer();
    }

    @wire(getAccRecord, { recordId: '$recordId' })
    wiredAccount(result) {
        this.wiredAccountResult = result;
        if (result.data) {
            if(result.data.RecordType.Name=='Person Account'){
                this.iconName = 'utility:user';
            }else{
                this.iconName = 'standard:account';
            }

            // this.accountData = result.data;
            // this.namaNasabahInput = result.data.Name;
            // this.usiaInput = result.data.SCC_TanggalLahir__c;
            // this.alamatInput = result.data.SCC_Address__c;
            // this.noHpInput = result.data.Phone;
            // this.emailInput = result.data.SCC_Primary_Email__c;
            this.facebookInput = result.data.SCC_Facebook__c || '';
            this.instagramInput = result.data.SCC_Instagram__c || '';
            this.xInput = result.data.SCC_X__c || '';
            // this.jenisNasabahInput = result.data.SCC_Jenis_Nasabah__c;
            // this.tipeNasabahInput = result.data.SCC_Tipe_Nasabah__c;
            // this.sumberDataInput = result.data.SCC_Sumber_Data__c;

            // Store original values
            this.originalFacebookInput = this.facebookInput;
            this.originalInstagramInput = this.instagramInput;
            this.originalXInput = this.xInput;
        } else if (result.error) {
            this.error = error.body.message;
        }
    }

    handleFacebookEditClick() {
        console.log('button edit clicked..');
        this.isFacebookInputDisabled = false;
        this.isSaving = false; 
        this.preventBlur = false;
        // this.originalFacebookInput = this.facebookInput;
        this.focusInput('facebookInput');

        // setTimeout(() => {
        //     const inputField = this.template.querySelector('input[data-id="facebookInput"]');
        //     if (inputField) {
        //         inputField.focus();
        //     }
        // }, 0);
    }
    
    handleInstagramEditClick() {
        console.log('button edit clicked..');
        this.isInstagramInputDisabled = false;
        this.isSaving = false; 
        this.preventBlur = false;
        // this.originalInstagramInput = this.instagramInput; 
        this.focusInput('igInput');

        // setTimeout(() => {
        //     const inputField = this.template.querySelector('input[data-id="igInput"]');
        //     if (inputField) {
        //         inputField.focus();
        //     }
        // }, 0);
    }

    handleXEditClick() {
        this.isXInputDisabled = false;
        this.isSaving = false; 
        this.preventBlur = false;
        // this.originalXInput = this.xInput;
        this.focusInput('xInput');

        // setTimeout(() => {
        //     const inputField = this.template.querySelector('input[data-id="xInput"]');
        //     if (inputField) {
        //         inputField.focus();
        //     }
        // }, 0);
    }

    focusInput(inputId) {
        setTimeout(() => {
            const inputField = this.template.querySelector(`input[data-id="${inputId}"]`);
            if (inputField) {
                inputField.focus();
            }
        }, 0);
    }

    handleFacebookInputChange(event) {
        console.log('Facebook input changed to:', event.target.value);
        this.facebookInput = event.target.value;
        
    }

    handleInstagramInputChange(event) {
        console.log('Instagram input changed to:', event.target.value);
        this.instagramInput = event.target.value;
    }
    handleXInputChange(event) {
        console.log('X input changed to:', event.target.value);
        this.xInput = event.target.value;
    }

    handleBlur() {
        if (!this.isSaving && !this.preventBlur) {
            this.facebookInput = this.originalFacebookInput || '';
            this.instagramInput = this.originalInstagramInput || '';
            this.xInput = this.originalXInput || '';

            this.isFacebookInputDisabled = true;
            this.isInstagramInputDisabled = true;
            this.isXInputDisabled = true;
        }
    }

    // handleBlur(event) {
    //     const fieldName = event.target.dataset.id;
    //     if (!this.isSaving && !this.preventBlur) {
    //         // const fieldName = event.target.dataset.id;
            
    //         // Check if the value is empty and handle accordingly
    //         if (this[fieldName].trim() === '') {
    //             this[fieldName] = '';
    //         } else {
    //             this[fieldName] = this['original' + fieldName.charAt(0).toUpperCase()];
    //         }

    //         console.log('Blur updated input value for', fieldName, ':', this[fieldName]);
    
    //         // Disable input fields
    //         this.isFacebookInputDisabled = true;
    //         this.isInstagramInputDisabled = true;
    //         this.isXInputDisabled = true;
    //     }
    // }
    
    handleSaveButtonMouseDown() {
        this.preventBlur = true;
    }

    // handleSubmit() {
    //     this.isSaving = true;

    //     setTimeout(() => {
    //         this.preventBlur = false;
    //     }, 0);

    //     this.saveRecord();
    // }

    handleSubmit() {
        this.isSaving = true;
        setTimeout(() => {
            this.preventBlur = false;
        }, 0);
        console.log('Submitting:', JSON.stringify({
            facebook: this.facebookInput,
            instagram: this.instagramInput,
            x: this.xInput
        }));
        this.saveRecord();
    }

    // saveRecord() {
    //     updateAccountFields({
    //         accountId: this.recordId,
    //         facebook: this.facebookInput,
    //         instagram: this.instagramInput,
    //         x: this.xInput
    //     })
    //     .then(() => {
    //         // Update the original input values
    //         this.originalFacebookInput = this.facebookInput;
    //         this.originalInstagramInput = this.instagramInput;
    //         this.originalXInput = this.xInput;
    //         // Reset editing state and saving flag
    //         this.isFacebookInputDisabled = true;
    //         this.isInstagramInputDisabled = true;
    //         this.isXInputDisabled = true;
    //         this.isSaving = false;
    //         return refreshApex(this.wiredAccountResult);
    //     })
    //     .catch(error => {
    //         this.error = error.body ? error.body.message : 'An unexpected error occurred.';
    //         this.isSaving = false;
    //     });
    // }

    //v2 - ON DEV
    saveRecord() {
        console.log('Saving record with:', JSON.stringify({
            facebook: this.facebookInput,
            instagram: this.instagramInput,
            x: this.xInput
        }));
    
        updateAccountFields({
            accountId: this.recordId,
            facebook: this.facebookInput || null,
            instagram: this.instagramInput || null,
            x: this.xInput || null
        })
        .then(() => {
            this.originalFacebookInput = this.facebookInput;
            this.originalInstagramInput = this.instagramInput;
            this.originalXInput = this.xInput;

            this.isFacebookInputDisabled = true;
            this.isInstagramInputDisabled = true;
            this.isXInputDisabled = true;
            this.isSaving = false;
            return refreshApex(this.wiredAccountResult);
        })
        .catch(error => {
            this.error = error.body.message;
            this.isSaving = false;
        });
    }
    
    

    async makeCalloutandUpdateAccount(){
        try {
            const calloutResult = await makeCallout({accountId: this.recordId});
            if (calloutResult.success) {
                this.successMessage = calloutResult.message;
                await refreshApex(this.wiredAccountResult);
            } else {
                this.error = calloutResult.message;
                await refreshApex(this.wiredAccountResult);
            }
        } catch (error) {
            this.error = error.body ? error.body.message : 'An unexpected error occurred.';
        }
    }


    /** ===== FOR PoC ===== **/
    /*
    async fetchInformasiCustomer() {
        console.log('Function fetchInformasiCustomer called..');
    
        const requestPayload = {
            idacc: this.recordId
        };
    
        console.log('Request Customer Payload:', JSON.stringify(requestPayload));
    
        try {
            const result = await getInformasiCustomer(requestPayload);
            console.log('Response Customer received:', result);
            console.log('bnm Response Customer received:', JSON.stringify(result, null, 2));
    
            // for CPG data
            if (result && result.cpg && result.cpg.data.length > 0) {
                const cpgData = result.cpg.data[0];
                console.log('cpg data: ', JSON.stringify(cpgData));
    

                // this.namaNasabahInput = cpgData.demografi.namaLengkap || '';
                this.namaNasabahInput = cpgData.demografi.namaSesuaiIdentitas || ''; //Adjust from SIT => the correct value
                this.usiaInput = cpgData.demografi.umur || '';
                this.alamatInput = cpgData.demografi.alamatSesuaiID + ' ' + cpgData.demografi.alamatSesuaiID2 || '';
                this.noHpInput = cpgData.demografi.handphone || '';
                this.emailInput = cpgData.demografi.email || '';
                // this.facebookInput = cpgData.demografi. || '';
                // this.instagramInput = cpgData.demografi. || ''; 
                // this.xInput = cpgData.SCC_X__c || '';
                // this.jenisNasabahInput = cpgData.demografi.tipeNasabah || '';
                const tipeNasabah = cpgData.demografi.nasabahPrioritas;
                // this.jenisNasabahInput = tipeNasabah === 'Yes' ? 'Prioritas' : 'Non Prioritas';
                this.jenisNasabahInput = tipeNasabah //FROM SIT => The correct value
                // this.tipeNasabahInput = cpgData.demografi.tipeNasabah || '';
                this.tipeNasabahInput = cpgData.demografi.tipeNasabahDesc || ''; //FROM SIT => The correct value
    
                this.sumberDataInput = 'BRINETS';

                this.errorMsg = '';
                this.hasErrorBrinets = false;

                await refreshApex(this.wiredAccountResult);
            } else {
                this.handleSearchError('Data tidak ditemukan');
                await refreshApex(this.wiredAccountResult);
                this.hasErrorBrinets = true;
            }

            // for CLCD data
            if (result && result.clcd && result.clcd.response) {
                console.log('bnm condition for the clcd..');
                
                // Extract additional data, card holder data, and customer data
                const clcdAdditionalData = result.clcd.response.additionalData ? result.clcd.response.additionalData[0] : null;
                const clcdCardHolderData = result.clcd.response.cardHolderData ? result.clcd.response.cardHolderData[0] : null;
                const clcdCustomerData = result.clcd.response.customerData ? result.clcd.response.customerData[0] : null;

                // Log the extracted data if available
                if (clcdAdditionalData) {
                    console.log('bnm clcdAdditionalData: ', JSON.stringify(clcdAdditionalData, null, 2));
                } else {
                    console.log('bnm No additional data found');
                }

                if (clcdCardHolderData) {
                    console.log('bnm clcdCardHolderData: ', JSON.stringify(clcdCardHolderData, null, 2));
                } else {
                    console.log('bnm No card holder data found');
                }

                if (clcdCustomerData) {
                    console.log('bnm clcdCustomerData: ', JSON.stringify(clcdCustomerData, null, 2));
                } else {
                    console.log('bnm No customer data found');
                }

                // Assuming you want to populate some input fields with the customer data:
                this.namaNasabahInput = clcdCustomerData ? clcdCustomerData.namaDepan + ' ' + clcdCustomerData.namaBelakang : '';
                // this.usiaInput = clcdCustomerData ? clcdCustomerData.tanggalLahir : '';
                this.usiaInput = clcdCustomerData ? this.calculateAge(clcdCustomerData.tanggalLahir) : '';
                this.alamatInput = (clcdCustomerData ? clcdCustomerData.alamatRumahDepan + ', ' + clcdCustomerData.alamatRumahBelakang : '');
                this.noHpInput = clcdCustomerData ? clcdCustomerData.nomorHandphoneTerdaftar : '';
                this.emailInput = clcdCustomerData ? clcdCustomerData.alamatEmail : '';

                const tipeNasabah = clcdCardHolderData ? clcdCardHolderData.jenisKartu : '';
                this.jenisNasabahInput = tipeNasabah;
                this.tipeNasabahInput = clcdCardHolderData ? clcdCardHolderData.tipeNasabah : '';
                this.sumberDataInput = 'CARDLINK';

                this.errorMsg = '';
                this.hasErrorCardlink = false;

                await refreshApex(this.wiredAccountResult);
            } else {
                console.log('bnm data clcd tidak ditemukan');
                this.handleSearchError('Data tidak ditemukan');
                await refreshApex(this.wiredAccountResult);
                this.hasErrorCardlink = true;
            }


        } catch (error) {
            this.hasError = true;
            console.error('Error occurred during search customer:', error.message);
            this.handleSearchError('Data tidak ditemukan');
        }
    }
    */

    async fetchInformasiCustomer() {
        console.log('Function fetchInformasiCustomer called..');
    
        const requestPayload = {
            idacc: this.recordId
        };
    
        console.log('Request Customer Payload:', JSON.stringify(requestPayload));
    
        try {
            const result = await getInformasiCustomer(requestPayload);
            console.log('Response Customer received:', result);
            console.log('bnm Response Customer received:', JSON.stringify(result, null, 2));
    
            // Reset error message
            this.errorMsg = '';
    
            // Initialize error flags
            let foundBrinetsData = false;
            let foundCardlinkData = false;
    
            // Handle CPG data (BRINETS)
            if (result && result.cpg && result.cpg.data.length > 0) {
                const cpgData = result.cpg.data[0];
                console.log('cpg data: ', JSON.stringify(cpgData));
    
                this.namaNasabahInput = cpgData.demografi.namaSesuaiIdentitas || '';
                this.usiaInput = cpgData.demografi.umur || '';
                this.alamatInput = cpgData.demografi.alamatSesuaiID + ' ' + cpgData.demografi.alamatSesuaiID2 || '';
                this.noHpInput = cpgData.demografi.handphone || '';
                this.emailInput = cpgData.demografi.email || '';
                this.jenisNasabahInput = cpgData.demografi.nasabahPrioritas;
                this.tipeNasabahInput = cpgData.demografi.tipeNasabahDesc || '';
    
                this.sumberDataInput = 'BRINETS';
                foundBrinetsData = true; // Data found
            } else {
                console.log('Data BRINETS tidak ditemukan');
            }
    
            // Handle CLCD data (CARDLINK)
            if (result && result.clcd && result.clcd.response) {
                console.log('bnm condition for the clcd..');
    
                const clcdCustomerData = result.clcd.response.customerData ? result.clcd.response.customerData[0] : null;
                const clcdCardHolderData = result.clcd.response.cardHolderData ? result.clcd.response.cardHolderData[0] : null;
    
                this.namaNasabahInput = clcdCustomerData ? clcdCustomerData.namaDepan + ' ' + clcdCustomerData.namaBelakang : '';
                this.usiaInput = clcdCustomerData ? this.calculateAge(clcdCustomerData.tanggalLahir) : '';
                this.alamatInput = clcdCustomerData ? clcdCustomerData.alamatRumahDepan + ', ' + clcdCustomerData.alamatRumahBelakang : '';
                this.noHpInput = clcdCustomerData ? clcdCustomerData.nomorHandphoneTerdaftar : '';
                this.emailInput = clcdCustomerData ? clcdCustomerData.alamatEmail : '';
    
                this.jenisNasabahInput = clcdCardHolderData ? clcdCardHolderData.jenisKartu : '';
                this.tipeNasabahInput = clcdCardHolderData ? clcdCardHolderData.tipeNasabah : '';
                this.sumberDataInput = 'CARDLINK';
                foundCardlinkData = true; // Data found
            } else {
                console.log('Data CARDLINK tidak ditemukan');
            }
    
            // Set error message based on which data is missing
            if (!foundBrinetsData && !foundCardlinkData) {
                // this.errorMsg = 'Data tidak ditemukan untuk BRINETS dan CARDLINK';
                this.handleSearchError('Data tidak ditemukan');
                this.hasError = true;
            }

            // } else if (!foundBrinetsData) {
            //     // this.errorMsg = 'Data tidak ditemukan untuk BRINETS';
            //     this.handleSearchError('Data tidak ditemukan');
            //     this.hasErrorBrinets = true;

            // } else if (!foundCardlinkData) {
            //     // this.errorMsg = 'Data tidak ditemukan untuk CARDLINK';
            //     this.handleSearchError('Data tidak ditemukan');
            //     this.hasErrorCardlink = true;

            // }
    
        } catch (error) {
            this.hasError = true;
            console.error('Error occurred during search customer:', error.message);
            this.handleSearchError('Data tidak ditemukan');
        }
    }
    
    
    

    calculateAge(birthDate) {
        if (!birthDate) return '';
    
        let birthDateObj;
    
        // Check the format of the date
        if (/^\d{8}$/.test(birthDate)) { // Format: YYYYMMDD
            const year = parseInt(birthDate.substring(0, 4), 10);
            const month = parseInt(birthDate.substring(4, 6), 10) - 1; // Months are 0-based in JavaScript
            const day = parseInt(birthDate.substring(6, 8), 10);
            birthDateObj = new Date(year, month, day);
        } else if (/^\d{4}-\d{2}-\d{2}$/.test(birthDate)) { // Format: YYYY-MM-DD
            birthDateObj = new Date(birthDate);
        } else {
            return ''; // Invalid format
        }
    
        const today = new Date();
        let age = today.getFullYear() - birthDateObj.getFullYear();
        const monthDifference = today.getMonth() - birthDateObj.getMonth();
    
        // Adjust age if the birth date hasn't occurred yet this year
        if (monthDifference < 0 || (monthDifference === 0 && today.getDate() < birthDateObj.getDate())) {
            age--;
        }
    
        return age;
    }
    

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        console.log('Error Message:', errorMessage);
    }
    /** ===== END FOR PoC ===== **/


}