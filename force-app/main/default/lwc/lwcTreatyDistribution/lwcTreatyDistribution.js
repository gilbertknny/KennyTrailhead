import { LightningElement, api, track, wire  } from 'lwc';
import getRelatedListRisk from '@salesforce/apex/Aswata_Treaty_Distribution.getRelatedListRisk';
import getTransactionDataOpp from '@salesforce/apex/Aswata_Treaty_Distribution.getTransactionDataOpp';
import getResponseTreaty from '@salesforce/apex/Aswata_Treaty_Distribution.getResponseTreaty';
import saveTreatyDistribution from '@salesforce/apex/Aswata_Treaty_Distribution.saveTreatyDistribution';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
// import CREATEDATE_FIELD from '@salesforce/schema/Quote.CreatedDate';
// import { getRecord } from 'lightning/uiRecordApi';
export default class LwcTreatyDistribution extends LightningElement {
    @api recordId;
    @api recordIdTemp = '0Q0MS000000LEmL0AW';
    @track selectedBusreqId = '';
    @track selectedRiskId = '';
    @track currentRisk = {};
    @track currentFormated = {};
    @track totalSumInsured;
    @track aswataShare;
    @track inputFacultative;
    @track insurancePeriod;
    @track aswataShare;
    @track relatedRisk=[]
    @track isRiskSelectorDisabled = false;
    @track isLoading = false;

