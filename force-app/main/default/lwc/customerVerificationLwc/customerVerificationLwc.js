import { LightningElement, wire, api,track } from 'lwc';
import fetchBankingDataFromAPI from '@salesforce/apex/SCC_CustomerVerificationController.fetchBankingDataFromAPI';
import fetchCreditDataFromAPI from '@salesforce/apex/SCC_CustomerVerificationController.fetchCreditDataFromAPI';
import saveRecord from '@salesforce/apex/SCC_CustomerVerificationController.saveRecord';

import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class TabExample extends LightningElement {

    @api recordId
    @track IsLoading = false;
    @track demografi ;

    @track portofolioPerbankan;
    @track creditObj ;
    @track caseObj;
    @track customerType = 'Individu';
    @track categoryOptions;
    @track cardNumber;
    @track category = "Banking";
    @track fieldName;
    @track errMsg;
    @track showError;

    connectedCallback (){
        this.IsLoading = true;
        this.categoryOptions = [{ label: "Banking", value: "Banking" },{ label: "Credit", value: "Credit" }]
        this.callbankInfo();
         
    }

    async callbankInfo(){
        this.showError = false;
        this.errMsg = '';
        await fetchBankingDataFromAPI({
            caseId:this.recordId
        }).then(returnData => { 
            this.IsLoading = false;
            console.log('returnData**',JSON.stringify(returnData));
            if(returnData){
                this.caseObj = returnData;
                this.customerType = returnData.customerType;
               
            }
        }).catch(e=>{
            this.IsLoading = false;
                console.log('error:',JSON.stringify(e));
            this.showError = true;
            this.errMsg = JSON.stringify(e);
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         message: JSON.stringify(e),
            //         variant: 'error',
            //     }) 
            // );
        })
    }

    async callCreditInfo(){
        this.showError = false;
        this.errMsg = '';
        console.log('cardNumber**',this.cardNumber);
        await fetchCreditDataFromAPI({
            caseId:this.recordId,cardNumber:this.cardNumber
        }).then(returnData => { 
            if(returnData){
                this.IsLoading = false;
                this.caseObj = returnData;
               }
               else{
                this.IsLoading = false;
                this.caseObj=null;
               }
        }).catch(e=>{
            this.IsLoading = false;
            console.log('error:',JSON.stringify(e));
            this.showError = true;
            this.caseObj=null;
            this.errMsg = JSON.stringify(e);
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         message: JSON.stringify(e),
            //         variant: 'error',
            //     }) 
            // );
        })
    }

    get showdata(){
        return this.caseObj;
    }

    get banking(){
        return this.category == "Banking";
    }

    get bankIndividual(){
        return this.category == "Banking" && this.customerType == "Individu";
    }

    get bankNonIndividual(){
        return this.category == "Banking" && this.customerType == "Non-Individu";
    }

    get creditIndividual(){
        return this.category == "Credit" && this.customerType == "Individu";
    }
    get creditNonIndividual(){
        return this.category == "Credit" && this.customerType == "Non-Individu";
    }

    handleChange(event){
        this.caseObj = null;
        this.category = event.detail.value;
        console.log('this.category***',this.category);
        if(this.category == 'Banking'){
            this.IsLoading = true;
            this.callbankInfo();
        }
        
    }
    cardChange(event){
        this.cardNumber = event.detail.value;
    }

    searchcardInfo(){
        this.IsLoading = true;
        this.callCreditInfo();
    }
    async handlecheckChange(event){
       
        let fieldNamea = event.target.name;
        if(fieldNamea) {
            fieldNamea = fieldNamea.replace('verif','SCC_Verif');
            fieldNamea = fieldNamea + '__c';
        }
        this.fieldName = fieldNamea;
        console.log('fieldName',fieldNamea);
        let checked = event.target.checked;
        let value = event.target.title;
        if(checked){


            let caseObject = '{"Id":"' + this.recordId + '","' + this.fieldName + '":' + checked +'}';
            console.log(caseObject);
            await saveRecord({
                caseStr:caseObject
            }).then(returnData => { 
                if(returnData == 'success'){

                }else{
                //     this.dispatchEvent(
                //     new ShowToastEvent({
                //         message: returnData,
                //         variant: 'error',
                //     }) 
                // );
                    this.showError = true;
                    this.errMsg = returnData;
                }
            }).catch(e=>{
                console.log('error:',JSON.stringify(e));
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         message: JSON.stringify(e),
                //         variant: 'error',
                //     }) 
                // );
                this.showError = true;
                this.errMsg = JSON.stringify(e);
            })

        }



    }
    
}