import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference }            from 'lightning/navigation';
import { ShowToastEvent }                 from 'lightning/platformShowToastEvent';
import { refreshApex }                    from '@salesforce/apex';

import getOpportunityFields               from '@salesforce/apex/OpportunityController.getOpportunity';
import getTransactionData                 from '@salesforce/apex/OpportunityController.getQQTransactionData';
import searchAccounts                     from '@salesforce/apex/OpportunityController.searchQQAccounts';
import saveTransactionData                from '@salesforce/apex/OpportunityController.saveTheInsuredTransactionData';
import deleteTransactionData              from '@salesforce/apex/OpportunityController.deleteTransactionData';

export default class TheInsuredLWC extends LightningElement {
  @api recordId;

  @track fieldList       = [];
  @track searchKey       = '';
  @track searchResults   = [];
  @track members         = [];
  @track showConfirmModal = false;
  @track stage = null;

  // Holds data for the row the user wants to delete
  rowPendingDelete = null;

  wiredMembersResult;
  originalMemberIds = new Set();
  /*
  columns = [
    { label: 'Name', fieldName: 'name',     type: 'text'  },
    { label: 'QQ Address',     fieldName: 'address', type: 'text'  },
    { label: 'Contract Number', fieldName: 'contract',    type: 'text' },
    { label: 'Loan Acc Number', fieldName: 'loan',    type: 'text' },
    {
      type: 'button-icon',
      fixedWidth: 40,
      typeAttributes: {
        iconName: 'utility:close',
        name: 'remove',
        alternativeText: 'Remove'
      }
    }
  ]; */
  columns = [
    { 
      label: 'Name', 
      fieldName: 'recordUrl', 
      type: 'url', 
      typeAttributes: {
        label: { fieldName: 'name' },
        target: '_blank'
      }
    },
    { label: 'QQ Address', fieldName: 'address', type: 'text' },
    { label: 'Contract Number', fieldName: 'contract', type: 'text' },
    { label: 'Loan Acc Number', fieldName: 'loan', type: 'text' },
    {
      type: 'button-icon',
      fixedWidth: 40,
      typeAttributes: {
        iconName: 'utility:close',
        name: 'remove',
        alternativeText: 'Remove'
      }
    }
  ];

  /*
  get isSaveDisabled() {
    const newOnes = this.members.filter(
      m => !this.originalMemberIds.has(m.accountId)
    );
    return newOnes.length === 0;
  }

  get isReadOnly() {
      return this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel';
  }
  */

  get isSaveDisabled() {
    const noNewMembers = this.members.filter(
        m => !this.originalMemberIds.has(m.accountId)
    ).length === 0;

    const isStageReadOnly = this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel';

    return noNewMembers || isStageReadOnly;
  }

  get isReadOnly() {
    return this.stage === 'Closed Won' || this.stage === 'Closed Lost' || this.stage === 'Cancel';
  }

  @wire(CurrentPageReference)
  setCurrentPage(pageRef) {
    if (pageRef?.state?.recordId) {
      this.recordId = pageRef.state.recordId;
      this.loadOpportunity();
    }
  }

  connectedCallback() {
    this.loadOpportunity();
    console.log('theInsured loaded. Last updated 07/11/2025 16.35');
  }

  loadOpportunity() {
    getOpportunityFields({ opportunityId: this.recordId })
      .then(data => {
        this.stage = data.StageName;
        this.fieldList = [
          { label: 'Insured Name',    value: data.The_Insured_Name__r?.Name },
          { label: 'Insured Status',  value: data.The_Insured_Status__c     },
          { label: 'Insured Address', value: data.The_Insured_Address__c    }
        ];
      })
      .catch(error => this.showToast('Error loading opportunity', error));
  }

  @wire(getTransactionData, { opportunityId: '$recordId' })
  wiredMembers(result) {
    this.wiredMembersResult = result;
    if (result.data) {
      this.members = result.data.map(r => ({
        recordId:  r.Id,
        accountId: r.QQ_Name__c,
        name:      r.Name,           // This is Transaction_Data__c.Name
        address:   r.QQ_Address__c,  // This is Transaction_Data__c.QQ_Address__c
        contract:  r.Contract_Number__c,
        loan:      r.Loan_Acc_Number__c,
        recordUrl: '/lightning/r/Transaction_Data__c/' + r.Id + '/view'
      }));
      this.originalMemberIds = new Set(
        this.members.map(m => m.accountId)
      );
    } else if (result.error) {
      this.showToast('Error loading members', result.error);
    }
  }

