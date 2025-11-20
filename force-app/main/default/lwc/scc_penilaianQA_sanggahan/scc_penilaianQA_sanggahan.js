import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { CurrentPageReference } from 'lightning/navigation';
import getCaseMasterData from '@salesforce/apex/SCC_PenilaianQA_ctrl.getCaseMasterData';
import saveTableData from '@salesforce/apex/SCC_PenilaianQA_ctrl.saveQAResponseItems';
import saveFormData from '@salesforce/apex/SCC_PenilaianQA_ctrl.saveFormData';
import getPicklistOptions from '@salesforce/apex/SCC_PenilaianQA_ctrl.getPicklistOptions'; 
import getCaseDetails from '@salesforce/apex/SCC_PenilaianQA_ctrl.getCaseDetails'; 
import getQAResponse from '@salesforce/apex/SCC_PenilaianQA_ctrl.getQAResponse';
import getQAResponseItems from '@salesforce/apex/SCC_PenilaianQA_ctrl.qaResponseItems';
import getFiturQAConfig from '@salesforce/apex/SCC_PenilaianQA_ctrl.getFiturQAConfig';

export default class scc_PenilaianQA_Sanggahan extends LightningElement {
    @wire(IsConsoleNavigation) isConsoleNavigation;

    @track formData = {}
    @track countCriticalZero = 0;
    @track countNonCriticalZero = 0;
    @track countCriticalErrorSanggahan = 0;
    @track countNonCriticalErrorSanggahan = 0;
    
    @api recordTypeName;
    @api recordId;
    @api recordIdCase;
    @api subVoice;
    @api totalCriticalError;
    @api totalNonCriticalError;
    @api totalUtama;
    @api avgCriticalError;
    @api avgNonCriticalError;
    @api avgCriticalErrorStr;
    @api avgNonCriticalErrorStr;
    @api timestamp;
    @api totalCriticalErrorSanggahan;
    @api totalNonCriticalErrorSanggahan;
    @api totalUtamaSanggahan;
    @api avgCriticalErrorSanggahan;
    @api avgNonCriticalErrorSanggahan;
    @api avgCriticalErrorStrSanggahan;
    @api avgNonCriticalErrorStrSanggahan;

    caseData = {
        CaseNumber: 'N/A',
        SCC_Card_Number__c: 'N/A',
        SCC_Account_Number__c: 'N/A',
        Cust_Current_Phone__c: 'N/A',
        Account: {
            Name: 'N/A'
        }
    };

    data = []; // Data dari object master qa
    groupedData = []; 
    totalCriticalError = 0; 
    totalNonCriticalError = 0; 
    totalUtama = 0;
    avgCriticalError = 0; 
    avgNonCriticalError = 0;
    totalCriticalErrorSanggahan = 0; 
    totalNonCriticalErrorSanggahan = 0; 
    totalUtamaSanggahan = 0;
    avgCriticalErrorSanggahan = 0; 
    avgNonCriticalErrorSanggahan = 0;  

    isModalOpen = false; 

    //mengatur visibility Field
    // showNamaNasabah = true;
    // showNomorKartu = true;
    // showNomorRekening = true;
    // showNomorPonsel = true;
    // showWaktuInteraksi = true;
    // showTanggalCallmon = true;
    // showCalltype = true;
    // showPerihal = true;
    // showNamaQA = true;
    // showInisialAgent = true;
    // showChannel = true;
    // showTanggalInteraksi = true;
    // showResponJawab = true;
    // showNamaAgent = true;
    // showExtAvaya = true;
    // showDurasi = true;
    // agentLeaderView = false;

    fieldVisibility = {
        showNamaNasabah: true,
        showNomorKartu: true,
        showNomorRekening: true,
        showNomorPonsel: true,
        showExtAvaya: true,
        showDurasi: true,
        showWaktuInteraksi: true,
        showTanggalCallmon: true,
        showCalltype: true,
        showPerihal: true,
        showNamaQA: true,
        showInisialAgent: true,
        showChannel: true,
        showTanggalInteraksi: true,
        showResponJawab: true,
        showNamaAgent: true,
    };

    // Menggunakan CurrentPageReference untuk mendapatkan recordId
    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c__recordId || null;
            console.log('Record ID (from CurrentPageReference):', this.recordId);

