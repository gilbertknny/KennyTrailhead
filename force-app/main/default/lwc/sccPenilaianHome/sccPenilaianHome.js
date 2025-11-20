import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import getCaseMasterData from '@salesforce/apex/SCC_PenilaianQA_ctrl.getCaseMasterData';
import saveTableData from '@salesforce/apex/SCC_PenilaianQA_ctrl.saveQAResponseItems';
import saveFormData from '@salesforce/apex/SCC_PenilaianQA_ctrl.saveFormData';
import getPicklistOptions from '@salesforce/apex/SCC_PenilaianQA_ctrl.getPicklistOptions'; 
import getCaseDetails from '@salesforce/apex/SCC_PenilaianQA_ctrl.getCaseDetails'; 
import searchUsers from '@salesforce/apex/SCC_PenilaianQA_ctrl.searchUsers';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';
import getFiturQAConfig from '@salesforce/apex/SCC_PenilaianQA_ctrl.getFiturQAConfig';

export default class SCC_penilaianQA_Home extends LightningElement {
    @wire(IsConsoleNavigation) isConsoleNavigation;

    @track searchKeyword = '';
    @track searchResults = [];
    @track selectedAgentName = '';
    @track selectedAgentId = '';
    @track showSelectedAgent = false;
    @track isDropdownOpen = false;
    @track isSaving = false;

    @track formData = {}
    @track countNonCriticalZero;
    @track countCriticalZero;

    @api recordTypeName;
    @api recordId;
    @api subVoice;
    @api totalCriticalError;
    @api totalNonCriticalError;
    @api totalUtama;
    @api avgCriticalError;
    @api avgNonCriticalError;
    @api avgCriticalErrorStr;
    @api avgNonCriticalErrorStr;
    @api timestamp;

    userId = USER_ID;
    userName = '';

