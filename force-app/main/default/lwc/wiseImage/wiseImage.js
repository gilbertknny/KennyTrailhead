import getProdukLookup from '@salesforce/apex/SCC_Wise_Lookup.getProdukLookup';
import getProgramLookup from '@salesforce/apex/SCC_Wise_Lookup.getProgramLookup';
import getPromoLookup from '@salesforce/apex/SCC_Wise_Lookup.getPromoLookup';
import getRecordName from '@salesforce/apex/SCC_Wise_Lookup.getRecordName';
import { getRecord } from 'lightning/uiRecordApi';
import { api, LightningElement, track,wire } from 'lwc';


export default class WiseImage extends LightningElement {
    @api recordId;
    @track idKnowledge;
    @track knowledgeType;
    imageData;
    @track recordName;


    fields = [
        'Knowledge__kav.UrlName',
        'Knowledge__kav.Record_Type__c',
        'Knowledge__kav.RecordTypeId'
    ]

    @wire(getRecord, {recordId: '$recordId', fields : '$fields'})
    wireKnowledge({data,error}){
        if(data){
            const idWise = data.fields.UrlName.value;
            const recordType = data.fields.Record_Type__c.value;
            const recordId = data.fields.RecordTypeId.value;

            console.log('wise id : ', idWise );
            console.log('record type id : ', recordId);
            console.log('recordType : ' , recordType);

            this.getRecordNamed(recordId)
            .then(() => {
                console.log('record name get : ' , this.recordName);

                if(this.recordName === 'Promotion'){
                    this.getPromoImage(idWise);
                }
    
                if(this.recordName === 'Program'){
                    this.getProgramImage(idWise);
                }
    
                if(this.recordName === 'Product'){    
                    this.getProdukData(idWise);
                }
            })
            .catch(error => {
                console.log('error get record type : ' , error );
            })
            
            // if(recordType === 'Promo'){
            //     this.getPromoImage(idWise);
            // }

            // if(recordType === 'Program'){
            //     this.getProgramImage(idWise);
            // }

            // if(recordType === 'Produk'){    
            //     this.getProdukData(idWise);
            // }
                    
        } else if(error){
            console.log('Error getting knowledge data : ', error.body.message);
            
        }
    }


    async getRecordNamed(id){
        const result = await getRecordName({idRecord:id});
        console.log('record name result : ', result );
        this.recordName = result;
        
    }

    async getPromoImage(path){
        const result = await getPromoLookup({path:path});
        console.log('result', result);
        this.imageData = result.data.image;
    }

    async getProgramImage(path){
        const result = await getProgramLookup({path:path});
        console.log('result', result);
        this.imageData =  result.data.image;
    }

    async getProdukData(path){
        const result = await getProdukLookup({path:path});
        console.log('result', result);
        this.imageData =  result.data.image;
    }


}