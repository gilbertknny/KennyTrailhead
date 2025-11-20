/** 
    LWC Name    : lwcDPLKInformation.js
    Created Date       : ?? September 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   ??/09/2024   Rakeyan Nuramria                  Initial Version
    1.0   24/09/2024   Rakeyan Nuramria                  Add API Functionality
    1.0   31/09/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to show nominal number & if data empty

**/

import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getDPLK from '@salesforce/apex/SCC_CaseBRICare.getDPLK';

export default class lwcDPLKInformation extends NavigationMixin(LightningElement) {
    @api recordId;
    @track options = [
        { label: 'No account DPLK', value: 'account_number' },
        { label: 'Nomor ID', value: 'id_number' }
    ];
    @track methodValue = '';
    @track searchValue = '';
    @track hasText = false;
    @track isLoading = false;
    @track showTransactionData = false;
    @track errorMessage = '';
    @track dataSI = [];
    @track dataTransaction = [];
    @track columns = [];

    // Dummy Data
    dummyDataSI = [
        {
            id: 1,
            kantor_pembukaan_cabang: 'Cabang A',
            nomor_akun_dplk: '1234567890',
            nomor_handphone: '08123456789',
            cif_dplk: 'CIF123',
            nama_nasabah: 'John Doe',
            tanggal_lahir: '01-01-1980',
            tgl_registrasi: '01-01-2022',
            anggota_korporat_individu: 'Individu',
            no_pegawai_korporat: 'N/A',
            nomor_rekening_bri: 'BRI123456',
            nomor_kartu_dplk: 'KARTU123',
            status_dplk: 'Aktif',
            sistem_pembayaran_iuran: 'Bulanan',
            jenis_investasi: 'Konservatif',
            iuran: 1000000,
            pengembangan: 200000,
            pengalihan: 500000,
            total_saldo: 1700000,
            alamat_email: 'johndoe@example.com'
        }
    ];

    dummyDataTransaction = [
        {
            id_transaksi: 'TXN001',
            tanggal_transaksi: '2023-09-01',
            nama_transaksi: 'Setoran',
            branch_code: 'CAB001',
            keterangan: 'Setoran Bulanan'
        },
        {
            id_transaksi: 'TXN002',
            tanggal_transaksi: '2023-09-15',
            nama_transaksi: 'Pengalihan',
            branch_code: 'CAB001',
            keterangan: 'Pengalihan Dana'
        }
    ];

    connectedCallback() {
        console.log('DPLK recordId : ', this.recordId);
    }

    fetchDataDPLK(){
        console.log('function fetchDataDPLK called..');
        this.isLoading = true;
    
        const requestPayload = {
            idNumber: this.methodValue === 'id_number' ? this.searchValue : null,
            acctNo: this.methodValue === 'account_number' ? this.searchValue : null,
            idcs: this.recordId
        };
    
        console.log('Request dplk payload:', JSON.stringify(requestPayload));
    
        getDPLK(requestPayload)
        .then(result => {
            console.log('Response result dplk received:', result);
            console.log('Response result dplk received:', JSON.stringify(result));
    
            // Check if response is an array and has at least one element
            if (result) {
                const responseSI = result?.SI_DPLK;
                const responseTrxSI = result?.TRX_DPLK;
                this.errorMsg = '';
                this.hasError = false;
                this.isLoading = false;
    
                // Process SI_DPLK data
                if (responseSI && responseSI.length > 0) {
                    this.dataSI = responseSI.map(item => ({
                        ...item,
                        iuran: this.formatNumber(item.iuran),
                        pengembangan: this.formatNumber(item.pengembangan),
                        pengalihan: this.formatNumber(item.pengalihan),
                        total_saldo: this.formatNumber(item.total_saldo),
                        alamat_email: item.alamat_email || "N/A",
                        anggota_korporat_individu: item.anggota_korporat_individu || "N/A",
                        cif_dplk: item.cif_dplk || "N/A",
                        cifno: item.cifno || "N/A",
                        jenis_investasi: item.jenis_investasi || "N/A",
                        kantor_pembukaan_cabang: item.kantor_pembukaan_cabang || "N/A",
                        nama_nasabah: item.nama_nasabah || "N/A",
                        no_pegawai_korporat: item.no_pegawai_korporat || "N/A",
                        nomor_akun_dplk: item.nomor_akun_dplk || "N/A",
                        nomor_handphone:  item.nomor_handphone || "N/A",
                        sistem_pembayaran_iuran: item.sistem_pembayaran_iuran || "N/A",
                        status_dplk: item.status_dplk || "N/A",
                        tanggal_lahir: item.tanggal_lahir || "N/A",
                        tgl_registrasi: item.tgl_registrasi || "N/A",
                        nomor_kartu_dplk: item.nomor_kartu_dplk || "N/A",
                        nomor_rekening_bri: item.nomor_rekening_bri || "N/A",
                        nik: item.nik || "N/A"
                    }));
                    
                    console.log('Formatted SI_DPLK Data:', JSON.stringify(this.dataSI));
                } else {
                    this.handleSearchError('Data tidak ditemukan for SI_DPLK');
                }
    
                // Process TRX_DPLK data
                if (responseTrxSI && responseTrxSI.length > 0) {
                    // this.dataTransaction = responseTrxSI.map(item => ({
                    //     ...item,
                    //     // You can add any additional formatting if needed
                    // }));

                    this.dataTransaction = responseTrxSI.map(item => {
                        // Create a new object with "N/A" for empty or null values
                        return Object.fromEntries(
                            Object.entries(item).map(([key, value]) => {
                                return [key, value ? value : "-"];
                            })
                        );
                    });
    
                    console.log('Formatted TRX_DPLK Data:', JSON.stringify(this.dataTransaction));
                } else {
                    this.handleSearchError('Data tidak ditemukan for TRX_DPLK');
                }
            } else {
                this.handleSearchError('Data tidak ditemukan');
            }
        })
        .catch(error => {
            console.error('Error occurred during search dplk:', error.message);
            this.handleSearchError('Data tidak ditemukan');
        })
        .finally(() => {
            this.isLoading = false;
            console.log('Loading state set to false.');
        });
    
    }

