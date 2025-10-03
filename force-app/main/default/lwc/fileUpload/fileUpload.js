import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUpload extends LightningElement {
    @api recordId; // ID of the record to associate the file with
    file; // Holds the selected file
    @track documentUrl; // Track the document URL
    @track uploadedFiles = []; // Holds an array of objects containing file name and document URL

    handleFileChange(event) {
        // Capture the selected file from the input
        this.file = event.target.files[0];
    }

    handleUploadFile() {
        if (this.file) {
            // Prepare the multipart form data
            const formData = new FormData();
            formData.append('file', this.file); // Append the file object directly
            formData.append('fileName', this.file.name); // Append the file name
            formData.append('source_system', 'SALESFORCE');
            formData.append('id_type', 'id_type');
            formData.append('ref_id', this.recordId);
            formData.append('document_type', 'document_type');

            // Create an XMLHttpRequest to send the multipart form data
            const xhr = new XMLHttpRequest();
            xhr.open('POST', 'https://microservices.sit.bravo.bfi.co.id/krakend-gateway/sf/document/v1/document', true);
            xhr.setRequestHeader('Accept', 'application/json');
            xhr.setRequestHeader('X-apiKey', 'SALESFORCE_INGRESS_123');
            xhr.responseType = 'json';

            xhr.onload = () => {
                const response = xhr.response;
                const documentUrl = response.document_url || 'Failed Upload';

                if (documentUrl === 'Failed Upload') {
                    // Show error toast if documentUrl is empty
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'File upload failed. Document URL is empty.',
                            variant: 'error'
                        })
                    );
                } else {
                    // On success, show a success toast and add the file to the list
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Files uploaded successfully!',
                            message: `${this.file.name}`,
                            variant: 'success'
                        })
                    );

                    // Add uploaded file details (file name and URL)
                    this.uploadedFiles = [
                        ...this.uploadedFiles,
                        { fileName: this.file.name, documentUrl: documentUrl }
                    ];
                }
            };

            xhr.onerror = () => {
                // Handle network error
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Network Error',
                        message: 'A network error occurred while uploading the file.',
                        variant: 'error'
                    })
                );
            };

            xhr.send(formData);
        } else {
            // No file selected, show a warning message
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No File Selected',
                    message: 'Please select a file to upload.',
                    variant: 'warning'
                })
            );
        }
    }

    get hasUploadedFiles() {
        // Check if there are any uploaded files available for display
        return this.uploadedFiles.length > 0;
    }
}