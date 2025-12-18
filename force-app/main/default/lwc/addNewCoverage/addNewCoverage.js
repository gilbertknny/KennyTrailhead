import { LightningElement, api, track, wire  } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
export default class AddNewCoverageRate extends LightningElement {
    @api recordTypeIdCoverage;
    @api amountInsurance;
    @api recordId;
    @api bsnId;
    @api cob301 = false;
    @api riskId;
    @api policyId;
    @api jsonString = '';
    @api outputJsonString = '';
    @api groupMatrix = '0';
    @track coverageData = [];
    @track coverageDataFormated = [];
    @track selectedCoverageNames = new Set();
    @track disableModeCoverage = false;
    @track hasSection1 = false;
    @track hasSection2 = false;
    @track hasSection3 = false;
    @track hasSection4 = false;
    @track selectedMode = 'BREAKDOWN_DEDUCTIBLE';
    @api descriptionRate = '';
    @api buttonClickedValue;
    @track counterYear = 0;
    get settingCoverage(){
        return this.disableModeCoverage;
    }
    get filteredCoverageData() {
        return this.coverageDataFormated;
        if (!this.searchTerm && this.selectedCoverageId == '0') {
            if(this.bsnId == '301'){
                return this.coverageDataFormated.filter(row =>
                    row.parentCoverageId == '0'
                );
            }else{
                return this.coverageDataFormated;
            }
        }
        const lowerCaseSearch = this.searchTerm.toLowerCase();
        let dataToFilter = this.coverageDataFormated;

        if(this.bsnId == '301'){
            if (this.selectedCoverageId) {
                const currentCoverageId = this.selectedCoverageId;
                dataToFilter = dataToFilter.filter(row => {
                    const isSelectedRow = row.coverageId === currentCoverageId;
                    const isChildOfSelected = row.parentCoverageId === currentCoverageId;
                    return isSelectedRow || isChildOfSelected;
                });
            }
            if (lowerCaseSearch) {
                dataToFilter = dataToFilter.filter(row =>
                    row.coverageName && row.coverageName.toLowerCase().includes(lowerCaseSearch)
                );
            }
            return dataToFilter;
        }else{
            return this.coverageDataFormated.filter(row =>
                row.coverageName && row.coverageName.toLowerCase().includes(lowerCaseSearch)
            );
        }
    }
    connectedCallback() {
        if (this.jsonString) {
            let parsedData = JSON.parse(this.jsonString);
            this.descriptionRate = parsedData[0].rate.descriptionRate;
            console.log('this.descriptionRate',this.descriptionRate);
            this.setSectionAsset(parsedData[0].sectionList);
            this.selectedMode = parsedData[0].coverageSetting ? parsedData[0].coverageSetting:'BREAKDOWN_DEDUCTIBLE';
            // this.disableModeCoverage = parsedData[0].disableModeCoverage;
            this.coverageData = parsedData.map(row => {
                const setting = row.deductibleSetting;
                // const shouldBeDisabled = (row.id === 'SINGLE_RATE_ID');
                return {
                    ...row,
                    ddtibleSetting: this.selectedMode,
                    // compositeDisable: shouldBeDisabled,
                    deductibleSetting: setting,
                };
            });
            this.jsonString = JSON.stringify(this.coverageData);
            // this.applyDisableLogic(null);
            this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
            console.log('✅ InitializeCoverageRateData After:', this.jsonString);
        } else {
            console.log('Waiting for all required data (picklist or json) to initialize.');
        }
    }
    get modeOptions() {
        return [
            { label: 'Breakdown', value: 'BREAKDOWN_DEDUCTIBLE' },
            { label: 'Single/Package', value: 'COMPOSITE' }
        ];
    }
    handleModeChange(event) {
        this.selectedMode = event.detail.value;
        this.applyDisableLogic('Change');
        console.log('Mode diubah menjadi:', this.selectedMode);
    }
    get isModeBreakdown() {
        return this.selectedMode === 'BREAKDOWN_DEDUCTIBLE';
    }
    get isCOB301() {
        return this.bsnId === '301';
    }
    // async getCoverageData(){
    //     try {
    //         return await getExistingCoverage({riskId : this.riskId });
    //     }
    //     catch (error) {
    //         console.error(`Error di getCoverageData: ${error}`);
    //         throw error; 
    //     }
    // }
    setSectionAsset(sectionList){
        this.hasSection1 = sectionList.includes(1);
        this.hasSection2 = sectionList.includes(2);
        this.hasSection3 = sectionList.includes(3);
        this.hasSection4 = sectionList.includes(4);
        console.log('this.hasSection',this.hasSection1);
    }
    finalizeData(finalData) {
        this.coverageData = finalData; 
        this.applyDisableLogic(null); 
        // console.log('✅ Data Coverage Final Diperbarui.',JSON.stringify(finalData));
    }
    formatDeepClone(sourceObject) {
        const fixedAmountKeys = ['fixedAmount', 'fixedAmount2', 'fixedAmount3', 'fixedAmount4'];
        let formattedClone = sourceObject.map(item => {
            let formattedItem = { ...item };
            if (formattedItem.rate) {
                let formattedRate = { ...formattedItem.rate };
                for (const key of fixedAmountKeys) {
                    const amount = formattedRate[key];
                    if (amount !== null && amount !== undefined) {
                        formattedRate[key] = this.formatNumber(amount);
                    }
                }
                formattedItem.rate = formattedRate;
            }
            return formattedItem;
        });
        return formattedClone;
    }
    applyDisableLogic(event) {
        console.log('✅ Success Change Mode', event);
        if (!this.coverageData) {
            console.error('Error fetching coverage data:', error);
            return;
        } 
        this.coverageData = this.coverageData.map(item => {
            let covSetting;
            let isSelected;
            let isDisabledRate;
            let disabledInputSelect;
            let singleFixedAmount = item.rate.fixedAmount;
            let singleFixedAmount2 = item.rate.fixedAmount2;
            let singleFixedAmount3 = item.rate.fixedAmount3;
            let singleFixedAmount4 = item.rate.fixedAmount4;
            let singleSelfInsurace = item.selfInsurace;
            let singleBatasBawah = item.batasBawah;
            let singleCoverageRate = item.rate.coverageRate;
            let singleCoverageRate2 = item.rate.coverageRate2;
            let singleCoverageRate3 = item.rate.coverageRate3;
            let singleCoverageRate4 = item.rate.coverageRate4;
            let descriptionRate = item.descriptionRate;
            
            // const originalItem = dynamicDataTemp.find(tempItem => tempItem.id === item.id);
            if (this.selectedMode === 'COMPOSITE') {
                if (item.rowType == 'BREAKDOWN_RATE') {
                    isDisabledRate = true;
                    // isSelected = false;
                    disabledInputSelect = false;
                    if(event == 'Change'){
                        singleFixedAmount= null;
                        singleSelfInsurace= null;
                        singleCoverageRate= null;
                        singleCoverageRate2= null;
                        singleCoverageRate3= null;
                        singleCoverageRate4= null;
                    }
                }else{
                    isDisabledRate = false;
                    isSelected = true;
                    disabledInputSelect = true;
                }
                covSetting = 'COMPOSITE';
            } else{
                if (item.rowType == 'BREAKDOWN_RATE') {
                    isDisabledRate = item.isSelected? false: true;
                    // isSelected = false;
                    disabledInputSelect = false;
                }else{
                    isDisabledRate = true;
                    isSelected = false;
                    disabledInputSelect = true;
                    singleFixedAmount= null;
                    singleSelfInsurace= null;
                    singleBatasBawah= null;
                    singleCoverageRate= null;
                    singleCoverageRate2= null;
                    singleCoverageRate3= null;
                    singleCoverageRate4= null;
                }
                covSetting = 'BREAKDOWN_DEDUCTIBLE';
            }

            return {
                ...item,
                isDisabledInput: isDisabledRate,
                isDisabledSelection: disabledInputSelect,
                coverageSetting: covSetting,
                fixedAmount: singleFixedAmount,
                selfInsurace: singleSelfInsurace,
                batasBawah: singleBatasBawah,
                coverageRate: singleCoverageRate,
                rate:{
                    fixedAmount: singleFixedAmount,
                    fixedAmount2: singleFixedAmount2,
                    fixedAmount3: singleFixedAmount3,
                    fixedAmount4: singleFixedAmount4,
                    selfInsurace: singleSelfInsurace,
                    coverageRate: singleCoverageRate,
                    coverageRate2: singleCoverageRate2,
                    coverageRate3: singleCoverageRate3,
                    coverageRate4: singleCoverageRate4,
                    descriptionRate: descriptionRate
                }
            };
        });
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
        
        this.handleChangeCoverageName(event);
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        console.log('Selected New Data:', this.jsonString);
    }
    get thisCoverageData() {
        return this.coverageDataFormated;
    }

