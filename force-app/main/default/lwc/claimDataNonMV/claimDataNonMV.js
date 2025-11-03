import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Impor dari ClaimControllerNonMV
import getClaimDetails from '@salesforce/apex/ClaimControllerNonMV.getClaimDetails';
import searchRisksNonMV from '@salesforce/apex/ClaimControllerNonMV.searchRisksNonMV';
import getCoveragesForAsset from '@salesforce/apex/ClaimControllerNonMV.getCoveragesForAsset';
import getAssetsForOpportunity from '@salesforce/apex/ClaimControllerNonMV.getAssetsForOpportunity';

// Kolom untuk Non-MV
const MODEL_COLUMNS_NON_MV = [
    { label: 'NO', fieldName: 'no', initialWidth: 70 },
    { label: 'RISK NAME', fieldName: 'riskName', wrapText: true }, // Added wrapText for potentially long names
    { label: 'RISK DETAIL', fieldName: 'riskDetail', wrapText: true } // Added wrapText
];
const COVERAGE_COLUMNS_NON_MV = [
    { label: 'COVERAGE', fieldName: 'coverage' },
    { label: '%', fieldName: 'percentage', type: 'number', initialWidth: 80, typeAttributes: { minimumFractionDigits: 1, maximumFractionDigits: 1 } }, // Adjusted width/digits
    { label: 'OF', fieldName: 'of', initialWidth: 150 },
    { label: 'DEDUCTIBLE CUR', fieldName: 'deductibleCur', initialWidth: 150 }, // Adjusted width
    { label: 'MINIMUM', fieldName: 'deductibleMin', type: 'currency', typeAttributes: { currencyCode: 'IDR' }, initialWidth: 150 } // Adjusted width
];

export default class ClaimDataNonMV extends LightningElement {
    @api recordId;
    @track isLoading = true;

    // Properti Data (Non-MV)
    @track policyNo;
    @track policyDate;
    @track classOfBusiness;
    @track sumInsured = 0.00;
    @track policyCurrency = 'IDR';
    @track busreqId;
    @track opportunityId;
    @track valueAtRisk = null; // Placeholder
    @track totalDeductible = 0.00; // Calculated sum
    @track lossEstimation = null; // Placeholder

    // Properti Input (Non-MV)
    @track riskNameInput = '';
    @track riskDetailInput = '';

    // Opsi Currency (Non-MV)
    currencyOptions = [ { label: 'IDR', value: 'IDR' }, { label: 'USD', value: 'USD' } ];

    // Properti Datatable (Non-MV)
    modelColumns = MODEL_COLUMNS_NON_MV;
    @track modelData = [];
    coverageColumns = COVERAGE_COLUMNS_NON_MV;
    @track coverageData = [];

    // Properti Paginasi (Non-MV)
    @track modelPageNumber = 1;
    @track modelTotalCount = 0;
    @track modelTotalPages = 1;
    pageSize = 10;
    isSearchMode = false; // To differentiate between auto-load and manual search

    // Wire getClaimDetails (Non-MV)
    @wire(getClaimDetails, { recordId: '$recordId' })
    wiredClaim(result) {
        if (result.data) {
            const data = result.data;
            this.policyNo = data.policyNo;
            this.policyDate = data.policyDate;
            this.classOfBusiness = data.classOfBusiness;
            this.sumInsured = data.sumInsured || 0.00;
            this.policyCurrency = data.cur || 'IDR';
            this.busreqId = data.busreqId;
            this.opportunityId = data.opportunityId;
            // Uncomment when fields are ready in Apex
            // this.valueAtRisk = data.valueAtRisk;
            // this.lossEstimation = data.lossEstimation;

            // Trigger auto-load if opportunity exists
            if (this.opportunityId) {
                this.isSearchMode = false; // Set to auto-load mode
                this.modelPageNumber = 1; // Reset page
                this.loadModelData(); // Call central data loader
            } else {
                this.isLoading = false; // No opportunity, finish loading
            }
        } else if (result.error) {
            console.error('Error loading claim data:', JSON.stringify(result.error));
            this.showToast('Error', 'Failed to load Claim data.', 'error');
            this.isLoading = false;
        }
    }

    // Helper processAssetResults (Non-MV)
    processAssetResults(assetList) {
        if (!assetList || assetList.length === 0) {
            this.modelData = [];
            return;
        }
        let i = 1;
        this.modelData = assetList.map(asset => {
            const noUrut = ((this.modelPageNumber - 1) * this.pageSize) + (i++) + '.';
            // Map fields specific to Non-MV table columns
            return {
                id: asset.Id,
                no: noUrut,
                riskName: asset.Name,
                riskDetail: asset.Address_Description__c // Mapped from your previous info
            };
        });
    }

    // handleInputChange (Non-MV)
    handleInputChange(event) {
        const fieldLabel = event.target.label;
        const value = event.target.value;
        switch(fieldLabel) {
            case 'RISK NAME': this.riskNameInput = value; break;
            case 'RISK DETAIL': this.riskDetailInput = value; break;
            default: break;
        }
    }

