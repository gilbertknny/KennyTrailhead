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

export default class scc_penilaianQA_edit extends LightningElement {
    @wire(IsConsoleNavigation) isConsoleNavigation;

    @track formData = {}

    @api recordTypeName;
    @api recordId;
    @api recordIdCase;
    @api subVoice;
    @api totalCriticalError;
    @api totalNonCriticalError;
    @api totalUtama
    @api avgCriticalError;
    @api avgNonCriticalError;
    @api avgCriticalErrorStr;
    @api avgNonCriticalErrorStr;
    @api timestamp;

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
        console.log('recordId QA Response: ' + this.recordId);
        this.initializeComponent();
        // this.loadQAResponseItems();
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
                namaAgent: record.Nama_Agent__c || ''
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
                SCC_Card_Number__c: data[0]?.SCC_Card_Number__c || 'N/A',
                SCC_Account_Number__c: data[0]?.SCC_Account_Number__c || 'N/A',
                Cust_Current_Phone__c: data[0]?.Cust_Current_Phone__c || 'N/A',
                Account: data[0]?.Account ? { Name: data[0].Account.Name || 'N/A' } : { Name: 'N/A' }
            };
    
            console.log('Case Data:', JSON.stringify(this.caseData, null, 2));
        } catch (error) {
            console.error('Error fetching QA Response:', error);
            this.showToast('Error', 'Failed to load QA Response data.', 'error');
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
                    Hasil: item.Hasil__c || '0',
                    Keterangan: item.Keterangan_Penilaian_QA__c || '',
                    Finding: item.Finding__c || ''
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
                        
                        //Check if picklist match with Finding Record
                        row.picklist.forEach(option => {
                            if (option.value === matchedItem.Finding) {
                                console.log('option Value: ' + option.value + " Finding: " + matchedItem.Finding);
                                option.selected = true; // Tambahkan atribut `selected` ke opsi yang cocok
                            }
                        });
    
                        // Tetapkan nilai Finding__c ke nilai default atau kosong jika tidak cocok
                        row.Finding__c = matchedItem.Finding || row.picklist[0]?.value || '';
                        if (this.agentLeaderView === false) {
                            row.Skor = this.calculateSkor(row.Bobot__c, matchedItem.Hasil);
                        } else {
                            row.Skor = this.calculateSkorLeader(row.Bobot__c, matchedItem.Hasil);
                        }  
                    }
                    return row;
                });
                // Panggil fungsi untuk menghitung total section score
                section.sectionScore = this.calculateSectionScore(section.rows, section.bobot);
                return section;
            });
    
            this.calculateErrorTotals();
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


    // async setFieldVisibility() {
    //     // Set visibility based on recordTypeName
    //     if (this.recordTypeName == 'Voice') {
    //         this.showInisialAgent = false;
    //         this.showChannel = false;
    //         this.showTanggalInteraksi = false;
    //         this.showResponJawab = false;
    //     } else if (this.recordTypeName == 'Non_Voice' || this.recordTypeName == 'Non Voice (SMS, Email, Layanan Peduli E-Channel)') {
    //         this.showNomorKartu = false;
    //         this.showNomorRekening = false;
    //         this.showNomorPonsel = false;
    //         this.showExtAvaya = false;
    //         this.showDurasi = false;
    //         this.showWaktuInteraksi = false;  
    //     } else if(this.recordTypeName == 'VBS'){
    //         this.showInisialAgent = false;
    //         this.showChannel = false;
    //         this.showTanggalInteraksi = false;
    //         this.showResponJawab = false;
    //     } else if(this.recordTypeName == 'URS_Urgent_Call_Recovery_Service' || this.recordTypeName == 'URS (Urgent Call Recovery Service)'){
    //         this.showInisialAgent = false;
    //         this.showChannel = false;
    //         this.showTanggalInteraksi = false;
    //         this.showResponJawab = false;
    //     } else if(this.recordTypeName == 'RPS_BRING_LOP' || this.recordTypeName == 'RPS (BRING & LOP)'){
    //         this.showExtAvaya = false;
    //         this.showInisialAgent = false;
    //         this.showChannel = false;
    //         this.showTanggalInteraksi = false;
    //         this.showResponJawab = false;
    //     } else if(this.recordTypeName == 'RPS_Non_BRING_LOP' || this.recordTypeName == 'RPS (BRING & LOP)'){
    //         this.showInisialAgent = false;
    //         this.showChannel = false;
    //         this.showTanggalInteraksi = false;
    //         this.showResponJawab = false;
    //     } else if(this.recordTypeName == 'AL_Agent_Leader' || this.recordTypeName == 'AL (Agent Leader)'){
    //         this.showNamaNasabah = false;
    //         this.showNomorKartu = false;
    //         this.showNomorRekening = false;
    //         this.showNomorPonsel = false;
    //         this.showInisialAgent = false;
    //         this.showChannel = false;
    //         this.showTanggalInteraksi = false;
    //         this.showResponJawab = false;
    //         // For Agent Leader View
    //         this.agentLeaderView = true;
    //     }
    // }

    processData(data) {
        if (!this.picklistOptions) {
            console.warn('Picklist options are empty or not loaded. Defaulting to empty picklists.');
            this.picklistOptions = {};
        }

        console.log('Processing data with picklist options:', this.picklistOptions);

        const grouped = data.reduce((acc, row) => {
            const sectionName = row.Section__r?.Name || 'Undefined Section';
            const sectionBobot = row.Section__r?.Bobot__c || null;
    
            if (!acc[sectionName]) {
                acc[sectionName] = {
                    section: sectionName,
                    bobot: sectionBobot, // Store Bobot__c in the grouped data
                    rows: [],
                    sectionScore: 0 // Initialize section score
                };
            }
    
            const picklistForRow = this.picklistOptions[row.Name] || []; // Default to empty picklist
    
            acc[sectionName].rows.push({
                ...row,
                Hasil: '',
                Skor: 0,
                picklist: picklistForRow,
                Keterangan_Penilaian_QA__c: row.Keterangan_Penilaian_QA__c || ''
            });

            return acc;
        }, {});

        const groupedArray = Object.values(grouped);
        console.log('Grouped data with picklist options:', groupedArray);

        // Calculate section scores
        groupedArray.forEach(section => {
            section.sectionScore = this.calculateSectionScore(section.rows, section.bobot); // Pass bobot to calculate score
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

            this.picklistOptions = data.reduce((acc, item) => {
                const key = item.Aspek_Penilaian__r.Name; 
                if (!acc[key]) {
                    acc[key] = [];
                }
                acc[key].push({ value: item.Id, label: item.Name });
                return acc;
            }, {});

            console.log('Grouped picklist options:', this.picklistOptions);
        } catch (error) {
            console.error('Error loading picklist options:', error);
            this.picklistOptions = {}; // Ensure picklistOptions is defined even if there's an error
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

            section.rows.forEach(row => {
                const skor = row.Skor || 0; 

                this.totalUtama += skor;
                // If section is Non-Critical, add to Non-Critical Error total
                if (isNonCriticalSection) {
                    this.totalNonCriticalError += skor;
                    nonCriticalRowCount++; // Increment count for Non-Critical Error rows
                } else {
                    // Else add to Critical Error total
                    this.totalCriticalError += skor;
                    criticalRowCount++; // Increment count for Critical Error rows
                }
            });
        });

        // Menghitung rata-rata untuk Total Critical Error
        this.averageCriticalError = criticalRowCount > 0 ? parseFloat((this.totalCriticalError / criticalRowCount).toFixed(2)) : 0;
        // Menghitung rata-rata untuk Total Non-Critical Error
        this.averageNonCriticalError = nonCriticalRowCount > 0 ? parseFloat((this.totalNonCriticalError / nonCriticalRowCount).toFixed(2)) : 0;

        this.avgCriticalErrorStr = this.averageCriticalError.toFixed(2);
        this.avgNonCriticalErrorStr = this.averageNonCriticalError.toFixed(2);

        console.log('Sending to Flow:');
        console.log('Total Critical Error:', this.totalCriticalError);
        console.log('Total Non Critical Error:', this.totalNonCriticalError);
        console.log('Total Penilaian:', this.totalUtama);
        console.log('Average Critical Error String:', this.averageCriticalError);
        console.log('Average Non Critical Error String:', this.averageNonCriticalError);
        // handleSendDataToFlow();
    }

    // Handle change in Hasil and calculate Skor
    handleHasilChange(event) {
        const rowId = event.target.dataset.id;
        const inputValue = event.target.value;
        let newHasil = parseFloat(inputValue);

        // Get the Bobot value for the row
        const row = this.getRowById(rowId);
        const bobot = row ? row.Bobot__c : 0;
        const sectionBobot = row.Section__r?.Bobot__c || null;

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
            else if (newHasil < 0) {
                this.showToast('Warning', 'Input tidak boleh berupa angka negatif.', 'warning');
                newHasil = '';
            }
        }
        
        // If Hasil is greater than Bobot, show a warning and set Hasil to null
        if (newHasil > bobot) {
            this.showToast('Warning', `Hasil tidak boleh lebih besar dari Bobot (${bobot}).`, 'warning');
            newHasil = ''; //set jadi kosong lagi
        }

        if (this.agentLeaderView == true) {
            if(sectionBobot != null){
                if (newHasil > sectionBobot) {
                    this.showToast('Warning', `Hasil tidak boleh lebih besar dari Section Bobot (${sectionBobot}).`, 'warning');
                    newHasil = ''; // Set jadi kosong lagi
                }
            }
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
            section.sectionScore = this.calculateSectionScore(section.rows, section.bobot); // Recalculate section score
            return section;
        });

        // Recalculate totals for Critical and Non-Critical errors after updating Skor
        this.calculateErrorTotals();

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
        return (bobot * hasil); // Assuming Bobot is in percentage (0-100)
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
    
        // Check if bobot is null
        if (bobot === null || bobot === 0) {
            const totalScore = rows.reduce((total, row) => {
                console.log('Processing row for total score:', row);
                return total + (row.Skor || 0); // Sum all Skor values, treating undefined or null as 0
            }, 0);
            
            console.log('Total section score calculated (bobot is null):', totalScore);
            return totalScore; // Return the sum of all row scores
        }
        
        // Check if any row has a Skor of 0
        const hasZeroScore = rows.some(row => row.Skor === 0);
        if (hasZeroScore) {
            console.log('At least one row has a Skor of 0, setting total section score to 0.');
            return 0; // Return 0 if any row has a score of 0
        }

        const totalScore = rows.reduce((total, row) => {
            console.log('Processing row:', row);
    
            // Only include the score if it's greater than zero
            if (row.Skor > 0) {
                const rowContribution = row.Skor * bobot;
                console.log(`Row Skor: ${row.Skor}, Contribution to total: ${rowContribution}`);
                return total + rowContribution;
            }
    
            console.log(`Row Skor is 0 or less, skipping this row.`);
            return total; // If Skor is 0, do not add anything
        }, 0);
    
        console.log('Total section score calculated:', totalScore);
        return totalScore;
    }

    handleKeteranganChange(event) {
        const rowId = event.target.dataset.id;
        const newKeterangan = event.target.value; 
    
        // Update nilai Keterangan_Penilaian_QA__c untuk baris yang relevan
        this.groupedData = this.groupedData.map(section => {
            section.rows = section.rows.map(row => {
                if (row.Id === rowId) {
                    row.Keterangan_Penilaian_QA__c = newKeterangan;
                }
                return row;
            });
            return section;
        });    
        // Force re-render untuk memastikan data terbaru ditampilkan
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
        collectedData['avgCriticalError'] = this.avgCriticalErrorStr || 0;
        collectedData['avgNonCriticalError'] = this.avgNonCriticalErrorStr || 0;
        collectedData['kategoriPenilaian']= this.recordTypeName || '';
        collectedData['subKategoriPenilaian'] = this.subVoice || '';
    
        console.log('Collected Input Data with Totals and Averages:', JSON.stringify(collectedData));
        return collectedData;
    }
    
    //function untuk saveData
    async handleSaveData() {
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
            this.showToast('Success', 'Data berhasil disimpan!', 'success');
            this.closeModal();
            this.closeTab();
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
                    Master_QA__c: row.Id, // Id dari QA Master 
                    Hasil__c: row.Hasil,
                    Finding__c: row.Finding__c,
                    Keterangan_Penilaian_QA__c: row.Keterangan_Penilaian_QA__c,
                    Skor_Agent_Leader__c: skorAgentLeader
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
    
        // Cari label yang sesuai untuk selectedValue
        let selectedLabel = '';
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                if (row.Id === rowId && row.picklist) {
                    const matchingOption = row.picklist.find(option => option.value === selectedValue);
                    if (matchingOption) {
                        selectedLabel = matchingOption.label;
                    }
                }
            });
        });
    
        // Log ID, value, dan label pilihan yang dipilih
        console.log(`Selected Row ID: ${rowId}, Selected Value: ${selectedValue}, Selected Label: ${selectedLabel}`);
    
        // Update nilai Finding__c dan tambahkan selectedLabel ke row
        this.groupedData = this.groupedData.map(section => {
            section.rows = section.rows.map(row => {
                if (row.Id === rowId) {
                    row.Finding__c = selectedValue; // Update value
                    row.FindingLabel = selectedLabel; // Simpan label untuk keperluan penyimpanan
                }
                return row;
            });
            return section;
        });
    
        // Force re-render to reflect the updated data
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
}