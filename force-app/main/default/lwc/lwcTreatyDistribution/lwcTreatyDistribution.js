import { LightningElement, api, track, wire  } from 'lwc';
import getRelatedListRisk from '@salesforce/apex/Aswata_Treaty_Distribution.getRelatedListRisk';
import getTransactionDataOpp from '@salesforce/apex/Aswata_Treaty_Distribution.getTransactionDataOpp';
import saveTreatyDistribution from '@salesforce/apex/Aswata_Treaty_Distribution.saveTreatyDistribution';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
export default class LwcTreatyDistribution extends LightningElement {
    @api recordId;
    @api recordIdTemp = '0Q0MS000000LEmL0AW';
    @track selectedBusreqId = '';
    @track currentRisk = {};
    @track totalSumInsured;
    @track inputFacultative;
    @track insurancePeriod;
    @track aswataShare;

    
    RISK_KEYS = [
        'bppda', 'poolEq', 'poolCustomBond', 
        'kark', 'underlying', 'excessLoss', 
        'grossRetention', 'quotaShare','surplus', 'facoblig'
    ];

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
                "capacity": 1500
            },
            "facoblig":{
                "limit": 0,
                "accumulation": 0,
                "capacity": 0
            }
        }
    ]
    @track picklistMaster=[]
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
            const dataTrxData = await getTransactionDataOpp({ recordId: this.recordId });
            this.aswataShare = dataTrxData.Amount__c
            console.log('Fetching Transaction Data:', dataTrxData);
            // fetch oppty
            const data = await getRelatedListRisk({ recordId: this.recordId });
            if (data) {
                this.picklistMaster=data;
                console.log('relatedList ',data);
                this.totalSumInsured = data[0].oppTotalSumInsured;
                const jsonString = data[0].treatyResponse;
                const startDate = this.formattedDate(data[0].oppStartDatePeriode);
                const endDate = this.formattedDate(data[0].oppEndDatePeriode);
                this.insurancePeriod = startDate + ' - ' + endDate;
                console.log('startDate', startDate, 'endDate', endDate);
                if(jsonString){
                    // this.masterData = JSON.parse(jsonString);
                    this.masterData = JSON.parse(jsonString).map(item => ({
                        ...item,
                        findId: item.busreq_id+item.riskNo
                    }));
                }
                console.log('modifiedTreatyArray',JSON.stringify(this.masterData));
                this.initialDataTreaty();
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
        // return this.masterData.map(item => ({
        return this.picklistMaster.map(item => ({
            label: item.labelName,
            // value: item.busreq_id
            value: item.findId
        }));
    }

    get sumInsured() {
        return this.totalSumInsured;
    }
    get insurancePeriodDate() {
        return this.insurancePeriod;
    }
    
    initialDataTreaty(){
        if (this.masterData.length > 0) {
            // this.selectedBusreqId = this.masterData[0].busreq_id;
            this.selectedBusreqId = this.masterData[0].findId;
            this.currentRisk = this.masterData[0];
            this.masterData = this.masterData.map(item=>{
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
            });
        }
        this.saveChanges();
    }
    connectedCallback() {
        this.initialDataTreaty();
    }
    handleBusreqIdChange(event) {
        this.selectedBusreqId = event.detail.value;
        console.log('change',event.detail.value);
        // const selectedObject = this.masterData.find(item => item.busreq_id === this.selectedBusreqId);
        const selectedObject = this.masterData.find(item => item.findId === this.selectedBusreqId);
        if (selectedObject) {
            this.currentRisk = selectedObject;
        } else {
            this.currentRisk = {};
        }
    }

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
        const value = this.calculatePercentageValue(component.limit, tsi100);
        return value.toFixed(2);
    }
    getFacultative(componentName) {
        const component = this.currentRisk[componentName];
        const tsi100 = this.totalSumInsured;
        if (!component) return '0';
        const value = this.calculatePercentageValue(component, tsi100);
        return value.toFixed(2);
    }
    handleInputChange(event) {
        const objectName = event.target.dataset.object;
        const field = event.target.dataset.field;
        const value = event.detail.value;
        console.log('objectName',objectName);
        let updatedObject = { ...this.currentRisk[objectName] };
        updatedObject[field] = parseFloat(value) || 0;
        
        this.currentRisk = {
            ...this.currentRisk,
            [objectName]: updatedObject
        };
        this.saveChanges();
        // console.log(JSON.stringify(this.currentRisk));
    }
    handleInputFacultative(event) {
        const field = event.target.dataset.field;
        const value = event.detail.value;
        console.log(field,value);
        const numericValue = parseFloat(value) || 0;
        this.inputFacultative = numericValue;
        this.currentRisk = {
            ...this.currentRisk,
            [field]: numericValue
        };
        this.masterData = this.masterData.map(item => {
            return {
                ...item,
                [field]: numericValue
            };
        });
        // console.log(JSON.stringify(this.masterData));
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
        console.log('Saving this.recordId'+this.recordId);
        
        const jsonDataString = JSON.stringify(this.masterData);
        const idListString = JSON.stringify(this.masterData.map(item => ({
            busreqId: item.busreq_id,
            riskId: item.riskNo,
            setFacultative:this.inputFacultative? this.inputFacultative : 0,
        })));
        console.log('Saving idListString'+idListString);
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
        this.masterData = updatedMasterData;
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
            const resultTotal = totals.limit + parseFloat(component.limit) || 0;
            const excess = this.totalSumInsured-resultTotal;
            if (component) {
                totals.limit = resultTotal;
                totals.tsi = this.percentageFixed(parseFloat((resultTotal) / this.totalSumInsured) * 100);
                totals.accumulation += parseFloat(component.accumulation) || 0;
                totals.capacity += parseFloat(component.capacity) || 0;
                totals.excess = excess;
                totals.excessPercent = this.percentageFixed((excess/this.totalSumInsured)*100);
                totals.shareOffered = getFromFacultative;
                totals.shareOfferedPercent = getSumOpptyPercentage;
                totals.accepted = getFromFacultative;
                totals.acceptedPercent = getSumOpptyPercentage;
                totals.binding = getFromFacultative;
                totals.bindingPercent = getSumOpptyPercentage;
                totals.pendingBinding = getFromFacultative;
                totals.pendingBindingPercent = getSumOpptyPercentage;
                totals.shortfall = getFromFacultative;
                totals.shortfallPercent = getSumOpptyPercentage;
            }
        });
        
        return totals;
    }
    
    percentageFixed(value){
        return value.toFixed(2);
    }

    get totalLimitDisplay() {
        const total = this.totalRiskComponentValues.limit;
        return total;
    }
    
    get totalTsiDisplay() {
        const total = this.totalRiskComponentValues.tsi;
        return total;
    }

    get totalAccumulationDisplay() {
        const total = this.totalRiskComponentValues.accumulation;
        return total;
    }

    get totalCapacityDisplay() {
        const total = this.totalRiskComponentValues.capacity;
        return total;
    }
    get totalExcessDisplay() {
        const total = this.totalRiskComponentValues.excess;
        return total;
    }
    get totalexcessPercentDisplay() {
        const total = this.totalRiskComponentValues.excessPercent;
        return total;
    }
    get totalShareDisplay() {
        const total = this.totalRiskComponentValues.shareOffered;
        return total;
    }
    get totalSharePercentDisplay() {
        const total = this.totalRiskComponentValues.shareOfferedPercent;
        return total;
    }
    get totalAcceptedDisplay() {
        const total = this.totalRiskComponentValues.accepted;
        return total;
    }
    get totalAcceptedPercentDisplay() {
        const total = this.totalRiskComponentValues.acceptedPercent;
        return total;
    }
    get totalBindingDisplay() {
        const total = this.totalRiskComponentValues.binding;
        return total;
    }
    get totalBindingPercentDisplay() {
        const total = this.totalRiskComponentValues.bindingPercent;
        return total;
    }
    get totalPendingBindingDisplay() {
        const total = this.totalRiskComponentValues.pendingBinding;
        return total;
    }
    get totalPendingBindingPercentDisplay() {
        const total = this.totalRiskComponentValues.pendingBindingPercent;
        return total;
    }
    get totalShortfallDisplay() {
        const total = this.totalRiskComponentValues.shortfall;
        return total;
    }
    get totalShortfallPercentDisplay() {
        const total = this.totalRiskComponentValues.shortfallPercent;
        return total;
    }
}