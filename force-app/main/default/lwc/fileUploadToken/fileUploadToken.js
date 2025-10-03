import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getUrlAndToken from '@salesforce/apex/GetTokenKrakendController.getUrlAndToken';

export default class FileUploadToken extends LightningElement {
    @api recordId; // ID of the record to associate the file with
    @api documentUrl; // Expose document URL to Flow or Record Page
    @api documentId; // Expose document ID to Flow or Record Page
    @api documentType = 'pbfsf'; // Expose document type with a default value
    @api title = 'Document Upload'; // Default title, can be overridden
    @api allowedFileTypes = ''; // Allowed file types, e.g., "application/pdf,image/png"
    @api refId = 'pbfsf';
    @api IdType = 'pbfsf';
    @api maxFileSizeMB = 15; // Maximum file size in MB (default: 15 MB)
    @api fileName; // Expose selected file's name

    file; // Holds the selected file
    @track uploadedFiles = []; // Holds an array of objects containing file name, document ID, and document URL

    handleFileChange(event) {
        const file = event.target.files[0];
        if (!file) {
            // Handle case where no file is selected
            this.file = null;
            this.fileName = '';
            return;
        }
    
        this.file = file;
        this.fileName = ''; // Reset filename
    
        const fileSizeMB = (file.size / (1000 * 1000)).toFixed(2);
        if (fileSizeMB > this.maxFileSizeMB) {
            this.file = null;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File Too Large',
                    message: `Please upload file maximum ${this.maxFileSizeMB} MB.`,
                    variant: 'error'
                })
            );
        } else {
            this.fileName = file.name; // Set filename when valid
        }
    }

    handleUploadFile() {
        if (this.file) {
            // Call Apex method to get the URL and token
            getUrlAndToken()
                .then(response => {
                    const url = response.url;
                    const token = response.token;

                    // Prepare the multipart form data
                    const formData = new FormData();
                    formData.append('file', this.file); // Append the file object directly
                    formData.append('fileName', this.file.name); // Append the file name
                    formData.append('source_system', 'SALESFORCE');
                    formData.append('id_type', this.IdType);
                    formData.append('ref_id', this.refId);
                    formData.append('document_type', this.documentType);

                    // Create an XMLHttpRequest to send the multipart form data
                    const xhr = new XMLHttpRequest();

                    xhr.open('POST', url, true);
                    xhr.setRequestHeader('Accept', 'application/json');
                    xhr.setRequestHeader('Authorization', token);
                    xhr.responseType = 'json';

                    xhr.onload = () => {
                        if (xhr.status === 413) {
                            // Handle file too large error
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!',
                                    message: 'File is too large. Please select a smaller file.',
                                    variant: 'error'
                                })
                            );
                        } else if (xhr.status >= 200 && xhr.status < 300) {
                            // Handle success
                            const response = xhr.response;
                            this.documentUrl = response.document_url || 'Failed Upload';
                            this.documentId = response.document_id || 'Unknown ID';

                            if (this.documentUrl === 'Failed Upload') {
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

                                // Add uploaded file details (file name, document ID, and URL)
                                this.uploadedFiles = [
                                    ...this.uploadedFiles,
                                    { fileName: this.file.name, documentId: this.documentId, documentUrl: this.documentUrl }
                                ];
                            }
                        } else {
                            // Handle other server errors
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!',
                                    message: `File upload failed with status code ${xhr.status}.`,
                                    variant: 'error'
                                })
                            );
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
                })
                .catch(error => {
                    console.error('Error getting URL and token:', error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: 'Failed to get URL and token.',
                            variant: 'error'
                        })
                    );
                });
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