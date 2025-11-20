import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { IsConsoleNavigation, getFocusedTabInfo, closeTab } from 'lightning/platformWorkspaceApi';
import { NavigationMixin } from 'lightning/navigation';
import getRecordTypes from '@salesforce/apex/SCC_PenilaianQA_ctrl.getQARecordType';
import getSubVoicePicklistValues from '@salesforce/apex/SCC_PenilaianQA_ctrl.getSubVoicePicklistValues';
import searchUsers from '@salesforce/apex/SCC_PenilaianQA_ctrl.searchUsers';
import getCaseMasterData from '@salesforce/apex/SCC_PenilaianQA_ctrl.getCaseMasterData';
import getPicklistOptions from '@salesforce/apex/SCC_PenilaianQA_ctrl.getPicklistOptions'; 
import saveTableData from '@salesforce/apex/SCC_PenilaianQA_ctrl.saveQAResponseItems';
import saveFormData from '@salesforce/apex/SCC_PenilaianQA_ctrl.saveFormData';
import checkPermission from '@salesforce/apex/SCC_PenilaianQA_ctrl.hasQAPermission';
import USER_ID from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';

export default class Scc_PenilaianQA_Home extends NavigationMixin(LightningElement) {
    @wire(IsConsoleNavigation) isConsoleNavigation;

    @track searchKeyword = '';
    @track searchResults = [];
    @track selectedAgentName = '';
    @track selectedAgentId = '';
    @track showSelectedAgent = false;
    @track isDropdownOpen = false;
    @track isSaving = false;
    
    @track recordTypeOptions = [];
    @track selectedValue;
    @track isSubVoiceVisible = false;
    @track subVoiceOptions = [];
    @track selectedSubVoice;
    @track showCategoryPicklist = true;
    @track redirect = false;
    @track groupedData = [];
    @track formData = {};
    @track isModalOpen = false;
    @track hasAccess = false; 

    @api recordId;
    @api recordTypeName;
    @api totalCriticalError = 0;
    @api totalNonCriticalError = 0;
    @api totalUtama = 0;
    @api countCriticalZero = 0;
    @api countNonCriticalZero = 0;

    userId = USER_ID;
    userName = '';

    showNamaNasabah = true;
    showNomorKartu = true;
    showNomorRekening = true;
    showNomorPonsel = true;
    showExtAvaya = true;
    showDurasi = true;
    showWaktuInteraksi = true;
    showTanggalCallmon = true;
    showCalltype = true;
    showPerihal = true;
    showNamaQA = true;
    showInisialAgent = true;
    showChannel = true;
    showTanggalInteraksi = true;
    showResponJawab = true;
    showNamaAgent = true;

    connectedCallback() {
        this.checkUserPermission();
        this.loadRecordTypes();
        this.loadSubVoicePicklist();
        this.setFieldVisibility();
    }

    checkUserPermission() {
        checkPermission()
            .then((hasAccess) => {
                console.log('Hasil pengecekan permission:', hasAccess);
                this.hasAccess = hasAccess; // Jika memiliki akses, tampilkan halaman
            })
            .catch((error) => {
                console.error('Error checking permission:', error);
                this.hasAccess = false; // Jika terjadi error, tetap sembunyikan konten
            });
    }


    setFieldVisibility() {
        console.log("pilihan reocrdTYpenya: " + this.selectedValue)
        this.resetFieldVisibility();
        // Set visibility based on recordTypeName
        if (this.selectedValue == 'Voice') {
            this.showInisialAgent = false;
            this.showChannel = false;
            this.showTanggalInteraksi = false;
            this.showResponJawab = false;
        } else if (this.selectedValue == 'Non_Voice') {
            this.showNomorKartu = false;
            this.showNomorRekening = false;
            this.showNomorPonsel = false;
            this.showExtAvaya = false;
            this.showDurasi = false;
            this.showWaktuInteraksi = false;  
        } else if(this.selectedValue == 'VBS'){
            this.showInisialAgent = false;
            this.showChannel = false;
            this.showTanggalInteraksi = false;
            this.showResponJawab = false;
        } else if(this.selectedValue == 'URS_Urgent_Call_Recovery_Service'){
            this.showInisialAgent = false;
            this.showChannel = false;
            this.showTanggalInteraksi = false;
            this.showResponJawab = false;
        } else if(this.selectedValue == 'RPS_BRING_LOP'){
            this.showExtAvaya = false;
            this.showInisialAgent = false;
            this.showChannel = false;
            this.showTanggalInteraksi = false;
            this.showResponJawab = false;
        } else if(this.selectedValue == 'RPS_Non_BRING_LOP'){
            this.showInisialAgent = false;
            this.showChannel = false;
            this.showTanggalInteraksi = false;
            this.showResponJawab = false;
        } else if(this.selectedValue == 'AL_Agent_Leader'){
            this.showNamaNasabah = false;
            this.showNomorKartu = false;
            this.showNomorRekening = false;
            this.showNomorPonsel = false;
            this.showInisialAgent = false;
            this.showChannel = false;
            this.showTanggalInteraksi = false;
            this.showResponJawab = false;
            // For Agent Leader View
            this.agentLeaderView = true;
        }
    }

