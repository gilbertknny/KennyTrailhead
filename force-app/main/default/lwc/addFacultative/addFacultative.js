import { LightningElement , api, wire, track} from 'lwc';
//import getRelatedRisks from '@salesforce/apex/Aswata_AddFacultative_Controller.getRiskList';
import getFolderAndRiskDetail from '@salesforce/apex/Aswata_AddFacultative_Controller.getFolderAndRiskDetail';
import getListOpportunityFolder from '@salesforce/apex/Aswata_AddFacultative_Controller.getListOpportunityFolder';
import updateFacultativeStatus from '@salesforce/apex/Aswata_AddFacultative_Controller.updateFacultativeStatus';
import getRiskDetail from '@salesforce/apex/Aswata_AddFacultative_Controller.getRiskDetail';
import { CurrentPageReference,NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AddFacultative extends NavigationMixin(LightningElement) {

    @track isModalOpen = false;
    @track opportunityList = [];
    @track folderOpportunities = [];
    @track offeringOpportunities = [];
    @track sooList = [];
    @track isLoading = false;
    @track selectedOpportunities = [];
    @track selectedOfferingOpportunity;
    @track opportunityOptions = [];
    @track folderOptions = [];
    @track formData = {};
    @track folderStatusMap = {};

    @api folderName;
    @api facultativeOwner;
    
    @api leadId;
    
    columns = [
        { label: 'Opportunity Name', fieldName: 'OpportunityName', type: 'text' },
        { label: 'Busreq ID', fieldName: 'BusreqID', type: 'text' },
        { label: 'Risk ID', fieldName: 'Risk_ID__c', type: 'text' },
        { label: 'Risk Name', fieldName: 'Name', type: 'text' },
        { label: 'Amount Insured', fieldName: 'Amount_Insured__c', type: 'currency' }   
    ];

   sooColumns = [
        { label: 'Opportunity Name', fieldName: 'OpportunityName', type: 'text' },
        { label: 'Reinsurer', fieldName: 'Reinsurer', type: 'text' },
        { label: 'Share Offered (%)', fieldName: 'Share_offered__c', type: 'text' },
        { label: 'Share Approved (%)', fieldName: 'Share_accepted__c', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text'},
        {
            type: 'action',
            typeAttributes: { rowActions: [
                { label: 'View', name: 'view_details' }
                //,{ label: 'Update Status', name: 'update_status' }
            ]},
            label: ''
        },
    ];

    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        console.log('Page Reference:', JSON.stringify(currentPageReference));
        console.log('recordId from @api:', this.recordId);

        if (!this.recordId && currentPageReference) {
            this.recordId = currentPageReference.state?.recordId
                || currentPageReference.attributes?.recordId;
        }

        console.log('Detected recordId:', this.recordId);
        if (this.recordId) {
            //this.loadDefaultRiskData();
            this.loadFolderOptions();
        }
        
    }

    handleOpenModal() {
        console.log('Open Modal');
        const modal = this.template.querySelector('c-add-facultative-set-offering');
        if (modal) {
            // Pass data before opening
            modal.selectedOpportunities = this.selectedOpportunities;
            modal.folderId = this.formData.folderName;
            modal.openModal();
        }
    }

    handleCloseModal() {
        console.log('Add Facultative Set Offering modal closed');
    }

    async handleOptySelected(event) {
        const selectedRiskId = event.detail.value;
        console.log('Selected Risk ID:', selectedRiskId);
        this.selectedOfferingOpportunity = event.detail.value;
        if (!selectedRiskId) 
        {
            return;
        }

        try {
            const risk = await getRiskDetail({ riskId: selectedRiskId });

            console.log('Apex getRiskDetail result:', JSON.stringify(risk, null, 2));

            if (risk) {
                this.formData = {
                    ...this.formData,
                    riskNo: risk.RiskId,
                    riskName: risk.Name,
                    description: risk.Description,
                    situation: risk.Situation,
                    totalSumInsured: risk.AmountInsured,
                    accumulationAswataShare: risk.AccumulationAswataShare,
                    opportunityId: risk.OpportunityId,
                    opportunityName: risk.OpportunityName,
                    opportunityStage: risk.OpportunityStage,
                    busreqId: risk.BusreqId,
                    facFolderNo: risk.FacFolderNo,
                    facultativeOpportunityNo: risk.FacultativeOpportunityNo,
                    insuredName: risk.InsuredName,
                    startDatePeriod: risk.StartDate,
                    endDatePeriod: risk.EndDate,
                    facultativeStartPeriod: risk.StartDate,
                    facultativeEndPeriod: risk.EndDate,
                    treatyAmount: risk.TreatyAmount,
                    exhaustedAmount: risk.ExhaustedAmount,
                    remainingAmount: risk.RemainingAmount,
                    excessAmount: risk.ExcessAmount,
                    originalRate: risk.OriginalRate,
                    originalCommission: risk.OriginalCommission,
                    rateOffered: risk.RateOffered,
                    commissionOffered: risk.CommissionOffered,
                    shareOfferedPercent: risk.ShareOfferedPercent,
                    shareAcceptedPercent: risk.ShareAcceptedPercent,
                    shareBindingPercent: risk.ShareBinding,
                    sharePendingPercent: risk.SharePendingBinding,
                    shortFallPercent: risk.ShortFall,
                    folderStatus: risk.FolderStatus,
                    qqName: risk.QQName
                };
            }

        } catch (error) {
            console.error('Error fetching risk detail:', error);
        }
    }

    handleAddOpty() {
        this.isModalOpen = true;
        this.loadRisks();
    }

    // Fetch data from Apex
    /*async loadRisks() {
        this.isLoading = true;
        try {
            const data = await getRelatedRisks();

            // Map related fields into flat structure for datatable
            this.opportunityList = data.map(item => ({
                ...item,
                OpportunityName: item.Opportunity__r ? item.Opportunity__r.Name : '',
                BusreqID: item.Opportunity__r ? item.Opportunity__r.Busreq_ID__c : ''
            }));

            // Filter out already added ones if needed
            const addedIds = new Set(this.opportunityOptions.map(opt => opt.value));
            this.opportunityList = this.opportunityList.filter(r => !addedIds.has(r.Id));

        } catch (error) {
            console.error('Error fetching related risks:', error);
        } finally {
            this.isLoading = false;
        }
    }*/

    //////////////////////////////////////////////////////////////////////////////
    /* Folder Controller Below*/
    async loadFolderOptions() {
        if (!this.recordId) 
        {
            return;
        }
        this.isLoading = true;

        console.log('recordId: ' + this.recordId);
        
        try {
            const data = await getFolderAndRiskDetail({ recordId: this.recordId });
            // ✅ Populate opportunity picklist options
            if (data && data.folderOptions) {
                this.folderOptions = data.folderOptions || [];
                this.folderStatusMap = data.folderStatusMap || {};

                // Set default selection
                if (this.folderOptions.length > 0) {
                    const firstFolderId = this.folderOptions[0].value;
                    this.formData.folderName = firstFolderId;
                    this.formData.statusFolder = this.folderStatusMap[firstFolderId] || '';
                    
                    console.log('formData after loading folders:', JSON.stringify(this.formData, null, 2));
                    await this.loadFolderOpportunities(firstFolderId);
                }

            }
        } catch (error) {
            console.error('Error loading default risk data:', error);
        } finally {
            this.isLoading = false;
        }
    }

    handleFolderSelected(event) {
        const selectedFolderId = event.detail.value;
        this.formData.folderName = selectedFolderId;
        this.formData.statusFolder = this.folderStatusMap[selectedFolderId] || '';
        console.log('Selected Folder ID:', selectedFolderId);
        this.loadFolderOpportunities(selectedFolderId);
    }

    async loadFolderOpportunities(folderId) {
        if (!folderId) return;

        this.isLoading = true;
        try {
            const data = await getListOpportunityFolder({ recordId: folderId });

            // Log full data
            console.log('📦 Apex Response:', JSON.stringify(data, null, 2));

            // ✅ Always assign a *new array reference* to trigger reactivity
            this.folderOpportunities = [...(data?.folderOpportunities || [])];
            this.offeringOpportunities = [...(data?.offeringOpportunities || [])];
            this.opportunityOptions = [...(data?.assetFolder || [])];

            console.log('✅ Folder Opportunities:', JSON.stringify(this.folderOpportunities));
            console.log('✅ Offering Opportunities:', JSON.stringify(this.offeringOpportunities));
            console.log('✅ Options Opportunities:', JSON.stringify(this.opportunityOptions));

            // Reset pagination
            this.currentPage = 1;
            this.updatePagedData();

            // ✅ Also refresh the pagedData array reference
            this.pagedData = [...this.pagedData];
        
        } catch (error) {
            console.error('⚠️ Error loading folder opportunities:', error);
            this.folderOpportunities = [];
            this.offeringOpportunities = [];
            this.opportunityOptions = [];
            this.pagedData = [];
        } finally {
            this.isLoading = false;
        }
    }

    /* Folder Controller Above*/

    /*async loadDefaultRiskData() {
        if (!this.recordId) 
        {
            return;
        }
        this.isLoading = true;

        console.log('recordId: ' + this.recordId);
        try {
            const data = await getDefaultRiskDetail({ recordId: this.recordId });

            if (data && data.defaultAsset) {
                const risk = data.defaultAsset;

                console.log('data.defaultAsset: ', JSON.stringify(data.defaultAsset, null, 2));
                this.formData = {
                    ...this.formData,
                    riskNo: risk.RiskId,
                    riskName: risk.Name,
                    description: risk.Description,
                    situation: risk.Situation,
                    totalSumInsured: this.formatCurrency(risk.AmountInsured),
                    accumAmount: this.formatCurrency(risk.AccumulationAswataShare),
                    opportunityNo: risk.OpportunityId,
                    optyName: risk.OpportunityName,
                    opportunityStatus: risk.OpportunityStage,
                    policyNo: risk.BusreqId,
                    facFolderNo:risk.FacFolderNo,
                    facOpportunityNo:risk.FacultativeOpportunityNo,
                    insuredName: risk.InsuredName,
                    startDatePeriod: risk.StartDate,
                    endDatePeriod: risk.EndDate,
                    facultativeStartPeriod: risk.StartDate,
                    facultativeEndPeriod: risk.EndDate,
                    treatyAmount: this.formatCurrency(risk.TreatyAmount),
                    rateOriginal: risk.OriginalRate,
                    commissionOriginal: risk.OriginalCommission,
                    exhaustedAmount: this.formatCurrency(risk.ExhaustedAmount),
                    remainingAmount: this.formatCurrency(risk.RemainingAmount),
                    excessAmount: this.formatCurrency(risk.ExcessAmount),
                    shareOfferedPercent: risk.ShareOfferedPercent,
                    shareAcceptedPercent: risk.ShareAcceptedPercent,
                    shareBindingPercent: risk.ShareBinding,
                    sharePendingPercent: risk.SharePendingBinding,
                    shortFallPercent: risk.ShortFall,
                    rateOffered: risk.RateOffered,
                    commissionOffered: risk.CommissionOffered,
                    statusFolder: risk.FolderStatus, 
                    shareOfferedCurrency: risk.Currency,
                    shareAcceptedCurrency: risk.Currency,
                    shareBindingCurrency: risk.Currency,
                    sharePendingCurrency: risk.Currency,
                    shortFallCurrency: risk.Currency,
                    shareOfferedAmount: this.formatCurrency(risk.ShareOfferedAmount),
                    shareAcceptedAmount: this.formatCurrency(risk.ShareAcceptedAmount),
                    shareBindingAmount: this.formatCurrency(risk.ShareBindingAmount),
                    sharePendingAmount: this.formatCurrency(risk.SharePendingAmount),
                    shortFallAmount: this.formatCurrency(risk.ShortFallAmount),
                    //facultativePeriod: `${risk.StartDate || ''} - ${risk.EndDate || ''}`,
                    qqName: risk.QQName || ''
                };
                console.log('✅ Default formData:', JSON.stringify(this.formData, null, 2));

            }
            // ✅ Populate opportunity picklist options
            if (data && data.options) {
                this.opportunityOptions = data.options;
                this.formData.opportunityName = data.options?.[0]?.value;
            }

            // ✅ Populate datatable from sooList (list of all assets)
            if (data && data.sooList && data.sooList.length > 0) {
                this.sooList = data.sooList.map(item => ({
                    Id: item.Id,
                    Name: item.Name || '',
                    BusreqID: item.BusreqId || '',
                    Reinsurer: item.Reinsurer || '',
                    Risk_Id__c: item.RiskId || '',
                    share_offered__c: item.ShareOffered || '',
                    share_accepted__c: item.ShareAccepted || '',
                    Status: item.Status || '',
                    TotalSumInsured: item.TotalSumInsured  || ''
                }));
            } else {
                this.sooList = [];
            }

            
            
            console.log('✅ SOO list loaded:', this.sooList);
        } catch (error) {
            console.error('Error loading default risk data:', error);
        } finally {
            this.isLoading = false;
        }
    }*/


    


    
    handleAddOpportunity() {
        if (!this.selectedOpportunities.length) {
            alert('Please select at least one opportunity.');
            return;
        }

        // Convert selected opportunities into picklist options
        const newOptions = this.selectedOpportunities.map(opp => ({
            label: opp.Name,
            value: opp.Id
        }));

        // Merge with existing options (prevent duplicates)
        const existingIds = new Set(this.opportunityOptions.map(opt => opt.value));
        const mergedOptions = [
            ...this.opportunityOptions,
            ...newOptions.filter(opt => !existingIds.has(opt.value))
        ];

        this.opportunityOptions = mergedOptions;

        // Optionally preselect the first added item in combobox
        this.formData.opportunityName = newOptions[0].value;

        // Close modal
        this.isModalOpen = false;
    }

    get badgeClass() {
        switch (this.formData.statusFolder) {
            case 'In Progress':
                return 'slds-theme_warning'; // yellow/orange
            case 'Cancelled':
                return 'slds-theme_error'; // red
            case 'Closed':
                return 'slds-theme_success'; // green
            default:
                return 'slds-theme_info'; // blue
        }
    }
    
    get shareOfferedAmountDisplay() {
        return this.formData?.shareOfferedAmount || 0;
    }

    get shareAcceptedAmountDisplay() {
        return this.formData?.shareAcceptedAmount || 0;
    }

    get shareBindingAmountDisplay() {
        return this.formData?.shareBindingAmount || 0;
    }

    get sharePendingAmountDisplay() {
        return this.formData?.sharePendingAmount || 0;
    }

    get shortFallAmountDisplay() {
        return this.formData?.shortFallAmount || 0;
    }

    formatCurrency(value) {
        if (value === null || value === undefined || isNaN(value)) {
            return '-';
        }
        return new Intl.NumberFormat('id-ID', {
            style: 'currency',
            currency: 'IDR',
            maximumFractionDigits: 0
        }).format(value);
    }

    /*
        Pagination Controller Below
    */
    @track pagedData = [];
    @track currentPage = 1;
    @track pageSize = 5; // ✅ You can change this to 10, 20, etc.

    get totalPages() {
        return Math.ceil(this.offeringOpportunities.length / this.pageSize);
    }

    get disablePrevious() {
        return this.currentPage <= 1;
    }

    get disableNext() {
        return this.currentPage >= this.totalPages;
    }

    updatePagedData() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.pagedData = this.offeringOpportunities.slice(start, end);
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePagedData();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updatePagedData();
        }
    }


    /* Additional List Offering and Update Status Opty */
    
    @track isUpdateStatusModalOpen = false;
    @track selectedStatus;

    statusOptions = [
        { label: 'Offering', value: 'Offering' },
        { label: 'Bainding', value: 'Bainding' },
        { label: 'Slip Generated', value: 'Slip Generated' },
        { label: 'Accepted', value: 'Accepted' }
    ];

    // Close modal
    handleCloseModalOpty() {
        this.isModalOpen = false;
    }

    handleRowSelection(event) {
        this.selectedOpportunities = event.detail.selectedRows;
        console.log('Row Selected: ',this.selectedOpportunities);
    }

    navigateToRecord(row) {
        console.log('🔗 Navigating to record:', row.Id);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: row.Id,
                objectApiName: 'Opportunity', // adjust if not Opportunity
                actionName: 'view'
            }
        });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        console.log('Row Action:', actionName, 'on row:', row);

        switch (actionName) {
            case 'view_details':
                this.navigateToRecord(row);
                break;

            case 'update_status':
                case 'update_status':
                this.selectedRowId = row.Id;
                this.selectedStatus = row.Status; 
                this.isUpdateStatusModalOpen = true;
                break;

            default:
                console.warn('Unknown action:', actionName);
        }
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    async handleSubmitStatus() {
        if (!this.selectedStatus) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Please select a status.',
                variant: 'error'
            }));
            return;
        }

        try {
            await updateFacultativeStatus({
                recordId: this.selectedRowId,
                newStatus: this.selectedStatus
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Status updated successfully.',
                variant: 'success'
            }));

            // small delay to ensure DB commit
            await new Promise(resolve => setTimeout(resolve, 800));

            // reload fresh data
            await this.loadFolderOpportunities(this.formData.folderName);

            // force reactivity & pagination refresh
            this.offeringOpportunities = [...this.offeringOpportunities];
            this.updatePagedData();

            console.log('♻️ Refreshed offering opportunities:', JSON.stringify(this.offeringOpportunities));

            // close modal
            this.isUpdateStatusModalOpen = false;
            this.selectedStatus = null;
            this.selectedRowId = null;

        } catch (error) {
            console.error(error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error updating status',
                message: error.body?.message || error.message,
                variant: 'error'
            }));
        }
    }

    handleCloseStatusModal() {
        this.isUpdateStatusModalOpen = false;
    }
}