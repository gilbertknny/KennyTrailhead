import { LightningElement, api, track, wire } from 'lwc';
import searchRecords from '@salesforce/apex/customLookup_Controller.searchRecords';
import getRecordById from '@salesforce/apex/customLookup_Controller.getRecordById';

export default class CustomLookup extends LightningElement {
    @api label;
    @api placeholder = 'Search...';
    @api objectApiName;
    @api provinceId;
    @api cityId;
    @api fields; // fields to query
    @api iconName = 'standard:record';
    @api sectionName;
    @api recordTypeName; 
    @track searchKey = '';
    @track results = [];
    @track isDropdownOpen = false;
    @track selectedRecord;
    @api displayText;
    @api showData; 
    @api cobField; 
    @api readOnly = false;

    _recordId;
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        console.log('recordId setter triggered: ', value, this.recordTypeName , this.displayText);
        if (value  && value !== '') {
            this.loadRecord(value, this.recordTypeName);
        } else if (this.displayText) {
        // show plain text if provided
            this.selectedRecord = { Id: null, Name: this.displayText };
        } 
        else {
            this.selectedRecord = null;
        }
    }

    get comboboxClass() {
        return 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ' +
            (this.isDropdownOpen ? 'slds-is-open' : '');
    }

    handleInputChange(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length >= 2) {
            console.log('Custom Lookup field: ' + this.fields);
            console.log('cityId: ' + this.cityId);
            console.log('provinceId: ' + this.provinceId);
            console.log('sectionName: ' + this.sectionName);
            console.log('CL.showData: ' + this.showData);
            console.log('COB: ' + this.cobField);
            searchRecords({ 
                objectApiName: this.objectApiName, 
                fields: this.fields, 
                searchKey: this.searchKey, 
                recordTypeName: this.recordTypeName, 
                provinceId: this.provinceId, 
                cityId: this.cityId, 
                sectionName: this.sectionName, 
                showData: this.showData,
                cobId:this.cobField
            })
                .then(data => {
                    this.results = data.map(rec => ({
                        Id: rec.Id,
                        Name: rec.Name,
                        Subtitle: rec.Subtitle,
                        FieldMap: rec.fieldMap
                    }));
                })
                .catch(error => {
                    console.error('Lookup error:', error);
                });
        } else {
            this.results = [];
        }
    }

    openDropdown() {
        if (!this.selectedRecord) {
            this.isDropdownOpen = true;
        }
    }

    selectRecord(event) {
        const id = event.currentTarget.dataset.id;

        const record = this.results.find(r => r.Id === id);

        this.isDropdownOpen = false;
        this.selectedRecord = record;

        this.dispatchEvent(new CustomEvent('recordselected', {
            //detail: { id, name, subtitle, fieldMap }
            detail: record
        }));
    }

    clearSelection() {
        this.selectedRecord = null;
        this.searchKey = '';
        this.results = [];
        this._recordId = null;

        this.dispatchEvent(new CustomEvent('recordcleared', {
            detail: {
                id: null,
                name: null,
                subtitle: null,
                fieldMap: null
            },
            bubbles: true,
            composed: true
        }));
    }

    get showNoResults() {
        console.log('showNoResults: ' + this.searchKey.length + ' ' + this.results.length);
        return this.searchKey.length >= 2 && this.results.length === 0;
    }

    connectedCallback() {
        console.log('this.recordId customLookup: ' + this.recordId + ' : ' + this.recordTypeName);
        if (!this.recordId && this.displayText) {
            this.searchKey = this.displayText;
        }

        if (this.recordId) {
            this.loadRecord(this.recordId, this.recordTypeName);
        }
    }

    renderedCallback() {
        if (this.recordId && this.recordId !== '' && (!this.selectedRecord || this.selectedRecord.Id !== this.recordId)) {
            this.loadRecord(this.recordId, this.recordTypeName);
        }
    }

    loadRecord(recordId, recordTypeName) {
        getRecordById({
            objectApiName: this.objectApiName,
            recordId: recordId,
            recordTypeName: recordTypeName,
            displayText: this.displayText
        })
            .then(rec => {
                if (rec) {
                    this.selectedRecord = { Id: rec.Id, Name: rec.Name };
                }
            })
            .catch(err => {
                console.error('Error loading record by Id:', err);
            });
    }
}