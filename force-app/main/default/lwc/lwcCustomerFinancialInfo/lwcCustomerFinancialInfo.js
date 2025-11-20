/** 
    LWC Name    : lwcCustomerFinancialInfo.js
    Created Date       : 28 August 2024
    @description       : This is class ..
    @author            : Rakeyan Nuramria
    Modification Log :
    Ver   Date         Author                            Modification
    1.0   28/08/2024   Rakeyan Nuramria                  Initial Version
    1.0   05/09/2024   Rakeyan Nuramria                  Add dummy data + functionality with mutasi comp for simpanan
    1.0   06/09/2024   Rakeyan Nuramria                  Add dummy data + functionality with mutasi comp for kredit & others
    1.0   07/09/2024   Rakeyan Nuramria                  Add functionality to clear child component
    1.0   24/09/2024   Rakeyan Nuramria                  Adjust indexing + API
    1.0   09/10/2024   Rakeyan Nuramria                  [FROM SIT] Adjust logic to pass cardNo to mutasi
    //release 3
    2.0   29/11/2024   Rakeyan Nuramria                  Add logic capability to create Case from Pinjaman
    1.1   18/02/2025   Rakeyan Nuramria                  [FROM SIT] Adjust logic to update info hold rekening & mutasi component when different noRek being clicked
**/

