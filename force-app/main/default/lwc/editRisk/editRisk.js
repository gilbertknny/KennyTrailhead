import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue, getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import modal from '@salesforce/resourceUrl/modal';
import { loadStyle} from 'lightning/platformResourceLoader';
import getActiveFields from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getActiveFields';
import upsertAsset from '@salesforce/apex/Aswata_Add_New_Asset_Controller.upsertAsset';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getRecordTypeIdByCob from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getRecordTypeIdByCob';
import getRequiredFieldsByCob from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getRequiredFieldsByCob';

export default class EditRisk extends LightningElement {

    @api objectName = 'Asset';
    @api recordId;
    
    @track cobValue;
    @track cobLabel;
    @track opportunityId;
    @track addressDescription = '';
    @track formData = {};
    @track fields = [];
    @track recordTypeId;
    @track isLoading = true;
    @track dynamicFields = [];
    @track contractType;

    @track requiredFieldApiNames = new Set();
    
    picklistValues;
    activeFieldData;
    assetRecord;
    wiredAssetResult;
    provinceId;
    cityId;

    // First, get COB to know which fields to load
    @wire(getRecord, { 
        recordId: '$recordId', 
        fields: ['Asset.Id', 'Asset.Name', 'Asset.COB__c', 'Asset.Opportunity__c', 'Asset.RecordTypeId', 'Asset.Opportunity__r.Policy_Closing_Type__c']
    })
    wiredAsset(result) {
        this.wiredAssetResult = result;
        const { error, data } = result;
        
        if (data) {
            console.log('basic data loaded:', data);
            
            // Extract essential fields
            this.cobValue = getFieldValue(data, 'Asset.COB__c');
            this.cobLabel = getFieldValue(data, 'Asset.COB__c');
            this.opportunityId = getFieldValue(data, 'Asset.Opportunity__c');
            this.recordTypeId = getFieldValue(data, 'Asset.RecordTypeId');
            this.contractType = getFieldValue(data, 'Asset.Opportunity__r.Policy_Closing_Type__c');
            
            // Initialize formData with basic fields
            this.formData = {
                Id: this.recordId,
                Name: getFieldValue(data, 'Asset.Name'),
                //COB__c: this.cobValue,
                Opportunity__c: this.opportunityId,
                RecordTypeId: this.recordTypeId
            };

            console.log('formData initialized:', JSON.stringify(this.formData));
        } else if (error) {
            console.error('Error loading Asset:', error);
            this.showToast('Error', 'Failed to load Asset data', 'error');
            this.isLoading = false;
        }
    }

    @wire(getRequiredFieldsByCob, { cobValue: '$cobValue' })
    wiredRequiredFields({ error, data }) {
        if (data) {
            console.log('✅ Required fields from Master Data:', data);
            
            // Convert array to Set for fast lookup
            this.requiredFieldApiNames = new Set(data);
            
            console.log('📋 Required fields Set:', Array.from(this.requiredFieldApiNames));
            console.log('📊 Total required fields:', this.requiredFieldApiNames.size);
            
            // Rebuild fields to update isRequired flags
            if (this.activeFieldData && this.assetRecord) {
                this.buildFields();
            }
        } else if (error) {
            console.error('❌ Error loading required fields:', error);
            console.error('   Error details:', error.body?.message || error.message);
            
            // Fallback to default required fields if query fails
            this.requiredFieldApiNames = new Set([
                'Address__c',
                'Occupation_Code__c',
                'Class__c'
            ]);
            
            console.log('⚠️ Using fallback required fields');
            
            if (this.activeFieldData && this.assetRecord) {
                this.buildFields();
            }
        }
    }

    // Wire Apex fields configuration
    @wire(getActiveFields, { objectName: '$objectName', interestCob: '$cobValue', contractType: '$contractType'})
    wiredFields({ error, data }) {
        if (data) {
            console.log('Active fields loaded:', data);
            this.activeFieldData = data;
            
            // Build field list for secondary getRecord
            this.buildDynamicFieldsList(data);
        } else if (error) {
            console.error('Error loading fields:', error);
            this.isLoading = false;
        }
    }

    // Build list of fields to load
    buildDynamicFieldsList(fieldConfigs) {
        const fieldsToLoad = [];
        
        fieldConfigs.forEach(cfg => {
            fieldsToLoad.push(`Asset.${cfg.apiName}`);
            
            // Add geolocation subfields
            if (cfg.dataType === 'Geolocation') {
                const baseName = cfg.apiName.replace('__c', '');
                fieldsToLoad.push(`Asset.${baseName}__Latitude__s`);
                fieldsToLoad.push(`Asset.${baseName}__Longitude__s`);
            }
        });
        
        // Add Address_Description__c if Address__c exists
        if (fieldsToLoad.includes('Asset.Address__c')) {
            fieldsToLoad.push('Asset.Address_Description__c');
        }
        
        this.dynamicFields = fieldsToLoad;
        console.log('Fields to load:', this.dynamicFields);
    }

