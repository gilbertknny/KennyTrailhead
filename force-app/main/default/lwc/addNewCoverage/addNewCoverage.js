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
    @track selectedMode = 'BREAKDOWN_DEDUCTIBLE';
    @api descriptionRate = '';
    @api buttonClickedValue;
    @track counterYear = 0;
    get settingCoverage(){
        return this.disableModeCoverage;
    }
    get filteredCoverageData() {
        return this.coverageDataFormated;
    }
    connectedCallback() {
        if (this.jsonString) {
            let parsedData = JSON.parse(this.jsonString);
            const selectedCoverages = parsedData
                .filter(item => item.isSelected && item.id !== 'SINGLE_RATE_ID' && item.sectionDisplay == 1)
                .map(item => item.coverageName);
            const combinedDescription = selectedCoverages.join(' + ');
            this.descriptionRate = combinedDescription;
            console.log('this.descriptionRate',this.descriptionRate);
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
                    rate: {
                        ...row.rate,
                        descriptionRate: combinedDescription 
                    },
                    deductible:{
                        ...row.deductible,
                    },
                    rebate:{
                        ...row.rebate,
                    }
                };
            });
            this.jsonString = JSON.stringify(this.coverageData);
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
    get isModeBreakdown() {
        return this.selectedMode === 'BREAKDOWN_DEDUCTIBLE';
    }
    get isCOB301() {
        return this.bsnId === '301';
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
            // let calculatedPremium2 = item.rate.fixedAmount2;
            // let calculatedPremium3 = item.rate.fixedAmount3;
            // let calculatedPremium4 = item.rate.fixedAmount4;
            
            if (fieldName.includes('coverageRate')) {
                console.log('Premi Amount');
                const rate = inputValue;
                if(fieldName == 'coverageRate') {
                    calculatedPremium = (rate * item.amountInsurance) / 100;
                }
                // else if(fieldName == 'coverageRate2') {
                //     calculatedPremium2 = (rate * item.amountInsurance) / 100;
                // }else if(fieldName == 'coverageRate3') {
                //     calculatedPremium3 = (rate * item.amountInsurance) / 100;
                // }else if(fieldName == 'coverageRate4') {
                //     calculatedPremium4 = (rate * item.amountInsurance) / 100;
                // }
            }
            if (item.coverageIdSection === rowId) {
                let newItem = {
                    ...item,
                    // [fieldName]: inputValue,
                    rate: {
                        ...item.rate,
                        [fieldName] :inputValue,
                        fixedAmount :calculatedPremium,
                        // fixedAmount2 :calculatedPremium2,
                        // fixedAmount3 :calculatedPremium3,
                        // fixedAmount4 :calculatedPremium4,
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
            if (item.coverageIdSection === rowId) {
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