            if (!this.recordId) {
                this.fetchRecordIdFallback();
            }
        }
    }

    // Fallback method untuk mengambil recordId dari URL secara manual
    fetchRecordIdFallback() {
        this.recordId = new URLSearchParams(window.location.search).get('c__recordId');
        console.log('Fallback Record ID:', this.recordId);
    }

    connectedCallback() {
        this.initializeComponent();
        this.loadQAResponseItems();
    }  

    openModal() {
        this.isModalOpen = true; 
    }

    closeModal() {
        this.isModalOpen = false; 
    }

    async initializeComponent() {
        try {
            await this.loadQAResponse(); 
            // this.setFieldVisibility();
            await this.loadFieldConfig();   
            await this.loadData();    
            await this.loadQAResponseItems();
        } catch (error) {
            console.error('Error during component initialization:', error);
            this.showToast('Error', 'Failed to initialize component.', 'error');
        }
    }

    async loadData() {
        try {
            await this.loadPicklistOptions();
            await this.loadMasterData();
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    //untuk Load QA REsponse Item dari record
    async loadQAResponse() {
        if (!this.recordId) {
            console.error('RecordId QA Response is not provided');
            return;
        }
    
        try {
            const response = await getQAResponse({ RecordId: this.recordId });
            console.log('QA Response from Apex:', JSON.stringify(response, null, 2));
    
            if (!response || response.length === 0) {
                throw new Error('No QA Response data found for the given RecordId.');
            }
    
            // Ambil data dari response
            const record = response[0]; // Asumsikan hanya satu record yang dikembalikan

            // Map data ke formData untuk tampilkan di UI
            this.formData = {
                extAvayaIdLogin: record.Ext_Avaya_ID_Login__c || '',
                durasiPercakapan: record.Durasi_Percakapan__c || '',
                waktuInteraksi: record.Waktu_Interaksi__c || '',
                tanggalCallmon: record.Tanggal_Callmon__c || '',
                calltype: record.Call_Type__c || '',
                perihal: record.Perihal__c || '',
                namaQA: record.Nama_QA__c || '',
                inisialAgent: record.Inisial_Agent__c || '',
                channel: record.Channel__c || '',
                tanggalInteraksi: record.Tanggal_Interaksi__c || '',
                responJawab: record.Respon_Jawab__c || '',
                namaAgent: record.Nama_Agent__c || '',
                AgentId : record.Agent_Lookup__c || '',
                namaNasabah : record.Nama_Nasabah__c || '',
                nomorRekening : record.Nomor_Rekening__c || '',
                NomorKartu : record.Nomor_Kartu__c || '',
                NomorPonselTelepon : record.Nomor_Ponsel_Telepon__c || ''
            };

            this.recordTypeName = record.Kategori_Penilaian__c;
            console.log('Kategori Penilaian QA / RecordtypeName: ' + this.recordTypeName);
    
            const recordIdCase = record.No_Tiket_New__c;
            console.log('RecordId Case:', recordIdCase);
    
            // Fetch case details
            const data = await getCaseDetails({ caseId: recordIdCase });
    
            // Map case data dengan fallback default
            this.caseData = {
                CaseNumber: data[0]?.CaseNumber || 'N/A',
                SCC_Card_Number__c: data[0]?.SCC_Card_Number__c || this.formData.NomorKartu || 'N/A',
                SCC_Account_Number__c: data[0]?.SCC_Account_Number__c || this.formData.nomorRekening || 'N/A',
                Cust_Current_Phone__c: data[0]?.Cust_Current_Phone__c || this.formData.NomorPonselTelepon || 'N/A',
                Account: {
                    Name: data[0]?.Account?.Name  
                        || this.formData.namaNasabah  
                        || data[0]?.SCC_Nama_Pelapor__c 
                        || 'N/A'  
                }
            };
    
            console.log('Case Data:', JSON.stringify(this.caseData, null, 2));
        } catch (error) {
            console.error('Error fetching QA Response:', error);
            // this.showToast('Error', 'Failed to load QA Response data.', 'error');
        }
    }
       
    //untuk load pilihan table dari qa response item
    async loadQAResponseItems() {
        if (!this.recordId) {
            console.error('RecordId is not provided for QA Response Items.');
            return;
        }
    
        try {
            const responseItems = await getQAResponseItems({ RecordId: this.recordId });
    
            // Buat peta untuk memetakan data berdasarkan Master_QA__c
            const responseMap = new Map();
            responseItems.forEach(item => {
                responseMap.set(item.Master_QA__c, {
                    Id: item.Id, // ID existing dari QA_Response_Item__c
                    Hasil: item.Hasil__c || 0,
                    Keterangan: item.Keterangan_Penilaian_QA__c || '',
                    Finding: item.Finding__c || '',
                    sanggahanHasil: item.Sanggahan_Hasil__c ?? item.Hasil__c,
                    sanggahanFinding : item.Sanggahan_Finding__c || '',
                    sanggahanKeterangan : item.Sanggahan_Keterangan_Penilaian_QA__c ||  '',
                });
            });
    
            // Mapping data ke groupedData dan tambahkan ExistingRecordId
            this.groupedData = this.groupedData.map(section => {
                section.rows = section.rows.map(row => {
                    const matchedItem = responseMap.get(row.Id);
    
                    if (matchedItem) {
                        row.Hasil = matchedItem.Hasil;
                        row.Keterangan_Penilaian_QA__c = matchedItem.Keterangan;
                        row.ExistingRecordId = matchedItem.Id; 
                        row.sanggahanHasil__c = matchedItem.sanggahanHasil;
                        row.sanggahanKeterangan_Penilaian_QA__c = matchedItem.sanggahanKeterangan;
                        console.log('dataaaaaaaaa:' + row.Hasil +', '+ row.Keterangan_Penilaian_QA__c +', '+ row.sanggahanHasil__c +', '+ row.sanggahanKeterangan_Penilaian_QA__c);
    
                        // // Cek kecocokan nilai Finding dengan picklist options dan set default value
                        row.picklist.forEach(option => {
                            if (option.value === matchedItem.Finding) {
                                console.log('option Value: ' + option.value + " Finding: " + matchedItem.Finding);
                                option.selected = true; 
                            }
                        });
                        // // Cek kecocokan nilai Finding Sanggahan dengan picklist options dan set default value
                        row.picklistSanggahan.forEach(optionSanggahan => {
                            if (optionSanggahan.value === matchedItem.sanggahanFinding) {
                                console.log('option Value Sanggahan : ' + optionSanggahan.value + " Finding: " + matchedItem.sanggahanFinding);
                                optionSanggahan.selected = true;
                            }
                        });
    
                        // Tetapkan nilai Finding__c ke nilai default atau kosong jika tidak cocok
                        row.Finding__c = matchedItem.Finding || row.picklist[0]?.value || '';
                        row.sanggahanFinding__c = matchedItem.sanggahanFinding || '';
    
                        // Hitung skor
                        if (this.agentLeaderView === false) {
                            row.Skor = this.calculateSkor(row.Bobot__c, matchedItem.Hasil);
                            row.sanggahanSkor = this.calculateSkor(row.Bobot__c, matchedItem.sanggahanHasil);
                        } else {
                            row.Skor = this.calculateSkorLeader(row.Bobot__c, matchedItem.Hasil);
                            row.sanggahanSkor = this.calculateSkorLeader(row.Bobot__c, matchedItem.Hasil);
                        } 

                    }
                    return row;
                });
                // Panggil fungsi untuk menghitung total section score
                section.sectionScore = this.calculateSectionScore(section.rows, section.bobot);
                section.sectionSanggahanScore = this.calculateSanggahanSectionScore(section.rows, section.bobot);
                return section;
            });
    
            this.calculateErrorTotals();
            this.calculateErrorTotalsSanggahan();
            this.groupedData = [...this.groupedData]; // Force re-render
        } catch (error) {
            console.error('Error fetching QA Response Items:', error);
        }
    }
                 
    async loadFieldConfig() {
            if (!this.recordTypeName) {
                console.error('RecordTypeName is not provided');
                return;
            }
    
            try {
                const configs = await getFiturQAConfig();
                console.log('Fitur QA Configs:', configs);
    
                const config = configs.find(item => item.recordType === this.recordTypeName);
                console.log('Matching Config:', config);
    
                // Reset semua field ke visible (true)
                Object.keys(this.fieldVisibility).forEach(key => {
                    this.fieldVisibility[key] = true;
                });
    
                // Hidden fields → set ke false
                if (config.hiddenFields && config.hiddenFields.length > 0) {
                    config.hiddenFields.forEach(field => {
                        const propName = 'show' + field;
                        if (propName in this.fieldVisibility) {
                            this.fieldVisibility[propName] = false;
                        } else {
                            console.warn(`Unknown field in hiddenFields: ${propName}`);
                        }
                    });
                }
    
                // Agent Leader
                this.agentLeaderView = config.showAgentLeaderView || false;
    
            } catch (error) {
                console.error('Error loading field config:', error);
            }
        }

    processData(data) {
        console.log('Processing data with picklist options:');

        const grouped = data.reduce((acc, row) => {
            const sectionName = row.Section__r?.Name || 'Undefined Section';
            const sectionBobot = row.Section__r?.Bobot__c || null;
            const recordType = row.RecordType.Name;
    
            if (!acc[sectionName]) {
                acc[sectionName] = {
                    section: sectionName,
                    bobot: sectionBobot, 
                    rows: [],
                    sectionScore: 0, 
                    sectionSanggahanScore: 0,
                    recordTypeName:recordType
                };
            }

            // Use the appropriate picklist options
            const picklistForRowDefault = this.picklistOptionsDefault[row.Name] || []; // Default picklist options
            const picklistForRowSanggahan = this.picklistOptionsSanggahan[row.Name] || []; // Sanggahan picklist options

            acc[sectionName].rows.push({
                ...row,
                Hasil: '',
                Skor: 0,
                picklist: picklistForRowDefault,
                picklistSanggahan: picklistForRowSanggahan,
                Keterangan_Penilaian_QA__c: row.Keterangan_Penilaian_QA__c || ''
            });

            return acc;
        }, {});

        const groupedArray = Object.values(grouped);
        console.log('Grouped data with picklist options:', groupedArray);

        // Calculate section scores
        groupedArray.forEach(section => {
            section.sectionScore = this.calculateSectionScore(section.rows, section.bobot);
            section.sectionSanggahanScore = this.calculateSanggahanSectionScore(section.rows, section.bobot);

        });

        return groupedArray;
    }

    // Fetch and map picklist options
    async loadPicklistOptions() {
        if (!this.recordTypeName) {
            console.error('RecordTypeName is not provided');
            return;
        }

        try {
            const data = await getPicklistOptions({ recordTypeName: this.recordTypeName });
            console.log('Picklist options data from server:', data);

            // Group data for default options
            this.picklistOptionsDefault = data.reduce((acc, item) => {
                const key = item.Aspek_Penilaian__r.Name; // Group by 'Aspek_Penilaian__r.Name'
                if (!acc[key]) {
                    acc[key] = [];
                }
                acc[key].push({ value: item.Id, label: item.Name });
                return acc;
            }, {});

            // Duplicate or modify for sanggahan options
            this.picklistOptionsSanggahan = data.reduce((acc, item) => {
                const key = item.Aspek_Penilaian__r.Name;
                if (!acc[key]) {
                    acc[key] = [];
                }
                // Example: Add " (Sanggahan)" to differentiate sanggahan options
                acc[key].push({ value: item.Id, label: `${item.Name} (Sanggahan)` });
                return acc;
            }, {});

            console.log('Grouped picklist options (Default):', this.picklistOptionsDefault);
            console.log('Grouped picklist options (Sanggahan):', this.picklistOptionsSanggahan);
        } catch (error) {
            console.error('Error loading picklist options:', error);
            this.picklistOptionsDefault = {}; 
            this.picklistOptionsSanggahan = {}; 
        }
    }

    async loadMasterData() {
        if (!this.recordTypeName) {
            console.error('RecordTypeName is not provided');
            return;
        }

        try {
            const data = await getCaseMasterData({ recordTypeName: this.recordTypeName });
            console.log('Fetched master data:', data);
            this.groupedData = this.processData(data);
            console.log('Processed grouped data:', this.groupedData);
        } catch (error) {
            console.error('Error fetching master data:', error);
        }
    }

    // Calculate totals for Critical and Non-Critical errors, and total for all rows
    calculateErrorTotals() {
        this.totalCriticalError = 0; 
        this.totalNonCriticalError = 0; 
        this.totalUtama = 0;

        let criticalRowCount = 0; 
        let nonCriticalRowCount = 0; 

        this.groupedData.forEach(section => {
            const isNonCriticalSection = section.section === 'Non Critical Error';
            if (section.sectionScore !== undefined && section.sectionScore !== null && section.recordTypeName == 'AGENT LEADER') {
                this.totalUtama += section.sectionScore; 
            }
            section.rows.forEach(row => {
                const skor = row.Skor || 0; 
                if (section.recordTypeName === 'AGENT LEADER') {
                    if (skor !== 1) {
                        this.totalUtama += skor;
                    }
                } else {
                    this.totalUtama += skor;
                }
        
                if (isNonCriticalSection) {
                    if (row.Hasil === 0) {
                        this.countNonCriticalZero++; 
                    } else if (row.Hasil === 1) {
                        this.totalNonCriticalError++; 
                    }   
                } else {
                    if (row.Hasil === 0) {
                        this.countCriticalZero++; 
                    } else if (row.Hasil === 1) {
                        this.totalCriticalError++;
                    }   
                }
            });
        });

        console.log('Total Critical Error:', this.totalCriticalError);
        console.log('Total Non Critical Error:', this.totalNonCriticalError);
        console.log('Total Penilaian:', this.totalUtama);
        console.log('Critical Error yang 0:' + this.countCriticalZero);
        console.log('Non Critical Error yang 0:' + this.countNonCriticalZero);
    }

    //calculate totals for Critical and Non-Critical Errors SANGGAHAN
    calculateErrorTotalsSanggahan() {
        this.totalCriticalErrorSanggahan = 0; 
        this.totalNonCriticalErrorSanggahan = 0; 
        this.totalUtamaSanggahan = 0;
    
        this.countNonCriticalErrorSanggahan = 0;
        this.countCriticalErrorSanggahan = 0;
        console.log('Updated groupedData:', JSON.stringify(this.groupedData, null, 2));

        this.groupedData.forEach(section => {
            const isNonCriticalSection = section.section === 'Non Critical Error';
            if (section.sectionSanggahanScore !== undefined && section.sectionSanggahanScore !== null && section.recordTypeName === 'AGENT LEADER') {
                this.totalUtamaSanggahan += section.sectionSanggahanScore;
            }
            section.rows.forEach(row => {
                const skor = row.sanggahanSkor || 0;
                console.log("row sanggahan skor ini adalah: " + skor)
    
                // Tambahkan skor ke total utama sesuai aturan recordTypeName
                if (section.recordTypeName === 'AGENT LEADER') {
                    if (skor !== 1 ) {
                        this.totalUtamaSanggahan += skor;
                    }
                } else {
                    this.totalUtamaSanggahan += skor;
                }
    
                // Hitung jumlah Non-Critical dan Critical berdasarkan hasil sanggahan
                if (isNonCriticalSection) {
                    if (row.sanggahanHasil__c === 0) {
                        this.countNonCriticalErrorSanggahan++;
                    } else if (row.sanggahanHasil__c === 1) {
                        this.totalNonCriticalErrorSanggahan++; 
                    }
                } else {
                    if (row.sanggahanHasil__c === 0) {
                        this.countCriticalErrorSanggahan++; 
                    } else if (row.sanggahanHasil__c === 1) {
                        this.totalCriticalErrorSanggahan++;
                    }
                }
            });
        });
    
        // Log hasil perhitungan
        console.log('Total Critical Error Sanggahan:', this.totalCriticalErrorSanggahan);
        console.log('Total Non Critical Error Sanggahan:', this.totalNonCriticalErrorSanggahan);
        console.log('Total Penilaian Sanggahan:', this.totalUtamaSanggahan);
        console.log('Critical Error Sanggahan yang 0:', this.countCriticalErrorSanggahan);
        console.log('Non Critical Error Sanggahan yang 0:', this.countNonCriticalErrorSanggahan);
    }
    

    // Handle change in Hasil and calculate Skor
    handleHasilChange(event) {
        const rowId = event.target.dataset.id;
        let newHasil = parseFloat(event.target.value);

        // Get the Bobot value for the row
        const row = this.getRowById(rowId);
        const bobot = row ? row.Bobot__c : 0;
        
        // If Hasil is greater than Bobot, show a warning and set Hasil to null
        if (newHasil > bobot) {
            this.showToast('Warning', `Hasil tidak boleh lebih besar dari Bobot (${bobot}).`, 'warning');
            newHasil = ''; //set jadi kosong lagi
        }

        if (isNaN(newHasil)) {
            console.warn(`Invalid Hasil value for rowId ${rowId}: ${newHasil}`);
            return;
        }

        // Update the 'Hasil' value and recalculate 'Skor' for the respective row
        this.groupedData = this.groupedData.map(section => {
            section.rows = section.rows.map(row => {
                if (row.Id === rowId) {
                    row.Hasil = newHasil;
                    if (this.agentLeaderView === false) {
                        row.Skor = this.calculateSkor(row.Bobot__c, newHasil);
                    } else {
                        row.Skor = this.calculateSkorLeader(row.Bobot__c, newHasil);
                    }
                }
                return row;
            });
            // Calculate the section score after updating the row
            section.sectionScore = this.calculateSectionScore(section.rows, section.bobot);
            return section;
        });

        // Recalculate totals for Critical and Non-Critical errors after updating Skor
        this.calculateErrorTotals();

        // Force the component to re-render by setting the groupedData array again
        this.groupedData = [...this.groupedData];
    }

    //Handle Hasil Sanggahan dan calculate skor
    handleSangahanHasilChange(event) {
        const rowId = event.target.dataset.id;
        const inputValue = event.target.value;
        let newHasil = parseFloat(inputValue);
    
        // Get the Bobot value for the row
        const row = this.getRowById(rowId);
        const sectionBobot = row.Section__r?.Bobot__c || null;
        const sectionName = row?.Section__r?.Name || '';
    
        // Validasi agar input hanya angka
        if (isNaN(newHasil)) {
            this.showToast('Warning', 'Input harus berupa angka.', 'warning');
            newHasil = '';
        } else {
            // Validasi agar input tidak boleh decimal
            if (!Number.isInteger(newHasil)) {
                this.showToast('Warning', 'Input tidak boleh berupa angka desimal.', 'warning');
                newHasil = '';
            }
            // Validasi agar input tidak boleh negatif
            else if (newHasil < 0 || newHasil > 1) {
                this.showToast('Warning', 'Input harus angka 0 atau 1.', 'warning');
                newHasil = '';
            }else if (newHasil == 0) {
                this.showToast('Warning', `Harap Segera Isi Finding dan Keterangan.`, 'warning');
            }
        }
    
        if (this.agentLeaderView == true) {
            if(sectionBobot != null){
                if (newHasil == 0) {
                    this.showToast('Warning', `Harap Segera Isi Finding dan Keterangan.`, 'warning');
                }
            }
        }
    
        // Update the 'Hasil' value and recalculate 'Skor' for the respective row
        this.groupedData = this.groupedData.map(section => {
            section.rows = section.rows.map(row => {
                if (row.Id === rowId) {
                    const oldHasil = row.sanggahanHasil__c || 0; // Ambil nilai lama
                    row.sanggahanHasil__c = newHasil;
                    if (this.agentLeaderView === false) {
                        row.sanggahanSkor = this.calculateSkor(row.Bobot__c, newHasil);
                    } else {
                        row.sanggahanSkor = this.calculateSkorLeader(row.Bobot__c, newHasil);
                    }
                    if (oldHasil == 0 && newHasil != 0) {
                        if (sectionName === 'Critical Error') this.countCriticalErrorSanggahan--;
                        if (sectionName === 'Non Critical Error') this.countNonCriticalErrorSanggahan--;
                        if (sectionName === 'Critical Error') this.totalCriticalErrorSanggahan++;
                        if (sectionName === 'Non Critical Error') this.totalNonCriticalErrorSanggahan++;
                    }
                    if (oldHasil != 0 && newHasil == 0) {
                        if (sectionName === 'Critical Error') this.countCriticalErrorSanggahan++;
                        if (sectionName === 'Non Critical Error') this.countNonCriticalErrorSanggahan++;
                        if (sectionName === 'Critical Error') this.totalCriticalErrorSanggahan--;
                        if (sectionName === 'Non Critical Error') this.totalNonCriticalErrorSanggahan--;
                    }
                }
                return row;
            });
            // Panggil fungsi untuk menghitung total section score
            section.sectionSanggahanScore = this.calculateSanggahanSectionScore(section.rows, section.bobot);
            return section;
        });
    
        // Recalculate totals for Critical and Non-Critical errors after updating Skor
        this.calculateErrorTotalsSanggahan();
    
        // Force the component to re-render by setting the groupedData array again
        this.groupedData = [...this.groupedData];
    }    

    // Get row data by rowId
    getRowById(rowId) {
        for (const section of this.groupedData) {
            const row = section.rows.find(r => r.Id === rowId);
            if (row) {
                return row;
            }
        }
        return null;
    }

    // Calculate Skor = Hasil * Bobot
    calculateSkor(bobot, hasil) {
        if (isNaN(bobot) || isNaN(hasil)) {
            console.error(`Invalid Bobot (${bobot}) or Hasil (${hasil})`);
            return 0;
        }
        return (bobot * hasil); 
    }

    calculateSkorLeader(bobot, hasil){
        if (isNaN(hasil)) {
            console.error(`Invalid Bobot (${bobot}) or Hasil (${hasil})`);
            return 0;
        }
        else if(isNaN(bobot)){
            return (hasil * 1);
        }
        else{
            return (bobot * hasil); // Assuming Bobot is in percentage (0-100)
        }

    }

    calculateSectionScore(rows, bobot) {
        console.log('Calculating section score...');
        console.log('Rows:', rows);
        console.log('Bobot:', bobot);
        
        const hasZeroScore = rows.some(row => row.Skor === 0);
        if (hasZeroScore) {
            console.log('At least one row has a Skor of 0, setting total section score to 0.');
            return 0;
        }
        return bobot; 
    }

    calculateSanggahanSectionScore(rows, bobot) {
        console.log('Calculating section score...');
        console.log('Rows:', rows);
        console.log('Bobot:', bobot);
        
        const hasZeroScore = rows.some(row => row.sanggahanSkor === 0);
        if (hasZeroScore) {
            console.log('At least one row has a Skor of 0, setting total section score to 0.');
            return 0;
        }
        return bobot; 
    }

    handleKeteranganChange(event) {
        const rowId = event.target.dataset.id;
        const newKeterangan = event.target.value;
    
        // Update 'sanggahanKeterangan_Penilaian_QA__c' field
        this.groupedData = this.groupedData.map(section => {
            section.rows = section.rows.map(row => {
                if (row.Id === rowId) {
                    row.sanggahanKeterangan_Penilaian_QA__c = newKeterangan;
                    console.log('row sanggahan Ketereangan : ' + row.sanggahanKeterangan_Penilaian_QA__c);
                }
    
                return row;
            });
    
            return section;
        });
    
        // Force re-render
        this.groupedData = [...this.groupedData];
    }
    
    //untuk menerima hasil input dari form
    collectAllInputs() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let collectedData = {};
    
        // Loop untuk mengumpulkan data input
        inputs.forEach(input => {
            if (input.name) { 
                collectedData[input.name] = input.value || ''; 
            }
        });
    
        // Menambahkan Record ID
        collectedData['noTiketBricare'] = this.recordId || 'N/A';

        // Menambahkan Total dan Rata-rata Error
        collectedData['totalCriticalError'] = this.totalCriticalError || 0;
        collectedData['totalNonCriticalError'] = this.totalNonCriticalError || 0;
        collectedData['totalPenilaian'] = this.totalUtama || 0;
        collectedData['countCriticalZero'] = this.countCriticalZero || 0;
        collectedData['countNonCriticalZero'] = this.countNonCriticalZero || 0;
        collectedData['kategoriPenilaian']= this.recordTypeName || '';
        collectedData['subKategoriPenilaian'] = this.subVoice || '';
    
        //Untuk Total dan Rata-Rata Error Sanggahan
        collectedData['totalCriticalErrorSanggahan'] = this.totalCriticalErrorSanggahan || 0;
        collectedData['totalNonCriticalErrorSanggahan'] = this.totalNonCriticalErrorSanggahan || 0;
        collectedData['totalPenilaianSanggahan'] = this.totalUtamaSanggahan || 0;
        // collectedData['avgCriticalErrorSanggahan'] = this.avgCriticalErrorStrSanggahan || 0;
        // collectedData['avgNonCriticalErrorSanggahan'] = this.avgNonCriticalErrorStrSanggahan || 0;
        collectedData['countCriticalErrorSanggahan'] = this.countCriticalErrorSanggahan || 0;
        collectedData['countNonCriticalErrorSanggahan'] = this.countNonCriticalErrorSanggahan || 0;
        collectedData['sanggahanFlag'] = true;
    
        console.log('Collected Input Data with Totals and Averages:', JSON.stringify(collectedData));
        return collectedData;
    }

    validateInputs() {
        const isHasilValid = this.validateHasilInputs();
        const isFindingValid = this.validateFindingInputs();
        const isKeteranganValid = this.validateKeteranganInputs();
    
        return isHasilValid && isFindingValid && isKeteranganValid;
    }

    validateHasilInputs() {
        let missingHasil = [];
        // console.log('Validating Hasil...');
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                // console.log(`Checking: ${row.Name}, Hasil: ${row.Hasil}`);
                if (row.sanggahanHasil__c === undefined || row.sanggahanHasil__c === null || isNaN(row.sanggahanHasil__c) || row.sanggahanHasil__c === '') {
                    missingHasil.push(row.Name); 
                }
            });
        });
    
        if (missingHasil.length > 0) {
            this.showToast('Warning', `Kolom "Hasil" wajib diisi untuk aspek berikut: ${missingHasil.join(', ')}`, 'warning');
            return false; 
        }
        console.log('All hasil are filled correctly.');
        return true; 
    }  
    
    validateFindingInputs() {
        let missingFinding = [];
        
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                if (row.sanggahanHasil__c === 0 && (!row.sanggahanFinding__c || row.sanggahanFinding__c.trim() === '' || row.sanggahanFinding__c == undefined)) {
                    missingFinding.push(row.Name); 
                }
            });
        });
    
        if (missingFinding.length > 0) {
            this.showToast('Warning', `Kolom "Finding" wajib diisi untuk aspek berikut karena nilai "Hasil" adalah 0: ${missingFinding.join(', ')}`, 'warning');
            return false; 
        }
    
        return true; 
    }

    validateKeteranganInputs() {
        let missingKeterangan = [];
        
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                if (row.sanggahanHasil__c === 0 && (!row.sanggahanKeterangan_Penilaian_QA__c || row.sanggahanKeterangan_Penilaian_QA__c.trim() === '' || row.sanggahanKeterangan_Penilaian_QA__c == undefined)) {
                    missingKeterangan.push(row.Name); 
                }
            });
        });
    
        if (missingKeterangan.length > 0) {
            this.showToast('Warning', `Kolom "Keterangan" wajib diisi untuk aspek berikut karena nilai "Hasil" adalah 0: ${missingKeterangan.join(', ')}`, 'warning');
            return false; 
        }
    
        return true; 
    }
    
    //function untuk saveData
    async handleSaveData() {
        if (!this.validateInputs()) {
            this.closeModal();
            return; 
        }
        try {
            // 1. Collect all form inputs
            const formData = this.collectAllInputs();
            console.log("form data to Apex: " + formData);

            // Tambahkan Id jika ini adalah update
            if (this.recordId) {
                formData['Id'] = this.recordId;
            }

            // 2. Call Apex to save the form data and get recordId
            const recordId = await saveFormData({ formData: formData });
            console.log('Returned Record ID:', recordId);       

            // 3. Prepare table data dengan Id jika ada
            const tableRecords = this.prepareTableData(recordId);
            console.log('Table Records to Save:', JSON.stringify(tableRecords));

            // 4. Call Apex untuk saveQAResponseItems
            if (tableRecords.length > 0) {
                await saveTableData({ records: tableRecords });
            }

            // 5. Show success toast dan tutup modal
            this.showToast('Success', 'Data Sanggahan berhasil disimpan!', 'success');
            this.closeModal();
            this.closeTab();

            // Delay to allow Salesforce to close the tab completely
            await this.delay(500);  // Delay for 500ms (adjust if needed)
            console.log('Tab closed successfully, refreshing page...');

            // Refresh the page
            window.location.reload();
        } catch (error) {
            console.error('Error saving data:', error);
            this.showToast('Error', 'Gagal menyimpan data.', 'error');
            this.closeModal();
        }
    }

    // Prepare table data and include the parent recordId
    prepareTableData(recordId) {
        const tableRecords = [];
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                let skorAgentLeader;
                if (this.agentLeaderView) {
                    skorAgentLeader = String(section.sectionScore);
                } else {
                    skorAgentLeader = '0';
                }
                const record = {
                    Id: row.ExistingRecordId || null,
                    Sanggahan_Hasil__c: row.sanggahanHasil__c,
                    Sanggahan_Finding__c: row.sanggahanFinding__c,
                    Sanggahan_Keterangan_Penilaian_QA__c: row.sanggahanKeterangan_Penilaian_QA__c,
                    Sanggahan_Skor_Agent_Leader__c: skorAgentLeader
                };
                tableRecords.push(record);
            });
        });
        return tableRecords;
    }
    
    // Handle changes to the picklist value
    handleFindingChange(event) {
        const rowId = event.target.dataset.id;
        const selectedValue = event.target.value;
    
        // Find the label corresponding to the selected picklist value
        let selectedLabel = '';
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                if (row.Id === rowId && row.picklistSanggahan) {
                    const matchingOption = row.picklistSanggahan.find(optionSanggahan => optionSanggahan.value === selectedValue);
                    if (matchingOption) {
                        selectedLabel = matchingOption.label;
                    }
                }
            });
        });
    
        // Update 'sanggahanFinding__c' field
        this.groupedData = this.groupedData.map(section => {
            section.rows = section.rows.map(row => {
                if (row.Id === rowId) {
                    row.sanggahanFinding__c = selectedValue;
                    row.sanggahanFindingLabel = selectedLabel;
                }
                return row;
            });
            return section;
        });
    
        // Force re-render
        this.groupedData = [...this.groupedData];
    }
        

    // Handles input changes for all fields
    handleInputChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value || ''; // Ganti null/undefined dengan string kosong
    
        if (!fieldName) {
            console.error('Field name is missing for the input element.');
            return;
        }
    
        this.formData = { ...this.formData, [fieldName]: fieldValue };
        console.log('Updated Form Data:', this.formData);
    }
    
    //close tab
    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        console.log('tab id'+ tabId);
        await closeTab(tabId);
    }

    // Utility untuk menampilkan toast
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}