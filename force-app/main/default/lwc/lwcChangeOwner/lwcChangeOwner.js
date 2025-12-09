import { LightningElement,track } from 'lwc';
import getPermission from '@salesforce/apex/ClsChangeOwner.getPermission';
import getUser from '@salesforce/apex/ClsChangeOwner.getUser';
import getAccounts from '@salesforce/apex/ClsChangeOwner.getAccounts';
import getOpportunity from '@salesforce/apex/ClsChangeOwner.getOpportunity';
import getInsurancePolicy from '@salesforce/apex/ClsChangeOwner.getInsurancePolicy';
import getLead from '@salesforce/apex/ClsChangeOwner.getLead';
import getClaim from '@salesforce/apex/ClsChangeOwner.getClaim';
import getCase from '@salesforce/apex/ClsChangeOwner.getCase';
import saveData from '@salesforce/apex/ClsChangeOwner.saveData';
import LightningAlert from 'lightning/alert';
import { getFocusedTabInfo,setTabLabel,closeTab,setTabIcon,refreshTab} from 'lightning/platformWorkspaceApi';

export default class LwcChangeOwner extends LightningElement {
    currentStep = '1';
    maxStep = 8;

    @track showData;
    @track tabId;
    @track user;
    @track isLoading = false;
    @track oldUserId;
    @track oldBranch = null;
    @track newUserId;
    @track showPrev;
    @track show1 = true;
    @track show2;
    @track show3;
    @track show4;
    @track show5;
    @track show6;
    @track show7;
    @track show8;
    @track filter2 = {};

    @track accounts = [];
    @track accountcolumn = [];

    @track opportunity = [];
    @track opportunitycolumn = [];

    @track insurancepolicy = [];
    @track insurancepolicycolumn = [];

    @track lead = [];
    @track leadcolumn = [];

    @track claim = [];
    @track claimcolumn = [];

    @track cases = [];
    @track casescolumn = [];

    connectedCallback() {
        getFocusedTabInfo().then(tabInfo => {
            this.tabId = tabInfo.tabId;
            setTabLabel(this.tabId, 'Change Owner');
            setTabIcon(this.tabId, 'standard:app', { iconAlt: 'Change Owner' });
        }); 
        this.onLoadGetPermission();
    }

    renderedCallback() {
    }

