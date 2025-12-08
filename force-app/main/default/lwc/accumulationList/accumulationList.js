// import { LightningElement, api, wire } from 'lwc';
// import { NavigationMixin } from 'lightning/navigation';
// import getAccumulationsByQuote from '@salesforce/apex/AccumulationListController.getAccumulationsByQuote';

// export default class AccumulationList extends NavigationMixin(LightningElement) {
//     @api recordId; // Quote ID
//     accumulationList = [];
//     isLoading = true;
//     error;

//     @wire(getAccumulationsByQuote, { quoteId: '$recordId' })
//     wiredAccumulations({ error, data }) {
//         this.isLoading = false;
//         if (data) {
//             this.accumulationList = data;
//             this.error = undefined;
//         } else if (error) {
//             this.error = error;
//             this.accumulationList = [];
//             console.error('Error loading accumulations:', JSON.stringify(error));
//         }
//     }

//     handleNavigate(event) {
//         event.preventDefault();
//         const accumulationId = event.currentTarget.dataset.id;
        
//         this[NavigationMixin.Navigate]({
//             type: 'standard__recordPage',
//             attributes: {
//                 recordId: accumulationId,
//                 objectApiName: 'Accumulation__c',
//                 actionName: 'view'
//             }
//         });
//     }

//     get hasAccumulations() {
//         return this.accumulationList && this.accumulationList.length > 0;
//     }

//     get noAccumulations() {
//         return !this.isLoading && (!this.accumulationList || this.accumulationList.length === 0);
//     }
// }