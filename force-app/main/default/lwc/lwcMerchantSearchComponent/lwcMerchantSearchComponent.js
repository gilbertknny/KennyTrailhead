/** 
    LWC Name    : lwcMerchantSearchComponent.js
    Created Date       : 12 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   12/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   25/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   01/10/2024   Rakeyan Nuramria                  [FROM SIT] Add '000' to mid for search transaction
    1.0   23/10/2024   Rakeyan Nuramria                  Adjust logic to close transaction section when no input
    1.0   31/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic show detail to N/A if empty/null
    1.1   26/02/2025   Nabila Febri Viola                Change row index from TID to MID for Detail Merchant

**/

import { LightningElement, track, api, wire } from 'lwc';
import makeCallout from '@salesforce/apex/SCC_MerchantCallout.makeCallout';
import getMerchant from '@salesforce/apex/SCC_CaseBRICare.getMerchant';

export default class LwcMerchantSearchComponent extends LightningElement {
    @api caseId;
    @api isCloseHidden = false;
    @track isLoading = false;
    @track tid = '';
    @track mid = '';
    @track errorMessage;
    @track showSearchResults = false;
    @track showDetailSection = false;
    @track data =[];
    @track isSearchTrxComponentVisible = false;
    @track selectedTID;
    @track selectedMID;

    @track showTransaksiMerchant = false;
    scrollToTransaksi = false;

    @track currentDetailData = {}; // To hold the processed data

    generateDummyData(){
        return [
            {
                mid: "1234567890",
                nama_merchant_edc: "Toko Serba Ada",
                nama_merchant_qris: "Toko Serba Ada (QRIS)",
                alamat_merchant: "Jl. Raya No. 100, Jakarta Selatan",
                tid: "9876543210",
                status_pemasangan: "Aktif",
                kanwil: "Jakarta Pusat",
                vendor_pemasang: "PT Mitra Pemasang",
                tanggal_pasang: "2024-08-15",
                showSection: false,
                regional_office_pengelola: "Kanwil Jakarta Pusat",
                nomor_telepon_merchant: "021-12345678",
                channel_merchant: "EDC & QRIS",
                jenis_usaha_merchant: "Retail",
                tanggal_update_data: "2024-09-11",
                nomor_rekening_penampungan: "1234567890123456",
                jenis_merchant: "Micro Merchant",
                kode_unit_kerja: "JKT-001",
                kantor_wilayah: "Jakarta Pusat",
                nama_pic_unit_kerja: "Andi",
                pn_pic_unit_kerja: "1234567890",
                tanggal_dibuat: "2024-08-14",
                tanggal_modifikasi_terakhir: "2024-09-11",
                modifikasi_oleh: "Budi",
                data_promo: "Diskon 10% untuk semua produk",
                detail: "Toko ini menjual berbagai macam barang kebutuhan sehari-hari",
                status_ticket: "Open",
                user_pemrakarsa: "Uker Pusat",
                pic_merchant: "Nina",
                telpon: "021-98765432",
                email: "toko@serbaada.com",
                perangkat: "SN EDC: 0000000001, SN CLR: 1111111111, SN SIMCARD: 2222222222",
                detail_edc: "Debit & Kredit",
                tipe_merchant: "Offline",
                mdr_onus: "0.5%",
                mdr_offus: "1%",
                mdr_mastercard: "0.7%",
                mdr_debit_pl: "1.2%",
                mdr_debit_npg: "1.5%",
                mdr_unik: "-",
                mcc_master: "5813",
                mcc_visa: "5813",
                mcc_npg: "-",
                code_reffnum: "123456",
                no_batch: "789012",
                rc: "00",
                tipe: "Regular"
              }
        ]
    }

    get isHandleSearchDisabled() {
        return !(this.tid || this.mid);
    }

    renderedCallback() {
        //for focus to the content
        if (this.scrollToTransaksi) {
            this.scrollToComponent('scrollable-transaction-container', 'transaksi-merchant-component');
            this.scrollToTransaksi = false;
        }
        //end for focus to the content
    
    }

