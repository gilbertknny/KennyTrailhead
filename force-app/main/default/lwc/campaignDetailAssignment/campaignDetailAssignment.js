import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllCampaignDetails from '@salesforce/apex/SCC_CampaignDetailAssignmentController.getAllCampaignDetails';
import getCampaignDetails from '@salesforce/apex/SCC_CampaignDetailAssignmentController.getCampaignDetails';
import getTelesalesMakers from '@salesforce/apex/SCC_CampaignDetailAssignmentController.getTelesalesMakers';
import assignCampaignDetails from '@salesforce/apex/SCC_CampaignDetailAssignmentController.assignCampaignDetails';

const PAGE_SIZE = 10;

export default class CampaignDetailAssignment extends NavigationMixin(LightningElement) {
    @track createdDate;
    @track telesalesMakers = [];
    @track campaignDetails = [];
    @track displayedCampaignDetails = [];
    @track selectedMakerIds = [];
    @track selectedRowIds = [];
    @track showSpinner = false;
    @track currentPage = 1;
    @track totalRecords = 0;
    @track totalPages = 0;

    columns = [
        { label: 'Campaign Detail No', fieldName: 'Name', type: 'text' },
        { label: 'Campaign Name', fieldName: 'CampaignName', type: 'text' },
        { label: 'Customer Name', fieldName: 'Customer_Name__c', type: 'text' },
        { label: 'Phone', fieldName: 'Dial_Phone_No__c', type: 'phone' },
        { label: 'Status', fieldName: 'Status__c', type: 'text' },
        { label: 'Owner', fieldName: 'OwnerName', type: 'text' },
        { label: 'Outbound Category Detail', fieldName: 'Outbound_Category_Detail__c', type: 'text' },
        { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
        {
            type: 'button',
            typeAttributes: {
                label: 'View',
                name: 'view_details',
                title: 'View Details',
                variant: 'brand'
            }
        }
    ];

    connectedCallback() {
        this.loadTelesalesMakers();
        this.loadAllCampaignDetails();
    }
    
    async loadAllCampaignDetails() {
        this.showSpinner = true;
        try {
            const result = await getAllCampaignDetails();
            
            if (result && result.campaignDetails) {
                this.campaignDetails = result.campaignDetails.map(detail => ({
                    ...detail,
                    CampaignName: detail.Campaign__r ? detail.Campaign__r.Name : '',
                    OwnerName: detail.Owner ? detail.Owner.Name : ''
                }));
                this.totalRecords = this.campaignDetails.length;
                this.totalPages = Math.ceil(this.totalRecords / PAGE_SIZE);
                this.updateDisplayedRecords();
            }
        } catch (error) {
            this.showToast('Error', 'Error loading all campaign details: ' + error.message, 'error');
        } finally {
            this.showSpinner = false;
        }
    }

    async loadTelesalesMakers() {
        try {
            this.telesalesMakers = await getTelesalesMakers();
        } catch (error) {
            this.showToast('Error', 'Error loading telesales makers: ' + error.message, 'error');
        }
    }

    async loadCampaignDetails() {
        this.showSpinner = true;
        try {
            const result = await getCampaignDetails({ createdDate: this.createdDate });
            
            if (result && result.campaignDetails) {
                this.campaignDetails = result.campaignDetails.map(detail => ({
                    ...detail,
                    CampaignName: detail.Campaign__r ? detail.Campaign__r.Name : '',
                    OwnerName: detail.Owner ? detail.Owner.Name : ''
                }));
                this.totalRecords = this.campaignDetails.length;
                this.totalPages = Math.ceil(this.totalRecords / PAGE_SIZE);
                this.updateDisplayedRecords();
            }
        } catch (error) {
            this.showToast('Error', 'Error loading campaign details: ' + error.message, 'error');
        } finally {
            this.showSpinner = false;
        }
    }

    handleDateChange(event) {
        this.createdDate = event.target.value;
    }

    handleSearch() {
        this.currentPage = 1;
        this.loadCampaignDetails();
    }

    handleMakerSelection(event) {
        const makerId = event.target.value;
        if (event.target.checked) {
            this.selectedMakerIds.push(makerId);
        } else {
            this.selectedMakerIds = this.selectedMakerIds.filter(id => id !== makerId);
        }
    }

    handleRowSelection(event) {
        this.selectedRowIds = event.detail.selectedRows.map(row => row.Id);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
    
        console.log('Action Name:', actionName);
        console.log('Row Data:', row);
    
        if (actionName === 'view_details') {
            this.navigateToRecordPage(row.Id);
        }
    }
    
    navigateToRecordPage(recordId) {
        console.log('Navigating to record page for ID:', recordId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Campaign_Detail__c',
                actionName: 'view'
            }
        });
    }    

    handleAssign() {
        if (this.selectedMakerIds.length === 0 || this.selectedRowIds.length === 0) {
            this.showToast('Error', 'Please select both makers and campaign details', 'error');
            return;
        }

        // Debug statement
        console.log('Selected Makers:', this.selectedMakerIds);
        console.log('Selected Campaign Details:', this.selectedRowIds);

        // Distribute campaign details evenly among selected makers
        const numMakers = this.selectedMakerIds.length;
        const numCampaignDetails = this.selectedRowIds.length;
        const campaignDetailsPerMaker = Math.floor(numCampaignDetails / numMakers);
        const remainder = numCampaignDetails % numMakers;

        let startIndex = 0;
        const assignments = {};

        for (let i = 0; i < numMakers; i++) {
            const makerId = this.selectedMakerIds[i];
            const endIndex = startIndex + campaignDetailsPerMaker + (i < remainder ? 1 : 0);
            const assignedCampaignDetails = this.selectedRowIds.slice(startIndex, endIndex);
            assignments[makerId] = assignedCampaignDetails;
            startIndex = endIndex;
        }

        // Debug statement
        console.log('Assignments:', assignments);

        // Call Apex method to update owners
        this.showSpinner = true;
        assignCampaignDetails({ assignments: assignments })
            .then(() => {
                this.showToast('Success', 'Campaign details assigned successfully', 'success');
                this.loadCampaignDetails(); // Refresh campaign details
            })
            .catch(error => {
                this.showToast('Error', 'Error assigning campaign details: ' + error.message, 'error');
            })
            .finally(() => {
                this.showSpinner = false;
            });
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateDisplayedRecords();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updateDisplayedRecords();
        }
    }

    updateDisplayedRecords() {
        const start = (this.currentPage - 1) * PAGE_SIZE;
        const end = Math.min(start + PAGE_SIZE, this.totalRecords);
        this.displayedCampaignDetails = this.campaignDetails.slice(start, end);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    get selectedCount() {
        return this.selectedRowIds.length;
    }

    get isAssignDisabled() {
        return this.selectedMakerIds.length === 0 || this.selectedRowIds.length === 0;
    }

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    handleSelectAll(event) {
        if (event.target.checked) {
            this.selectedRowIds = this.campaignDetails.map(detail => detail.Id);
        } else {
            this.selectedRowIds = [];
        }
    }
}