import { getRecord } from 'lightning/uiRecordApi';
import { LightningElement, api, track, wire } from 'lwc';
import inquiryBrivaUI from '@salesforce/apex/SCC_InquiryBriva.inquiryBrivaUI';
import updateCaseAccountNumber from '@salesforce/apex/SCC_InquiryBriva.updateCaseAccountNumber';
// import inquiryBirvaUI from '@salesforce/apex/SSC_InquiryBriva.inquiryBrivaUI'
// import updateCaseAccountNumber from '@salesforce/apex/SCC_InquiryBriva.updateCaseAccountNumber';


const FIELDS = [
    'Case.SCC_Nomor_Briva_Tagihan__c',
    'Case.SCC_Account_Number__c',
    'Case.SCC_Case_Type_for_Suggested_Article__c'
]

export default class popupBriva extends LightningElement {
    @api recordId;
    @track showConfirmDialog = false;
    @track showNext = false
    @track brivaPreviousValue = null;
    @track brivaCurrentValue = null;
    @track rekeningPreviousValue = null;
    @track rekeningCurrentValue = null;
    @track isFirstLoad = true;
    @track nomorRekening = '';


    @track corpAccountNo  = '';
    @track errorCode = '';
    @track responseCode = '';
    @track responseMessage = '';


    
@wire(getRecord , {recordId : '$recordId' , fields: FIELDS})
recordHandler({data,error}){
    if(data){
        const nomorBriva = data.fields.SCC_Nomor_Briva_Tagihan__c.value;
        const nomorRekening = data.fields.SCC_Account_Number__c.value;
        const caseType = data.fields.SCC_Case_Type_for_Suggested_Article__c.value;
        this.nomorRekening = nomorRekening;

        
        console.log('nomor briva' , nomorBriva);
        console.log('nomor rekening' , nomorRekening);


        if(this.isFirstLoad){
            this.brivaCurrentValue = nomorBriva;
            this.rekeningCurrentValue = nomorRekening;
            this.isFirstLoad = false
            console.log('first load');
            return;
        }

        if(this.brivaCurrentValue !== nomorBriva && (caseType == '8812' || caseType == '8915') ){


              this.brivaPreviousValue = this.brivaCurrentValue; 
              this.brivaCurrentValue = nomorBriva; 
              this.rekeningPreviousValue = this.rekeningCurrentValue;
              this.rekeningCurrentValue = nomorRekening;

              console.log(`Sebelum: ${this.brivaPreviousValue}, Sesudah: ${this.brivaCurrentValue}`);
              console.log(`Sebelum: ${this.rekeningPreviousValue}, Sesudah: ${this.nomorRekening}`);

              if(this.brivaCurrentValue){
                 this.getNomorRekening(this.brivaCurrentValue);
              }
        }
        
    }

    else if(error){
        console.log('Error retrieving record data : ' , data);
    }


}

async getNomorRekening(brivaNo){
    try{    
        const result = await inquiryBrivaUI({brivaNo:brivaNo});
        console.log('briva no' , brivaNo);
        console.log('result' , result);
        console.log('acc no' , result.corpAccountNo );
        console.log('error code' , result.errorCode);
        console.log('response code' , result.responseCode);
        console.log('response mssg' ,result.responseMessage);
        console.log('response brivaco number stringify' ,  JSON.stringify(result.brivaco));
        console.log('corp name ' , result.corpName);
        console.log('special segment' , result.specialSegment);
        
        const specialSegment = result.specialSegment;

        this.corpAccountNo = specialSegment == 'Y' ? result.brivaco[0].accountNo : result.corpAccountNo;

        console.log("no rekening giro :", this.corpAccountNo);
        

        // this.corpAccountNo = result.corpAccountNo;
        this.errorCode = result.errorCode;
        this.responseCode = result.responseCode;
        this.responseMessage = result.responseMessage;

        if((this.nomorRekening == null || this.nomorRekening== undefined) && this.corpAccountNo){
            console.log('nomor rekening ' , this.corpAccountNo);
            console.log('nomor rekening akan langsung diupdate jika dapat balikan dari api');
            this.updateNomorRekeningCase(this.recordId, this.corpAccountNo);
            this.showNext = true
          }

        if((this.nomorRekening != null || this.nomorRekening != undefined) && this.corpAccountNo){
            console.log('rekening previous value' , this.rekeningPreviousValue);
            
            if(this.rekeningPreviousValue != this.corpAccountNo){
                console.log('muncul pop up konfirmasi untuk mengganti nomor rekening');
                this.showConfirmDialog = true        
            }
        }


    }catch(err){
        console.log('error get briva no' +  (err.body?.message || JSON.stringify(err)));
        
    }
}

async updateNomorRekeningCase(recordId, nomorRekening){
    try{
        const result = await updateCaseAccountNumber({
            recordId: recordId, 
            corpAccountNumber: nomorRekening
        });
    } catch (error){
        console.log('error update nomor rekening' , err.body.message);
    }

}

handleConfirmChange(){
    this.updateNomorRekeningCase(this.recordId, this.corpAccountNo);
    this.refreshPage();
}


refreshPage() {
    window.location.reload();
}


handleCancelChange(){
    this.showConfirmDialog = false;
}
    

}