import { LightningElement, api, track, wire  } from 'lwc';
import getDeductiblePicklistValues from '@salesforce/apex/Aswata_Coverage_Data_Handler.getDeductiblePicklistValues';
// import insertCoverageJson from '@salesforce/apex/Aswata_Add_New_CoverageRate.insertCoverageJson';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
export default class AddNewCoverageRebate extends LightningElement {
    @track deductibleData;
    @api jsonString = '';
    @api groupMatrix = '0';
    @track coverageData = [];
    @track coverageDataTemp = [ ];
    @track coverageDataFinal = [ ];
    @track selectedMode = 'BREAKDOWN_DEDUCTIBLE';
    @track showDiscount= true;
    @track showCommission= true;
    @track showBankFeeBool= true;
    @track showLeasing= true;
    @track showOverriding= true;
    @track showBSP= true;
    @track showProfit= true;
    @track showAgentCommission = true;
    @track showBrokerCommission = true;
    @track showFinancialCommission = true;
    @track descriptionRate= '';
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
        const isCompositeMode = (this.selectedMode === 'COMPOSITE');
        this.coverageData = this.coverageData.map(row => {
            let updateItem = { ...row};
            if (isCompositeMode) {
                if(row.id == 'SINGLE_RATE_ID'){
                    updateItem.isDisabledTotalRebate = true;
                    updateItem.isDisabledInputRebate = false;
                }else{
                    updateItem.isDisabledTotalRebate = true;
                    updateItem.isDisabledInputRebate = true;
                    updateItem.rebate = {
                        discountValue: null,discountValue2: null,discountValue3: null,discountValue4: null,
                        commissionValue: null,commissionValue2: null,commissionValue3: null,commissionValue4: null,
                        agentCommissionValue: null,agentCommissionValue2: null,agentCommissionValue3: null,agentCommissionValue4: null,
                        brokerCommissionValue: null,brokerCommissionValue2: null,brokerCommissionValue3: null,brokerCommissionValue4: null,
                        financialCommissionValue: null,financialCommissionValue2: null,financialCommissionValue3: null,financialCommissionValue4: null,
                        leasingValue: null,leasingValue2: null,leasingValue3: null,leasingValue4: null,
                        bankFeeValue: null,bankFeeValue2: null,bankFeeValue3: null,bankFeeValue4: null,
                        overridingValue: null,overridingValue2: null,overridingValue3: null,overridingValue4: null,
                        bspValue: null,bspValue2: null,bspValue3: null,bspValue4: null,
                        totalRebate: null,
                        totalRebate2: null,
                        totalRebate3: null,
                        totalRebate4: null,
                    }
                }
            } else {
                updateItem.isDisabledTotalRebate = true;
                updateItem.isDisabledInputRebate = false;
                if(row.id == 'SINGLE_RATE_ID'){
                    updateItem.rebate = {
                        discountValue: null,discountValue2: null,discountValue3: null,discountValue4: null,
                        commissionValue: null,commissionValue2: null,commissionValue3: null,commissionValue4: null,
                        agentCommissionValue: null,agentCommissionValue2: null,agentCommissionValue3: null,agentCommissionValue4: null,
                        brokerCommissionValue: null,brokerCommissionValue2: null,brokerCommissionValue3: null,brokerCommissionValue4: null,
                        financialCommissionValue: null,financialCommissionValue2: null,financialCommissionValue3: null,financialCommissionValue4: null,
                        leasingValue: null,leasingValue2: null,leasingValue3: null,leasingValue4: null,
                        bankFeeValue: null,bankFeeValue2: null,bankFeeValue3: null,bankFeeValue4: null,
                        overridingValue: null,overridingValue2: null,overridingValue3: null,overridingValue4: null,
                        bspValue: null,bspValue2: null,bspValue3: null,bspValue4: null,
                        totalRebate: null,
                        totalRebate2: null,
                        totalRebate3: null,
                        totalRebate4: null,
                    }
                }
            }
           updateItem.rebateSetting=this.selectedMode;
            return updateItem;
        });
        // this.jsonString = JSON.stringify(this.coverageData);
        console.log('Mode diubah menjadi:', this.selectedMode);
    }
    @wire(getDeductiblePicklistValues)
    deductiblePicklist({ error, data }) {
        if (data) {
            this.deductibleData = data;
            this.error = undefined;
            console.log('groupMatrix:', JSON.stringify(this.groupMatrix));
            this.getMatrixBooleans();
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
            this.setSectionAsset(parsedData[0].sectionList);
            // this.disableModeCoverage = parsedData[0].disableModeCoverage;
            this.selectedMode = parsedData[0].coverageSetting ? parsedData[0].coverageSetting:'BREAKDOWN_DEDUCTIBLE';
            const isCompositeMode = (this.selectedMode === 'COMPOSITE');
            console.log('✅ Initializing Rebate Mode:', this.selectedMode);
            this.coverageData = parsedData.map(row => {
                const rebateData = row.rebate ?? {};
                let updateItem = { 
                    ...row, 
                    rebateSetting:this.selectedMode,
                    rebate:{
                        ...rebateData,
                        totalRebate: rebateData.totalRebate || 0,
                        totalRebate2: rebateData.totalRebate2 || 0,
                        totalRebate3: rebateData.totalRebate3 || 0,
                        totalRebate4: rebateData.totalRebate4 || 0,
                        // profitValue: rebateData.profitValue,
                        // bspValue:rebateData.bspValue,
                        // overridingValue:rebateData.overridingValue,
                        // leasingValue:rebateData.leasingValue,
                        // bankFeeValue:rebateData.bankFeeValue,
                        // commissionValue:rebateData.commissionValue,
                        // agentCommissionValue:rebateData.agentCommissionValue,
                        // brokerCommissionValue:rebateData.brokerCommissionValue,
                        // financialCommissionValue:rebateData.financialCommissionValue,
                        // discountValue:rebateData.discountValue
                    }
                }
                if (isCompositeMode) {
                    if(row.id == 'SINGLE_RATE_ID'){
                        this.descriptionRate=row.descriptionRate;
                        updateItem.isDisabledTotalRebate = false;
                        updateItem.isDisabledInputRebate = true;
                    }else{
                        updateItem.isDisabledTotalRebate = true;
                        updateItem.isDisabledInputRebate = true;
                    }
                } else {
                    updateItem.isDisabledTotalRebate = true;
                    updateItem.isDisabledInputRebate = false;
                }                
                return updateItem;
            });
            
            // this.coverageData = parsedData;
            this.coverageDataTemp = JSON.parse(this.jsonString);
            // this.jsonString = JSON.stringify(this.coverageData);
            console.log('✅ Initializing Rebate Data:', JSON.stringify(this.coverageData));
        } else {
            console.log('Waiting for all required data (picklist or json) to initialize.');
        }
    }
    get deductFlag() {
        return this.deductibleData;
    }
    get options() {
        return [
            { label: 'Flat(Number)', value: 'number' },
            { label: 'Percent(%)', value: 'percent' },
        ];
    }

    handleChange(event) {
        const rowId = event.target.dataset.id;
        const fieldName = event.target.name;
        const value = event.detail.value;
        console.log(`Perubahan di Baris ID: ${rowId}, Field: ${fieldName}, Nilai: ${value}`);
        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                let updatedItem = { ...item, [fieldName]: value };
                if (fieldName === 'deductibleSetting') {
                    const isFlatSelected = (value === 'number');
                    const isPercentSelected = (value === 'percent');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting: value,
                        isFlat: isFlatSelected,
                        isPercent: isPercentSelected,
                        rebate:{
                            ...updatedItem.rebate,
                            deductibleSetting : value
                        }
                    };
                }
                
                return updatedItem;
            }
            return item;
        });
        // this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    handleChangeSingle(event) {
        const rowId = event.target.dataset.id;
        const fieldName = event.target.name;
        const value = event.detail.value;
        console.log(`Perubahan di Baris ID: ${rowId}, Field: ${fieldName}, Nilai: ${value}`);
        this.coverageData = this.coverageData.map(item => {
            // if (item.id === rowId) {
                let updatedItem = { ...item, [fieldName]: value };
                if (fieldName === 'deductibleSetting') {
                    const isFlatSelected = (value === 'number');
                    const isPercentSelected = (value === 'percent');
                    updatedItem = {
                        ...updatedItem, 
                        deductibleSetting: value,
                        isFlat: isFlatSelected,
                        isPercent: isPercentSelected,
                        rebate:{
                            ...updatedItem.rebate,
                            deductibleSetting : value
                        }
                    };
                }
                
                return updatedItem;
            // }
            // return item;
        });
        // this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    calculateTotalRebate = (rebate, sectionNumber) => {
        const suffix = sectionNumber === 1 ? '' : sectionNumber;
        const fields = [
            'bankFeeValue',
            'commissionValue',
            'agentCommissionValue',
            'brokerCommissionValue',
            'financialCommissionValue',
            'discountValue',
            'leasingValue',
            'overridingValue',
            'bspValue'
        ];
        let total = 0;
        fields.forEach(field => {
            const fieldName = field + suffix;
            const value = Number(rebate[fieldName]) || 0;
            total += value;
        });

        return total;
    };
    handleInputChange(event) {
        console.log('Change Data from Flow:');
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const value = event.detail.value;

        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                // return { ...item, [fieldName]: Number(value) };
                let updatedItem = { 
                    ...item, 
                    // [fieldName]: Number(value),
                    rebate:{
                        ...item.rebate,
                        [fieldName]: Number(value)
                    }
                };
                const rebate = updatedItem.rebate;
                updatedItem.rebate={
                    ...updatedItem.rebate,
                    totalRebate : Number(this.calculateTotalRebate(rebate, 1)) || 0,
                    totalRebate2 : Number(this.calculateTotalRebate(rebate, 2)) || 0,
                    totalRebate3 : Number(this.calculateTotalRebate(rebate, 3)) || 0,
                    totalRebate4 : Number(this.calculateTotalRebate(rebate, 4)) || 0
                }
                return updatedItem;
            }
            return item;
        });
        /* // Commission Average 
        if (fieldName === 'commissionValue') {
            const filteredBreakdownRates = this.coverageData.filter(item => 
                item.isSelected && item.rowType === "BREAKDOWN_RATE"
            );
            console.log('filteredBreakdownRates:', filteredBreakdownRates);
            const totalBreakdownRatesSelected = filteredBreakdownRates.length;
            const totalSumOfRates = filteredBreakdownRates.reduce((sum, row) => {
                return sum + (Number(row.rebate.commissionValue) || 0); 
            }, 0);
            let newAverageRate = 0;
            if (totalBreakdownRatesSelected > 0) {
                newAverageRate = totalSumOfRates / totalBreakdownRatesSelected;
            }
            console.log('Rata-rata Coverage Rate Baru:', newAverageRate);
            this.coverageData = this.coverageData.map(item => ({
                ...item,
                commisionAllRate: newAverageRate
            }));
        }
        */
        // this.jsonString = JSON.stringify(this.coverageData);
        this.coverageDataFinal = this.coverageData.filter(item => item.Id !== 'SINGLE_RATE_ID');
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    handleInputChangeSingle(event) {
        console.log('Change Data from Flow:');
        const rowId = event.target.dataset.id;
        const fieldName = event.target.dataset.fieldname;
        const value = event.detail.value;

        this.coverageData = this.coverageData.map(item => {
            if (item.id === rowId) {
                // return { ...item, [fieldName]: Number(value) };
                let updatedItem = { 
                    ...item, 
                    // [fieldName]: Number(value),
                    rebate:{
                        ...item.rebate,
                        [fieldName]: Number(value)
                    }
                };
                const rebate = updatedItem.rebate;
                updatedItem.rebate={
                    ...updatedItem.rebate,
                    totalRebate : Number(this.calculateTotalRebate(rebate, 1)) || 0,
                    totalRebate2 : Number(this.calculateTotalRebate(rebate, 2)) || 0,
                    totalRebate3 : Number(this.calculateTotalRebate(rebate, 3)) || 0,
                    totalRebate4 : Number(this.calculateTotalRebate(rebate, 4)) || 0
                }
                return updatedItem;
            }
            return item;
        });
        // this.jsonString = JSON.stringify(this.coverageData);
        this.coverageDataFinal = this.coverageData.filter(item => item.Id !== 'SINGLE_RATE_ID');
        console.log('Final Data to Flow:', this.jsonString);
    }
    logFinalData() {
        let finalData = this.coverageData.filter(item => {
            return item.id !== 'SINGLE_RATE_ID' && item.isSelected;;
        });
        console.log('Log Final:', JSON.stringify(finalData));
    }

    
    getMatrixBooleans() {
        const matrixValue = this.groupMatrix;
        let agentCommission, brokerCommission, financialCommission, discount, commission, bankFee, leasing, overriding, BSP, profit;

        switch (matrixValue) {
            case '1':
                agentCommission = false; brokerCommission = false; financialCommission = false;
                discount = true; commission = true; bankFee = false; 
                leasing = false; overriding = false; BSP = false;
                profit = false;
                break;
            case '2':
                agentCommission = false; brokerCommission = false; financialCommission = false;
                discount = true; commission = true; bankFee = false;
                leasing = false; overriding = true; BSP = true;
                profit = true;
                break;
            case '5':
                agentCommission = false; brokerCommission = true; financialCommission = false;
                discount = true; commission = false; bankFee = false;
                leasing = false; overriding = true; BSP = true;
                profit = true;
                break;
            case '3':
                agentCommission = false; brokerCommission = false; financialCommission = false;
                discount = false; commission = false; bankFee = true;
                leasing = false; overriding = true; BSP = true;
                profit = true;
                break;
            case '4':
                agentCommission = false; brokerCommission = false; financialCommission = true;
                discount = false; commission = false; bankFee = false;
                leasing = true; overriding = true; BSP = true;
                profit = true;
                break;
            case '6':
                agentCommission = true; brokerCommission = false; financialCommission = false;
                discount = true; commission = false; bankFee = false; 
                leasing = false; overriding = false; BSP = false;
                profit = false;
                break;
            default:
                agentCommission = false; brokerCommission = false; financialCommission = false;
                discount = false; commission = false; bankFee = false;
                leasing = false; overriding = false; BSP = false;
                profit = false;
                break;
        }
        this.showCommission = commission;
        this.showAgentCommission = agentCommission;
        this.showBrokerCommission = brokerCommission;
        this.showFinancialCommission = financialCommission;
        this.showDiscount = discount;
        this.showBankFeeBool = bankFee;
        this.showLeasing = leasing;
        this.showOverriding = overriding;
        this.showBSP = BSP;
        this.showProfit = profit;
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
        // this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        // console.log('Final Data to Flow:', this.jsonString);
    }
    
    handleNext() {
        const flattenDeductibles = (deductibleObj) => {
            const deductiblesArray = [];
            for (let i = 2; i <= 4; i++) {
                const suffix = String(i);
                const deductibleItem = {
                    deductibleAmount: deductibleObj['deductibleAmount' + suffix],
                    minimumAmount: deductibleObj['minimumAmount' + suffix],
                    currencyId: deductibleObj['currencyId' + suffix],
                    currencyName: deductibleObj['currencyName' + suffix],
                    deductibleSetting: deductibleObj['deductibleSetting' + suffix],
                    deductibleFlag: deductibleObj['deductibleFlag' + suffix],
                    descriptionValue: deductibleObj['descriptionValue' + suffix],
                    descriptionDeductible: deductibleObj['descriptionDeductible' + suffix]
                };
                deductiblesArray.push(deductibleItem);
            }
            return deductiblesArray;
        };
        const flattenRebates = (rebateObj) => {
            const rebatesArray = [];
            for (let i = 2; i <= 4; i++) {
                const suffix = String(i);
                const rebateItem = {
                    totalRebate: rebateObj['totalRebate' + suffix],
                    bspValue: rebateObj['bspValue' + suffix],
                    overridingValue: rebateObj['overridingValue' + suffix],
                    leasingValue: rebateObj['leasingValue' + suffix],
                    bankFeeValue: rebateObj['bankFeeValue' + suffix],
                    commissionValue: rebateObj['commissionValue' + suffix],
                    agentCommissionValue: rebateObj['agentCommissionValue' + suffix],
                    brokerCommissionValue: rebateObj['brokerCommissionValue' + suffix],
                    financialCommissionValue: rebateObj['financialCommissionValue' + suffix],
                    discountValue: rebateObj['discountValue' + suffix],
                };
                rebatesArray.push(rebateItem);
            }
            return rebatesArray;
        };
        this.coverageData = this.coverageData.map(item => {
            const deductibleObj = item.deductible || {};
            const rebateObj = item.rebate || {};
            const newDeductibles = flattenDeductibles(deductibleObj);
            const newRebates = flattenRebates(rebateObj);
            return {
                ...item,
                deductibles: newDeductibles,
                rebates: newRebates,
            };
        });
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
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
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}