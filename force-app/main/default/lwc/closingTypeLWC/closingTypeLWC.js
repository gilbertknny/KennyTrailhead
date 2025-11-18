import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent }                from 'lightning/platformShowToastEvent';
import { refreshApex }                   from '@salesforce/apex';

import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import CLOSING_CLASS_FIELD from '@salesforce/schema/Opportunity.Closing_Class__c';
import POLICY_CLOSING_TYPE_FIELD from '@salesforce/schema/Opportunity.Policy_Closing_Type__c';
import TYPE_OF_BUSINESS_FIELD from '@salesforce/schema/Opportunity.Type_Of_Business__c';

import getOpportunity                    from '@salesforce/apex/OpportunityController.getOpportunity';
import searchCoInsurerAccounts           from '@salesforce/apex/OpportunityController.searchCoInsurerAccounts';
import getCoInsurerData                  from '@salesforce/apex/OpportunityController.getCoInsurerData';
import saveCoInsurerData                 from '@salesforce/apex/OpportunityController.saveCoInsurerData';
import deleteCoInsurerData               from '@salesforce/apex/OpportunityController.deleteCoInsurerData';

export default class OpportunityClosingPolicy extends LightningElement {
  @api recordId;
  @track recordTypeId;

  @track closingClassOptions       = [];
  @track policyClosingTypeOptions  = [];
  @track typeOfBusinessOptions     = [];

  @track closingClassValue;
  @track policyClosingTypeValue;
  @track typeOfBusinessValue;
  @track leaderPolicyNumber;

  //@track fieldList     = [];
  @track searchResults = [];
  @track coInsurers    = [];
  @track stage = null;

  // Modal state
  @track showDeleteModal       = false;
  selectedRowForDeletion       = null;

  // Keep track of originally loaded IDs to enable Save button only for new rows
  originalCoInsurerIds         = new Set();

  // Hold the wired result so we can refreshApex on save/delete
  wiredCoInsurersResult;

  // Datatable columns: clickable Account Name, plus Delete action
  columns = [
    {
      label: 'Account Name',
      fieldName: 'recordUrl',
      type: 'url',
      typeAttributes: {
        label: { fieldName: 'Name' },
        target: '_blank'
      }
    },
    { label: 'Type', fieldName: 'Type', type: 'text' },
    { label: 'Acc Segment',    fieldName: 'AccSegment',    type: 'text' },
    {
      type: 'action',
      typeAttributes: {
        rowActions: [
          { label: 'Delete', name: 'delete' }
        ]
      }
    }
  ];

  connectedCallback(){
    console.log('last updated by Marco 10/10/2025 13.34');
    console.log('recordId: '+this.recordId);
  }

  /***************************************************************************
   * Wire Apex: Opportunity fields
   ***************************************************************************/
  // 1. Fetch default Record Type ID for picklist scoping
  @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
  objectInfo({ data, error }) {
    if (data) {
      this.recordTypeId = data.defaultRecordTypeId;
    } else if (error) {
      console.error('Error fetching object info:', error);
    }
  }

