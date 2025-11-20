import { LightningElement, api, wire, track } from 'lwc';
import getFileImageCaseVRA from '@salesforce/apex/DisplayImageVRAController.getFileImageCaseVRA';

export default class DisplayImageVRA extends LightningElement {
    @api recordId;
    @api selectedVersionId;

    @track files = [];
    @track error;
    @track isDataLoaded = false;
    @track selectedFile = null;

    // Get data from Apex
    @wire(getFileImageCaseVRA, { recordId: '$recordId' })
    wiredFiles({ error, data }) {
        this.isDataLoaded = true;

        if (data) {
            if (data.length === 0) {
                this.files = [];
                this.error = null;
                this.selectedFile = null;
            } else {
                this.files = data.map(file => ({
                    ...file,
                    selected: file.versionId === this.selectedVersionId
                }));

                this.selectedFile = this.files.find(file => file.selected) || null;
                this.error = null;
            }
        } else if (error) {
            this.error = error.message;
            console.error("Error LWC result ocr:", JSON.stringify(error, null, 2));
        }
    }

    // File existence check
    get hasFiles() {
        return this.files && this.files.length > 0;
    }

    get hasNoFiles() {
        return this.isDataLoaded && (!this.files || this.files.length === 0);
    }

    getClass(file) {
        return file.selected ? 'file-item selected' : 'file-item';
    }

    // Handle file selection
    handleSelect(event) {
        const selectedId = event.currentTarget.dataset.id;

        this.files = this.files.map(file => {
            const isSelected = file.versionId === selectedId;
            if (isSelected) {
                this.selectedFile = file;
            }
            return {
                ...file,
                selected: isSelected
            };
        });

        this.selectedVersionId = selectedId;

        
        this.dispatchEvent(new CustomEvent('valuechange', {
            detail: {
                name: 'selectedVersionId',
                value: this.selectedVersionId
            }
        }));
        console.log(selectedId);
    }
}