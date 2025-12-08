import { LightningElement, wire, track, api } from 'lwc';
import searchAssets from '@salesforce/apex/AccumulationController.searchAssets';
import getInitialAssetData from '@salesforce/apex/AccumulationController.getInitialAssetData'; 
import getQuoteData from '@salesforce/apex/AccumulationController.getQuoteData';
import getAccumulationData from '@salesforce/apex/AccumulationController.getAccumulationData';
import createAccumulationRecord from '@salesforce/apex/AccumulationController.createAccumulationRecord';
import updateAccumulationRecord from '@salesforce/apex/AccumulationController.updateAccumulationRecord';
import getExchangeRate from '@salesforce/apex/AccumulationController.getExchangeRate';
import getAssetsByGroupId from '@salesforce/apex/AccumulationController.getAssetsByGroupId';
import checkMultipleAssetOwnership from '@salesforce/apex/AccumulationController.checkMultipleAssetOwnership';
import getRisksByOpportunityBusReq from '@salesforce/apex/AccumulationController.getRisksByOpportunityBusReq';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBsnIdFromOpportunity from '@salesforce/apex/AccumulationController.getBsnIdFromOpportunity';
import { getRecord } from 'lightning/uiRecordApi';

const DEFAULT_CURRENCY = 'IDR';
const RELOAD_DELAY = 1500;

