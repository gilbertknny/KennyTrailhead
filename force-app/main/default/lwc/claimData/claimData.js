import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Impor dari ClaimController
import getClaimDetails from '@salesforce/apex/ClaimController.getClaimDetails';
import searchRisks from '@salesforce/apex/ClaimController.searchRisks';
import getCoveragesForAsset from '@salesforce/apex/ClaimController.getCoveragesForAsset';
import getAssetsForOpportunity from '@salesforce/apex/ClaimController.getAssetsForOpportunity';

// Definisi Kolom (Tidak berubah)
const MODEL_COLUMNS = [
    { label: 'NO', fieldName: 'no', initialWidth: 70 },
    { label: 'MODEL', fieldName: 'modelName' }
];
const COVERAGE_COLUMNS = [
    { label: 'COVERAGE', fieldName: 'coverage', initialWidth: 100 },
    { label: 'CUR', fieldName: 'cur', initialWidth: 80 },
    { label: 'SUM INSURED', fieldName: 'sumInsured', type: 'currency', typeAttributes: { currencyCode: 'IDR' } },
    { label: '%', fieldName: 'percentage', type: 'number', initialWidth: 70, typeAttributes: { minimumFractionDigits: 2, maximumFractionDigits: 2 } },
    { label: 'OF', fieldName: 'of' },
    { label: 'Deductible CUR', fieldName: 'deductibleCur', initialWidth: 120 },
    { label: 'Deductible Minimum', fieldName: 'deductibleMin', type: 'currency', initialWidth: 150 }
];


export default class ObjectData extends LightningElement {
    @api recordId;
    @track isLoading = true; 

    // Properti Data
    @track policyNo;
    @track policyDate;
    @track classOfBusiness;
    @track sumInsured = 0.00;
    @track policyCurrency = 'IDR';
    @track busreqId; 
    @track opportunityId; 

    // Properti Input
    @track modelMerkInput = '';
    @track registerNoInput = ''; 
    @track chasisNoInput = '';
    @track engineNoInput = '';

    // Properti Loss Estimation
    @track lossEstimationCol1 = [];
    @track lossEstimationCol2 = [];

    // Opsi Currency
    currencyOptions = [
        { label: 'IDR', value: 'IDR' },
        { label: 'USD', value: 'USD' },
    ];
    
    // Properti Datatable
    modelColumns = MODEL_COLUMNS;
    @track modelData = []; 
    coverageColumns = COVERAGE_COLUMNS;
    @track coverageData = []; 

    // --- PROPERTI BARU UNTUK PAGINASI ---
    @track modelPageNumber = 1;
    @track modelTotalCount = 0;
    @track modelTotalPages = 1;
    pageSize = 10; // Sesuai permintaan Anda
    isSearchMode = false; // Melacak mode (auto-load vs search)

    // --- WIRE HANYA UNTUK getClaimDetails ---
    @wire(getClaimDetails, { recordId: '$recordId' })
    wiredClaim(result) {
        if (result.data) {
            const data = result.data;
            this.policyNo = data.policyNo;
            this.policyDate = data.policyDate;
            this.classOfBusiness = data.classOfBusiness;
            this.registerNoInput = data.registerNo; 
            this.sumInsured = data.sumInsured || 0.00;
            this.policyCurrency = data.cur || 'IDR';
            this.busreqId = data.busreqId;
            this.opportunityId = data.opportunityId; 

            this.populateLossEstimation(data);
            
            // --- LOGIKA AUTO-LOAD BARU ---
            // Memanggil method pemuat data imperatif
            this.isSearchMode = false; // Mode auto-load
            this.modelPageNumber = 1;  // Reset ke halaman 1
            this.loadModelData();      // Panggil method pemuat data

        } else if (result.error) {
            console.error('Error loading claim data:', JSON.stringify(result.error));
            this.showToast('Error', 'Gagal memuat data Claim.', 'error');
            this.isLoading = false; 
        }
    }

    // --- MENGHAPUS WIRE 'wiredAssets' ---

