import { LightningElement, wire, api, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import picklistValues from '@salesforce/apex/ClsInput.picklistValues';

export default class Input extends LightningElement {
    @api objectApiName;
    @api fieldName;
    @api fieldType;
    @api fieldLabel;
    @api fieldLookup;
    @api fieldFilter;
    @api fieldRequired;
    @api fieldValue;
    @api mapInput;
    @track showPicklist;
    @track showAddress;
    @track showGeolocation;
    @track showInput;
    @track showLookup;
    @track showTextArea;
    @track options;
    @track filter = {};

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfo;

    dataTypeMapping = {
        String: 'text',
        Currency: 'number',
        Double: 'number',
        DateTime: 'datetime',
        Phone: 'phone',
        Boolean: 'checkbox',
        Url: 'url',
        Date: 'date',
        Int: 'number',
        Number: 'number'
    }

    @track displayInfo = {
        primaryField: 'Name',
        additionalFields: ['Additional__c'],
    };

    @track matchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'contains' },
        additionalFields: [{ fieldPath: 'Additional__c' }],
    };

    @api setFilter(recordId){
        //console.log('setFilter:'+recordId);
        //console.log('fieldName:'+this.fieldName);
        this.filter = {
            criteria: [
                { fieldPath: 'RecordType.Name',operator: 'eq',value: this.fieldFilter },
                { fieldPath: 'ADDRESS_ID__c',operator: 'eq',value: recordId },
            ],
            filterLogic: '1 AND 2'
        };
    }

    @api getName(){
        return this.fieldName;
    }

    @api clearLookup(){
        const myPicker = this.refs.myPicker;
        myPicker.clearSelection();

        this.filter = {
            criteria: [
                { fieldPath: 'RecordType.Name',operator: 'eq',value: this.fieldFilter },
            ],
            filterLogic: '1'
        }; 
    }
    
    renderedCallback() {
        //console.log('renderedCallback');
        //console.log('this.fieldName:'+this.fieldName);
        //console.log('this.fieldLabel:'+this.fieldLabel);
        //console.log('this.fieldType:'+this.fieldType);
        //console.log('this.fieldLookup:'+this.fieldLookup);
        //console.log('objectApiName:'+this.objectApiName);
        if(this.fieldValue == '' && this.fieldType == 'Lookup'){
            const myPicker = this.refs.myPicker;
            myPicker.clearSelection();
        }
    }

    connectedCallback() {
        //console.log('this.fieldName:'+this.fieldName);
        //console.log('this.fieldLabel:'+this.fieldLabel);
        //console.log('connectedCallback');
        this.onload();
    }

    onload(){
        this.showInput = false;
        this.showPicklist = false;
        this.showAddress = false;
        this.showGeolocation = false;
        this.showLookup = false;
        this.showTextArea = false;
        if(this.fieldType == 'Text'){
            this.showInput = true;
        }else if(this.fieldType == 'Picklist'){
            this.showPicklist = true;
            this.getPicklist();
        }else if(this.fieldType == 'Address'){
            this.showAddress = true;
        }else if(this.fieldType == 'Geolocation'){
            this.showGeolocation = true;
        }else if(this.fieldType == 'Lookup'){
            this.showLookup = true;
            if(this.fieldLookup == 'Location'){
                this.filter = {
                    criteria: [
                        { fieldPath: 'LocationType',operator: 'eq',value: this.fieldFilter },
                    ],
                    filterLogic: '1'
                };
            }else if(this.fieldLookup == 'Master_Data__c'){
                this.filter = {
                    criteria: [
                        { fieldPath: 'RecordType.Name',operator: 'eq',value: this.fieldFilter },
                    ],
                    filterLogic: '1'
                };             
            }
        }else if(this.fieldType == 'TextArea'){
            this.showTextArea = true;   
        }else{
            this.showInput = true;
        }
        if(this.fieldName != undefined) this.mapInput.set(this.fieldName, '');
    }

    get fieldInfo() {
        if (this.objectInfo && this.objectInfo.data && this.objectInfo.data.fields) {
            let field = this.objectInfo.data.fields[this.fieldName];
            field = JSON.parse(JSON.stringify(field));
            field.dataType = this.dataTypeMapping[this.fieldType];
            if(this.fieldLabel != undefined && this.fieldLabel != '') field.label = this.fieldLabel;
            if(this.fieldRequired != undefined) field.required = this.fieldRequired;
            if(this.fieldType == 'Readonly'){
                field.required = false;
                field.disabled = true;
            }
            return field;
        }
        return {};
    }

    getPicklist(){
        picklistValues({
            objectName: this.objectApiName,
            fieldName: this.fieldName
        })
        .then(result => {
            this.options = [];
            for (var key in result) {
                this.options.push({label:result[key], value:key});
            }
            return this.options;
        })
        .catch(error => {
            console.log('error-getPicklist:'+ error.message);
        });
    }

    handleChange(event) {
        let value;
        if (event.target.type === 'checkbox' || event.target.type === 'checkbox-button' || event.target.type === 'toggle') {
            value = event.target.checked;
        } else {
            value = event.target.value;
        }
        this.dispatchEvent(new CustomEvent('change', { detail: value }));
        if(this.fieldName != undefined) this.mapInput.set(this.fieldName, value);
        //console.log('map:'+this.mapInput.get(this.fieldName));
    }

    handleChangeTextArea(event) {
        let value = event.target.value;
        this.dispatchEvent(new CustomEvent('change', { detail: value }));
        if(this.fieldName != undefined) this.mapInput.set(this.fieldName, value);
    }

    handleAddressSelect(event) {
        let value;
        const address = event.detail;
        const address1 = {
            street: address.street,
            city: address.city,
            state: address.state,
            postalCode: address.postalCode,
            country: address.country
        };
        //console.log('address:'+JSON.stringify(address1));
        value = JSON.stringify(address1);
        this.dispatchEvent(new CustomEvent('change', { detail: value }));
        if(this.fieldName != undefined) this.mapInput.set(this.fieldName, value);
    }
    
    handleGeolocation(event){
        let value = event.detail;
        const location = {
            latitude: value.latitude,
            longitude: value.longitude
        };
        value = JSON.stringify(location);
        this.dispatchEvent(new CustomEvent('change', { detail: value }));
        if(this.fieldName != undefined) this.mapInput.set(this.fieldName, value);
    }

    /*handleLookup(event){
        //console.log('handleLookup:');
        if(event.detail != undefined){
            let value = event.detail.Id;
            //console.log('value:'+value);
            if(this.fieldName != undefined) this.mapInput.set(this.fieldName, value);
            this.dispatchEvent(new CustomEvent('change', { detail: value }));     
        }else{
            //console.log('delete');
            if(this.fieldName != undefined) this.mapInput.delete(this.fieldName);
            this.dispatchEvent(new CustomEvent('change', { detail: '' }));
        }
    }*/

    handleChangeLookup(event){
        let value = event.detail.recordId;
        //console.log('value:'+value);
        if(value == null || value == undefined){
            if(this.fieldName != undefined) this.mapInput.set(this.fieldName, '');
            this.dispatchEvent(new CustomEvent('change', { detail: '' }));
        }else{
            if(this.fieldName != undefined) this.mapInput.set(this.fieldName, value);
            this.dispatchEvent(new CustomEvent('change', { detail: value }));     
        }
    }
}