    // Second wire to load ALL field values including dynamic ones
    @wire(getRecord, { 
        recordId: '$recordId', 
        optionalFields: '$dynamicFields'
    })
    wiredAllFields({ error, data }) {
        if (data && this.activeFieldData) {
            console.log('fields data loaded:', data);
            this.assetRecord = data;
            
            // Extract ALL field values into formData
            this.activeFieldData.forEach(fieldConfig => {
                const fieldApiName = fieldConfig.apiName;
                const fieldPath = `Asset.${fieldApiName}`;
                const value = getFieldValue(data, fieldPath);
                
                if (value !== undefined && value !== null) {
                    this.formData[fieldApiName] = value;
                }
                
                // Handle geolocation fields
                if (fieldConfig.dataType === 'Geolocation') {
                    const baseName = fieldApiName.replace('__c', '');
                    const latField = `${baseName}__Latitude__s`;
                    const longField = `${baseName}__Longitude__s`;
                    
                    const latValue = getFieldValue(data, `Asset.${latField}`);
                    const longValue = getFieldValue(data, `Asset.${longField}`);
                    
                    if (latValue !== undefined) this.formData[latField] = latValue;
                    if (longValue !== undefined) this.formData[longField] = longValue;
                }
            });
            
            // Extract Address_Description__c
            const addressDesc = getFieldValue(data, 'Asset.Address_Description__c');
            if (addressDesc) {
                this.formData.Address_Description__c = addressDesc;
                this.addressDescription = addressDesc;
            }
            
            // Set lookup IDs
            this.provinceId = this.formData.Province__c;
            this.cityId = this.formData.City__c;
            
            console.log('Complete formData:', JSON.stringify(this.formData));
            
            // Now build the fields for UI
            this.buildFields();
            this.isLoading = false;
        } else if (error) {
            console.error('Error loading all fields:', error);
            this.isLoading = false;
        }
    }

    // Get recordTypeId dynamically based on COB
    @wire(getRecordTypeIdByCob, { objectName: '$objectName', cobValue: '$cobLabel' })
    wiredRtId({ error, data }) {
        if (data) {
            this.recordTypeId = data;
            console.log('RecordTypeId from COB:', this.recordTypeId);
        } else if (error) {
            console.error('fetching RecordTypeId:', error);
        }
    }
     
    @wire(getPicklistValuesByRecordType, {
        objectApiName: '$objectName',
        recordTypeId: '$recordTypeId'
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data;
            if (this.activeFieldData && this.assetRecord) {
                this.buildFields(); // Rebuild if data already loaded
            }
        } else if (error) {
            console.error('Error loading picklist metadata:', error);
        }
    }

