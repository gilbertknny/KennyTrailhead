import { LightningElement, track, api } from 'lwc';
//import updateLeadInformation from '@salesforce/apex/Aswata_EditLeadInformation_Controller.updateLeadInformation';

export default class EditLeadAccountInformation extends LightningElement {
    @api leadId;
    @api jsonString = '';

    @track formData = {
        Account_Type__c: '',
        Account_Segment__c: '',
        Account_Sub_Segment__c: '',
        Account_Pipeline_Status__c: '',
        Business_Segmentation__c: ''
    };

    @track accountTypeOptions = [
        { label: 'General', value: '0' },
        { label: 'Bank', value: '1' },
        { label: 'Finance/Leasing', value: '4' },
        { label: 'Broker', value: '2' },
        { label: 'Agent', value: '3' }
    ];

    @track accountSegmentOptions = [];
    @track accountSubSegmentOptions = [];
    @track pipelineStatusOptions = [];
    @track businessSegmentationOptions = [];

    // -----------------------------
    // Account Type change
    // -----------------------------
    handleAccountTypeChange(event) {
        this.formData.accountType = event.detail.value;
        this.formData.accountSegment = '';
        this.formData.accountSubSegment = '';
        this.formData.pipelineStatus = '';
        this.formData.businessSegmentation = '';

        // 🧩 SEGMENT options depend on Account Type
        switch (this.formData.accountType) {
            case '0':
            case '3':
                this.accountSegmentOptions = [
                    { label: 'Individual', value: 'I' },
                    { label: 'Business', value: 'E' }
                ];
                break;
            case '1':
            case '4':
            case '2':
                this.accountSegmentOptions = [
                    { label: 'Business', value: 'E' }
                ];
                break;
            default:
                this.accountSegmentOptions = [];
        }
        this.accountSubSegmentOptions = [];
        this.pipelineStatusOptions = [];
        this.businessSegmentationOptions = [];
    }

    // -----------------------------
    // Account Segment change
    // -----------------------------
    handleAccountSegmentChange(event) {
        this.formData.accountSegment = event.detail.value?.trim();
        this.formData.accountSubSegment = '';
        this.formData.pipelineStatus = '';
        this.formData.businessSegmentation = '';

        const { accountType, accountSegment } = this.formData;
        this.accountSubSegmentOptions = [];

        if (!accountType || !accountSegment) {
            return; // prevent running if values are missing
        }
        console.log('accountType: ', JSON.stringify(accountType));
        console.log('accountSegment: ', JSON.stringify(accountSegment));

        // 🧩 SUB-SEGMENT options depend on both Account Type & Segment
        if (accountSegment === 'I') {
            if (accountType === '0' || accountType === '3') {
                this.accountSubSegmentOptions = [{ label: 'Private', value: 'Y' }];
            }
        } else if (accountSegment === 'E') {
            if (['0', '1', '4', '2'].includes(accountType)) {
                this.accountSubSegmentOptions = [
                    { label: 'Private', value: 'Y' },
                    { label: 'Government', value: 'N' }
                ];
            } else if (accountType === '3') {
                this.accountSubSegmentOptions = [{ label: 'Private', value: 'Y' }];
            }
        }

        this.pipelineStatusOptions = [];
        this.businessSegmentationOptions = [];
    }


    // -----------------------------
    // Sub-Segment change
    // -----------------------------
    handleAccountSubSegmentChange(event) {
        this.formData.accountSubSegment = event.detail.value;
        this.formData.pipelineStatus = '';
        this.formData.businessSegmentation = '';
        // 🧩 PIPELINE STATUS now depends ONLY on Account Type
        const { accountType } = this.formData;

        if (accountType === '0') {
            this.pipelineStatusOptions = [
                { label: 'Direct', value: 'Direct' }
            ];
        } else {
            this.pipelineStatusOptions = [
                { label: 'Direct', value: 'Direct' },
                { label: 'Channel', value: 'Channel' }
            ];
        }
        this.businessSegmentationOptions = [];
    }

    handlePipelineStatusChange(event) {
        this.formData.pipelineStatus = event.detail.value;
        this.formData.businessSegmentation = '';

        // 🧩 PIPELINE STATUS now depends ONLY on Account Type
        const { accountType, accountSegment } = this.formData;

        // 🧩 Determine Business Segment
        let businessSegments = [];

        if (accountType === '0') {
            if (accountSegment === 'I') {
                businessSegments = [{ label: 'Retail', value: 'Retail' }];
            } else if (accountSegment === 'E') {
                businessSegments = [{ label: 'Corporate', value: 'Corporate' }];
            }
        } else if (accountType === '1' || accountType === '2') {
            businessSegments = [{ label: 'Corporate', value: 'Corporate' }];
        } else if (accountType === '4' || accountType === '3') {
            businessSegments = [{ label: 'Retail', value: 'Retail' }];
        }

        this.businessSegmentationOptions = businessSegments;
    }

     handleBusinessSegmentChange(event) {
        this.formData.businessSegmentation = event.detail.value;
        this.formData.id = this.leadId;
        console.log('FormData final: ' + JSON.stringify(this.formData));
        this.jsonString = JSON.stringify(this.formData)
    }

    // -----------------------------
    // Disable logic
    // -----------------------------
    get isAccountSegmentDisabled() {
        return !this.formData.accountType;
    }

    get isAccountSubSegmentDisabled() {
        return !this.formData.accountSegment;
    }

    get isPipelineStatusDisabled() {
        return !this.formData.accountSubSegment;
    }

    get isBusinessSegmentationDisabled() {
        return !this.formData.pipelineStatus;
    } 


    /*async handleSave() {
        try {
            const payload = {
                ...this.formData,
                id: this.recordId || this.formData.id // use current record id if available
            };

            console.log('Updating Lead with:', JSON.stringify(payload));

            await updateLeadInformation({ leadData: payload });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Lead information updated successfully!',
                    variant: 'success'
                })
            );

        } catch (error) {
            console.error('Error updating Lead:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating Lead',
                    message: error.body?.message || error.message,
                    variant: 'error'
                })
            );
        }
    }*/
}