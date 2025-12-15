import LightningModal from 'lightning/modal';
import { track,api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getPicklistSTD from '@salesforce/apex/ClsNewRequest.getPicklist';
import getCurrency from '@salesforce/apex/ClsNewRequest.getCurrency';
import getCoverage from '@salesforce/apex/ClsNewRequest.getCoverage';
import getCoverageDetail from '@salesforce/apex/ClsNewRequest.getCoverageDetail';
import getSectionDetail from '@salesforce/apex/ClsNewRequest.getSectionDetail';

export default class LwcNewRequestCoverage extends LightningModal {
    @api records;
    @api record;
    @api recordid;
    @api assets;
    @api type;
    @track labelAdd = 'Add';
    @track isLoading;
    @track section = new Array();
    @track coverage = [];
    @track deductible = [];
    @track minimumCur = [];
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
    @track totalAmount = 0;
    @track dataCoverage = [];

    connectedCallback() {
        console.log('LwcNewRequestCoverage');
        console.log('this.records:'+ JSON.stringify(this.records));
        console.log('this.record:'+ JSON.stringify(this.record));
        console.log('this.recordid:'+ this.recordid);
        console.log('this.assets:'+ JSON.stringify(this.assets));
        if(this.assets != undefined){
            for(let i=0;i<this.assets.length;i++){
                let sectionId = this.assets[i].sectionId;
                this.section.push(sectionId);
                let amount = this.assets[i].sumInsuredIDR;
                this.totalAmount += amount;
            }
            console.log('section:'+JSON.stringify(this.section));
            console.log('totalAmount:'+this.totalAmount);
            if(this.section != undefined){
                if(this.record == undefined) this.getDataSectionDetail();
                this.getPicklistCoverage();
            }
            if(this.record != undefined){
                this.labelAdd = 'Update';
                this.coverageId = this.record.coverageId;
                this.coverageName = this.record.coverageName;
                let records = this.records;
                console.log('dataCoverage:'+JSON.stringify(records));
                if(records != undefined){
                    let data = [];
                    for(let i=0;i<records.length;i++){
                        if(records[i].Id == this.record.Id){
                            data.push({
                                Id:this.record.Id, 
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:records[i].coverageId,
                                coverageName:records[i].coverageName,
                                proposedFixedAmount : records[i].proposedFixedAmount,
                                deductiblePCT : records[i].deductiblePCT,
                                deductibleId :records[i].deductibleId,
                                deductibleName : records[i].deductibleName,
                                minimumCurId : records[i].minimumCurId,
                                minimumCurName : records[i].minimumCurName,
                                minimumAmount : records[i].minimumAmount,
                                banksFee : records[i].banksFee,
                                agentComission : records[i].agentComission,
                                brokerComission : records[i].brokerComission,
                                generalRPremiumPCT : records[i].generalRPremiumPCT,
                                overdngComission : records[i].overdngComission,
                                maxPerson : records[i].maxPerson
                            });
                        }
                    }
                    console.log('data:'+JSON.stringify(data));
                    this.dataCoverage = data;
                }
            }
        }
    }

    getDataSectionDetail(){
        getSectionDetail({
            recordids : JSON.stringify(this.section)
        })
        .then(result => {
            let data = [];
            for(let i=0;i<result.length;i++){
                let sectionName = 'Section ' + result[i].Section__c + ' - ' + result[i].Name;
                data.push({
                    sectionId:result[i].Id, 
                    sectionName:result[i].Name,
                    sectionLabel:sectionName,
                    section:result[i].Section__c,
                });
            }
            this.dataCoverage = data;
        })
        .catch(error => {
            console.log('error-getDataSectionDetail:'+ error.message);
        });
    }

    getPicklistCoverage(){
        getCoverage({
            contractid : this.recordid,
            assetsection : JSON.stringify(this.section),
            assetcategory : undefined,
            suminsured : this.totalAmount,
            type : this.type
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

    getDataCoverageDetail(){
        getCoverageDetail({
            contractid : this.recordid,
            coverageid : this.coverageId,
            assetsection : JSON.stringify(this.section),
            type : this.type
        })
        .then(result => {
            if(result != null){
                console.log('result:'+JSON.stringify(result));
                const mapResult = new Map(result.map(item => [item.Asset__r.Section__c, item]));
                let records = this.dataCoverage;
                if(records != undefined){
                    let data = [];
                    for(let i=0;i<records.length;i++){
                        let resultcoverage = mapResult.get(records[i].sectionId);
                        console.log('resultcoverage:'+JSON.stringify(resultcoverage));
                        if(resultcoverage != undefined){
                            data.push({
                                Id:records[i].Id,
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:this.coverageId,
                                coverageName:this.coverageName,
                                proposedFixedAmount : resultcoverage.Proposed_Fixed_Amount__c,
                                deductiblePCT : resultcoverage.Deductible_PCT__c,
                                deductibleId :resultcoverage.Deductible__c,
                                deductibleName : resultcoverage.DeductibleName,
                                minimumCurId : resultcoverage.Minimum_Cur_ID__c,
                                minimumCurName : resultcoverage.Minimum_Cur_ID__c,
                                minimumAmount : resultcoverage.Minimum_Amount__c,
                                banksFee : resultcoverage.Banks_Fee__c,
                                agentComission : resultcoverage.Agent_Comission__c,
                                brokerComission : resultcoverage.Broker_Comission__c,
                                generalRPremiumPCT : resultcoverage.General_RPremium_PCT__c,
                                overdngComission : resultcoverage.Overdng_Comission__c,
                                maxPerson : resultcoverage.max_person__c
                            });
                        }else{
                            data.push({
                                Id:records[i].Id,
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:this.coverageId,
                                coverageName:this.coverageName,
                            });
                        }

                        /*if(records[i].section == 1){
                            data.push({
                                Id:records[i].Id,
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:this.coverageId,
                                coverageName:this.coverageName,
                                proposedFixedAmount : result.Proposed_Fixed_Amount__c,
                                deductiblePCT : result.Deductible_PCT__c,
                                deductibleId :result.Deductible__c,
                                deductibleName : result.DeductibleName,
                                minimumCurId : result.Minimum_Cur_ID__c,
                                minimumCurName : result.Minimum_Cur_ID__c,
                                minimumAmount : result.Minimum_Amount__c,
                                banksFee : result.Banks_Fee__c,
                                agentComission : result.Agent_Comission__c,
                                brokerComission : result.Broker_Comission__c,
                                generalRPremiumPCT : result.General_RPremium_PCT__c,
                                overdngComission : result.Overdng_Comission__c,
                                maxPerson : result.max_person__c
                            });
                        }else if(records[i].section == 2){
                            data.push({
                                Id:records[i].Id,
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:this.coverageId,
                                coverageName:this.coverageName,
                                proposedFixedAmount : result.Proposed_Fixed_Amount_Section_2__c,
                                deductiblePCT : result.Deductible_PCT_Section_2__c,
                                deductibleId :result.Deductible_Section_2__c,
                                deductibleName : result.DeductibleName2,
                                minimumCurId : result.Minimum_Cur_ID_Section_2__c,
                                minimumCurName : result.Minimum_Cur_ID_Section_2__c,
                                minimumAmount : result.Minimum_Amount_Section_2__c,
                                banksFee : result.Banks_Fee_Section_2__c,
                                agentComission : result.Agent_Comission_Section_2__c,
                                brokerComission : result.Broker_Comission_Section_2__c,
                                generalRPremiumPCT : result.General_RPremium_PCT_Section_2__c,
                                overdngComission : result.Overdng_Comission_Section_2__c,
                                maxPerson : result.Max_Person_Section_2__c
                            });
                        }else if(records[i].section == 3){
                            data.push({
                                Id:records[i].Id,
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:this.coverageId,
                                coverageName:this.coverageName,
                                proposedFixedAmount : result.Proposed_Fixed_Amount_Section_3__c,
                                deductiblePCT : result.Deductible_PCT_Section_3__c,
                                deductibleId :result.Deductible_Section_3__c,
                                deductibleName : result.DeductibleName3,
                                minimumCurId : result.Minimum_Cur_ID_Section_3__c,
                                minimumCurName : result.Minimum_Cur_ID_Section_3__c,
                                minimumAmount : result.Minimum_Amount_Section_3__c,
                                banksFee : result.Banks_Fee_Section_3__c,
                                agentComission : result.Agent_Comission_Section_3__c,
                                brokerComission : result.Broker_Comission_Section_3__c,
                                generalRPremiumPCT : result.General_RPremium_PCT_Section_3__c,
                                overdngComission : result.Overdng_Comission_Section_3__c,
                                maxPerson : result.Max_Person_Section_3__c
                            });
                        }else if(records[i].section == 4){
                            data.push({
                                Id:records[i].Id,
                                sectionId:records[i].sectionId, 
                                sectionName:records[i].sectionName, 
                                sectionLabel:records[i].sectionLabel,
                                section:records[i].section, 
                                coverageId:this.coverageId,
                                coverageName:this.coverageName,
                                proposedFixedAmount : result.Proposed_Fixed_Amount_Section_4__c,
                                deductiblePCT : result.Deductible_PCT_Section_4__c,
                                deductibleId :result.Deductible_Section_4__c,
                                deductibleName : result.DeductibleName4,
                                minimumCurId : result.Minimum_Cur_ID_Section_4__c,
                                minimumCurName : result.Minimum_Cur_ID_Section_4__c,
                                minimumAmount : result.Minimum_Amount_Section_4__c,
                                banksFee : result.Banks_Fee_Section_4__c,
                                agentComission : result.Agent_Comission_Section_4__c,
                                brokerComission : result.Broker_Comission_Section_4__c,
                                generalRPremiumPCT : result.General_RPremium_PCT_Section_4__c,
                                overdngComission : result.Overdng_Comission_Section_4__c,
                                maxPerson : result.Max_Person_Section_4__c
                            });
                        }*/
                        
                    }
                    console.log('data:'+JSON.stringify(data));
                    this.dataCoverage = data;
                }
            }
        })
        .catch(error => {
            console.log('error-getDataCoverageDetail:'+ error.message);
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

    handleCoverage(e){
        this.coverageId = e.detail.value;
        this.coverageName = this.coverage.find(item => item.value === this.coverageId).label;
        if(this.coverageId != undefined){
            this.getDataCoverageDetail();
        }
    }

    handleCancel(e){
        this.close('cancel');
    }

    handleAdd(e){
        console.log('coverageId:'+this.coverageId);
        if(this.coverageId === undefined || this.coverageId === ''){
            LightningAlert.open({message: 'Please Select Coverage!',theme: 'error',label: 'Error!'});
        }else{
            if(this.record != undefined){
                try{
                    let newdata = [];
                    for(let i=0;i<this.records.length;i++){
                        if(this.records[i].Id == this.record.Id){
                            for(let j=0;j<this.dataCoverage.length;j++){
                                let data = this.dataCoverage[j];
                                if(data.Id == this.record.Id && data.section == this.records[i].section){
                                    newdata = [...newdata,data];
                                    break;
                                }
                            }
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
                if(jum == 0) jum++;
                else{
                    let Id = this.records[jum-1].Id;
                    jum = parseInt(Id,10)+1;
                }

                let records = this.dataCoverage;
                for(let i=0;i<records.length;i++){
                    let data = {
                        Id:jum.toString(),
                        sectionId : records[i].sectionId,
                        sectionName : records[i].sectionName,
                        sectionLabel : records[i].sectionLabel,
                        section : records[i].section,
                        coverageId : records[i].coverageId,
                        coverageName : records[i].coverageName,
                        proposedFixedAmount : records[i].proposedFixedAmount,
                        deductiblePCT : records[i].deductiblePCT,
                        deductibleId : records[i].deductibleId,
                        deductibleName : records[i].deductibleName,
                        minimumCurId : records[i].minimumCurId,
                        minimumCurName : records[i].minimumCurName,
                        minimumAmount : records[i].minimumAmount,
                        banksFee : records[i].banksFee,
                        agentComission : records[i].agentComission,
                        brokerComission : records[i].brokerComission,
                        generalRPremiumPCT : records[i].generalRPremiumPCT,
                        overdngComission : records[i].overdngComission,
                        maxPerson : records[i].maxPerson,
                    };
                    this.records = [
                        ...this.records,
                        data
                    ];
                }
                this.close(this.records);
            }
        }
    }
}