    // Build fields with existing values from formData
    buildFields() {
        if (!this.activeFieldData) return;

        // ✅ Use dynamic required fields from Master Data
        const requiredFieldApiNames = this.requiredFieldApiNames.size > 0 
            ? this.requiredFieldApiNames 
            : new Set(['Address__c', 'Occupation_Code__c', 'Class__c']);
        
        console.log('🔧 Building fields with required:', Array.from(requiredFieldApiNames));

        this.fields = this.activeFieldData.map(f => {
            const typeData = (f.dataType || '').toLowerCase().trim();
            
            let lookupFields = 'Name';
            if (f.dataType === 'Lookup') {
                switch (f.filter) {
                    case 'City':
                        lookupFields = 'Name, City_ID__c, Province__r.Name, Country__r.Name';
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
                showData: f.showData ? f.showData : '',
                isRequired: requiredFieldApiNames.has(f.apiName), // ✅ Dynamic!
                isText: typeData === 'text',
                isReadonly: typeData === 'readonly',
                isNumber: typeData === 'number',
                isLookup: typeData === 'lookup',
                isTextArea: typeData === 'textarea',
                isPicklist: typeData === 'picklist',
                isGeolocation: typeData === 'geolocation',
                isAddress: (f.filter || '').toLowerCase() === 'address',
                isDate: typeData === 'date',            
                value: this.formData[f.apiName] !== undefined ? this.formData[f.apiName] : null
            };

            // Add picklist options
            if (fieldObj.isPicklist && this.picklistValues?.picklistFieldValues?.[fieldObj.apiName]) {
                const picklistMeta = this.picklistValues.picklistFieldValues[fieldObj.apiName];
                fieldObj.options = picklistMeta.values.map(v => ({ label: v.label, value: v.value }));
            } else {
                fieldObj.options = [];
            }

            // Handle geolocation fields
            if (typeData === 'geolocation') {
                fieldObj.isGeolocation = true;
                const baseName = f.apiName.replace('__c','');
                fieldObj.latitudeName = `${baseName}__Latitude__s`;
                fieldObj.longitudeName = `${baseName}__Longitude__s`;
                fieldObj.latitudeLabel = `${f.label} (Latitude)`;
                fieldObj.longitudeLabel = `${f.label} (Longitude)`;

                fieldObj.latitude = this.formData[fieldObj.latitudeName] || null;
                fieldObj.longitude = this.formData[fieldObj.longitudeName] || null;
            }

            return fieldObj;
        });

        this.fields.sort((a, b) => (a.order || 0) - (b.order || 0));
        
        const requiredCount = this.fields.filter(f => f.isRequired).length;
        console.log(`✅ Fields built: ${this.fields.length} total, ${requiredCount} required`);
    }

    validateRequiredFields() {
        const requiredFields = [];
        
        this.fields.forEach(field => {
            if (field.isRequired) {
                requiredFields.push({
                    apiName: field.apiName,
                    label: field.label
                });
            }
        });
        
        console.log('🔍 Validating required fields:', requiredFields.map(f => f.label).join(', '));

        const missingFields = [];

        requiredFields.forEach(field => {
            const value = this.formData[field.apiName];
            if (!value || value === '' || value === null || value === undefined) {
                missingFields.push(field.label);
            }
        });

        if (missingFields.length > 0) {
            const fieldList = missingFields.join(', ');
            this.showToast(
                'Required Fields Missing',
                `Please fill in the following required fields: ${fieldList}`,
                'error'
            );
            return false;
        }

        return true;
    }

    handleUpdateAsset() {
        // ✅ Add validation before save
        if (!this.validateRequiredFields()) {
            console.log('❌ Validation failed');
            return;
        }
        
        console.log('Updating Asset with data:', JSON.stringify(this.formData));

        if (!this.formData.Id) {
            this.formData.Id = this.recordId;
        }

        upsertAsset({ fieldValues: this.formData })
            .then(resultId => {
                console.log('✅ Asset updated! Id:', resultId);

                getRecordNotifyChange([{ recordId: this.recordId }]);

                this.showToast('Success', 'Risk updated successfully', 'success');
                
                this.dispatchEvent(new CustomEvent('close'));
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('❌ Error updating Asset:', error);
                const errorMessage = error?.body?.message || error.message || 'Unknown error';
                this.showToast('Error', 'Failed to update Risk: ' + errorMessage, 'error');
            });
    }

    connectedCallback() {
        console.log('Edit Risk Component initialized for recordId:', this.recordId);
        Promise.all([
            loadStyle(this, modal)
        ]);
    }

    handleInputChange(event) {
        try {
            const fieldName = event.target.name;
            let value = event.target.value;

            if (event.target.type === 'number' || 
                fieldName.endsWith('__Latitude__s') || 
                fieldName.endsWith('__Longitude__s')) {
                value = (value !== '' && value !== null) ? parseFloat(value) : null;
            }

            // Validate Latitude
            if (fieldName.endsWith('__Latitude__s')) {
                if (value !== null && (value < -90 || value > 90)) {
                    this.showToast('Error', 'Latitude must be between -90 and 90', 'error');
                    return;
                }
            }

            // Validate Longitude
            if (fieldName.endsWith('__Longitude__s')) {
                if (value !== null && (value < -180 || value > 180)) {
                    this.showToast('Error', 'Longitude must be between -180 and 180', 'error');
                    return;
                }
            }

            // Update formData
            this.formData = {
                ...this.formData,
                [fieldName]: value
            };

            // Update fields for UI re-render
            this.fields = this.fields.map(f => {
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

            console.log('formData updated:', JSON.stringify(this.formData));
        } catch (e) {
            console.error('Error in handleInputChange:', e);
        }
    }

    handleLookUpSelected(event) {
        const fieldApiName = event.target.dataset.field;
        const record = event.detail;
        const fieldMap = (record && record.FieldMap) ? record.FieldMap : {};
        const recordId = record.Id;
        const recordName = record.Name;

        this.formData = {
            ...this.formData,
            [fieldApiName]: recordId
        };

        if (Object.keys(fieldMap).length > 0) {
            this.formData = {
                ...this.formData,
                ...fieldMap
            };
        }

        this.fields = this.fields.map(f => {
            if (fieldMap && fieldMap.hasOwnProperty(f.apiName)) {
                return { ...f, value: fieldMap[f.apiName] };
            }
            if (f.apiName === fieldApiName) {
                return { ...f, value: recordId };
            }
            return f;
        });

        console.log('formData updated:', JSON.stringify(this.formData));

        if (fieldApiName === 'Province__c') {
            this.provinceId = recordId;
        }
        if (fieldApiName === 'City__c') {
            this.cityId = recordId;
        }
        if (fieldApiName === 'Address__c') {
            this.addressDescription = recordName;
            this.formData = {
                ...this.formData,
                Address_Description__c: this.addressDescription
            };
        }
    }

    handleLookUpCleared(event) {
        const fieldApiName = event.target.dataset.field;

        // Clear the main lookup field
        this.formData = {
            ...this.formData,
            [fieldApiName]: null
        };

        // Update UI for main field
        this.fields = this.fields.map(f => {
            if (f.apiName === fieldApiName) {
                return { ...f, value: null };
            }
            return f;
        });

        // Handle specific lookups
        if (fieldApiName === 'Province__c') {
            this.provinceId = null;
            // Clear dependent City and Address
            this.formData.City__c = null;
            this.formData.Address__c = null;
            this.formData.Address_Description__c = null;
            this.cityId = null;
            this.addressDescription = null;
            
            // Update UI for dependent fields
            this.fields = this.fields.map(f => {
                if (f.apiName === 'City__c' || f.apiName === 'Address__c') {
                    return { ...f, value: null };
                }
                return f;
            });
        }
        
        if (fieldApiName === 'City__c') {
            this.cityId = null;
            // Clear dependent Address
            this.formData.Address__c = null;
            this.formData.Address_Description__c = null;
            this.addressDescription = null;
            
            // Update UI for Address
            this.fields = this.fields.map(f => {
                if (f.apiName === 'Address__c') {
                    return { ...f, value: null };
                }
                return f;
            });
        }
        
        if (fieldApiName === 'Address__c') {
            this.addressDescription = null;
            
            const addressDependentFields = [
                'Address_Description__c',
                'Zip_Code__c', 
                'EQ_Zone__c', 
                'Volcanic_Zone__c', 
                'Tsunami_Zone__c'
            ];
            
            addressDependentFields.forEach(field => {
                this.formData[field] = null;
            });
            
            this.formData.Province__c = null;
            this.formData.City__c = null;
            this.provinceId = null;
            this.cityId = null;
            
            // Update UI for all dependent fields including Province and City
            this.fields = this.fields.map(f => {
                if (addressDependentFields.includes(f.apiName) || 
                    f.apiName === 'Province__c' || 
                    f.apiName === 'City__c') {
                    return { ...f, value: null };
                }
                return f;
            });
        }

        console.log('formData:', JSON.stringify(this.formData));
    }

    handleUpdateAsset() {
        // ✅ Add validation FIRST
        if (!this.validateRequiredFields()) {
            console.log('❌ Validation failed - required fields missing');
            return; // ✅ Stop here, don't proceed to save
        }
        
        console.log('✅ Validation passed, proceeding to update...');
        console.log('Updating Asset with data:', JSON.stringify(this.formData));

        if (!this.formData.Id) {
            this.formData.Id = this.recordId;
        }

        // ✅ Add try-catch for better error handling
        upsertAsset({ fieldValues: this.formData })
            .then(resultId => {
                console.log('✅ Asset updated! Id:', resultId);

                getRecordNotifyChange([{ recordId: this.recordId }]);

                this.showToast('Success', 'Risk updated successfully', 'success');
                
                this.dispatchEvent(new CustomEvent('close'));
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('❌ Error updating Asset:', error);
                console.error('   Error body:', error.body);
                console.error('   Error message:', error.message);
                
                // ✅ Better error message handling
                let errorMessage = 'Unknown error occurred';
                
                if (error.body) {
                    if (error.body.message) {
                        errorMessage = error.body.message;
                    } else if (error.body.pageErrors && error.body.pageErrors.length > 0) {
                        errorMessage = error.body.pageErrors[0].message;
                    } else if (error.body.fieldErrors) {
                        const fieldErrors = Object.values(error.body.fieldErrors).flat();
                        if (fieldErrors.length > 0) {
                            errorMessage = fieldErrors[0].message;
                        }
                    }
                } else if (error.message) {
                    errorMessage = error.message;
                }
                
                this.showToast('Error', 'Failed to update Risk: ' + errorMessage, 'error');
            });
    }

    handleCloseModal() {
        // ✅ Dispatch close event to parent
        this.dispatchEvent(new CustomEvent('close'));
        
        // ✅ Also close standard modal
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}