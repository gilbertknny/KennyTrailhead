import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActiveFields from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getActiveFields';
import upsertAsset from '@salesforce/apex/Aswata_Add_New_Asset_Controller.upsertAsset';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getRecordTypeIdByObject from '@salesforce/apex/Aswata_Add_New_Asset_Controller.getRecordTypeIdByObject';
import { getRecord } from 'lightning/uiRecordApi';
import COB_FIELD from '@salesforce/schema/Opportunity.COB__c';
import NUMBER_OF_RISK from '@salesforce/schema/Opportunity.Number_Of_Risk__c';
import CLOSING_TYPE from '@salesforce/schema/Opportunity.Policy_Closing_Type__c';

import { CloseActionScreenEvent } from 'lightning/actions';

//const HARDCODED_RT_ID = '012MS000000BcI5YAK';
export default class AddNewRisk extends LightningElement {

    @api objectName = 'Asset';
    @api cobValue;
    @api cobLabel;
    @api recordId;
    @api noRisk;
    @api closingType;

    @track addressDescription = '';
    @track formData = {};
    @track fields = [];
    @track recordTypeId;
    @track picklistValues;
    @track activeFieldData;
    
    provinceId;
    cityId;

    //Fetch Risk Record Type on component init
    connectedCallback() {
        this.fetchRiskRecordType();
    }