    fetchMerchantData(){
        console.log('function fetchGetMerchantData called..');
        this.isLoading = true;
    
        const requestPayload = {
            tid: this.tid,
            mid: this.mid,
            // idPangkalan: this.idPangkalan,
            idcs: this.caseId
        };
    
        console.log('Request Merchant payload:', JSON.stringify(requestPayload));
    
        getMerchant(requestPayload)
        .then(result => {
            console.log('Response result Merchant received:', result);
            console.log('Response result Merchant received:', JSON.stringify(result));
    
            if (result) {
                const responseMerchant = result?.MERCHANT_PROFILE;
                console.log('responseMerchant ', responseMerchant);
                this.errorMsg = '';
                this.hasError = false;
                this.isLoading = false;
    
                // Process responseAgen data
                if (responseMerchant && responseMerchant.length > 0) {
                    this.data = responseMerchant.map(item => ({
                        ...item,
                    }));

                    this.showSearchResults=true;
                    
                    console.log('Formatted responseMerchant Data:', JSON.stringify(this.data));
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            } else {
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error occurred during search Merchant:', error.message);
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
        console.log('Error Message:', errorMessage);
    }

    handleClearChildTransaction(){
        console.log('handleClearChildTransaction called..');
        const childComponent = this.template.querySelector('c-lwc-merchant-transaction-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }

    handleTransaksiAction(event){
        console.log('handleTransaksiAction called..');
        // this.handleClearChildKredit();

        const tid = event.currentTarget.dataset.tid;
        const mid = event.currentTarget.dataset.mid;

        // Set the selected nomorKartu
        this.selectedTID = tid;
        this.selectedMID = '000'+mid;
        console.log(`Select TID : ${this.selectedTID}`);
        console.log(`Select MID : ${this.selectedMID}`);

        this.showTransaksiMerchant = true;
        this.scrollToTransaksi = true;

    }

    handleCloseTransaksi(event) {
        console.log(event.detail.message);
        this.showTransaksiMerchant = false;
    }

    handleClosePencarianTrx(event) {
        console.log(event.detail.message);
        this.showTransaksiMerchant = false;
        // this.isMutasiComponentVisible = false;
    }

    // handleCloseDetail() {
    //     const closeEvent = new CustomEvent('close', {
    //         detail: { message: 'Close button clicked' }
    //     });
    //     this.showDetailSection = false;
    //     // this.handleClear();
    //     this.dispatchEvent(closeEvent);
    // }

    handleTidChange(event) {
        this.tid = event.target.value;
        this.mid = '';
        this.toggleFields('tid');
       
        if (!this.tid) {
            this.clearInputFields();
            this.showTransaksiMerchant = false;
        }
    }

    handleMidChange(event) {
        this.mid = event.target.value;
        this.tid = '';
        this.toggleFields('mid');
        if (!this.mid) {
            this.clearInputFields();
            this.showTransaksiMerchant = false;
        }
    }

    showDetail(event) {
        //this.showDetailSection = true;
        // this.showDetailSection = true;
        // this.data.forEach(data=>{if(data.alamat_merchant==event.target.dataset.id)data.showSection=true; else data.showSection=false  });

        console.log('showDetail clicked..');
    
        // Get the MID from the button's data-id attribute
        const mid = event.target.dataset.id;
        
        // Find the specific data item by MID
        const selectedData = this.data.find(item => item.mid === mid);
        
        if (selectedData) {
            // Set showSection for each data item
            this.data.forEach(data => {
                data.showSection = data.mid === mid; // Show the selected section
            });

            // Process data: replace null or empty values with "N/A"
            this.currentDetailData = Object.fromEntries(
                Object.entries(selectedData).map(([key, value]) => {
                    // return [key, (value === null || value === '' || value === 'NULL' || value === 'null') ? 'N/A' : value];
                    return [key, (value === null || value === '' || value === undefined || value == 'null' || value == 'NULL') ? 'N/A' : value];
                })
            );
            
            this.showDetailSection = true; // Show the detail section
            
            // console.log('Detail data to show:', JSON.stringify(selectedData));
            console.log('Detail data to show:', JSON.stringify(currentDetailData));
        } else {
            console.log('No data found for the provided TID.');
            this.showDetailSection = false; // Hide detail section if no data found
        }

    }

    handleCloseMerchantDetail(event){
        console.log('handleCloseDetail called..');
        const mid = event.target.dataset.id;

        const selectedData = this.data.find(item => item.mid === mid);
        if (selectedData) {
            console.log('if handleCloseDetail called..');
            selectedData.showSection = false; // Hide the detail section
        }

        // Reassign data to trigger reactivity
        this.data = [...this.data]; // This helps in re-rendering the component

        // Optionally, if want to hide all detail sections
        // this.data.forEach(item => item.showSection = false);
    }

    handleSearch() {
        //for data from dummy
        //this.showSearchResults=true;
        //this.data = this.generateDummyData();
        //end for data from dummy

        this.fetchMerchantData();
    }

    toggleFields(inputField) {
        if (inputField === 'tid') {
            this.disableMidField = !!this.tid;
        } else if (inputField === 'mid') {
            this.disableTidField = !!this.mid;
        } 
    }

    clearSearchResults() {
        this.data = null;
        this.errorMessage = '';
        this.showSearchResults = false;
        this.showDetailSection=false;
        this.error = '';
    }

    clearInputFields() {
        this.data = [];
        this.tid='';
        this.mid = '';
        this.disableMidField = false;
        this.disableTidField = false;
        this.errorMessage = '';
        this.errorMsg = '';
        this.hasError = false;
        this.showDetailSection=false;
        this.showSearchResults = false;
    }

    @api handleClear() {
        this.data = [];
    
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