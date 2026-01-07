import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActiveFields from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getActiveFields';
import getSections from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getSections';
import saveDetailAsset from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.saveDetailAsset';
import getDetailAssetData from '@salesforce/apex/Aswata_Add_New_DetailAsset_Controller.getDetailAssetData';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import COB_FIELD from '@salesforce/schema/Asset.COB__c';
import OPPORTUNITY from '@salesforce/schema/Asset.Opportunity__c';
import NAME_FIELD from '@salesforce/schema/Asset.Name';
import RECORD_TYPE_FIELD from '@salesforce/schema/Asset.Record_Type__c';
import { getRecord } from 'lightning/uiRecordApi';
import getRecordTypeIdByCob from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob';
import { CloseActionScreenEvent } from 'lightning/actions';
// import { NavigationMixin } from 'lightning/navigation';

export default class addNewDetailAsset extends LightningElement {
    @api objectName = 'Asset';
    @api recordId;
    @api currentId;
    @api nameParent;
    @api cobValue;
    @api cobLabel;
    @api opportunityId;
    @api recordTypeId;
    @api parentAsset;
    
    // ✅ NEW: Flag to detect if opened from addNewRisk modal
    _fromOpportunityModal = false;

    @api
    get fromOpportunityModal() {
        return this._fromOpportunityModal;
    }
    set fromOpportunityModal(value) {
        // normalize: only true / 'true' become true
        this._fromOpportunityModal = (value === true || value === 'true');
    }
    
    @track dynamicFields = [];
    @track formData = {};
    @track picklistValues; 
    @track transactionData = [];
    @track currency = 'IDR';
    @track exchangeRate = 1;
    @track detailInsuredName;
    @track amount;
    @track amountIDR;
    @track category;
    @track section;
    @track categoryID;
    @track sectionId;
    @track resultSection = [];
    @track showSection = false;
    // @track descriptionDetailInsured;
    // @track indemnityType;
    // @track firstLossAmount;
    @track showSectionFields = false; // controls Section & below visibility
    @track showDataTable = false;
    @track groupedDynamicFields = {};
    @track hideParentModal = false; 
    controllingValue;

    recordTypeIdAsset;
    activeFieldData;
    picklistOptions;
    fieldsReady = false;
    picklistReady = false;
    recordTypeValue = null;
    
