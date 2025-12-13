/*
Last Modified by Marco Lie, 13-10-2025
Change String value {Annual, Short, Long-Term} into {1, 2, 3}. And {Percentage, Pro-Rata Basis} into {1, 2}. 
*/

import { LightningElement,api,track,wire } from 'lwc';
import getOpportunity from '@salesforce/apex/ClsNewRequest.getOpportunity';
import getMasterData from '@salesforce/apex/ClsNewRequest.getMasterData';
import getMasterDataSection from '@salesforce/apex/ClsNewRequest.getMasterDataSection';
import getAccountDetail from '@salesforce/apex/ClsNewRequest.getAccountDetail';
import searchAccounts from '@salesforce/apex/ClsNewRequest.searchQQAccounts';
import deleteFile from '@salesforce/apex/ClsNewRequest.deleteFile';
import deleteFiles from '@salesforce/apex/ClsNewRequest.deleteFiles';
import saveData from '@salesforce/apex/ClsNewRequest.saveData';
import saveDataMOU from '@salesforce/apex/ClsNewRequest.saveDataMOU';
import getPicklistSTD from '@salesforce/apex/ClsNewRequest.getPicklist';
import getProductType from '@salesforce/apex/ClsNewRequest.getProductType';
import getPolicyWording from '@salesforce/apex/ClsNewRequest.getPolicyWording';
import getAssetSection from '@salesforce/apex/ClsNewRequest.getAssetSection';
import getAssetCategory from '@salesforce/apex/ClsNewRequest.getAssetCategory';
import getObject from '@salesforce/apex/ClsNewRequest.getObject';
import getRate from '@salesforce/apex/ClsNewRequest.getRate';
import getValidateDouble from '@salesforce/apex/ClsNewRequest.getValidateDouble';
import getContract from '@salesforce/apex/ClsNewRequest.getContract';
import getCurrency from '@salesforce/apex/ClsNewRequest.getCurrency';
import { getFocusedTabInfo,setTabLabel,closeTab,setTabIcon,refreshTab} from 'lightning/platformWorkspaceApi';
import { NavigationMixin,CurrentPageReference } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getWording from '@salesforce/apex/ClsNewRequest.getWording';
import LightningAlert from 'lightning/alert';
import { CloseActionScreenEvent } from 'lightning/actions';
import myModal from 'c/lwcRenewal';
import LightningConfirm from 'lightning/confirm';
import modalRealisasi from 'c/lwcNewRequestAsset';
import modalCoverage from 'c/lwcNewRequestCoverage';


export default class LwcNewRequest extends NavigationMixin(LightningElement) {
    activeSections = [];//['A'];
    activeSectionsMessage = '';

    // public inputs
    periodType     = null;
    years          = null;
    shortBasis     = null;
    percentage     = null;
    startDate      = null;
    endDate        = null;
    calculatedRate = null;
    @track schemaType = null;

    // reactive values
    @track dayCount        = null;
    @track yearsMonthsInfo = '';
    @track adjustmentRows  = [];

    // private placeholders for suffix logic
    _computedYears  = 0;
    _computedMonths = 0;

    // ------ Template getters ------
    get isLongTerm()        { return this.periodType === '3'; }
    get isAnnual()          { return this.periodType === '1'; }
    get isShort()           { return this.periodType === '2'; }
    get isPercentageBasis() { return this.shortBasis === '1'; }
    get isProRataBasis()    { return this.shortBasis === '2'; }
    get showInfo() { return !this.isAnnual; }

    // public inputs 2
    periodType2     = '';
    years2          = null;
    shortBasis2     = '';
    percentage2     = null;
    startDate2      = '';
    endDate2        = '';
    calculatedRate2 = null;
    @track schemaType2 = null;

    // reactive values 2
    @track dayCount2        = null;
    @track yearsMonthsInfo2 = '';
    @track adjustmentRows2  = [];

    // private placeholders for suffix logic 2
    _computedYears2  = 0;
    _computedMonths2 = 0;

    // ------ Template getters 2 ------
    get isLongTerm2()        { return this.periodType2 === '3'; }
    get isAnnual2()          { return this.periodType2 === '1'; }
    get isShort2()           { return this.periodType2 === '2'; }
    get isPercentageBasis2() { return this.shortBasis2 === '1'; }
    get isProRataBasis2()    { return this.shortBasis2 === '2'; }
    get showInfo2() { return !this.isAnnual2; }

    @api recordId;
    @api account;
    @track showrecord = true;
    @track isLoading = false;
    @track accountId;
    @track insuredId;
    @track accountAddress;
    @track showMultiple = false;
    @track showSingle = false;    
    @track showInsured = false;
    @track tabId;
    @track actionsave;
    @track opportunityType;
    @track opportunityTypeId;
    @track disabledAccount = false;
    @track showFull = false;
    @track showDouble = false;
    @track showStandard = true;
    
    //REQUESTOR
    @track requestorType;
    @track requestorTypeId;
    @track requestorSegment;
    @track requestorSegmentId;
    @track requestorSubSegment;
    @track requestorSubSegmentId;
    @track requestorBusinessSegmentation;
    @track requestorBusinessSegmentationId;
    @track requestorPipelineStatus;
    @track requestorPipelineStatusId;
    @track requestorChannel;
    @track requestorChannelId;
    @track showChannel;
    @track requestorAddress;

    //QQ MEMBER
    @track searchKey = '';
    @track searchResults = [];
    @track members = [];
    @track originalMemberIds = new Set();

    //RISK
    @track riskName;
    @track riskName2;
    @track showFormat1 = false;
    @track showFormat2 = false;
    @track datafield1 = [];
    @track datafield2 = [];
    @track cob1;
    @track cob2;
    @track mapInput = new Map();
    @track mapInput2 = new Map();
    @track productType;
    @track productType2;
    @track productTypeId;
    @track productTypeId2;
    @track productTypeName;
    @track productTypeName2;
    @track policyWording;
    @track policyWording2;
    @track policyWordingId;
    @track policyWordingId2;
    @track policyWordingName;
    @track policyWordingName2;
    @track contractType;
    @track contractType2;
    @track contractTypeId;
    @track contractTypeId2;
    @track description;
    @track description2;
    @track showIAR;
    @track fireType;
    @track fireTypeId;
    @track wording;
    @track wordingId;
    @track wordingName;
    @track showIAR2;
    @track fireType2;
    @track fireTypeId2;
    @track wording2;
    @track wordingId2;
    @track wordingName2;
    @track dataDescription1 = [];
    @track dataDescription2 = [];
    @track premiumCalculation;
    @track premiumCalculation2;
    @track premiumCalculationId;
    @track premiumCalculationId2;
    @track showPremium;
    @track showPremium2;

    //MOU
    @track showMOU;
    @track showFieldMOU;
    @track datafieldMOU1 = [];
    @track mapInputMOU1 = new Map();
    @track filterMOU1;
    @track mouId1;
    @track dataAssetMOU1 = [];
    @track dataCoverageMOU1 = [];

    //REALISASI
    @track showRealisasi1;
    @track showFieldRealisasi1;
    @track datafieldRealisasi1 = [];
    @track mapInputRealisasi1 = new Map();
    @track filterRealisasi1;
    @track realisasiId1;
    @track dataAssetRealisasi1 = [];
    @track dataCoverageRealisasi1 = [];

    //SUMMARY
    @track rate;
    @track rate2;
    @track currency;
    @track currencyId;
    @track currencyName;
    @track currency2;
    @track currencyId2;
    @track currencyName2;
    @track showIDR;
    @track showIDR2;
    @track sumInsured;
    @track sumInsuredIDR;
    @track premium;
    @track premiumIDR;
    @track numberOfRisk;
    @track closedDate;
    @track sumInsured2;
    @track sumInsuredIDR2;
    @track premium2;
    @track premiumIDR2;
    @track numberOfRisk2;
    @track closedDate2;
    @track dataSummary1 = [];
    @track dataSummary2 = [];
    @track showSummary = false;
    @track showSummary2 = false;
    @track mapSummary1 = new Map();
    @track mapSummary2 = new Map();
    @track dataFormat1;
    @track dataFormat2;
    @track assetSection;
    @track assetSectionId;
    @track assetCategory;
    @track assetCategoryId;
    @track assetSection2;
    @track assetSectionId2;
    @track assetCategory2;
    @track assetCategoryId2;

    //FILE
    @api myFileId;
    @track filequote1 = [];
    @track fileclosing1 = [];
    @track filesurvey1 = [];
    @track filequote2 = [];
    @track fileclosing2 = [];
    @track filesurvey2 = [];
    acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg'];

    columns = [
        { label: 'Account Name',fieldName: 'name',     type: 'text' },
        { label: 'Address',fieldName: 'address', type: 'text' },
        { label: 'Account Type',fieldName: 'type',    type: 'text' },
        {
            type: 'button-icon',
            fixedWidth: 40,
            typeAttributes: {
                iconName: 'utility:close',
                name:     'remove',
                alternativeText: 'Remove'
            }
        }
    ];

    actions = [
        { label: 'Show details', name: 'show_details' },
        { label: 'Delete', name: 'delete' }
    ];

    columnsAssetRealisasi1 = [
        {type: 'action', typeAttributes: { rowActions: this.actions} },
        {label:'Section',fieldName:'sectionName',type:'text'},
        {label:'Category',fieldName:'categoryName',type:'text'},
        {label:'Currency',fieldName:'currencyName',type:'text'},
        {label:'Sum Insured',fieldName:'sumInsured',type:'number'},
        {label:'Sum Insured IDR',fieldName:'sumInsuredIDR',type:'number'}
    ];

    columnsCoverageRealisasi1 = [
        {type: 'action', typeAttributes: { rowActions: this.actions} },
        {label:'Section',fieldName:'sectionName',type:'text'},
        {label:'Coverage',fieldName:'coverageName',type:'text'},
        {label:'Proposed Rate',fieldName:'proposedFixedAmount',type:'number'},
        {label:'Deductible PCT (%)',fieldName:'deductiblePCT',type:'number' },
        {label:'Deductible Flag',fieldName:'deductibleName',type:'text'},
        {label:'Minimum Curr',fieldName:'minimumCurId',type:'text'},
        {label:'Minimum Amount',fieldName:'minimumAmount',type:'number'},
        {label:'Banks Fee (%)',fieldName:'banksFee',type:'number'},
        {label:'Agent Comission (%)',fieldName:'agentComission',type:'number'},
        {label:'Broker Comission (%)',fieldName:'brokerComission',type:'number'},
        {label:'Commision (%)',fieldName:'generalRPremiumPCT',type:'number'},
        {label:'Overiding (%)',fieldName:'overdngComission',type:'number'},
        {label:'Max Person',fieldName:'maxPerson',type:'number'}
    ];

    columnsAssetMOU1 = [
        {type: 'action', typeAttributes: { rowActions: this.actions} },
        {label:'Section',fieldName:'sectionName',type:'text'},
        {label:'Category',fieldName:'categoryName',type:'text'},
        {label:'Currency',fieldName:'currencyName',type:'text'},
        {label:'Sum Insured',fieldName:'sumInsured',type:'number'},
        {label:'Sum Insured IDR',fieldName:'sumInsuredIDR',type:'number'}
    ];

    columnsCoverageMOU1 = [
        {type: 'action', typeAttributes: { rowActions: this.actions} },
        {label:'Section',fieldName:'sectionName',type:'text'},
        {label:'Coverage',fieldName:'coverageName',type:'text'},
        {label:'Proposed Rate',fieldName:'proposedFixedAmount',type:'number'},
        {label:'Deductible PCT (%)',fieldName:'deductiblePCT',type:'number' },
        {label:'Deductible Flag',fieldName:'deductibleName',type:'text'},
        {label:'Minimum Curr',fieldName:'minimumCurId',type:'text'},
        {label:'Minimum Amount',fieldName:'minimumAmount',type:'number'},
        {label:'Banks Fee (%)',fieldName:'banksFee',type:'number'},
        {label:'Agent Comission (%)',fieldName:'agentComission',type:'number'},
        {label:'Broker Comission (%)',fieldName:'brokerComission',type:'number'},
        {label:'Commision (%)',fieldName:'generalRPremiumPCT',type:'number'},
        {label:'Overiding (%)',fieldName:'overdngComission',type:'number'},
        {label:'Max Person',fieldName:'maxPerson',type:'number'}
    ];

    get options() {
        return [
            { label: 'Single', value: '1' },
            { label: 'Multiple', value: '2' },
        ];
    }

    get formats() {
        return [
            { label: 'Summary/General', value: 'Summary' },
            { label: 'Complete/Detail', value: 'Specific' },
        ];
    }