    //SIMPLIFIED: Only pass objectName (DeveloperName is always "Risk")
    fetchRiskRecordType() {
        console.log('🎯 [STEP 1/4] Fetching Risk RecordTypeId for:', this.objectName);
        
        getRecordTypeIdByObject({ 
            objectName: this.objectName 
        })
        .then(result => {
            if (result) {
                this.recordTypeId = result;
                console.log('Risk RecordTypeId fetched:', this.recordTypeId);
            } else {
                console.error('Risk Record Type not found for:', this.objectName);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Risk Record Type not found',
                        variant: 'error'
                    })
                );
            }
        })
        .catch(error => {
            console.error('Error fetching Risk RecordTypeId:', error);
            console.error('Error details:', error.body?.message);
        });
    }

    @wire(getRecord, { recordId: '$recordId', fields: [COB_FIELD, NUMBER_OF_RISK,CLOSING_TYPE] })
    wiredOpportunity({ error, data }) {
        if (data) {
            this.cobValue = data.fields.COB__c.value;
            this.cobLabel = data.fields.COB__c.displayValue;
            this.noRisk = data.fields.Number_Of_Risk__c.value;
            this.closingType = data.fields.Policy_Closing_Type__c.value;
            this.formData = {
                ...this.formData,
                //COB__c: this.cobValue,
                Opportunity__c: this.recordId
            };
        } else if (error) {
            console.error('❌ Error fetching Opportunity:', error);
        }
    }

    /*@wire(getAssetCountByOpportunity, { oppId: '$recordId' })
    wiredAssetCount({ error, data }) {
        if (data !== undefined) {
            console.log('📊 Existing Asset count:', data, ' vs noRisk:', this.noRisk);
            if (this.noRisk !== undefined && data >= this.noRisk) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: `This Opportunity already has ${data} Asset(s). Allowed Number of Risk is ${this.noRisk}.`,
                        variant: 'error'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            }
        } else if (error) {
            console.error('❌ Error fetching asset count:', error);
        }
    }*/
    
     // ⚡ Get recordTypeId dynamically based on COB
    // @wire(getRecordTypeIdByCob, { objectName: '$objectName', cobValue: '$cobLabel' })
    // wiredRtId({ error, data }) {
    //     if (data) {
    //         this.recordTypeId = data;
    //         console.log('✅ RecordTypeId from COB:', this.recordTypeId);
    //     } else if (error) {
    //         console.error('❌ Error fetching RecordTypeId:', error);
    //     }
    // }
     
    @wire(getPicklistValuesByRecordType, {
        objectApiName: '$objectName',
        recordTypeId: '$recordTypeId'
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.picklistValues = data;
            console.log('Available fields:', Object.keys(data.picklistFieldValues || {}).join(', '));
            
            if (this.activeFieldData) {
                this.buildFields();
            }
        } else if (error) {
            console.error('Error loading picklist metadata:', error);
        }
    }

    @wire(getActiveFields, { objectName: '$objectName', interestCob: '$cobValue', contractType: '$closingType' })
    wiredFields({ error, data }) {
        if (data) {
            this.activeFieldData = data;
            this.buildFields();
        } else if (error) {
            console.error('Error loading fields:', error);
        }
    }

    buildFields() {
        if (!this.activeFieldData) {
            return;
        }
        
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
                isText: typeData === 'text',
                isReadonly: typeData ==='readonly',
                isNumber: typeData === 'number',
                isLookup: typeData === 'lookup',
                isTextArea: typeData === 'textarea',
                isPicklist: typeData === 'picklist',
                isGeolocation: typeData === 'geolocation',
                isAddress: (f.filter || '').toLowerCase() === 'address',
                
                value: (this.formData && this.formData[f.apiName] !== undefined)
                    ? this.formData[f.apiName]
                    : null
            };

            if (fieldObj.isPicklist) {
                if (this.picklistValues?.picklistFieldValues?.[fieldObj.apiName]) {
                    const picklistMeta = this.picklistValues.picklistFieldValues[fieldObj.apiName];
                    fieldObj.options = picklistMeta.values.map(v => ({ 
                        label: v.label, 
                        value: v.value 
                    }));
                    console.log(`${fieldObj.apiName}: ${fieldObj.options.length} options`);
                } else {
                    fieldObj.options = [];
                }
            } else {
                fieldObj.options = [];
            }

            if (typeData === 'geolocation') {
                fieldObj.isGeolocation = true;
                const baseName = f.apiName.replace('__c','');
                fieldObj.latitudeName = `${baseName}__Latitude__s`;
                fieldObj.longitudeName = `${baseName}__Longitude__s`;
                fieldObj.latitudeLabel = `${f.label} (Latitude)`;
                fieldObj.longitudeLabel = `${f.label} (Longitude)`;

                fieldObj.latitude = this.formData?.[fieldObj.latitudeName] || null;
                fieldObj.longitude = this.formData?.[fieldObj.longitudeName] || null;
            }

            return fieldObj;
        });

        this.fields.sort((a, b) => (a.order || 0) - (b.order || 0));
        console.log('Fields built:', this.fields.length, 'total');
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

            if (fieldName.endsWith('__Latitude__s')) {
                if (value !== null && (value < -90 || value > 90)) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Latitude must be between -90 and 90',
                            variant: 'error'
                        })
                    );
                    return;
                }
            }

            if (fieldName.endsWith('__Longitude__s')) {
                if (value !== null && (value < -180 || value > 180)) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Longitude must be between -180 and 180',
                            variant: 'error'
                        })
                    );
                    return;
                }
            }

            this.formData = {
                ...this.formData,
                [fieldName]: value
            };

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

        this.formData = {
            ...this.formData,
            [fieldApiName]: null
        };

        this.fields = this.fields.map(f => {
            if (f.apiName === fieldApiName) {
                return { ...f, value: null };
            }
            return f;
        });

        if (fieldApiName === 'Province__c') {
            this.provinceId = null;
        }
        if (fieldApiName === 'City__c') {
            this.cityId = null;
        }
        if (fieldApiName === 'Address__c') {
            this.addressDescription = null;
            this.formData = {
                ...this.formData,
                Address_Description__c: null
            };
        }

        const possibleFieldMapKeys = this.fields
            .filter(f => f.apiName !== fieldApiName)
            .map(f => f.apiName);

        possibleFieldMapKeys.forEach(apiName => {
            if (this.formData.hasOwnProperty(apiName)) {
                this.formData[apiName] = null;
            }
        });

        this.fields = this.fields.map(f => ({
            ...f,
            value: this.formData[f.apiName] || null
        }));
    }

    handleSaveAsset() {
        upsertAsset({ fieldValues: this.formData })
            .then(resultId => {
                console.log('Asset saved! Id:', resultId);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Asset saved successfully',
                        variant: 'success'
                    })
                );
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('Error saving Asset:', error);
                const errorMessage = error?.body?.message || error.message || 'Unknown error';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Failed to save Asset: ' + errorMessage,
                        variant: 'error'
                    })
                );
            });
    }

    handleCloseAssetModal(){
        this.formData = {};
        this.fields = this.fields.map(f => {
            return { ...f, value: null };
        });
        this.dispatchEvent(new CloseActionScreenEvent());
    }   
}