    @wire(getRecord, { recordId: '$recordId', fields: [NAME_FIELD,COB_FIELD, OPPORTUNITY] })
    wiredOpportunity({ error, data }) {
        if (data) {
            console.log('Fetching COB data:', data);
            this.cobValue = data.fields.COB__c.value;
            this.cobLabel = data.fields.COB__c.displayValue;
            this.nameParent = data.fields.Name.value;
            this.opportunityId = data.fields.Opportunity__c.value;
            this.fetchActiveFields(this.cobValue);
            this.formData = {
                ...this.formData,
                ParentId: this.recordId,
                //Name: this.nameParent,
                Opportunity__c: this.opportunityId
            };
            console.log('Fetching COB:', JSON.stringify(this.formData));
        } else if (error) {
            console.error('❌ Error fetching COB:', error);
        }
    }

    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: [NAME_FIELD, COB_FIELD, OPPORTUNITY, RECORD_TYPE_FIELD]
    })
    wiredAssetRecord({ error, data }) {
        if (data) {
            // Get custom field value
            this.recordTypeValue = data.fields.Record_Type__c?.value;
            console.log(`Mode: ${this.recordTypeValue}`);

            if (this.isAddMode) {
                // Risk record → Setup for new child
                this.formData = {
                    ParentId: this.recordId,
                    Opportunity__c: this.opportunityId
                };
            } else if (this.isEditMode) {
                // Asset record → Load existing
                this.loadExistingAssetData();
            }
        }
    }

    async loadExistingAssetData() {
        try {
            console.log('🔄 Loading existing asset data for:', this.recordId);
            
            const data = await getDetailAssetData({ detailAssetId: this.recordId });
            
            console.log('✅ Asset data loaded:', JSON.stringify(data));
            
            // Set formData
            this.formData = { ...data };
            
            // Set other properties
            this.cobValue = this.formData?.COB__c || null;
            this.parentAsset = this.formData?.ParentId || null;
            this.exchangeRate = this.formData?.Exchange_Rate__c || 1;
            
            // ✅ Set section name untuk display
            this.section = this.formData?.Section_Name__c || '';
            this.sectionId = this.formData?.Section__c || '';

            if (this.formData?.Indemnity_Type__c) {
                this.controllingValue = this.formData.Indemnity_Type__c;
                console.log('🔧 Initialized controllingValue:', this.controllingValue);

            }
            
            console.log('🔍 Loaded values:');
            console.log('  Currency:', this.formData.Currency__c);
            console.log('  Section:', this.formData.Section__c, '(' + this.section + ')');
            console.log('  Category:', this.formData.Category__c);
            console.log('  Indemnity Type:', this.formData.Indemnity_Type__c);
            console.log('  Description:', this.formData.Interest_Insured_Detail_Description__c);
            
            // Fetch active fields based on COB
            if (this.cobValue) {
                await this.fetchActiveFields(this.cobValue);
            }
            
            // ✅ Auto-trigger fetchSection untuk show Section 1
            if (this.section && this.cobValue) {
                console.log('🔄 Auto-loading Section 1 for edit mode...');
                this.fetchSection(this.section, this.cobValue);
            }
            
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
        if (this.isEditMode) return 'EDIT DETAIL ASSET';
        if (this.isAddMode) return 'ADD NEW DETAIL ASSET';
        return 'DETAIL ASSET';
    }

    get saveButtonLabel() {
        return this.isEditMode ? 'Update' : 'Save';
    }

    getFilteredFields(sectionFields) {
        return sectionFields.filter(f => {
            // Apply visibility rule only to "Declare Value"
            if (f.label === 'Declare Value') {
                return this.controllingValue === 'First Loss' || this.controllingValue === 'Lost Limit';
            }
            return true; // other fields always visible
        });
    }
    get sectionList() {
        if (!this.groupedDynamicFields) return [];
        const desiredSections = this.resultSection;
        const sections = Object.keys(this.groupedDynamicFields)
            .filter(key => desiredSections.includes(key))
            .map(key => {
                const sectionNumber = key;
                const originalFields = this.groupedDynamicFields[sectionNumber];
                const filteredFields = originalFields.filter(f => {
                    if (f.label === 'Declare Value') {
                        return this.controllingValue === 'First Loss' || this.controllingValue === 'Lost Limit';
                    }
                    return true; 
                });
                if (filteredFields.length === 0) {
                    return null;
                }
                return {
                    id: sectionNumber, 
                    label: `Section ${sectionNumber}`,
                    fields: filteredFields
                };
            })
            .filter(section => section !== null) 
            .sort((a, b) => a.id - b.id); 
        console.log('sections',sections);
        return sections;
    }
    @wire(getDetailAssetData, { detailAssetId: '$currentId' })
        wiredCoverage({ error, data }) {
            if (data) {
                this.formData = { ...data };

                console.log('🔍 Category__c value:', this.formData.Category__c);
                console.log('🔍 Section__c value:', this.formData.Section__c);
                console.log('🔍 Full formData:', JSON.stringify(this.formData));

                this.cobValue = this.formData?.COB__c || null;
                this.parentAsset = this.formData?.Parent_Asset__c || null;
                //console.log('currentId: ' + this.currentId);
                console.log('Fetched detailAsset data:', JSON.stringify(this.formData));
            } else if (error) {
                console.error('Error fetching detailAsset data', error);
            }
    }
    
    // @wire(getActiveFields, { cobValue: '$objectName' })
    // wiredFields({ error, data }) {
    //     if (data) {
    //         this.dynamicFields = data;
    //         this.loading = false;
    //         this.fieldsReady = true;
    //         console.log('✅ Dynamic Field Loaded:', this.dynamicFields);
    //         this.handleDataLoad();
    //     } else if (error) {
    //         this.loading = false;
    //             console.error('❌ Error fetching Active Fields:', error);
    //     }
    // }

    async fetchActiveFields(cob) {
        const data = await getActiveFields({ cobValue: cob });
        this.dynamicFields = data;
        this.loading = false;
        this.fieldsReady = true;
        console.log('✅ Dynamic Field Loaded Async:', this.dynamicFields);
        this.handleDataLoad();
    }
    
    @wire(getRecordTypeIdByCob, { objectName: '$objectName', cobValue: '$objectName' })
    wiredRtId({ error, data }) {
        if (data) {
            this.recordTypeId = data;
            console.log('✅ RecordTypeId from COB:', this.recordTypeId);
        } else if (error) {
            console.error('❌ Error fetching RecordTypeId:', error);
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
            // console.log('{"Debug cek":', JSON.stringify(this.picklistValues),"}");
            console.log('{"Debug cek":');
            // if (data.picklistFieldValues && data.picklistFieldValues.Indemnity_Type__c) {
            //     this.picklistOptions = data.picklistFieldValues.Indemnity_Type__c.values;
            // }
            this.handleDataLoad();
        } else if (error) {
            console.error('Error loading picklist metadata:', error);
        }
    }
    
    handleInputChange(event) {
        try {
            const fieldName = event.target.name;
            let value = event.target.value;
            console.log(fieldName,value);
            
           
            if(fieldName === 'Amount__c' ){
                this.amountIDR = event.target.value *  this.exchangeRate;   
                console.log('amountIDR: ' + this.amountIDR);
                this.formData = {
                    ...this.formData,
                    Amount_IDR__c : this.amountIDR
                
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

            // update formData
            this.formData = {
                ...this.formData,
                [fieldName]: value
            };

            // also update fields so UI re-renders safely
            this.dynamicFields = this.dynamicFields.map(f => {
                if (f.latitudeName === fieldName) {
                    return { ...f, latitude: value };
                }
                if (f.longitudeName === fieldName) {
                    return { ...f, longitude: value };
                }
                if (f.apiName === fieldName) {
                    return { ...f, value: value };
                }
                return f;
            });

            console.log('📝 formData updated:', JSON.stringify(this.formData));
        } catch (e) {
        console.error('💥 Error in handleInputChange:', e);
        }
    }
    
    handleInputChangeNumber(event) {
        try {
            const fieldName = event.target.name;
            let value = Number(event.target.value);
            console.log(fieldName,value);
            // update formData
            this.formData = {
                ...this.formData,
                [fieldName]: value
            };
            console.log('📝 formData updated:', JSON.stringify(this.formData));
        } catch (e) {
        console.error('💥 Error in handleInputChange:', e);
        }
    }

    fetchSection(sectionTitle,COB) {
        console.log('sectionTitle',sectionTitle + COB);
        
        getSections({ titleValue: sectionTitle,cobValue:COB })
            .then(result => {
                this.resultSection = result;
                console.log('✅ Section Loaded:', this.resultSection);
            })
            .catch(error => {
                this.loading = false;
                console.error('❌ Error fetching Section:', error);
            });
    }

    /* LOGIC FOR CUSTOM LOOKUP COMPONENT */
    handleLookUpSelected(event) {
        const fieldApiName = event.target.dataset.field;   // 👈 from data-field in HTML
        const recordId = event.detail.Id;
        const recordName = event.detail.Name;
        const recordSubtitle = event.detail.Subtitle;
        //const recordType = event.target.dataset.recordtype; // 👈 optional (can also use field.filter)
        console.log('recordSubtitle: ' + recordSubtitle + ' fieldApiName: ' + fieldApiName);
        
        if(fieldApiName === 'Currency__c'){
            this.exchangeRate = recordSubtitle;
            this.formData = {
                ...this.formData,
                Currency__c: recordId,
                Exchange_Rate__c : recordSubtitle,
                [fieldApiName]: recordId
            };
        } else if(fieldApiName === 'Section__c'){
            this.section = recordName;
            this.sectionId = recordId;
            this.formData = {
                ...this.formData,
                //Section_ID__c : recordId,
                [fieldApiName]: recordId
            };
            console.log('Select Section__c: ' + recordId);
            this.fetchSection(this.section,this.cobValue)
        } /*else if(fieldApiName === 'Category__c'){
            this.formData = {
                ...this.formData,
            //Category_ID__c : recordId,
                [fieldApiName]: recordName
            };
        } */ else { 
            this.formData = {
                ...this.formData,
                [fieldApiName]: recordId
            };
        }

        console.log('📝 formData updated:', JSON.stringify(this.formData),' COB: ',this.cobValue);
        // console.log('📝 formData section:', this.formData['Section__c']);
        
    }

    handleLookUpCleared(event) {
        const fieldApiName = event.target.dataset.field;
        console.log('fieldApiName: ' + fieldApiName)
        if(fieldApiName === 'Section__c'){
            this.section = '';
            this.sectionId = '';
            this.resultSection = [];
            this.formData = {
                ...this.formData,
                'Section__c': null,
                'Category__c': null,
            };
        }else{
            this.formData = {
                ...this.formData,
                [fieldApiName]: null
            };
        }        
        
    }
    
    /* Start Action Button */
    handleCloseDetailAsset(){
        // ✅ CASE 1: Opened from Opportunity Modal (addNewRisk)
        console.log(' 777: '+this.fromOpportunityModal);

        if (this.fromOpportunityModal === false || this.fromOpportunityModal === 'false') {
            console.log('🔴 Closing Quick Action modal');
            this.dispatchEvent(new CloseActionScreenEvent());
            return;
        }

        // ✅ CASE 2: Edit mode with currentId (from action button on record page)
        if (this.currentId != null) {
            console.log('🔴 Closing from edit mode - redirect to parent');
            
            if (this.parentAsset) {
                this.recordId = this.parentAsset;
            }
            
            const recordUrl = `/lightning/r/Asset/${this.recordId}/view`;
            window.location.assign(recordUrl);
            return;
        }

        // ✅ CASE 3: Default - close action screen
        console.log('🔴 Custom close - CloseActionScreenEvent');
        //this.dispatchEvent(new CloseActionScreenEvent());

        const closeEvent = new CustomEvent('closemodal');
        this.dispatchEvent(closeEvent);
    }

    validateRequiredFields() {
        const excludedFields = new Set(['ParentId','Name']); 
        const formData = this.formData;
        
        const fieldsToValidate = Object.keys(formData).filter(fieldName => 
            !excludedFields.has(fieldName)
        );

        if (fieldsToValidate.length === 0) {
            console.error('❌ Validation Failed: Form is Empty.');
            return false; 
        }

        return true;
    }

    async handleSaveDetailAsset(){
        try {
            if (!this.validateRequiredFields()) {
                throw new Error('❌ Validation Failed: Form is Empty.');
            }
            
            // Clean up formData
            const dataToSave = { ...this.formData };
            delete dataToSave.Section_Name__c;
            delete dataToSave.Section_Title__c;
            delete dataToSave.COB__c;
            delete dataToSave.Amount_IDR__c;
            
            if (dataToSave.Parent_Asset__c) {
                dataToSave.ParentId = dataToSave.Parent_Asset__c;
                delete dataToSave.Parent_Asset__c;
            }
            
            console.log('📝 formData to SAVE:', JSON.stringify(dataToSave));
            const response = await saveDetailAsset({ formData : dataToSave });
            const newRecordId = response;
            console.log('Saved record Id : ', newRecordId);
            
            if (!newRecordId) {
                throw new Error('Insert failed. Record ID is null.');
            }
            
            // Show success message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: this.isEditMode 
                        ? 'Detail Asset updated successfully' 
                        : 'Detail Asset inserted successfully',
                    variant: 'success'
                })
            );
            
            // ✅ CASE 1: Opened from Opportunity Modal (addNewRisk)
            if (this.fromOpportunityModal === false || this.fromOpportunityModal === 'false') {
                console.log('🔴 Closing Quick Action modal');
                this.dispatchEvent(new CloseActionScreenEvent());
                return;
            }

            const closeEvent = new CustomEvent('closemodal');
            this.dispatchEvent(closeEvent);
            
            // ✅ CASE 2 & 3: Redirect to Risk record page
            /*console.log('✅ Saved - redirect to Risk record page');
            const recordUrl = `/lightning/r/Asset/${this.recordId}/view`;
            window.location.href = recordUrl;
            */
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error saving record',
                    message: error.body?.message || error.message,
                    variant: 'error'
                })
            );
        }
    }
    /* End Action Button */

    handleDataLoad() {
        if (this.fieldsReady && this.picklistReady) {
            console.log('⚡ Fields & Picklist Ready..');
            this.buildFields(); 
        } else {
            console.log(`⏳ Wait data Fields: ${this.fieldsReady}, Picklist: ${this.picklistReady}`);
        }
    }

    buildFields() {
        console.log('Build Field', JSON.stringify(this.dynamicFields));
        this.groupedDynamicFields = {};
        
        this.dynamicFields = this.dynamicFields.map(f => {
            const typeData = (f.dataType || '').toLowerCase().trim();
            let lookupFields = 'Name';
            
            if (f.dataType === 'Lookup') {
                switch (f.filter) {
                    case 'City':
                        lookupFields = 'Name, Section__c, Section_Title__c, BSN_ID__c, BSN__r.Name';
                        break;
                    case 'Province':
                        lookupFields = 'Name, Country__r.Name';
                        break;
                    case 'Address':
                        lookupFields = 'Name, City__r.Name, Zip_Code__r.Name';
                        break;
                    default:
                        lookupFields = 'Name';
                }
            }

            const fieldObj = {
                apiName: f.apiName,
                label: f.label,
                dataType: f.dataType,
                lookupObject: f.lookupObject,
                filter: f.filter,
                order: f.order,
                fieldsToQuery: lookupFields,
                section: f.section,
                showData: f.showData,
                isText: (typeData == 'text' || typeData == 'string'),
                isNumber: (typeData == 'number' || typeData == 'double'),
                isPicklist: (typeData == 'picklist'),
                isLookup: typeData === 'lookup',
                isTextArea: typeData === 'textarea',
                isGeolocation: typeData === 'geolocation',
                isAddress: (f.filter || '').toLowerCase() === 'address',
                
                // ✅ PENTING: Load value dari formData jika ada
                value: (this.formData && this.formData[f.apiName] !== undefined)
                ? this.formData[f.apiName]
                : null
            };

            // Picklist options
            if (fieldObj.isPicklist && this.picklistValues) {
                const picklistMeta = this.picklistValues.picklistFieldValues[fieldObj.apiName];
                if (picklistMeta) {
                    fieldObj.options = picklistMeta.values.map(v => ({ 
                        label: v.label, 
                        value: v.value 
                    }));
                    console.log(`✅ Options for ${fieldObj.apiName}:`, fieldObj.options);
                } else {
                    console.warn(`⚠️ No picklist metadata found for ${fieldObj.apiName}`);
                    fieldObj.options = [];
                }
            }
            
            // ✅ TAMBAHAN: Log loaded values for debugging
            if (fieldObj.value) {
                console.log(`📝 Field ${fieldObj.apiName} loaded with value:`, fieldObj.value);
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
        console.log('⚡ Final mapped fields Complete', this.dynamicFields.length);
        // console.log('📦 Final Grouped Fields:', JSON.stringify(this.groupedDynamicFields));
    }
}