    handleRadioChange(event) {
        this.methodValue = event.detail.value;
    }

    handleInputChange(event) {
        this.searchValue = event.target.value;
        if (!this.searchValue) {
            this.clearInputFields();
        }
    }

    searchData() {
        if (!this.methodValue) {
            this.errorMessage = 'Pilih salah satu metode pencarian terlebih dahulu!';
            return;
        }

        if (!this.searchValue) {
            this.errorMessage = 'Masukkan ID Number atau Nomor Rekening terlebih dahulu!';
            return;
        }

        

        // this.columns = [
        //     { label: 'Tgl Transaksi', fieldName: 'tanggal_transaksi', type: 'date', initialWidth: 120 },
        //     { label: 'Nama Transaksi', fieldName: 'nama_transaksi', type: 'text' },
        //     { label: 'Kode Cabang', fieldName: 'branch_code', type: 'text', initialWidth: 120 },
        //     { label: 'ID Transaksi', fieldName: 'id_transaksi', type: 'text', initialWidth: 120 },
        //     { label: 'Keterangan', fieldName: 'keterangan', type: 'text', initialWidth: 330 },
        // ];

        this.errorMessage = '';
        this.isLoading = true;

        this.fetchDataDPLK();

        // Simulating data retrieval
        // setTimeout(() => {
        //     this.dataSI = this.dummyDataSI.map(item => ({
        //         ...item,
        //         iuran: this.formatCurrency(item.iuran),
        //         pengembangan: this.formatCurrency(item.pengembangan),
        //         pengalihan: this.formatCurrency(item.pengalihan),
        //         total_saldo: this.formatCurrency(item.total_saldo),
        //     }));
        //     this.dataTransaction = this.dummyDataTransaction;
        //     this.isLoading = false;
        //     this.showTransactionData = true;
        // }, 1000); // Simulate a 1-second delay
    }

    clearInputFields(){
        this.searchValue = '';
        this.hasError = false;
        this.isLoading = false;
        this.errorMsg = '';
        this.dataSI = [];
        this.dataTransaction = [];
    }

    handleSearchError(errorMessage) {
        this.hasError = true;
        this.errorMsg = errorMessage;
        this.isLoading = false;
        console.log('Error Message:', errorMessage);
    }

    formatCurrencySafe(value) {
        // Check if the value is NaN or null/undefined and return a default value if so
        if (value == null || isNaN(value)) {
            return this.formatCurrency(0);
        }
        return this.formatCurrency(value);
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            minimumFractionDigits: 0,
            maximumFractionDigits: 0,
        }).format(value);
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