    // Method helper 'populateLossEstimation' (Tidak berubah)
    populateLossEstimation(data) {
        const col1 = [];
        if (data.isCasco) col1.push({ id: 'le1', label: 'CASCO', cur: 'IDR', val: '0.00' });
        if (data.isLifeInsurance) col1.push({ id: 'le2', label: 'LIFE INSURANCE', cur: 'IDR', val: '0.00' });
        if (data.isPaPassenger) col1.push({ id: 'le3', label: 'PA PASSENGER', cur: 'IDR', val: '0.00' });
        col1.push({ id: 'le7', label: 'MARKET PRICE', cur: 'IDR', val: this.sumInsured.toString() });
        col1.push({ id: 'le9', label: 'TOTAL LOSS ESTIMATION', cur: 'IDR', val: '0.00' });
        this.lossEstimationCol1 = col1;
        //... (sisa logika tidak berubah)
        const col2 = [];
        if (data.isTpl) col2.push({ id: 'le4', label: 'TPL', cur: 'IDR', val: '0.00' });
        if (data.isPaDriver) col2.push({ id: 'le5', label: 'PA DRIVER', cur: 'IDR', val: '0.00' });
        if (data.isPll) col2.push({ id: 'le6', label: 'PLL', cur: 'IDR', val: '0.00' });
        col2.push({ id: 'le8', label: 'DEDUCTIBLE', cur: 'IDR', val: '0.00' });
        col2.push({ id: 'le10', label: 'DISCOUNT DEDUCTIBLE', cur: 'IDR', val: '0' });
        this.lossEstimationCol2 = col2;
    }

    // Method helper 'processAssetResults' (Tidak berubah)
    processAssetResults(assetList) {
        if (!assetList || assetList.length === 0) {
            this.modelData = [];
            return;
        }
        let i = 1;
        this.modelData = assetList.map(asset => { 
            const modelName = asset.Model__r ? asset.Model__r.Name : '';
            const chasisNo = asset.Chasis_No__c ? asset.Chasis_No__c : '';
            const engineNo = asset.Engine_No__c ? asset.Engine_No__c : '';
            const regNo = asset.Register_No__c ? asset.Register_No__c : ''; 
            
            return {
                id: asset.Id,
                no: ((this.modelPageNumber - 1) * this.pageSize) + (i++) + '.', // No. urut halaman
                modelName: `${modelName}, ${chasisNo}, ${engineNo}, ${regNo}`
            };
        });
    }

    // handleInputChange (Tidak berubah)
    handleInputChange(event) {
        const fieldLabel = event.target.label;
        const value = event.target.value;
        switch(fieldLabel) {
            case 'MODEL/MERK': this.modelMerkInput = value; break;
            case 'REGISTER NO': this.registerNoInput = value; break;
            case 'CHASIS NO': this.chasisNoInput = value; break;
            case 'ENGINE NO': this.engineNoInput = value; break;
            default: break;
        }
    }

    // --- DIPERBARUI: handleSearchClick ---
    // Sekarang hanya mengatur mode dan memanggil pemuat data
    handleSearchClick() {
        this.isSearchMode = true;  // Set mode ke 'search'
        this.modelPageNumber = 1;  // Reset ke halaman 1
        this.loadModelData();      // Panggil pemuat data
    }

    // --- METHOD HELPER BARU: Pemuat Data Pusat ---
    loadModelData() {
        this.isLoading = true;
        this.coverageData = []; // Selalu kosongkan coverage saat data model baru dimuat

        if (this.isSearchMode) {
            // --- Mode Search (Manual) ---
            searchRisks({ 
                model: this.modelMerkInput, 
                chasisNo: this.chasisNoInput, 
                engineNo: this.engineNoInput,
                pageSize: this.pageSize,
                pageNumber: this.modelPageNumber
            })
            .then(result => {
                this.handlePaginationResult(result);
            })
            .catch(error => {
                this.handlePaginationError(error, 'search');
            });
        } else {
            // --- Mode Auto-Load ---
            if (!this.opportunityId) {
                // Tidak ada Opty ID, jangan lakukan apa-apa
                this.isLoading = false;
                return;
            }
            getAssetsForOpportunity({ 
                opportunityId: this.opportunityId,
                pageSize: this.pageSize,
                pageNumber: this.modelPageNumber
            })
            .then(result => {
                this.handlePaginationResult(result);
            })
            .catch(error => {
                this.handlePaginationError(error, 'auto-load');
            });
        }
    }