    handleInputChange(event) {
        console.log('Change Data from Flow:');
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const inputValue = Number(event.detail.value);
        this.coverageData = this.coverageData.map(item => {
            let calculatedPremium = item.rate.fixedAmount;
            let calculatedPremium2 = item.rate.fixedAmount2;
            let calculatedPremium3 = item.rate.fixedAmount3;
            let calculatedPremium4 = item.rate.fixedAmount4;
            
            if (fieldName.includes('coverageRate')) {
                console.log('Premi Amount');
                const rate = inputValue;
                if(fieldName == 'coverageRate') {
                    calculatedPremium = (rate * item.amountInsurance) / 100;
                }else if(fieldName == 'coverageRate2') {
                    calculatedPremium2 = (rate * item.amountInsurance) / 100;
                }else if(fieldName == 'coverageRate3') {
                    calculatedPremium3 = (rate * item.amountInsurance) / 100;
                }else if(fieldName == 'coverageRate4') {
                    calculatedPremium4 = (rate * item.amountInsurance) / 100;
                }
            }
            if (item.id === rowId || item.id2 === rowId || item.id3 === rowId || item.id4 === rowId) {
                let newItem = {
                    ...item,
                    // [fieldName]: inputValue,
                    rate: {
                        ...item.rate,
                        [fieldName] :inputValue,
                        fixedAmount :calculatedPremium,
                        fixedAmount2 :calculatedPremium2,
                        fixedAmount3 :calculatedPremium3,
                        fixedAmount4 :calculatedPremium4,
                    }
                };

                return newItem;
            }
            return item;
        });
        /* // Coverage Rate Average
        if (fieldName === 'coverageRate') {
            const filteredBreakdownRates = this.coverageData.filter(item => 
                item.isSelected && item.rowType === "BREAKDOWN_RATE"
            );
            console.log('filteredBreakdownRates:', filteredBreakdownRates);
            const totalBreakdownRatesSelected = filteredBreakdownRates.length;
            const totalSumOfRates = filteredBreakdownRates.reduce((sum, row) => {
                return sum + (Number(row.rate.coverageRate) || 0); 
            }, 0);
            let newAverageRate = 0;
            if (totalBreakdownRatesSelected > 0) {
                newAverageRate = totalSumOfRates / totalBreakdownRatesSelected;
            }
            console.log('Rata-rata Coverage Rate Baru:', newAverageRate);
            this.coverageData = this.coverageData.map(item => ({
                ...item,
                coverageAllRate: newAverageRate
            }));
        }
        */
        // formated Data
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData )));
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    handleInputChangeSingle(event) {
        console.log('Change Data Single Rate from Flow:');
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const inputValue = event.detail.value;

        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                let calculatedPremium = item.rate.fixedAmount;
                let calculatedPremium2 = item.rate.fixedAmount2;
                let calculatedPremium3 = item.rate.fixedAmount3;
                let calculatedPremium4 = item.rate.fixedAmount4;
                if (fieldName.includes('coverageRate')) {
                    console.log('Premi Amount');
                    const rate = inputValue;
                    if(fieldName == 'coverageRate') {
                        calculatedPremium = (rate * item.amountInsurance) / 100;
                    }else if(fieldName == 'coverageRate2') {
                        calculatedPremium2 = (rate * item.amountInsurance) / 100;
                    }else if(fieldName == 'coverageRate3') {
                        calculatedPremium3 = (rate * item.amountInsurance) / 100;
                    }else if(fieldName == 'coverageRate4') {
                        calculatedPremium4 = (rate * item.amountInsurance) / 100;
                    }
                }
                return { 
                    ...item, 
                    // coverageAllRate: inputValue,
                    rate:{
                        ...item.rate,
                        [fieldName] :inputValue,
                        fixedAmount :calculatedPremium,
                        fixedAmount2 :calculatedPremium2,
                        fixedAmount3 :calculatedPremium3,
                        fixedAmount4 :calculatedPremium4,
                    }
                };
            }
            return item;
        });
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData )));
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        // console.log('Final Data to Flow:', this.jsonString);
        this.logFinalData();
    }

    handleRowSelection(event) {
        const rowId = event.target.dataset.id;
        const isChecked = event.detail.checked;
        let disabledInput = false;
        const selectedRow = this.coverageData.find(item => item.id === rowId);
        const singleRateRow = this.coverageData.find(item => item.id === 'SINGLE_RATE_ID');

        if(isChecked && this.selectedMode == 'BREAKDOWN_DEDUCTIBLE'){
            disabledInput = false;
        }else{
            disabledInput = true;
        }
        let shouldClearChildren = false;
        if(this.bsnId == '301'){
            if(selectedRow.parentCoverageId == '0'){
                if (isChecked && selectedRow) {
                    this.selectedCoverageId = selectedRow.coverageId; 
                } else if (!isChecked && this.selectedCoverageId === selectedRow.coverageId) {
                    this.selectedCoverageId = '0'; 
                    shouldClearChildren = true;
                }
            }
        }
        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                let updatedItem = { 
                    ...item, 
                    isSelected: isChecked,
                    isDisabledInput: disabledInput
                };
                if(isChecked && this.selectedMode == 'COMPOSITE'){
                    // updatedItem.fixedAmount = singleRateRow.fixedAmount;
                    // updatedItem.selfInsurace = singleRateRow.selfInsurace;
                    // updatedItem.coverageRate = singleRateRow.coverageRate;
                    // updatedItem.rate = {
                    //     fixedAmount: singleRateRow.fixedAmount,
                    //     selfInsurace: singleRateRow.selfInsurace,
                    //     coverageRate: singleRateRow.coverageRate  
                    // };
                }else if(!isChecked){
                    updatedItem.fixedAmount = null;
                    updatedItem.selfInsurace = null;
                    updatedItem.coverageRate = null;
                    updatedItem.rate = {
                        fixedAmount: singleRateRow.fixedAmount,
                        fixedAmount2: singleRateRow.fixedAmount2,
                        fixedAmount3: singleRateRow.fixedAmount3,
                        fixedAmount4: singleRateRow.fixedAmount4,
                        selfInsurace: singleRateRow.selfInsurace,
                        coverageRate: singleRateRow.coverageRate,
                        coverageRate2: singleRateRow.coverageRate2,
                        coverageRate3: singleRateRow.coverageRate3,
                        coverageRate4: singleRateRow.coverageRate4
                    };
                }
                return updatedItem;
            }
            if (shouldClearChildren) {
                if (item.parentCoverageId === selectedRow.coverageId) {
                    return {
                        ...item,
                        isSelected: false,
                        isDisabledInput: true,
                    };
                }
            }
            return item;
        });
        if (selectedRow && selectedRow.id !== 'SINGLE_RATE_ID') {
            if (isChecked) {
                this.selectedCoverageNames.add(selectedRow.coverageName);
            } else {
                this.selectedCoverageNames.delete(selectedRow.coverageName);
            }
        }
        this.handleChangeCoverageName();
        console.log(`Baris ${rowId} dipilih: ${isChecked}`,event);
        this.coverageDataFormated = this.formatDeepClone(JSON.parse(JSON.stringify(this.coverageData)));
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        console.log('Selected New Data:', this.jsonString);

    }
    
    handleChangeCoverageName(){
        let newCoverageNameEdit;
        console.log('selectedCoverageNames',this.selectedCoverageNames);
        if (this.selectedMode === 'COMPOSITE' && this.selectedCoverageNames.size > 0) {
            newCoverageNameEdit = Array.from(this.selectedCoverageNames).join(' + ');
        } else if (this.selectedCoverageNames.size === 0) {
            newCoverageNameEdit = ''; 
        } else {
            newCoverageNameEdit = null; 
        }

        if (this.descriptionRate !== newCoverageNameEdit) {
            this.descriptionRate = newCoverageNameEdit;
            this.coverageData = this.coverageData.map(item => {
                item.descriptionRate = newCoverageNameEdit;
                item.rate.descriptionRate= newCoverageNameEdit;
                return item;
            });
        }
        // console.log('Change Name Coverage:');
        // const selectedCoverages = this.coverageData.filter(item => 
        //     item.isSelected && item.id !== 'SINGLE_RATE_ID'
        // );
        // const coverageNames = selectedCoverages.map(item => item.coverageName);

        // let newCoverageNameEdit = null;
        // if (this.selectedMode === 'COMPOSITE' && coverageNames.length > 0) {
        //     newCoverageNameEdit = coverageNames.join(' + ');
        // }
        // this.descriptionRate = newCoverageNameEdit;
        // this.coverageData = this.coverageData.map(item => {
        //     item.descriptionRate = newCoverageNameEdit;
        //     item.rate.descriptionRate= newCoverageNameEdit;
        //     return item;
        // });
    }
    get totalFixedAmount() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.fixedAmount) || 0:0;
            return accumulator + rate;
        }, 0);
        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totalFixedAmount2() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.fixedAmount2) || 0:0;
            return accumulator + rate;
        }, 0);
        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totalFixedAmount3() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.fixedAmount3) || 0:0;
            return accumulator + rate;
        }, 0);
        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totalFixedAmount4() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.fixedAmount4) || 0:0;
            return accumulator + rate;
        }, 0);
        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totacoverageRate() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.coverageRate) || 0:0;
            return accumulator + rate;
        }, 0);

        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totacoverageRate2() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.coverageRate2) || 0:0;
            return accumulator + rate;
        }, 0);

        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totacoverageRate3() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.coverageRate3) || 0:0;
            return accumulator + rate;
        }, 0);

        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totacoverageRate4() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.rate.coverageRate4) || 0:0;
            return accumulator + rate;
        }, 0);

        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }
    get totalRateSum() {
        if (!this.coverageData || this.coverageData.length === 0) {
            return 0;
        }
        const sum = this.coverageData.reduce((accumulator, item) => {
            const rate = (item.isSelected && !item.isSingleRate)? Number(item.batasBawah) || 0: 0;
            return accumulator + rate;
        }, 0);

        // return sum.toFixed(2); 
        return this.formatNumber(sum);
    }

    changeSelectedDataOutput() {
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        console.log('Log Selected:', JSON.stringify(this.jsonString));
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
    formatNumber(value) {
        if (value === null || value === undefined || value === '') {
            return 0;
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
    handleChangeDesc(event) {
        const newValue = event.detail.value;
        console.log('Change Description: ',newValue);
        this.descriptionRate = newValue;
        this.coverageData = this.coverageData.map(item => {
            return { 
                ...item,
                descriptionRate: newValue,
                rate:{
                    ...item.rate,
                    descriptionRate: newValue,
                }
            };
            // return { 
            //     ...item, 
            //     description: newValue,
            //     deductible : {
            //         ...item.deductible,
            //         description: newValue,
            //     }
            // };
        });
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    handleNext() {
        this.buttonClickedValue = 'Next';
        const attributeChangeEvent = new FlowAttributeChangeEvent('buttonClickedValue', this.buttonClickedValue);
        this.dispatchEvent(attributeChangeEvent);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
    handlePrevious() {
        this.buttonClickedValue = 'Previous';
        const attributeChangeEvent = new FlowAttributeChangeEvent('buttonClickedValue', this.buttonClickedValue);
        this.dispatchEvent(attributeChangeEvent);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}