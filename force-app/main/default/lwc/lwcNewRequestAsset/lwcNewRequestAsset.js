import LightningModal from 'lightning/modal';
import { track,api } from 'lwc';
import LightningAlert from 'lightning/alert';
import getRate from '@salesforce/apex/ClsNewRequest.getRate';
import getSection from '@salesforce/apex/ClsNewRequest.getAssetSectionMOU';
import getCategory from '@salesforce/apex/ClsNewRequest.getAssetCategoryMOU';
import getCurrency from '@salesforce/apex/ClsNewRequest.getCurrency';
import getSectionAmount from '@salesforce/apex/ClsNewRequest.getSectionAmount';

export default class LwcNewRequestAsset extends LightningModal {
    @api records;
    @api record;
    @api recordid;
    @api type;
    @track labelAdd = 'Add';
    @track isLoading;
    @track section = [];
    @track category = [];
    @track currency = [];
    @track disabledSection;
    @track sectionId;
    @track sectionName;
    @track categoryId;
    @track categoryName;
    @track currencyId;
    @track currencyName;
    @track sumInsured;
    @track sumInsuredIDR;
    @track showIDR;
    @track rate;
    @track limitAmount;

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
            this.categoryId = this.record.categoryId;
            this.categoryName = this.record.categoryName;
            this.currencyId = this.record.currencyId;
            this.currencyName = this.record.currencyName;
            this.sumInsured = this.record.sumInsured;
            this.sumInsuredIDR = this.record.sumInsuredIDR;
            this.rate = this.record.rate;
            this.showIDR = this.record.showIDR;
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
        getSectionAmount({
            recordid : this.recordid,
            sectionid : this.sectionId
        })
        .then(result => {
            this.limitAmount = result;
        })
        .catch(error => {
            console.log('error-getDataSectionAmount:'+ error.message);
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
        if(this.sectionId === undefined || this.sectionId === ''){
            LightningAlert.open({message: 'Please Select Section!',theme: 'error',label: 'Error!'});
        }else if(this.categoryId === undefined || this.categoryId === ''){
            LightningAlert.open({message: 'Please Select Category!',theme: 'error',label: 'Error!'});
        }else if(this.currencyId === undefined || this.currencyId === ''){
            LightningAlert.open({message: 'Please Select Currency!',theme: 'error',label: 'Error!'});
        }else if(this.sumInsured === undefined || this.sumInsured === ''){
            LightningAlert.open({message: 'Please Fill Sum Insured!',theme: 'error',label: 'Error!'});
        }else if(this.type === 'realisasi' && (this.sumInsuredIDR > this.limitAmount)){
            LightningAlert.open({message: 'Please Change Sum Insured, over limit!',theme: 'error',label:'Error!'});
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
                                showIDR:this.showIDR
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
                    showIDR:this.showIDR
                };
                this.records = [...this.records,data];
                this.close(this.records);
            }
        }
    }
}