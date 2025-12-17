import { LightningElement, api, wire, track } from 'lwc';
import getRelatedRisks from '@salesforce/apex/Aswata_AddFacultative_Controller.getRiskList';
import getRiskAssets from '@salesforce/apex/Aswata_AddFacultative_Controller.getRiskByFolder';
import { NavigationMixin } from 'lightning/navigation';
import updateSelectedRisks from '@salesforce/apex/Aswata_AddFacultative_Controller.updateSelectedRisks';


const COLUMNS = [
    {
        label: 'Asset Name',
        fieldName: 'assetUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_self'
        }
    },
    { label: 'Risk ID', fieldName: 'Risk_ID__c' },
    { label: 'Amount Insured', fieldName: 'Amount_Insured__c', type: 'currency' },
    { label: 'Opportunity Name', fieldName: 'opportunityName' },
    { label: 'Busreq ID', fieldName: 'busreqId' }
];

export default class NewFacultative extends LightningElement {

    @api recordId;
    @track assetList = [];
    @track selectedRowIds = [];
    @track isModalOpen = false;
    @track opportunityList = [];
    @track isLoading = false;
    selectedRows;

    columns = COLUMNS;

    @wire(getRiskAssets, { recordId: '$recordId' })
    wiredAssets({ data, error }) {
        if (data) {
            this.assetList = data.map(row => ({
                ...row,
                assetUrl: '/' + row.Id,
                opportunityName: row.Opportunity__r?.Name,
                busreqId: row.Opportunity__r?.Busreq_ID__c
            }));
        } else if (error) {
            console.error(error);
        }
    }

    handleRowSelection(event) {
        this.selectedOpportunities = event.detail.selectedRows;
        console.log('Row Selected: ',this.selectedOpportunities);
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'open_asset') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: row.Id,
                    objectApiName: 'Asset',
                    actionName: 'view'
                }
            });
        }
    }

    // Open modal Opportunity //

    handleAdd() {
        this.isModalOpen = true;
        this.loadRisks();
    }

    handleCloseModalOpty() {
        this.isModalOpen = false;
    }

    async loadRisks() {
        this.isLoading = true;
        try {
            const data = await getRelatedRisks();

            // Map related fields into flat structure for datatable
            this.opportunityList = data.map(item => ({
                ...item,
                assetUrl: '/' + item.Id,
                Name: item.Name,
                opportunityName: item.Opportunity__r ? item.Opportunity__r.Name : '',
                busreqId: item.Opportunity__r ? item.Opportunity__r.Busreq_ID__c : ''
            }));
            console.log('Fetched opportunityList: ', JSON.stringify(this.opportunityList));

            // Filter out already added ones if needed
            //const addedIds = new Set(this.opportunityOptions.map(opt => opt.value));
            //this.opportunityList = this.opportunityList.filter(r => !addedIds.has(r.Id));

        } catch (error) {
            console.error('Error fetching related risks:', error);
        } finally {
            this.isLoading = false;
        }
    }

    async handleAddOpportunity() {
        if (!this.selectedOpportunities || !this.selectedOpportunities.length) {
            alert('Please select at least one opportunity.');
            return;
        }

        this.isLoading = true;

        try {
            const selectedIds = this.selectedOpportunities.map(row => row.Id);

            await updateSelectedRisks({
                assetIds: selectedIds,
                folderId: this.recordId
            });

            const existingIds = new Set(this.assetList.map(a => a.Id));

            const newAssets = this.selectedOpportunities
                .filter(row => !existingIds.has(row.Id))
                .map(row => ({
                    ...row,
                    assetUrl: '/' + row.Id,
                    opportunityName: row.opportunityName,
                    busreqId: row.busreqId
                }));

            this.assetList = [...this.assetList, ...newAssets];

            this.selectedOpportunities = [];
            this.isModalOpen = false;

        } catch (error) {
            console.error(error);
            alert('Failed to add assets.' , error);
        } finally {
            this.isLoading = false;
        }
    }

    // Open Modal Offering

    handleOpenModal() {
        console.log('Open Modal');
        const modal = this.template.querySelector('c-add-facultative-set-offering');
        if (modal) {
            // Pass data before opening
            modal.selectedOpportunities = this.selectedOpportunities;
            modal.folderId = this.recordId;
            modal.openModal();
        }
    }

    handleCloseModal() {
        console.log('Add Facultative Set Offering modal closed');
    }



}