import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActiveFields from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getActiveFields';
import getSections from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getSections';
import saveDetailAsset from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.saveDetailAsset';
import getDetailAssetData from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getDetailAssetData';
import getDetailAssetsByRisk from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getDetailAssetsByRisk';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import COB_FIELD from '@salesforce/schema/Asset.COB__c';
import OPPORTUNITY from '@salesforce/schema/Asset.Opportunity__c';
import NAME_FIELD from '@salesforce/schema/Asset.Name';
import RECORD_TYPE_FIELD from '@salesforce/schema/Asset.Record_Type__c';
import { getRecord } from 'lightning/uiRecordApi';
import getRecordTypeIdByCob from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob';
import { CloseActionScreenEvent } from 'lightning/actions';
// import { NavigationMixin } from 'lightning/navigation';

export default class AswataNewRiskDetailAsset extends LightningElement {
    @api objectName = 'Asset';
    @api recordId;
    @api currentId;
    @api nameParent;
    @api cobValue;
    @api cobLabel;
    @api opportunityId;
    @api recordTypeId;
    @api parentAsset;
    @api fromOpportunityModal = false;
    
    // ✅ List/Form Toggle
    @track showFormView = false;
    @track savedAssets = [];
    @track isLoading = false;
    @track isOpportunityOpen = true;
    
    @track dynamicFields = [];
    @track formData = {};
    @track picklistValues; 
    @track exchangeRate = 1;
    @track section;
    @track sectionId;
    @track resultSection = [];
    @track groupedDynamicFields = {};

    // ✅ For Add/Edit Asset Modal
    @track isAddEditAssetModalOpen = false;
    @track selectedAssetIdForEdit = null;
    
    controllingValue;
    fieldsReady = false;
    picklistReady = false;
    recordTypeValue = null;

    // Pagination for Risk List
    assetPage = 1;
    assetPageSize = 5;

    get assetTotalPages() {
        return Math.ceil(this.savedAssets.length / this.assetPageSize);
    }

    get paginatedAssetData() {
        const startIndex = (this.assetPage - 1) * this.assetPageSize;
        const endIndex = startIndex + this.assetPageSize;
        
        return this.savedAssets
            .slice(startIndex, endIndex)
            .map((asset, index) => ({
                ...asset,
                rowNumber: startIndex + index + 1  // ✅ Add sequential row number
            }));
    }

    handleNextAsset() {
        if (this.assetPage < this.assetTotalPages) {
            this.assetPage++;
        }
    }

    handlePrevAsset() {
        if (this.assetPage > 1) {
            this.assetPage--;
        }
    }

