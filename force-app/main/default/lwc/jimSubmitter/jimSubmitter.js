/*
 * Copyright (c) 2024, developed-by: Jimmy Lumbantobing.
 * All rights reserved.
 * SPDX-License-Identifier: MIT
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/MIT
 */

import { LightningElement, api, wire, track } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import Jim_Compo_Channel from '@salesforce/messageChannel/Jim_Channel__c';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class JimSubmitter extends LightningElement {
    @api recordId;
    @api objectApiName;
    error;

    @api isDebug = false;
    @api objectName;
    @api objectRecordId;
    @api buttonCentered = false;
    @api btnResetLabel = "Reset";
    @api btnSaveLabel = "Save";
    btnSaveDisabled = true;
    btnIsHidden = false;
    
    @wire(MessageContext) messageContext;
    @track compos=[];
    wiredRecordId;
    wiredObjectName;
    jimButtonClass ="slds-grid slds-grid_align-end slds-m-top_small"; 
    
    formStatus;
    optionalFields = [];
    //rst;
    //rsi;

    //-----------------------------------------------------
    connectedCallback() {
        if(!this.objectRecordId) this.objectRecordId = this.recordId;
        if(!this.objectName    ) this.objectName = this.objectApiName; 
        if(!this.buttonCentered) {
            this.jimButtonClass = "slds-grid slds-grid_align-end slds-m-top_small"; 
        }else{
            this.jimButtonClass = "slds-grid slds-grid_align-center slds-m-top_small"; 
        }
        
        this.subscribeToMessageChannel();
        this.publishToMessageChannel(this.objectName+".Status", "Ready");
        //__form.ready >>>
        //__compo.register <<<

        console.log('|__form.connectedCallback() :  this.objectName  => ', this.objectName);
        //@wire wiredObjectName :  Survey__c
        //@wire wiredRecordId :  a08MR0000067jrOYAQ

        this.formReady();
        console.log('------------------------');

        //__wiredInfo()
        //__.__form.objectInfo >>>
        //__wireRecordData()
        //__.__form.defaultValue >>>
    }
    
    renderedCallback(){
        //console.log('form.renderedCallback() :  this => ', this);
    }

    //-----------------------------------------------------

    publishToMessageChannel(context, value, status) {
        const message = {
            sender: "form",
            context: context,
            value: value,
            status : status
        };
        console.log(('%cform ==> ** ').padEnd(40,' '), 'color: #40b5bc', JSON.stringify(message)); //this.hostElement
        publish(
            this.messageContext, 
            Jim_Compo_Channel, 
            message
        );
    }

    //----------------------------------------------------
    subscription = null;
    subscribeToMessageChannel() {
        if(!this.subscription) this.subscription = subscribe(
            this.messageContext,
            Jim_Compo_Channel,
            (message) => this.handleMessage(message)
        );
    }

    chainSender;
    handleMessage(message) {
        let msgSender = (message.sender.indexOf('.'))? message.sender.split('.')[1] : message.sender;
        if(message.sender!=="form"){
            console.log(('%cform <== '+msgSender).padEnd(40,' '), 'color: #FE8A18', message);
        }else if(message.context == this.objectName+".Register"){
            console.log(('%cform <== '+msgSender).padEnd(40,' '), 'color: #FE8A18', message);
        }else if(message.context == this.objectName+".Status"){
            console.log(('%cform <== '+msgSender).padEnd(40,' '), 'color: #FE8A18', message);
        }else{
            console.log(('%cform(else) <== '+msgSender + ' ' + JSON.stringify(message)).padEnd(40,' '), 'color: #FFBBBB');
        }

        if(message.context == this.objectName+".Register"){
            const objExist = this.compos.find((cmp) => {
                return (cmp.fieldName==message.value)
            });

            if(!objExist) { //undefined
                const fieldName = message.value;

                let compo = {
                    fieldName   : fieldName,
                    fieldContexName : this.objectName+"."+fieldName
                }
                this.compos.push(compo);
                //
                if(this.formStatus == "Ready"){
                    console.log("!! form sudah keburu ready");
                    this.formRequestingToDb();
                }
            }else{
                //bila jimCompo yang minta register sudah ada di dalam compos
                let compo = objExist;
                console.log("Compo ini sudah ada di Compos :", JSON.stringify(compo));
                this.publishToMessageChannel(compo.fieldContexName+".DefaultValue", JSON.stringify(compo));                            
            }

        }else if (message.context == this.objectName+".Status"){
            if(message.value == "EditMode"){
                //__compo.EditMode <<<
                this.btnSaveDisabled = false;
                this.btnSaveLabel = "Save";
                this.btnIsHidden = false;
            }else if((message.value == "Saved") || (message.value == "Reset")){
                this.btnSaveDisabled = true;
                this.btnSaveLabel = "Saved";
                this.btnIsHidden = true && (!this.isDebug);
            }
        } else if(message.sender !== "form") {
            //Trigger dari luar untuk mengupdate internal compos
            this.chainSender=message.sender;
            //console.log("set chainSender =", this.chainSender);
            let compo = this.compos.find((cmp) => {
                return (message.context == cmp.fieldContexName)
            });
            if(!compo) return;

            compo.value = message.value;
            this.btnSaveDisabled = !(message.status == "valid");
            //console.log('form.handleMessage(objectName.fieldName) : compo => ', compo);
        }
        //console.log('form : this.compos => ', JSON.stringify(this.compos));
    }

    formRequestingToDb(){
        this.wiredObjectName = undefined;
        this.wiredObjectName = this.objectName;
        console.log("@wire wiredObjectName : ", this.wiredObjectName);
        //

        const _optionalFields = [];
        this.compos.forEach((compo) =>{
            const fldName = compo.fieldName;
            _optionalFields.push(this.objectName+"."+fldName);
        });
        //

        this.wiredRecordId = undefined;
        this.wiredRecordId = this.objectRecordId;
        this.optionalFields = _optionalFields;
        console.log("@wire wiredRecordId : ", this.wiredRecordId);
    }

    formReady(){
        this.btnSaveDisabled = true;
        this.btnSaveLabel = "Save";
        this.btnIsHidden = true && (!this.isDebug);
        
        this.formRequestingToDb();
        this.formStatus = "Ready";
    }

    //----------------------------------------------------
    @wire(getObjectInfo, { objectApiName: '$wiredObjectName' }) 
    wiredObjectInfo({ error, data }) {
        //let error =errors;
        if(error) {
            console.log("wiredInfo() => error: " , error);
            this.rsi =  undefined;
            this.error = error;
        }else if(data) {
            console.log("%cwiredInfo() => data: ", 'color: #FF69B4', data);
            this.rsi = data.fields;
            this.error = undefined;

            this.compos.forEach((compo) =>{
                const fldName = compo.fieldName;
                const compoInfo = data.fields[fldName];
                const fieldContexName =this.objectName+"."+fldName;

                console.log("cek2 chainSender =", this.chainSender);
                if(fieldContexName!=this.chainSender){
                    Object.assign(compo,compoInfo);
                    this.publishToMessageChannel(fieldContexName+".ObjectInfo", JSON.stringify(compoInfo));
                }
            });
            
        }
    }

    @wire(getRecord, { recordId: '$wiredRecordId', optionalFields: '$optionalFields'}) 
    wiredRecordData({ error, data }) {
        //let error =errors;        
        if (error) {
            console.log("wiredData() => error: " , error);
            this.rst =  undefined;
            this.error = error;
        } else if (data) {
            // Process record data
            console.log('%cwiredData() => data : ', 'color: #FF69B4', data);     
            this.rst = data.fields;
            this.error = undefined;
            
            this.compos.forEach((compo) =>{
                const fldName = compo.fieldName;
                const compoValue = data.fields[fldName];
                const fieldContexName =this.objectName+"."+fldName;

                console.log("cek chainSender =", this.chainSender);
                if(fieldContexName!=this.chainSender){
                    Object.assign(compo,compoValue);
                    this.publishToMessageChannel(fieldContexName+".DefaultValue", JSON.stringify(compoValue));
                }else{
                    console.log("del chainSender =", this.chainSender);
                    this.chainSender = undefined;
                }

            });
            /*
            Object.keys(data.fields).forEach((fldName) => {
                const compo = this.compos.find((cmp) => {
                    return (cmp.fieldName==fldName)
                });
                if(compo){
                    if(compo.fieldContexName!=this.chainSender){
                        Object.assign(compo,compoValue);
                        let compoValue = data.fields[fldName];
                        let fieldContexName =this.objectName+"."+fldName;
                        this.publishToMessageChannel(fieldContexName+".DefaultValue", JSON.stringify(compoValue));
                    }else{
                        this.chainSender = undefined;
                    }
                    console.log("2.compo : " + JSON.stringify(compo));                    
                }

            });
            */
        }
    }

    //----------------------------------------------------

    handleSubmit(event){
        event.preventDefault();
        //untuk create New Record : objectRecordId = undefined

        let changes = {}
        this.compos.forEach((compo) => {
            changes[compo.fieldName] = compo.value;
        });

        console.log('Save to DB : changes = ', JSON.stringify(changes));
        this.template.querySelector("lightning-record-edit-form").submit(changes);
    }

    handleSuccess(event){
        const updatedRecord = event.detail.id;
        console.log('onsuccess => recordId : ', updatedRecord);
        const payload = event.detail;
        console.log('onsuccess => payload :',JSON.stringify(payload));

        this.publishToMessageChannel(this.objectName+".Status", "Saved");
    }

    handleError(event){
        console.log('handleError: ', event.detail);
        this.error = event.detail;
        //this.publishToMessageChannel(this.objectName+".Status", "Error", this.error);
    }

    handleLoad(event){
        console.log('handleLoad: ', event.detail);
        this.error = undefined;
    }

    handleCancel(event){
        console.log('handleCancel: ', event.detail);
        this.error = undefined;
    }

    //----------------------------------------------------

    resetHandler(event){
        event.preventDefault();
        this.error = undefined;
        this.chainSender = undefined;
        this.compos = []; //buang semua data dan compo di Array compos
        this.publishToMessageChannel(this.objectName+".Status", "Reset");
    }

    errorCloseHandler(event){
        event.preventDefault();
        this.error = undefined;
    }

}