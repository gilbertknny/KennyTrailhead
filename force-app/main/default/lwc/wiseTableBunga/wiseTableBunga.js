import { api, LightningElement, track, wire } from 'lwc';
//import URL_ID from '@salesforce/schema/Knowledge__c.UrlName';
import getProdukLookup from '@salesforce/apex/SCC_Wise_Lookup.getProdukLookup';
import { getRecord } from 'lightning/uiRecordApi';


export default class DataTable extends LightningElement {
    @track processedData = [];
    @api recordId;
    @track idKnowledge;
    bungaTable = [];

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
            const result = await getProdukLookup({path : path})

            console.log('result : ', result);
            

            const {bunga_flag , bunga_table} = result.data;

            console.log('syarat table api', bunga_table);
            

            if(bunga_flag){
                this.bungaTable = bunga_table
            }

            console.log('bunga table : ', this.bungaTable );
            
        } catch(error){
            console.error('Error checking invitation:', error);
        }
    }
}