import { LightningElement,api,wire,track } from 'lwc';
import getPermission from '@salesforce/apex/ClsApprovalMasterData.getPermission';
import getMasterData from '@salesforce/apex/ClsApprovalMasterData.getMasterData';
import approveData from '@salesforce/apex/ClsApprovalMasterData.approveData';
import rejectData from '@salesforce/apex/ClsApprovalMasterData.rejectData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getFocusedTabInfo, setTabLabel } from 'lightning/platformWorkspaceApi';
import LightningConfirm from 'lightning/confirm';

const columns = [
    //{ label: 'Id', fieldName: 'Id' },
    {   label: 'Name', 
        fieldName: 'nameURL',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true},
];

const columns1 = [
    {   label: 'Name', 
        fieldName: 'nameURL',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true},
    { label: 'BSN', fieldName: 'BSN__c' },
    { label: 'CURR', fieldName: 'CURRENCY_CODE__c' },
    { label: 'LIMIT', fieldName: 'LIMIT_AMOUNT__c', type: 'number'},
    { label: 'BRANCH', fieldName: 'BRANCH_ID__c' },
    { label: 'RISK_CODE', fieldName: 'RISK_CODE__c' },
    { label: 'AGE', fieldName: 'AGE__c' },
    { label: 'TONNAGE', fieldName: 'TONNAGE__c' },
    { label: 'RISK_TYPE', fieldName: 'RISK_TYPE__c' },
    { label: 'Business Type', fieldName: 'Business_Type__c' },
    { label: 'Product Segment', fieldName: 'Product_Segment__c' },
    { label: 'Created Date', fieldName: 'CREATED_DATE__c',type: 'date'},
];

const columns2 = [
    {   label: 'Name', 
        fieldName: 'nameURL',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true},
    { label: 'BSN', fieldName: 'BSN__c' },
    { label: 'TREATY YEAR', fieldName: 'TREATY_YEAR__c' },
    { label: 'RISK CATEGORY', fieldName: 'RISK_CATEGORY__c' },
    { label: 'RISK CLASS', fieldName: 'RISK_CLASS__c' },
    { label: 'EQ ZONE', fieldName: 'EQ_ZONE__c' },
    { label: 'UR AMOUNT', fieldName: 'UR_AMOUNT__c',type:'number' },
    { label: 'XL AMOUNT', fieldName: 'XL_AMOUNT__c',type:'number' },
    { label: 'QS PCT', fieldName: 'QS_PCT__c',type:'number' },
    { label: 'QS AMOUNT', fieldName: 'QS_AMOUNT__c',type:'number' },
    { label: 'SP1 LINES', fieldName: 'SP1_LINES__c' },
    { label: 'SP1 AMOUNT', fieldName: 'SP1_AMOUNT__c',type:'number' },
    { label: 'FACOBLIG AMOUNT', fieldName: 'FACOBLIG_AMOUNT__c',type:'number' },
    { label: 'CURR', fieldName: 'CURRENCY_CODE__c' },
    { label: 'EFFECTIVE DATE', fieldName: 'EFFECTIVE_DATE__c', type:'date' },
    { label: 'CreatedBy', fieldName: 'createdBy' },
];

const columns3 = [
    {   label: 'Name', 
        fieldName: 'nameURL',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, 
        target: '_blank'},
        sortable: true},
    { label: 'Product Segment', fieldName: 'Product_Segment__c' },
    { label: 'Product Line', fieldName: 'Product_Line__c' },
    { label: 'Product Type', fieldName: 'Product_Type__c'},
    { label: 'Area', fieldName: 'Area__c' },
    { label: 'Branch Name', fieldName: 'Branch_Name__c' },
    { label: 'USER PIC', fieldName: 'USER_PIC__c' }
];

export default class LwcApprovalMasterData extends LightningElement {
    @track showData;
    @track value = '';
    @track typevalue = '';
    @track authvalue = '';
    @track data = [];
    @track columns;
    @track tabId;

    @track page = 1;
    @track pageSize = 10; // Number of records to be displayed in the page
    @track totalRecords = 0;
    @track totalPages = 0;
    @track paginatedData = []; // To store sliced data

    get options() {
        return [
            { label: '', value: '' },
            { label: 'Approval Limit Underwriting', value: 'Approval_Limit_Underwriting' },
            { label: 'Approval Limit Claim', value: 'Approval_Limit_Claim' },
            // { label: 'Treaty Capacity', value: 'Treaty_Capacity' },
            { label: 'Policy Distribution', value: 'Policy_Distribution' },
        ];
    }

