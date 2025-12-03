import LightningModal from 'lightning/modal';
import { track,api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getPicklistSTD from '@salesforce/apex/ClsNewRequest.getPicklist';
import getCurrency from '@salesforce/apex/ClsNewRequest.getCurrency';
import getCoverage from '@salesforce/apex/ClsNewRequest.getCoverage';
import getCoverageDetail from '@salesforce/apex/ClsNewRequest.getCoverageDetail';

export default class LwcNewRequestMOU extends LightningModal {
    @api records;
    @api record;
    @api contractId;
    @track labelAdd = 'Add';
    @track isLoading;
    @track coverageId;
    @track coverageName;
    @track proposedFixedAmountOld;
    @track proposedFixedAmount;
    @track deductiblePCT;
    @track deductibleId;
    @track deductibleName;
    @track minimumCurId;
    @track minimumCurName;
    @track minimumAmount;
    @track banksFee;
    @track agentComission;
    @track brokerComission;
    @track generalRPremiumPCT;
    @track overdngComission;
    @track maxPerson;
    @track coverage = [];
    @track deductible = [];
    @track minimumCur = [];

    connectedCallback() {
        console.log('records:'+JSON.stringify(this.records));
        console.log('record:'+JSON.stringify(this.record));
        console.log('contractId:'+this.contractId);
        if(this.contractId != undefined && this.contractId != ''){
            this.getPicklistCoverage();
        }
        this.getPicklistDeductible();
        this.getPicklistCurrency();
        if(this.record != undefined){
            this.labelAdd = 'Update';
            this.coverageId = this.record.coverageId;
            this.coverageName = this.record.coverageName;
            this.proposedFixedAmountOld = this.record.proposedFixedAmountOld;
            this.proposedFixedAmount = this.record.proposedFixedAmount;
            this.deductiblePCT = this.record.deductiblePCT;
            this.deductibleId = this.record.deductibleId;
            this.deductibleName = this.record.deductibleName;
            this.minimumCurId = this.record.minimumCurId;
            this.minimumAmount = this.record.minimumAmount;
            this.banksFee = this.record.banksFee;
            this.agentComission = this.record.agentComission;
            this.brokerComission = this.record.brokerComission;
            this.generalRPremiumPCT = this.record.generalRPremiumPCT;
            this.overdngComission = this.record.overdngComission;
            this.maxPerson = this.record.maxPerson;
        }
    }

    getPicklistCoverage(){
        getCoverage({
            contractid : this.contractId
        })
        .then(result => {
            this.coverage = [];
            for (var key in result) {
                this.coverage.push({label:result[key], value:key});
            }
            return this.coverage;
        })
        .catch(error => {
            console.log('error-getPicklistCoverage:'+ error.message);
        });
    }

    getPicklistDeductible(){
        getPicklistSTD({
            objectName : 'InsurancePolicyCoverage',
            fieldName : 'Deductible__c'
        })
        .then(result => {
            this.deductible = [];
            for (var key in result) {
                this.deductible.push({label:result[key], value:key});
            }
            return this.deductible;
        })
        .catch(error => {
            console.log('error-getPicklistDeductible:'+ error.message);
        });
    }

    getPicklistCurrency(){
        getCurrency({})
        .then(result => {
            this.minimumCur = [];
            for (var key in result) {
                this.minimumCur.push({label:result[key], value:result[key]});
            }
            return this.minimumCur;
        })
        .catch(error => {
            console.log('error-getPicklistCurrency:'+ error.message);
        });
    }

    getDataCoverageDetail(){
        getCoverageDetail({
            contractid : this.contractId,
            coverageid : this.coverageId
        })
        .then(result => {
            if(result != null){
                console.log('result:'+JSON.stringify(result));
                this.proposedFixedAmountOld = result.Proposed_Fixed_Amount__c;
                this.proposedFixedAmount = result.Proposed_Fixed_Amount__c;
                this.deductiblePCT = result.Deductible_PCT__c;
                this.deductibleId = result.Deductible__c;
                if(this.deductibleId != undefined && this.deductibleId != ''){
                    this.deductibleName = this.deductible.find(item => item.value === this.deductibleId).label;
                }
                this.minimumCurId = result.Minimum_Cur_ID__c;
                if(this.minimumCurId != undefined && this.minimumCurId != ''){
                    this.minimumCurName = this.minimumCur.find(item => item.value === this.minimumCurId).label;
                }
                this.minimumAmount = result.Minimum_Amount__c;
                this.banksFee = result.Banks_Fee__c;
                this.agentComission = result.Agent_Comission__c;
                this.brokerComission = result.Broker_Comission__c;
                this.generalRPremiumPCT = result.General_RPremium_PCT__c;
                this.overdngComission = result.Overdng_Comission__c;
                this.maxPerson = result.max_person__c; 
            }
        })
        .catch(error => {
            console.log('error-getDataCoverageDetail:'+ error.message);
        });
    }

    handleCoverage(e){
        this.coverageId = e.detail.value;
        this.coverageName = this.coverage.find(item => item.value === this.coverageId).label;
        if(this.coverageId != undefined && this.coverageId != ''){
            this.getDataCoverageDetail();
        }
    }

    handleProposedFixedAmount(e){
        this.proposedFixedAmount = e.detail.value;
    }

    handleDeductiblePCT(e){
        this.deductiblePCT = e.detail.value;
    }

    handleDeductible(e){
        this.deductibleId = e.detail.value;
        this.deductibleName = this.deductible.find(item => item.value === this.deductibleId).label;
    }

    handleMinimumCurId(e){
        this.minimumCurId = e.detail.value;
        this.minimumCurName = this.minimumCur.find(item => item.value === this.minimumCurId).label;
    }

    handleMinimumAmount(e){
        this.minimumAmount = e.detail.value;
    }

    handleBanksFee(e){
        this.banksFee = e.detail.value;
    }

    handleAgentComission(e){
        this.agentComission = e.detail.value;
    }

    handleBrokerComission(e){
        this.brokerComission = e.detail.value;
    }

    handleGeneralRPremiumPCT(e){
        this.generalRPremiumPCT = e.detail.value;
    }

    handleOverdngComission(e){
        this.overdngComission = e.detail.value;
    }

    handleMaxPerson(e){
        this.maxPerson = e.detail.value;
    }
    
    handleCancel(e){
        this.close('cancel');
    }

    handleAdd(e){
        let rateold = this.proposedFixedAmountOld;
        let rate = this.proposedFixedAmount;
        console.log('rateold:'+rateold);
        console.log('rate:'+rate);
        if(this.coverageId === undefined || this.coverageId === ''){
            LightningAlert.open({message: 'Please Select Coverage!',theme: 'error',label: 'Error!'});
        }else if(this.proposedFixedAmount === undefined || this.proposedFixedAmount === ''){
            LightningAlert.open({message: 'Please Fill Proposed Rate!',theme: 'error',label: 'Error!'});
        }else if(rate < rateold && rateold != undefined){
            LightningAlert.open({message: 'Please Change the Proposed Rate min '+rateold +'!',theme: 'error',label: 'Error!'});
        }else if(this.deductiblePCT === undefined || this.deductiblePCT === ''){
            LightningAlert.open({message: 'Please Fill Deductible PCT!',theme: 'error',label: 'Error!'});
        }else if(this.deductibleId === undefined || this.deductibleId === ''){
            LightningAlert.open({message: 'Please Select Deductible Flag!',theme: 'error',label: 'Error!'});
        }else if(this.minimumCurId === undefined || this.minimumCurId === ''){
            LightningAlert.open({message: 'Please Select Minimum Currency!',theme: 'error',label: 'Error!'});
        }else if(this.minimumAmount === undefined || this.minimumAmount === ''){
            LightningAlert.open({message: 'Please Fill Minimum Amount!',theme: 'error',label: 'Error!'});
        }else if(this.banksFee === undefined || this.banksFee === ''){
            LightningAlert.open({message: 'Please Fill Banks Fee!',theme: 'error',label: 'Error!'});
        }else if(this.agentComission === undefined || this.agentComission === ''){
            LightningAlert.open({message: 'Please Fill Agent Comission!',theme: 'error',label: 'Error!'});
        }else if(this.brokerComission === undefined || this.brokerComission === ''){
            LightningAlert.open({message: 'Please Fill Broker Comission!',theme: 'error',label: 'Error!'});
        }else if(this.generalRPremiumPCT === undefined || this.generalRPremiumPCT === ''){
            LightningAlert.open({message: 'Please Fill Commission!',theme: 'error',label: 'Error!'});
        }else if(this.overdngComission === undefined || this.overdngComission === ''){
            LightningAlert.open({message: 'Please Fill Overiding!',theme: 'error',label: 'Error!'});
        }else if(this.maxPerson === undefined || this.maxPerson === ''){
            LightningAlert.open({message: 'Please Fill Max Person!',theme: 'error',label: 'Error!'});
        }else{
            console.log('record:'+JSON.stringify(this.record));
            if(this.record != undefined){
                console.log('update');
                try{
                    let newdata = [];
                    for(let i=0;i<this.records.length;i++){
                        if(this.records[i].Id == this.record.Id){
                            let data = {
                                Id : this.record.Id,
                                coverageId : this.coverageId,
                                coverageName : this.coverageName,
                                proposedFixedAmountOld : this.proposedFixedAmountOld,
                                proposedFixedAmount : this.proposedFixedAmount,
                                deductiblePCT : this.deductiblePCT,
                                deductibleId : this.deductibleId,
                                deductibleName : this.deductibleName,
                                minimumCurId : this.minimumCurId,
                                minimumCurName : this.minimumCurName,
                                minimumAmount : this.minimumAmount,
                                banksFee : this.banksFee,
                                agentComission : this.agentComission,
                                brokerComission : this.brokerComission,
                                generalRPremiumPCT : this.generalRPremiumPCT,
                                overdngComission : this.overdngComission,
                                maxPerson : this.maxPerson
                            }
                            newdata = [...newdata,data];
                        }else{
                            newdata = [...newdata,this.records[i]];
                        }   
                    }
                    console.log('newdata:'+JSON.stringify(newdata));
                    this.records = newdata;
                    this.close(this.records);
                }catch(error){
                    //console.log('error:'+error.message);
                    LightningAlert.open({message: error.message,theme: 'error',label: 'Error!'});
                }
            }else{
                let jum = this.records.length;
                //console.log('jum:'+jum);
                if(jum == 0) jum++;
                else{
                    let Id = this.records[jum-1].Id;
                    //console.log('Id:'+Id);
                    jum = parseInt(Id,10)+1;
                }
                //console.log('jum:'+jum);

                let data = {
                    Id:jum.toString(),
                    coverageId : this.coverageId,
                    coverageName : this.coverageName,
                    proposedFixedAmountOld : this.proposedFixedAmountOld,
                    proposedFixedAmount : this.proposedFixedAmount,
                    deductiblePCT : this.deductiblePCT,
                    deductibleId : this.deductibleId,
                    deductibleName : this.deductibleName,
                    minimumCurId : this.minimumCurId,
                    minimumCurName : this.minimumCurName,
                    minimumAmount : this.minimumAmount,
                    banksFee : this.banksFee,
                    agentComission : this.agentComission,
                    brokerComission : this.brokerComission,
                    generalRPremiumPCT : this.generalRPremiumPCT,
                    overdngComission : this.overdngComission,
                    maxPerson : this.maxPerson,
                };
                this.records = [
                    ...this.records,
                    data
                ];
                //console.log('this.records:'+JSON.stringify(this.records));
                this.close(this.records);
            }
        }
    }
}