    // RISK_KEYS = [
    //     'bppda', 'poolEq', 'poolCustomBond', 
    //     'kark',
    //     'grossRetention', 'quotaShare','surplus', 'facoblig'
    // ];
    // FORMULA_KEYS = ['grossRetention'];
    FORMULA_KEYS = ['underlying','excessLoss'];
    RISK_KEYS = [
        'bppda', 'poolEq', 'poolCustomBond', 
        'kark', 'underlying', 'excessLoss', 
        'grossRetention', 'quotaShare','surplus', 'facoblig'
    ];
    @track responseJson = {
            "status" : "00",
            "message" : "Success",
            "data" : {
            "treaty_dist" : [ {
                "busreq_id" : "024.1010.201.2025.000514.00",
                "risk_id" : "1",
                "seq_id" : "332348428",
                "inception_date" : "2025-12-05 00:00:00.0",
                "currency_code" : "IDR",
                "accum_id" : "685572",
                "tsi100" : null,
                "tsi_wt" : "5000000000.00",
                "tsi_jp" : "0.00",
                "maipark_amt" : "0.00",
                "cbond_amt" : "0.00",
                "bppdan_amt" : "125000000.00",
                "kark_amt" : "0.00",
                "ur_amt" : "4875000000.00",
                "anr_amt" : "4875000000.00",
                "jrofur_amt" : "0.00",
                "xl_amt" : "0.00",
                "gr_amt" : "4875000000.00",
                "jrofgr_amt" : "0.00",
                "qs_amt" : "0.00",
                "sp1_amt" : "0.00",
                "sp2_amt" : "0.00",
                "facoblig_amt" : "0.00",
                "fc_prop_amt" : "0.00",
                "fc_nonprop_pl_amt" : "0.00",
                "fc_nonprop_placed_amt" : "0.00",
                "fc_nonprop_unplaced_amt" : "0.00",
                "sf_amt" : "0.00",
                "sum_distribution_amt" : "5000000000.00",
                "ts_distribution_amt" : "0.00",
                "ts_fc_prop_amt" : "0.00",
                "ts_fc_nonprop_pl_amt" : "0.00",
                "ts_fc_nonprop_placed_amt" : "0.00",
                "ts_fc_nonprop_unplaced_amt" : "0.00",
                "ts_sf_amt" : "0.00",
                "ts_sum_distribution_amt" : "0.00",
                "created_date" : "2025-12-04 14:29:04.0",
                "created_by" : "17",
                "lastupdate_date" : "2025-12-04 14:29:04.0",
                "lastupdate_by" : "17"
                } ],
                "treaty_dist_accum" : [ {
                "busreq_id" : "024.1010.201.2025.000514.00",
                "risk_id" : "1",
                "seq_id" : "332348428",
                "inception_date" : "2025-12-05 00:00:00.0",
                "currency_code" : "IDR",
                "accum_id" : "685572",
                "tsi100" : null,
                "tsi_wt" : "9500000000.00",
                "tsi_jp" : "0.00",
                "maipark_amt" : "0.00",
                "cbond_amt" : "0.00",
                "bppdan_amt" : "237500000.00",
                "kark_amt" : "0.00",
                "ur_amt" : "9262500000.00",
                "anr_amt" : "9262500000.00",
                "jrofur_amt" : "0.00",
                "xl_amt" : "0.00",
                "gr_amt" : "9262500000.00",
                "jrofgr_amt" : "0.00",
                "qs_amt" : "0.00",
                "sp1_amt" : "0.00",
                "sp2_amt" : "0.00",
                "facoblig_amt" : "0.00",
                "fc_prop_amt" : "0.00",
                "fc_nonprop_pl_amt" : "0.00",
                "fc_nonprop_placed_amt" : "0.00",
                "fc_nonprop_unplaced_amt" : "0.00",
                "sf_amt" : "0.00",
                "sum_distribution_amt" : "9500000000.00",
                "ts_distribution_amt" : "0.00",
                "ts_fc_prop_amt" : "0.00",
                "ts_fc_nonprop_pl_amt" : "0.00",
                "ts_fc_nonprop_placed_amt" : "0.00",
                "ts_fc_nonprop_unplaced_amt" : "0.00",
                "ts_sf_amt" : "0.00",
                "ts_sum_distribution_amt" : "0.00",
                "created_date" : "2025-12-04 14:29:01.0",
                "created_by" : "17",
                "lastupdate_date" : "2025-12-04 14:29:04.0",
                "lastupdate_by" : "17"
                } 
            ],
            "max_treaty": {
                "sp1_amt": "850000000000.00",
                "sp2_amt": "0.00",
                "qs_amt": "0.00",
                "ur_amt": "15000000000.00",
                "xl_amt": "35000000000.00",
                "jrofur_amt": "0.00",
                "jrofgr_amt": "0.00",
                "cbond_amt": "0.00",
                "bppdan_amt": "500000000.00",
                "kark_amt": "0.00",
                "maipark_amt": "0.00",
                "anr_amt": "0.00",
                "gr_amt": "50000000000.00",
                "maxtreaty_amt": "900000000000.00",
                "cbond_pct": "0.0",
                "bppdan_pct": "2.5",
                "kark_pct": "100.0",
                "maipark_pct": "0.0",
                "jfur_pct": "0.0",
                "jfgr_pct": "0.0",
                "qs_pct": "0.0"
            }
        }
    }
    @track masterData =[
        {
            "busreq_id": "",
            "dateOpportunity": "",
            "dateQuoteRequest": "",
            "dateAccumulation": "",
            "idAccumulation": "",
            "riskNo": "",
            "riskName": "",
            "location": "",
            "oppyQuoteNo": "",
            "insurancePeriod": "",
            "totalSumInsured100": 0,
            "totalSumInsuredShare": 0,
            "accumulatedSumInsured100": 0,
            "accumulatedSumInsuredShare": 0,
            "listAccumulatedRisk": "",
            "setFacultative":0,
            "bppda":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "poolEq":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "poolCustomBond":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "kark":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "underlying":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "excessLoss":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "grossRetention":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "quotaShare":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "surplus":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            },
            "facoblig":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            }
        }
    ]
    formattedDate(date) {
        if (!date) return '';
        const dateObj = new Date(date);
        const options = { 
            year: 'numeric', 
            month: '2-digit', 
            day: '2-digit'
        };
        // startDate 2024-10-07 endDate 2025-10-07
        return new Intl.DateTimeFormat('id-ID', options).format(dateObj);
    }
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('Page Reference:', JSON.stringify(currentPageReference));
        console.log('recordId from @api:', this.recordId);
        if (!this.recordId && currentPageReference) {
            this.recordId = currentPageReference.state?.recordId || currentPageReference.attributes?.recordId;
        }
        console.log('Detected recordId:', this.recordId);
        if (this.recordId) {
            this.loadDefaultRiskData();
        }        
    }

    async loadDefaultRiskData() {
        if (!this.recordId){
            return;
        }
        this.isLoading = true;
        console.log('recordId: ' + this.recordId);
        try {
            this.aswataShare = 0;
            const data = await getRelatedListRisk({ recordId: this.recordId });
            if (data) {
                this.relatedRisk=data;
                console.log('relatedList ',JSON.stringify(this.relatedRisk));
                const startDate = this.formattedDate(data[0].oppStartDatePeriode);
                const endDate = this.formattedDate(data[0].oppEndDatePeriode);
                this.totalSumInsured = data[0].oppTotalSumInsured;
                this.insurancePeriod = startDate + ' - ' + endDate;
                this.masterData = data.map(item => {
                    console.log('item.oppTotalSumInsured',item.oppTotalSumInsured);
                    let newMasterItem = {
                        "status": "404",
                        "busreq_id": item.busreqId,
                        "dateOpportunity": startDate,
                        "dateQuoteRequest": this.formattedDate(item.quoteReqDate),
                        "dateAccumulation": "",
                        "idAccumulation": item.accumId,
                        "riskId": item.findId,
                        "riskNo": item.riskNo,
                        "riskName": item.riskName,
                        "location": item.addressRisk,
                        "oppyQuoteNo": item.quoteNumber,
                        "insurancePeriod": startDate + ' - ' + endDate,
                        "totalSumInsured100": Number(item.oppTotalSumInsured),
                        "totalSumInsuredShare": 0,
                        "accumulatedSumInsured100": 0,
                        "accumulatedSumInsuredShare": 0,
                        "listAccumulatedRisk": item.opptyName,
                        "setFacultative":0,
                        "bppda":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "poolEq":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "poolCustomBond":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "kark":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "underlying":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "excessLoss":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "grossRetention":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "quotaShare":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "surplus":{ "limit": 0, "accumulation": 0, "capacity": 0 },
                        "facoblig":{ "limit": 0, "accumulation": 0, "capacity": 0 }
                    };
                    return newMasterItem;
                });
                // this.initialDataTreaty();
                console.log('Fetching Opportunity Data:', JSON.stringify(this.masterData));
            } else if (error) {
                console.error('Error fetching Opportunity Data:', error);
            }
        } catch (error) {
            console.error('Error loading default risk data:', error);
        } finally {
            this.isLoading = false;
        }
    }
    get aswataShareAmount() {
        return this.aswataShare?? 0;
    }
    get busreqIdOptions() {
        return this.relatedRisk
        .map(item => ({
            label: item.labelName,
            value: item.findId
        }));
    }

    get sumInsured() {
        return this.totalSumInsured;
    }
    get insurancePeriodDate() {
        return this.insurancePeriod;
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
        console.log();
        return parseFloat(cleanValue);
    }
    async formatDeepClone(sourceObject) {
        if (!sourceObject) return null;
        let formattedClone = JSON.parse(JSON.stringify(sourceObject));
        let finalFormattedData = { ...formattedClone }; 
        this.RISK_KEYS.forEach(key => {
            const component = formattedClone[key];
            if (component && typeof component === 'object') {
                const accumulation = component.accumulation ?? 0;
                const capacity = component.capacity ?? 0;
                const tempLimit = component.limit !== undefined 
                        ? component.limit
                        : (capacity - accumulation);
                finalFormattedData[key] = {    
                    limit: this.formatNumber(tempLimit ?? 0),
                    accumulation: this.formatNumber(component.accumulation ?? 0),
                    capacity: this.formatNumber(component.capacity ?? 0)
                };
            }
        });
        finalFormattedData.totalSumInsured100 = this.formatNumber(finalFormattedData.totalSumInsured100 ?? 0);
        finalFormattedData.totalSumInsuredShare = this.formatNumber(finalFormattedData.totalSumInsuredShare ?? 0);
        finalFormattedData.accumulatedSumInsured100 = this.formatNumber(finalFormattedData.accumulatedSumInsured100 ?? 0);
        finalFormattedData.accumulatedSumInsuredShare = this.formatNumber(finalFormattedData.accumulatedSumInsuredShare ?? 0);
        console.log('finalFormattedData',JSON.stringify(finalFormattedData));
        return finalFormattedData;
    }
    initialDataTreaty(){
        if (this.masterData.length > 0) {
            this.selectedBusreqId = this.masterData[0].busreq_id;
            this.selectedRiskId = this.masterData[0].findId;
            this.currentRisk = this.masterData[0];
            this.masterData = this.masterData.map(item=>{
                item.insurancePeriod = this.insurancePeriod;
                if(item.setFacultative != null){
                    item.isSetFacultativeDisabled = true;
                }
                else{
                    item.isSetFacultativeDisabled = false;
                }
                return item;
            })
            this.RISK_KEYS.forEach(key => {
                const component = this.currentRisk[key];
                const componentFormat = this.currentFormated[key];
                // let isFacultative = (this.currentRisk.setFacultative != null);
                let tempLimit = component?.limit ?? component.capacity - component.accumulation;
                this.currentRisk = {
                    ...this.currentRisk,
                    // isSetFacultativeDisabled:isFacultative,
                    [key]: {
                        ...component,
                        limit: tempLimit
                    }
                };
                this.currentFormated = {
                    ...this.currentFormated,
                    // isSetFacultativeDisabled:isFacultative,
                    [key]: {
                        ...componentFormat,
                        limit: this.formatNumber(tempLimit),
                        accumulation: this.formatNumber(component?.accumulation ?? 0),
                        capacity: this.formatNumber(component?.capacity ?? 0)
                    },
                    setFacultative: this.formatNumber(this.currentRisk.setFacultative ?? 0)
                };
            });
        }
        this.saveChanges();
    }
    connectedCallback() {
        this.initialDataTreaty();
    }
    async handleBusreqIdChange(event){
        this.isRiskSelectorDisabled = true;
        this.isLoading = true;
        let selectRisk = event.detail.value;
        this.selectedRiskId = selectRisk;
        console.log('change',selectRisk);
        // const dataTrxData = this.responseJson;
        const dataTrxData = await getResponseTreaty({ recordId: selectRisk });
        const checkStatusData = this.masterData.find(item => item.riskId == selectRisk && item.status == "200");
        if(!checkStatusData){
            console.log('statusAPI','Hit Baru');
            if (dataTrxData && dataTrxData?.status == "00") {
                await this.getSelectedObject(dataTrxData.data);
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Error',
                    message: dataTrxData?.message || 'Gagal memuat data',
                    variant: 'error',
                }));
            }
        }else{ 
            console.log('statusAPI','Sudah ada'); 
        }
        const selectedObject = this.masterData.find(item => item.riskId === selectRisk);
        if (selectedObject) {
            this.currentRisk = selectedObject;
            this.currentFormated = await this.formatDeepClone(selectedObject);
        } else {
            this.currentRisk = {};
            this.currentFormated = {};
        }
        this.isRiskSelectorDisabled = false;
        this.isLoading = false;
        // this.saveChanges();
        // window.setTimeout(() => {
        //     this.isRiskSelectorDisabled = false;
        // }, 3500);
    }
    async getSelectedObject(apiData) {
        console.log('apiData',apiData);
        const riskIdToUpdate = this.selectedRiskId;
        this.masterData = this.masterData.map(treatyResult => {
            if (treatyResult.riskId === riskIdToUpdate) {
                return this.getUpdatedTreatyData(treatyResult, apiData);
            }
            return treatyResult;
        });
        console.log('MasterData setelah update:', JSON.stringify(this.masterData));
    }
    getUpdatedTreatyData(originalResult, apiData) {
        const dist = apiData.treaty_dist?.[0] || {};
        const accum = apiData.treaty_dist_accum?.[0] || {};
        const max = apiData.max_treaty || {};
        this.aswataShare = Number(dist.tsi_wt);
        this.totalSumInsured = Number(originalResult.totalSumInsured100)
        console.log('this.aswataShare',this.aswataShare);
        console.log('this.totalSumInsured',this.totalSumInsured);
        let underlyingAmount = 0;
        // this.totalSumInsured = Number(dist.tsi_jp);
        let newResult = {
            ...originalResult,
            status: '200',
            busreq_id: dist.busreq_id,
            totalSumInsured100: Number(originalResult.totalSumInsured100),
            totalSumInsuredShare: Number(dist.tsi_wt),
            accumulatedSumInsured100: Number(accum.tsi_jp),
            accumulatedSumInsuredShare: Number(accum.tsi_wt),
            // idAccumulation:accum.accum_id,
            dateAccumulation:accum.inception_date
        };
        const updateComponent = (componentName, distVal, accumVal, maxVal) => {
            let amountLimit = Number(maxVal)?Number(maxVal)-Number(accumVal):Number(distVal);
            const currentComponent = originalResult[componentName] || {}; 
            if(componentName == 'underlying' || componentName == 'excessLoss'){
                underlyingAmount+=amountLimit;
            }
            newResult[componentName] = {
                ...currentComponent,
                limit: amountLimit,
                accumulation: Number(accumVal),
                capacity: Number(maxVal)
            };
            // newResult[componentName] = {
            //     ...currentComponent,
            //     limit: Number(distVal),
            //     accumulation: Number(accumVal),
            //     capacity: Number(maxVal)
            // };
        };
        updateComponent('bppda', dist.bppdan_amt, accum.bppdan_amt, max.bppdan_amt);
        updateComponent('poolEq', dist.maipark_amt, accum.maipark_amt, max.maipark_amt);
        updateComponent('poolCustomBond', dist.cbond_amt, accum.cbond_amt, max.cbond_amt);
        updateComponent('kark', dist.kark_amt, accum.kark_amt, max.kark_amt);
        updateComponent('underlying', dist.ur_amt, accum.ur_amt, max.ur_amt);
        updateComponent('excessLoss', dist.xl_amt, accum.xl_amt, max.xl_amt);
        updateComponent('grossRetention', underlyingAmount, accum.gr_amt, max.gr_amt);
        updateComponent('quotaShare', dist.qs_amt, accum.qs_amt, max.qs_amt);
        updateComponent('surplus', dist.sp1_amt, accum.sp1_amt, max.sp1_amt);
        updateComponent('facoblig', dist.facoblig_amt, accum.facoblig_amt, max.facoblig_amt);
        return newResult;
    }
    async mappingData(responseJson){
        const formattedResponse = {
            treaty_dist: this.formatArray(responseJson.treaty_dist),
            treaty_dist_accum: this.formatArray(responseJson.treaty_dist_accum),
            max_treaty: this.formatObject(responseJson.max_treaty)
        };
        console.log('mappingData',formattedResponse);
        return formattedResponse;
    }
    formatObject(obj){
        let newObj = { ...obj };
        for (const key in newObj) {
            if (key.includes('_amt')) {
                const rawValue = newObj[key];
                if (rawValue != null) {
                    newObj[key] = this.cleanNumber(rawValue);
                }
            }
        }
        return newObj;
    };
    formatArray(arr){
        return arr.map(item => {
            let newItem = { ...item };
            for (const key in newItem) {
                if (key.includes('_amt')) {
                    const rawValue = newItem[key];
                    if (rawValue != null) {
                        newItem[key] = this.cleanNumber(rawValue);
                    }
                }
            }
            return newItem;
        });
    };
    formatCurrency(value) {
        if (!value) return '0';
        return new Intl.NumberFormat('id-ID').format(value);
    }

    calculatePercentageValue(pembilang, pembagi) {
        if (!pembagi || isNaN(pembagi) || pembagi === 0) return 0;
        return (parseFloat(pembilang) / pembagi) * 100;
    }
    getComponentLimitPercentage(componentName) {
        const component = this.currentRisk[componentName];
        const tsi100 = this.totalSumInsured;
        if (!component) return '0';
        const safeLimit = component && component.limit ? component.limit : 0;
        const value = this.calculatePercentageValue(safeLimit, tsi100);
        const numericValue = Number(value);
        return new Intl.NumberFormat('id-ID', {
            useGrouping: false,
            minimumFractionDigits: 1,
            maximumFractionDigits: 2
        }).format(numericValue);
        // return value.toFixed(2);
    }
    getFacultative(componentName) {
        const component = this.currentRisk[componentName];
        const tsi100 = this.totalSumInsured;
        if (!component) return '0';
        const value = this.calculatePercentageValue(component, tsi100);
        const numericValue = Number(value);
        return new Intl.NumberFormat('id-ID', {
            useGrouping: false,
            minimumFractionDigits: 1,
            maximumFractionDigits: 2
        }).format(numericValue);
        // return value.toFixed(2);
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
        if (key === ',' && !value.includes(',')) {
            return; 
        }
        event.preventDefault();
    }
    handleInputFocus(event) {
        const objectName = event.target.dataset.object;
        const field = event.target.dataset.field;
        const rawValue = this.currentRisk?.[objectName]?.[field];
        let updatedFormattedObject = { ...this.currentFormated[objectName] };
        let rawString = '';
        if (rawValue !== null && rawValue !== undefined) {
            rawString = rawValue.toString();
            rawString = rawString.replace('.', ','); 
        }
        updatedFormattedObject[field] = rawString;
        this.currentFormated = {
            ...this.currentFormated,
            [objectName]: updatedFormattedObject
        };
    }
    handleInputBlur(event) {
        const objectName = event.target.dataset.object;
        const field = event.target.dataset.field;
        const inputValue = event.target.value;
        const numericValue = this.cleanNumber(inputValue);
        let updatedRiskObject = { ...this.currentRisk[objectName] };
        updatedRiskObject[field] = numericValue;
        this.currentRisk = {
            ...this.currentRisk,
            [objectName]: updatedRiskObject
        };
        let updatedFormattedObject = { ...this.currentFormated[objectName] };
        updatedFormattedObject[field] = this.formatNumber(numericValue);
        this.currentFormated = {
            ...this.currentFormated,
            [objectName]: updatedFormattedObject
        };
        this.saveChanges();
    }
    handleInputFocusFacultative(event) {
        const field = event.target.dataset.field;
        const rawValue = this.currentRisk?.[field]; 
        this.currentFormated = {
            ...this.currentFormated,
            [field]: (rawValue !== null && rawValue !== undefined) ? rawValue.toString() : ''
        };
    }
    handleInputBlurFacultative(event) {
        const field = event.target.dataset.field;
        const inputValue = event.target.value;
        const numericValue = this.cleanNumber(inputValue);
        this.currentRisk = {
            ...this.currentRisk,
            [field]: numericValue
        };
        this.currentFormated = {
            ...this.currentFormated,
            [field]: this.formatNumber(numericValue)
        };
        const keyId = this.currentRisk.riskId;
        this.masterData = this.masterData.map(item => {
            if (item.findId === keyId) { 
                return {
                    ...item,
                    [field]: numericValue
                };
            }
            return item;
        });
        this.saveChanges();
    }
    get bppdaLimitPercentage() { return this.getComponentLimitPercentage('bppda'); }
    get poolEqLimitPercentage() { return this.getComponentLimitPercentage('poolEq'); }
    get poolCustomBondLimitPercentage() { return this.getComponentLimitPercentage('poolCustomBond'); }
    get karkLimitPercentage() { return this.getComponentLimitPercentage('kark'); }
    get underlyingLimitPercentage() { return this.getComponentLimitPercentage('underlying'); }
    get excessLossLimitPercentage() { return this.getComponentLimitPercentage('excessLoss'); }
    get grossRetentionLimitPercentage() { return this.getComponentLimitPercentage('grossRetention'); }
    get quotaShareLimitPercentage() { return this.getComponentLimitPercentage('quotaShare'); }
    get surplusLimitPercentage() { return this.getComponentLimitPercentage('surplus'); }
    get facobligLimitPercentage() { return this.getComponentLimitPercentage('facoblig'); }
    get facultativePercentage() { return this.getFacultative('setFacultative'); }
    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    handleSave() {
        console.log('Saving recordId: '+this.recordId);
        console.log('Saving selectedRiskId: '+this.selectedRiskId);
        
        const jsonDataString = JSON.stringify(this.masterData.find(item => item.riskId === this.selectedRiskId));
        const idListString = JSON.stringify(this.masterData
            .filter(item => item.riskId === this.selectedRiskId)
            .map(item => ({
            busreqId: item.busreq_id,
            riskId: item.riskId,
            setFacultative: item.setFacultative?? 0,
        })));
        // const jsonDataString = JSON.stringify(this.currentRisk);
        // const idListString = JSON.stringify(this.currentRisk
        //     .map(item => ({
        //     busreqId: item.busreq_id,
        //     riskId: item.riskId,
        //     setFacultative: item.setFacultative?? 0,
        // })));
        console.log('Saving jsonDataString'+jsonDataString);
        saveTreatyDistribution({
            quoteId:this.recordId,
            jsonData: jsonDataString, 
            listId: idListString 
        }).then(() => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Data berhasil disimpan',
                variant: 'success',
            }));
            this.dispatchEvent(new CloseActionScreenEvent());
        })
        .catch(error => {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: error.body.message,
                variant: 'error',
            }));
        })
    }

    saveChanges() {
        const currentbusreq_id = this.currentRisk.busreq_id;
        const indexToUpdate = this.masterData.findIndex(item => item.busreq_id === currentbusreq_id);
        let updatedMasterData = [...this.masterData];
        updatedMasterData[indexToUpdate] = this.currentRisk;
        // updatedMasterData = this.currentRisk;
        this.masterData = updatedMasterData;
        console.log('updatedMasterData',JSON.stringify(this.masterData));
    }

    get totalRiskComponentValues() {
        //set facultative // 13
        const totals = {
            limit: 0,
            tsi: 0,
            accumulation: 0,
            capacity: 0,
            excess:0, //12
            excessPercent:0,
            shareOffered:0, //14 -> sum oppty Offering
            shareOfferedPercent:0,
            accepted:0, //15 -> sum oppty AcceptedApproved
            acceptedPercent:0,
            binding:0, //16 -> sum oppty Binding
            bindingPercent:0,
            pendingBinding:0, //17 -> 15-16
            pendingBindingPercent:0,
            shortfall:0, //18 -> 12-15
            shortfallPercent:0
        };
        const getFromFacultative = 0;
        const getSumOpptyPercentage = 0;
        this.RISK_KEYS.forEach(key => {
            const component = this.currentRisk[key];
            const componentLimit = parseFloat(component?.limit) || 0;
            const resultTotal = (totals.limit || 0) + componentLimit;
            // const excess = this.aswataShare - resultTotal;
            const excess = Math.max(0, this.aswataShare - resultTotal);
            let acceptedValue = getFromFacultative;
            let bindingValue = getFromFacultative;
            if (component) {
                totals.limit = resultTotal;
                if(this.totalSumInsured!=null && this.totalSumInsured!=0){
                    // totals.tsi = this.percentageFixed(parseFloat((resultTotal) / this.totalSumInsured) * 100);
                    // totals.excessPercent = this.percentageFixed((excess/this.totalSumInsured)*100);
                    totals.tsi = this.percentageFixed(parseFloat((resultTotal) / this.totalSumInsured));
                    totals.excessPercent = this.percentageFixed((excess/this.totalSumInsured));
                }
                totals.accumulation += parseFloat(component.accumulation) || 0;
                totals.capacity += parseFloat(component.capacity) || 0;
                totals.excess = parseFloat(excess) || 0;
                totals.shareOffered = getFromFacultative;
                totals.shareOfferedPercent = getSumOpptyPercentage;
                totals.accepted = getFromFacultative;
                totals.acceptedPercent = getSumOpptyPercentage;
                totals.binding = getFromFacultative;
                totals.bindingPercent = getSumOpptyPercentage;
                totals.pendingBinding = acceptedValue - bindingValue;
                totals.pendingBindingPercent = getSumOpptyPercentage;
                totals.shortfall = parseFloat(excess - acceptedValue) || 0;
                totals.shortfallPercent = getSumOpptyPercentage;
            }
        });
        return totals;
    }
    
    percentageFixed(value){
        return value.toFixed(2);
    }

    get totalLimitDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.limit);
        return total;
    }
    
    get totalTsiDisplay() {
        const total = this.totalRiskComponentValues.tsi;
        return total;
    }

    get totalAccumulationDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.accumulation);
        return total;
    }

    get totalCapacityDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.capacity);
        return total;
    }
    get totalExcessDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.excess);
        return total;
    }
    get totalexcessPercentDisplay() {
        const total = this.totalRiskComponentValues.excessPercent;
        return total;
    }
    get totalShareDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.shareOffered);
        return total;
    }
    get totalSharePercentDisplay() {
        const total = this.totalRiskComponentValues.shareOfferedPercent;
        return total;
    }
    get totalAcceptedDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.accepted);
        return total;
    }
    get totalAcceptedPercentDisplay() {
        const total = this.totalRiskComponentValues.acceptedPercent;
        return total;
    }
    get totalBindingDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.binding);
        return total;
    }
    get totalBindingPercentDisplay() {
        const total = this.totalRiskComponentValues.bindingPercent;
        return total;
    }
    get totalPendingBindingDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.pendingBinding);
        return total;
    }
    get totalPendingBindingPercentDisplay() {
        const total = this.getPercentageValue(this.totalRiskComponentValues.pendingBinding);
        return total;
    }
    get totalShortfallDisplay() {
        const total = this.formatNumber(this.totalRiskComponentValues.shortfall);
        return total;
    }
    get totalShortfallPercentDisplay() {
        const total = this.getPercentageValue(this.totalRiskComponentValues.shortfall);
        return total;
    }
    getPercentageValue(amount) {
        const tsi100 = this.totalSumInsured;
        const value = this.calculatePercentageValue(amount, tsi100);
        const numericValue = Number(value);
        return new Intl.NumberFormat('id-ID', {
            useGrouping: false,
            minimumFractionDigits: 1,
            maximumFractionDigits: 2
        }).format(numericValue);
        // return value.toFixed(2);
    }
}