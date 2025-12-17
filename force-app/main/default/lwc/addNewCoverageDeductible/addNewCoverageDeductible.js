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
    @track coverageDataFormated = [];
    @track selectedMode = 'BREAKDOWN_DEDUCTIBLE';
    @track exchangeRate = 1;
    @track disableModeCoverage = false;
    @api buttonClickedValue;
    @track hasSection1 = false;
    @track hasSection2 = false;
    @track hasSection3 = false;
    @track hasSection4 = false;
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
    setSectionAsset(sectionList){
        this.hasSection1 = sectionList.includes(1);
        this.hasSection2 = sectionList.includes(2);
        this.hasSection3 = sectionList.includes(3);
        this.hasSection4 = sectionList.includes(4);
        // console.log('this.hasSection',this.hasSection1);
    }
    initializeCoverageData() {
        if (this.jsonString) {
            let parsedData = JSON.parse(this.jsonString);
            this.descriptionDeductible = parsedData[0].deductible.descriptionDeductible;
            this.setSectionAsset(parsedData[0].sectionList);
            console.log('this.descriptionDeductible',this.descriptionDeductible);

            this.selectedMode = parsedData[0].coverageSetting ? parsedData[0].coverageSetting:'BREAKDOWN_DEDUCTIBLE';
            // this.disableModeCoverage = parsedData[0].disableModeCoverage;
            this.coverageData = parsedData.map(row => {
                const setting = row.deductibleSetting;
                const setting2 = row.deductibleSetting2;
                const setting3 = row.deductibleSetting3;
                const setting4 = row.deductibleSetting4;
                const shouldBeDisabled = (row.id === 'SINGLE_RATE_ID');
                return { 
                    ...row, 
                    ddtibleSetting: this.selectedMode,
                    compositeDisable: shouldBeDisabled,
                    deductibleSetting: setting,
                    deductibleSetting2: setting2,
                    deductibleSetting3: setting3,
                    deductibleSetting4: setting4,
                    // deductibleAmount:row.deductibleAmount,
                    // deductibleFlag:row.deductibleFlag,
                    // currencyName: this.selectedCurrency,
                    deductible : {
                        ...row.deductible,
                        currencyName: row.deductible.currencyName?row.deductible.currencyName: this.selectedCurrency,
                        currencyName2: row.deductible.currencyName2?row.deductible.currencyName2: this.selectedCurrency,
                        currencyName3: row.deductible.currencyName3?row.deductible.currencyName3: this.selectedCurrency,
                        currencyName4: row.deductible.currencyName4?row.deductible.currencyName4: this.selectedCurrency,
                    },
                    get isFlat() { return setting === 'Flat'; },
                    get isFlat2() { return setting2 === 'Flat'; },
                    get isFlat3() { return setting3 === 'Flat'; },
                    get isFlat4() { return setting4 === 'Flat'; },
                    get isPercent() { return setting === 'Percentage';},
                    get isPercent2() { return setting2 === 'Percentage';},
                    get isPercent3() { return setting3 === 'Percentage';},
                    get isPercent4() { return setting4 === 'Percentage';}
                };
            });
            this.jsonString = JSON.stringify(this.coverageData);
            this.applyDisableLogic(null);
            this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
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
    handleInputFocus(event) {
        const rowId = event.target.dataset.id;
        const objectName = event.target.dataset.object;
        const field = event.target.dataset.field;
        const item = this.coverageData.find(i => i.id === rowId);
        if (!item || !item[objectName]) return;
        const rawValue = item[objectName][field];
        const itemIndex = this.coverageDataFormated.findIndex(i => i.id === rowId);
        let updatedFormattedData = [...this.coverageDataFormated];
        let updatedFormattedItem = { ...updatedFormattedData[itemIndex] };
        let updatedFormattedSubObject = { ...updatedFormattedItem[objectName] };
        let displayString = '';
        if (rawValue !== null && rawValue !== undefined) {
            displayString = rawValue.toString();
            displayString = displayString.replace('.', ','); 
        }
        updatedFormattedSubObject[field] = displayString;
        updatedFormattedItem[objectName] = updatedFormattedSubObject;
        updatedFormattedData[itemIndex] = updatedFormattedItem;
        this.coverageDataFormated = updatedFormattedData;
    }
    handleInputBlur(event) {
        const rowId = event.target.dataset.id;
        const objectName = event.target.dataset.object;
        const field = event.target.dataset.field;
        const inputValue = event.target.value;
        const numericValue = this.cleanNumber(inputValue);
        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId || item.id2 === rowId || item.id3 === rowId || item.id4 === rowId) {
                let updatedItem = { ...item };
                let updatedSubObject = { ...updatedItem[objectName] };
                updatedSubObject[field] = numericValue; 
                updatedItem[objectName] = updatedSubObject;
                return updatedItem;
            }
            return item;
        });
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow (Numeric):', this.jsonString);
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
                            minimumAmount: isFlatSelected ? 0 : updatedItem.deductible.minimumAmount
                        }
                    };
                }
                else if (fieldName === 'deductibleSetting2') {
                    const isFlatSelected = (value === 'Flat');
                    const isPercentSelected = (value === 'Percentage');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting2: value,
                        isFlat2: isFlatSelected,
                        isPercent2: isPercentSelected,
                        deductible : {
                            ...updatedItem.deductible,
                            deductibleSetting2: value,
                            minimumAmount2: isFlatSelected ? 0 : updatedItem.deductible.minimumAmount2
                        }
                    };
                }
                else if (fieldName === 'deductibleSetting3') {
                    const isFlatSelected = (value === 'Flat');
                    const isPercentSelected = (value === 'Percentage');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting3: value,
                        isFlat3: isFlatSelected,
                        isPercent3: isPercentSelected,
                        deductible : {
                            ...updatedItem.deductible,
                            deductibleSetting3: value,
                            minimumAmount3: isFlatSelected ? 0 : updatedItem.deductible.minimumAmount3
                        }
                    };
                }
                else if (fieldName === 'deductibleSetting4') {
                    const isFlatSelected = (value === 'Flat');
                    const isPercentSelected = (value === 'Percentage');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting4: value,
                        isFlat4: isFlatSelected,
                        isPercent4: isPercentSelected,
                        deductible : {
                            ...updatedItem.deductible,
                            deductibleSetting4: value,
                            minimumAmount4: isFlatSelected ? 0 : updatedItem.deductible.minimumAmount4
                        }
                    };
                }
                
                return updatedItem;
            }
            return item;
        });
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
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
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
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
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
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
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data change Description:', this.jsonString);
    }
    handleInputChange(event) {
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const value = event.detail.value;
        console.log('Change Data from Flow:',fieldName,value);

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
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
        this.jsonString = JSON.stringify(this.coverageData);
        // console.log('Final Data to Flow:', this.jsonString);
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
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
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
        let validation = true;
        let validationResult = [];
        let percentageResult = [];
        if(this.isModeBreakdown){
            validationResult = this.coverageData.filter(item => {
                return (item.id != 'SINGLE_RATE_ID' && item.deductible.deductibleSetting == null)
                || (item.id != 'SINGLE_RATE_ID' && (item.isPercent && item.deductible.deductibleFlag == null));
            });
            percentageResult = this.coverageData.filter(item => {
                return (item.id != 'SINGLE_RATE_ID' && (item.isPercent && item.deductible.deductibleAmount > 100));
            });
        }else{
            validationResult = this.coverageData.filter(item => {
                return (item.id == 'SINGLE_RATE_ID' && item.deductible.deductibleSetting == null)
                || (item.id == 'SINGLE_RATE_ID' && (item.isPercent && item.deductible.deductibleFlag == null));
            });
            percentageResult = this.coverageData.filter(item => {
                return (item.id != 'SINGLE_RATE_ID' && (item.isPercent && item.deductible.deductibleAmount > 100));
            });
        }
        if(validationResult.length > 0){
            validation = false;
            this.showToast('Error', 'Please Select Type and Applied to/ of for type Percentage', 'error');
            return;
        }else if(percentageResult.length > 0){
            validation = false;
            this.showToast('Error', 'Percentage greater than 100%', 'error');
            return;
        }
        if(validation){
            console.log('this.coverageData',JSON.stringify(this.coverageData));
            this.showValidationMessage = false;
            this.buttonClickedValue = 'Next';
            const attributeChangeEvent = new FlowAttributeChangeEvent('buttonClickedValue', this.buttonClickedValue);
            this.dispatchEvent(attributeChangeEvent);
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
        }
    }
    formatNumber(value) {
        if (value === null || value === undefined || value === '') {
            return '';
        }
        return new Intl.NumberFormat('id-ID', {
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2,
            useGrouping: true
        }).format(Number(value));
    }
    cleanNumber(formattedString) {
        if (formattedString === null || formattedString === undefined || formattedString === '') {
            return 0;
        }
        let cleanValue = formattedString.toString().replace(/\./g, '');
        cleanValue = cleanValue.replace(',', '.');
        return parseFloat(cleanValue);
    }
    formatDeepClone(sourceObject) {
        const fixedAmountKeys = [
            'deductibleAmount','minimumAmount',
            'deductibleAmount2','minimumAmount2',
            'deductibleAmount3','minimumAmount3',
            'deductibleAmount4','minimumAmount4'
        ];
        let formattedClone = sourceObject.map(item => {
            let formattedItem = { ...item };
            if (formattedItem.deductible) {
                let formattedDeductible = { ...formattedItem.deductible };
                for (const key of fixedAmountKeys) {
                    const amount = formattedDeductible[key];
                    if (amount !== null && amount !== undefined) {
                        if(item.isPercent && key == 'deductibleAmount'){
                        }else if(item.isPercent2 && key == 'deductibleAmount2'){   
                        }else if(item.isPercent3 && key == 'deductibleAmount3'){   
                        }else if(item.isPercent4 && key == 'deductibleAmount4'){   
                        }
                        else{
                            formattedDeductible[key] = this.formatNumber(amount);
                        }
                    }
                }
                formattedItem.deductible = formattedDeductible;
            }
            return formattedItem;
        });
        return formattedClone;
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