    // --- METHOD HELPER BARU: Menangani Hasil Paginasi ---
    handlePaginationResult(result) {
        this.modelTotalCount = result.totalItemCount;
        this.modelTotalPages = Math.ceil(this.modelTotalCount / this.pageSize);
        if(this.modelTotalPages === 0) this.modelTotalPages = 1; // Cegah 0 dari 0

        this.processAssetResults(result.assetList); // Memproses list data

        if (!result.assetList || result.assetList.length === 0) {
            if (this.isSearchMode) { // Hanya tampilkan toast saat search
                this.showToast('Info', 'Data Asset (Risk) tidak ditemukan.', 'info');
            }
        } else {
            // Otomatis pilih baris pertama dan muat coverage-nya
            // Kita buat 'selected' secara artifisial
            this.handleRowSelection({ detail: { selectedRows: [this.modelData[0]] } });
        }
        this.isLoading = false;
    }

    // --- METHOD HELPER BARU: Menangani Error Paginasi ---
    handlePaginationError(error, context) {
        console.error(`Error ${context} assets:`, error);
        this.showToast('Error', `Gagal memuat data Asset (Risk) (${context}).`, 'error');
        this.isLoading = false;
    }


    // handleRowSelection (sedikit diubah untuk auto-select)
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows && selectedRows.length > 0) {
            const selectedAssetId = selectedRows[0].id;
            console.log('Selected Asset ID:', selectedAssetId);
            this.loadCoverages(selectedAssetId); 
        } else {
            this.coverageData = []; 
        }
    }

    // loadCoverages (Tidak berubah)
    loadCoverages(assetId) {
        this.isLoading = true;
        getCoveragesForAsset({ assetId: assetId })
            .then(result => {
                this.coverageData = result.map(cov => {
                    return {
                        id: cov.Id,
                        coverage: cov.CoverageName,
                        cur: this.policyCurrency, 
                        sumInsured: this.sumInsured, 
                        percentage: cov.Deductible_PCT__c,
                        of: cov.Deductible_Type__c,
                        deductibleCur: cov.Deductible_Currency__r ? cov.Deductible_Currency__r.Name : '',
                        deductibleMin: cov.Minimum_Amount__c
                    };
                });
            })
            .catch(error => {
                console.error('Error loading coverages:', error);
                this.showToast('Error', 'Gagal memuat data coverage.', 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    // handleLossChange (Tidak berubah)
    handleLossChange(event) {
        const fieldId = event.target.dataset.id;
        const fieldType = event.target.dataset.type; 
        const newValue = event.target.value;
        let field = this.lossEstimationCol1.find(f => f.id === fieldId);
        if (!field) {
            field = this.lossEstimationCol2.find(f => f.id === fieldId);
        }
        if (field) {
            field[fieldType] = newValue;
            this.lossEstimationCol1 = [...this.lossEstimationCol1];
            this.lossEstimationCol2 = [...this.lossEstimationCol2];
        }
    }

    // --- GETTER & HANDLER BARU UNTUK PAGINASI ---
    get isModelFirstPage() {
        return this.modelPageNumber === 1;
    }
    get isModelLastPage() {
        return this.modelPageNumber >= this.modelTotalPages;
    }

    handlePreviousPage() {
        if (!this.isModelFirstPage) {
            this.modelPageNumber -= 1;
            this.loadModelData(); // Muat ulang data untuk halaman baru
        }
    }
    handleNextPage() {
        if (!this.isModelLastPage) {
            this.modelPageNumber += 1;
            this.loadModelData(); // Muat ulang data untuk halaman baru
        }
    }

    // Getters 'hasModelData' & 'hasCoverageData' (Tidak berubah)
    get hasModelData() {
        return this.modelData && this.modelData.length > 0;
    }
    get hasCoverageData() {
        return this.coverageData && this.coverageData.length > 0;
    }

    // showToast (Tidak berubah)
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}