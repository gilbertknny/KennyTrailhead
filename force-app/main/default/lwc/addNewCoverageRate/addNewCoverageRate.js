import { LightningElement, api, track, wire  } from 'lwc';
import getCoverageFields from '@salesforce/apex/Aswata_Coverage_Data_Handler.getCoverageFields';
import getExistingCoverage from '@salesforce/apex/Aswata_Coverage_Data_Handler.getExistingCoverage';
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
    @track searchTerm = '';
    @track selectedCoverageId = '0';
    @track counterYear = 0;
    get settingCoverage(){
        return this.disableModeCoverage;
    }
    get filteredCoverageData() {
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
    handleSearchChange(event) {
        this.searchTerm = event.target.value;
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
    async getCoverageData(){
        try {
            return await getExistingCoverage({riskId : this.riskId });
        }
        catch (error) {
            console.error(`Error di getCoverageData: ${error}`);
            throw error; 
        }
    }
    setSectionAsset(sectionList){
        this.hasSection1 = sectionList.includes(1);
        this.hasSection2 = sectionList.includes(2);
        this.hasSection3 = sectionList.includes(3);
        this.hasSection4 = sectionList.includes(4);
        console.log('this.hasSection',this.hasSection1);
    }
    // formatPeriodRate(value) {
    //     if (value < 1) {
    //         return 1;
    //     }
    //     return value;
    // }
    @wire(getCoverageFields, { rtId: '$recordTypeIdCoverage', cob: '$bsnId',riskId:'$riskId'})
    wiredCoverages({ error, data }) {
        if (data) {
            this.counterYear = this.buttonClickedValue;
            console.log('counterYear: ', this.buttonClickedValue);
            console.log('Data Coverage: ', data.length);
            console.log('Policy:', this.policyId);
            this.setSectionAsset(data[0].sectionList);
            // const matrixBools = this.getMatrixBooleans(this.groupMatrix);
            let dynamicRows = data.map((item, index) => ({
                ...item,
                id: item.coverageId,
                id2: item.coverageId+'SEC2',
                id3: item.coverageId+'SEC3',
                id4: item.coverageId+'SEC4',
                riskId:this.riskId,
                policyId:this.policyId,
                amountInsurance: this.amountInsurance,
                isDisabledSelection: false,
                rowType: 'BREAKDOWN_RATE',
                covTahun: this.buttonClickedValue,
                isSelected: false,
                isExisting: false,
                isDisabledInput: true,
                isSingleRate: false,
                coverageSetting:'BREAKDOWN_DEDUCTIBLE',
                fixedAmount: null,
                selfInsurace: null,
                coverageRate: null,
                rate:{
                    fixedAmount: null,
                    fixedAmount2: null,
                    fixedAmount3: null,
                    fixedAmount4: null,
                    selfInsurace: null,
                    coverageRate: null,
                    coverageRate2: null,
                    coverageRate3: null,
                    coverageRate4: null,
                },
                deductible:{
                    descriptionDeductible: ''
                },
                rebate:{
                    totalRebate: 0
                },
                rebateSetting:'',
                isDisabledTotalRebate: true,
                isDisabledInputRebate: false,
                commisionAllRate: null
            }));
            const singleRateRow = {
                id: 'SINGLE_RATE_ID',
                id2: 'SINGLE_RATE_ID'+'SEC2',
                id3: 'SINGLE_RATE_ID'+'SEC3',
                id4: 'SINGLE_RATE_ID'+'SEC4',
                riskId:this.riskId,
                policyId:this.policyId,
                amountInsurance: this.amountInsurance,
                coverageId: ' ',
                coverageName: 'Single/Package Rate',
                // coverageRate: 0,
                isSelected: true,
                isDisabledInput: true,
                isDisabledSelection: true,
                rowType: 'SINGLE_RATE',
                isSingleRate: true,
                isExisting: false,
                coverageSetting:'BREAKDOWN_DEDUCTIBLE',
                rate:{
                    fixedAmount: null,
                    fixedAmount2: null,
                    fixedAmount3: null,
                    fixedAmount4: null,
                    selfInsurace: null,
                    coverageRate: null,
                    coverageRate2: null,
                    coverageRate3: null,
                    coverageRate4: null,
                },
                deductible:{
                    descriptionDeductible: ''
                },
                rebate:{
                    totalRebate: 0,
                    totalRebate2: 0,
                    totalRebate3: 0,
                    totalRebate4: 0,
                },
                rebateSetting:'',
                isDisabledTotalRebate: true,
                isDisabledInputRebate: false,
                commisionAllRate: null
            };
            let baseDataList = [...dynamicRows, singleRateRow];
            const idList = baseDataList.map(item => item.id);
            // console.log('Daftar semua ID:', JSON.stringify(idList));
            if (this.jsonString) {
                console.log('✅ Success parsing JSON from Flow CoverageRate:', this.jsonString);
                const parsedData = JSON.parse(this.jsonString);
                try {
                    let currentDataList = baseDataList;
                    this.setSectionAsset(parsedData[0].sectionList);
                    if (this.bsnId === '301') {
                        const selectedParent = parsedData.find(item => 
                            item.parentCoverageId == '0' && item.isSelected == true
                        );
                        if (selectedParent) {
                            console.log('✅ CoverageRate selectedParent IF');
                            this.selectedCoverageId = selectedParent.coverageId;
                        }
                    }
                    parsedData.forEach(newItem => {
                        this.descriptionRate = newItem.rate.descriptionRate;
                        const targetId = newItem.id;
                        // console.log('✅ CoverageRate targetId',targetId);
                        const targetItem = currentDataList.find(item => item.id === targetId);
                        // console.log('✅ CoverageRate targetItem',targetItem);
                        if (targetItem) {
                            for (const key in newItem) {
                                if (newItem.hasOwnProperty(key)) {
                                    // console.log('✅ CoverageRate hasOwnProperty',key);
                                    if (key !== 'id' && key !== 'riskId' && key !== 'policyId') {
                                        if (typeof newItem[key] === 'object' && newItem[key] !== null && 
                                            (key === 'rate' || key === 'deductible' || key === 'rebate')) {
                                                if (Object.keys(newItem[key]).length > 0) {
                                                    Object.assign(targetItem[key], newItem[key]);
                                                }
                                        } 
                                        else {
                                            // targetItem[key] = newItem[key];
                                            if(key != 'covTahun') {
                                                // console.log('✅ CoverageRate Key',key);
                                                targetItem[key] = newItem[key];
                                            }
                                        }
                                    }
                                }
                            }
                            this.selectedMode = targetItem.coverageSetting;
                        }
                    });
                    console.log('✅ parsedData',parsedData);
                } catch (e) {
                    console.error('❌ Error parsing or merging JSON string:', e);
                }
                this.finalizeData(baseDataList);
            }else{
                this.getCoverageData()
                .then(existingResult => {
                    if (existingResult && existingResult.length > 0) {
                        console.log('existingResult', existingResult);
                        this.disableModeCoverage = true;
                        this.selectedMode = existingResult[0].existing.coverageSetting;
                        const initialDataList = baseDataList;
                        let currentDataList = JSON.parse(JSON.stringify(initialDataList));
                        existingResult.forEach(existingItem => {
                            const targetId = existingItem.coverageId;
                            const selectedIdString = existingItem.existing.listSelectedId; 
                            const selectedIds = selectedIdString ? selectedIdString.split(',') : [];
    
                            if (existingItem.coverageName.includes('+') || selectedIds.length > 1) {
                                this.selectedCoverageNames.add(existingItem.coverageName);
                                const singleTargetItem = currentDataList.find(item => item.id === 'SINGLE_RATE_ID');
                                if (singleTargetItem) {
                                    const rateValue = existingItem.rate;
                                    console.log('rateValue',rateValue);
                                    const deductibleValue = existingItem.deductible;
                                    console.log('rateValue Deduct',deductibleValue);
                                    const rebateValue = existingItem.rebate;
                                    console.log('rateValue rebate',rebateValue);
                                    let calculatedPremium1 =0;
                                    let calculatedPremium2 =0;
                                    let calculatedPremium3 =0;
                                    let calculatedPremium4 =0;
                                    if(rateValue && rateValue.coverageRate) calculatedPremium1 = (Number(rateValue.coverageRate) * singleTargetItem.amountInsurance) / 100;                                    
                                    if(rateValue && rateValue.coverageRate2) calculatedPremium2 = (Number(rateValue.coverageRate2) * singleTargetItem.amountInsurance) / 100;                                    
                                    if(rateValue && rateValue.coverageRate3) calculatedPremium3 = (Number(rateValue.coverageRate3) * singleTargetItem.amountInsurance) / 100;                                    
                                    if(rateValue && rateValue.coverageRate4) calculatedPremium4 = (Number(rateValue.coverageRate4) * singleTargetItem.amountInsurance) / 100;                                    
                                    singleTargetItem.isSelected = true;
                                    singleTargetItem.disableModeCoverage= true;
                                    // singleTargetItem.descriptionRate= existingItem.coverageName;
                                    singleTargetItem.rate = {
                                        ...rateValue,
                                        // descriptionRate:existingItem.coverageName,
                                        fixedAmount: calculatedPremium1,
                                        fixedAmount2: calculatedPremium2,
                                        fixedAmount3: calculatedPremium3,
                                        fixedAmount4: calculatedPremium4
                                    };
                                    singleTargetItem.deductible = {
                                        ...deductibleValue
                                    };
                                    singleTargetItem.rebate = {
                                        ...rebateValue
                                    };
                                    singleTargetItem.compositeDisable = false;
                                }
                                currentDataList.forEach(targetItem => {
                                    if (selectedIds.includes(targetItem.id)) {
                                        targetItem.isExisting = true;
                                        targetItem.isSelected = true; 
                                        targetItem.disableModeCoverage= true;
                                    }
                                });
                            }else{
                                const targetItem = currentDataList.find(item => item.id === targetId);
                                console.log('existingResult targetItem', JSON.stringify(targetItem));
                                if (targetItem) {
                                    const rateValue = existingItem.rate;
                                    console.log('rateValue',rateValue);
                                    const deductibleValue = existingItem.deductible;
                                    console.log('rateValue Deduct',deductibleValue);
                                    const rebateValue = existingItem.rebate;
                                    console.log('rateValue rebate',rebateValue);
                                    let calculatedPremium1 =0;
                                    let calculatedPremium2 =0;
                                    let calculatedPremium3 =0;
                                    let calculatedPremium4 =0;
                                    if(rateValue.coverageRate) calculatedPremium1 = (Number(rateValue.coverageRate) * targetItem.amountInsurance) / 100;                                    
                                    if(rateValue.coverageRate2) calculatedPremium2 = (Number(rateValue.coverageRate2) * targetItem.amountInsurance) / 100;                                    
                                    if(rateValue.coverageRate3) calculatedPremium3 = (Number(rateValue.coverageRate3) * targetItem.amountInsurance) / 100;                                    
                                    if(rateValue.coverageRate4) calculatedPremium4 = (Number(rateValue.coverageRate4) * targetItem.amountInsurance) / 100;                                    
                                    targetItem.isSelected = true;
                                    targetItem.isExisting = true;
                                    targetItem.disableModeCoverage= true;
                                    targetItem.rate = existingItem.rate;
                                    targetItem.rate = {
                                        ...rateValue,
                                        fixedAmount: calculatedPremium1,
                                        fixedAmount2: calculatedPremium2,
                                        fixedAmount3: calculatedPremium3,
                                        fixedAmount4: calculatedPremium4
                                    };
                                    targetItem.deductible = {
                                        ...deductibleValue
                                    };
                                    targetItem.rebate = {
                                        ...rebateValue
                                    };
                                    targetItem.compositeDisable = false;
                                }
                            } 
                        });
                        let finalDataList = [...currentDataList];
                        if (this.bsnId === '301') {
                            const selectedParent = currentDataList.find(item => 
                                item.parentCoverageId == '0' && item.isSelected == true
                            );
                            if (selectedParent) {
                                console.log('✅ CoverageRate selectedParent IF');
                                this.selectedCoverageId = selectedParent.coverageId;
                            }
                        }
                        // finalDataList = currentDataList.filter(item => 
                        //     (item.rowType == 'BREAKDOWN_RATE' && item.isSelected != true) || 
                        //     (item.id === 'SINGLE_RATE_ID') 
                        // );
                        this.finalizeData(finalDataList);
                    }else{
                        this.finalizeData(baseDataList);
                    }
                })
                .catch(error => {
                    console.error('Error fetching existing coverage:', error);
                });
                this.finalizeData(baseDataList);
            }
            // this.coverageData = [...dynamicRows, singleRateRow];
            // this.coverageDataFormated = [...dynamicRows, singleRateRow];
            // this.applyDisableLogic(null);
        } else if (error) {
            this.coverageData = undefined;
            console.error('Error fetching coverage data:', error);
        }
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
                },
                descriptionRate: descriptionRate
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