    @wire(getRecord, { recordId: '$userId', fields: [USER_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.userName = data.fields.Name.value;
            console.log('Nama QA:', this.userName);
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    handleSearchChange(event) {
        this.searchKeyword = event.target.value;

        if (this.searchKeyword.length > 2) {
            this.isDropdownOpen = true;
            searchUsers({ searchKeyword: this.searchKeyword })
                .then((result) => {
                    this.searchResults = result.map(user => ({
                        Id: user.Id,
                        Name: user.Name + ' - ' + user.EmployeeNumber
                    }));
                })
                .catch((error) => {
                    console.error('Error fetching users:', error);
                    this.searchResults = [];
                });
        } else {
            this.searchResults = [];
            this.isDropdownOpen = false;
        }
    }

    handleSelect(event) {
        const agentId = event.target.dataset.id;
        const agentName = event.target.dataset.name;

        this.selectedAgentId = agentId;
        this.selectedAgentName = agentName;
        this.searchKeyword = '';
        this.searchResults = [];
        this.isDropdownOpen = false;
        this.showSelectedAgent = true;
    }

    closeDropdown() {
        this.isDropdownOpen = false; // Menutup dropdown secara manual dengan tombol X
    }

    caseData = {
        CaseNumber: 'N/A',
        SCC_Card_Number__c: 'N/A',
        SCC_Account_Number__c: 'N/A',
        Cust_Current_Phone__c: 'N/A',
        Account: {
            Name: 'N/A'
        },
        Owner: {
            Id: 'N/A',
            Name : 'N/A'
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

    fieldVisibilityConfig = new Map(); 

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

    loadFieldConfig() {
        getFiturQAConfig()
            .then((data) => {
                console.log('getFiturQAConfig:', data);
                const map = new Map();
                data.forEach(item => {
                    map.set(item.recordType, {
                        hiddenFields: item.hiddenFields,
                        showAgentLeaderView: item.showAgentLeaderView
                    });
                });
                this.fieldVisibilityConfig = map;
                this.setFieldVisibility(); // baru set visibility setelah config loaded
            })
            .catch((error) => {
                console.error('Error loading field visibility config:', error);
            });
    }

    connectedCallback() {
        console.log('Record ID received in child LWC: ', this.recordId);
        console.log('Record Type Name: ', this.recordTypeName);
        console.log('Sub-Voice:', this.subVoice);
        this.loadData();
        this.loadCaseDetails();
        // this.setFieldVisibility();
        this.loadFieldConfig();
    }

    openModal() {
        this.isModalOpen = true; 
    }

    closeModal() {
        this.isModalOpen = false; 
    }

    async loadData() {
        try {
            await this.loadPicklistOptions();
            await this.loadMasterData();
        } catch (error) {
            console.error('Error loading data:', error);
        }
    }

    // untuk load case details data dari BackEnd
    async loadCaseDetails() {
        if (!this.recordId) {
            console.error('RecordId is not provided');
            return;
        }

        try {
            const data = await getCaseDetails({ caseId: this.recordId });
            
            // Validate data and set default values
            this.caseData = {
                CaseNumber: data[0].CaseNumber || 'N/A',
                SCC_Card_Number__c: data[0].SCC_Card_Number__c || 'N/A',
                SCC_Account_Number__c: data[0].SCC_Account_Number__c || 'N/A',
                Cust_Current_Phone__c: data[0].Cust_Current_Phone__c || 'N/A',
                Account: {
                    Name: data[0].Account?.Name || data[0].SCC_Nama_Pelapor__c || 'N/A'
                },
                Owner: {
                    Id: data[0].Owner?.Id || 'N/A',
                    Name: data[0].Owner?.Name || 'N/A'
                }
            };
            
    
            console.log('Validated Case Data:', JSON.stringify(this.caseData, null, 2));
        } catch (error) {
            console.error('Error fetching Case Details:', error);
        }
    }

    setFieldVisibility() {
        if (!this.recordTypeName || !this.fieldVisibilityConfig.has(this.recordTypeName)) {
            console.warn('Config belum ada atau recordTypeName belum valid:', this.recordTypeName);
            return;
        }

        this.resetFieldVisibility();

        const config = this.fieldVisibilityConfig.get(this.recordTypeName);
        console.log(`Config for ${this.recordTypeName}:`, config);

        if (config && Array.isArray(config.hiddenFields)) {
            config.hiddenFields.forEach(fieldName => {
                const propName = 'show' + fieldName;
                if (propName in this.fieldVisibility) {
                    this.fieldVisibility[propName] = false;
                } else {
                    console.warn(`Field ${propName} tidak ditemukan di fieldVisibility`);
                }
            });

            this.agentLeaderView = config.showAgentLeaderView;
        }
    }

    resetFieldVisibility() {
        Object.keys(this.fieldVisibility).forEach(key => {
            this.fieldVisibility[key] = true;
        });
        this.agentLeaderView = false;
    }

    processData(data) {
        if (!this.picklistOptions) {
            console.warn('Picklist options are empty or not loaded. Defaulting to empty picklists.');
            this.picklistOptions = {};
        }

        console.log('Processing data with picklist options:', this.picklistOptions);

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
                    recordTypeName: recordType
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
        console.log('Grouped data with picklist options:', JSON.stringify(groupedArray));

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
            console.error('Error fetching master data:', error.message);
        }
    }

    // Calculate totals for Critical and Non-Critical errors, and total for all rows
    calculateErrorTotals() {
        this.totalCriticalError = 0; 
        this.totalNonCriticalError = 0; 
        this.totalUtama = 0;

        this.countCriticalZero = 0;
        this.countNonCriticalZero = 0;

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

    // Handle change in Hasil and calculate Skor
    handleHasilChange(event) {
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
            // Validasi agar input tidak boleh negatif dan tidak boleh lebih besar daripada 1
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
                    const oldHasil = row.Hasil || 0; // Ambil nilai lama
                    row.Hasil = newHasil;
                    if (this.agentLeaderView == true) {
                        row.Skor = this.calculateSkorLeader(row.Bobot__c, newHasil);
                    } else {
                        row.Skor = this.calculateSkor(row.Bobot__c, newHasil);
                    }

                    if (oldHasil == 0 && newHasil != 0) {
                        if (sectionName === 'Critical Error') this.countCriticalZero--;
                        if (sectionName === 'Non Critical Error') this.countNonCriticalZero--;
                        if (sectionName === 'Critical Error') this.totalCriticalError++;
                        if (sectionName === 'Non Critical Error') this.totalNonCriticalError++;
                    }
                    if (oldHasil != 0 && newHasil == 0) {
                        if (sectionName === 'Critical Error') this.countCriticalZero++;
                        if (sectionName === 'Non Critical Error') this.countNonCriticalZero++;
                        if (sectionName === 'Critical Error') this.totalCriticalError--;
                        if (sectionName === 'Non Critical Error') this.totalNonCriticalError--;
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
        
        const hasZeroScore = rows.some(row => row.Skor === 0);
        if (hasZeroScore) {
            console.log('At least one row has a Skor of 0, setting total section score to 0.');
            return 0;
        }
        return bobot; 
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
        // collectedData['avgCriticalError'] = this.avgCriticalErrorStr || 0;
        // collectedData['avgNonCriticalError'] = this.avgNonCriticalErrorStr || 0;
        collectedData['countCriticalZero']  = this.countCriticalZero || 0;
        collectedData['countNonCriticalZero'] = this.countNonCriticalZero || 0;
        collectedData['kategoriPenilaian']= this.recordTypeName || '';
        collectedData['subKategoriPenilaian'] = this.subVoice || '';
        collectedData['isDirect_Penilaian_QA__c'] = 'false';
    
        console.log('Collected Input Data with Totals and Averages:', JSON.stringify(collectedData));
        return collectedData;
    }
    
    //function untuk saveData
    async handleSaveData() {
        this.isSaving = true;

        if (!this.validateMandatoryFields()) {
            this.isSaving = false;
            this.closeModal();
            return;
        }

        if (!this.validateInputs()) {
            this.isSaving = false;
            this.closeModal();
            return; 
        }

        try {
            // 1. Collect all form inputs
            const formData = this.collectAllInputs();
            console.log("form data to Apex: " + formData);

            // 2. Call Apex to save the form data and get recordId
            const recordId = await saveFormData({ formData: formData });
            console.log('Returned Record ID:', recordId);
            if (!recordId) {
                throw new Error('Record ID is empty or null');
            }            

            // 3. Prepare table data with the returned recordId
            const tableRecords = this.prepareTableData(recordId);
            console.log('Table Data to Save:', JSON.stringify(tableRecords));

            // 4. Call Apex to save table data
            await saveTableData({ records: tableRecords });

            // 5. Show success toast
            this.showToast('Success', 'Data berhasil disimpan!', 'success');
            this.closeModal();
            console.log('close tab');
            this.closeTab();
        } catch (error) {
            console.error('Error saving data:', error);
            this.showToast('Error', 'Gagal menyimpan data.', 'error');
        } finally {
            // Enable button kembali dan sembunyikan loading setelah proses selesai
            this.isSaving = false;
        }
    }
    
    // Prepare table data and include the parent recordId
    prepareTableData(recordId) {
        const tableRecords = [];
        this.groupedData.forEach(section => {
            section.rows.forEach(row => {
                const record = {
                    Master_QA__c: row.Id, // Id dari QA Master 
                    Hasil__c: row.Hasil,
                    Finding__c: row.Finding__c,
                    Keterangan_Penilaian_QA__c: row.Keterangan_Penilaian_QA__c,
                    Fitur_Penilaian_QA__c: recordId,
                    Skor_Agent_Leader__c: String(section.sectionScore)
                };
                tableRecords.push(record);
            });
        });
        return tableRecords;
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
                if (row.Hasil === undefined || row.Hasil === null || isNaN(row.Hasil) || row.Hasil === '') {
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
                if (row.Hasil === 0 && (!row.Finding__c || row.Finding__c.trim() === '' || row.Finding__c == undefined)) {
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
                if (row.Hasil === 0 && (!row.Keterangan_Penilaian_QA__c || row.Keterangan_Penilaian_QA__c.trim() === '' || row.Keterangan_Penilaian_QA__c == undefined)) {
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

    validateMandatoryFields() {
        let isValid = true;
        let errorMessages = []; // Array untuk menyimpan pesan kesalahan
    
        // Validasi Nama Agent Terpilih
        if (!this.selectedAgentName || this.selectedAgentName.trim() === '') {
            errorMessages.push('Field "Nama Agent" wajib diisi.');
            isValid = false;
        }
    
        // Validasi Tanggal Callmon
        if (!this.formData.tanggalCallmon || this.formData.tanggalCallmon.trim() === '') {
            errorMessages.push('Field "Tanggal Callmon" wajib diisi.');
            isValid = false;
        }

        // Validasi Tanggal Interaksi
        if(this.recordTypeName == 'Non_Voice'){
            if (!this.formData.tanggalInteraksi || this.formData.tanggalInteraksi.trim() === '') {
                errorMessages.push('Field "Tanggal Intearksi" wajib diisi.');
                isValid = false;
            }
        }
    
        // Tampilkan pesan kesalahan menggunakan Toast jika ada error
        if (!isValid) {
            this.showToast(
                'Error',
                `Harap isi semua field wajib:\n${errorMessages.join('\n')}`,
                'error'
            );
        }
    
        return isValid;
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
        console.log('tab id' + tabId);
        await closeTab(tabId);
    
        // Reload halaman setelah menutup tab
        setTimeout(() => {
            location.reload();
        }, 1000); // Delay 1 detik untuk memastikan tab ditutup sebelum reload
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