import { LightningElement, track, api, wire } from 'lwc';
import getInformasiCustomer from '@salesforce/apex/SCC_Account_UI.getInformasiCustomer';
import getInformasiFinansial from '@salesforce/apex/SCC_Account_UI.getInformasiFinansial';
import getMutasiRekening from '@salesforce/apex/SCC_Account_UI.getMutasiRekening';
import getMutasiKartu from '@salesforce/apex/SCC_Account_UI.getMutasiKartu';
import { createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// import getInformasiFinansial from '@salesforce/apex/SCC_Account_UI.getInformasiFinansial';

export default class LwcCustomerFinancialInfo extends NavigationMixin(LightningElement) {
    @api recordId
    @track accountId;
    @track selectedNomorRekening;
    @track selectedNomorKartu;
    // @track isMutasiComponentVisible = false;
    @track isMutasiSimpananVisible = false;
    @track isMutasiKreditVisible = false;
    @track isCloseHidden = false;
    scrollToMutasiSimpanan = false;
    scrollToMutasiKredit = false;

    @track isLoadingCreateCasePinjaman = false;

    @track simpananData= [];
    @track kreditData= [];
    @track pinjamanData= [];
    @track investasiData= [];

    pendingMutasiAction = false;

    connectedCallback(){
        this.fetchInformasiFinansial();

        // getInformasiFinansial(this.recordId);
        // console.log('get data :', JSON.stringify(this.getInformasiFinansial));

        // this.simpananData = this.generateSimpananDummyData();
        // this.simpananData = this.generateFinancialDummyJSONData();
        // this.kreditData = this.generateKreditDummyData();
        // this.pinjamanData = this.generatePinjamanDummyData();
        // this.investasiData = this.generateInvestasiDummyData();
    }

    renderedCallback() {
        

        //for focus to the content
        if (this.scrollToMutasiSimpanan) {
            this.scrollToComponent('scrollable-simpanan-container', 'mutasi-simpanan-component');
            this.scrollToMutasiSimpanan = false;
        }
        
        if (this.scrollToMutasiKredit) {
            this.scrollToComponent('scrollable-kredit-container', 'mutasi-kredit-component');
            this.scrollToMutasiKredit = false;
        }
        //end for focus to the content

        if (this.pendingMutasiAction) {
            const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-component');
            if (childComponent) {
                childComponent.noRekening = this.selectedNomorRekening;
                childComponent.updateLatestCardDetails();   
                childComponent.updateGrandchildHoldDetails();
                
                this.pendingMutasiAction = false; // Reset flag
            } else {
                console.error('🚫 Parent: Mutasi Child component not found in renderedCallback!');
            }
        }
    
    }

    generateSimpananDummyData(){
        return [
        { no: 1, produk: 'SiMuda', nomorRekening: '123456789', status: 'Aktif', brimo: 'Aktif' },
        { no: 2, produk: 'Simpel', nomorRekening: '987654321', status: 'Nonaktif', brimo: 'Nonaktif' },
        { no: 3, produk: 'TabunganKu', nomorRekening: '111222333', status: 'Aktif', brimo: 'Aktif' },
        { no: 4, produk: 'BritAma', nomorRekening: '444555666', status: 'Nonaktif', brimo: 'Aktif' },
        { no: 5, produk: 'BritAma', nomorRekening: '444555667', status: 'Nonaktif', brimo: 'Aktif' },
        { no: 6, produk: 'BritAma', nomorRekening: '444555668', status: 'Nonaktif', brimo: 'Aktif' },
        { no: 7, produk: 'BritAma', nomorRekening: '444555669', status: 'Nonaktif', brimo: 'Aktif' },
        { no: 8, produk: 'BritAma', nomorRekening: '444555670', status: 'Nonaktif', brimo: 'Aktif' },
        { no: 9, produk: 'SiMuda', nomorRekening: '777888999', status: 'Aktif', brimo: 'Nonaktif' }
        ]

    }

    generateFinancialDummyJSONData(){
        const dummyData = {
            data: [
              {
                cifno: "CIF12345678",
                demografi: {
                  agama: "Christian",
                  alamatDomisili: "Jl. Melati No. 20",
                  alamatDomisili1: "Jl. Melati No. 20",
                  alamatDomisili2: "Kecamatan A",
                  alamatDomisili3: "Kecamatan A",
                  alamatDomisili4: "Kota B",
                  alamatId1: "Jl. Mawar No. 10",
                  alamatId2: "Kecamatan X",
                  alamatId3: "Kelurahan Y",
                  alamatId4: "Kota Z",
                  alamatKantor: "Jl. Anggrek No. 30",
                  alamatKantor1: "Jl. Anggrek No. 30",
                  alamatKantor2: "Kecamatan C",
                  alamatKantor3: "Kecamatan C",
                  alamatKantor4: "Kota D",
                  alamatSesuaiID: "Jl. Mawar No. 10",
                  alamatSesuaiID2: "Kecamatan X",
                  alamatSurat: "Jl. Kenanga No. 40",
                  alamatSuratMenyurat: "Jl. Kenanga No. 40",
                  bidangPekerjaan: "Finance",
                  bidangUsaha: "Banking",
                  cfbrnn: "CFBRNN123",
                  createdDate: "2024-01-01",
                  email: "john.doe@example.com",
                  email1: "john.doe1@example.com",
                  email2: "john.doe2@example.com",
                  email3: "john.doe3@example.com",
                  emailPengurus1: "alice.smith@example.com",
                  emailPengurus2: "bob.brown@example.com",
                  emailPengurus3: "charlie.davis@example.com",
                  fax: "0212345679",
                  gelarSebelumNama: "Dr.",
                  gelarSesudahNama: "S.E.",
                  gelarSetelahNama: "PhD",
                  handphone: "08123456789",
                  idDesc: "Kartu Tanda Penduduk",
                  idExp: "2030-01-01",
                  idIssue: "2020-01-01",
                  idNumber: "123456789",
                  idType: "KTP",
                  jabatan: "Finance Manager",
                  jabatan1: "Finance Manager",
                  jabatan2: "Team Lead",
                  jabatan3: "Senior Analyst",
                  jabatanPengurus1: "Director",
                  jabatanPengurus2: "Manager",
                  jabatanPengurus3: "Assistant Manager",
                  jenisIdentitas: "KTP",
                  jenisKelamin: "Male",
                  jenisPekerjaan: "Full-time",
                  jumlahTanggungan: "3",
                  kecamatanDomisili: "Kecamatan A",
                  kecamatanId: "Kecamatan01",
                  kecamatanKantor: "Kecamatan C",
                  kecamatanSesuaiID: "Kecamatan X",
                  kelurahanDomisili: "Kelurahan A",
                  kelurahanId: "Kelurahan01",
                  kelurahanKantor: "Kelurahan C",
                  kelurahanSesuaiID: "Kelurahan X",
                  keteranganAgama: "Christian",
                  kewarganegaraan: "Indonesian",
                  kodeBidangPekerjaan: "Finance",
                  kodeBidangUsaha: "Banking",
                  kodeJabatan: "Mgr",
                  kodeJenisPekerjaan: "Employee",
                  kodeOmsetPerBulan: "6000",
                  kodePajak: "PJK123456",
                  kodePendidikan: "S1",
                  kodePenghasilanPerBulan: "5000",
                  kodePosDomisili: "12345",
                  kodeposId: "12345",
                  kodePosKantor: "67890",
                  kodePosSesuaiID: "54321",
                  kodeSumberPenghasilan: "Salary",
                  kodeTrxNormalHarian: "7000",
                  kodeTujuanBukaRekening: "Saving",
                  kotaDomisili: "Kota B",
                  kotaId: "Kota01",
                  kotaKantor: "Kota D",
                  kotaSesuaiID: "Kota Z",
                  lamaBekerjaBulan: "6",
                  lamaBekerjaTahun: "5",
                  lastModifiedDate: "2024-01-01",
                  nama1: "John Doe",
                  nama2: "John Smith",
                  nama3: "John Johnson",
                  namaGadisIbuKandung: "Jane Doe",
                  namaIbuKandung: "Jane Doe",
                  namaKantor: "ABC Corp",
                  namaLengkap: "John Doe",
                  namaLengkapKontakDarurat: "Eve White",
                  namaPengurus1: "Alice Smith",
                  namaPengurus2: "Bob Brown",
                  namaPengurus3: "Charlie Davis",
                  namaSesuaiId: "John Doe",
                  namaSesuaiIdentitas: "John Doe",
                  namaTempatBekerja: "ABC Corp",
                  nasabahPrioritas: "Yes",
                  negara: "Indonesia",
                  noAktaPendirian: "B123",
                  noAktaPerubahan: "A123",
                  noIdCorp: "ID123456",
                  nomorHandphoneKontakDarurat: "08567890123",
                  nomorIdentitas: "123456789",
                  notesBeneficialOwner: "N/A",
                  notesIbuKandung: "N/A",
                  notesTanggalLahir: "N/A",
                  NPWP: "123456789012345",
                  omsetPerBulan: "6000",
                  pendidikan: "Bachelor",
                  pendidikanTerakhir: "Bachelor",
                  penghasilanPerBulan: "5000",
                  PEP: "Yes",
                  pepJabatan: "Manager",
                  pepKeluarga: "Spouse",
                  pepStatusKeluarga: "Active",
                  prioritas: "High",
                  prioritasPbo: "Medium",
                  prioritasPboContact: "Low",
                  propinsiDomisili: "Propinsi01",
                  propinsiIid: "Propinsi01",
                  propinsiKantor: "Propinsi01",
                  propinsiSesuaiID: "Propinsi01",
                  rtDomisili: "001",
                  rtId: "001",
                  rtKantor: "002",
                  rtSesuaiID: "003",
                  rwDomisili: "001",
                  rwId: "002",
                  rwKantor: "002",
                  rwSesuaiID: "003",
                  statusKepemilikanTempatTinggal: "Own",
                  statusNikah: "Married",
                  statusPerkawinan: "Married",
                  sumberPenghasilan: "Salary",
                  tanggalAktaPendirian: "2024-01-01",
                  tanggalAktaPerubahan: "2024-01-01",
                  tanggalBukaCif: "2024-01-01",
                  tanggalKadaluarsaCorp: "2025-01-01",
                  tanggalLahir: "1990-01-01",
                  tanggalMaintenanceCif: "2024-01-01",
                  tanggalTerbit: "2024-01-01",
                  tanggalTerbitCorp: "2024-01-01",
                  telepon: "08123456789",
                  telepon1: "08234567890",
                  telepon2: "08345678901",
                  telepon3: "08456789012",
                  teleponKantor: "0212345678",
                  teleponPengurus1: "08234567890",
                  teleponPengurus2: "08345678901",
                  teleponPengurus3: "08456789012",
                  telpKantor: "0212345678",
                  telpRumah: "08123456789",
                  tempatLahir: "Jakarta",
                  tempatPendirian: "Surabaya",
                  tipeIdCorp: "Legal Entity",
                  tipeIdDescCorp: "Legal Entity",
                  tipeNasabah: "Corporate",
                  tipeNasabahDesc: "Corporation",
                  trxNormalHarian: "7000",
                  tujuanBukaRekening: "Savings Account",
                  umur: 34
                },
                portofolioPerbankan: {
                  cardlink: [
                    {
                      cardNo: "CARD789012",
                      cardNumber: "CARD789012",
                      cifno: "CIF12345678",
                      deskripsiProduk: "Premium credit card with various benefits",
                      groupProduk: "Credit Cards",
                      idNumber: "ID123456",
                      kolektibilitas: "Good",
                      mataUang: "USD",
                      nomorKartu: "CARD789012",
                      openAccountDate: "2024-01-01",
                      product: "Premium Credit Card",
                      productDescription: "Premium credit card with enhanced features",
                      productType: "Credit Card",
                      produk: "Credit Card",
                      status: "Active",
                      tipeProduk: "Premium"
                    },
                    {
                      cardNo: "CARD789013",
                      cardNumber: "CARD789013",
                      cifno: "CIF12345678",
                      deskripsiProduk: "Premium credit card with various benefits",
                      groupProduk: "Credit Cards",
                      idNumber: "ID123456",
                      kolektibilitas: "Good",
                      mataUang: "IDR",
                      nomorKartu: "CARD789013",
                      openAccountDate: "2024-01-01",
                      product: "Standard Credit Card",
                      productDescription: "Standard credit card with basic features",
                      productType: "Credit Card",
                      produk: "Credit Card",
                      status: "Inactive",
                      tipeProduk: "Standard"
                    }
                  ],
                  investasi: [
                    {
                      accountNumber: "INV7891011",
                      balance: 1000000,
                      deskripsiProduk: "Equity Investment in Tech Sector",
                      productType: "Investment",
                      status: "Active",
                    },
                    {
                      accountNumber: "INV7891012",
                      balance: 500000,
                      deskripsiProduk: "Bond Investment",
                      productType: "Investment",
                      status: "Inactive",
                    }
                  ],
                  pinjaman: [
                    {
                      accountNumber: "ACCT123456",
                      balance: 1000000,
                      deskripsiProduk: "Standard personal loan with fixed interest",
                      status: "Active",
                    },
                    {
                      accountNumber: "ACCT123457",
                      balance: 500000,
                      deskripsiProduk: "Home loan with low interest rate",
                      status: "Closed",
                    }
                  ],
                  simpanan: [
                    {
                      accountNumber: "9876543210",
                      balance: 150000,
                      deskripsiProduk: "Standard Savings Account",
                      status: "Active",
                    },
                    {
                      accountNumber: "9876543211",
                      balance: 200000,
                      deskripsiProduk: "Fixed Deposit Account",
                      status: "Closed",
                    }
                  ]
                },
                profileDukcapil: {
                  alamat: "Jl. Melati No. 20",
                  namaIbuKandung: "Jane Doe",
                  tanggalLahir: "1990-01-01"
                }
              }
            ],
            errorCode: "000",
            responseCode: "00",
            responseMessage: "Success",
            statusCode: 200
          };
          
          // Log the dummy data to check
          console.log(dummyData);
          
    }

    generateKreditDummyData(){
        return [
        { no: 1, produk: 'BRI Touch', nomorKartu: '987654321', status: 'Aktif' },
        { no: 2, produk: 'BRI Infinite', nomorKartu: '987654322', status: 'Nonaktif' },
        { no: 3, produk: 'BRI Easy', nomorKartu: '111222334', status: 'Aktif' },
        { no: 4, produk: 'BRI Easy', nomorKartu: '111222334', status: 'Aktif' },
        { no: 5, produk: 'BRI Easy', nomorKartu: '111222334', status: 'Aktif' },
        { no: 6, produk: 'BRI Easy', nomorKartu: '111222334', status: 'Aktif' },
        { no: 7, produk: 'BRI Easy', nomorKartu: '111222334', status: 'Aktif' }
        ]

    }

    generatePinjamanDummyData(){
        return [
        { no: 1, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' },
        { no: 2, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' },
        { no: 3, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' },
        { no: 4, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' },
        { no: 5, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' },
        { no: 6, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' },
        { no: 7, produk: 'Kupedes', nomorRekening: '676767', status: 'Aktif' }
        ]

    }

    generateInvestasiDummyData(){
        return [
        { no: 1, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' },
        { no: 2, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' },
        { no: 3, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' },
        { no: 4, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' },
        { no: 5, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' },
        { no: 6, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' },
        { no: 7, produk: 'DPLK', nomorRekening: '321321', status: 'Aktif' }
        ]

    }

    async fetchInformasiFinansial() {
        console.log('Function fetchInformasiFinansial called..');
    
        const requestPayload = {
            idacc: this.recordId
        };
    
        console.log('Request Finansial Payload:', JSON.stringify(requestPayload));
    
        getInformasiFinansial(requestPayload)
            .then(result => {
                console.log('Response Finansial received:', result);
    
                // if (result && result.length > 0) {
                if (result) {
                    const response = Array.isArray(result) ? result[0] : result;
                    console.log('masuk sini..');
                    console.log('response : ', JSON.stringify(response));
                    console.log('response.data : ', JSON.stringify(response.data));
                    console.log('response.data.portofolioPerbankan : ', JSON.stringify(response.data[0].portofolioPerbankan));
    
                    if (response.errorCode === '000' && response.responseCode === '00') {
                        // Always set simpananData to an array
                        this.simpananData = Array.isArray(result) ? result : [response];
                        this.kreditData = Array.isArray(result) ? result : [response];
                        this.pinjamanData = Array.isArray(result) ? result : [response];
                        this.investasiData = Array.isArray(result) ? result : [response];

                        this.errorMsg = '';
                        this.hasError = false;
                    } else {
                        this.handleSearchError(response.responseMessage || 'Data tidak ditemukan');
                    }
                } else { 
                    this.handleSearchError('Data tidak ditemukan');
                }
            })
            .catch(error => {
                console.error('Error occurred during search:', error.message);
                this.handleSearchError('Data tidak ditemukan');
            })
            .finally(() => {
                this.isLoadingBanking = false;
                console.log('Loading state set to false.');
            });
    }

    get processedSimpananData() {
        let globalIndex = 1; // Initialize a global index
        return this.simpananData.map((result) => {
            const simpananArray = result?.data?.[0]?.portofolioPerbankan?.simpanan || [];
            
            const processedSimpanan = simpananArray.map(simpanan => ({
                ...simpanan,
                status: simpanan.status === '1' ? 'Aktif' : 'Nonaktif',
                customStatus: simpanan.status === '1' ? 'status-aktif' : 'status-nonaktif',
                brimo: simpanan.brimo === '1' ? 'Aktif' : 'Nonaktif',
                customBrimo: simpanan.brimo === '1' ? 'status-aktif' : 'status-nonaktif'
            }));
    
            // Create an object to hold the result and processed simpanan
            const resultObj = {
                ...result,
                simpanan: processedSimpanan
            };
    
            // Set the 'no' property for each simpanan item
            processedSimpanan.forEach(simpanan => {
                simpanan.no = globalIndex; // Assign the global index to each simpanan
                globalIndex++; // Increment the global index for the next item
            });
    
            return resultObj;
        });
    }

    get processedKreditData() {
        let globalIndex = 1; // Initialize a global index
        return this.kreditData.map((result) => {
            const kreditArray = result?.data?.[0]?.portofolioPerbankan?.cardlink || [];
            
            const processedCardlink = kreditArray.map(cardlink => ({
                ...cardlink,
                status: cardlink.status === '1' ? 'Aktif' : 'Nonaktif',
                customStatus: cardlink.status === '1' ? 'status-aktif' : 'status-nonaktif',
            }));
    
            processedCardlink.forEach(cardlink => {
                cardlink.no = globalIndex; 
                globalIndex++;
            });
    
            return {
                ...result,
                cardlink: processedCardlink
            };
        });
    }

    get processedPinjamanData() {
        let globalIndex = 1; // Initialize a global index
        return this.pinjamanData.map((result) => {
            const pinjamanArray = result?.data?.[0]?.portofolioPerbankan?.pinjaman || [];
            
            const processedPinjaman = pinjamanArray.map(pinjaman => ({
                ...pinjaman,
                customStatus: pinjaman.status === 'Active' ? 'status-aktif' : 'status-nonaktif',
            }));
    
            processedPinjaman.forEach(pinjaman => {
                pinjaman.no = globalIndex;
                globalIndex++; 
            });
    
            return {
                ...result,
                pinjaman: processedPinjaman 
            };
        });
    }

    get processedInvestasiData() {
        let globalIndex = 1; // Initialize a global index
        return this.investasiData.map((result) => {
            const investasiArray = result?.data?.[0]?.portofolioPerbankan?.investasi || [];
            
            const processedInvestasi = investasiArray.map(investasi => ({
                ...investasi,
                status: investasi.status === '1' ? 'Aktif' : 'Non-Aktif',
                customStatus: investasi.status === '1' ? 'status-aktif' : 'status-nonaktif',
            }));
    
            processedInvestasi.forEach(investasi => {
                investasi.no = globalIndex;
                globalIndex++; 
            });
    
            return {
                ...result,
                investasi: processedInvestasi 
            };
        });
    }

    handleClickMutasiSimpanan(event) {

        console.log('clicked..')

        this.handleClearChildSimpanan();

        const accountNumber = event.target.dataset.accountNumber;
        console.log('Selected Nomor Rekening: ', accountNumber);
        this.selectedNomorRekening = accountNumber;

        const cardNo = event.target.dataset.cardNo;
        console.log('Selected cardNo: ', cardNo);
        this.selectedNomorKartu = cardNo;

        this.accountId = this.recordId;
    
        this.isMutasiSimpananVisible = true;
        this.scrollToMutasiSimpanan = true;
        
        this.pendingMutasiAction = true; // Set flag for pending action

    }

    handleClickMutasiKredit(event) {

        console.log('clicked..')

        this.handleClearChildKredit();

        const cardNo = event.target.dataset.cardNo;
        console.log('Selected Nomor Kartu Kredit: ', cardNo);
        this.selectedNomorKartu = cardNo;
        this.accountId = this.recordId;
    
        this.isMutasiKreditVisible = true;
        this.scrollToMutasiKredit = true;
    }

    @track isProcessingCase = false;

    handleCreateCasePinjaman(event) {
        // Check if any case creation is already in progress
        if (this.isProcessingCase) {
            this.showToast('Warning', 'A case is currently being created. Please wait.', 'warning');
            return;
        }

        const button = event.target.closest('.custom-case-button');
        const accountNumber = button.dataset.accountNumber;

        // Quick early exit checks
        if (!this.recordId || !accountNumber) {
            this.showToast('Error', 'AccountId or Nomor Rekening is missing!', 'error');
            return;
        }

        // Disable all buttons and set processing flag
        this.isProcessingCase = true;
        this.disableAllCaseButtons();

        // Pre-bind spinner and text elements
        const spinnerContainer = button.querySelector('.spinner-case-container');
        const buttonText = button.querySelector('.button-text');

        // Disable button and show spinner
        button.disabled = true;
        spinnerContainer.classList.remove('slds-hidden');
        buttonText.classList.add('slds-hidden');

        // Prepare fields for creating Case record
        const fields = {
            AccountId: this.recordId,
            SCC_Account_Number__c: accountNumber,
        };

        const recordInput = { apiName: 'Case', fields };

        // Create a new Case record
        createRecord(recordInput)
            .then((caseRecord) => {
                this.showToast(
                    'Sukses',
                    `Case berhasil dibuat, Anda akan diarahkan ke halaman detail Case.`,
                    'success'
                );

                setTimeout(() => {
                    // Navigate to the newly created record after the delay
                    this.navigateToRecord(caseRecord.id, 'Case');
                }, 700);
            })
            .catch((error) => {
                console.error('Error creating Case:', error);

                let errorMessage = 'Failed to create Case. Please try again.';

                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                } else if (error.message) {
                    errorMessage = error.message;
                }

                this.showToast('Error', errorMessage, 'error');
            })
            .finally(() => {
                // Restore button state and enable all buttons
                this.isProcessingCase = false;
                this.enableAllCaseButtons();
                
                const spinnerContainer = button.querySelector('.spinner-case-container');
                const buttonText = button.querySelector('.button-text');
                
                button.disabled = false;
                spinnerContainer.classList.add('slds-hidden');
                buttonText.classList.remove('slds-hidden');
            });
    }

    // Method to disable all case creation buttons
    disableAllCaseButtons() {
        const buttons = this.template.querySelectorAll('.custom-case-button');
        buttons.forEach(button => {
            button.disabled = true;
        });
    }

    // Method to enable all case creation buttons
    enableAllCaseButtons() {
        const buttons = this.template.querySelectorAll('.custom-case-button');
        buttons.forEach(button => {
            button.disabled = false;
        });
    }
    
    /** end v2 */

    handleCloseMutasiSimpanan(event) {
        console.log(event.detail.message);
        this.isMutasiSimpananVisible = false;
        // this.isMutasiComponentVisible = false;
    }

    handleCloseMutasiKredit(event) {
        console.log(event.detail.message);
        this.isMutasiKreditVisible = false;
    }

    handleClearChildSimpanan(){
        const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }
    handleClearChildKredit(){
        const childComponent = this.template.querySelector('c-lwc-mutasi-rekening-kredit-component');
        if (childComponent) {
            childComponent.handleClear();
        }
    }


    /** MISC FUNCTION */

    handleSearchError(errorMessage) {
        this.errorMsg = errorMessage;
        // this.searchData = [];
        // this.hasError = true;
        // this.isLoadingBanking = false;
        // this.isLoadingKredit = false;
        // this.isLoadingBRILink = false;
        // this.isLoadingMerchant = false;
        // this.isLoadingDPLK = false;
        console.log('Error Message:', errorMessage);
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

    navigateToRecord(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName,
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }
}