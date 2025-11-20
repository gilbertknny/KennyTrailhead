import { api, LightningElement, track, wire } from 'lwc';
//import URL_ID from '@salesforce/schema/Knowledge__c.UrlName';
import getPromoLookup from '@salesforce/apex/SCC_Wise_Lookup.getPromoLookup';
import { getRecord } from 'lightning/uiRecordApi';


export default class DataTable extends LightningElement {
    @track processedData = [];
    @api recordId;
    @track idKnowledge;
    syaratTable = [];

    fields =[
        'Knowledge__kav.UrlName'
    ]

    @wire(getRecord, {recordId: '$recordId' , fields: '$fields'})
    wireKnowledge({data,error}){
        if(data){
            console.log('data knowledge : ' , data);
            const idWise = data.fields.UrlName.value;
            this.idKnowledge = idWise
            console.log('data knowledge url : ' , this.idKnowledge);

            this.getDataWise(this.idKnowledge);

        }else if(error){
            console.log('Error getting userId:', error.body.message);
        }
    }

    async getDataWise(path){
        try{
            const result = await getPromoLookup({path : path})

            console.log('result : ', result);
            

            const {syarat_dan_ketentuan_flag , syarat_dan_ketentuan_table} = result.data;

            console.log('syarat table api', syarat_dan_ketentuan_table);
            

            if(syarat_dan_ketentuan_flag){
                this.syaratTable = syarat_dan_ketentuan_table
            }

            console.log('syarat table : ', this.syaratTable );
            
        } catch(error){
            console.error('Error checking invitation:', error);
        }
    }
}