    // handleSearchClick (Non-MV)
    handleSearchClick() {
        this.isSearchMode = true; // Set to search mode
        this.modelPageNumber = 1; // Reset page
        this.loadModelData(); // Call central data loader
    }

    // Central data loader (Non-MV)
    loadModelData() {
        this.isLoading = true;
        this.coverageData = []; // Clear coverage when model data changes
        this.totalDeductible = 0.00; // Clear deductible sum

        let promise;

        if (this.isSearchMode) {
            // Manual Search
            promise = searchRisksNonMV({
                riskName: this.riskNameInput,
                riskDetail: this.riskDetailInput,
                pageSize: this.pageSize,
                pageNumber: this.modelPageNumber
            });
        } else {
            // Auto-Load via Opportunity
            if (!this.opportunityId) {
                this.isLoading = false;
                this.modelData = []; // Ensure model is empty
                return; // Stop if no Opportunity ID
            }
            promise = getAssetsForOpportunity({
                opportunityId: this.opportunityId,
                pageSize: this.pageSize,
                pageNumber: this.modelPageNumber
            });
        }

        // Execute the promise
        promise.then(result => {
            this.handlePaginationResult(result);
        }).catch(error => {
            this.handlePaginationError(error, this.isSearchMode ? 'search' : 'auto-load');
        });
    }

    // handlePaginationResult (Non-MV)
    handlePaginationResult(result) {
        this.modelTotalCount = result.totalItemCount;
        this.modelTotalPages = Math.ceil(this.modelTotalCount / this.pageSize);
        if(this.modelTotalPages === 0) this.modelTotalPages = 1; // Prevent 0 of 0 pages

        this.processAssetResults(result.assetList); // Process the list

        if (!result.assetList || result.assetList.length === 0) {
            if (this.isSearchMode) { // Show toast only on manual search
                this.showToast('Info', 'No Risk/Asset data found.', 'info');
            }
            this.isLoading = false; // Stop loading if no results
        } else {
            // Auto-select first row and load its coverages
            // Simulate the event structure for handleRowSelection
            this.handleRowSelection({ detail: { selectedRows: [this.modelData[0]] } });
            // isLoading will be set to false in loadCoverages
        }
    }

    // handlePaginationError (Non-MV)
    handlePaginationError(error, context) {
        console.error(`Error ${context} assets:`, error);
        this.showToast('Error', `Failed to load Asset (Risk) data (${context}).`, 'error');
        this.isLoading = false;
    }

    // handleRowSelection (Non-MV)
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows && selectedRows.length > 0) {
            const selectedAssetId = selectedRows[0].id;
            this.loadCoverages(selectedAssetId);
        } else {
            // Clear coverage and deductible if no row is selected
            this.coverageData = [];
            this.totalDeductible = 0.00;
        }
    }

    // loadCoverages (Non-MV)
    loadCoverages(assetId) {
        this.isLoading = true;
        getCoveragesForAsset({ assetId: assetId })
            .then(wrapper => { // Expecting CoverageWrapper
                this.totalDeductible = wrapper.totalDeductible; // Set the summed deductible
                // Map coverage list for the Non-MV table
                this.coverageData = wrapper.coverages.map(cov => ({
                    id: cov.Id,
                    coverage: cov.CoverageName,
                    percentage: cov.Deductible_PCT__c,
                    of: cov.Deductible_Type__c,
                    deductibleCur: cov.Deductible_Currency__r ? cov.Deductible_Currency__r.Name : '',
                    deductibleMin: cov.Minimum_Amount__c
                    // Note: 'cur' and 'sumInsured' from policy level are not in Non-MV coverage table
                }));
            })
            .catch(error => {
                console.error('Error loading coverages:', error);
                this.showToast('Error', 'Failed to load coverage data.', 'error');
                this.coverageData = []; // Clear data on error
                this.totalDeductible = 0.00;
            })
            .finally(() => {
                this.isLoading = false; // Stop loading spinner
            });
    }

    // Paginasi Getters & Handlers (Non-MV)
    get isModelFirstPage() { return this.modelPageNumber === 1; }
    get isModelLastPage() { return this.modelPageNumber >= this.modelTotalPages; }
    handlePreviousPage() { if (!this.isModelFirstPage) { this.modelPageNumber -= 1; this.loadModelData(); } }
    handleNextPage() { if (!this.isModelLastPage) { this.modelPageNumber += 1; this.loadModelData(); } }

    // Getters 'hasModelData' & 'hasCoverageData' (Non-MV)
    get hasModelData() { return this.modelData && this.modelData.length > 0; }
    get hasCoverageData() { return this.coverageData && this.coverageData.length > 0; }

    // showToast (Non-MV)
    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title: title, message: message, variant: variant });
        this.dispatchEvent(event);
    }
}