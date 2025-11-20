import { LightningElement, api, wire } from 'lwc';
import getImageUrlByContentVersionId from '@salesforce/apex/DemoVRAPreviewImageKTPResultController.getImageUrlByContentVersionId';

export default class DemoVRAPreviewImageKTPResult extends LightningElement {
    @api recordId;
    imageUrl;
    error;

    @wire(getImageUrlByContentVersionId, {recordId: '$recordId'})
    wiredImageUrl({ error, data }){
    if(data){
        this.imageUrl = data;
        this.error = null;
    } else if(error) {
        this.error = error.body ? error.body.message : error.message;
        this.imageUrl = null;
    }
    }
}