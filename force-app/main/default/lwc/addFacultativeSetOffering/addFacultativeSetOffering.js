import { LightningElement, api, track } from 'lwc';
import createOpportunitiesAndCloneAssets from '@salesforce/apex/OpportunityController.createOpportunitiesAndCloneAssets';
import searchAccounts from '@salesforce/apex/Aswata_AddFacultative_Controller.searchAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AddFacultativeSetOffering extends LightningElement {

    @api selectedOpportunities = [];
    @api folderId = '';
    @api isOpen = false;
    @track formData = {};
    @track riskNameOptions = [];
    @track listReasurance = [];

    /* handle search */
    @track searchKey = '';
    @track searchResults = [];
    @track listReasurance = [];
    @track showDropdown = false;

    handleSearchChange(event) {
        this.searchKey = event.target.value.trim();

        if (this.searchKey.length > 1) {
            searchAccounts({ searchKey: this.searchKey })
                .then(result => {
                    this.searchResults = result.map(acc => ({
                        Id: acc.Id,
                        Name: acc.Name,
                        Insurance_ID__c: acc.Insurance_ID__c
                    }));
                     console.log('✅ Processed searchResults:', JSON.stringify(this.searchResults));
                    this.showDropdown = true;
                })
                .catch(error => {
                    console.error('Error searching accounts:', error);
                });
        } else {
            this.searchResults = [];
            this.showDropdown = false;
        }
    }

    handleSelectAccount(event) {
        const accountId = event.currentTarget.dataset.id;
        const account = this.searchResults.find(acc => acc.Id === accountId);

        if (account) {
            // prevent duplicate entries
            const alreadyExists = this.listReasurance.some(r => r.PanelID === account.Insurance_ID__c);
            if (!alreadyExists) {
                this.listReasurance = [
                    ...this.listReasurance,
                    { Id: account.Id, PanelName: account.Name, PanelID: account.Insurance_ID__c }
                ];
            }
        }

        this.showDropdown = false;
        this.searchKey = '';
        this.searchResults = [];
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;

        // Extract only the Ids from selected rows
        const selectedIds = selectedRows.map(row => row.Id);

        console.log('Selected Account IDs:', selectedIds);

        // ✅ Update your formData in the same consistent pattern
        this.formData = {
            ...this.formData,
            accountIds: selectedIds
        };

        console.log('Updated formData:', JSON.stringify(this.formData, null, 2));

    }
    /* end handle search */

    @track selectedRiskId = '';
    @track totalSumInsured = 0;
    @track shareOfferedTotal = 0;
    @track shareOfferedPercent = 0;

    @track shareAcceptedTotal = 0;
    @track shareAcceptedPercent = 0;

    @track shareBindingTotal = 0;
    @track shareBindingPercent = 0;

    columns = [
        { label: 'Panel Name', fieldName: 'PanelName', type: 'text' },
        { label: 'Panel Id', fieldName: 'PanelID', type: 'text' }  
    ];

    inputModeOptions = [
        { label: 'Across Risk', value: 'Across Risk' },
        { label: 'Per-Risk', value: 'Per Risk' }
    ];

    termConditionOptions = [
        { label: 'Across Panel', value: 'Across Panel' },
        { label: 'Per-Panel', value: 'Per Panel' }
    ];
    riskNameOptions = [];

    /*offeringStatusOptions = [
        { label: 'Draft', value: 'Draft' },
        { label: 'Submitted', value: 'Submitted' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Rejected', value: 'Rejected' }
    ];*/
    
    get showRiskName() {
        return this.formData.inputMode === 'Per Risk';
    }

    get showInputPanel(){
        return this.formData.termCondition === 'Per Panel';
    }

    @api openModal() {
        this.isOpen = true;

        console.log('Modal folderId from parent:', this.folderId); // <-- check here

        // Ensure formData exists
        if (!this.formData) { 
            this.formData = {};
        }

        // Merge folderId safely
        this.formData = {
            ...this.formData,
            folderId: this.folderId || ''
        };

        console.log('Modal opened with:', JSON.stringify(this.selectedOpportunities));
        if (this.selectedOpportunities && this.selectedOpportunities.length > 0) {
            this.riskNameOptions = this.selectedOpportunities.map(item => ({
                label: item.BusreqID,
                value: item.Id
            }));
        } else {
            this.riskNameOptions = [];
        }
    }

    @api closeModal() {
        this.isOpen = false;
    }

    handleClose() {
        this.closeModal();
        this.dispatchEvent(new CustomEvent('close'));
    }

    async handleSubmit() {
        this.isLoading = true;
        
        if (
            !this.formData.hasOwnProperty('accountIds') ||  // Missing key
            !Array.isArray(this.formData.accountIds) ||     // Not an array
            this.formData.accountIds.length === 0           // Empty array
        ) {
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Please select at least one Account before submitting.',
                    variant: 'error'
                })
            );
            return; // 🚫 Stop further execution
        }

        try {
            const jsonInput = JSON.stringify(this.formData);
            console.log('➡️ Sending JSON:', jsonInput);

            const result = await createOpportunitiesAndCloneAssets({ jsonInput });
            console.log('✅ Apex Result:', JSON.stringify(result, null, 2));

            if (result && result.isSuccess) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: result.message,
                        variant: 'success'
                    })
                );

                console.log('this.formData.inputMode:', this.formData.inputMode);
                if (this.formData.inputMode === 'Across Risk') {
                    setTimeout(() => {
                        this.closeModal();
                        this.dispatchEvent(new CustomEvent('close'));
                    }, 500);
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: result?.message || 'Operation failed.',
                        variant: 'error'
                    })
                );
            }
        } catch (error) {
            console.error('💥 JS or Apex Error (Full):', error);
            console.error('💥 JS or Apex Error (Stringified):', JSON.stringify(error, null, 2));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error?.body?.message || error?.message || 'Unexpected error.',
                    variant: 'error'
                })
            );
        } finally {
            this.isLoading = false;
        }
    }


    handleInputChange(event) {
        const field = event.target.name; // 👈 cleaner than data-field
        const value = event.target.value;

        this.formData = {
            ...this.formData,
            [field]: value
        }; 
        if (field === 'riskId') {
            this.selectedRiskId = value;

            this.formData = {
                ...this.formData,
                riskId: [this.selectedRiskId] // 👈 always store as array
            };
        }

        /*
        if (field === 'Rate__c') {
            const ratePercent = parseFloat(value) || 0;
            const totalShare = parseFloat(this.shareOfferedIdr) || 0;

            // Calculate rebate (Rate% * shareOfferedIdr)
            const premi = (ratePercent / 100) * totalShare;

            // Format as IDR currency
            const formattedPremi = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
                maximumFractionDigits: 0
            }).format(premi);

            // Update form data
            this.formData = {
                ...this.formData,
                Premium_Ceded__c: formattedPremi
            };
        }

        if (field === 'Share_Offered__c') {
            const percent = parseFloat(value) || 0; // user enters 10 → stays 10
            this.shareOfferedPercent = percent;

            // Calculate total
            this.shareOfferedTotal = this.totalSumInsured * (percent / 100);

            // Format as currency
            this.shareOfferedIdr = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
                maximumFractionDigits: 0
            }).format(this.shareOfferedTotal);

            console.log(
                `💰 Share Offered: ${percent}% of ${this.totalSumInsured} = ${this.shareOfferedIdr}`
            );
        }

        if (field === 'Share_Accepted_Approved__c') {
            const percent = parseFloat(value) || 0; // user enters 10 → stays 10
            this.shareAcceptedPercent = percent;

            // Calculate total
            this.shareAcceptedTotal = this.totalSumInsured * (percent / 100);

            // Format as currency
            this.shareAcceptedIdr = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
                maximumFractionDigits: 0
            }).format(this.shareAcceptedTotal);

            console.log(
                `💰 Share Offered: ${percent}% of ${this.totalSumInsured} = ${this.shareAcceptedIdr}`
            );
        }

         if (field === 'Share_Binding__c') {
            const percent = parseFloat(value) || 0; // user enters 10 → stays 10
            this.shareBindingPercent = percent;

            // Calculate total
            this.shareBindingTotal = this.totalSumInsured * (percent / 100);

            // Format as currency
            this.shareBindingIdr = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
                maximumFractionDigits: 0
            }).format(this.shareBindingTotal);

            console.log(
                `💰 Share Offered: ${percent}% of ${this.totalSumInsured} = ${this.shareBindingIdr}`
            );
        }*/

        if (field === 'inputMode') {
            if (value === 'Across Risk') {
                const riskIds = this.riskNameOptions.map(opt => opt.value);

                this.formData = {
                    ...this.formData,
                    riskId: riskIds,
                };
            } else {
                // Remove riskId from formData if it exists
                const { riskId, ...rest } = this.formData;
                this.formData = { ...rest };
            }
        }


        console.log('Updated formData:', JSON.stringify(this.formData, null, 2));
    }

    

    /*handleLookUpSelected(event) {
        const fieldApiName = event.target.dataset.field;  
         // 👈 from data-field in HTML
        const record = event.detail;
        console.log('record:', JSON.stringify(record));

        const fieldMap = (record && record.FieldMap) ? record.FieldMap : {};
        console.log('fieldMap:', JSON.stringify(fieldMap));

        const recordId = record.Id;
        const recordName = record.Name;

        this.formData = {
            ...this.formData,
            [fieldApiName]: recordId
        };

        console.log('Updated formData:', JSON.stringify(this.formData));  
    }*/

    /*handleRiskSelection(event) {
        this.selectedRiskId = event.detail.value;

        // Find the selected risk object based on the selected Id
        const selectedRisk = this.selectedOpportunities.find(
            item => item.Id === this.selectedRiskId
        );

        if (selectedRisk) {
            this.totalSumInsured = selectedRisk.TotalSumInsured || 0;
            console.log('✅ Selected TotalSumInsured:', this.totalSumInsured);

            this.totalSumInsuredIdr = new Intl.NumberFormat('id-ID', {
                style: 'currency',
                currency: 'IDR',
                maximumFractionDigits: 0
            }).format(this.totalSumInsured);
            // (Optional) Save into formData for consistency
            this.formData = {
                ...this.formData,
                riskId: this.selectedRiskId,
                totalSumInsured: this.totalSumInsured
            };
            console.log('Updated formData:', JSON.stringify(this.formData, null, 2));
        } /*else {
            this.totalSumInsured = 0;
        }
    }*/

}