  handleSearchKeyChange(evt) {
    this.searchKey = evt.target.value;
    if (this.searchKey.length < 2) {
      this.searchResults = [];
      return;
    }
    searchAccounts({ searchKey: this.searchKey })
      .then(results => (this.searchResults = results))
      .catch(error => console.error(error));
      console.log("search result=", JSON.stringify(this.searchResults, null, 2));
  }
  /*
  handleSelectAccount(evt) {
    const { id, name, address, contract, loan } = evt.currentTarget.dataset;
    if (this.members.some(m => m.accountId === id)) {
      this.clearLookup();
      return;
    }
    this.members = [
      ...this.members,
      { recordId: null, accountId: id, name, address, contract, loan }
    ];
    this.clearLookup();
  }*/ 
  handleSelectAccount(evt) {
    const { id, name, address } = evt.currentTarget.dataset;
    console.log('currentTarget=', JSON.stringify(evt.currentTarget.dataset, null, 2));
    
    // Check if account is already in members
    if (this.members.some(m => m.accountId === id)) {
        this.clearLookup();
        return;
    }
    
    // Add account data with URL to Account record page
    this.members = [
        ...this.members,
        { 
            recordId: null, 
            accountId: id, 
            name: name,        // Account Name
            address: address,  // Account Address
            contract: '',      // Blank for new records
            loan: '',          // Blank for new records
            recordUrl: '/lightning/r/Account/' + id + '/view' // Account record URL
        }
    ];
    console.log('member=', JSON.stringify(this.members, null, 2));
    this.clearLookup();
  }

  clearLookup() {
    this.searchKey     = '';
    this.searchResults = [];
  }

  handleRowAction(evt) {
    const row = evt.detail.row;
    if (row.recordId) {
      // show modal for persisted row
      this.rowPendingDelete = row;
      this.showConfirmModal = true;
    } else {
      // remove unsaved row immediately
      this.members = this.members.filter(m => m.accountId !== row.accountId);
    }
  }

  // User clicked “Delete” in modal
  confirmDelete() {
    deleteTransactionData({ recordId: this.rowPendingDelete.recordId })
      .then(() => {
        this.showToast('Deleted', 'Co-insurer removed.', 'success');
        return refreshApex(this.wiredMembersResult);
      })
      .catch(error => this.showToast('Error deleting member', error))
      .finally(() => this.closeModal());
  }

  // User clicked “Cancel” in modal
  cancelDelete() {
    this.closeModal();
  }

  closeModal() {
    this.showConfirmModal = false;
    this.rowPendingDelete = null;
  }
  /*
  handleSave() {
    const newIds = this.members
      .map(m => m.accountId)
      .filter(id => !this.originalMemberIds.has(id));
    if (newIds.length === 0) {
      return;
    }
    saveTransactionData({
      opportunityId: this.recordId,
      accountIds:    newIds
    })
      .then(() => {
        this.showToast('Success', 'New members saved.', 'success');
        return refreshApex(this.wiredMembersResult);
      })
      .catch(error => this.showToast('Error saving members', error));
  } */ 
  handleSave() {
    // Get new accounts (not in originalMemberIds)
    const newAccounts = this.members.filter(m => !this.originalMemberIds.has(m.accountId));
    
    if (newAccounts.length === 0) {
      return;
    }
    
    // Prepare data for Apex - include names and addresses
    const accountData = newAccounts.map(acc => ({
      accountId: acc.accountId,
      accountName: acc.name,    // Account Name
      accountAddress: acc.address // Account Address
    }));
    
    saveTransactionData({
      opportunityId: this.recordId,
      accountData: accountData  // Pass the array with account details
    })
      .then(() => {
        this.showToast('Success', 'New members saved.', 'success');
        return refreshApex(this.wiredMembersResult);
      })
      .catch(error => this.showToast('Error saving members', error));
  }

  handleCancel() {
    this.members = this.members.filter(m =>
      this.originalMemberIds.has(m.accountId)
    );
  }

  showToast(title, error, variant = 'error') {
    const message = error?.body?.message || error?.message || error;
    this.dispatchEvent(
      new ShowToastEvent({ title, message, variant })
    );
  }
}