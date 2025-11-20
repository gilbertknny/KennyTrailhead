import { LightningElement, track, api } from 'lwc';
import searchQueueNames from '@salesforce/apex/SCC_QueueController.searchQueueNames';
import saveQueueToCustomObject from '@salesforce/apex/SCC_QueueController.saveQueueToCustomObject';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class QueueLookup extends LightningElement {
    @api recordId;
    
    @track searchResultsLevel1 = [];
    @track searchResultsLevel2 = [];
    @track searchResultsLevel3 = [];
    @track searchResultsLevel4 = [];

    @track selectedQueueLevel1 = '';
    @track selectedQueueLevel2 = '';
    @track selectedQueueLevel3 = '';
    @track selectedQueueLevel4 = '';

    searchTermLevel1 = '';
    searchTermLevel2 = '';
    searchTermLevel3 = '';
    searchTermLevel4 = '';
    

    handleSearchLevel1(event) {
        const searchTerm = event.target.value;
        this.searchTermLevel1 = searchTerm;

        if (searchTerm.length >= 2) {
            searchQueueNames({ searchTerm })
                .then(result => {
                    this.searchResultsLevel1 = result.map(queueName => {
                        return { label: queueName, value: queueName };
                    });
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error searching queues',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.searchResultsLevel1 = [];
        }
    }

    handleSearchLevel2(event) {
        const searchTerm = event.target.value;
        this.searchTermLevel2 = searchTerm;

        if (searchTerm.length >= 2) {
            searchQueueNames({ searchTerm })
                .then(result => {
                    this.searchResultsLevel2 = result.map(queueName => {
                        return { label: queueName, value: queueName };
                    });
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error searching queues',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.searchResultsLevel2 = [];
        }
    }

    handleSearchLevel3(event) {
        const searchTerm = event.target.value;
        this.searchTermLevel3 = searchTerm;

        if (searchTerm.length >= 2) {
            searchQueueNames({ searchTerm })
                .then(result => {
                    this.searchResultsLevel3 = result.map(queueName => {
                        return { label: queueName, value: queueName };
                    });
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error searching queues',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.searchResultsLevel3 = [];
        }
    }

    handleSearchLevel4(event) {
        const searchTerm = event.target.value;
        this.searchTermLevel4 = searchTerm;

        if (searchTerm.length >= 2) {
            searchQueueNames({ searchTerm })
                .then(result => {
                    this.searchResultsLevel4 = result.map(queueName => {
                        return { label: queueName, value: queueName };
                    });
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error searching queues',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
        } else {
            this.searchResultsLevel4 = [];
        }
    }

    handleLevel1Select(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selectedLabel = event.currentTarget.dataset.label;
    
        if (selectedValue && selectedLabel) {
            this.selectedQueueLevel1 = selectedValue;
            this.searchTermLevel1 = selectedLabel;
            this.searchResultsLevel1 = [];
            this.handleSave(this.selectedQueueLevel1,'SCC_Level1_Escalation_team__c');
        } else {
            console.error('Selected value or label is undefined.');
        }
    }

    handleLevel2Select(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selectedLabel = event.currentTarget.dataset.label;
    
        if (selectedValue && selectedLabel) {
            this.selectedQueueLevel2 = selectedValue;
            this.searchTermLevel2 = selectedLabel;
            this.searchResultsLevel2 = [];
            this.handleSave(this.selectedQueueLevel2,'SCC_Level2_Escalation_team__c');
        } else {
            console.error('Selected value or label is undefined.');
        }
    }

    handleLevel3Select(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selectedLabel = event.currentTarget.dataset.label;
    
        if (selectedValue && selectedLabel) {
            this.selectedQueueLevel3 = selectedValue;
            this.searchTermLevel3 = selectedLabel;
            this.searchResultsLevel3 = [];
            this.handleSave(this.selectedQueueLevel3,'SCC_Level3_Escalation_team__c');
        } else {
            console.error('Selected value or label is undefined.');
        }
    }

    handleLevel4Select(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selectedLabel = event.currentTarget.dataset.label;
    
        if (selectedValue && selectedLabel) {
            this.selectedQueueLevel4 = selectedValue;
            this.searchTermLevel4 = selectedLabel;
            this.searchResultsLevel4 = [];
            this.handleSave(this.selectedQueueLevel4,'SCC_Level4_Escalation_team__c');
        } else {
            console.error('Selected value or label is undefined.');
        }
    }

    handleSave(selectedQueue, fieldName) {
        console.log(selectedQueue + '===' + fieldName);
        saveQueueToCustomObject({ customObjectId: this.recordId, queueName: selectedQueue, fieldName: fieldName})
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Queue saved successfully!',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error saving queue',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

    get hasResultsLevel1() {
        return this.searchResultsLevel1.length > 0;
    }

    get hasResultsLevel2() {
        return this.searchResultsLevel2.length > 0;
    }

    get hasResultsLevel3() {
        return this.searchResultsLevel3.length > 0;
    }

    get hasResultsLevel4() {
        return this.searchResultsLevel4.length > 0;
    }
}