  // 2. Load picklist values for each field
  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: CLOSING_CLASS_FIELD
  })
  wiredClosingClass({ data, error }) {
    if (data) {
      this.closingClassOptions = data.values;
    } else if (error) {
      console.error('Error loading Closing Class picklist values:', error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: POLICY_CLOSING_TYPE_FIELD
  })
  wiredPolicyClosingType({ data, error }) {
    if (data) {
      this.policyClosingTypeOptions = data.values;
    } else if (error) {
      console.error('Error loading Policy Closing Type values:', error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: '$recordTypeId',
    fieldApiName: TYPE_OF_BUSINESS_FIELD
  })
  wiredTypeOfBusiness({ data, error }) {
    if (data) {
      this.typeOfBusinessOptions = data.values;
    } else if (error) {
      console.error('Error loading Type of Business values:', error);
    }
  }

  // 3. Load existing Opportunity values from Apex
  @wire(getOpportunity, { opportunityId: '$recordId' })
  wiredOpportunity({ data, error }) {
    if (data) {
      this.stage = data.StageName;
      this.closingClassValue      = data.Closing_Class__c;
      this.policyClosingTypeValue = data.Policy_Closing_Type__c;
      this.typeOfBusinessValue    = data.Type_Of_Business__c;
      this.leaderPolicyNumber     = data.Leader_Policy_Number__c;
    } else if (error) {
      console.error('Error loading Opportunity:', error);
    }
  }

  // 4. Handlers to keep values in sync with UI
  handleClosingClassChange(event) {
    this.closingClassValue = event.detail.value;
  }

  handlePolicyClosingTypeChange(event) {
    this.policyClosingTypeValue = event.detail.value;
  }

  handleTypeOfBusinessChange(event) {
    this.typeOfBusinessValue = event.detail.value;
  }

  handleLeaderPolicyNumberChange(event) {
    this.leaderPolicyNumber = event.detail.value;
  }

  /***************************************************************************
   * Wire Apex: Co-Insurer rows
   ***************************************************************************/
  @wire(getCoInsurerData, { opportunityId: '$recordId' })
  wiredCoInsurers(result) {
    this.wiredCoInsurersResult = result;
    const { data, error } = result;
    if (data) {
      // Map each record into the format our datatable needs
      this.coInsurers = data.map(r => ({
        id:        r.Co_Insurance_Company__c,
        Name:      r.Co_Insurance_Company__r.Name,
        Type:  r.Co_Insurance_Company__r.Type,
        AccSegment:     r.Co_Insurance_Company__r.Account_Segment__c,
        recordUrl: `/${r.Co_Insurance_Company__c}`
      }));

      // Track original IDs for Save button logic
      this.originalCoInsurerIds = new Set(this.coInsurers.map(ci => ci.id));
    } else if (error) {
      console.error('Error loading Co-Insurers:', error);
    }
  }

  /***************************************************************************
   * Computed property for Save button enablement
   ***************************************************************************/
  /*
  get isSaveDisabled() {
    const currentIds = this.coInsurers.map(ci => ci.id);
    const newOnes    = currentIds.filter(id => !this.originalCoInsurerIds.has(id));
    return newOnes.length === 0;
  } */
  
  get isSaveDisabled() {
    const currentIds = this.coInsurers.map(ci => ci.id);
    const newOnes = currentIds.filter(id => !this.originalCoInsurerIds.has(id));
    const isStageReadOnly = this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel';

    return newOnes.length === 0 || isStageReadOnly;
  }

  get isReadOnly() {
      return this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel';
  }

  /***************************************************************************
   * Lookup: Type-to-search
   ***************************************************************************/
  handleSearchKeyChange(event) {
    this.searchKey = event.target.value;
    if (this.searchKey.length < 2) {
      this.searchResults = [];
      return;
    }
    searchCoInsurerAccounts({ searchKey: this.searchKey })
      .then(results => {
        this.searchResults = results;
      })
      .catch(error => {
        console.error('Error searching Accounts:', error);
      });
  }

  /***************************************************************************
   * Lookup: Account selection
   ***************************************************************************/
  handleSelectAccount(event) {
    const { id, name, type, accsegment } = event.currentTarget.dataset;

    // Prevent duplicates
    if (this.coInsurers.some(ci => ci.id === id)) {
      this.clearLookup();
      return;
    }

    // Add new row (including recordUrl for link)
    this.coInsurers = [
      ...this.coInsurers,
      {
        id,
        Name: name,
        Type: type,
        AccSegment: accsegment,
        recordUrl: `/${id}`
      }
    ];
    this.clearLookup();
  }

  clearLookup() {
    this.searchKey     = '';
    this.searchResults = [];
  }

  /***************************************************************************
   * Row actions: open delete confirmation modal
   ***************************************************************************/
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row        = event.detail.row;

    if (actionName === 'delete') {
      this.selectedRowForDeletion = row;
      this.showDeleteModal        = true;
    }
  }

  /***************************************************************************
   * Modal: Confirm deletion
   ***************************************************************************/
  confirmDelete() {
    deleteCoInsurerData({
      opportunityId: this.recordId,
      accountId:     this.selectedRowForDeletion.id
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title:   'Deleted',
            message: 'Co-Insurer removed successfully.',
            variant: 'success'
          })
        );

        // Close modal & refresh data
        this.showDeleteModal          = false;
        this.selectedRowForDeletion   = null;
        return refreshApex(this.wiredCoInsurersResult);
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title:   'Error deleting Co-Insurer',
            message: error.body?.message || error,
            variant: 'error'
          })
        );
        this.showDeleteModal        = false;
        this.selectedRowForDeletion = null;
      });
  }

  /***************************************************************************
   * Modal: Cancel deletion
   ***************************************************************************/
  cancelDelete() {
    this.showDeleteModal        = false;
    this.selectedRowForDeletion = null;
  }

  /***************************************************************************
   * Save new Co-Insurer rows
   ***************************************************************************/
  handleSave() {
    // Only send IDs that weren't part of the original load
    const allIds = this.coInsurers.map(ci => ci.id);
    const newIds = allIds.filter(id => !this.originalCoInsurerIds.has(id));
    if (newIds.length === 0) {
      return;
    }

    saveCoInsurerData({
      opportunityId: this.recordId,
      accountIds:    newIds
    })
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title:   'Success',
            message: 'Co-Insurers saved successfully.',
            variant: 'success'
          })
        );
        return refreshApex(this.wiredCoInsurersResult);
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title:   'Error saving Co-Insurers',
            message: error.body?.message || error,
            variant: 'error'
          })
        );
      });
  }

  /***************************************************************************
   * Cancel edits: revert to original rows
   ***************************************************************************/
  handleCancel() {
    this.coInsurers = this.coInsurers.filter(ci =>
      this.originalCoInsurerIds.has(ci.id)
    );
  }
}