    connectedCallback() {
        getFocusedTabInfo().then(tabInfo => {
            this.tabId = tabInfo.tabId;
            // Optionally, set an initial label
            setTabLabel(this.tabId, 'Approval Master Data');
        });
        this.onLoadGetPermission();
    }

    onLoadGetPermission(){
        getPermission({})
        .then(result => {
            this.showData = result;
        })
        .catch(error => {
            console.log('error:'+ error.message);
        }); 
    }

    handleChange(event) {
        let type = event.detail.value;
        if(type == 'Approval_Limit_Underwriting'){
            this.typevalue = 'Approval_Limit';
            this.authvalue = 'UW';
            this.columns = columns1;
        }else if(type == 'Approval_Limit_Claim'){
            this.typevalue = 'Approval_Limit';
            this.authvalue = 'CL';
            this.columns = columns1;
        }else if(type == 'Treaty_Capacity'){
            this.typevalue =  event.detail.value;
            this.authvalue = null;
            this.columns = columns2;
        }else if(type == 'Policy_Distribution'){
            this.typevalue =  event.detail.value;
            this.authvalue = null;
            this.columns = columns3;
        }else{
            this.typevalue = event.detail.value;
            this.authvalue = null;
            this.columns = [];
        }
        getMasterData({
                strType: this.typevalue,
                strAuth: this.authvalue
            })
            .then(result => {
                let nameURL;
                let createdBy;
                console.log('result:'+JSON.stringify(result));
                this.data = result.map(row =>{
                    nameURL = `/${row.Id}`;
                    createdBy = row.CreatedBy.Name;
                    return {...row , nameURL,createdBy} 
                })
                this.totalRecords = result.length;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.updatePaginatedData();
            })
            .catch(error => {
            });
    }

    get _disablePrevious(){
        return this.page === 1 ? true : false;
    }

    get _disableNext(){
        if(this.totalPages == 0){
            return true;
        }else{
            return this.page === this.totalPages ? true : false;
        }
    }

    updatePaginatedData() {
        const startIndex = (this.page - 1) * this.pageSize; // Calculates the start index of paginated data
        const endIndex = startIndex + this.pageSize; // Calculates the end index of paginated data
        this.paginatedData = this.data.slice(startIndex, endIndex);
    }

    handlePrevious() {
        if (this.page > 1) {
        this.page--;
        this.updatePaginatedData();
        }
    }

    handleNext() {
        if (this.page < this.totalPages) {
        this.page++;
        this.updatePaginatedData();
        }
    }

    handleApprove() {
        if(this.data.length == 0){
            this.dispatchEvent(new 
                ShowToastEvent({
                    title: 'Warning!!',
                    message: 'Master data not found!' 
                })
            );
        }else{
            approveData({
                strType: this.typevalue,
                strAuth: this.authvalue
            })
            .then(result => {
                this.data = [];
                this.typevalue = '';
                this.value = '';
                this.authvalue = '';
                this.refreshApex();
                this.dispatchEvent(new 
                    ShowToastEvent({
                        title: 'Success!!',
                        message: 'Master Data has been approved!!',
                        variant: 'success'
                    }), 
                );
            })
            .catch(error => {
                this.error = error.message;
            });
        }
    }

    handleReject(){
        if(this.data.length == 0){
            this.dispatchEvent(new 
                ShowToastEvent({
                    title: 'Warning!!',
                    message: 'Master data not found!' 
                })
            );
        }else{
            LightningConfirm.open({
                message: 'Are you sure want to reject this approval?',
                //theme defaults to "default"
                label: 'Warning', // this is the header text
                variant : 'headerless'
            }).then((result) => {
                //result is true if OK was clicked
                if(result == true){
                    console.log('reject');
                    rejectData({
                        strType: this.typevalue,
                        strAuth: this.authvalue
                    })
                    .then(rs => {
                        console.log('rs:'+rs);
                        this.data = [];
                        this.paginatedData = [];
                        this.typevalue = '';
                        this.value = '';
                        this.authvalue = '';
                        this.dispatchEvent(new 
                            ShowToastEvent({
                                title: 'Success!!',
                                message: 'Master Data has been rejected!!',
                                variant: 'success'
                            }), 
                        );
                    })
                    .catch(error => {
                        this.error = error.message;
                        console.log('error:'+this.error);
                    });
                }
            });
        }
    }

}