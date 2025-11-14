import { LightningElement, api, track, wire } from 'lwc';
import getCustomMilestonesWithDetails from '@salesforce/apex/CustomMilestoneService.getCustomMilestonesWithDetails';
import { refreshApex } from '@salesforce/apex';


export default class LWC_AutoRefresh extends LightningElement {
    @api recordId; // The ID of the Case record
    @track intervalId;

    @wire(getCustomMilestonesWithDetails, { recordId: '$recordId' })
    wiredResult(value){
        this.wiredMilestones = value;
        const { data, error } = value;
        if (data) {
            
        } else if (error) {
            console.error(error);
        }
    }

    connectedCallback() {
        this.intervalId = setInterval(() => {
            refreshApex(this.wiredMilestones);
        }, 5000);
    }

    disconnectedCallback() {
        clearInterval(this.intervalId);
    }

    
}