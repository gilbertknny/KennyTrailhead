/** 
    LWC Name    : lwcBriLinkSearchComponent.js
    Created Date       : 16 September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   16/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   25/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   31/09/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show nominal number & if data empty
    //release 3
    1.2   20/01/2025   Rakeyan Nuramria                  UST-017 - Add capability search by Id Outlet

**/

import { LightningElement, track, wire, api } from 'lwc';
import makeCallout from '@salesforce/apex/SCC_BriLinkCallout.makeCallout';
import getBRILink from '@salesforce/apex/SCC_CaseBRICare.getBRILink';

export default class LwcBriLinkSearchComponent extends LightningElement {
    @api isCloseHidden;
    @api recordId;
    @track isLoading = false;
    @track tid = '';
    @track mid = '';
    @track idOutlet = '';
    @track errorMessage;
    @track showSearchResults = false;
    @track showDetailSection = false;
    @track data =[];

    @track currentDetailData = {};

    generateDummyData(){
        return [
            {
                UniqueId: "98989",
                mid: "1234567890",
                nama_merchant: "Toko BRILink",
                tid: "9876543210",
                status: "Aktif",
                tanggal_dibuat: "2024-08-15",
                data: {
                //   showSection: true,
                  showSection: false,
                  UniqueId: "98989",
                  nama_agen: "Toko BRILink",
                  alamat_agen: "Jl. Raya No. 100, Jakarta Selatan",
                  nomor_rekening: "2142152121",
                  nama_ibu_kandung: "Maesanoh",
                  nama_lengkap: "Tukimin",
                  kode_channel: "2121",
                  mid: "1234567890",
                  telepon: "08665545453443",
                  kode_uker_pengelola: "12673",
                  region_office_pengelola: "KC Jakarta Seletan",
                  jenis_usaha: "Sembako",
                  nomor_kartu_debit: "927727210272913",
                  nomor_kontak_pab: "082525172552",
                  status: "Aktif",
                  kode_merchant: "212252",
                  kode_agen: "8875",
                  nama_merchant: "Toko BRILink",
                  nomor_ktp: "329374932625265",
                  nomor_siup: "218217",
                  nomor_rekening_pelimpahan: "7464682826112",
                  nomor_rekening_pinjaman: "2675457547565",
                  limit_transaksi: "400000000",
                  sharing_fee: "1%",
                  pic_uker: "215213",
                  tanggal_dibuat: "2020-10-10",
                  tanggal_modifikasi: "2021-090-10",
                  modifikasi_oleh: "2112",
                  jenis_jaringan: "Online"

                }
              }
        ]
    }

    get isHandleSearchDisabled() {
        // return !(this.tid || this.idOutlet);
        return !(this.tid || this.mid || this.idOutlet);
    }

    fetchGetBRILink(){
        console.log('function fetchgetBRILink called..');
        this.isLoading = true;
    
        const requestPayload = {
            tid: this.tid,
            mid: this.mid,
            outletCode: this.idOutlet,
            idcs: this.recordId
        };
    
        console.log('Request BRILink payload:', JSON.stringify(requestPayload));
    
        getBRILink(requestPayload)
        .then(result => {
            console.log('Response result BRILink received:', result);
            console.log('Response result BRILink received:', JSON.stringify(result));
    
            if (result) {
                const responseBrilink = result?.BRILINK_PROFILE;
                console.log('responseBrilink ', responseBrilink);
                this.errorMsg = '';
                this.hasError = false;
                // this.isLoading = false;
    
                // Process responseAgen data
                if (responseBrilink && responseBrilink.length > 0) {
                    this.data = responseBrilink.map(item => ({
                        ...item,
                        mid: item.mid || "-",
                        nama_merchant: item.nama_merchant || "-",
                        status: item.status || "-",
                        tanggal_dibuat: item.tanggal_dibuat || "-",
                        limit_transaksi: this.formatNumber(item.limit_transaksi)
                    }));

                    this.showSearchResults=true;
                    
                    console.log('Formatted responseBrilink Data:', JSON.stringify(this.data));
                } else {
                    this.handleSearchError('Data tidak ditemukan');
                }
            } else {
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error occurred during search Brilink:', error.message);
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

    handleTidChange(event) {
        this.tid = event.target.value;
        this.idOutlet = '';
        this.toggleFields('tid');
       
        if (!this.tid) {
            this.clearInputFields();
        }
    }

    handleIdOutletChange(event) {
        this.idOutlet = event.target.value;
        this.tid = '';
        this.toggleFields('idOutlet');
        if (!this.idOutlet) {
            this.clearInputFields();
        }
    }

    handleMidChange(event) {
        this.mid = event.target.value;
        this.tid = '';
        this.toggleFields('mid');
        if (!this.mid) {
            this.clearInputFields();
        }
    }

    showDetail(event) {
        //this.showDetailSection = true;
        // console.log('showDetail clicked..')
        // this.showDetailSection = true;
        // this.data.forEach(data=>{if(data.mid==event.target.dataset.id)data.showSection=true; else data.showSection=false  });

        // console.log('showDetail data : ' , JSON.stringify(this.data));

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
                    return [key, (value === null || value === '') ? 'N/A' : value];
                })
            );
            
            this.showDetailSection = true; // Show the detail section
            
            console.log('Detail data to show:', JSON.stringify(selectedData));
        } else {
            console.log('No data found for the provided MID.');
            this.showDetailSection = false; // Hide detail section if no data found
        }
    }

    // showDetail(event) {
    //     const selectedId = event.target.dataset.id;
    //     this.data = this.data.map(item => {
    //         if (item.mid === selectedId) {
    //             item.data.showSection = true;
    //         } else {
    //             item.data.showSection = false;
    //         }
    //         return item;
    //     });
    //     this.showDetailSection = this.data.some(item => item.data.showSection);
    // }

    handleSearch() {

        //for data from dummy
        // this.showSearchResults=true;
        // this.data = this.generateDummyData();
        //end for data from dummy

        this.fetchGetBRILink();

    }

    handleCloseDetail(event){
        const mid = event.target.dataset.id;

        const selectedData = this.data.find(item => item.mid === mid);
        if (selectedData) {
            selectedData.showSection = false; // Hide the detail section
        }

        // Optionally, if want to hide all detail sections
        this.data.forEach(item => item.showSection = false);
    }

    toggleFields(inputField) {

        if (inputField === 'tid') {
            this.disableMidField = !!this.tid;
            this.disableIdOutletField = !!this.tid;
        } else if (inputField === 'mid') {
            this.disableTidField = !!this.mid;
            this.disableIdOutletField = !!this.mid;
        } else if (inputField === 'idOutlet') {
            this.disableTidField = !!this.idOutlet;
            this.disableMidField = !!this.idOutlet;
        } 

        // if (inputField === 'tid') {
        //     this.disableIdOutletField = !!this.tid;
        // } else if (inputField === 'idOutlet') {
        //     this.disableTidField = !!this.idOutlet;
        // } 
    }

    clearSearchResults() {
        this.data = null;
        this.errorMessage = '';
        this.showSearchResults = false;
        this.showDetailSection=false;
        this.errorMsg = '';
        this.hasError = false;
    }

    clearInputFields() {
        this.data = [];
        this.tid='';
        this.mid = '';
        this.idOutlet = '';
        this.disableIdOutletField = false;
        this.disableTidField = false;
        this.errorMessage = '';
        this.errorMsg = '';
        this.hasError = false;
        this.showDetailSection=false;
        this.showSearchResults = false;
    }

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