    resetFieldVisibility() {
        this.showNamaNasabah = true;
        this.showNomorKartu = true;
        this.showNomorRekening = true;
        this.showNomorPonsel = true;
        this.showExtAvaya = true;
        this.showDurasi = true;
        this.showWaktuInteraksi = true;
        this.showTanggalCallmon = true;
        this.showCalltype = true;
        this.showPerihal = true;
        this.showNamaQA = true;
        this.showInisialAgent = true;
        this.showChannel = true;
        this.showTanggalInteraksi = true;
        this.showResponJawab = true;
        this.agentLeaderView = false;
        this.totalCriticalError = 0;
        this.totalNonCriticalError = 0;
        this.totalUtama = 0;
        this.countCriticalZero = 0;
        this.countNonCriticalZero = 0;
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

        this.selectedAgentId = agentId || '';
        this.selectedAgentName = agentName || '';
        this.searchKeyword = '';
        this.searchResults = [];
        this.isDropdownOpen = false;
        this.showSelectedAgent = true;
    }

    closeDropdown() {
        this.isDropdownOpen = false; // Menutup dropdown secara manual dengan tombol X
    }

    @wire(getRecord, { recordId: '$userId', fields: [USER_NAME_FIELD] })
    wiredUser({ data, error }) {
        if (data) {
            this.userName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching user data:', error);
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(pageRef) {
        if (pageRef) {
            this.recordId = pageRef.state.c__recordId || this.recordId;
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

    async loadPicklistOptions() {
        if (!this.selectedValue) {
            console.error('RecordTypeName is not provided');
            return;
        }

        try {
            const data = await getPicklistOptions({ recordTypeName: this.selectedValue });
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
        if (!this.selectedValue) {
            console.error('RecordTypeName is not provided');
            return;
        }

        try {
            const data = await getCaseMasterData({ recordTypeName: this.selectedValue });
            console.log('Fetched master data:', data);
            this.groupedData = this.processData(data);
            console.log('Processed grouped data:', this.groupedData);
        } catch (error) {
            console.error('Error fetching master data:', error);
        }
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
            const recordType = row.RecordType.Name
    
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

    loadSubVoicePicklist() {
        getSubVoicePicklistValues()
            .then((data) => {
                console.log('Sub-Voice Data:', data);
                this.subVoiceOptions = data.map((value) => ({
                    label: value,
                    value: value,
                }));
            })
            .catch((error) => {
                console.error('Error fetching sub-voice picklist values:', error);
            });
    }

    handleSubVoiceChange(event) {
        this.selectedSubVoice = event.detail.value;
    }

    handleSubVoiceNext() {
        if (this.selectedSubVoice) {
            this.redirect = true;
            this.isSubVoiceVisible = false;
            this.setFieldVisibility();
            this.loadData();
        } else {
            this.showToast('Pilih Sub-Voice', 'Harap pilih salah satu sub-voice sebelum melanjutkan.', 'warning');
        }
    }

    handleCategoryNext() {
        if (this.selectedValue) {
            console.log('Selected Record Type: ' + this.selectedValue);
            if (this.selectedValue === 'Voice') {
                this.isVoiceSelected = true; // Tandai bahwa Voice dipilih
                this.isSubVoiceVisible = true;
                this.showCategoryPicklist = false;
                this.setFieldVisibility();
            } else if (this.selectedValue === 'AL_Agent_Leader') {
                this.redirect = true;
                this.showCategoryPicklist = false;
                this.loadData();
                this.setFieldVisibility();
            } else {
                this.redirect = true;
                this.showCategoryPicklist = false;
                this.loadData();
                this.setFieldVisibility();
            }
        } else {
            this.showToast('Pilih kategori terlebih dahulu', 'Harap pilih salah satu kategori sebelum melanjutkan.', 'warning');
        }
    }

    async loadRecordTypes() {
        try {
            const data = await getRecordTypes();
            this.recordTypeOptions = data.map(recordType => ({
                label: recordType.Name,
                value: recordType.DeveloperName
            }));
        } catch (error) {
            console.error('Error fetching record types:', error);
        }
    }

    handleChange(event) {
        this.selectedValue = event.detail.value;
        console.log('Selected Record Type: ' + this.selectedValue);
    }

    handleSubVoicePrevious() {
        this.isSubVoiceVisible = false;
        this.showCategoryPicklist = true;
    }

    handleRedirectPrevious() {
        this.redirect = false;
        this.resetFieldVisibility(); 
        this.isSubVoiceVisible = this.selectedValue === 'Voice';
        this.showCategoryPicklist = !this.isSubVoiceVisible;
        this.setFieldVisibility();
    }    

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    async closeTab() {
        if (!this.isConsoleNavigation) {
            return;
        }
        const { tabId } = await getFocusedTabInfo();
        console.log('tab id'+ tabId);
        await closeTab(tabId);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
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

            section.sectionScore = this.calculateSectionScore(section.rows, section.bobot); 

            return section;
        });


        // Recalculate totals for Critical and Non-Critical errors after updating Skor
        this.calculateErrorTotals();

        // Force the component to re-render by setting the groupedData array again
        this.groupedData = [...this.groupedData];
    }

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
        if(this.selectedValue == 'Non_Voice'){
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
    
    // Fungsi untuk menampilkan Toast
    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
    

    async handleSaveData() {
        this.isSaving = true;

        if (!this.validateMandatoryFields()) {
            this.isSaving = true;
            this.closeModal();
            return;
        }

        if (!this.validateInputs()) {
            this.isSaving = true;
            this.closeModal();
            return; 
        }
        try {
            const formData = this.collectAllInputs();
            console.log("form data to Apex: " + JSON.stringify(formData));

            const recordId = await saveFormData({ formData: formData });
            console.log('Returned Record ID:', recordId);
            if (!recordId) {
                throw new Error('Record ID is empty or null');
            }            

            const tableRecords = this.prepareTableData(recordId);
            console.log('Table Data to Save:', JSON.stringify(tableRecords));

            await saveTableData({ records: tableRecords });
            this.showToast('Success', 'Data berhasil disimpan!', 'success');
            this.closeModal();
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: 'QA_Response__c', 
                    actionName: 'view'
                }
            });
            this.closeTab();

        } catch (error) {
            console.error('Error saving data:', error);
            this.showToast('Error', 'Gagal menyimpan data.', 'error');
            this.closeModal();
        }
    }

    collectAllInputs() {
        const inputs = this.template.querySelectorAll('lightning-input');
        let collectedData = {};
    
        inputs.forEach(input => {
            // Melewati input yang memiliki atribut data-exclude
            if (input.name) { 
                collectedData[input.name] = input.value || ''; 
            }
        });
    
        // Menambahkan Record ID dan nilai lainnya
        collectedData['totalCriticalError'] = this.totalCriticalError || 0;
        collectedData['totalNonCriticalError'] = this.totalNonCriticalError || 0;
        collectedData['totalPenilaian'] = this.totalUtama || 0;
        collectedData['countCriticalZero'] = this.countCriticalZero || 0;
        collectedData['countNonCriticalZero'] = this.countNonCriticalZero || 0;
        collectedData['kategoriPenilaian'] = this.selectedValue || '';
        collectedData['subKategoriPenilaian'] = this.selectedSubVoice || '';
        collectedData['isDirect_Penilaian_QA__c'] = 'true';
    
        console.log('Collected Input Data with Totals and Averages:', JSON.stringify(collectedData));
        return collectedData;
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

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}