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
    @track descriptionRate= '';
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
        const isCompositeMode = (this.selectedMode === 'COMPOSITE');
        this.coverageData = this.coverageData.map(row => {
            let updateItem = { ...row};
            if (isCompositeMode) {
                if(row.id == 'SINGLE_RATE_ID'){
                    updateItem.isDisabledTotalRebate = false;
                    updateItem.isDisabledInputRebate = true;
                }else{
                    updateItem.isDisabledTotalRebate = true;
                    updateItem.isDisabledInputRebate = true;
                    updateItem.rebate = {
                        discountValue: null,
                        commissionValue: null,
                        leasingValue: null,
                        bankFeeValue: null,
                        overridingValue: null,
                        bspValue: null,
                        profitValue: null,
                        totalRebate: null,
                    }
                }
            } else {
                updateItem.isDisabledTotalRebate = true;
                updateItem.isDisabledInputRebate = false;
                if(row.id == 'SINGLE_RATE_ID'){
                    updateItem.rebate = {
                        discountValue: null,
                        commissionValue: null,
                        leasingValue: null,
                        bankFeeValue: null,
                        overridingValue: null,
                        bspValue: null,
                        profitValue: null,
                        totalRebate: null,
                    }
                }
            }
           updateItem.rebateSetting=this.selectedMode;
            return updateItem;
        });
        this.jsonString = JSON.stringify(this.coverageData);
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
    initializeCoverageData() {
        if (this.jsonString) {
            let parsedData = JSON.parse(this.jsonString);
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
                        totalRebate: rebateData.totalRebate,
                        profitValue: rebateData.profitValue,
                        bspValue:rebateData.bspValue,
                        overridingValue:rebateData.overridingValue,
                        leasingValue:rebateData.leasingValue,
                        bankFeeValue:rebateData.bankFeeValue,
                        commissionValue:rebateData.commissionValue,
                        discountValue:rebateData.discountValue
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
            this.jsonString = JSON.stringify(this.coverageData);
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
        this.jsonString = JSON.stringify(this.coverageData);
        console.log('Final Data to Flow:', this.jsonString);
        // this.logFinalData();
    }
    
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

                const bankFee = Number(updatedItem.rebate.bankFeeValue) || 0;
                const commission = Number(updatedItem.rebate.commissionValue) || 0;
                const discount = Number(updatedItem.rebate.discountValue) || 0;
                const leasing = Number(updatedItem.rebate.leasingValue) || 0;
                const overriding = Number(updatedItem.rebate.overridingValue) || 0;
                const bsp = Number(updatedItem.rebate.bspValue) || 0;
                const profit = Number(updatedItem.rebate.profitValue) || 0;
                let total = bankFee + commission + discount + leasing + overriding + bsp + profit;
                // updatedItem.totalRebate = total;
                updatedItem.rebate={
                    ...updatedItem.rebate,
                    totalRebate : total
                }
                return updatedItem;
            }
            return item;
        });
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
        this.jsonString = JSON.stringify(this.coverageData);
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

                const bankFee = Number(updatedItem.rebate.bankFeeValue) || 0;
                const commission = Number(updatedItem.rebate.commissionValue) || 0;
                const discount = Number(updatedItem.rebate.discountValue) || 0;
                const leasing = Number(updatedItem.rebate.leasingValue) || 0;
                const overriding = Number(updatedItem.rebate.overridingValue) || 0;
                const bsp = Number(updatedItem.rebate.bspValue) || 0;
                const profit = Number(updatedItem.rebate.profitValue) || 0;
                let total = bankFee + commission + discount + leasing + overriding + bsp + profit;
                // updatedItem.totalRebate = total;
                updatedItem.rebate={
                    ...updatedItem.rebate,
                    totalRebate : total
                }
                return updatedItem;
            }
            return item;
        });
        this.jsonString = JSON.stringify(this.coverageData);
        this.coverageDataFinal = this.coverageData.filter(item => item.Id !== 'SINGLE_RATE_ID');
        console.log('Final Data to Flow:', this.jsonString);
    }
    // get discountSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.discountValue) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get commisionSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.commissionValue) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get bankFeeSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.bankFeeValue) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get leasingSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.leasingValue) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get overridingSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.overridingValue) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get riskBSPSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.bspValue) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get totalRebateSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.rebate.totalRebate) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }
    // get deductibleSum() {
    //     if (!this.coverageData || this.coverageData.length === 0) {
    //         return 0;
    //     }
    //     const sum = this.coverageData.reduce((accumulator, item) => {
    //         const deductible = Number(item.deductibleRate) || 0;
    //         return accumulator + deductible;
    //     }, 0);

    //     return sum.toFixed(2); 
    // }

    logFinalData() {
        let finalData = this.coverageData.filter(item => {
            return item.id !== 'SINGLE_RATE_ID' && item.isSelected;;
        });
        console.log('Log Final:', JSON.stringify(finalData));
    }

    
    getMatrixBooleans() {
        const matrixValue = this.groupMatrix;
        let discount, commission, bankFee, leasing, overriding, BSP, profit;

        switch (matrixValue) {
            case '1':
                discount = true; commission = true; bankFee = false; 
                leasing = false; overriding = false; BSP = false;
                profit = false;
                break;
            case '2':
            case '5':
                discount = true; commission = true; bankFee = false;
                leasing = false; overriding = true; BSP = true;
                profit = true;
                break;
            case '3':
                discount = false; commission = false; bankFee = true;
                leasing = false; overriding = true; BSP = true;
                profit = true;
                break;
            case '4':
                discount = false; commission = false; bankFee = false;
                leasing = true; overriding = true; BSP = true;
                profit = true;
                break;
            default:
                discount = false; commission = false; bankFee = false;
                leasing = false; overriding = false; BSP = false;
                profit = false;
                break;
        }
        this.showDiscount = discount;
        this.showCommission = commission;
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
        this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
        console.log('Final Data to Flow:', this.jsonString);
    }
    
    handleNext() {
        // this.insertCoverageData();
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
    // async insertCoverageData() {
    //     this.jsonString = JSON.stringify(this.coverageData.filter(item => item.isSelected));
    //     const result = await insertCoverageJson({ jsonStringList: this.jsonString });
    //     console.log('Coverage Successfully Inserted:', result);
    //     if (result == 'Success') {
    //         // this.showToast('Success', 'Coverage Successfully Insert!', 'success');
    //         this.buttonClickedValue = 'Next';
    //         const attributeChangeEvent = new FlowAttributeChangeEvent('buttonClickedValue', this.buttonClickedValue);
    //         this.dispatchEvent(attributeChangeEvent);
    //         const navigateNextEvent = new FlowNavigationNextEvent();
    //         this.dispatchEvent(navigateNextEvent);
    //     } else {
    //         this.showToast('Error', 'Failed to Insert Coverage', result);
    //     }
    // }
    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}