    get formats2() {
        return [
            { label: 'Summary/General', value: 'Summary2' },
            { label: 'Complete/Detail', value: 'Specific2' },
        ];
    }

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['Additional__c'],
    };

    matchingInfo = {
        primaryField: { fieldPath: 'Name', mode: 'contains' },
        additionalFields: [{ fieldPath: 'Phone' }],
    };

    displayInfoMOU = {
        primaryField: 'ContractNumber',
        additionalFields: ['Additional__c'],
    };

    matchingInfoMOU = {
        primaryField: { fieldPath: 'ContractNumber', mode: 'contains' },
        additionalFields: [{ fieldPath: 'Additional__c' }],
    };

    displayInfoRealisasi = {
        primaryField: 'Name',
        additionalFields: ['Additional__c'],
    };

    matchingInfoRealisasi = {
        primaryField: { fieldPath: 'Name', mode: 'contains' },
        additionalFields: [{ fieldPath: 'Additional__c' }],
    };

    get insuranceTypeOptions() {
        return [
        { label: 'Annual',       value: '1' },
        { label: 'Short-Period', value: '2' },
        { label: 'Long Term',    value: '3' }
        ];
    }

    get shortBasisOptions() {
        return [
        { label: 'Percentage',     value: '1'     },
        { label: 'Pro-Rata Basis', value: '2' }
        ];
    }

    schemaOptions = [
        { label: '--None--', value: null },
        { label: 'Sum Insured Adjustment', value: 'Sum Insured Adjustment' },
        { label: 'Discounted Premium', value: 'Discounted Premium' }
    ];

    get displayRows() {
        return this.adjustmentRows.filter(r => r.year !== 1);
    }

    get hasSchemaType() {
        return this.schemaType !== null && this.schemaType !== undefined && String(this.schemaType).trim() !== '';
    }

    get hasSchemaType2() {
        return this.schemaType2 !== null && this.schemaType2 !== undefined && String(this.schemaType2).trim() !== '';
    }

    currentPageReference = null;

    //<-- START ONLOAD
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          //console.log('state:'+JSON.stringify(currentPageReference.state));
          let state = currentPageReference.state;
          this.disabledAccount = false;
          this.showrecord = true;
          if(state){
            let recid = state.recordId;
            if(recid != undefined){
                if(recid.startsWith('006')){
                    this.recordId = state.recordId;
                    this.getOpportunityDetail(this.recordId);
                }
            }
          }
       }
    }
    //GET OPPORTUNITY DETAIL
    getOpportunityDetail(recordid){
        this.isLoading = true;
        getOpportunity({ recordId: recordid })
        .then(rec => {
            this.isLoading = false;
            this.showrecord = false;
            this.opportunityTypeId = rec.Opportunity_Type__c;
            this.accountId = rec.AccountId;
            this.getAccountDetail(this.accountId);
            if(this.accountId != undefined) this.disabledAccount = true;
            //const single = this.template.querySelector('input[data-id="1"]');
            //single.checked = true;
            this.insuredId = rec.The_Insured_Name__c;
            this.getInsuredDetail(this.insuredId);
            this.showSingle = true;
            this.showMultiple = false;
            this.contractTypeId = undefined;
            this.contractTypeId2 = undefined;
            this.getPicklistContractType();
            this.cob1 = rec.COB__c;
            this.description = rec.Description;
            //const optyname = recName.split(' - ');
            //if(optyname[1] != undefined) this.riskName = rec.Name;
            this.changeCOB(this.cob1,'');
            this.productTypeId = rec.Product_Type_Id__c;
            this.productTypeName = rec.Product_Type__c;
            this.getPicklistPolicy('',1,this.productTypeId);
        })
        .catch(error => {
            this.isLoading = false;
            console.error('Error fetching Opportunity details:', error.message);
        });
    }
    //ONLOAD
    connectedCallback() {
        this.showFull = false;
        if(this.recordId == undefined){
            getFocusedTabInfo().then(tabInfo => {
                this.tabId = tabInfo.tabId;
                setTabLabel(this.tabId, 'Opportunity');
                setTabIcon(this.tabId, 'standard:opportunity', { iconAlt: 'Opportunity' });
            }); 
            this.showFull = true;
        }
        this.getPicklistOpportunityType();
        if(this.account != undefined){
            this.accountId = this.account;
            this.getAccountDetail(this.accountId);
            if(this.accountId != undefined) this.disabledAccount = true;
            this.showFull = false;
        }
        console.log('Gerry3');
    }
    //GET PICKLIST OPPORTUNITY TYPE
    getPicklistOpportunityType(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Opportunity_Type__c'
        })
        .then(result => {
            this.opportunityType = [];
            for (var key in result) {
                if(key != 'RN' && key != 'ED') this.opportunityType.push({label:result[key], value:key});
            }
            return this.opportunityType;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }
    //--> END ONLOAD

    //<-- START CLOSE
    disconnectedCallback(){
        if(this.actionsave != 'yes'){
            //this.successMessage('See u again!');
            let listId = [];
            if(this.filequote1.length > 0){
                for(let i=0;i<this.filequote1.length;i++){
                    listId.push(this.filequote1[i].documentId);
                }
            }
            if(this.fileclosing1.length > 0){
                for(let i=0;i<this.fileclosing1.length;i++){
                    listId.push(this.fileclosing1[i].documentId);
                }
            }
            if(this.filesurvey1.length > 0){
                for(let i=0;i<this.filesurvey1.length;i++){
                    listId.push(this.filesurvey1[i].documentId);
                }
            }
            if(this.filequote2.length > 0){
                for(let i=0;i<this.filequote2.length;i++){
                    listId.push(this.filequote2[i].documentId);
                }
            }
            if(this.fileclosing2.length > 0){
                for(let i=0;i<this.fileclosing2.length;i++){
                    listId.push(this.fileclosing2[i].documentId);
                }
            }
            if(this.filesurvey2.length > 0){
                for(let i=0;i<this.filesurvey2.length;i++){
                    listId.push(this.filesurvey2[i].documentId);
                }
            }

            if(listId.length > 0){
                deleteFiles({ data: JSON.stringify(listId) })
                    .then(() => {
                        console.log('sukses delete file');
                    })
                    .catch(error => {
                        console.log('error:'+error.body.message);
                    });
            }
        }
    }
    //--> END CLOSE

    //BUTTON RENEWAL
    async handleRenewal(event){
        const result = await myModal.open({});
        console.log('result:'+result);
        if(result != undefined){
            if(result.indexOf('006')!=-1){
                this.successMessage('Opportunity has been saved!');
                this.refreshTabPage();
                if(this.recordId != undefined) this.dispatchEvent(new CloseActionScreenEvent());
                else{
                    if(this.accountId != undefined) window.location.href = "/"+result;
                    this.navigateToRecordViewPage(result);
                }
            }else if(result != 'cancel'){
                this.errorMessage('Error: '+result);
            }
        }
    }

    //<-- START OPPORTUNITY TYPE
    //CHANGE OPPORTUNITY TYPE
    handleOpportunityType(event){
        this.opportunityTypeId = event.detail.value;
        this.getShowMOU();
        this.getShowRealisasi();
    }
    //GET SHOW FIELD MOU
    getShowMOU(){
        this.mouId1 = undefined;
        this.showFieldMOU = false;
        if(this.opportunityTypeId == 'NB' && this.cob1 == '301' && this.accountId != undefined){
            this.getContractData(this.accountId);
        }
    }
    //GET DATA MOU
    getContractData(recordId){
        this.isLoading = true;
        getContract ({
            recordId: recordId
        }).then(result =>{
            this.isLoading = false;
            this.showFieldMOU = result;
            if(result == true){
                this.filterMOU1 = {
                    criteria : [
                        {
                            fieldPath : 'AccountId',
                            operator : 'eq',
                            value : this.accountId
                        },
                        {
                            fieldPath : 'Status',
                            operator : 'eq',
                            value : 'Activated'
                        }
                    ],
                    filterLogic: '1 AND 2', 
                    orderBy: [{fieldPath: 'Name', direction: 'asc'}]
                };
            }
        }).catch(error => {
            this.isLoading = false;
            console.error('Error - getContractData:', error.message);
        });
    }
    //GET SHOW FIELD REALISASI
    getShowRealisasi(){
        this.realisasiId1 = undefined;
        this.showFieldRealisasi1 = false;
        if(this.opportunityTypeId == 'NB' && this.cob1 == '101' && this.contractTypeId != undefined){
            this.showFieldRealisasi1 = true;
            this.filterRealisasi1 = {
                criteria : [
                    {
                        fieldPath : 'Policy_Closing_Type__c',
                        operator : 'eq',
                        value : this.contractTypeId
                    },
                    {
                        fieldPath : 'StageName',
                        operator : 'eq',
                        value : 'Closed Won'
                    },
                    {
                        fieldPath : 'COB__c',
                        operator : 'eq',
                        value : this.cob1
                    },
                    {
                        fieldPath : 'Parent_Opportunity__c',
                        operator : 'eq',
                        value : null
                    },
                    {
                        fieldPath : 'AccountId',
                        operator : 'eq',
                        value : this.accountId
                    },
                ],
                filterLogic: '1 AND 2 AND 3 AND 4 AND 5', 
                orderBy: [{fieldPath: 'Name', direction: 'asc'}]
            };
        }
    }
    //--> END OPPORTUNITY TYPE

    //<-- START ACCOUNT
    //CHANGE ACCOUNT
    handleAccountSelected(event) {
        this.accountId = event.detail.recordId;
        if(this.accountId){
            this.getAccountDetail(this.accountId);
        }
        this.getShowMOU();
    }
    //GET ACCOUNT DETAIL
    getAccountDetail(recordid){
        this.isLoading = true;
        this.getPicklistRequestorType();
        this.getPicklistRequestorSegment();
        this.getPicklistRequestorSubSegment();
        this.getPicklistRequestorBusinessSegmentation();
        this.getPicklistRequestorPipelineStatus();
        this.getPicklistRequestorChannel();
        this.requestorChannelId = undefined;
        getAccountDetail({ accountId: recordid })
        .then(acc => {
            this.isLoading = false;
            this.requestorTypeId = acc.Type;
            this.requestorSegmentId = acc.Account_Segment__c;
            this.requestorSubSegmentId = acc.Account_Sub_Segment__c;
            this.requestorBusinessSegmentationId = acc.Business_Segmentation__c;
            this.requestorPipelineStatusId = acc.Account_Pipeline_Status__c;
            this.requestorAddress = acc.Address__c;
            if(this.requestorPipelineStatusId == 'Channel'){
                this.showChannel = true;
                this.requestorChannelId = acc.Account_Channel__c;
            }
            if(this.requestorPipelineStatusId == 'Direct'){
                this.insuredId = this.accountId;
                this.getInsuredDetail(this.insuredId);
            }
        })
        .catch(error => {
            this.isLoading = false;
            console.error('Error fetching Account details', error);
        });
    }
    //CHANGE Account Pipeline Status
    handleRequestorPipelineStatus(event){
        this.requestorPipelineStatusId = event.detail.value;
        
        if(this.requestorPipelineStatusId == 'Channel'){
            this.showChannel = true;
        }else{
            this.showChannel = false;
            this.requestorChannelId - undefined;
        }
        if(this.requestorPipelineStatusId == 'Direct'){
            this.insuredId = this.accountId;
            this.getInsuredDetail(this.insuredId);
        }
    }
    //CHANGE ACCOUNT TYPE
    handleRequestorType(event){
        this.requestorTypeId = event.detail.value;
    }
    //CHANGE ACCOUNT SEGMENT
    handleRequestorSegment(event){
        this.requestorSegmentId = event.detail.value;
    }
    //CHANGE ACCOUNT SUB SEGMENT
    handleRequestorSubSegment(event){
        this.requestorSubSegmentId = event.detail.value;
    }
    //CHANGE ACCOUNT Business Segmentation
    handleRequestorBusinessSegmentation(event){
        this.requestorBusinessSegmentationId = event.detail.value;
    }
    //CHANGE Account Channel
    handleRequestorChannel(event){
        this.requestorChannelId = event.detail.value;
    }
    //CHANGE Account Address
    handleRequestorAddress(event){
        this.requestorAddress = event.detail.value;
    }
    //--> END ACCOUNT

    //<-- START QQ MEMBER
    //CHANGE QQ MEMBER
    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        if (this.searchKey.length < 2) {
            this.searchResults = [];
            return;
        }
        this.isLoading = true;
        searchAccounts({ searchKey: this.searchKey })
            .then(results => {
                this.isLoading = false;
                this.searchResults = results;
            })
            .catch(error => {
                this.isLoading = false;
                console.error('Error searching Accounts:', error);
            });
    }
    //SELECT QQ MEMBER FROM TABLE
    handleSelectAccount(event) {
        const { id, name, address, type } = event.currentTarget.dataset;
        if (this.members.some(m => m.id === id)) {
            this.clearLookup();
            return;
        }
        this.members = [
            ...this.members,
            { id, name, address, type }
        ];
        this.originalMemberIds.add(id);
        this.clearLookup();
    }
    //CLEAR SEARCH INPUT
    clearLookup() {
        this.searchKey     = '';
        this.searchResults = [];
    }
    //ROW ACTION TABLE QQ MEMBER
    handleRowAction(event) {
        if (event.detail.action.name === 'remove') {
            const remId = event.detail.row.id;
            this.members = this.members.filter(m => m.id !== remId);
            this.originalMemberIds.delete(remId);
        }
    }
    //--> END QQ MEMBER

    //SINGLE / MULTIPLE
    handleSelected(event){
        const single = this.template.querySelector('input[data-id="1"]');
        const multiple = this.template.querySelector('input[data-id="2"]');
        if(single.checked == true){
            this.showSingle = true;
            this.showMultiple = false;
            this.contractTypeId = undefined;
            this.contractTypeId2 = undefined;
            this.getPicklistContractType();
        }else if(multiple.checked == true){
            this.showSingle = true;
            this.showMultiple = true;
            this.contractTypeId2 = undefined;
            this.getPicklistContractType();
            this.getPicklistContractType2();
        }
    }

    //CLICK SECTION ACCORDION
    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage = 'Open sections: ' + openSections.join(', ');
        }
    }

    //<-- START COB 1
    //CHANGE COB 1
    handleChangeCOB1(event) {
        let value = event.detail.value;
        this.cob1 = value;
        this.showPremium = false;
        if(value != '' && value != undefined){
            this.changeCOB(value,'change');
            if(this.cob1  == '301' || this.cob1  == '302' || this.cob1  == '303'){
                this.showPremium = true;
                this.getPremiumCalculation();
                this.adjustPremiumCalculationBasedOnDuration();
            }
        }
        this.getShowMOU();
        this.getShowRealisasi();
    }
    //FUNCTION CHANGE COB 1
    changeCOB(value,type){
        this.isLoading = true;
        if(type == 'change'){
            this.contractTypeId = undefined;
            this.productType = [];
            this.policyWording = [];
            this.productTypeId = undefined;
            this.productTypeName = undefined;
            this.policyWordingId = undefined;
            this.policyWordingName = undefined;
            this.getPicklist(this.cob1,1);
        }else if(type == ''){
            this.contractTypeId = undefined;
            this.productType = [];
            this.policyWording = [];
            this.getPicklist(this.cob1,1);
        }
        if(this.showMOU == true){
            this.mapInputMOU1 = new Map();
            this.mapInputMOU1.set('COB__C',value);
            this.datafieldMOU1 = [];
            this.getRisk1();
        }else if(this.showRealisasi1 == true){
            this.mapInputRealisasi1 = new Map();
            this.mapInputRealisasi1.set('COB__C',value);
            this.datafieldRealisasi1 = [];
            this.dataAssetRealisasi1 = [];
            this.getRiskRealisasi();
        }else{
            this.mapInput = new Map();
            this.mapInput.set('COB__C',value);
            this.datafield1 = [];
            this.dataDescription1 = [];
            this.getDescription(value);
            this.getSituation(value);
            this.getPicklistAssetSection(value);
        }
        if(this.cob1  != '101'){
            this.contractTypeId = '1';
        }
    }
    //GET FIELD SITUATION 1
    async getSituation(value){
        await getMasterData({
            cob: value,
            description : "Situation",
            contracttype : this.contractTypeId
        })
        .then(result => {
            this.isLoading = false;
            let field1 = [];
            for(let i=0; i<result.length; i++){
                let setValue = undefined;
                field1.push({
                    object : result[i].dataobject,
                    field : result[i].datafield,
                    label : result[i].datalabel,
                    type : result[i].datatype,
                    lookup : result[i].datalookup,
                    filter : result[i].datafilter,
                    required : result[i].datarequired,
                    value : setValue,
                    showdata : result[i].showdata
                });
            }
            this.datafield1 = field1;
            //console.log('this.datafield1:'+JSON.stringify(this.datafield1));
            if(result.length > 0) this.showFormat1 = true;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error-handleChangeCOB1:'+ error.message);
        }); 
    }
    //GET FIELD DESCRIPTION 1
    async getDescription(value){
        await getMasterData({
            cob: value,
            description : "Description",
            contracttype : this.contractTypeId
        })
        .then(result => {
            this.isLoading = false;
            let field1 = [];
            for(let i=0; i<result.length; i++){
                let setValue = undefined;
                field1.push({
                    object : result[i].dataobject,
                    field : result[i].datafield,
                    label : result[i].datalabel,
                    type : result[i].datatype,
                    lookup : result[i].datalookup,
                    filter : result[i].datafilter,
                    required : result[i].datarequired,
                    value : setValue,
                    showdata : result[i].showdata
                });
            }
            this.dataDescription1 = field1;
            //console.log('this.dataDescription1:'+JSON.stringify(this.dataDescription1));
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error-getDescription:'+ error.message);
        }); 
    }
    //GET FIELD RISK - MOU 1
    async getRisk1(){
        let value = this.cob1;
        if(value!= '' && value != undefined){
            await getMasterDataSection({
                cob: value,
                contracttype : this.contractTypeId
            })
            .then(result => {
                this.isLoading = false;
                let field1 = [];
                for(let i=0; i<result.length; i++){
                    field1.push({
                        name : result[i].name,
                        data : result[i].data
                    });
                }
                this.datafieldMOU1 = field1;
                console.log('this.datafieldMOU1:'+JSON.stringify(this.datafieldMOU1));
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error-getRisk1:'+ error.message);
            }); 
        }
    }
    //GET FIELD RISK - REALISASI 1
    async getRiskRealisasi(){
        let value = this.cob1;
        if(value!= '' && value != undefined){
            await getMasterDataSection({
                cob: value,
                contracttype : this.contractTypeId
            })
            .then(result => {
                this.isLoading = false;
                let field1 = [];
                for(let i=0; i<result.length; i++){
                    field1.push({
                        name : result[i].name,
                        data : result[i].data
                    });
                }
                this.datafieldRealisasi1 = field1;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error-getRiskRealisasi:'+ error.message);
            }); 
        }
    }
    //--> END COB 1

    //<-- START COB 2
    //CHANGE COB 2
    handleChangeCOB2(event) {
        let value = event.detail.value;
        this.cob2 = value;
        this.showPremium2 = false;
        if(value != '' && value != undefined){
            this.changeCOB2(value,'change');
            if(value == '301' || value == '302' || value == '303'){
                this.showPremium2 = true;
                this.getPremiumCalculation2();
                this.adjustPremiumCalculationBasedOnDuration2();
            }
        }
    }
    //FUNCTION COB 2
    changeCOB2(value,type){
        this.isLoading = true;
        if(type == 'change'){
            this.contractTypeId2 = undefined;
            this.productType2 = [];
            this.policyWording2 = [];
            this.productTypeId2 = undefined;
            this.productTypeName2 = undefined;
            this.policyWordingId2 = undefined;
            this.policyWordingName2 = undefined;
            this.getPicklist(this.cob2,2);
        }
        this.mapInput2 = new Map();
        this.mapInput2.set('COB__C',value);
        this.datafield2 = [];
        this.dataDescription2 = [];
        this.getDescription2(value);
        this.getSituation2(value);
        this.getPicklistAssetSection2(value);
        if(value != '101'){
            this.contractTypeId2 = '1';
        }
    }
    //GET FIELD SITUATION 2
    async getSituation2(value){
        await getMasterData({
            cob: value,
            description : "Situation",
            contracttype : this.contractTypeId2
        })
        .then(result => {
            this.isLoading = false;
            for(let i=0; i<result.length; i++){
                let setValue = undefined;
                this.datafield2.push({
                    object : result[i].dataobject,
                    field : result[i].datafield,
                    label : result[i].datalabel,
                    type : result[i].datatype,
                    lookup : result[i].datalookup,
                    filter : result[i].datafilter,
                    required : result[i].datarequired,
                    value : setValue,
                    showdata : result[i].showdata,
                });
            }
            if(result.length > 0) this.showFormat2 = true;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error-handleChangeCOB2:'+ error.message);
        }); 
    }
    //GET FIELD DESCRIPTION 2
    async getDescription2(value){
        await getMasterData({
            cob: value,
            description : "Description",
            contracttype : this.contractTypeId2
        })
        .then(result => {
            this.isLoading = false;
            
            for(let i=0; i<result.length; i++){
                let setValue = undefined;
                this.dataDescription2.push({
                    object : result[i].dataobject,
                    field : result[i].datafield,
                    label : result[i].datalabel,
                    type : result[i].datatype,
                    lookup : result[i].datalookup,
                    filter : result[i].datafilter,
                    required : result[i].datarequired,
                    value : setValue,
                    showdata : result[i].showdata
                });
            }
            //if(result.length > 0) this.showFormat1 = true;
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error-getDescription2:'+ error.message);
        }); 
    }
    //--> END COB 2

    //<-- START INSURED
    //CHANGE THE INSURED NAME
    handleInsuredSelected(event){
        this.insuredId = event.detail.recordId;
        if (this.insuredId) {
            this.isLoading = true;
            this.getInsuredDetail(this.insuredId);
        }else{
            this.showInsured = false;
        }
    }
    //GET INSURED DETAIL
    getInsuredDetail(recordid){
        getAccountDetail({ accountId: recordid })
        .then(acc => {
            this.showInsured = true;
            this.isLoading = false;
            // concatenate billing fields
            this.accountAddress = acc.Address__c;
            /*this.accountAddress = [
                acc.BillingStreet,
                acc.BillingCity,
                acc.BillingState,
                acc.BillingPostalCode,
                acc.BillingCountry
                ]
                .filter(Boolean)
                .join(', ');*/
        })
        .catch(error => {
            this.isLoading = false;
            console.error('Error fetching Account details', error);
        });
    }
    //CHANGE The Insured Address
    handleInsuredAddress(event){
        this.accountAddress = event.detail.value;
    }
    //--> END INSURED

    //<-- PRODUCT TYPE 1
    //CHANGE PRODUCT TYPE
    handleProductType(event){
        this.policyWording = [];
        this.policyWordingId = undefined;
        this.policyWordingName = undefined;
        this.productTypeId = event.detail.value;
        this.getProductType();
    }
    //GET PRODUCT TYPE
    getProductType(){
        this.productTypeName = this.productType.find(opt => opt.value === this.productTypeId).label;
        this.getPicklistPolicy('',1,this.productTypeId);
    }
    //--> PRODUCT TYPE 1

    //CHANGE POLICY WORDING 1
    handlePolicyWording(event){
        this.policyWordingId = event.detail.value;
        this.policyWordingName = this.policyWording.find(opt => opt.value === this.policyWordingId).label;
        this.showIAR = false;
        this.fireTypeId = undefined;
        this.wordingId = undefined;
        this.wordingName = undefined;
        if(this.policyWordingName == 'IAR/PAR'){
            this.showIAR = true;
            //this.getPicklistFireType();
            this.getPicklistWording(this.policyWordingId);
        }
    }

    //CHANGE CONTRACT TYPE 1
    handleContractType(event){
        this.contractTypeId = event.detail.value;
        if(this.cob1 != undefined && this.cob1 != ''){
            if(this.cob1 == '101'){
                this.changeCOB(this.cob1,'contract');
            }
        }
        this.getShowRealisasi();
    }

    //CHANGE Wording Standard 1
    handleWording(event){
        this.wordingId = event.detail.value;
        this.wordingName = this.wording.find(opt => opt.value === this.wordingId).label;
    }

    //CHANGE PREMIUM CALCULATION 1
    handlePremiumCalculation(event){
        this.premiumCalculationId = event.detail.value;
    }

    //<-- INSURANCE PERIOD 1
    handleSchemaChange(event) { this.schemaType = event.detail.value; this.calculateDuration(); }
    handleInsurance(event) {
        const newType = event.detail ? event.detail.value : event.target.value;
        this.periodType = newType;
        if (newType === '2') {this.shortBasis = '2'; }
        else { this.shortBasis = null; }
        this.percentage = null; this.startDate = null; this.endDate = null;
        this.calculatedRate = null; this.adjustmentRows = []; this.dayCount = null; this.yearsMonthsInfo = null;
        this.years = (newType === '1') ? 1 : null;
        this.calculateDuration();
    }
    handleYearsChange(event) { this.years = this.isAnnual ? 1 : event.detail.value; this.calculateDuration(); }
    handleShortBasisChange(event) { this.shortBasis = event.detail.value; this.calculateDuration(); }
    handlePercentageChange(event) { this.percentage = event.detail.value; this.calculateDuration(); }
    handleStartDateChange(event) {
        this.startDate = event.detail.value;
        if (this.isAnnual && this.startDate) {
            const dt = new Date(this.startDate);
            dt.setFullYear(dt.getFullYear() + 1);
            this.endDate = dt.toISOString().slice(0, 10);
        }
        this.calculateDuration();
        this.adjustPremiumCalculationBasedOnDuration();
    }
    handleEndDateChange(event) { 
        this.endDate = event.detail.value; 
        this.calculateDuration(); 
        this.adjustPremiumCalculationBasedOnDuration();
    }
    handleRowTypeChange(event) {
        const year = parseInt(event.target.dataset.year, 10);
        const type = event.detail.value;
        this.adjustmentRows = this.adjustmentRows.map(r => {
            if (r.year === year) {
                let newPct = (type === '2') ? this.calculatedRate : r.percentage;
                return { ...r, type, percentage: newPct };
            }
            return r;
        });
        this.updateYearsMonthsInfo();
    }
    sanitizePercentageString(raw) {
        if (raw == null) return '';
        let s = String(raw);
        s = s.replace(/,/g, '.');
        s = s.replace(/[^0-9.]/g, '');
        const parts = s.split('.');
        if (parts.length > 1) { s = parts.shift() + (parts.length ? '.' + parts.join('') : ''); }
        if (s.startsWith('.')) {s = '0' + s;}
        return s;
    }
    handleRowPercentageInput(event) {
        const input = event.target;
        const original = input.value;
        const sanitized = this.sanitizePercentageString(original);

        if (sanitized !== original) {input.value = sanitized;}

        // Keep local model in sync while typing
        const year = parseInt(input.dataset.year, 10);
        const percentage = sanitized;
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage } : r
        );
    }
    handleRowPercentagePaste(event) {
        event.preventDefault();
        const paste = (event.clipboardData || window.clipboardData).getData('text') || '';
        const sanitized = this.sanitizePercentageString(paste);
        const input = event.target;
        input.value = sanitized;
        const year = parseInt(input.dataset.year, 10);
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage: sanitized } : r
        );
    }
    handleRowPercentageKeyDown(event) {
        const key = event.key;
        if (
            key === 'Backspace' || key === 'Delete' ||
            key === 'ArrowLeft' || key === 'ArrowRight' ||
            key === 'Home' || key === 'End' ||
            event.ctrlKey || event.metaKey || event.altKey
        ) {
            return;
        }

        // we only care about inserting a dot character
        if (key !== '.' && key !== ',') return;

        const input = event.target;
        const value = input.value || '';
        const selStart = input.selectionStart ?? value.length;
        const selEnd = input.selectionEnd ?? value.length;

        // compute what the value would become after inserting the key
        const before = value.slice(0, selStart);
        const after = value.slice(selEnd);
        const wouldBe = before + '.' + after;

        // allow if resulting value contains at most one dot; otherwise block
        const dotCount = (wouldBe.match(/\./g) || []).length;
        if (dotCount > 1) {
            event.preventDefault();
        } else {
            // if user typed comma, convert it to dot for immediate insertion
            if (key === ',') {
            event.preventDefault();
            const newValue = wouldBe; // already uses dot above
            input.value = newValue;
            // move caret after inserted dot
            const newPos = before.length + 1;
            input.setSelectionRange(newPos, newPos);

            // sync model immediately
            const year = parseInt(input.dataset.year, 10);
            const percentage = this.sanitizePercentageString(newValue);
            this.adjustmentRows = this.adjustmentRows.map(r =>
                r.year === year ? { ...r, percentage } : r
            );
            }
        }
    }
    handleRowPercentageChange(event) {
        const year = parseInt(event.target.dataset.year, 10);
        const raw = event?.detail?.value ?? event.target.value;
        const percentage = this.sanitizePercentageString(raw);
        try { event.target.value = percentage; }
        catch (e) {}
        this.adjustmentRows = this.adjustmentRows.map(r =>
            r.year === year ? { ...r, percentage } : r
        );
        this.updateYearsMonthsInfo();
    }
    // ------ Core calculation ------
    calculateDuration() {
        if (!this.startDate || !this.endDate) {
            this.dayCount = null; this.yearsMonthsInfo = null; this.calculatedRate = null; this.adjustmentRows = [];
            return;
        }
        const start  = new Date(this.startDate);
        const end    = new Date(this.endDate);
        this.dayCount = Math.floor((end - start) / (1000 * 60 * 60 * 24));
        let y = end.getFullYear() - start.getFullYear();
        let m = end.getMonth() - start.getMonth();
        let d = end.getDate() - start.getDate();
        if (d < 0) { m--; }
        if (d >= 30) { m++; }
        if (m < 0) { y--; m += 12; }
        this._computedYears  = y;
        this._computedMonths = m;

        if (this.isShort && this.isProRataBasis) {
            this.calculatedRate = parseFloat((this.dayCount / 365).toFixed(6));
        } else if (this.isLongTerm && y >= 1) {
            const fullYearsLater = new Date(start);
            fullYearsLater.setFullYear(start.getFullYear() + y);
            const extraMs = end - fullYearsLater;
            const extraDays = Math.floor(extraMs / (1000 * 60 * 60 * 24)) + 1; 
            this.calculatedRate = extraDays > 0 ? parseFloat((extraDays / 365).toFixed(6)) : 0;
        } else {
            this.calculatedRate = null;
        }

        if (this.isLongTerm && this.schemaType != null) {
            const hasExtra = m > 0 || d > 0;
            const rowCount = y + (hasExtra ? 1 : 0);
            const newRows = [];
            const oldUiRows = [...this.adjustmentRows];

            for (let i = 0; i < rowCount; i++) {
                const yearNum = i + 1;
                const isExtraRow = hasExtra && i === rowCount - 1;
                const oldUiRow = oldUiRows.find(row => row.year === yearNum);

                let rowType = null;
                let rowPercentage = null;
                
                if (i === 0) {
                    rowPercentage = 100;
                    rowType = null; // First row doesn't need type
                } else if (isExtraRow) {
                    // Ensure type always has a value, default to '2'
                    rowType = oldUiRow?.type || '2';
                    if (rowType === '2') {
                        rowPercentage = this.calculatedRate; 
                    } else {
                        rowPercentage = oldUiRow?.percentage ?? null;
                    }
                } else {
                    // For other rows, ensure type has a value
                    rowType = oldUiRow?.type || '2';
                    rowPercentage = oldUiRow?.percentage ?? null;
                }

                newRows.push({ 
                    year: yearNum, 
                    percentage: rowPercentage, 
                    type: rowType  // This ensures every row has a type (except first row)
                });
            }
            this.adjustmentRows = [...newRows];
        } else {
            this.adjustmentRows = [];
        }

        this.updateYearsMonthsInfo();
    }
    // build the human‐readable period string
    updateYearsMonthsInfo() {
        if (this.isAnnual) { this.yearsMonthsInfo = '1 Year'; return; }
        if (this.isShort) {
            if (this.isProRataBasis) { this.yearsMonthsInfo = `Rate ${this.calculatedRate}`; } 
            else { this.yearsMonthsInfo = `Percentage ${this.percentage || 0}%`; }
            return;
        }
        const y = this._computedYears;
        const m = this._computedMonths;
        let base = `${y} Year${y !== 1 ? 's' : ''}`;
        if (m > 0) {
            base += ` and ${m} Month${m !== 1 ? 's' : ''}`;
        }
        if (m === 0 && this._computedDays === 0) { this.yearsMonthsInfo = base; return; }
        const lastRow = this.adjustmentRows && this.adjustmentRows.length > 0 
            ? this.adjustmentRows[this.adjustmentRows.length - 1] 
            : null;
        if(lastRow){
            if (lastRow.type === '1') { this.yearsMonthsInfo = `${base} | Percentage ${lastRow.percentage || 0}%`; }
            else if (lastRow.type === '2') { this.yearsMonthsInfo = `${base} | Total Rate ${ (this._computedYears + this.calculatedRate) }`; }
            else { this.yearsMonthsInfo = base; }
        }else{
            if(this._computedYears >= 1 && this._computedMonths > 0){
                this.yearsMonthsInfo = `${base} | Total Rate ${ (this._computedYears + this.calculatedRate) }`;
            }else{
                this.yearsMonthsInfo = base;
            }
        }
    }
    // Method to adjust premium calculation value when dates change
    adjustPremiumCalculationBasedOnDuration() {
        if (!this.showPremium || !this.startDate || !this.endDate) {
            return;
        }
        
        const start = new Date(this.startDate);
        const end = new Date(this.endDate);
        const yearDiff = end.getFullYear() - start.getFullYear();
        const monthDiff = end.getMonth() - start.getMonth();
        const dayDiff = end.getDate() - start.getDate();
        
        let actualYearDiff = yearDiff;
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            actualYearDiff--;
        }
        
        let newPremiumCalculation = null;
        
        if (actualYearDiff === 0) {
            // Less than 1 year - Default to "Pro Rata" (4), but user can also select "Percentage" (5)
            // Only set default if not already set to one of the allowed options
            if (!this.premiumCalculationId || 
                (this.premiumCalculationId !== '4' && this.premiumCalculationId !== '5')) {
                newPremiumCalculation = '4';
            }
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year - Set to "Flat" (1)
            newPremiumCalculation = '1';
        } else {
            // More than 1 year - Default to "Long Period" (6), but user can also select 
            // "Decreasing Sum Insured" (2) or "Discount Rate" (3)
            // Only set default if not already set to one of the allowed options
            if (!this.premiumCalculationId || 
                (this.premiumCalculationId !== '6' && 
                 this.premiumCalculationId !== '2' && 
                 this.premiumCalculationId !== '3')) {
                newPremiumCalculation = '6';
            }
        }
        
        // Only update if we have a new value to set
        if (newPremiumCalculation !== null && this.premiumCalculationId !== newPremiumCalculation) {
            this.premiumCalculationId = newPremiumCalculation;
        }
    }
    //--> INSURANCE PERIOD 1

    //CHANGE RISK NAME 1
    handleRiskName(event){
        this.riskName = event.detail.value;
    }

    //<-- STANDARD 1
    //CHANGE RISK DESCRIPTION 1
    handleInputDesc(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob1;
        let result = this.dataDescription1;
        let mapIn = this.mapInput;
        this.setCInput(result,cob,fieldName,value,mapIn,'1');
    }

    //CHANGE RISK SITUATION 1
    handleCInput(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob1;
        let result = this.datafield1;
        let mapIn = this.mapInput;
        //console.log('fieldName:'+fieldName);
        //console.log('value:'+value);
        this.setCInput(result,cob,fieldName,value,mapIn,'1');
    }
    //SET INPUT FROM DYNAMIC FIELD
    setCInput(result,cob,fieldName,value,mapIn,type){
        const field = result.find(item => item.field === fieldName);
        //console.log('field:'+JSON.stringify(field));
        //console.log('field-showdata:'+field.showdata);
        if(value == undefined && fieldName != undefined && field.showdata != undefined){ //fieldName == 'Address__c'
            let resultid = mapIn.get(fieldName);
            //console.log('resultid:'+resultid);
            //console.log('this.datafield1:'+JSON.stringify(result));
            let mapData = new Map();
            for(let i=0; i<result.length; i++){
                if(result[i].field == fieldName){
                    let showdata = result[i].showdata;
                    //console.log('showdata:'+showdata);
                    let data = JSON.parse(showdata);
                    //console.log('data:'+data);
                    for(let j=0;j<data.length;j++){
                        //console.log('param1:'+data[j].param1);
                        mapData.set(data[j].param1,data[j].param2);
                    }
                    break;
                }
            }

            if(resultid != undefined && resultid != ''){
                const childCmp = this.template.querySelectorAll('c-input');
                if (childCmp) {
                    for(let i=0;i<childCmp.length;i++){
                        let fieldName = childCmp[i].getName();
                        let fieldDepend = mapData.get(fieldName);
                        //console.log('fieldDepend:'+fieldDepend);
                        if(fieldDepend == ''){
                            childCmp[i].setFilter(resultid);
                        }
                    }
                }

                getObject({
                    fieldname: fieldName,
                    cob : cob,
                    recordId : resultid
                })
                .then(obj => {
                    //console.log('obj:'+JSON.stringify(obj));
                    let mapObj = new Map(Object.entries(obj[0]));
                    //console.log('mapObj:'+mapObj.get('Id'));
                    for(let i=0; i<result.length; i++){
                        //console.log('i:'+i);
                        let fKey = result[i].field;
                        //console.log('fKey:'+fKey);
                        let fName = mapData.get(fKey);
                        //console.log('fName:'+fName);
                        if(fName != undefined){
                            let fValue = mapObj.get(fName);
                            if(fValue == undefined) fValue = '';
                            //console.log('fValue:'+fValue);
                            result[i].value = fValue;
                            if(type == '1') this.mapInput.set(fKey,fValue);
                            else if(type == '2') this.mapInput2.set(fKey,fValue);
                            else if(type == '3') this.mapSummary1.set(fKey,fValue);
                            else if(type == '4') this.mapSummary2.set(fKey,fValue);
                        }
                    }
                    console.log('result:'+JSON.stringify(result));
                })
                .catch(error => {
                    console.log('error-getObject:'+ error.message);
                });
            }else{
                for(let i=0; i<result.length; i++){
                    let fKey = result[i].field;
                    let fName = mapData.get(fKey);
                    console.log(fKey+':'+fName);
                    if(fName != undefined){
                        console.log(fName);
                        result[i].value = '';
                        if(type == '1') this.mapInput.set(fKey,'');
                        else if(type == '2') this.mapInput2.set(fKey,'');
                        else if(type == '3') this.mapSummary1.set(fKey,'');
                        else if(type == '4') this.mapSummary2.set(fKey,'');
                    }
                }
                const childCmp = this.template.querySelectorAll('c-input');
                if (childCmp) {
                    for(let i=0;i<childCmp.length;i++){
                        let fieldName = childCmp[i].getName();
                        let fieldDepend = mapData.get(fieldName);
                        if(fieldDepend == ''){
                            childCmp[i].clearLookup();
                        }
                    }
                }
                console.log('result:'+JSON.stringify(result));
            }
        }
    }

    //CHANGE SUMMARY / SPECIFIC (1)
    handleFormat(event){
        const summary = this.template.querySelector('input[data-id="Summary"]');
        const specific = this.template.querySelector('input[data-id="Specific"]');
        if(summary.checked == true){
            this.dataFormat1 = 'Summary';
            this.showSummary = true;
            this.getPicklistCurrency();
            this.assetSectionId = undefined;
            this.assetCategoryId = undefined;
            this.currencyId = undefined;
            this.rate = undefined;
            this.showIDR = false;
            this.sumInsured = undefined;
            this.sumInsuredIDR = undefined;
            this.premium = undefined;
            this.premiumIDR = undefined;
            this.numberOfRisk = undefined;
            this.closedDate = undefined;
            this.description = undefined;
        }else if(specific.checked == true){
            this.showSummary = false;
            this.dataSummary1 = [];
            this.dataFormat1 = 'Specific';
        }
        if(this.showSummary == true){
            this.isLoading = true;
            getMasterData({
                cob: this.cob1,
                description : "Profile",
                contracttype : this.contractTypeId
            })
            .then(result => {
                this.isLoading = false;
                let field1 = [];
                for(let i=0; i<result.length; i++){
                    let setValue = undefined;
                    field1.push({
                        object : result[i].dataobject,
                        field : result[i].datafield,
                        label : result[i].datalabel,
                        type : result[i].datatype,
                        lookup : result[i].datalookup,
                        filter : result[i].datafilter,
                        required : result[i].datarequired,
                        value : setValue,
                        showdata : result[i].showdata
                    });
                }
                this.dataSummary1 = field1;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error-handleFormat:'+ error.message);
            });  
        }
    }

    //CHANGE ASSET SECTION 1
    handleAssetSection(event){
        this.assetSectionId = event.detail.value;
        if(this.assetSectionId){
            this.getPicklistAssetCategory(this.cob1,this.assetSectionId);
        }
    }

    //CHANGE ASSET CATEGORY 1
    handleAssetCategory(event){
        this.assetCategoryId = event.detail.value;
    }

    //CHANGE CURRENCY 1
    handleCurrency(event){
        this.currencyId = event.detail.value;
        this.currencyName = this.currency.find(item => item.value === this.currencyId).label;
        this.showIDR = false;
        this.sumInsuredIDR = undefined;
        this.premiumIDR = undefined;
        this.rate = undefined;
        if(this.currencyName == 'IDR'){
            this.rate = 1;
            if(this.sumInsured) this.sumInsuredIDR = this.sumInsured;
            if(this.premium) this.premiumIDR = this.premium;
        }else if(this.currencyName != 'IDR'){
            this.showIDR = true;
            this.getAmountRate(this.currencyName,'1');
        }
    }

    //CHANGE SUM INSURED 1
    handleSumInsured(event){
        this.sumInsured = event.detail.value;
        this.sumInsuredIDR = undefined;
        if(this.sumInsured){
            this.sumInsuredIDR = this.sumInsured * this.rate;
        }
    }

    //CHANGE PREMIUM 1
    handlePremium(event){
        this.premium = event.detail.value;
        this.premiumIDR = undefined;
        if(this.premium){
            this.premiumIDR = this.premium * this.rate;
        }
    }

    //CHANGE RISK PROFILE 1
    handleInputProfile(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob1;
        let result = this.dataSummary1;
        let mapIn = this.mapSummary1;
        this.setCInput(result,cob,fieldName,value,mapIn,'3');
    }

    //CHANGE QUANTITY OF RISK 1
    handleNumberOfRisk(event){
        this.numberOfRisk = event.detail.value;
    }

    //CHANGE Expected Date Of Closing 1
    handleClosedDate(event){
        this.closedDate = event.detail.value;
    }

    //CHANGE DESCRIPTION 1
    handleDescription(event){
        this.description = event.detail.value;
    }

    //<-- UPLOAD FILE 1
    //UPLOAD QUOTATION
    handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        for(const item of uploadedFiles){
            this.filequote1.push(item);    
        }
    }
    //UPLOAD CLOSING
    handleUploadFinished1(event){
        const uploadedFiles = event.detail.files;
        for(const item of uploadedFiles){
            this.fileclosing1.push(item);    
        }
    }
    //UPLOAD SURVEY
    handleUploadFinished2(event){
        const uploadedFiles = event.detail.files;
        for(const item of uploadedFiles){
            this.filesurvey1.push(item);    
        }
    }
    //--> UPLOAD FILE 1
    //--> STANDARD 1

    //<-- REALISASI 1
    //CHANGE REALISASI 1
    handleRealisasiSelected1(event){
        this.realisasiId1 = event.detail.recordId;
        this.showRealisasi1 = false;
        this.showStandard = true;
        if(this.realisasiId1 != undefined && this.realisasiId1 != ''){
            this.showRealisasi1 = true;
            this.showStandard = false;
            this.getRiskRealisasi();
        }
    }
    //CHANGE FIELD REALISASI 1
    handleInputRealisasi1(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob1;
        let result = this.datafieldRealisasi1;
        let mapIn = this.mapInputRealisasi1;
        this.setCInputRealisasi(result,cob,fieldName,value,mapIn,'1');
    }
    //SET INPUT REALISASI 1
    setCInputRealisasi(result,cob,fieldName,value,mapIn,type){
        let field,resultdata;
        for(let x=0;x<result.length;x++){
            resultdata = result[x].data;
            field = resultdata.find(item => item.datafield === fieldName);
            if(field != undefined) break;
        }
        if(value == undefined && fieldName != undefined && field.showdata != undefined){
            let resultid = mapIn.get(fieldName);
            let mapData = new Map();
            for(let i=0; i<resultdata.length; i++){
                if(resultdata[i].datafield == fieldName){
                    let showdata = resultdata[i].showdata;
                    let data = JSON.parse(showdata);
                    for(let j=0;j<data.length;j++){
                        mapData.set(data[j].param1,data[j].param2);
                    }
                    break;
                }
            }
            if(resultid != undefined && resultid != ''){
                const childCmp = this.template.querySelectorAll('c-input');
                if (childCmp) {
                    for(let i=0;i<childCmp.length;i++){
                        let fieldName = childCmp[i].getName();
                        let fieldDepend = mapData.get(fieldName);
                        if(fieldDepend == ''){
                            childCmp[i].setFilter(resultid);
                        }
                    }
                }
                getObject({
                    fieldname: fieldName,
                    cob : cob,
                    recordId : resultid
                })
                .then(obj => {
                    let mapObj = new Map(Object.entries(obj[0]));
                    for(let i=0; i<resultdata.length; i++){
                        let fKey = resultdata[i].datafield;
                        let fName = mapData.get(fKey);
                        if(fName != undefined){
                            let fValue = mapObj.get(fName);
                            if(fValue == undefined) fValue = '';
                            resultdata[i].value = fValue;
                            if(type == '1') this.mapInputRealisasi1.set(fKey,fValue);
                        }
                    }
                })
                .catch(error => {
                    console.log('error-getObject:'+ error.message);
                });
            }else{
                console.log('clear');
                for(let i=0; i<resultdata.length; i++){
                    let fKey = resultdata[i].datafield;
                    let fName = mapData.get(fKey);
                    //console.log(fKey+':'+fName);
                    if(fName != undefined){
                        //console.log(fName);
                        resultdata[i].value = '';
                        if(type == '1') this.mapInputRealisasi1.set(fKey,'');
                    }
                }
                const childCmp = this.template.querySelectorAll('c-input');
                if (childCmp) {
                    for(let i=0;i<childCmp.length;i++){
                        let fieldName = childCmp[i].getName();
                        let fieldDepend = mapData.get(fieldName);
                        if(fieldDepend == ''){
                            childCmp[i].clearLookup();
                        }
                    }
                }
                console.log('resultdata:'+JSON.stringify(resultdata));
            }
        }
    }
    //ROW ACTION REALISASI ASSET 1
    handleRowActionAssetRealisasi1(event){
        console.log('handleRowActionAssetRealisasi1');
        const action = event.detail.action;
        const row = event.detail.row;
        let records = this.dataAssetRealisasi1;
        const rowIndex = records.findIndex(r => r.Id === row.Id);
        let record = records[rowIndex];
        console.log('row:'+JSON.stringify(row));
        switch (action.name) {
            case 'show_details':
                this.showModalAsset1(records,record,this.realisasiId1);
                break;
            case 'delete':
                LightningConfirm.open({
                    message: 'Are your sure want to delete this asset?',
                    label: 'Warning', 
                    variant : 'headerless'
                }).then((result) => {
                    if(result == true){
                        const rowIndex = records.findIndex(r => r.Id === row.Id);
                        records.splice(rowIndex, 1);
                        this.dataAssetRealisasi1 = [...records];
                        this.dataCoverageRealisasi1 = [];
                        console.log('record:'+JSON.stringify(this.dataAssetRealisasi1));
                    }
                });
                break;
        }
    }
    //BUTTON ADD ASSET REALISASI 1
    handleAddAssetRealisasi1(event){
        console.log('handleAddAssetRealisasi1');
        let records = this.dataAssetRealisasi1;
        this.showModalAsset1(records,undefined,this.realisasiId1);
    }
    //ROW ACTION REALISASI COVERAGE 1
    handleRowActionCoverageRealisasi1(event){
        console.log('handleRowActionCoverageRealisasi1');
        const action = event.detail.action;
        const row = event.detail.row;
        let assets = this.dataAssetRealisasi1;
        let records = this.dataCoverageRealisasi1;
        const rowIndex = records.findIndex(r => r.Id === row.Id);
        let record = records[rowIndex];
        console.log('row:'+JSON.stringify(row));
        switch (action.name) {
            case 'show_details':
                this.showModalCoverage1(records,record,this.realisasiId1,assets);
                break;
            case 'delete':
                LightningConfirm.open({
                    message: 'Are your sure want to delete this coverage?',
                    label: 'Warning', 
                    variant : 'headerless'
                }).then((result) => {
                    if(result == true){
                        let data = [];
                        for(let i=0;i<records.length;i++){
                            if(records[i].Id != row.Id){
                                data = [...data,records[i]];
                            }
                        }
                        this.dataCoverageRealisasi1 = [...data];
                        console.log('record:'+JSON.stringify(this.dataCoverageRealisasi1));
                    }
                });
                break;
        }
    }
    //BUTTON ADD REALISASI COVERAGE 1
    handleAddCoverageRealisasi1(event){
        console.log('handleAddCoverageRealisasi1');
        let assets = this.dataAssetRealisasi1;
        let records = this.dataCoverageRealisasi1;
        if(assets.length == 0){
            LightningAlert.open({message: 'Please Add Asset!',theme: 'error',label: 'Error!'});
        }else{
            this.showModalCoverage1(records,undefined,this.realisasiId1,assets);
        }
    }
    //SHOW MODAL ASSET REALISASI 1
    async showModalAsset1(records,record,recordid){
        const result = await modalRealisasi.open({
            records : records,
            record : record,
            recordid : recordid,
            type : 'realisasi'
        });
        console.log('result:'+JSON.stringify(result));
        if(result != 'cancel' && result != undefined){
            this.dataAssetRealisasi1 = result;
            this.dataCoverageRealisasi1 = [];
        }
    }
    //SHOW MODAL REALISASI COVERAGE 1
    async showModalCoverage1(records,record,recordid,assets){
        const result = await modalCoverage.open({
            records : records,
            record : record,
            recordid : recordid,
            assets : assets,
            type : 'realisasi'
        });
        console.log('result:'+JSON.stringify(result));
        if(result != 'cancel' && result != undefined){
            this.dataCoverageRealisasi1 = result;
        }
    }
    //--> REALISASI 1

    //--> MOU 1
    //CHANGE MOU 1
    handleMOUSelected1(event){
        console.log('handleMOUSelected1');
        this.mouId1 = event.detail.recordId;
        console.log('mouId1:'+this.mouId1);
        this.showMOU = false;
        this.showStandard = true;
        if(this.mouId1 != undefined && this.mouId1 != ''){
            this.showMOU = true;
            this.showStandard = false;
            this.getRisk1();
        }
    }
    //CHANGE FIELD MOU 1
    handleInputMOU1(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob1;
        let result = this.datafieldMOU1;
        let mapIn = this.mapInputMOU1;
        this.setCInputMOU(result,cob,fieldName,value,mapIn,'1');
    }
    //SET INPUT MOU 1
    setCInputMOU(result,cob,fieldName,value,mapIn,type){
        let field,resultdata;
        for(let x=0;x<result.length;x++){
            resultdata = result[x].data;
            field = resultdata.find(item => item.datafield === fieldName);
            if(field != undefined) break;
        }
        if(value == undefined && fieldName != undefined && field.showdata != undefined){
            let resultid = mapIn.get(fieldName);
            let mapData = new Map();
            for(let i=0; i<resultdata.length; i++){
                if(resultdata[i].datafield == fieldName){
                    let showdata = resultdata[i].showdata;
                    let data = JSON.parse(showdata);
                    for(let j=0;j<data.length;j++){
                        mapData.set(data[j].param1,data[j].param2);
                    }
                    break;
                }
            }
            if(resultid != undefined && resultid != ''){
                const childCmp = this.template.querySelectorAll('c-input');
                if (childCmp) {
                    for(let i=0;i<childCmp.length;i++){
                        let fieldName = childCmp[i].getName();
                        let fieldDepend = mapData.get(fieldName);
                        if(fieldDepend == ''){
                            childCmp[i].setFilter(resultid);
                        }
                    }
                }
                getObject({
                    fieldname: fieldName,
                    cob : cob,
                    recordId : resultid
                })
                .then(obj => {
                    let mapObj = new Map(Object.entries(obj[0]));
                    for(let i=0; i<resultdata.length; i++){
                        let fKey = resultdata[i].datafield;
                        let fName = mapData.get(fKey);
                        if(fName != undefined){
                            let fValue = mapObj.get(fName);
                            if(fValue == undefined) fValue = '';
                            resultdata[i].value = fValue;
                            if(type == '1') this.mapInputMOU1.set(fKey,fValue);
                        }
                    }
                    //console.log('resultdata:'+JSON.stringify(resultdata));
                })
                .catch(error => {
                    console.log('error-getObject:'+ error.message);
                });
            }else{
                console.log('clear');
                for(let i=0; i<resultdata.length; i++){
                    let fKey = resultdata[i].datafield;
                    let fName = mapData.get(fKey);
                    //console.log(fKey+':'+fName);
                    if(fName != undefined){
                        //console.log(fName);
                        resultdata[i].value = '';
                        if(type == '1') this.mapInputMOU1.set(fKey,'');
                    }
                }
                const childCmp = this.template.querySelectorAll('c-input');
                if (childCmp) {
                    for(let i=0;i<childCmp.length;i++){
                        let fieldName = childCmp[i].getName();
                        let fieldDepend = mapData.get(fieldName);
                        if(fieldDepend == ''){
                            childCmp[i].clearLookup();
                        }
                    }
                }
                console.log('resultdata:'+JSON.stringify(resultdata));
            }
        }
    }
    //ROW ACTION ASSET MOU 1
    handleRowActionAssetMOU1(event){
        console.log('handleRowActionAssetMOU1');
        const action = event.detail.action;
        const row = event.detail.row;
        let records = this.dataAssetMOU1;
        const rowIndex = records.findIndex(r => r.Id === row.Id);
        let record = records[rowIndex];
        console.log('row:'+JSON.stringify(row));
        switch (action.name) {
            case 'show_details':
                this.showModalAssetMOU1(records,record,this.mouId1);
                break;
            case 'delete':
                LightningConfirm.open({
                    message: 'Are your sure want to delete this asset?',
                    label: 'Warning', 
                    variant : 'headerless'
                }).then((result) => {
                    if(result == true){
                        const rowIndex = records.findIndex(r => r.Id === row.Id);
                        records.splice(rowIndex, 1);
                        this.dataAssetMOU1 = [...records];
                        this.dataCoverageMOU1 = [];
                        console.log('record:'+JSON.stringify(this.dataAssetMOU1));
                    }
                });
                break;
        }
    }
    //BUTTON ADD ASSET MOU 1
    handleAddAssetMOU1(event){
        console.log('handleAddAssetMOU1');
        let records = this.dataAssetMOU1;
        this.showModalAssetMOU1(records,undefined,this.mouId1);
    }
    //ROW ACTION COVERAGE MOU 1
    handleRowActionCoverageMOU1(event){
        console.log('handleRowActionCoverageMOU1');
        const action = event.detail.action;
        const row = event.detail.row;
        let assets = this.dataAssetMOU1;
        let records = this.dataCoverageMOU1;
        const rowIndex = records.findIndex(r => r.Id === row.Id);
        let record = records[rowIndex];
        console.log('row:'+JSON.stringify(row));
        switch (action.name) {
            case 'show_details':
                this.showModalCoverageMOU1(records,record,this.mouId1,assets);
                break;
            case 'delete':
                LightningConfirm.open({
                    message: 'Are your sure want to delete this coverage?',
                    label: 'Warning', 
                    variant : 'headerless'
                }).then((result) => {
                    if(result == true){
                        let data = [];
                        for(let i=0;i<records.length;i++){
                            if(records[i].Id != row.Id){
                                data = [...data,records[i]];
                            }
                        }
                        this.dataCoverageMOU1 = [...data];
                        console.log('record:'+JSON.stringify(this.dataCoverageMOU1));
                    }
                });
                break;
        }
    }
    //BUTTON ADD COVERAGE MOU 1
    handleAddCoverageMOU1(event){
        console.log('handleAddCoverageMOU1');
        let assets = this.dataAssetMOU1;
        let records = this.dataCoverageMOU1;
        if(assets.length == 0){
            LightningAlert.open({message: 'Please Add Asset!',theme: 'error',label: 'Error!'});
        }else{
            this.showModalCoverageMOU1(records,undefined,this.mouId1,assets);
        }
    }
    //SHOW MODAL ASSET MOU 1
    async showModalAssetMOU1(records,record,recordid){
        const result = await modalRealisasi.open({
            records : records,
            record : record,
            recordid : recordid,
            type : 'mou'
        });
        console.log('result:'+JSON.stringify(result));
        if(result != 'cancel' && result != undefined){
            this.dataAssetMOU1 = result;
            this.dataCoverageMOU1 = [];
        }
    }
    //SHOW MODAL REALISASI MOU 1
    async showModalCoverageMOU1(records,record,recordid,assets){
        const result = await modalCoverage.open({
            records : records,
            record : record,
            recordid : recordid,
            assets : assets,
            type : 'mou'
        });
        console.log('result:'+JSON.stringify(result));
        if(result != 'cancel' && result != undefined){
            this.dataCoverageMOU1 = result;
        }
    }
    //--> MOU 1

    //CHANGE POLICY WORDING 2
    handlePolicyWording2(event){
        this.policyWordingId2 = event.detail.value;
        this.policyWordingName2 = this.policyWording2.find(opt => opt.value === this.policyWordingId2).label;
        this.showIAR2 = false;
        this.fireTypeId2 = undefined;
        this.wordingId2 = undefined;
        this.wordingName2 = undefined;
        if(this.policyWordingName2 == 'IAR/PAR'){
            this.showIAR2 = true;
            //this.getPicklistFireType2();
            this.getPicklistWording2(this.policyWordingId2);
        }
    }

    //CHANGE Wording Standard 2
    handleWording2(event){
        this.wordingId2 = event.detail.value;
        this.wordingName2 = this.wording2.find(opt => opt.value === this.wordingId2).label;
    }

    //CHANGE RISK SITUATION 2
    handleCInput2(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob2;
        let result = this.datafield2;
        let mapIn = this.mapInput2;
        this.setCInput(result,cob,fieldName,value,mapIn,'2');
    }

    //CHANGE RISK DESCRIPTION 2
    handleInputDesc2(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob2;
        let result = this.dataDescription2;
        let mapIn = this.mapInput2;
        //console.log('fieldName:'+fieldName);
        //console.log('value:'+value);
        this.setCInput(result,cob,fieldName,value,mapIn,'2');
    }

    //CHANGE SUMMARY / SPECIFIC (2)
    handleFormat2(event){
        const summary = this.template.querySelector('input[data-id="Summary2"]');
        const specific = this.template.querySelector('input[data-id="Specific2"]');
        if(summary.checked == true){
            this.showSummary2 = true;
            this.dataFormat2 = 'Summary';
            this.getPicklistCurrency2();
            this.assetSectionId2 = undefined;
            this.assetCategoryId2 = undefined;
            this.currencyId2 = undefined;
            this.rate2 = undefined;
            this.showIDR2 = false;
            this.sumInsured2 = undefined;
            this.sumInsuredIDR2 = undefined;
            this.premium2 = undefined;
            this.premiumIDR2 = undefined;
            this.numberOfRisk2 = undefined;
            this.closedDate2 = undefined;
            this.description2 = undefined;
        }else if(specific.checked == true){
            this.showSummary2 = false;
            this.dataSummary2 = [];
            this.dataFormat2 = 'Specific';
        }
        if(this.showSummary2 == true){
            this.isLoading = true;
            let field1 = [];
            getMasterData({
                cob: this.cob2,
                description : "Profile",
                contracttype : this.contractTypeId2
            })
            .then(result => {
                this.isLoading = false;
                let field1 = [];
                for(let i=0; i<result.length; i++){
                    let setValue = undefined;
                    field1.push({
                        object : result[i].dataobject,
                        field : result[i].datafield,
                        label : result[i].datalabel,
                        type : result[i].datatype,
                        lookup : result[i].datalookup,
                        filter : result[i].datafilter,
                        required : result[i].datarequired,
                        value : setValue,
                        showdata : result[i].showdata
                    });
                }
                this.dataSummary2 = field1;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error-handleFormat2:'+ error.message);
            });  
        }
    }

    //CHANGE RISK PROFILE 2
    handleInputProfile2(event){
        let value = event.detail.value;
        let fieldName = event.target.fieldName;
        let cob = this.cob2;
        let result = this.dataSummary2;
        let mapIn = this.mapSummary2;
        this.setCInput(result,cob,fieldName,value,mapIn,'4');
    }


    //CHANGE PRODUCT TYPE 2
    handleProductType2(event){
        this.policyWording2 = [];
        this.policyWordingId2 = undefined;
        this.policyWordingName2 = undefined;
        this.productTypeId2 = event.detail.value;
        this.productTypeName2 = this.productType2.find(opt => opt.value === this.productTypeId2).label;
        this.getPicklistPolicy('',2,this.productTypeId2);
    }

    //CHANGE CONTRACT TYPE 2
    handleContractType2(event){
        this.contractTypeId2 = event.detail.value;
        if(this.cob2 != undefined && this.cob2 != ''){
            if(this.cob2 == '101'){
                this.changeCOB2(this.cob2,'contract');
            }
        }
    }

    //CHANGE ASSET SECTION 2
    handleAssetSection2(event){
        this.assetSectionId2 = event.detail.value;
        if(this.assetSectionId2){
            this.getPicklistAssetCategory2(this.cob2,this.assetSectionId2);
        }
    }

    //CHANGE ASSET CATEGORY 2
    handleAssetCategory2(event){
        this.assetCategoryId2 = event.detail.value;
    }

    //CHANGE CURRENCY 2
    handleCurrency2(event){
        this.currencyId2 = event.detail.value;
        this.currencyName2 = this.currency2.find(item => item.value === this.currencyId2).label;
        this.showIDR2 = false;
        this.sumInsuredIDR2 = undefined;
        this.premiumIDR2 = undefined;
        this.rate2 = undefined;
        if(this.currencyName2 == 'IDR'){
            this.rate2 = 1;
            if(this.sumInsured2) this.sumInsuredIDR2 = this.sumInsured2;
            if(this.premium2) this.premiumIDR2 = this.premium2;
        }else if(this.currencyName2 != 'IDR'){
            this.showIDR2 = true;
            this.getAmountRate(this.currencyName2,'2');
        }
    }

    //CHANGE PREMIUM CALCULATION 2
    handlePremiumCalculation2(event){
        this.premiumCalculationId2 = event.detail.value;
    }

    //<-- INSURANCE PERIOD 2
    handleSchemaChange2(event) { this.schemaType2 = event.detail.value; this.calculateDuration2(); }
    handleInsurance2(event) {
        const newType = event.detail ? event.detail.value : event.target.value;
        this.periodType2 = newType;
        if (newType === '2') {this.shortBasis2 = '2'; }
        else { this.shortBasis2 = null; }
        this.percentage2 = null; this.startDate2 = null; this.endDate2 = null;
        this.calculatedRate2 = null; this.adjustmentRows2 = []; this.dayCount2 = null; this.yearsMonthsInfo2 = null;
        this.years2 = (newType === '1') ? 1 : null;
        this.calculateDuration2();
        
    }
    handleYearsChange2(event) { this.years2 = this.isAnnual2 ? 1 : event.detail.value; this.calculateDuration2(); }
    handleShortBasisChange2(event) { this.shortBasis2 = event.detail.value; this.calculateDuration2(); }
    handlePercentageChange2(event) { this.percentage2 = event.detail.value; this.calculateDuration2(); }
    handleStartDateChange2(event) {
        this.startDate2 = event.detail.value;
        if (this.isAnnual2 && this.startDate2) {
            const dt = new Date(this.startDate2);
            dt.setFullYear(dt.getFullYear() + 1);
            this.endDate2 = dt.toISOString().slice(0, 10);
        }
        this.calculateDuration2();
        this.adjustPremiumCalculationBasedOnDuration2();
    }
    handleEndDateChange2(event) { 
        this.endDate2 = event.detail.value; 
        this.calculateDuration2(); 
        this.adjustPremiumCalculationBasedOnDuration2();
    }
    handleRowTypeChange2(event) {
        const year = parseInt(event.target.dataset.year, 10);
        const type = event.detail.value;
        this.adjustmentRows2 = this.adjustmentRows2.map(r => {
            if (r.year === year) {
                let newPct = (type === '2') ? this.calculatedRate2 : r.percentage;
                return { ...r, type, percentage: newPct };
            }
            return r;
        });
        this.updateYearsMonthsInfo2();
    }
    handleRowPercentageInput2(event) {
        const input = event.target;
        const original = input.value;
        const sanitized = this.sanitizePercentageString(original);

        if (sanitized !== original) {input.value = sanitized;}

        // Keep local model in sync while typing
        const year = parseInt(input.dataset.year, 10);
        const percentage = sanitized;
        this.adjustmentRows2 = this.adjustmentRows2.map(r =>
            r.year === year ? { ...r, percentage } : r
        );
    }
    handleRowPercentagePaste2(event) {
        event.preventDefault();
        const paste = (event.clipboardData || window.clipboardData).getData('text') || '';
        const sanitized = this.sanitizePercentageString(paste);
        const input = event.target;
        input.value = sanitized;
        const year = parseInt(input.dataset.year, 10);
        this.adjustmentRows2 = this.adjustmentRows2.map(r =>
            r.year === year ? { ...r, percentage: sanitized } : r
        );
    }
    handleRowPercentageKeyDown2(event) {
        const key = event.key;
        if (
            key === 'Backspace' || key === 'Delete' ||
            key === 'ArrowLeft' || key === 'ArrowRight' ||
            key === 'Home' || key === 'End' ||
            event.ctrlKey || event.metaKey || event.altKey
        ) {
            return;
        }

        // we only care about inserting a dot character
        if (key !== '.' && key !== ',') return;

        const input = event.target;
        const value = input.value || '';
        const selStart = input.selectionStart ?? value.length;
        const selEnd = input.selectionEnd ?? value.length;

        // compute what the value would become after inserting the key
        const before = value.slice(0, selStart);
        const after = value.slice(selEnd);
        const wouldBe = before + '.' + after;

        // allow if resulting value contains at most one dot; otherwise block
        const dotCount = (wouldBe.match(/\./g) || []).length;
        if (dotCount > 1) {
            event.preventDefault();
        } else {
            // if user typed comma, convert it to dot for immediate insertion
            if (key === ',') {
            event.preventDefault();
            const newValue = wouldBe; // already uses dot above
            input.value = newValue;
            // move caret after inserted dot
            const newPos = before.length + 1;
            input.setSelectionRange(newPos, newPos);

            // sync model immediately
            const year = parseInt(input.dataset.year, 10);
            const percentage = this.sanitizePercentageString(newValue);
            this.adjustmentRows2 = this.adjustmentRows2.map(r =>
                r.year === year ? { ...r, percentage } : r
            );
            }
        }
    }
    handleRowPercentageChange2(event) {
        const year = parseInt(event.target.dataset.year, 10);
        const raw = event?.detail?.value ?? event.target.value;
        const percentage = this.sanitizePercentageString(raw);
        try { event.target.value = percentage; }
        catch (e) {}
        this.adjustmentRows2 = this.adjustmentRows2.map(r =>
            r.year === year ? { ...r, percentage } : r
        );
        this.updateYearsMonthsInfo2();
    }
    // ------ Core calculation ------
    calculateDuration2() {
        if (!this.startDate2 || !this.endDate2) {
            this.dayCount2 = null; this.yearsMonthsInfo2 = null; this.calculatedRate2 = null; this.adjustmentRows2 = [];
            return;
        }
        const start  = new Date(this.startDate2);
        const end    = new Date(this.endDate2);
        this.dayCount2 = Math.floor((end - start) / (1000 * 60 * 60 * 24));
        let y = end.getFullYear()  - start.getFullYear();
        let m = end.getMonth()     - start.getMonth();
        let d = end.getDate()      - start.getDate();
        if (d < 0) { m--; }
        if (d >= 30) { m++; }
        if (m < 0) { y--; m += 12; }
        this._computedYears2  = y;
        this._computedMonths2 = m;

        if (this.isShort2 && this.isProRataBasis2) {
            this.calculatedRate2 = parseFloat((this.dayCount2 / 365).toFixed(6));
        } else if (this.isLongTerm2 && y >= 1) {
            const fullYearsLater = new Date(start);
            fullYearsLater.setFullYear(start.getFullYear() + y);
            const extraMs = end - fullYearsLater;
            const extraDays = Math.floor(extraMs / (1000 * 60 * 60 * 24)) + 1; 
            this.calculatedRate2 = extraDays > 0 ? parseFloat((extraDays / 365).toFixed(6)) : 0;
        } else {
            this.calculatedRate2 = null;
        }

        if (this.isLongTerm2 && this.schemaType2 != null) {
            const hasExtra = m > 0 || d > 0;
            const rowCount = y + (hasExtra ? 1 : 0);
            const newRows = [];
            const oldUiRows = [...this.adjustmentRows2];

            for (let i = 0; i < rowCount; i++) {
                const yearNum = i + 1;
                const isExtraRow = hasExtra && i === rowCount - 1;
                const oldUiRow = oldUiRows.find(row => row.year === yearNum);

                let rowType = null;
                let rowPercentage = null;
                
                if (i === 0) {
                    rowPercentage = 100;
                    rowType = null; // First row doesn't need type
                } else if (isExtraRow) {
                    // Ensure type always has a value, default to '2'
                    rowType = oldUiRow?.type || '2';
                    if (rowType === '2') {
                        rowPercentage = this.calculatedRate2; 
                    } else {
                        rowPercentage = oldUiRow?.percentage ?? null;
                    }
                } else {
                    // For other rows, ensure type has a value
                    rowType = oldUiRow?.type || '2';
                    rowPercentage = oldUiRow?.percentage ?? null;
                }

                newRows.push({ 
                    year: yearNum, 
                    percentage: rowPercentage, 
                    type: rowType  // This ensures every row has a type (except first row)
                });
            }
            this.adjustmentRows2 = [...newRows];
        } else {
            this.adjustmentRows2 = [];
        }

        this.updateYearsMonthsInfo2();
    }
    // build the human‐readable period string
    updateYearsMonthsInfo2() {
        if (this.isAnnual2) { this.yearsMonthsInfo2 = '1 Year'; return; }
        if (this.isShort2) {
            if (this.isProRataBasis2) { this.yearsMonthsInfo2 = `Rate ${this.calculatedRate2}`; } 
            else { this.yearsMonthsInfo2 = `Percentage ${this.percentage2 || 0}%`; }
            return;
        }
        const y = this._computedYears2;
        const m = this._computedMonths2;
        let base = `${y} Year${y !== 1 ? 's' : ''}`;
        if (m > 0) {
            base += ` and ${m} Month${m !== 1 ? 's' : ''}`;
        }
        if (m === 0 && this._computedDays2 === 0) { this.yearsMonthsInfo2 = base; return; }
        const lastRow = this.adjustmentRows2[this.adjustmentRows2.length - 1];
        if(lastRow){
            if (lastRow.type === '1') { this.yearsMonthsInfo2 = `${base} | Percentage ${lastRow.percentage || 0}%`; }
            else if (lastRow.type === '2') { this.yearsMonthsInfo2 = `${base} | Total Rate ${ (this._computedYears2 + this.calculatedRate2) }`; }
            else { this.yearsMonthsInfo2 = base; }
        }else{
            if(this._computedYears2 >= 1 && this._computedMonths2 > 0){
                this.yearsMonthsInfo2 = `${base} | Total Rate ${ (this._computedYears2 + this.calculatedRate2) }`;
            }else{
                this.yearsMonthsInfo2 = base;
            }
        }
    }
    // Method to adjust premium calculation value when dates change
    adjustPremiumCalculationBasedOnDuration2() {
        if (!this.showPremium2 || !this.startDate2 || !this.endDate2) {
            return;
        }
        
        const start = new Date(this.startDate2);
        const end = new Date(this.endDate2);
        const yearDiff = end.getFullYear() - start.getFullYear();
        const monthDiff = end.getMonth() - start.getMonth();
        const dayDiff = end.getDate() - start.getDate();
        
        let actualYearDiff = yearDiff;
        if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            actualYearDiff--;
        }
        
        let newPremiumCalculation = null;
        
        if (actualYearDiff === 0) {
            // Less than 1 year - Default to "Pro Rata" (4), but user can also select "Percentage" (5)
            // Only set default if not already set to one of the allowed options
            if (!this.premiumCalculationId2 || 
                (this.premiumCalculationId2 !== '4' && this.premiumCalculationId2 !== '5')) {
                newPremiumCalculation = '4';
            }
        } else if (actualYearDiff === 1 && monthDiff === 0 && dayDiff === 0) {
            // Exactly 1 year - Set to "Flat" (1)
            newPremiumCalculation = '1';
        } else {
            // More than 1 year - Default to "Long Period" (6), but user can also select 
            // "Decreasing Sum Insured" (2) or "Discount Rate" (3)
            // Only set default if not already set to one of the allowed options
            if (!this.premiumCalculationId2 || 
                (this.premiumCalculationId2 !== '6' && 
                 this.premiumCalculationId2 !== '2' && 
                 this.premiumCalculationId2 !== '3')) {
                newPremiumCalculation = '6';
            }
        }
        
        // Only update if we have a new value to set
        if (newPremiumCalculation !== null && this.premiumCalculationId2 !== newPremiumCalculation) {
            this.premiumCalculationId2 = newPremiumCalculation;
        }
    }
    //--> INSURANCE PERIOD 2

    //CHANGE DESCRIPTION 2
    handleDescription2(event){
        this.description2 = event.detail.value;
    }

    //CHANGE RISK NAME 2
    handleRiskName2(event){
        this.riskName2 = event.detail.value;
    }
    //CHANGE SUM INSURED 2
    handleSumInsured2(event){
        this.sumInsured2 = event.detail.value;
        this.sumInsuredIDR2 = undefined;
        if(this.sumInsured2){
            this.sumInsuredIDR2 = this.sumInsured2 * this.rate2;
        }
    }
    //CHANGE PREMIUM 2
    handlePremium2(event){
        this.premium2 = event.detail.value;
        this.premiumIDR2 = undefined;
        if(this.premium2){
            this.premiumIDR2 = this.premium2 * this.rate2;
        }
    }
    //CHANGE QUANTITY OF RISK 2
    handleNumberOfRisk2(event){
        this.numberOfRisk2 = event.detail.value;
    }
    //CHANGE EXPECTED DATE OF CLOSING 2
    handleClosedDate2(event){
        this.closedDate2 = event.detail.value;
    }

    //<-- UPLOAD FILE 2
    //UPLOAD QUOTATION 2
    handleUploadFinished3(event){
        const uploadedFiles = event.detail.files;
        for(const item of uploadedFiles){
            this.filequote2.push(item);    
        }
    }
    //UPLOAD CLOSING 2
    handleUploadFinished4(event){
        const uploadedFiles = event.detail.files;
        for(const item of uploadedFiles){
            this.fileclosing2.push(item);    
        }
    }
    //UPLOAD SURVEY 2
    handleUploadFinished5(event){
        const uploadedFiles = event.detail.files;
        for(const item of uploadedFiles){
            this.filesurvey2.push(item);    
        }
    }
    //--> UPLOAD FILE 2

    //<-- DELETE FILE 1
    //DELETE QUOTATION 1
    handleDelete(event){
        const documentId = event.target.dataset.id;
        this.isLoading = true;
        deleteFile({ documentId: documentId })
            .then(() => {
                this.isLoading = false;
                this.filequote1 = this.filequote1.filter(file => file.documentId !== documentId);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error:'+error.body.message);
            });
    }
    //DELETE CLOSING 1
    handleDelete1(event){
        const documentId = event.target.dataset.id;
        this.isLoading = true;
        deleteFile({ documentId: documentId })
            .then(() => {
                this.isLoading = false;
                this.fileclosing1 = this.fileclosing1.filter(file => file.documentId !== documentId);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error:'+error.body.message);
            });
    }
    //DELETE SURVEY 1
    handleDelete2(event){
        const documentId = event.target.dataset.id;
        this.isLoading = true;
        deleteFile({ documentId: documentId })
            .then(() => {
                this.isLoading = false;
                this.filesurvey1 = this.filesurvey1.filter(file => file.documentId !== documentId);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error:'+error.body.message);
            });
    }
    //--> DELETE FILE 1

    //<-- DELETE FILE 2
    //DELETE QUOTATION 2
    handleDelete3(event){
        const documentId = event.target.dataset.id;
        this.isLoading = true;
        deleteFile({ documentId: documentId })
            .then(() => {
                this.isLoading = false;
                this.filequote2 = this.filequote2.filter(file => file.documentId !== documentId);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error:'+error.body.message);
            });
    }
    //DELETE CLOSING 2
    handleDelete4(event){
        const documentId = event.target.dataset.id;
        this.isLoading = true;
        deleteFile({ documentId: documentId })
            .then(() => {
                this.isLoading = false;
                this.fileclosing2 = this.fileclosing2.filter(file => file.documentId !== documentId);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error:'+error.body.message);
            });
    }
    //DELETE SURVEY 2
    handleDelete5(event){
        const documentId = event.target.dataset.id;
        this.isLoading = true;
        deleteFile({ documentId: documentId })
            .then(() => {
                this.isLoading = false;
                this.filesurvey2 = this.filesurvey2.filter(file => file.documentId !== documentId);
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error:'+error.body.message);
            });
    }   
    //--> DELETE FILE 2

    //<-- GET DATA FROM CLASS
    getPicklist(cob,type){
        getProductType({
            filter: cob
        })
        .then(result => {
            if(type == 1) this.productType = [];
            else if(type == 2) this.productType2 = [];
            for (var key in result) {
                if(type == 1) this.productType.push({label:result[key], value:key});
                if(type == 2) this.productType2.push({label:result[key], value:key});
            }
            if(type == 1) return this.productType;
            else if(type == 2) return this.productType2;
        })
        .catch(error => {
            console.log('error-getPicklist:'+ error.message);
        });
    }

    getPicklistPolicy(cob,type,producttype){
        getPolicyWording({
            filter: cob,
            producttype:producttype
        })
        .then(result => {
            if(type == 1) this.policyWording = [];
            else if(type == 2) this.policyWording2 = [];
            for (var key in result) {
                if(type == 1) this.policyWording.push({label:result[key], value:key});
                if(type == 2) this.policyWording2.push({label:result[key], value:key});
            }
            if(type == 1) return this.policyWording;
            else if(type == 2) return this.policyWording2;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistRequestorType(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Requestor_Type__c'
        })
        .then(result => {
            this.requestorType = [];
            for (var key in result) {
                this.requestorType.push({label:result[key], value:key});
            }
            return this.requestorType;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistRequestorSegment(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Requestor_Segment__c'
        })
        .then(result => {
            this.requestorSegment = [];
            for (var key in result) {
                this.requestorSegment.push({label:result[key], value:key});
            }
            return this.requestorSegment;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistRequestorSubSegment(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Requestor_Sub_Segment__c'
        })
        .then(result => {
            this.requestorSubSegment = [];
            for (var key in result) {
                this.requestorSubSegment.push({label:result[key], value:key});
            }
            return this.requestorSubSegment;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistRequestorBusinessSegmentation(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Requestor_Business_Segmentation__c'
        })
        .then(result => {
            this.requestorBusinessSegmentation = [];
            for (var key in result) {
                this.requestorBusinessSegmentation.push({label:result[key], value:key});
            }
            return this.requestorBusinessSegmentation;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistRequestorPipelineStatus(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Requestor_Pipeline_Status__c'
        })
        .then(result => {
            this.requestorPipelineStatus = [];
            for (var key in result) {
                this.requestorPipelineStatus.push({label:result[key], value:key});
            }
            return this.requestorPipelineStatus;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistRequestorChannel(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Requestor_Channel__c'
        })
        .then(result => {
            this.requestorChannel = [];
            for (var key in result) {
                this.requestorChannel.push({label:result[key], value:key});
            }
            return this.requestorChannel;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistContractType(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Policy_Closing_Type__c'
        })
        .then(result => {
            this.contractType = [];
            for (var key in result) {
                this.contractType.push({label:result[key], value:key});
            }
            return this.contractType;
        })
        .catch(error => {
            console.log('error-getPicklistContractType:'+ error.message);
        });
    }

    getPicklistContractType2(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'Policy_Closing_Type__c'
        })
        .then(result => {
            this.contractType2 = [];
            for (var key in result) {
                this.contractType2.push({label:result[key], value:key});
            }
            return this.contractType2;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistAssetSection(cob){
        this.assetSectionId = undefined;
        getAssetSection({
            cob : cob
        })
        .then(result => {
            this.assetSection = [];
            for (var key in result) {
                this.assetSection.push({label:result[key], value:key});
            }
            return this.assetSection;
        })
        .catch(error => {
            console.log('error-getPicklistAssetSection:'+ error.message);
        });
    }

    getPicklistAssetSection2(cob){
        this.assetSectionId2 = undefined;
        getAssetSection({
            cob : cob
        })
        .then(result => {
            this.assetSection2 = [];
            for (var key in result) {
                this.assetSection2.push({label:result[key], value:key});
            }
            return this.assetSection2;
        })
        .catch(error => {
            console.log('error-getPicklistAssetSection2:'+ error.message);
        });
    }

    getPicklistAssetCategory(cob,assetsection){
        this.assetCategoryId = undefined;
        getAssetCategory({
            cob : cob,
            assetsection : assetsection
        })
        .then(result => {
            this.assetCategory = [];
            for (var key in result) {
                this.assetCategory.push({label:result[key], value:key});
            }
            return this.assetCategory;
        })
        .catch(error => {
            console.log('error-getPicklistAssetCategory:'+ error.message);
        });
    }

    getPicklistAssetCategory2(cob,assetsection){
        this.assetCategoryId2 = undefined;
        getAssetCategory({
            cob : cob,
            assetsection : assetsection
        })
        .then(result => {
            this.assetCategory2 = [];
            for (var key in result) {
                this.assetCategory2.push({label:result[key], value:key});
            }
            return this.assetCategory2;
        })
        .catch(error => {
            console.log('error-getPicklistAssetCategory2:'+ error.message);
        });
    }

    getPicklistCurrency(){
        this.currencyId = undefined;
        this.currencyName = undefined;
        getCurrency({})
        .then(result => {
            this.currency = [];
            for (var key in result) {
                this.currency.push({label:result[key], value:key});
            }
            //console.log('this.currency:'+JSON.stringify(this.currency));
            return this.currency;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistCurrency2(){
        this.currencyId2 = undefined;
        this.currencyName2 = undefined;
        getCurrency({})
        .then(result => {
            this.currency2 = [];
            for (var key in result) {
                this.currency2.push({label:result[key], value:key});
            }
            return this.currency2;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        });
    }

    getPicklistFireType(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'FIRE_TYPE__c'
        })
        .then(result => {
            this.fireType = [];
            for (var key in result) {
                this.fireType.push({label:result[key], value:key});
            }
            return this.fireType;
        })
        .catch(error => {
            console.log('error-getPicklistFireType:'+ error.message);
        });
    }

    getPicklistFireType2(){
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'FIRE_TYPE__c'
        })
        .then(result => {
            this.fireType2 = [];
            for (var key in result) {
                this.fireType2.push({label:result[key], value:key});
            }
            return this.fireType2;
        })
        .catch(error => {
            console.log('error-getPicklistFireType2:'+ error.message);
        });
    }

    getPicklistWording(recordid){
        getWording({
            recordId : recordid,
        })
        .then(result => {
            this.wording = [];
            for (var key in result) {
                this.wording.push({label:result[key], value:key});
            }
            return this.wording;
        })
        .catch(error => {
            console.log('error-getPicklistWording:'+ error.message);
        });
    }

    getPicklistWording2(recordid){
        getWording({
            recordId : recordid,
        })
        .then(result => {
            this.wording2 = [];
            for (var key in result) {
                this.wording2.push({label:result[key], value:key});
            }
            return this.wording2;
        })
        .catch(error => {
            console.log('error-getPicklistWording2:'+ error.message);
        });
    }

    getPremiumCalculation(){
        this.premiumCalculationId = undefined;
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'premium_calculation__c'
        })
        .then(result => {
            this.premiumCalculation = [];
            for (var key in result) {
                this.premiumCalculation.push({label:result[key], value:key});
            }
            return this.premiumCalculation;
        })
        .catch(error => {
            console.log('error-getPremiumCalculation:'+ error.message);
        });
    }

    getPremiumCalculation2(){
        this.premiumCalculationId2 = undefined;
        getPicklistSTD({
            objectName : 'Opportunity',
            fieldName : 'premium_calculation__c'
        })
        .then(result => {
            this.premiumCalculation2 = [];
            for (var key in result) {
                this.premiumCalculation2.push({label:result[key], value:key});
            }
            return this.premiumCalculation2;
        })
        .catch(error => {
            console.log('error-getPremiumCalculation2:'+ error.message);
        });
    }

    getAmountRate(curr,type){
        getRate({
            curr : curr
        })
        .then(result => {
            if(type == '1'){
                this.rate = result;
                if(this.sumInsured) this.sumInsuredIDR = this.sumInsured * this.rate;
                if(this.premium) this.premiumIDR = this.premium * this.rate;
            }else if(type == '2'){
                this.rate2 = result;
                if(this.sumInsured2) this.sumInsuredIDR2 = this.sumInsured2 * this.rate2;
                if(this.premium2) this.premiumIDR2 = this.premium2 * this.rate2;
            }
        })
        .catch(error => {
            console.log('error-getAmountRate:'+ error.message);
        });
    }
    //--> GET DATA FROM CLASS

    
    //BUTTIN SUBMIT STANDARD
    handleSubmit(event){
        const qqmember = [];
        let risksituation1 = "";
        let risksituation2 = "";
        let summary1 = "";
        let summary2 = "";
        let i = 0;
        let cob1,cob2;
        
        for(const item of this.originalMemberIds){
            qqmember.push({Id:item});
        }
        risksituation1 += "{";
        i = 0;
        this.mapInput.forEach((value, key) => {
            if(key == 'COB__c' && this.cob1 != undefined) value = this.cob1;
            if(i > 0) risksituation1 += ',';
            let cValue = '"'+value+'"';
            if(value.indexOf('{')!=-1) cValue = value;
            risksituation1 += '"'+key+'":'+cValue;
            i++;
            if(key == 'COB__c') cob1 = value;
        });
        risksituation1 += "}";
        summary1 += "{";
        i = 0;
        this.mapSummary1.forEach((value, key) => {
            if(i > 0) summary1 += ',';
            let cValue = '"'+value+'"';
            if(value.indexOf('{')!=-1) cValue = value;
            summary1 += '"'+key+'":'+cValue;
            i++;
        });
        summary1 += "}";
        risksituation2 += "{";
        i = 0;
        this.mapInput2.forEach((value, key) => {
            if(i > 0) risksituation2 += ',';
            let cValue = '"'+value+'"';
            if(value.indexOf('{')!=-1) cValue = value;
            risksituation2 += '"'+key+'":'+cValue;
            i++;
            if(key == 'COB__c') cob2 = value;
        });
        risksituation2 += "}";
        summary2 += "{";
        i = 0;
        this.mapSummary2.forEach((value, key) => {
            if(i > 0) summary2 += ',';
            let cValue = '"'+value+'"';
            if(value.indexOf('{')!=-1) cValue = value;
            summary2 += '"'+key+'":'+cValue;
            i++;
        });
        summary2 += "}";

        const data = {};
        data.id = this.recordId;
        data.opportunitytype = this.opportunityTypeId;
        data.accountId = this.accountId;
        data.requestorTypeId = this.requestorTypeId;
        data.requestorSegmentId = this.requestorSegmentId;
        data.requestorSubSegmentId = this.requestorSubSegmentId;
        data.requestorBusinessSegmentationId = this.requestorBusinessSegmentationId;
        data.requestorPipelineStatusId = this.requestorPipelineStatusId;
        data.requestorChannelId = this.requestorChannelId;
        data.requestorAddress = this.requestorAddress;
        data.insuredId = this.insuredId;
        data.insuredAddress = this.accountAddress;
        data.qqmember = qqmember;
        data.policywording = this.policyWordingName;
        data.policywordingId = this.policyWordingId;
        data.firetype = this.fireTypeId;
        data.wording = this.wordingId;
        data.wordingname = this.wordingName;
        data.premiumcalculation = this.premiumCalculationId;
        data.riskName = this.riskName;
        data.insuranceperiod = this.periodType;
        data.startdateperiod = this.startDate;
        data.enddateperiod = this.endDate;
        data.schematype = this.schemaType;
        data.transactionRows = this.adjustmentRows;
        data.description = this.description;
        data.totalyear = this._computedYears;
        data.totalmonth = this._computedMonths;
        if(data.insuranceperiod == '1'){
            data.yearperiod = this.years;
        }else{
            data.shortperiod = this.shortBasis;
            data.percentageperiod = this.isPercentageBasis ? this.percentage : undefined;
            data.rateperiod = this.calculatedRate;
        }
        data.risksituation1 = risksituation1;
        data.producttype = this.productTypeId;
        data.producttypename = this.productTypeName;
        data.contracttype = this.contractTypeId;
        data.format1 = this.dataFormat1;
        if(this.showSummary == true){
            data.assetsection = this.assetSectionId;
            data.assetcategory = this.assetCategoryId;
            data.currency = this.currencyId;
            data.rate = this.rate;
            data.sumInsured = this.sumInsured;
            data.sumInsuredIDR = this.sumInsuredIDR;
            data.premium = this.premium;
            data.premiumIDR = this.premiumIDR;
            data.summary1 = summary1;
            data.numberOfRisk = this.numberOfRisk;
            data.closedDate = this.closedDate;
            data.filequote1 = this.filequote1;
            data.fileclosing1 = this.fileclosing1;
            data.filesurvey1 = this.filesurvey1;
        }
        if(this.showMultiple == true) data.risk = 'multiple';
        else if(this.showSingle == true) data.risk = 'single';
        if(data.risk == 'multiple'){
            data.policywording2 = this.policyWordingName2;
            data.policywordingId2 = this.policyWordingId2;
            data.firetype2 = this.fireTypeId2;
            data.wording2 = this.wordingId2;
            data.wordingname2 = this.wordingName2;
            data.premiumcalculation2 = this.premiumCalculationId2;
            data.riskName2 = this.riskName2;
            data.insuranceperiod2 = this.periodType2;
            data.startdateperiod2 = this.startDate2;
            data.enddateperiod2 = this.endDate2;
            data.schematype2 = this.schemaType2;
            data.transactionRows2 = this.adjustmentRows2;
            data.description2 = this.description2;
            data.totalyear2 = this._computedYears2;
            data.totalmonth2 = this._computedMonths2;
            if(data.insuranceperiod2 == '1'){
                data.yearperiod2 = this.years2;
            }else{
                data.shortperiod2 = this.shortBasis2;
                data.percentageperiod2 = this.isPercentageBasis2 ? this.percentage2 : undefined;
                data.rateperiod2 = this.calculatedRate2;
            }
            data.risksituation2 = risksituation2;
            data.producttype2 = this.productTypeId2;
            data.producttypename2 = this.productTypeName2;
            data.contracttype2 = this.contractTypeId2;
            data.format2 = this.dataFormat2;
            if(this.showSummary2 == true){
                data.assetsection2 = this.assetSectionId2;
                data.assetcategory2 = this.assetCategoryId2;
                data.currency2 = this.currencyId2;
                data.rate2 = this.rate2;
                data.sumInsured2 = this.sumInsured2;
                data.sumInsuredIDR2 = this.sumInsuredIDR2;
                data.premium2 = this.premium2;
                data.premiumIDR2 = this.premiumIDR2;
                data.summary2 = summary2;
                data.numberOfRisk2 = this.numberOfRisk2;
                data.closedDate2 = this.closedDate2;
                data.filequote2 = this.filequote2;
                data.fileclosing2 = this.fileclosing2;
                data.filesurvey2 = this.filesurvey2;
            }
        }
        let msg1 = '';
        if(data.risksituation1 != '{}'){
            this.mapInput.forEach((value, key) => {
                if(value == undefined || value == ''){
                    for(let j=0;j<this.datafield1.length;j++){
                        if(this.datafield1[j].field == key && this.datafield1[j].type != 'Readonly' && this.datafield1[j].required == true) msg1 += '['+this.datafield1[j].label+']';
                    }
                    for(let j=0;j<this.dataDescription1.length;j++){
                        if(this.dataDescription1[j].field == key && this.dataDescription1[j].type != 'Readonly' && this.dataDescription1[j].required == true) msg1 += '['+this.dataDescription1[j].label+']';
                    }
                }else if(value.indexOf('{')!=-1){
                    let mapData = JSON.parse(value);
                    if(mapData.latitude == undefined || mapData.latitude == '' 
                        || mapData.longitude == undefined || mapData.longitude == ''
                        || mapData.latitude > 90 || mapData.latitude < -90
                        || mapData.longitude > 180 || mapData.longitude < -180){
                        for(let j=0;j<this.datafield1.length;j++){
                            if(this.datafield1[j].field == key) msg1 += '['+this.datafield1[j].label+']';
                        }
                        for(let j=0;j<this.dataDescription1.length;j++){
                            if(this.dataDescription1[j].field == key) msg1 += '['+this.dataDescription1[j].label+']';
                        }
                    }
                }
            });
        }

        let msgSummary1 = '';
        if(data.summary1 != '{}'){
            this.mapSummary1.forEach((value, key) => {
                if(value == undefined || value == ''){
                    for(let j=0;j<this.dataSummary1.length;j++){
                        if(this.dataSummary1[j].field == key && this.dataSummary1[j].required == true) msgSummary1 += '['+this.dataSummary1[j].label+']';
                    }
                }
            });
        }

        let msg2 = '';
        if(data.risk == 'multiple' && (data.risksituation2 != '{}')){
            this.mapInput2.forEach((value, key) => {
                if(value == undefined || value == ''){
                    for(let j=0;j<this.datafield2.length;j++){
                        if(this.datafield2[j].field == key && this.datafield2[j].type != 'Readonly' && this.datafield2[j].required == true) msg2 += '['+this.datafield2[j].label+']';
                    }
                    for(let j=0;j<this.dataDescription2.length;j++){
                        if(this.dataDescription2[j].field == key && this.dataDescription2[j].type != 'Readonly' && this.dataDescription2[j].required == true) msg2 += '['+this.dataDescription2[j].label+']';
                    }

                }else if(value.indexOf('{')!=-1){
                    let mapData = JSON.parse(value);
                    if(mapData.latitude == undefined || mapData.latitude == '' 
                        || mapData.longitude == undefined || mapData.longitude == ''
                        || mapData.latitude > 90 || mapData.latitude < -90
                        || mapData.longitude > 180 || mapData.longitude < -180){
                        for(let j=0;j<this.datafield2.length;j++){
                            if(this.datafield2[j].field == key) msg2 += '['+this.datafield2[j].label+']';
                        }
                        for(let j=0;j<this.dataDescription2.length;j++){
                            if(this.dataDescription2[j].field == key) msg2 += '['+this.dataDescription2[j].label+']';
                        }
                    }
                }
            });
        }

        let msgSummary2 = '';
        if(data.risk == 'multiple' && (data.summary2 != '{}')){
            this.mapSummary2.forEach((value, key) => {
                if(value == undefined || value == ''){
                    for(let j=0;j<this.dataSummary2.length;j++){
                        if(this.dataSummary2[j].field == key && this.dataSummary2[j].required == true) msgSummary2 += '['+this.dataSummary2[j].label+']';
                    }
                }
            });
        }

        let file1, file2, file3, file4, file5, file6;
        if(data.format1 === 'Summary'){
            if(data.filequote1.length === 0) file1 = 'no';
            //if(data.fileclosing1.length === 0) file2 = 'no';
            //if(data.filesurvey1.length === 0) file3 = 'no';
        }

        if(data.risk == 'multiple' && (data.format2 === 'Summary')){
            if(data.filequote2.length === 0) file4 = 'no';
            //if(data.fileclosing2.length === 0) file5 = 'no';
            //if(data.filesurvey2.length === 0) file6 = 'no';
        }
        
        console.log('data (before):'+JSON.stringify(data));
        if(data.opportunitytype === undefined || data.opportunitytype === ''){
            this.errorMessage('Please Select Opportunity Type!');
        }else if(data.accountId === undefined || data.accountId === ''){
            this.errorMessage('Please Select Account Name!');
        }else if(data.requestorTypeId === undefined || data.requestorTypeId === ''){
            this.errorMessage('Please Select Account Type!');
        }else if(data.requestorSegmentId === undefined || data.requestorSegmentId === ''){
            this.errorMessage('Please Select Account Segment!');
        }else if(data.requestorSubSegmentId === undefined || data.requestorSubSegmentId === ''){
            this.errorMessage('Please Select Account Sub Segment!');
        }else if(data.requestorBusinessSegmentationId === undefined || data.requestorBusinessSegmentationId === ''){
            this.errorMessage('Please Select Account Business Segmentation!');
        }else if(data.requestorPipelineStatusId === undefined || data.requestorPipelineStatusId === ''){
            this.errorMessage('Please Select Account Pipeline Status!');
        }else if(data.requestorPipelineStatusId == 'Channel' && (data.requestorChannelId === undefined || data.requestorChannelId === '')){
            this.errorMessage('Please Select Account Channel!');
        }else if(data.requestorAddress === undefined || data.requestorAddress === ''){
            this.errorMessage('Please Select Account Address!');
        }else if(data.insuredId === undefined || data.insuredId === ''){
            this.errorMessage('Please Select The Insured Name!');
        }else if(data.insuredAddress === undefined || data.insuredAddress === ''){
            this.errorMessage('Please input The Insured Address!');
        //}else if(data.qqmember.length === 0){
            //this.errorMessage('Please Add QQ Member!');
        }else if(data.risk === undefined || data.risk === ''){
            this.errorMessage('Please Choose Single / Multiple!');
        }else if(this.cob1 === undefined || this.cob1 === ''){
            this.errorMessage('Please Select Line (COB)!');
        }else if(data.producttype === undefined || data.producttype === ''){
            this.errorMessage('Please Select Product Type!');
        }else if(data.policywording === undefined || data.policywording === ''){
            this.errorMessage('Please input Wording Type!');
        //}else if(this.showIAR === true && (data.firetype === undefined || data.firetype === '')){
        //    this.errorMessage('Please input Fire Type!');
        }else if(this.showIAR === true && (data.wording === undefined || data.wording === '')){
            this.errorMessage('Please input Wording Standard!');
        }else if(this.showPremium == false && (data.insuranceperiod === undefined || data.insuranceperiod === '' || data.insuranceperiod  == null)){
            this.errorMessage('Please input Insurance Period!');
        }else if(data.insuranceperiod == '1' && (data.yearperiod === undefined || data.yearperiod === '' || data.yearperiod === null)){ // Annual
            this.errorMessage('Please input Number of Years!');
        }else if(data.insuranceperiod == '2' && (data.shortperiod === undefined || data.shortperiod === '' || data.shortperiod === null)){ // Short
            this.errorMessage('Please input Short-Period Basis!');
        }else if(data.insuranceperiod == '2' && data.shortperiod === '1' && (data.percentageperiod === undefined || data.percentageperiod === '' || data.percentageperiod === null)){ // Short & Percentage
            this.errorMessage('Please input Percentage (%)!');
        }else if(data.startdateperiod === undefined || data.startdateperiod === '' || data.startdateperiod === null){
            this.errorMessage('Please input Start Date Period!');
        }else if(data.enddateperiod === undefined || data.enddateperiod === '' || data.enddateperiod === null){
            this.errorMessage('Please input End Date Period!');
        }else if(data.riskName === undefined || data.riskName === ''){
            this.errorMessage('Please input Risk Name!');
        }else if(msg1 != ''){
            this.errorMessage('Please Input Risk : '+ msg1 +'!');
        }else if(data.format1 === undefined || data.format1 === ''){
            this.errorMessage('Please Choose Summary / Specific!'); 
        }else if(data.format1 === 'Summary' && (data.assetsection === '' || data.assetsection === undefined)){
            this.errorMessage('Please Input Asset Section!'); 
        }else if(data.format1 === 'Summary' && (data.currency === '' || data.currency === undefined)){
            this.errorMessage('Please Input Currency!'); 
        }else if(data.format1 === 'Summary' && (data.sumInsured === '' || data.sumInsured === undefined)){
            this.errorMessage('Please Input Top Risk Sum Insured!');  
        }else if(data.format1 === 'Summary' && (data.sumInsured.length > 16)){
            this.errorMessage('Please Change Top Risk Sum Insured, max 16 digit!');
        }else if(data.format1 === 'Summary' && (data.sumInsuredIDR.toString().length > 16)){
            this.errorMessage('Please Change Top Risk Sum Insured IDR, max 16 digit!');
        }else if(data.format1 === 'Summary' && (data.premium === '' || data.premium === undefined)){
            this.errorMessage('Please Input Top Gross Premium!'); 
        }else if(data.format1 === 'Summary' && (data.premium.length > 16)){
            this.errorMessage('Please Change Top Gross Premium, max 16 digit!');
        }else if(data.format1 === 'Summary' && (data.premiumIDR.toString().length > 16)){
            this.errorMessage('Please Change Top Gross Premium IDR, max 16 digit!');
        }else if(msgSummary1 != ''){
            this.errorMessage('Please Input Opportunity Format : '+ msgSummary1 +'!');
        }else if(data.format1 === 'Summary' && (data.numberOfRisk === '' || data.numberOfRisk === undefined)){
            this.errorMessage('Please Input Quantity Of Risk!');
        }else if(data.format1 === 'Summary' && (data.closedDate === '' || data.closedDate === undefined)){
            this.errorMessage('Please Input Expected Date Of Closing!');
        }else if(file1 === 'no'){
            this.errorMessage('Please Upload Quotation & Supporting Document!');
        //}else if(file2 === 'no'){
        //    this.errorMessage('Please Upload Closing Slip!');
        //}else if(file3 === 'no'){
        //    this.errorMessage('Please Upload Survey Report!');
        }else if(data.risk == 'multiple' && (this.cob2 === undefined || this.cob2 === '')){
            this.errorMessage('Please Select Line (COB) (2)!');
        }else if(data.risk == 'multiple' && (data.producttype2 === undefined || data.producttype2 === '')){
            this.errorMessage('Please Select Product Type (2)!');
        }else if(data.risk == 'multiple' && (data.policywording2 === undefined || data.policywording2 === '')){
            this.errorMessage('Please input Wording Type (2)!');
        //}else if(data.risk == 'multiple' && this.showIAR2 === true && (data.firetype2 === undefined || data.firetype2 === '')){
        //    this.errorMessage('Please input Fire Type (2)!');
        }else if(data.risk == 'multiple' && this.showIAR2 === true && (data.wording2 === undefined || data.wording2 === '')){
            this.errorMessage('Please input Wording Standard (2)!');
        }else if(data.risk == 'multiple' && this.showPremium2 == false && (data.insuranceperiod2 === undefined || data.insuranceperiod2 === '' || data.insuranceperiod2 === null)){
            this.errorMessage('Please input Insurance Period (2)!');
        }else if(data.risk == 'multiple' && data.insuranceperiod2 == '1' && (data.yearperiod2 === undefined || data.yearperiod2 === '' || data.yearperiod2 === null)){ // Annual
            this.errorMessage('Please input Number of Years (2)!');
        }else if(data.risk == 'multiple' && data.insuranceperiod2 == '2' && (data.shortperiod2 === undefined || data.shortperiod2 === '' || data.shortperiod2 === null)){ // Short
            this.errorMessage('Please input Short-Period Basis (2)!');
        }else if(data.risk == 'multiple' && data.insuranceperiod2 == '2' && data.shortperiod2 === '1' && (data.percentageperiod2 === undefined || data.percentageperiod2 === '' || data.percentageperiod2 === null)){ // Short & Percentage
            this.errorMessage('Please input Percentage (%) (2)!');
        }else if(data.risk == 'multiple' && (data.startdateperiod2 === undefined || data.startdateperiod2 === '' || data.startdateperiod2 === null)){
            this.errorMessage('Please input Start Date Period (2)!');
        }else if(data.risk == 'multiple' && (data.enddateperiod2 === undefined || data.enddateperiod2 === '' || data.enddateperiod2 === null)){
            this.errorMessage('Please input End Date Period (2)!');
        }else if(data.risk == 'multiple' && (data.riskName2 === undefined || data.riskName2 === '')){
            this.errorMessage('Please input Risk Name (2)!');
        }else if(data.risk == 'multiple' && (msg2 != '')){
            this.errorMessage('Please Input Risk (2): '+ msg2 +'!');
        }else if(data.risk == 'multiple' && (data.format2 === undefined || data.format2 === '')){
            this.errorMessage('Please Choose Summary / Specific (2)!'); 
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.assetsection2 === '' || data.assetsection2 === undefined))){
            this.errorMessage('Please Input Asset Section (2)!'); 
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.currency2 === '' || data.currency2 === undefined))){
            this.errorMessage('Please Input Currency (2)!'); 
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.sumInsured2 === '' || data.sumInsured2 === undefined))){
            this.errorMessage('Please Input Top Risk Sum Insured (2)!');  
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.sumInsured2.length > 16))){
            this.errorMessage('Please Change Top Risk Sum Insured (2), max 16 digit!'); 
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.sumInsuredIDR2.toString().length > 16))){
            this.errorMessage('Please Change Top Risk Sum Insured IDR (2), max 16 digit!');   
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.premium2 === '' || data.premium2 === undefined))){
            this.errorMessage('Please Input Top Gross Premium (2)!'); 
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.premium2.length > 16))){
            this.errorMessage('Please Change Top Gross Premium (2), max 16 digit!'); 
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.premiumIDR2.toString().length > 16))){
            this.errorMessage('Please Change Top Gross Premium IDR (2), max 16 digit!'); 
        }else if(data.risk == 'multiple' && (msgSummary2 != '')){
            this.errorMessage('Please Input Opportunity Format (2): '+ msgSummary2 +'!');
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.numberOfRisk2 === '' || data.numberOfRisk2 === undefined))){
            this.errorMessage('Please Input Quantity Of Risk (2)!');
        }else if(data.risk == 'multiple' && (data.format2 === 'Summary' && (data.closedDate2 === '' || data.closedDate2 === undefined))){
            this.errorMessage('Please Input Expected Date Of Closing (2)!');
        }else if(file4 === 'no'){
            this.errorMessage('Please Upload Quotation & Supporting Document (2)!');
        //}else if(file5 === 'no'){
        //    this.errorMessage('Please Upload Closing Slip (2)!');
        //}else if(file6 === 'no'){
        //    this.errorMessage('Please Upload Survey Report (2)!');
        }else{
            // data validation before submit
            if(data.insuranceperiod  == '2' && data.shortperiod == '1'){ // Short & Percentage
                data.rateperiod = null;
                data.yearperiod = null;
                data.totalyear = null;
            }else if(data.insuranceperiod == '2' && data.shortperiod == '2'){ // Short & Pro-Rata Basis
                data.percentageperiod = null;
                data.yearperiod = null;
                data.totalyear = null;
            }else if(this.periodType == '1'){
                data.rateperiod = null;
            }

            if(data.risk == 'multiple'){
                if(data.insuranceperiod2  == '2' && data.shortperiod2 == '1'){ // Short & Percentage
                    data.rateperiod2 = null;
                    data.yearperiod2 = null;
                    data.totalyear2 = null;
                }else if(data.insuranceperiod2 == '2' && data.shortperiod2 == '2'){ // Short & Pro-Rata Basis
                    data.percentageperiod2 = null;
                    data.yearperiod2 = null;
                    data.totalyear2 = null;
                }else if(this.periodType2 == '1'){
                    data.rateperiod2 = null;
                }
            }

            if(this.recordId != undefined){
                this.submitSaveData(data);
            }else{
                this.submitIsValidateDouble(data);
            }
        }
    }

    //BUTTON SUBMIT MOU
    handleSubmitMOU(event){
        console.log('handleSubmitMOU');
        const qqmember = [];
        let risk1 = "";
        let i = 0;
        for(const item of this.originalMemberIds){
            qqmember.push({Id:item});
        }
        risk1 += "{";
        i = 0;
        this.mapInputMOU1.forEach((value, key) => {
            if(i > 0) risk1 += ',';
            let cValue = '"'+value+'"';
            if(value.indexOf('{')!=-1) cValue = value;
            risk1 += '"'+key+'":'+cValue;
            i++;
        });
        risk1 += "}";

        const data = {};
        data.id = this.recordId;
        data.opportunitytype = this.opportunityTypeId;
        data.accountId = this.accountId;
        data.requestorTypeId = this.requestorTypeId;
        data.requestorSegmentId = this.requestorSegmentId;
        data.requestorSubSegmentId = this.requestorSubSegmentId;
        data.requestorBusinessSegmentationId = this.requestorBusinessSegmentationId;
        data.requestorPipelineStatusId = this.requestorPipelineStatusId;
        data.requestorChannelId = this.requestorChannelId;
        data.requestorAddress = this.requestorAddress;
        data.insuredId = this.insuredId;
        data.insuredAddress = this.accountAddress;
        data.qqmember = qqmember;
        data.cob = this.cob1;
        data.policywording = this.policyWordingName;
        data.policywordingId = this.policyWordingId;
        data.firetype = this.fireTypeId;
        data.wording = this.wordingId;
        data.wordingname = this.wordingName;
        data.premiumcalculation = this.premiumCalculationId;
        data.riskName = this.riskName;
        data.insuranceperiod = this.periodType;
        data.startdateperiod = this.startDate;
        data.enddateperiod = this.endDate;
        data.schematype = this.schemaType;
        data.transactionRows = this.adjustmentRows;
        data.totalyear = this._computedYears;
        data.totalmonth = this._computedMonths;
        if(data.insuranceperiod == '1'){
            data.yearperiod = this.years;
        }else{
            data.shortperiod = this.shortBasis;
            data.percentageperiod = this.isPercentageBasis ? this.percentage : undefined;
            data.rateperiod = this.calculatedRate;
        }
        data.producttype = this.productTypeId;
        data.producttypename = this.productTypeName;
        data.contracttype = this.contractTypeId;
        if(this.showMultiple == true) data.risk = 'multiple';
        else if(this.showSingle == true) data.risk = 'single';
        data.risk1 = risk1;
        data.mouId1 = this.mouId1;
        data.asset1 = this.dataAssetMOU1;
        data.coverage1 = this.dataCoverageMOU1;
        /*if(data.risk == 'multiple'){
            data.policywording2 = this.policyWordingName2;
            data.policywordingId2 = this.policyWordingId2;
            data.firetype2 = this.fireTypeId2;
            data.wording2 = this.wordingId2;
            data.wordingname2 = this.wordingName2;
            data.premiumcalculation2 = this.premiumCalculationId2;
            data.riskName2 = this.riskName2;
            data.insuranceperiod2 = this.periodType2;
            data.startdateperiod2 = this.startDate2;
            data.enddateperiod2 = this.endDate2;
            data.schematype2 = this.schemaType2;
            data.transactionRows2 = this.adjustmentRows2;
            data.totalyear2 = this._computedYears2;
            data.totalmonth2 = this._computedMonths2;
            if(data.insuranceperiod2 == '1'){
                data.yearperiod2 = this.years2;
            }else{
                data.shortperiod2 = this.shortBasis2;
                data.percentageperiod2 = this.isPercentageBasis2 ? this.percentage2 : undefined;
                data.rateperiod2 = this.calculatedRate2;
            }
            data.producttype2 = this.productTypeId2;
            data.producttypename2 = this.productTypeName2;
            data.contracttype2 = this.contractTypeId2;
            data.assetsection2 = this.assetSectionId2;
            data.assetcategory2 = this.assetCategoryId2;
            data.currency2 = this.currencyId2;
            data.rate2 = this.rate2;
            data.sumInsured2 = this.sumInsured2;
            data.sumInsuredIDR2 = this.sumInsuredIDR2;
        }*/

        let msg1 = '';
        if(data.risk1 != '{}'){
            this.mapInputMOU1.forEach((value, key) => {
                if(value == undefined || value == ''){
                    for(let j=0;j<this.datafieldMOU1.length;j++){
                        let field = this.datafieldMOU1[j].data;
                        for(let i=0;i<field.length;i++){
                            if(field[i].datafield == key && field[i].datatype != 'Readonly' && field[i].datarequired == true) msg1 += '['+field[i].datalabel+']';
                        } 
                    }
                }else if(value.indexOf('{')!=-1){
                    let mapData = JSON.parse(value);
                    if(mapData.latitude == undefined || mapData.latitude == '' 
                        || mapData.longitude == undefined || mapData.longitude == ''
                        || mapData.latitude > 90 || mapData.latitude < -90
                        || mapData.longitude > 180 || mapData.longitude < -180){
                        for(let j=0;j<this.datafieldMOU1.length;j++){
                            let field = this.datafieldMOU1[j].data;
                            for(let i=0;i<field.length;i++){
                                if(field[i].datafield == key) msg1 += '['+field[i].datalabel+']';
                            }
                        }
                    }
                }
            });
        }

        console.log('data:'+JSON.stringify(data));

        if(data.opportunitytype === undefined || data.opportunitytype === ''){
            this.errorMessage('Please Select Opportunity Type!');
        }else if(data.accountId === undefined || data.accountId === ''){
            this.errorMessage('Please Select Account Name!');
        }else if(data.requestorTypeId === undefined || data.requestorTypeId === ''){
            this.errorMessage('Please Select Account Type!');
        }else if(data.requestorSegmentId === undefined || data.requestorSegmentId === ''){
            this.errorMessage('Please Select Account Segment!');
        }else if(data.requestorSubSegmentId === undefined || data.requestorSubSegmentId === ''){
            this.errorMessage('Please Select Account Sub Segment!');
        }else if(data.requestorBusinessSegmentationId === undefined || data.requestorBusinessSegmentationId === ''){
            this.errorMessage('Please Select Account Business Segmentation!');
        }else if(data.requestorPipelineStatusId === undefined || data.requestorPipelineStatusId === ''){
            this.errorMessage('Please Select Account Pipeline Status!');
        }else if(data.requestorPipelineStatusId == 'Channel' && (data.requestorChannelId === undefined || data.requestorChannelId === '')){
            this.errorMessage('Please Select Account Channel!');
        }else if(data.requestorAddress === undefined || data.requestorAddress === ''){
            this.errorMessage('Please Select Account Address!');
        }else if(data.insuredId === undefined || data.insuredId === ''){
            this.errorMessage('Please Select The Insured Name!');
        }else if(data.insuredAddress === undefined || data.insuredAddress === ''){
            this.errorMessage('Please input The Insured Address!');
        }else if(data.cob === undefined || data.cob === ''){
            this.errorMessage('Please Select Line (COB)!');
        }else if(data.producttype === undefined || data.producttype === ''){
            this.errorMessage('Please Select Product Type!');
        }else if(data.policywording === undefined || data.policywording === ''){
            this.errorMessage('Please input Wording Type!');
        }else if(this.showIAR === true && (data.wording === undefined || data.wording === '')){
            this.errorMessage('Please input Wording Standard!');
        }else if(data.insuranceperiod === undefined || data.insuranceperiod === ''){
            this.errorMessage('Please input Insurance Period!');
        }else if(data.insuranceperiod == '1' && (data.yearperiod === undefined || data.yearperiod === '' || data.yearperiod === null)){ // Annual
            this.errorMessage('Please input Number of Years!');
        }else if(data.insuranceperiod == '2' && (data.shortperiod === undefined || data.shortperiod === '' || data.shortperiod === null)){ // Short
            this.errorMessage('Please input Short-Period Basis!');
        }else if(data.insuranceperiod == '2' && data.shortperiod === '1' && (data.percentageperiod === undefined || data.percentageperiod === '' || data.percentageperiod === null)){ // Short & Percentage
            this.errorMessage('Please input Percentage (%)!');
        }else if(data.startdateperiod === undefined || data.startdateperiod === '' || data.startdateperiod === null){
            this.errorMessage('Please input Start Date Period!');
        }else if(data.enddateperiod === undefined || data.enddateperiod === '' || data.enddateperiod === null){
            this.errorMessage('Please input End Date Period!');
        }else if(data.riskName === undefined || data.riskName === ''){
            this.errorMessage('Please input Risk Name!');
        }else if(msg1 != ''){
            this.errorMessage('Please Input Risk : '+ msg1 +'!');
        }else if(data.asset1.length == 0){
            this.errorMessage('Please Add Asset!');
        }else if(data.coverage1.length == 0){
            this.errorMessage('Please Add Coverage!');
        }else{
            if(data.insuranceperiod  == '2' && data.shortperiod == '1'){ // Short & Percentage
                data.rateperiod = null;
                data.yearperiod = null;
                data.totalyear = null;
            }else if(data.insuranceperiod == '2' && data.shortperiod == '2'){ // Short & Pro-Rata Basis
                data.percentageperiod = null;
                data.yearperiod = null;
                data.totalyear = null;
            }else if(this.periodType == '1'){
                data.rateperiod = null;
            }

            /*if(data.risk == 'multiple'){
                if(data.insuranceperiod2  == '2' && data.shortperiod2 == '1'){ // Short & Percentage
                    data.rateperiod2 = null;
                    data.yearperiod2 = null;
                    data.totalyear2 = null;
                }else if(data.insuranceperiod2 == '2' && data.shortperiod2 == '2'){ // Short & Pro-Rata Basis
                    data.percentageperiod2 = null;
                    data.yearperiod2 = null;
                    data.totalyear2 = null;
                }else if(this.periodType2 == '1'){
                    data.rateperiod2 = null;
                }
            }*/
            this.isLoading = true;
            saveDataMOU({ data: JSON.stringify(data)})
            .then(result => {
                this.isLoading = false;
                console.log('result:'+result);

                if(result.indexOf('006')!=-1){
                    this.actionsave = 'yes';
                    this.successMessage('Opportunity has been saved!');
                    this.refreshTabPage();
                    if(this.recordId != undefined) this.dispatchEvent(new CloseActionScreenEvent());
                    else{
                        if(this.accountId != undefined) window.location.href = "/"+result;
                        this.navigateToRecordViewPage(result);
                    }
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
    }

    //BUTTON SUBMIT REALISASI
    handleSubmitRealisasi(event){
        console.log('handleSubmitRealisasi');
    }

    //VALIDATE FOR DOUBLE PROSPECT
    submitIsValidateDouble(data){
        this.isLoading = true;
        getValidateDouble({ data: JSON.stringify(data)})
            .then(result => {
                this.isLoading = false;
                this.showDouble = result;
                if(this.showDouble == false){
                    this.submitSaveData(data);
                }else{
                    LightningConfirm.open({
                        message: 'This new opportunity has double prospect. Do you still want to proceed ?',
                        //theme defaults to "default"
                        label: 'Warning', // this is the header text
                        variant : 'headerless'
                    }).then((result) => {
                        //result is true if OK was clicked
                        if(result == true){
                            console.log('yes');
                            this.submitSaveData(data);
                        }
                    });
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('Error-submitIsValidateDouble:'+error.body.message);
                this.errorMessage('Error: '+error.body.message);
            });
    }

    //FUNCTION CALL SAVEDATA
    submitSaveData(data){
        console.log('data (after validation):'+JSON.stringify(data));
        console.log('do save-data');
        this.isLoading = true;
        saveData({ data: JSON.stringify(data)})
            .then(result => {
                this.isLoading = false;
                console.log('result:'+result);

                if(result.indexOf('006')!=-1){
                    this.actionsave = 'yes';
                    this.successMessage('Opportunity has been saved!');
                    this.refreshTabPage();
                    if(this.recordId != undefined) this.dispatchEvent(new CloseActionScreenEvent());
                    else{
                        if(this.accountId != undefined) window.location.href = "/"+result;
                        this.navigateToRecordViewPage(result);
                    }
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

    //ERROR MESSAGE
    errorMessage(msg){
        if(this.account == undefined && this.recordId == undefined){
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: msg, variant: 'error' }));
        }else{ 
            LightningAlert.open({message: msg,theme: 'error',label: 'Error!'});
        }
    }
    //SUCCESS MESSAGE
    successMessage(msg){
        if(this.account == undefined && this.recordId == undefined){
            this.dispatchEvent(new ShowToastEvent({ title: 'Success', message: msg, variant: 'success' }));   
        }else{
            LightningAlert.open({message: msg,theme: 'success',label: 'Success!'});
        }            
    }
    //REFRESH TAB
    async refreshTabPage(){
        await refreshTab(this.tabId, {
            includeAllSubtabs: true
        });
    }
    //NAVIGATE TO RECORD VIEW PAGE
    navigateToRecordViewPage(recordId) {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: recordId,
                objectApiName: "Opportunity",
                actionName: "view",
            },
        });
    }
    //NAVIGATE TO URL
    navigateToURL(url) {
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url: url,
            },
        });
    }
}