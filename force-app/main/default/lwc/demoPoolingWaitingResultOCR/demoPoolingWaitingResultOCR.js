import { LightningElement, api} from 'lwc';
import getOCRStatus from '@salesforce/apex/DemoPoolingWaitingResultOCRController.getOCRStatus';

export default class DemoPoolingWaitingResultOCR extends LightningElement {
    @api recordId;
    caseData;
    isLoading = true;
    isFailed = false;
    intervalId;

    connectedCallback() {
        this.startPooling();
    }

    disconnectedCallback(){
        clearInterval(this.intervalId);
    }

    startPooling(){
        this.intervalId = setInterval(() => {
            getOCRStatus({ caseId: this.recordId })
            .then((status) => {
                if(status === 'Success'){
                    clearInterval(this.intervalId);
                    this.isLoading = false;
                } else if (status === 'Failed') {
                    clearInterval(this.intervalId);
                    this.isLoading = false;
                    this.isFailed = true;
                }
            })
            .catch((error) => {
                console.error('Pooling error', error);
            });
        }, 500);
    }
}