export default class Accumulation extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    @track bsnId = null;
    @track isQuoteContext = false;
    @track isAccumulationContext = false;
    @track isEditMode = false;
    @track currentRiskId = null;
    @track opportunityId = null;
    @track inceptionDate = null;
    @track existingAccumulationId = null;
    @track city = '';
    @track version = null;
    @track groupId = null;
    
    // LIST DATA
    @track accumulationList = [];
    @track requestList = [];
    
    @track searchCriteria = {};
    @track isLoading = false;
    @track riskOwnershipMap = {};
    @track showAccumulationList = false;
    @track showRequestList = false;
    
    hasAutoLoaded = false; 

    // =================================================================
    // GETTERS
    // =================================================================

    get showBasicFields() { return ['201', '203', '701', '702', '703', '704', '707', '808'].includes(this.bsnId); }
    get showCatastropheFields() { return this.bsnId === '202'; }
    get showMarineFields() { return this.bsnId === '101'; }
    get showInsuredNameOnly() { return this.bsnId === '852'; }
    get showInsurancePeriod() { return ['101', '701', '702', '703', '704', '707', '808', '852'].includes(this.bsnId); }
    
    get totalTSI() { 
        return this.accumulationList.reduce((total, item) => total + (item.sumInsuredIDR || 0), 0); 
    }

    get buttonLabel() { 
        return this.isEditMode ? 'UPDATE ACCUMULATION' : 'SET ACCUMULATION'; 
    }

    get currentJoinCount() {
        const uniqueGroups = new Set(
            this.accumulationList
                .filter(item => item.groupId && item.groupId.trim() !== '')
                .map(item => item.groupId)
        );
        const nonGroupItemsCount = this.accumulationList.filter(item => !item.groupId || item.groupId.trim() === '').length;
        return uniqueGroups.size + nonGroupItemsCount;
    }

    get hasGroupInList() {
        return this.accumulationList.some(item => item.groupId && item.groupId.trim() !== '');
    }

    get maxJoinAllowed() {
        if (this.hasGroupInList) {
            return 2;
        }
        return 50; 
    }

    get isLimitReached() {
        return this.currentJoinCount >= this.maxJoinAllowed;
    }

    get isSearchDisabled() {
        return this.isLoading || this.isLimitReached;
    }

    // [UPDATED] Button Logic: Always enabled in Edit Mode, Disabled if < 2 in Create Mode
    get isSaveDisabled() {
        if (this.isLoading) return true;
        if (this.isEditMode) return false; 
        return this.accumulationList.length < 2;
    }

    isZipCodeMatch(incomingZip) {
        if (this.accumulationList.length === 0) return true;
        
        const currentZip = this.accumulationList[0].zipCode;
        const s1 = currentZip ? String(currentZip).trim().toLowerCase() : '';
        const s2 = incomingZip ? String(incomingZip).trim().toLowerCase() : '';
        
        return s1 === s2;
    }

    // =================================================================
    // WIRES & LIFECYCLE
    // =================================================================

    connectedCallback() {
        this.initializeSearchCriteria();
        this.accumulationList = [];
        
        if (this.objectApiName === 'Opportunity' && this.recordId) {
            this.opportunityId = this.recordId;
            this.loadBsnIdFromOpportunity(this.opportunityId);
            this.loadAutoSuggestedRisks(this.opportunityId);
        }
    }

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Compact'] })
    wiredRecord({ error, data }) {
        if (data) {
            this.detectRecordContext(data);
        } else if (error && this.objectApiName) {
            this.detectRecordContext({ apiName: this.objectApiName });
        }
    }

    detectRecordContext(recordData) {
        const objectApiName = recordData.apiName;
        
        if (objectApiName === 'Quote') {
            this.isQuoteContext = true;
            this.isAccumulationContext = false;
        } 
        else if (objectApiName === 'Accumulation__c') {
            this.isAccumulationContext = true;
            this.isQuoteContext = false;
            this.isEditMode = true;
            this.loadAccumulationData();
        } 
        else if (objectApiName === 'Opportunity') {
            this.opportunityId = this.recordId;
            this.loadBsnIdFromOpportunity(this.opportunityId);
            this.loadAutoSuggestedRisks(this.opportunityId);
        }
    }

    @wire(getQuoteData, { quoteId: '$recordId' })
    wiredQuoteData({ error, data }) {
        if (data) {
            this.isQuoteContext = true; 
            this.currentRiskId = data.riskId;
            this.opportunityId = data.opportunityId;
            this.city = data.city;
            this.inceptionDate = data.inceptionDate;
            this.searchCriteria = { ...this.searchCriteria, zipCode: data.zipCode };
            
            if (this.opportunityId) {
                this.loadBsnIdFromOpportunity(this.opportunityId);
                if (!this.isEditMode) {
                    this.loadAutoSuggestedRisks(this.opportunityId);
                }
            }
        }
    }

    @wire(getInitialAssetData, { assetId: '$recordId' })
    wiredInitialData({ error, data }) {
        if (data) {
            if (!data.assetRow || !data.assetRow.id) return;
            this.isLoading = true;
            const initialRow = { ...data.assetRow, effectiveDate: new Date().toLocaleDateString('en-GB') };
            if (initialRow.opportunityId) this.loadBsnIdFromOpportunity(initialRow.opportunityId);
            this.loadExchangeRateAndAddToList(initialRow);
        }
    }

    loadBsnIdFromOpportunity(opportunityId) {
        getBsnIdFromOpportunity({ opportunityId }).then(result => { this.bsnId = result; }).catch(() => { this.bsnId = null; });
    }

    loadAutoSuggestedRisks(oppId) {
        if (!oppId || this.hasAutoLoaded) return;
        
        this.isLoading = true;
        this.hasAutoLoaded = true;

        getRisksByOpportunityBusReq({ opportunityId: oppId })
            .then(result => {
                const risks = result.data || [];
                const message = result.message || '';

                const excludedIds = this.accumulationList.map(item => item.id);
                this.requestList = risks.filter(item => !excludedIds.includes(item.id));
                
                if (this.requestList.length > 0) {
                    this.showRequestList = true;
                    this.showToast('Info', message, 'info');
                } else if (message) {
                     this.showToast('Info', message, 'info');
                }
            })
            .catch(error => {
                console.error('Error auto-loading risks', error);
                this.showToast('Error', 'Auto-load failed: ' + (error?.body?.message || error.message), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    initializeSearchCriteria() {
        this.searchCriteria = {
            address: '', zipCode: '', policyNumber: '', nkr: '', riskName: '',
            earthquakeZone: '', volcanicZone: '', tsunamiZone: '',
            vesselName: '', voyageNumber: '', startDatePeriode: null, endDatePeriode: null
        };
    }

    loadAccumulationData() {
        this.isLoading = true;
        getAccumulationData({ accumulationId: this.recordId })
            .then(data => {
                this.existingAccumulationId = data.accumulationId;
                this.version = data.version;
                this.groupId = data.groupId;
                this.inceptionDate = data.inceptionDate;
                this.searchCriteria = { ...this.searchCriteria, zipCode: data.zipCode };
                if (data.assets && data.assets.length > 0 && data.assets[0].opportunityId) {
                    this.loadBsnIdFromOpportunity(data.assets[0].opportunityId);
                }
                return this.loadAccumulationAssets(data.assets);
            })
            .catch(error => {
                this.showToast('Error', 'Error loading accumulation data: ' + error.body?.message, 'error');
                this.showAccumulationList = false;
            })
            .finally(() => this.isLoading = false);
    }

    async loadAccumulationAssets(assets) {
        if (!assets || assets.length === 0) {
            this.accumulationList = [];
            this.showAccumulationList = false;
            return;
        }
        const currentYear = String(new Date().getFullYear());
        try {
            const promises = assets.map(asset => this.convertAssetToAccumulationItem(asset, currentYear));
            this.accumulationList = await Promise.all(promises);
            this.accumulationList = this.accumulationList.filter(item => item && item.id);
            await this.checkAssetOwnerships();
            this.showAccumulationList = this.accumulationList.length > 0;
        } catch (error) {
            this.accumulationList = [];
            this.showAccumulationList = false;
            this.showToast('Error', 'Error loading assets: ' + error.message, 'error');
        }
    }

    async checkAssetOwnerships() {
        const assetIds = this.accumulationList.map(item => item.id).filter(id => id);
        if (assetIds.length === 0) return;
        try {
            this.riskOwnershipMap = await checkMultipleAssetOwnership({ assetIds });
            this.accumulationList = this.accumulationList.map(item => ({
                ...item,
                canDelete: this.canDeleteItem(item)
            }));
        } catch (error) {
            this.accumulationList = this.accumulationList.map(item => ({ ...item, canDelete: false }));
        }
    }

    canDeleteItem(item) {
        if (!this.isEditMode) return true;
        return this.riskOwnershipMap[item.id] === true;
    }

    handleSearchCriteriaChange(event) {
        const { name, value } = event.target;
        this.searchCriteria = { ...this.searchCriteria, [name]: value };
    }

    handleReset() {
        this.initializeSearchCriteria();
        this.requestList = [];
        this.showRequestList = false;
    }

    validateSearchCriteria() {
        const { address, policyNumber, zipCode, nkr, riskName, earthquakeZone, 
                volcanicZone, tsunamiZone, vesselName, voyageNumber, 
                startDatePeriode, endDatePeriode } = this.searchCriteria;
        return !!(address || policyNumber || zipCode || nkr || riskName || 
                  earthquakeZone || volcanicZone || tsunamiZone || 
                  vesselName || voyageNumber || startDatePeriode || endDatePeriode);
    }

    handleSearch() {
        if (!this.validateSearchCriteria()) {
            this.showToast('Warning', 'Please enter at least one search criteria.', 'warning');
            return;
        }
        this.isLoading = true;
        this.requestList = [];

        searchAssets({
            addressQuery: this.searchCriteria.address,
            policyQuery: this.searchCriteria.policyNumber,
            zipCodeQuery: this.searchCriteria.zipCode,
            nkrQuery: this.searchCriteria.nkr,
            riskNameQuery: this.searchCriteria.riskName,
            earthquakeZoneQuery: this.searchCriteria.earthquakeZone || '',
            volcanicZoneQuery: this.searchCriteria.volcanicZone || '',
            tsunamiZoneQuery: this.searchCriteria.tsunamiZone || '',
            vesselNameQuery: this.searchCriteria.vesselName || '',
            voyageNumberQuery: this.searchCriteria.voyageNumber || '',
            startDatePeriodeQuery: this.searchCriteria.startDatePeriode || null,
            endDatePeriodeQuery: this.searchCriteria.endDatePeriode || null,
            contextOpportunityId: this.opportunityId 
        })
        .then(result => {
            const excludedIds = this.accumulationList.map(item => item.id);
            this.requestList = result.filter(item => !excludedIds.includes(item.id));
            
            this.showRequestList = true;
            const message = this.requestList.length === 0 ? 'No records found.' : `${this.requestList.length} record(s) found.`;
            this.showToast(this.requestList.length === 0 ? 'Info' : 'Success', message, this.requestList.length === 0 ? 'info' : 'success');
        })
        .catch(error => {
            this.showToast('Error', 'Error searching records: ' + error?.body?.message, 'error');
        })
        .finally(() => this.isLoading = false);
    }

    handleJoin(event) {
        if (this.isLimitReached) { 
            this.showToast('Warning', `Limit reached (${this.maxJoinAllowed} joins). Cannot add more.`, 'warning'); 
            return; 
        }
        
        const requestId = event.currentTarget.dataset.id;
        const selectedRequest = this.requestList.find(item => item.id === requestId);
        
        if (!selectedRequest) return;

        if (selectedRequest.groupId) {
            this.handleJoinGroup(selectedRequest.groupId);
        } else {
            if (!this.isZipCodeMatch(selectedRequest.zipCode)) {
                if (!confirm('Zip codes do not match. Do you want to proceed with the join?')) { // Translated
                    return; 
                }
            }
            this.joinSingleAsset(selectedRequest);
        }
    }

    handleJoinGroup(groupId) {
        this.isLoading = true;

        getAssetsByGroupId({ groupId })
            .then(groupAssets => {
                const accumulationIds = this.accumulationList.map(item => item.id);
                const assetsToJoin = groupAssets.filter(asset => !accumulationIds.includes(asset.id));
                
                if (assetsToJoin.length === 0) {
                    this.showToast('Info', 'All assets in this group are already in the list.', 'info');
                    this.isLoading = false;
                    return;
                }

                const hasDifferentZip = assetsToJoin.some(asset => !this.isZipCodeMatch(asset.zipCode));

                if (hasDifferentZip) {
                    if (!confirm('Zip codes do not match. Do you want to proceed?')) { // Translated
                        this.isLoading = false;
                        return; 
                    }
                }

                return this.processGroupAssets(assetsToJoin);
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching group assets: ' + (error?.body?.message || 'Unknown error'), 'error');
                this.isLoading = false;
            });
    }

    async processGroupAssets(assets) {
        const currentYear = String(new Date().getFullYear());
        try {
            const promises = assets.map(asset => this.convertAssetToAccumulationItem(asset, currentYear));
            const newItems = await Promise.all(promises);
            const validItems = newItems.filter(item => item && item.id);

            const itemsWithPermission = validItems.map(item => ({
                ...item,
                canDelete: this.canDeleteItem(item)
            }));
            
            this.accumulationList = [...this.accumulationList, ...itemsWithPermission];
            this.showAccumulationList = true;
            
            const joinedIds = itemsWithPermission.map(item => item.id);
            this.requestList = this.requestList.filter(item => !joinedIds.includes(item.id));

            this.showToast('Success', `${itemsWithPermission.length} asset(s) joined from group.`, 'success');
        } catch (error) {
            this.showToast('Error', 'Error joining group assets', 'error');
        } finally {
            this.isLoading = false;
        }
    }

    joinSingleAsset(selectedRequest) {
        this.isLoading = true;
        const currentYear = String(new Date().getFullYear());
        this.convertAssetToAccumulationItem(selectedRequest, currentYear)
            .then(newItem => {
                if(!newItem) return;
                newItem.canDelete = this.canDeleteItem(newItem);
                this.accumulationList = [...this.accumulationList, newItem];
                this.showAccumulationList = true;
                this.requestList = this.requestList.filter(item => item.id !== selectedRequest.id);
                this.showToast('Success', 'Request joined.', 'success');
            })
            .catch(error => this.showToast('Error', error?.body?.message, 'error'))
            .finally(() => this.isLoading = false);
    }

    async convertAssetToAccumulationItem(asset, currentYear) {
        if (!asset || !asset.id) return null;
        try {
            const exchangeRate = await getExchangeRate({ currencyCode: asset.cur, year: currentYear });
            return {
                id: asset.id,
                requestNum: asset.requestNum,
                policyNum: asset.policyNum,
                riskName: asset.riskName,
                insuredName: asset.insuredName,
                address: asset.address,
                zipCode: asset.zipCode,
                nkr: asset.nkr,
                showConversion: asset.cur !== DEFAULT_CURRENCY,
                cur: asset.cur,
                sumInsured: asset.sumInsured,
                sumInsuredIDR: asset.sumInsured * exchangeRate,
                exchangeRate,
                riskId: asset.riskId,
                riskObjectId: null,
                opportunityId: asset.opportunityId,
                effectiveDate: new Date().toLocaleDateString('en-GB'),
                groupId: asset.groupId,
                canDelete: true,
                accumId: asset.accumId || '' 
            };
        } catch (error) {
            return { 
                ...asset, 
                sumInsuredIDR: asset.sumInsured, 
                exchangeRate: 1.0, 
                showConversion: false, 
                canDelete: true, 
                accumId: asset.accumId || '' 
            };
        }
    }

    // [MODIFIED] Handle Remove - Checks Opportunity Assigned Underwriter
    handleRemove(event) {
        const recordIdToRemove = event.currentTarget.dataset.id;
        const itemToRemove = this.accumulationList.find(item => item.id === recordIdToRemove);
        
        if (!itemToRemove) return;

        if (this.isEditMode) {
            if (!itemToRemove.canDelete) {
                this.showToast('Permission Denied', 'Only the Assigned Underwriter can remove this risk.', 'warning'); // Translated
                return;
            }
            if (confirm('Are you sure you want to remove this risk? This action is immediate.')) { // Translated
                this.handleImmediateDelete(itemToRemove);
            }
        } else {
            this.accumulationList = this.accumulationList.filter(item => item.id !== recordIdToRemove);
            this.showAccumulationList = this.accumulationList.length > 0;
            this.showToast('Info', 'Risk removed from list.', 'info'); // Translated
        }
    }

    // [NEW] Immediate API call for Deletion
    handleImmediateDelete(itemToRemove) {
        this.isLoading = true;

        const payload = {
            accumulationId: this.existingAccumulationId,
            businessRequestId: itemToRemove.requestNum || '',
            address: itemToRemove.address || '',
            zipCode: itemToRemove.zipCode || '',
            totalTSI: this.totalTSI, 
            versionStr: this.version || '1.0',
            oppId: itemToRemove.opportunityId,
            policyNum: itemToRemove.policyNum || '',
            riskId: itemToRemove.riskId,
            groupId: itemToRemove.groupId,
            allAssetIds: [], 
            assetDetails: [], // Empty list = no updates/creates
            deletedAssetDetails: [itemToRemove], // Trigger Delete Logic in IP
            inceptionDate: this.inceptionDate
        };

        updateAccumulationRecord({ data: payload })
            .then(result => {
                if (result && result.success) {
                    this.showToast('Success', 'Risk deleted successfully.', 'success'); // Translated
                    this.accumulationList = this.accumulationList.filter(item => item.id !== itemToRemove.id);
                    this.showAccumulationList = this.accumulationList.length > 0;
                } else {
                    const msg = result && result.message ? result.message : 'Unknown error';
                    this.showToast('Error', 'Failed to delete: ' + msg, 'error'); // Translated
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error deleting record: ' + (error?.body?.message || error?.message), 'error');
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    handleSetAccumulation() {
        if (this.isLoading) return;

        if (!this.isEditMode && this.accumulationList.length < 2) {
             this.showToast('Warning', 'Minimum 2 risks required to create accumulation.', 'warning'); // Translated
             return;
        }

        this.isLoading = true;
        const recordData = this.prepareAccumulationData();
        const saveMethod = this.isEditMode ? updateAccumulationRecord : createAccumulationRecord;
        
        saveMethod({ data: recordData })
            .then(result => {
                if (result && result.success) {
                    this.showToast('Success', 'Integration Successful.', 'success'); // Translated
                    setTimeout(() => location.reload(), RELOAD_DELAY);
                } else {
                    const msg = result && result.message ? result.message : 'Unknown integration error';
                    this.showToast('Error', 'Integration Failed: ' + msg, 'error'); // Translated
                    this.isLoading = false; 
                }
            })
            .catch(error => {
                this.showToast('Error', 'Error: ' + (error?.body?.message || error?.message), 'error');
                this.isLoading = false;
            });
    }

    prepareAccumulationData() {
        const referenceItem = this.accumulationList.length > 0 ? this.accumulationList[0] : null;
        
        const newVersion = this.isEditMode ? this.version : this.calculateNewVersion();
        const allAssetIds = this.accumulationList.map(item => item.id); 

        // deletedAssetDetails is always null here because deletions are handled immediately
        const deletedAssetDetails = null;

        return {
            accumulationId: this.existingAccumulationId,
            businessRequestId: referenceItem ? (referenceItem.requestNum || '') : '',
            address: referenceItem ? (referenceItem.address || '') : '',
            zipCode: referenceItem ? (referenceItem.zipCode || '') : '',
            totalTSI: this.totalTSI,
            versionStr: newVersion,
            oppId: this.isQuoteContext ? this.opportunityId : (referenceItem ? referenceItem.opportunityId : null),
            policyNum: referenceItem ? (referenceItem.policyNum || '') : '',
            riskId: this.isQuoteContext ? this.currentRiskId : null,
            groupId: this.groupId || (referenceItem ? referenceItem.groupId : null),
            allRiskIds: [],
            allAssetIds: allAssetIds, 
            inceptionDate: this.inceptionDate,
            assetDetails: this.accumulationList, 
            deletedAssetDetails: deletedAssetDetails
        };
    }

    calculateNewVersion() {
        if (!this.version) return '1.0';
        return (parseFloat(this.version) + 1).toFixed(1);
    }

    loadExchangeRateAndAddToList(assetRow) {
        if(!assetRow) return;
        const currentYear = String(new Date().getFullYear());
        getExchangeRate({ currencyCode: assetRow.cur, year: currentYear })
            .then(rate => {
                assetRow.sumInsuredIDR = assetRow.sumInsured * rate;
                assetRow.exchangeRate = rate;
                assetRow.showConversion = assetRow.cur !== DEFAULT_CURRENCY;
                assetRow.canDelete = true;
                assetRow.accumId = assetRow.accumId || '';
                
                this.accumulationList = [assetRow];
                this.showAccumulationList = true;
            })
            .finally(() => this.isLoading = false);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }       
}