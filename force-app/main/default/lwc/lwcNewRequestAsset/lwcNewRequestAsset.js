import LightningModal from 'lightning/modal';
import { track,api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getRate from '@salesforce/apex/ClsNewRequest.getRate';
import getSection from '@salesforce/apex/ClsNewRequest.getAssetSectionMOU';
import getCategory from '@salesforce/apex/ClsNewRequest.getAssetCategoryMOU';
import getCurrency from '@salesforce/apex/ClsNewRequest.getCurrency';
import getSectionAmount from '@salesforce/apex/ClsNewRequest.getSectionAmount';
import getMasterDataDetailAsset from '@salesforce/apex/ClsNewRequest.getMasterDataDetailAsset';

export default class LwcNewRequestAsset extends LightningModal {
    @api records;
    @api record;
    @api recordid;
    @api type;
    @api contracttypeid;
    @track labelAdd = 'Add';
    @track isLoading;
    @track section = [];
    @track category = [];
    @track currency = [];
    @track disabledSection;
    @track sectionId;
    @track sectionName;
    @track sectionLabel;
    @track categoryId;
    @track categoryName;
    @track currencyId;
    @track currencyName;
    @track sumInsured;
    @track sumInsuredIDR;
    @track showIDR;
    @track rate;
    @track balanceAmount;
    @track data;
    @track isShowSection;
    @track mapInputDetail = new Map();

    connectedCallback() {
        //console.log('records:'+JSON.stringify(this.records));
        //console.log('record:'+JSON.stringify(this.record));
        this.disabledSection = false;
        this.getPicklistSection();
        this.getPicklistCurrency();
        if(this.record != undefined){
            //this.disabledSection = true;
            this.labelAdd = 'Update';
            this.sectionId = this.record.sectionId;
            this.sectionName = this.record.sectionName;
            if(this.sectionId != undefined) this.getPicklistCategory();
            this.sectionLabel = 'Section ' + this.sectionName; 
            this.categoryId = this.record.categoryId;
            this.categoryName = this.record.categoryName;
            this.currencyId = this.record.currencyId;
            this.currencyName = this.record.currencyName;
            this.sumInsured = this.record.sumInsured;
            this.sumInsuredIDR = this.record.sumInsuredIDR;
            this.rate = this.record.rate;
            this.showIDR = this.record.showIDR;
            this.data = this.record.detail;
            this.isShowSection = true;
            this.balanceAmount = this.record.balanceAmount;
        }
    }

    getPicklistSection(){
        getSection({
            recordid : this.recordid,
            type : this.type
        })
        .then(result => {
            let data = [];
            for (var key in result) {
                data.push({label:result[key], value:key});
            }
            this.section = data;
        })
        .catch(error => {
            console.log('error-getPicklistSection:'+ error.message);
        });
    }

    getPicklistCategory(){
        getCategory({
            recordid : this.recordid,
            assetsection : this.sectionId,
            type : this.type
        })
        .then(result => {
            let data = [];
            for (var key in result) {
                data.push({label:result[key], value:key});
            }
            this.category = data;
        })
        .catch(error => {
            console.log('error-getPicklistAssetCategory1MOU:'+ error.message);
        });
    }

    getPicklistCurrency(){
        getCurrency({})
        .then(result => {
            let data = [];
            for (var key in result) {
                data.push({label:result[key], value:key});
                if(result[key] == 'IDR' && this.currencyId == undefined){
                    this.currencyId = key;
                    this.currencyName = result[key];
                    this.rate = 1;
                }
            }
            this.currency = data;
        })
        .catch(error => {
            console.log('error-getPicklistCurrency:'+ error.message);
        });
    }

    getAmountRate(){
        getRate({
            curr : this.currencyName
        })
        .then(result => {
            this.rate = result;
            if(this.sumInsured != undefined && this.rate != undefined) this.sumInsuredIDR = this.sumInsured * this.rate;
        })
        .catch(error => {
            console.log('error-getAmountRate:'+ error.message);
        });
    }

    getDataSectionAmount(){
        let contractType = this.contracttypeid;
        getSectionAmount({
            recordid : this.recordid,
            sectionid : this.sectionId,
            contracttypeid : contractType
        })
        .then(result => {
            this.balanceAmount = result;
        })
        .catch(error => {
            console.log('error-getDataSectionAmount:'+ error.message);
        });
    }

    async getDataDetailAsset(){
        this.isLoading = true;
        await getMasterDataDetailAsset({
            contracttype : this.contracttypeid,
            sectionId : this.sectionId
        })
        .then(result => {
            this.isLoading = false;
            this.isShowSection = true;
            this.sectionLabel = 'Section '+ this.sectionName;
            for(let i=0;i<result.length;i++){
                result[i].isshow = true;
                if(result[i].datashow != undefined){
                    result[i].isshow = false;
                }
            }
            this.data = result;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error-getDataDetailAsset:'+ error.message);
        }); 
    }

    handleChange(e){
        let name = e.target.dataset.name;
        let value = e.detail.value;
        if(name == 'section'){
            this.sectionId = value;
            this.sectionName = this.section.find(item => item.value === this.sectionId).label;
            this.getPicklistCategory();
            this.categoryId = undefined;
            this.categoryName = undefined;
            if(this.type == 'realisasi'){
                this.getDataSectionAmount();
            }
            if(this.sectionId != undefined){
                this.getDataDetailAsset();
            }
        }else if(name == 'category'){
            this.categoryId = value;
            this.categoryName = this.category.find(item => item.value === this.categoryId).label;
        }else if(name == 'currency'){
            this.currencyId = value;
            this.currencyName = this.currency.find(item => item.value === this.currencyId).label;
            this.showIDR = false;
            if(this.currencyName == 'IDR'){
                this.rate = 1;
                this.sumInsuredIDR = this.sumInsured;
            }else{
                this.showIDR = true;
                this.getAmountRate();
            }
        }else if(name == 'sumInsured'){
            this.sumInsured = value;
            this.sumInsuredIDR = undefined;
            if(this.currencyId != undefined){
                if(this.sumInsured != undefined && this.rate != undefined) this.sumInsuredIDR = this.sumInsured * this.rate;
            }
        }
    }   

    handleCancel(e){
        this.close('cancel');
    }

    handleAdd(e){
        console.log('records:'+JSON.stringify(this.records));
        let totalAmount = 0;
        if(this.balanceAmount != undefined){
            if(this.record != undefined){
                for(let i=0;i<this.records.length;i++){
                    if(this.records[i].Id == this.record.Id){
                        totalAmount += this.sumInsuredIDR;
                    }else{
                        totalAmount += this.records[i].sumInsuredIDR;
                    }
                }
            }else{
                totalAmount += this.sumInsuredIDR;
                for(let i=0;i<this.records.length;i++){
                    totalAmount += this.records[i].sumInsuredIDR;
                }
            }
        }
        console.log('totalAmount:'+totalAmount);
        if(this.sectionId === undefined || this.sectionId === ''){
            LightningAlert.open({message: 'Please Select Section!',theme: 'error',label: 'Error!'});
        }else if(this.categoryId === undefined || this.categoryId === ''){
            LightningAlert.open({message: 'Please Select Category!',theme: 'error',label: 'Error!'});
        }else if(this.currencyId === undefined || this.currencyId === ''){
            LightningAlert.open({message: 'Please Select Currency!',theme: 'error',label: 'Error!'});
        }else if(this.sumInsured === undefined || this.sumInsured === ''){
            LightningAlert.open({message: 'Please Fill Sum Insured!',theme: 'error',label: 'Error!'});
        }else if(this.type === 'realisasi' && (this.balanceAmount != undefined && totalAmount > this.balanceAmount)){
            LightningAlert.open({message: 'Please Change Sum Insured, over limit IDR '+ this.balanceAmount.toLocaleString('id-ID') +'!',theme: 'error',label:'Error!'});
        }else{
            if(this.record != undefined){
                try{
                    let newdata = [];
                    for(let i=0;i<this.records.length;i++){
                        if(this.records[i].Id == this.record.Id){
                            let data = {
                                Id : this.record.Id,
                                sectionId:this.sectionId,
                                sectionName:this.sectionName,
                                categoryId:this.categoryId,
                                categoryName:this.categoryName,
                                currencyId:this.currencyId,
                                currencyName:this.currencyName,
                                sumInsured:this.sumInsured,
                                sumInsuredIDR:this.sumInsuredIDR,
                                rate:this.rate,
                                showIDR:this.showIDR,
                                detail:this.data,
                                balanceAmount:this.balanceAmount
                            }
                            newdata = [...newdata,data];
                        }else{
                            newdata = [...newdata,this.records[i]];
                        }   
                    }
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

                let data = {
                    Id:jum.toString(),
                    sectionId:this.sectionId,
                    sectionName:this.sectionName,
                    categoryId:this.categoryId,
                    categoryName:this.categoryName,
                    currencyId:this.currencyId,
                    currencyName:this.currencyName,
                    sumInsured:this.sumInsured,
                    sumInsuredIDR:this.sumInsuredIDR,
                    rate:this.rate,
                    showIDR:this.showIDR,
                    detail:this.data,
                    balanceAmount:this.balanceAmount
                };
                this.records = [...this.records,data];
                this.close(this.records);
            }
        }
    }

    handleInputDetail(e){
        let rec = this.data;
        let fieldName = e.target.fieldName;
        let value = e.detail.value;
        try{
            let newrec = [];
            for(let i=0;i<rec.length;i++){
                if(rec[i].datafield == fieldName){
                    newrec[i] = {
                        dataobject : rec[i].dataobject,
                        datafield : rec[i].datafield,
                        datatype : rec[i].datatype,
                        datalabel : rec[i].datalabel,
                        datashow : rec[i].datashow,
                        isshow : rec[i].isshow,
                        value : value
                    }
                }else{
                    newrec[i] = rec[i];
                }
                if(newrec[i].datashow != undefined){
                    let detail = JSON.parse(newrec[i].datashow);
                    let detailvalue = detail.value;
                    if(fieldName == detail.field){
                        if(detailvalue.includes(value)){
                            newrec[i] = {
                                dataobject : newrec[i].dataobject,
                                datafield : newrec[i].datafield,
                                datatype : newrec[i].datatype,
                                datalabel : newrec[i].datalabel,
                                datashow : newrec[i].datashow,
                                isshow : true,
                                value : newrec[i].value
                            }
                        }else{
                            newrec[i] = {
                                dataobject : newrec[i].dataobject,
                                datafield : newrec[i].datafield,
                                datatype : newrec[i].datatype,
                                datalabel : newrec[i].datalabel,
                                datashow : newrec[i].datashow,
                                isshow : false,
                                value : undefined
                            }
                        }
                    }
                }
            }
            this.data = newrec;
        }catch(e){
            console.log('error:'+e.message);
        }
        console.log('this.data:'+JSON.stringify(this.data));
    }
}