    disconnectedCallback() {

    }

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['Additional__c'],
    };

    matchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'startsWith' },
        additionalFields: [{ fieldPath: 'Email' }],
    };

    filter = {
        criteria : [
            {
                fieldPath : 'IsActive',
                operator : 'eq',
                value : true
            },
            {
                fieldPath : 'Branch__c',
                operator : 'ne',
                value : null
            },
            {
                fieldPath : 'UserLicense__c',
                operator : 'eq',
                value : 'Salesforce'
            }
        ],
        filterLogic: '1 AND 2 AND 3', 
        orderBy: [{fieldPath: 'Name', direction: 'asc'}]
    };

    onLoadGetPermission(){
        this.isLoading = true;
        getPermission({})
        .then(result => {
            this.isLoading = false;
            this.showData = result;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error:'+ error.message);
        }); 
    }

    async handleUser(event){
        this.isLoading = true;
        this.oldUserId = event.detail.recordId;
        await getUser({
            recordId: this.oldUserId
        })
        .then(result => {
            this.isLoading = false;
            this.oldBranch = result.Branch__c;
            this.user = result;
            console.log('result:'+JSON.stringify(result));
            this.filter2 = {
                criteria : [
                    {
                        fieldPath : 'IsActive',
                        operator : 'eq',
                        value : true
                    },
                    {
                        fieldPath : 'Branch__c',
                        operator : 'eq',
                        value : this.oldBranch 
                    },
                    {
                        fieldPath : 'Id',
                        operator : 'ne',
                        value : this.oldUserId 
                    },
                    {
                        fieldPath : 'UserLicense__c',
                        operator : 'eq',
                        value : 'Salesforce'
                    }
                ],
                filterLogic: '1 AND 2 AND 3 AND 4', 
                orderBy: [{fieldPath: 'Name', direction: 'asc'}]
            };
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error:'+ error.message);
        });  
    }

    handleNewUser(event){
        this.newUserId = event.detail.recordId;
    }

    updateDataValues(updateItem,field,type) {
        let copyData = JSON.parse(JSON.stringify(field));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        field = [...copyData];
        if(type == 'account') this.accounts = field;
        else if(type == 'opportunity') this.opportunity = field;
        else if(type == 'insurancepolicy') this.insurancepolicy = field;
        else if(type == 'lead') this.lead = field;
        else if(type == 'claim') this.claim = field;
        else if(type == 'case') this.cases = field;
        console.log('field:'+ JSON.stringify(field));
    }

    accountLookupChanged(event) {
        //console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let ownerIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, OwnerId: ownerIdVal  };
        //console.log(updatedItem);
        this.updateDataValues(updatedItem,this.accounts,"account");
    }

    opportunityLookupChanged(event) {
        //console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let ownerIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, OwnerId: ownerIdVal  };
        //console.log(updatedItem);
        this.updateDataValues(updatedItem,this.opportunity,"opportunity");
    }

    insurancepolicyLookupChanged(event) {
        //console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let ownerIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, OwnerId: ownerIdVal  };
        //console.log(updatedItem);
        this.updateDataValues(updatedItem,this.insurancepolicy,"insurancepolicy");
    }

    leadLookupChanged(event) {
        //console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let ownerIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, OwnerId: ownerIdVal  };
        //console.log(updatedItem);
        this.updateDataValues(updatedItem,this.lead,"lead");
    }

    claimLookupChanged(event) {
        //console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let ownerIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, OwnerId: ownerIdVal  };
        //console.log(updatedItem);
        this.updateDataValues(updatedItem,this.claim,"claim");
    }

    caseLookupChanged(event) {
        //console.log(event.detail.data);
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let ownerIdVal = dataRecieved.value != undefined ? dataRecieved.value : null;
        let updatedItem = { Id: dataRecieved.context, OwnerId: ownerIdVal  };
        //console.log(updatedItem);
        this.updateDataValues(updatedItem,this.cases,"case");
    }

    handleNext() {
        let iNum = '1';
        const currentStepNumber = parseInt(this.currentStep, 10);      
        if (currentStepNumber < this.maxStep) {
            iNum = (currentStepNumber + 1).toString();
            //this.currentStep = iNum;
        }
        this.getShow(iNum);
    }

    handlePrev() {
        let iNum = '1';
        const currentStepNumber = parseInt(this.currentStep, 10);
        if (currentStepNumber > 1) {
            iNum = (currentStepNumber - 1).toString();
            //this.currentStep = (currentStepNumber - 1).toString();
        }
        this.getShow(iNum);
    }

    handleSave(event){
        this.isLoading = true;
        let data = {};
        data.olduser = this.oldUserId;
        data.newuser = this.newUserId;
        data.account = this.accounts;
        data.opportunity = this.opportunity;
        data.insurancepolicy = this.insurancepolicy;
        data.lead = this.lead;
        data.claim = this.claim;
        data.case = this.cases;

        console.log('this.accounts:'+JSON.stringify(this.accounts));
        console.log('this.opportunity:'+JSON.stringify(this.opportunity));
        console.log('this.insurancepolicy:'+JSON.stringify(this.insurancepolicy));
        console.log('this.lead:'+JSON.stringify(this.lead));
        console.log('this.claim:'+JSON.stringify(this.claim));
        console.log('this.cases:'+JSON.stringify(this.cases));
        console.log('data:'+ JSON.stringify(data));

        saveData({ data: JSON.stringify(data)})
            .then(result => {
                this.isLoading = false;
                console.log('result:'+result);
                if(result == 'Sukses'){
                    this.successMessage('Change Owner has been saved!');
                    this.refreshTab();
                }else{
                    this.errorMessage('Error: '+result);
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error:'+error.body.message);
                this.errorMessage('Error: '+error.body.message);
            });
    }

    getShow(step){
        this.show1 = false;
        this.show2 = false;
        this.show3 = false;
        this.show4 = false;
        this.show5 = false;
        this.show6 = false;
        this.show7 = false;
        this.show8 = false;
        if(step === '1'){
            this.showPrev = false;
            this.show1 = true;
            this.accounts = [];
            this.opportunity = [];
            this.insurancepolicy = [];
            this.lead = [];
            this.claim = [];
            this.cases = [];
        }else if(step === '2'){
            if(this.oldUserId == undefined || this.oldUserId == null || this.oldUserId == ''){
                this.show1 = true;
                step = '1';
                this.errorMessage('Please select the old user!');
            }else if(this.newUserId == undefined || this.newUserId == null || this.newUserId == ''){
                this.show1 = true;
                step = '1';
                this.errorMessage('Please select the new user!');
            }else{
                this.show2 = true;
                if(this.lead.length === 0) this.getDataLead();
                this.showPrev = true;
            }
        }else if(step === '3'){
            let isFlag = false;
            for(let i=0;i<this.lead.length;i++){
                let ownerid = this.lead[i].OwnerId;
                if(ownerid == undefined || ownerid == null || ownerid == ''){
                    isFlag = true;
                    break;
                }
            }
            if(isFlag == true){
                this.show2 = true;
                step = '2';
                this.errorMessage('Please select the owner!');
            }else{
                this.show3 = true;
                if(this.accounts.length === 0) this.getDataAccount();
            }
            
        }else if(step === '4'){
            let isFlag = false;
            for(let i=0;i<this.accounts.length;i++){
                let ownerid = this.accounts[i].OwnerId;
                if(ownerid == undefined || ownerid == null || ownerid == ''){
                    isFlag = true;
                    break;
                }
            }
            if(isFlag == true){
                this.show3 = true;
                step = '3';
                this.errorMessage('Please select the owner!');
            }else{
                this.show4 = true;
                if(this.opportunity.length === 0) this.getDataOpportunity();
            }
            
        }else if(step === '5'){
            let isFlag = false;
            for(let i=0;i<this.opportunity.length;i++){
                let ownerid = this.opportunity[i].OwnerId;
                if(ownerid == undefined || ownerid == null || ownerid == ''){
                    isFlag = true;
                    break;
                }
            }
            if(isFlag == true){
                this.show4 = true;
                step = '4';
                this.errorMessage('Please select the owner!');
            }else{
                this.show5 = true;
                if(this.insurancepolicy.length === 0) this.getDataInsurancePolicy();
            }
        }else if(step === '6'){
            let isFlag = false;
            for(let i=0;i<this.insurancepolicy.length;i++){
                let ownerid = this.insurancepolicy[i].OwnerId;
                if(ownerid == undefined || ownerid == null || ownerid == ''){
                    isFlag = true;
                    break;
                }
            }
            if(isFlag == true){
                this.show5 = true;
                step = '5';
                this.errorMessage('Please select the owner!');
            }else{
                this.show6 = true;
                if(this.cases.length === 0) this.getDataCase();
            }
        }else if(step === '7'){
            let isFlag = false;
            for(let i=0;i<this.cases.length;i++){
                let ownerid = this.cases[i].OwnerId;
                if(ownerid == undefined || ownerid == null || ownerid == ''){
                    isFlag = true;
                    break;
                }
            }
            if(isFlag == true){
                this.show6 = true;
                step = '6';
                this.errorMessage('Please select the owner!');
            }else{
                this.show7 = true;
                if(this.claim.length === 0) this.getDataClaim();
            }
        }else if(step === '8'){
            let isFlag = false;
            for(let i=0;i<this.claim.length;i++){
                let ownerid = this.claim[i].OwnerId;
                if(ownerid == undefined || ownerid == null || ownerid == ''){
                    isFlag = true;
                    break;
                }
            }
            if(isFlag == true){
                this.show7 = true;
                step = '7';
                this.errorMessage('Please select the owner!');
            }else{
                this.show8 = true;
            }
        }
        this.currentStep = step;
    }

    getDataAccount(){
        getAccounts({
            ownerId: this.oldUserId
        })
        .then(result => {
            let nameURL,OwnerId,parentName;
            this.accounts = result.map(row =>{
                nameURL = `/${row.Id}`;
                OwnerId = this.newUserId;
                if(row.ParentId != undefined) parentName = `/${row.ParentId}`;
                else parentName = '';
                return {...row , nameURL, OwnerId,parentName} 
            })
            //console.log('this.accounts:'+JSON.stringify(this.accounts));
            this.accountcolumn = [
                {   
                    label: 'Name', 
                    fieldName: 'nameURL',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Owner', 
                    fieldName: 'OwnerId', 
                    type: 'lookupColumn', 
                    editable: false, 
                    typeAttributes: {
                        object: 'Account',
                        fieldName: 'OwnerId',
                        value: { fieldName: 'OwnerId' },
                        context: { fieldName: 'Id' },
                        name: 'User',
                        fields: ['User.Name'],
                        target: '_blank',
                        user: this.user,
                        newuserid: this.newUserId
                    },
                },
                {   
                    label: 'Parent Account', 
                    fieldName: 'parentName',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'ParentName__c' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Type', fieldName: 'Type' },
                {   label: 'Branch', fieldName: 'Branch__c' },
                
            ];
        })
        .catch(error => {
            //this.isLoading = false;
            console.log('error:'+ error.message);
        });
    }

    getDataOpportunity(){
        getOpportunity({
            ownerId: this.oldUserId
        })
        .then(result => {
            let nameURL,OwnerId,accountname;
            this.opportunity = result.map(row =>{
                nameURL = `/${row.Id}`;
                OwnerId = this.newUserId;
                if(row.AccountId != undefined) accountname = `/${row.AccountId}`;
                else accountname = '';
                return {...row , nameURL, OwnerId,accountname} 
            })
            //console.log('this.opportunity:'+JSON.stringify(this.opportunity));
            this.opportunitycolumn = [
                {   
                    label: 'Name', 
                    fieldName: 'nameURL',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Owner', 
                    fieldName: 'OwnerId', 
                    type: 'lookupColumn', 
                    editable: false, 
                    typeAttributes: {
                        object: 'Opportunity',
                        fieldName: 'OwnerId',
                        value: { fieldName: 'OwnerId' },
                        context: { fieldName: 'Id' },
                        name: 'User',
                        fields: ['User.Name'],
                        target: '_blank',
                        user: this.user,
                        newuserid: this.newUserId
                    },
                },
                {   
                    label: 'Account Name', 
                    fieldName: 'accountname',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'AccountName__c' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Stage', fieldName: 'StageName' },
                {   label: 'Type', fieldName: 'Opportunity_Type__c' },
                {   label: 'Close Date', fieldName: 'CloseDate', type: 'date'},
                
            ];
        })
        .catch(error => {
            //this.isLoading = false;
            console.log('error:'+ error.message);
        });
    }

    getDataInsurancePolicy(){
        getInsurancePolicy({
            ownerId: this.oldUserId
        })
        .then(result => {
            let nameURL,OwnerId,nameinsured;
            this.insurancepolicy = result.map(row =>{
                nameURL = `/${row.Id}`;
                OwnerId = this.newUserId;
                if(row.NameInsuredId != undefined) nameinsured = `/${row.NameInsuredId}`;
                else nameinsured = '';
                return {...row , nameURL, OwnerId,nameinsured} 
            })
            //console.log('this.insurancepolicy:'+JSON.stringify(this.insurancepolicy));
            this.insurancepolicycolumn = [
                {   
                    label: 'Policy Number', 
                    fieldName: 'nameURL',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Owner', 
                    fieldName: 'OwnerId', 
                    type: 'lookupColumn', 
                    editable: false, 
                    typeAttributes: {
                        object: 'InsurancePolicy',
                        fieldName: 'OwnerId',
                        value: { fieldName: 'OwnerId' },
                        context: { fieldName: 'Id' },
                        name: 'User',
                        fields: ['User.Name'],
                        target: '_blank',
                        user: this.user,
                        newuserid: this.newUserId
                    },
                },
                {   label: 'Gross Written Premium', fieldName: 'GrossWrittenPremium' },
                {   label: 'Policy Type', fieldName: 'PolicyType' },
                {   
                    label: 'Name Insured', 
                    fieldName: 'nameinsured',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'NameInsured__c' }, 
                    target: '_blank'},
                    sortable: true
                },
            ];
        })
        .catch(error => {
            //this.isLoading = false;
            console.log('error:'+ error.message);
        });
    }

    getDataLead(){
        getLead({
            ownerId: this.oldUserId
        })
        .then(result => {
            let nameURL,OwnerId;
            this.lead = result.map(row =>{
                nameURL = `/${row.Id}`;
                OwnerId = this.newUserId;
                return {...row , nameURL, OwnerId} 
            })
            //console.log('this.lead:'+JSON.stringify(this.lead));
            this.leadcolumn = [
                {   
                    label: 'Name', 
                    fieldName: 'nameURL',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Owner', 
                    fieldName: 'OwnerId', 
                    type: 'lookupColumn', 
                    editable: false, 
                    typeAttributes: {
                        object: 'Lead',
                        fieldName: 'OwnerId',
                        value: { fieldName: 'OwnerId' },
                        context: { fieldName: 'Id' },
                        name: 'User',
                        fields: ['User.Name'],
                        target: '_blank',
                        user: this.user,
                        newuserid: this.newUserId
                    },
                },
                {   label: 'Company', fieldName: 'Company' },
                {   label: 'Status', fieldName: 'Status' },
            ];
        })
        .catch(error => {
            //this.isLoading = false;
            console.log('error:'+ error.message);
        });
    }

    getDataClaim(){
        getClaim({
            ownerId: this.oldUserId
        })
        .then(result => {
            let nameURL,OwnerId,accountname;
            this.claim = result.map(row =>{
                nameURL = `/${row.Id}`;
                OwnerId = this.newUserId;
                if(row.AccountId != undefined) accountname = `/${row.AccountId}`;
                else accountname = '';
                return {...row , nameURL, OwnerId,accountname} 
            })
            //console.log('this.claim:'+JSON.stringify(this.claim));
            this.claimcolumn = [
                {   
                    label: 'Claim Number', 
                    fieldName: 'nameURL',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'Name' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Owner', 
                    fieldName: 'OwnerId', 
                    type: 'lookupColumn', 
                    editable: false, 
                    typeAttributes: {
                        object: 'Claim',
                        fieldName: 'OwnerId',
                        value: { fieldName: 'OwnerId' },
                        context: { fieldName: 'Id' },
                        name: 'User',
                        fields: ['User.Name'],
                        target: '_blank',
                        user: this.user,
                        newuserid: this.newUserId
                    },
                },
                {   
                    label: 'Account', 
                    fieldName: 'accountname',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'AccountName__c' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Claim Reason', fieldName: 'ClaimReason' },
                {   label: 'Status', fieldName: 'Status' },
                {   label: 'Approved Amount', fieldName: 'ApprovedAmount' },
            ];
        })
        .catch(error => {
            //this.isLoading = false;
            console.log('error:'+ error.message);
        });
    }

    getDataCase(){
        getCase({
            ownerId: this.oldUserId
        })
        .then(result => {
            let nameURL,OwnerId;
            this.cases = result.map(row =>{
                nameURL = `/${row.Id}`;
                OwnerId = this.newUserId;
                return {...row , nameURL, OwnerId} 
            })
            //console.log('this.cases:'+JSON.stringify(this.cases));
            this.casescolumn = [
                {   
                    label: 'Name', 
                    fieldName: 'nameURL',
                    type: 'url',
                    typeAttributes: {label: { fieldName: 'CaseNumber' }, 
                    target: '_blank'},
                    sortable: true
                },
                {   label: 'Owner', 
                    fieldName: 'OwnerId', 
                    type: 'lookupColumn', 
                    editable: false, 
                    typeAttributes: {
                        object: 'Case',
                        fieldName: 'OwnerId',
                        value: { fieldName: 'OwnerId' },
                        context: { fieldName: 'Id' },
                        name: 'User',
                        fields: ['User.Name'],
                        target: '_blank',
                        user: this.user,
                        newuserid: this.newUserId
                    },
                },
                {   label: 'Subject', fieldName: 'Subject' },
                {   label: 'Status', fieldName: 'Status' },
                {   label: 'Date/Time Opened', fieldName: 'CreatedDate', type: 'date'},
            ];
        })
        .catch(error => {
            //this.isLoading = false;
            console.log('error:'+ error.message);
        });
    }

    errorMessage(msg){
        LightningAlert.open({
            message: msg,
            theme: 'error',
            label: 'Error!', 
            });
    }

    successMessage(msg){
        LightningAlert.open({
            message: msg,
            theme: 'success',
            variant: 'headerless'
            });
    }

    async refreshTab(){
        await refreshTab(this.tabId, {
            includeAllSubtabs: true
        });
    }
}