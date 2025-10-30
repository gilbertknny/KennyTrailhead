import { LightningElement, wire, track, api } from 'lwc';
import getUserBranchName from '@salesforce/apex/accumulationController.getUserBranchName';
import searchAssets from '@salesforce/apex/accumulationController.searchAssets';
import getInitialAssetData from '@salesforce/apex/accumulationController.getInitialAssetData'; 
import createAccumulationRecord from '@salesforce/apex/accumulationController.createAccumulationRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Accumulation extends LightningElement {
    @api recordId; 

    // --- DATA HEADER ---
    @track businessRequestId = null; 
    @track insuredName = null;     
    @track address = null; 
    @track zipCode = null; 
    @track inceptionDate = null; 
    @track version = null; 
    @track tsi = null; 
    @track policyNumber = null; 
    @track totalCurrency = 'IDR'; 

    // --- DATA TABEL & PENCARIAN ---
    @track city = '';
    @track accumulationList = []; 
    @track requestList = [];
    @track searchCriteria = {}; 
    showRequestList = false;
    @track isLoading = false;

    @wire(getInitialAssetData, { assetId: '$recordId' })
    wiredInitialData({ error, data }) {
        if (data) {
            this.businessRequestId = data.businessRequestId;
            
            const initialRow = data.assetRow;
            initialRow.effectiveDate = new Date().toLocaleDateString('en-GB'); 
            initialRow.businessCode = 'NB';
            this.accumulationList = [initialRow];
            this.updateTotalCurrency(); 
        } else if (error) {

        }
    }

    @wire(getUserBranchName)
    wiredBranchName({ data, error }) {
        if (data) {
            this.city = data;
        } else if (error) {
            console.error('Error fetching branch name: ', error);
            this.showToast('Error', 'Unable to fetch branch name', 'error');
        }
    }

    connectedCallback() {
        this.initializeSearchCriteria();
    }
    
    get totalTSI() {
        return this.accumulationList.reduce((total, item) => total + item.sumInsured, 0);
    }
    
    updateTotalCurrency() {
        if (this.accumulationList.length > 0) {
            this.totalCurrency = this.accumulationList[0].cur;
        } else {
            this.totalCurrency = 'IDR';
        }
    }

    handleSearchCriteriaChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;
        this.searchCriteria = { ...this.searchCriteria, [fieldName]: fieldValue };
    }

    handleRemove(event) {
        const recordIdToRemove = event.currentTarget.dataset.id;
        this.accumulationList = this.accumulationList.filter(item => item.id !== recordIdToRemove);
        this.showToast('Success', 'Record removed successfully', 'success');
        this.updateTotalCurrency(); 
    }
    
    handleSearch() {
        this.isLoading = true;
        this.requestList = []; 

        searchAssets({ 
            addressQuery: this.searchCriteria.address, 
            policyQuery: this.searchCriteria.policyNumber,
            zipCodeQuery: this.searchCriteria.zipCode,
            nkrQuery: this.searchCriteria.nkr
        })
        .then(result => {
            this.requestList = result; 
            this.showRequestList = true;
            this.showToast('Success', `${result.length} record(s) found.`, 'success');
            this.isLoading = false;
        })
        .catch(error => {
            console.error('Error searching assets: ', error);
            let errorMessage = 'Unknown error';
            if (error && error.body && error.body.message) {
                errorMessage = error.body.message;
            }
            this.showToast('Error', 'Error searching records: ' + errorMessage, 'error');
            this.isLoading = false;
        });
    }

    initializeSearchCriteria() {
        this.searchCriteria = {
            address: '',
            zipCode: '',
            policyNumber: '',
            nkr: '' 
        };
    }
    
    handleReset() {
        this.initializeSearchCriteria();
        this.requestList = [];
        this.showRequestList = false;
    }

    handleJoin(event) {
        const requestId = event.currentTarget.dataset.id;
        const selectedRequest = this.requestList.find(item => item.id === requestId);

        if (selectedRequest && !this.accumulationList.some(item => item.id === selectedRequest.id)) {
            
            if (this.accumulationList.length > 0 && this.accumulationList[0].cur !== selectedRequest.cur) {
                this.showToast('Error', 'Cannot join record. Currency does not match the existing list.', 'error');
                return;
            }

            const newItemForAccumulation = {
                id: selectedRequest.id,
                requestNum: selectedRequest.requestNum,
                policyNum: selectedRequest.policyNum,
                address: selectedRequest.address,
                zipCode: selectedRequest.zipCode,
                nkr: selectedRequest.nkr,
                cur: selectedRequest.cur, 
                sumInsured: selectedRequest.sumInsured, 
                riskId: selectedRequest.riskId,
                opportunityId: selectedRequest.opportunityId, 
                effectiveDate: new Date().toLocaleDateString('en-GB'), 
                businessCode: 'NB'
            };
            this.accumulationList = [...this.accumulationList, newItemForAccumulation];
            this.updateTotalCurrency(); 
            this.showToast('Success', 'Request joined.', 'success');
        } else {
            this.showToast('Info', 'This request is already in the accumulation list.', 'info');
        }
    }

    handleTemporarilySave() {
    }

    
    handleSetAccumulation() {
        if (this.accumulationList.length === 0) {
            this.showToast('Error', 'Cannot save. Accumulation list is empty.', 'error');
            return;
        }

        this.isLoading = true;

        console.log('Logging IDs dari Accumulation List:');
        this.accumulationList.forEach((item, index) => {
            console.log(`Item ${index + 1} (Asset ID: ${item.id}): OppId = ${item.opportunityId}`);
        });

        const firstItem = this.accumulationList[0];
        const calculatedTSI = this.totalTSI;
        const currentCurrency = this.totalCurrency;

        let newVersion = '1.0';
        if (this.version) {
            const currentVersion = parseFloat(this.version);
            newVersion = (currentVersion + 1).toFixed(1);
        }

        const recordData = {
            businessRequestId: firstItem.requestNum,
            address: firstItem.address,
            zipCode: firstItem.zipCode,
            totalTSI: calculatedTSI,
            versionStr: newVersion,
            oppId: firstItem.opportunityId,
            policyNum: firstItem.policyNum 
        };

        createAccumulationRecord({ data: recordData }) 
            .then(newRecordName => { 
                this.isLoading = false;
                
                this.businessRequestId = recordData.businessRequestId;
                this.address = recordData.address;
                this.zipCode = recordData.zipCode;
                this.tsi = recordData.totalTSI.toLocaleString('id-ID', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
                this.version = recordData.versionStr; 

                const today = new Date();
                const day = String(today.getDate()).padStart(2, '0');
                const year = today.getFullYear();
                const monthNames = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
                const month = monthNames[today.getMonth()];
                this.inceptionDate = `${day}-${month}-${year}`;

                this.showToast(
                    'Success', 
                    // `Accumulation record created (Name: ${newRecordName}). Version ${this.version}. Flow triggered.`, 
                    `Accumulation record created. Version ${this.version}. Flow triggered.`, 
                    'success'
                );
            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error creating accumulation record: ', error);
                let errorMessage = 'Unknown error';
                if (error && error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showToast('Error', 'Error saving record: ' + errorMessage, 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}