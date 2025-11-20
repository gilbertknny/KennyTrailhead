import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import makeCallout from '@salesforce/apex/SCC_CardAndDigitalLandingCallout.getCustomerDataByPhone';
import getCustomerDataByNIK from '@salesforce/apex/SCC_CardAndDigitalLandingCallout.getCustomerDataByNIK';
import getPCTD from '@salesforce/apex/SCC_CardAndDigitalLandingCallout.getPCTD';
import getCardlinkByCardNumber from '@salesforce/apex/SCC_CardAndDigitalLandingCallout.getCardlinkByCardNumber';
import CASE_OBJECT from '@salesforce/schema/Case';
import PHONE_FIELD from '@salesforce/schema/Case.SCC_Cust_Phone1__c';

export default class CreditCardTabError extends LightningElement {
    @api recordId;
    @track phoneNumber;
    @track customerData;
    @track showCustomerData = false;
    @track error;
    @track error1;
    @track showresult = false;
    @track isCustomerPortfolioExpanded = false;
    parsedData1;
    @track parsedData2;
    @track nik = '';
    @track isInputFilled = false;
    @track customerData1;

    @wire(getRecord, { recordId: '$recordId', fields: [PHONE_FIELD] })
    caseRecord({ error, data }) {
        if (data) {
            this.phoneNumber = data.fields.SCC_Cust_Phone1__c.value;
            if (this.phoneNumber && this.isCustomerPortfolioExpanded) {
                this.fetchCustomerData(this.phoneNumber);
            } else if (this.isCustomerPortfolioExpanded && !this.phoneNumber) {
                this.error = 'Nomor telepon tidak ada untuk melakukan panggilan API..';
            }
        } else if (error) {
            this.error = error.body ? error.body.message : 'Unknown error';
        }
    }

    handleAccordionSectionToggle(event) {
        this.isCustomerPortfolioExpanded = event.detail.openSections.includes('customerPortfolio');
        if (this.isCustomerPortfolioExpanded && this.phoneNumber) {
            this.fetchCustomerData(this.phoneNumber);
        } else if (this.isCustomerPortfolioExpanded && !this.phoneNumber) {
            this.error = 'Nomor telepon tidak ada untuk melakukan panggilan API.';
        }
    }

    fetchCustomerData(phoneNumber) {
        makeCallout({ phoneNumber })
            .then(result => {
                if (result && result.length > 0) {
                    this.customerData = this.processData(result);
                    this.showCustomerData = true;
                    this.error = undefined;
                } else {
                    this.error = 'Data customer tidak ditemukan.';
                    this.customerData = [];
                }
            })
            .catch(error => {
                this.error = error.body ? error.body.message : 'Kesalahan tidak diketahui.';
                this.customerData = [];
            });
    }

    processData(result) {
        return result.map(item => {
            let nama = `${item.namaDepan || ''} ${item.namaTengah || ''} ${item.namaBelakang || ''}`.trim();
            let status = item.status === 'Active' ? 'Active' : 'Inactive';
            // Concatenate alamatKantor fields
            let alamatKantor = `${item.alamatKantorDepan || ''} ${item.alamatKantorTengah || ''} ${item.alamatKantorBelakang || ''}`.trim();

            // Concatenate alamatRumah fields
            let alamatRumah = `${item.alamatRumahDepan || ''} ${item.alamatRumahBelakang || ''}`.trim();
            return {
                ...item,
                Nama: nama,
                status: status,
                alamatKantor: alamatKantor,
                alamatRumah: alamatRumah,
                showDropdown: false // Initialize dropdown visibility flag
            };
        });
    }
    handleDataTransaksiClick(event) {
        // Access the target element of the event
        const target = event.target || event.srcElement;
    
        // Find the closest ancestor tr element
        const closestTr = target.closest('tr');
    
        // Access the data-id attribute of the closest tr element
        const selectedItem = closestTr.dataset.id;
    
    
        if (!this.customerData || this.customerData.length === 0) {
            this.error = 'Riwayat data transaksi tidak tersedia.';
            return;
        }
    
    
        const selectedTransaction = this.customerData.find(item => item.cardNumber === selectedItem);
    
        if (selectedTransaction) {
            getPCTD({
                cardNumber: selectedTransaction.cardNumber,
            })
            .then(result => {
                this.parsedData1 = result;
                
                // Handle the result accordingly
            })
            .catch(error => {
                // Handle the error accordingly
            });
        } else {
            // Handle the scenario where the selected transaction is not found
        }
    }
    
    handleDataKartu(event) {
        const selectedCardNumber = event.currentTarget.dataset.id;
            
        if (!this.customerData || this.customerData.length === 0) {
            this.error = 'Riwayat data transaksi tidak tersedia.';
            return;
        }
        
        
        const selectedTransaction1 = this.customerData.find(item => item.cardNumber === selectedCardNumber);
        
        if (selectedTransaction1) {
            // Log the request body before making the API call
            console.log('Request Body:', JSON.stringify({
                cardNo: selectedTransaction1.cardNumber
            }));
            
            getCardlinkByCardNumber({
                cardNo: selectedTransaction1.cardNumber
            })
            .then(result => {
                this.parsedData2 = result;
            
                // Handle the result accordingly
            })
            .catch(error => {
                // Handle the error accordingly
            });
        } else {
            // Handle the scenario where the selected transaction is not found
        }
    }
    
    fetchTransactionData(cardNumber) {
        fetchTransactionData({ cardNumber })
            .then(result => {
                // Process the retrieved transaction data here
            })
            .catch(error => {
            });
    }
    handleSearch() {
        // Get the NIK value from the input field
        const nikInput = this.template.querySelector('lightning-input');
        const nikNumber = nikInput.value;
    
        // Call the new method to fetch customer data by NIK
        getCustomerDataByNIK({ nikNumber })
            .then(result => {
                if (result && result.length > 0) {
                    this.customerData1 = result;
                    this.showresult = true;
                    this.error1 = undefined;
                } else {
                    this.error1 = 'Data tidak ditemukan';
                    this.customerData1 = [];
                }
            })
            .catch(error1 => {
                this.error1 = error1.body ? error1.body.message : 'Kesalahan tidak diketahui.';
                this.customerData1 = [];
            });
    }
    handleInputChange(event) {
        this.nik = event.target.value;
        // Update the input filled status
        this.isInputFilled = this.nik.trim() !== '';
    }
}