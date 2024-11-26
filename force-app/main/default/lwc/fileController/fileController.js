import { LightningElement, api } from 'lwc';
import getIncidentFiles from '@salesforce/apex/IncidentFilesController.getIncidentFiles';

const columns = [
    {
        label: 'Title',
        fieldName: 'TitleUrl',
        type: 'url',
        sortable: false,
        typeAttributes: {
            label: { fieldName: 'Title' },
            target: '_blank'
        }
    },
    { label: 'File Type', fieldName: 'FileType', type: 'text', sortable: true },
    { 
        label: 'Size (KB)', 
        fieldName: 'ContentSizeKb', 
        type: 'number',
        sortable: true,
        typeAttributes: {
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }
    },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'date', sortable: true }
];

export default class FilesLWCRelatedList extends LightningElement {
    @api recordId; 
    columns = columns;
    files;
    boolerror = false; 

    sortedBy;
    sortedDirection;

    connectedCallback(){
        this.getFilesMethod();
    }
   
    getFilesMethod(){
        getIncidentFiles({ incidentId: this.recordId })
        .then(result => {
            if(result){
                this.files = result.map(file => ({
                    Id: file.Id,
                    Title: file.Title,
                    FileType: file.FileType,
                    ContentSize: file.ContentSize,
                    CreatedDate: file.CreatedDate,
                    TitleUrl: `/lightning/r/ContentDocument/${file.Id}/view`,
                    ContentSizeKb: parseFloat((file.ContentSize / 1024).toFixed(2)) // Mengkonversi ke Number
                }));
            }
        })
        .catch(error => {
            console.error('Error fetching files: ', error);
            this.boolerror = true;
        });
   }

    /**
     * Handler untuk event sort dari lightning-datatable
     * @param {Event} event 
     */
    handleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.files];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));

        this.files = cloneData;
        this.sortedBy = sortedBy;
        this.sortedDirection = sortDirection;
    }

    /**
     * Fungsi pembanding untuk mengurutkan data
     * @param {String} field 
     * @param {Number} reverse 
     * @returns {Function}
     */
    sortBy(field, reverse, primer) {
        const key = primer 
            ? function(x) { return primer(x[field]); } 
            : function(x) { return x[field]; };
        
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}