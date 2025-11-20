import { api, LightningElement, track, wire } from 'lwc';
//import URL_ID from '@salesforce/schema/Knowledge__kav.UrlName';
import getPromoLookup from '@salesforce/apex/SCC_Wise_Lookup.getPromoLookup';
import { getRecord } from 'lightning/uiRecordApi';


export default class DataTable extends LightningElement {
    @track processedData = [];
    @api recordId;
    @track idKnowledge;
    benefitTable = [];

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
            

            const {benefit_flag , benefit_table} = result.data;

            console.log('benefit table api', benefit_table);
            

            if(benefit_flag){
                this.benefitTable = benefit_table
            }

            console.log('benefit table : ', this.benefitTable );
            
        } catch(error){
            console.error('Error checking invitation:', error);
        }
    }
}