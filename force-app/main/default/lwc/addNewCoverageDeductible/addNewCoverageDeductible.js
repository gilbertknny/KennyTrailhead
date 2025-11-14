import { LightningElement, api, track, wire  } from 'lwc';
import getDeductiblePicklistValues from '@salesforce/apex/Aswata_Coverage_Data_Handler.getDeductiblePicklistValues';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class AddNewCoverageDeductible extends LightningElement {
    //
    selectedCurrency = 'IDR';
    @track deductibleData;
    @track currencyOptions;
    @api jsonString = '';
    @api descriptionDeductible = '';
    @track coverageData = [];
    @track coverageDataTemp = [ ];
    @track selectedMode = 'BREAKDOWN_DEDUCTIBLE';
    @track exchangeRate = 1;
    @track disableModeCoverage = false;
    @api buttonClickedValue;
    get modeOptions() {
        return [
            { label: 'Breakdown', value: 'BREAKDOWN_DEDUCTIBLE' },
            { label: 'Composite', value: 'COMPOSITE' }
        ];
    }
    get isModeBreakdown() {
        return this.selectedMode === 'BREAKDOWN_DEDUCTIBLE';
    }
    handleModeChange(event) {
        this.selectedMode = event.detail.value;
        this.applyDisableLogic('CHANGE');
        console.log('Mode diubah menjadi:', this.selectedMode);
    }
    applyDisableLogic(event) {
        const isCompositeMode = (this.selectedMode === 'COMPOSITE');
        const sourceRow = this.coverageData.find(row => row.id === 'SINGLE_RATE_ID');
        const sourceDeductibleSetting = sourceRow?.deductible?.deductibleSetting || 'Flat'; 
        this.coverageData = this.coverageData.map(row => {
            let updatedItem = { ...row };
            const isSingleRateRow = (row.id === 'SINGLE_RATE_ID');
            let updatedDeductible = { ...row.deductible }; 
            if (isCompositeMode) {
                updatedItem.compositeDisable = !isSingleRateRow; 
                updatedItem.ddtibleSetting = 'COMPOSITE';
                // if (!isSingleRateRow) {
                if(row.id !== 'SINGLE_RATE_ID'){
                    updatedItem.deductibleAmount= null;
                    updatedItem.deductibleFlag= null;
                    updatedItem.currencyId= null;
                    updatedItem.Currency__c= null;
                    updatedItem.Exchange_Rate__c= null;
                    updatedItem.minimumAmount= null;
                    // updatedItem.descriptionValue= null;
                    const setting = sourceDeductibleSetting;
                    updatedDeductible = {
                        ...updatedDeductible,
                        deductibleSetting: setting,
                    };
                    if (event === 'CHANGE') {
                        console.log('Composite Mode - Resetting Detail Rows');
                        updatedDeductible = {
                            ...updatedDeductible,
                            deductibleSetting: 'Flat',
                            deductibleAmount: null,
                            deductibleFlag: null,
                            minimumAmount: null,
                        };
                    }
                }
            } 
            
            else {
                updatedItem.ddtibleSetting = 'BREAKDOWN_DEDUCTIBLE';
                updatedItem.compositeDisable = isSingleRateRow;
                if(row.id == 'SINGLE_RATE_ID'){
                    if (event === 'CHANGE') {
                        updatedItem.deductibleAmount= null;
                        updatedItem.deductibleFlag= null;
                        updatedItem.currencyId= null;
                        updatedItem.Currency__c= null;
                        updatedItem.Exchange_Rate__c= null;
                        updatedItem.minimumAmount= null;
                        // updatedItem.descriptionValue= null;
                        updatedItem.deductibleSetting= 'Flat';
                        console.log('Breakdown/Single Mode - Resetting Single Rate Row');
                        updatedDeductible = {
                            ...updatedDeductible,
                            deductibleSetting: 'Flat',
                            deductibleAmount: null,
                            deductibleFlag: null,
                            minimumAmount: null,
                            descriptionValue: null,
                        };                    
                        updatedItem.currencyId = null;    
                    }
                }
            }
            updatedItem.deductible = updatedDeductible;

            return updatedItem;
        });
        
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Data updated successfully.', this.jsonString);
    }
    handleLookUpSelected(event) {
        const rowId = event.target.dataset.id;
        const isCompositeMode = (this.selectedMode == 'COMPOSITE');
        // const sourceRow = this.coverageData.find(row => row.id == 'SINGLE_RATE_ID');
        const fieldApiName = event.target.dataset.field;   // 👈 from data-field in HTML
        console.log('currency: ', JSON.stringify(event.detail));
        
        const recordName = event.detail.Name;
        const recordSubtitle = event.detail.Subtitle;
        const recordId = event.detail.Id;
        // const value = event.detail.value;
        console.log('recordSubtitle: ' + recordSubtitle + ' fieldApiName: ' + fieldApiName);
        this.coverageData = this.coverageData.map(row => {
            let updatedItem = { ...row };
            if(isCompositeMode && rowId == 'SINGLE_RATE_ID'){
                console.log('Composite Mode');
                if (row.id === rowId) {
                    updatedItem = {
                        ...updatedItem, 
                        currencyId: recordId,
                        Currency__c: recordName,
                        Exchange_Rate__c : recordSubtitle,
                        deductible : {
                            ...updatedItem.deductible,
                            currencyId: recordId
                        }
                    };
                }
            }else{
                console.log('Breakdown Mode',rowId);
                if (row.id === rowId) {
                    updatedItem = {
                        ...updatedItem, 
                        currencyId: recordId,
                        Currency__c: recordName,
                        Exchange_Rate__c : recordSubtitle,
                        deductible : {
                            ...updatedItem.deductible,
                            currencyId: recordId
                        }
                    };
                }
            }
            return updatedItem;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Lookup updated successfully.',this.jsonString);
    }
    handleLookUpCleared(event) {
        const rowId = event.target.dataset.id;
        const isCompositeMode = (this.selectedMode == 'COMPOSITE');
        // const sourceRow = this.coverageData.find(row => row.id == 'SINGLE_RATE_ID');
        // const fieldApiName = event.target.dataset.field;   // 👈 from data-field in HTML
        // console.log('currency: ', JSON.stringify(event.detail));
        
        this.coverageData = this.coverageData.map(row => {
            let updatedItem = { ...row };
            if(isCompositeMode){
                console.log('Composite Mode');
                updatedItem = {
                    ...updatedItem, 
                    currencyId: null,
                    Currency__c: null,
                    Exchange_Rate__c : null,
                    deductible : {
                        ...updatedItem.deductible,
                        currencyId: null
                    }
                };
            }else{
                console.log('Breakdown Mode',rowId);
                if (row.id === rowId) {
                    updatedItem = {
                        ...updatedItem, 
                        currencyId: null,
                        Currency__c: null,
                        Exchange_Rate__c : null,
                        deductible : {
                            ...updatedItem.deductible,
                            currencyId: null
                        }
                    };
                }
            }
            return updatedItem;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('📝 formData clearance :',this.jsonString);

        // const fieldApiName = event.target.dataset.field;
        // this.dynamicFieldShow1 = false;
        // this.dynamicFieldShow2 = false;
        // this.dynamicFieldShow3 = false;
        // this.formData = {
        //     ...this.formData,
        //     [fieldApiName]: null
        // };
        // console.log('📝 formData clearance:', JSON.stringify(this.formData));
    }
    @wire(getDeductiblePicklistValues)
    deductiblePicklist({ error, data }) {
        if (data) {
            this.deductibleData = data.deductibleOptions;
            this.currencyOptions = data.currencyOptions;
            this.error = undefined;
            console.log('Deductible Picklist Options from Apex:', this.deductibleData);
            this.initializeCoverageData();
        } else if (error) {
            this.deductibleData = undefined;
            console.error('Error fetching picklist values from Apex:', error);
        }
    }
    initializeCoverageData() {
        if (this.jsonString) {
            let parsedData = JSON.parse(this.jsonString);
            this.descriptionDeductible = parsedData[0].deductible.descriptionDeductible;
            console.log('this.descriptionDeductible',this.descriptionDeductible);
            
            this.selectedMode = parsedData[0].coverageSetting ? parsedData[0].coverageSetting:'BREAKDOWN_DEDUCTIBLE';
            // this.disableModeCoverage = parsedData[0].disableModeCoverage;
            this.coverageData = parsedData.map(row => {
                const setting = row.deductibleSetting;
                const shouldBeDisabled = (row.id === 'SINGLE_RATE_ID');
                return { 
                    ...row, 
                    ddtibleSetting: this.selectedMode,
                    compositeDisable: shouldBeDisabled,
                    deductibleSetting: setting,
                    // deductibleAmount:row.deductibleAmount,
                    // deductibleFlag:row.deductibleFlag,
                    // currencyName: this.selectedCurrency,
                    deductible : {
                        ...row.deductible,
                        currencyName: row.deductible.currencyName?row.deductible.currencyName: this.selectedCurrency,
                    },
                    get isFlat() {
                        return setting === 'Flat';
                    },
                    get isPercent() {
                        return setting === 'Percentage';
                    }
                };
            });
            this.jsonString = JSON.stringify(this.coverageData);
            this.coverageDataTemp = JSON.parse(this.jsonString);
            this.applyDisableLogic(null);
            console.log('✅ InitializeDeductibleData:', this.jsonString);
        } else {
            console.log('Waiting for all required data (picklist or json) to initialize.');
        }
    }
    get deductFlag() {
        return this.deductibleData;
    }
    get currencyPicklist() {
        return this.currencyOptions;
    }
    get options() {
        return [
            { label: 'Select an Option', value: '' }, 
            { label: 'Amount', value: 'Flat' },
            { label: 'Percentage', value: 'Percentage' },
        ];
    }

    handleChange(event) {
        const rowId = event.target.dataset.id;
        const fieldName = event.target.name;
        const value = event.detail.value;
        console.log(`Perubahan di Baris ID: ${rowId}, Field: ${fieldName}, Nilai: ${value}`);
        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                let updatedItem = { ...item, 
                    // [fieldName]: value,
                    deductible : {
                        ...item.deductible,
                        [fieldName]: value,
                    }
                };
                if (fieldName === 'deductibleSetting') {
                    const isFlatSelected = (value === 'Flat');
                    const isPercentSelected = (value === 'Percentage');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting: value,
                        isFlat: isFlatSelected,
                        isPercent: isPercentSelected,
                        deductible : {
                            ...updatedItem.deductible,
                            deductibleSetting: value,
                        }
                    };
                }
                
                return updatedItem;
            }
            return item;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }

    handleChangeSingle(event) {
        const rowId = event.target.dataset.id;
        const fieldName = event.target.name;
        const value = event.detail.value;
        console.log(`Perubahan di Baris ID: ${rowId}, Field: ${fieldName}, Nilai: ${value}`);
        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                let updatedItem = { 
                    ...item, 
                    // [fieldName]: value,
                    deductible : {
                        ...item.deductible,
                        [fieldName]: value,
                    }
                };
                if (fieldName === 'deductibleSetting') {
                    const isFlatSelected = (value === 'Flat');
                    const isPercentSelected = (value === 'Percentage');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting: value,
                        isFlat: isFlatSelected,
                        isPercent: isPercentSelected,
                        deductible : {
                            ...updatedItem.deductible,
                            deductibleSetting: value,
                        }
                    };
                }
                
                return updatedItem;
            }
            return item;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    handleChangeDesc(event) {
        const newValue = event.detail.value;
        this.descriptionDeductible = newValue;
        this.coverageData = this.coverageData.map(item => {
            let updatedItem = { 
                ...item,
                deductible : {
                    ...item.deductible,
                    descriptionDeductible: newValue,
                }
            };
            updatedItem.deductible = updatedDeductible;
            return updatedItem;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
    }
    handleChangeDescSingle(event) {
        const newValue = event.detail.value;
        const isDescriptionEmpty = !newValue && newValue.trim() === '';
        this.descriptionDeductible = newValue;
        console.log('Change descriptionDeductible: ',this.descriptionDeductible , isDescriptionEmpty);
        let newCompositeDisableStatus = false;
        if(this.selectedMode == 'COMPOSITE'){
            newCompositeDisableStatus = true;
        }

        this.coverageData = this.coverageData.map(item => {
            let updatedItem = { 
                ...item,
                deductible : {
                    ...item.deductible,
                    descriptionDeductible: newValue,
                }
            };
            if (item.id === 'SINGLE_RATE_ID') {
                updatedItem.compositeDisable = !isDescriptionEmpty;
            }
            return updatedItem;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
    }
    handleInputChange(event) {
        console.log('Change Data from Flow:');
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const value = event.detail.value;

        const textFields = ['descriptionValue'];

        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                if (textFields.includes(fieldName)){
                    return { 
                        ...item, 
                        [fieldName]: value,
                        deductible  : {
                            ...item.deductible,
                            [fieldName]: value,   
                        }
                    };
                }
                return { 
                    ...item, 
                    [fieldName]: Number(value),
                    deductible  : {
                        ...item.deductible,
                        [fieldName]: Number(value),
                    }
                };
            }
            return item;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    
    handleInputChangeSingle(event) {
        console.log('Change Data Single Composite:');
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const value = event.detail.value;

        const textFields = ['descriptionValue'];
        
        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                if (textFields.includes(fieldName)){
                    return { 
                        ...item, 
                        [fieldName]: value,
                        deductible  : {
                            ...item.deductible,
                            [fieldName]: value,   
                        }
                    };
                }
                return { 
                    ...item, 
                    [fieldName]: Number(value),
                    deductible  : {
                        ...item.deductible,
                        [fieldName]: Number(value),
                    }
                };
            }
            return item;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }

    logFinalData() {
        let finalData = this.coverageData.filter(item => {
            return item.id !== 'SINGLE_RATE_ID' && item.isSelected;;
        });
        console.log('Log Final:', JSON.stringify(finalData));
    }
    handleNumericKeyDown(event) {
        const key = event.key;
        const value = event.target.value;
        const allowedControlKeys = [
            'Backspace', 'Delete', 'Tab', 'Escape', 'Enter', 'ArrowLeft', 'ArrowRight'
        ];
        if (allowedControlKeys.includes(key)) {
            return;
        }

        if (/[0-9]/.test(key)) {
            return;
        }

        if ((key === '.') && !value.includes('.')) {
            return;
        }
        
        event.preventDefault();
    }
    handleNext() {
        let validationResult = [];
        if(this.isModeBreakdown){
            validationResult = this.coverageData.filter(item => {
                return (item.id != 'SINGLE_RATE_ID' && item.deductible.deductibleSetting == null)
                || (item.id != 'SINGLE_RATE_ID' && (item.isPercent && item.deductible.deductibleFlag == null));
            });
        }else{
            validationResult = this.coverageData.filter(item => {
                return (item.id == 'SINGLE_RATE_ID' && item.deductible.deductibleSetting == null)
                || item.id == 'SINGLE_RATE_ID' && (item.isPercent && item.deductible.deductibleFlag == null);
            });
        }
        if(validationResult.length > 0){
            this.showToast('Error', 'Please Select Type and Applied to/ of for type Percentage', 'error');
            return;
        }else{
            this.showValidationMessage = false;
            this.buttonClickedValue = 'Next';
            const attributeChangeEvent = new FlowAttributeChangeEvent('buttonClickedValue', this.buttonClickedValue);
            this.dispatchEvent(attributeChangeEvent);
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    handlePrevious() {
        this.buttonClickedValue = 'Previous';
        const attributeChangeEvent = new FlowAttributeChangeEvent('buttonClickedValue', this.buttonClickedValue);
        this.dispatchEvent(attributeChangeEvent);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}