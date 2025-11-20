/** 
    LWC Name    : lwcInquiryToken.js
    Created Date       : ?? ?? 2025
    @description       : This is class ..
    @author            : Dwiki
    Modification Log :
    Ver   Date         Author                            Modification
    //release 3
    1.0   ??/??/2025   Dwiki                             Initial Version
    1.0   24/02/2025   Rakeyan Nuramria                  Adjust UI


**/

import { api, LightningElement, track } from 'lwc';
import searchRekonToken from '@salesforce/apex/SCC_Rekon.searchRekonToken';
import tokenFeatureId from '@salesforce/label/c.tokenFeatureId';
import updateCase from '@salesforce/apex/SCC_TokenPLN.updateCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

export default class LwcInquiryToken extends LightningElement {
    @api recordId;
    @track hasError = false;
    @track tanggalTransaksi;
    // @track disableSearchButton = true;
    @track idPelanggan;
    @track nomorRekening;
    @track showSearchResults = false;
    @track isLoading = false;
    @track data;
    @track selectedToken = null;
    @track mcs = null;
    @track statusRekon = null;
    @track hasToken = false;


    connectedCallback(){
        console.log("feature id token : " , tokenFeatureId);
        console.log("record id : " , this.recordId);
        
    }

    handleNomorRekeningChange(event){
        this.nomorRekening = event.target.value;
        //this.validateEmptyFields();
    }

    handleCheckboxChange(event){

        let token = event.target.value;
        let status = event.target.dataset.status;
        let mcs = event.target.dataset.mcs;

        if(token){
            console.log('no token :' ,  token);
            console.log('status rekon : ', status);
            console.log('mcs :' ,mcs );
            
            
            this.selectedToken = token;
            this.mcs = mcs;
            this.statusRekon = status;
            this.hasToken = true;
        }else{
            this.hasToken = false;
        }

    }

    handleClickSubmit(){
        this.updateNomorToken(this.recordId,this.selectedToken, '',this.mcs,this.statusRekon);
    }


    handleTrxDateChange(event){
        this.tanggalTransaksi = event.target.value
        console.log('Get Date',event.target.value);
        this.validateDate();
        //this.validateEmptyFields();

    }

    handleSearchError(errorMessage){
        this.hasError = true;
        this.errorMessage = errorMessage;
        console.log("has error");
        
        //this.isLoading = false;
    }

    handleSearch(){
        this.fetchRekonData();
        console.log("handle search");
        
    }

   clearErrorFields(){
        this.hasError = false;
        this.errorMessage = '';
   }
    

    validateDate(){
        const today = new Date().toISOString().slice(0, 10)
        if(this.tanggalTransaksi > today ){
            console.log("Tanggal melebihi hari ini");
            this.handleSearchError("Tanggal transaksi tidak boleh melebihi hari ini");
        }else{
            this.clearErrorFields();
        }
    }


    fetchRekonData(){
        this.isLoading = true;
        this.showSearchResults = false;


        const reqToken = {
            FeatureId : tokenFeatureId || "PLNPRE001",
            TransactionDate : this.tanggalTransaksi ,
            BillingNumber : this.nomorRekening
        }

        const menu = 'Drone'

        searchRekonToken({
            cdh : reqToken,
            menu : menu,
            recid : this.recordId
        })
        .then((result) => {

            
            if(result){

                
                console.log('Response result Token received:', result);
                console.log('Response result Token received:', JSON.stringify(result));

                this.isLoading = false;
                this.clearErrorFields();

                const responseData = result.responseData.detailData;

                console.log('response data : ', responseData);
                console.log('response data : ', JSON.stringify(responseData));                

                if(responseData){

                    this.showSearchResults = true
                    this.data = responseData;

                
                }else{
                    this.handleSearchError("Data tidak ditemukan");
                }
                
            }else{
                this.showSearchResults = false;
                this.handleSearchError("Data tidak ditemukan");
            }
          

        }).catch((err) => {
            console.error('Error occurred during search Merchant:', err.message);
            this.handleSearchError("Data tidak ditemukan")
        })
        .finally(() => {

            if(this.data != null){
                this.updateNomorToken(this.recordId, '', this.nomorRekening);
            }
            
            this.isLoading = false;
            this.updateNomorToken(this.recordId, '', this.nomorRekening);
            console.log('Loading state set to false.');
            console.log('show result data : ' , this.showSearchResults  ) ;
            
        })
    }

     updateNomorToken(caseId, nomorToken , billingNumber,mcs,status){

        this.isLoading = true;
        this.showSearchResults = false;


        updateCase({
            caseId: caseId,
            tokenNumber: nomorToken,
            billingNumber : billingNumber,
            mcs: mcs,
            statusRkon : status
        })
        .then((result) => {


            console.log("update nomor token case : " , result);
            

            if(result){


                if(nomorToken != ''){
                    this.showToast("Success", "Nomor Token berhasil ditambahkan pada case" , "success");
                }

                if(billingNumber != ''){
                     this.showToast("Success", "Billing Number  berhasil ditambahkan pada case" , "success");
                }
                
            }

            getRecordNotifyChange([{recordId: this.recordId}]);

        })
        .catch(error => {

            if (error && error.body && error.body.message) {

                console.log("err : " , error.body);
                
                this.showToast('Error', 'Gagal melakukan update pada case: ' + error.body.message, 'error');    
            }
        })
        .finally(() => {
            this.isLoading = false
            this.showSearchResults = true;
        })

    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    // validateEmptyFields(){

    //     if(!this.nomorRekening && !this.tanggalTransaksi){
    //         this.disableSearchButton = false
    //     }
    // }

    // validateEmptyFields(){
    //     this.disableSearchButton = !this.nomorRekening || !this.tanggalTransaksi || this.tanggalTransaksiError;
    // }


}