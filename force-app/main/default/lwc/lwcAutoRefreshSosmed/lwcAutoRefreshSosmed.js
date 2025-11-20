import { api, LightningElement, track, wire } from 'lwc';
import SPROUTEX_FIELD from '@salesforce/schema/Case.SproutExId__c';
import STATUS_FIELD from '@salesforce/schema/Case.Status';
import DATETIME_ANSWER_FIELD from '@salesforce/schema/Case.Date_Time_Answer__c';
import SL_STARTED_FIELD from '@salesforce/schema/Case.SCC_SL_Sosmed_Timer_Dimulai__c';
import SL_STOPPED_TIME_FIELD from '@salesforce/schema/Case.SCC_SL_Sosmed_Waktu_Stop__c';
import SL_ORIGIN_FIELD from '@salesforce/schema/Case.Origin';
import SL_TARGET_RESPONSE from '@salesforce/schema/Case.SCC_Target_Response_Time_Non_Voice__c';
import RESPONSE_TIME_FIELD from '@salesforce/schema/Case.Response_Time_Minutes__c';
import CLOSED_DATE_FIELD from '@salesforce/schema/Case.ClosedDate';
import CREATED_DATE_FIELD from '@salesforce/schema/Case.CreatedDate';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class LwcAutoRefreshSosmed extends LightningElement {
    @api recordId;
    @track invtervalRefreshId;
    @track wiredCaseResult;
    @track isCompleted;
    @track sproutExId;

    @wire(getRecord , {
        recordId: '$recordId',
        fields: [
            SPROUTEX_FIELD,
            STATUS_FIELD,
            DATETIME_ANSWER_FIELD,
            SL_STARTED_FIELD,
            SL_STOPPED_TIME_FIELD,
            SL_ORIGIN_FIELD,
            SL_TARGET_RESPONSE,
            RESPONSE_TIME_FIELD,
            CLOSED_DATE_FIELD,
            CREATED_DATE_FIELD
        ]
    })
    wireCaseRecord(result){
        this.wiredCaseResult = result;
        const {data,error} = result
        if(data){
            const sproutId= getFieldValue(data,SPROUTEX_FIELD);
            const stopedId = getFieldValue(data,SL_STOPPED_TIME_FIELD);
            this.sproutExId = sproutId;
            this.isCompleted = stopedId

            console.log('semprot id : ' , sproutId );
            console.log('closed time : ' ,stopedId);
            

            this.handleInterval();
        } else if (error){
            console.error(error);
        }
    }

    handleInterval() {

        console.log('this semprot id' , this.sproutExId);
        console.log('this is completed' , this.isCompleted);
        
        

        if (this.invtervalRefreshId) {
            clearInterval(this.invtervalRefreshId);
            this.invtervalRefreshId = null;
        }

        if (this.sproutExId && this.isCompleted == null) {
            this.invtervalRefreshId = setInterval(() => {
                refreshApex(this.wiredCaseResult);
                console.log('refreshed');
            }, 5000);
        }
    }

    disconnectedCallback(){
        if (this.invtervalRefreshId) {
            clearInterval(this.invtervalRefreshId);
        }
    }


}