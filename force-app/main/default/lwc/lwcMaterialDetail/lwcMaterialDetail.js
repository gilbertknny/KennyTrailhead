// lwcMaterialDetail.js
import { LightningElement, api, wire, track } from 'lwc';
import getMaterialDetail from '@salesforce/apex/MaterialController.getMaterialDetail';
import getFileDownloadUrl from '@salesforce/apex/MaterialController.getFileDownloadUrl';

const FILE_COLUMNS = [
    { label: 'File Name', fieldName: 'Title', type: 'text' },
    { label: 'Type', fieldName: 'FileType', type: 'text' },
    { label: 'Size', fieldName: 'FormattedSize', type: 'text' },
    { label: 'Uploaded', fieldName: 'CreatedDate', type: 'date', 
      typeAttributes: {
          year: 'numeric',
          month: 'short',
          day: '2-digit'
      }
    },
    {
        type: 'button',
        typeAttributes: {
            label: 'Download',
            name: 'download',
            variant: 'brand',
            iconName: 'utility:download'
        }
    }
];

export default class LwcMaterialDetail extends LightningElement {
    @api materialId;
    @track material;
    @track files;
    @track error;
    @track presenterName;
    @track presenterTitle;
    @track presenterEmail;
    
    fileColumns = FILE_COLUMNS;

    @wire(getMaterialDetail, { recordId: '$materialId' })
    wiredMaterialDetail({ error, data }) {
        if (data) {
            this.material = data.material;
            this.files = data.files;
            this.presenterName = data.presenterName;
            this.presenterTitle = data.presenterTitle;
            this.presenterEmail = data.presenterEmail;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.material = undefined;
            this.files = undefined;
            this.presenterName = undefined;
            this.presenterTitle = undefined;
            this.presenterEmail = undefined;
            console.error('Error loading material detail:', error);
        }
    }

    get hasNoFiles() {
        return !this.files || this.files.length === 0;
    }

    async handleFileAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        
        if (action.name === 'download') {
            try {
                const downloadUrl = await getFileDownloadUrl({ 
                    contentVersionId: row.LatestPublishedVersionId 
                });
                window.open(downloadUrl, '_blank');
            } catch (error) {
                console.error('Error downloading file:', error);
            }
        }
    }
}