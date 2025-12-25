import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class CustomPathQuotation extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api fieldApiName;

    @track steps = [];
    currentStep = '';
    recordTypeId;

    iconMap = {
        "Waiting for Approval": "action:user_activation",
        "Approve On Hold Binding": "action:new_custom95",
        "Binding": "action:upload",
        "Contra Quote": "action:recall",
        "Cancel": "action:back",
        "Approved": "action:approval",
        "Rejected": "action:close",
        "Draft": "action:preview",
        "Waiting KYC Approval": "action:new_custom77",
        "Closed Won": "action:following"
    };

    /* -------------------------------------------------------
       1️⃣ GET OBJECT INFO (recordTypeId)
       ------------------------------------------------------- */
    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    objectInfoHandler({ data, error }) {
        if (data) {
            this.recordTypeId = data.defaultRecordTypeId;
            console.log('RecordTypeId →', this.recordTypeId);
        }
        if (error) {
            console.error('Error getObjectInfo', error);
        }
    }

    /* -------------------------------------------------------
       2️⃣ GET PICKLIST VALUES (dynamic field)
       ------------------------------------------------------- */
    @wire(getPicklistValues, { 
        recordTypeId: '$recordTypeId',
        fieldApiName: '$normalizedFieldApi'
    })
    picklistHandler({ data, error }) {
        if (data) {
            console.log('Picklist values → ', data.values);

            this.steps = data.values.map(v => ({
                label: v.label,
                value: v.value,
                icon: this.iconMap[v.value] || this.iconMap.Default
            }));
        }

        if (error) {
            console.error('Picklist error →', error);
        }
    }

    /* Normalize dynamic field name for UI API */
    get normalizedFieldApi() {
        if (!this.objectApiName || !this.fieldApiName) {
            return null;
        }
        return `${this.objectApiName}.${this.fieldApiName}`;
    }

    /* -------------------------------------------------------
       3️⃣ GET CURRENT RECORD VALUE OF THE PICKLIST
       ------------------------------------------------------- */
    @wire(getRecord, { 
        recordId: '$recordId',
        fields: '$computedField'
    })
    recordHandler({ data, error }) {
        if (data) {
            this.currentStep = getFieldValue(data, this.normalizedFieldApi);
            console.log('Current Step →', this.currentStep);
        }
        if (error) {
            console.error('Record error →', error);
        }
    }

    get computedField() {
        if (!this.normalizedFieldApi) {
            return [];
        }
        return [this.normalizedFieldApi];
    }

    /* -------------------------------------------------------
       Path UI Logic
       ------------------------------------------------------- */
    get computedSteps() {
        return this.steps.map(step => {
            const isActive = step.value === this.currentStep;

            return {
                ...step,
                variant: isActive ? "brand" : "default",
                combinedBoxClass: `icon-box ${isActive ? "active-box" : "inactive-box"}`
            };
        });
    }

    renderedCallback() {
        console.log("🔹 Component Loaded");
        console.log("recordId →", this.recordId);
        console.log("objectApiName →", this.objectApiName);
        console.log("fieldApiName →", this.fieldApiName);
    }
}