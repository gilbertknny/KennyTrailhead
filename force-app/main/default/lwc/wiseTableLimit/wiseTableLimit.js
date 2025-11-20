import { api, LightningElement, track, wire } from 'lwc';
import getProdukLookup from '@salesforce/apex/SCC_Wise_Lookup.getProdukLookup';
import { getRecord } from 'lightning/uiRecordApi';


export default class DataTable extends LightningElement {
    @track processedData = [];
    @api recordId;
    @track idKnowledge;
    limitsTable = [];

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
            

            const {limits_flag , limits_table} = result.data;

            console.log('limit table api', limits_table);
            

            if(limits_flag){
                this.limitsTable = limits_table
            }

            console.log('limit table : ', this.limitsTable );
            
        } catch(error){
            console.error('Error checking invitation:', error);
        }
    }
}