    // ✅ Columns with Row Actions (Edit Asset)
    listAssetColumns = [
        { 
            label: 'No', 
            fieldName: 'rowNumber', 
            type: 'number',
            cellAttributes: { alignment: 'left' },
            initialWidth: 60
        },
        { label: 'Asset Name', fieldName: 'name', type: 'text' },
        { label: 'Section', fieldName: 'sectionName', type: 'text' },
        { label: 'Category', fieldName: 'categoryName', type: 'text' },
        { label: 'Amount (IDR)', fieldName: 'amountIDR', type: 'currency', typeAttributes: { currencyCode: 'IDR' } },
        { 
            type: 'action',
            typeAttributes: {
                rowActions: [
                    {
                        label: 'Edit Asset',
                        name: 'edit_asset',
                        iconName: 'utility:edit'
                    }
                ]
            },
            cellAttributes: {
                alignment: 'center'
            }
        }
    ];

    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [NAME_FIELD, COB_FIELD, OPPORTUNITY, RECORD_TYPE_FIELD]
    })
    wiredAssetRecord({ error, data }) {
        if (data) {
            this.recordTypeValue = data.fields.Record_Type__c?.value;
            this.cobValue = data.fields.COB__c.value;
            this.cobLabel = data.fields.COB__c.displayValue;
            this.nameParent = data.fields.Name.value;
            this.opportunityId = data.fields.Opportunity__c.value;
            
            console.log(`📋 Mode: ${this.recordTypeValue}`);
            
            if (this.isAddMode) {
                this.loadExistingAssets();
            } else if (this.isEditMode) {
                this.loadExistingAssetData();
            }
        }
    }

    async loadExistingAssets() {
        if (!this.recordId) return;

        try {
            console.log('🔄 Loading assets for Risk:', this.recordId);
            
            const assets = await getDetailAssetsByRisk({ riskId: this.recordId });
            
            console.log('✅ Loaded assets:', assets.length);
            console.log('📦 Asset data:', JSON.stringify(assets));
            
            this.savedAssets = assets.map((asset, index) => {
                const sectionName = asset.Section__r?.Name || '-';
                const categoryName = asset.Category__r?.Name || '-';
                
                return {
                    id: asset.Id,
                    name: asset.Interest_Insured_Detail_Description__c || asset.Name || `Asset ${index + 1}`,
                    sectionName: sectionName,
                    categoryName: categoryName,
                    amountIDR: asset.Amount_IDR_new__c || 0,
                    salesforceId: asset.Id
                };
            });
            
            // ✅ LOGIKA: Jika tidak ada asset, langsung buka form Add
            if (this.savedAssets.length === 0) {
                console.log('📝 No assets found, opening Add Asset form');
                this.selectedAssetIdForEdit = this.recordId; // Pass Risk ID
                this.isAddEditAssetModalOpen = true;
                this.showFormView = false; // Tetap false untuk hide list
            } else {
                console.log('📋 Assets found, showing list');
                this.showFormView = false; // Show list view
            }
            
            console.log('📊 Total assets:', this.savedAssets.length);
            
        } catch (error) {
            console.error('❌ Error loading assets:', error);
            // Jika error, tetap coba buka form
            this.selectedAssetIdForEdit = this.recordId;
            this.isAddEditAssetModalOpen = true;
            this.showFormView = false;
        }
    }

    // ✅ Load asset data for editing (from list)
    async loadAssetForEdit(assetId) {
        try {
            console.log('🔄 Loading asset data for edit:', assetId);
            
            const data = await getDetailAssetData({ detailAssetId: assetId });
            
            console.log('✅ Asset data loaded:', JSON.stringify(data));
            
            this.formData = { ...data };
            this.currentId = assetId; // ✅ Set currentId for edit mode
            this.cobValue = this.formData?.COB__c || null;
            this.parentAsset = this.formData?.Parent_Asset__c || null;
            this.exchangeRate = this.formData?.Exchange_Rate__c || 1;
            this.section = this.formData?.Section_Name__c || '';
            this.sectionId = this.formData?.Section__c || '';

            if (this.formData?.Indemnity_Type__c) {
                this.controllingValue = this.formData.Indemnity_Type__c;
            }
            
            if (this.cobValue) {
                await this.fetchActiveFields(this.cobValue);
            }
            
            if (this.section && this.cobValue) {
                this.fetchSection(this.section, this.cobValue);
            }
            
            this.showFormView = true;
            
        } catch (error) {
            console.error('❌ Error loading asset data:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Failed to load asset data',
                    variant: 'error'
                })
            );
        }
    }

    async loadExistingAssetData() {
        try {
            console.log('🔄 Loading asset data for edit:', this.recordId);
            
            const data = await getDetailAssetData({ detailAssetId: this.recordId });
            
            this.formData = { ...data };
            this.cobValue = this.formData?.COB__c || null;
            this.parentAsset = this.formData?.ParentId || null;
            this.exchangeRate = this.formData?.Exchange_Rate__c || 1;
            this.section = this.formData?.Section_Name__c || '';
            this.sectionId = this.formData?.Section__c || '';

            if (this.formData?.Indemnity_Type__c) {
                this.controllingValue = this.formData.Indemnity_Type__c;
            }
            
            if (this.cobValue) {
                await this.fetchActiveFields(this.cobValue);
            }
            
            if (this.section && this.cobValue) {
                this.fetchSection(this.section, this.cobValue);
            }
            
            this.showFormView = true;
            
        } catch (error) {
            console.error('❌ Error loading asset data:', error);
        }
    }

    get isEditMode() {
        return this.recordTypeValue === 'Asset';
    }

    get isAddMode() {
        return this.recordTypeValue === 'Risk';
    }

    get modalTitle() {
        if (this.showFormView) {
            return this.currentId ? 'EDIT DETAIL ASSET' : 'ADD NEW DETAIL ASSET';
        }
        return 'LIST OF ASSET';
    }

    get saveButtonLabel() {
        return this.currentId ? 'Update' : 'Save';
    }

    // ✅ Handle Row Actions
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        
        if (actionName === 'edit_asset') {
            console.log('✏️ Edit Asset clicked for:', row);
            console.log('   Asset Salesforce ID:', row.salesforceId);
            
            this.selectedAssetIdForEdit = row.salesforceId;
            this.isAddEditAssetModalOpen = true;
            
            this.hideParentModal();
        }
    }


    handleAddNewAsset() {
        console.log('➕ Opening Add Asset modal');
        this.selectedAssetIdForEdit = this.recordId; // Pass Risk ID as recordId
        this.isAddEditAssetModalOpen = true;
        
        this.hideParentModal();
    }

    async fetchActiveFields(cob) {
        const data = await getActiveFields({ cobValue: cob });
        this.dynamicFields = data;
        this.fieldsReady = true;
        console.log('✅ Fields loaded:', this.dynamicFields.length);
        this.handleDataLoad();
    }
    
    @wire(getRecordTypeIdByCob, { objectName: '$objectName', cobValue: '$objectName' })
    wiredRtId({ error, data }) {
        if (data) {
            this.recordTypeId = data;
        }
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: '$objectName',
        recordTypeId: '$recordTypeId'
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data;
            this.picklistReady = true;
            this.handleDataLoad();
        }
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        let value = event.target.value;
        
        if(fieldName === 'Amount__c' ){
            this.formData = {
                ...this.formData,
                Amount_IDR_new__c: event.target.value * this.exchangeRate
            };
        }
        if (fieldName === 'Indemnity_Type__c') {
            this.controllingValue = value;
        }
        if (fieldName === 'Interest_Insured_Detail_Description__c') {
            this.formData = {
                ...this.formData,
                [fieldName]: value,
                Name: value
            };
        }

        this.formData = {
            ...this.formData,
            [fieldName]: value
        };

        this.dynamicFields = this.dynamicFields.map(f => {
            if (f.apiName === fieldName) {
                return { ...f, value: value };
            }
            return f;
        });
    }

    handleInputChangeNumber(event) {
        const fieldName = event.target.name;
        let value = Number(event.target.value);
        
        this.formData = {
            ...this.formData,
            [fieldName]: value
        };
    }

    fetchSection(sectionTitle, COB) {
        getSections({ titleValue: sectionTitle, cobValue: COB })
            .then(result => {
                this.resultSection = result;
                console.log('✅ Sections loaded:', this.resultSection);
            })
            .catch(error => {
                console.error('❌ Error fetching sections:', error);
            });
    }

    handleLookUpSelected(event) {
        const fieldApiName = event.target.dataset.field;
        const recordId = event.detail.Id;
        const recordName = event.detail.Name;
        const recordSubtitle = event.detail.Subtitle;
        
        if(fieldApiName === 'Currency__c'){
            this.exchangeRate = recordSubtitle;
            this.formData = {
                ...this.formData,
                Currency__c: recordId,
                Exchange_Rate__c: recordSubtitle
            };
        } else if(fieldApiName === 'Section__c'){
            this.section = recordName;
            this.sectionId = recordId;
            this.formData = {
                ...this.formData,
                [fieldApiName]: recordId
            };
            this.fetchSection(this.section, this.cobValue);
        } else { 
            this.formData = {
                ...this.formData,
                [fieldApiName]: recordId
            };
        }
    }

    handleLookUpCleared(event) {
        const fieldApiName = event.target.dataset.field;
        
        if(fieldApiName === 'Section__c'){
            this.section = '';
            this.sectionId = '';
            this.resultSection = [];
            this.formData = {
                ...this.formData,
                'Section__c': null,
                'Category__c': null
            };
        } else {
            this.formData = {
                ...this.formData,
                [fieldApiName]: null
            };
        }
    }
    
    handleAddEditAssetModalClose() {
        console.log('🔴 Closing Add/Edit Asset modal');
        this.isAddEditAssetModalOpen = false;
        this.selectedAssetIdForEdit = null;
        
        // ✅ Reload assets setelah save/close
        this.loadExistingAssets();
        
        // ✅ Jika ada asset, show parent modal (list)
        if (this.savedAssets.length > 0) {
            this.showParentModal();
        } else {
            // ✅ Jika masih tidak ada asset, close ke parent Risk modal
            if (this.fromOpportunityModal) {
                const closeEvent = new CustomEvent('closemodal');
                this.dispatchEvent(closeEvent);
            }
        }
    }
    
    handleCloseDetailAsset() {
        if (this.fromOpportunityModal) {
            const closeEvent = new CustomEvent('closemodal');
            this.dispatchEvent(closeEvent);
            return;
        }

        this.dispatchEvent(new CloseActionScreenEvent());
    }

    hideParentModal() {
        try {
            const listModal = this.template.querySelector('.list-modal');
            if (listModal) {
                listModal.style.display = 'none';
                console.log('✅ Asset LIST modal hidden');
            }
        } catch (error) {
            console.warn('⚠️ Could not hide parent modal:', error);
        }
    }

    showParentModal() {
        try {
            const listModal = this.template.querySelector('.list-modal');
            if (listModal) {
                listModal.style.display = 'flex';
                console.log('✅ Asset LIST modal shown');
            }
        } catch (error) {
            console.warn('⚠️ Could not show parent modal:', error);
        }
    }

    async handleSaveDetailAsset() {
        try {
            this.isLoading = true;
            
            const dataToSave = { ...this.formData };
            
            // ✅ For Edit mode: Keep existing Id
            if (this.currentId) {
                dataToSave.Id = this.currentId;
            } else {
                // ✅ For Add mode: Set ParentId
                dataToSave.ParentId = this.recordId;
            }
            
            dataToSave.Opportunity__c = this.opportunityId;
            
            delete dataToSave.Section_Name__c;
            delete dataToSave.Section_Title__c;
            delete dataToSave.COB__c;
            
            if (dataToSave.Parent_Asset__c) {
                dataToSave.ParentId = dataToSave.Parent_Asset__c;
                delete dataToSave.Parent_Asset__c;
            }
            
            console.log('💾 Saving asset:', JSON.stringify(dataToSave));
            
            const response = await saveDetailAsset({ formData: dataToSave });
            
            console.log('✅ Asset saved:', response);
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.currentId 
                        ? 'Asset updated successfully' 
                        : 'Asset created successfully',
                    variant: 'success'
                })
            );
            
            // ✅ Reload list and show it
            this.resetForm();
            await this.loadExistingAssets();
            this.showFormView = false;
            
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body?.message || error.message,
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }

    resetForm() {
        this.formData = {
            ParentId: this.recordId,
            Opportunity__c: this.opportunityId
        };
        this.currentId = null;
        this.section = '';
        this.sectionId = '';
        this.resultSection = [];
        this.exchangeRate = 1;
        this.controllingValue = null;
    }

    handleDataLoad() {
        if (this.fieldsReady && this.picklistReady) {
            this.buildFields(); 
        }
    }

    get sectionList() {
        if (!this.groupedDynamicFields) return [];
        const desiredSections = this.resultSection;
        return Object.keys(this.groupedDynamicFields)
            .filter(key => desiredSections.includes(key))
            .map(key => ({
                id: key,
                label: `Section ${key}`,
                fields: this.groupedDynamicFields[key].filter(f => {
                    if (f.label === 'Declare Value') {
                        return this.controllingValue === 'First Loss' || this.controllingValue === 'Lost Limit';
                    }
                    return true;
                })
            }))
            .filter(section => section.fields.length > 0)
            .sort((a, b) => a.id - b.id);
    }

    buildFields() {
        this.groupedDynamicFields = {};
        
        this.dynamicFields = this.dynamicFields.map(f => {
            const typeData = (f.dataType || '').toLowerCase().trim();
            
            const fieldObj = {
                apiName: f.apiName,
                label: f.label,
                dataType: f.dataType,
                lookupObject: f.lookupObject,
                filter: f.filter,
                order: f.order,
                section: f.section,
                showData: f.showData,
                isText: (typeData === 'text' || typeData === 'string'),
                isNumber: (typeData === 'number' || typeData === 'double'),
                isPicklist: (typeData === 'picklist'),
                isLookup: typeData === 'lookup',
                isTextArea: typeData === 'textarea',
                isGeolocation: typeData === 'geolocation',
                value: (this.formData && this.formData[f.apiName] !== undefined)
                    ? this.formData[f.apiName]
                    : null
            };

            if (fieldObj.isPicklist && this.picklistValues) {
                const picklistMeta = this.picklistValues.picklistFieldValues[fieldObj.apiName];
                if (picklistMeta) {
                    fieldObj.options = picklistMeta.values.map(v => ({ 
                        label: v.label, 
                        value: v.value 
                    }));
                } else {
                    fieldObj.options = [];
                }
            }

            return fieldObj;
        });
        
        const groupedData = {};
        this.dynamicFields.forEach((fieldConfig) => {
            const sectionValue = fieldConfig.section;
            if (sectionValue !== null && sectionValue !== undefined) {
                if (!groupedData[sectionValue]) {
                    groupedData[sectionValue] = [];
                }
                groupedData[sectionValue].push(fieldConfig);
            }
        });
        this.groupedDynamicFields = groupedData;
    }
}