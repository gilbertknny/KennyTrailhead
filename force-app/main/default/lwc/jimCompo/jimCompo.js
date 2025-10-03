/*
 * Copyright (c) 2024, developed-by: Jimmy Lumbantobing.
 * All rights reserved.
 * SPDX-License-Identifier: MIT
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/MIT
 */

import { LightningElement, api,track, wire } from 'lwc';
import { publish, subscribe, MessageContext } from 'lightning/messageService';
import Jim_Compo_Channel from '@salesforce/messageChannel/Jim_Channel__c';
import { FlowAttributeChangeEvent } from "lightning/flowSupport";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';


const SLDS_FIELD_CLASS = 'slds-form-element__static';

export default class JimCompo extends LightningElement {
    @api recordId;
    @api objectApiName;

    @api isDebug;
    @api objectName;
    @api fieldName;
    @api fieldAttr; //None
    @api fieldPlaceholder; // = fieldLabel
    @api fieldValue; // = fieldLabel
    @api compoType; //"String"
    fieldReadOnly;
    fieldRequired;

    @api showLabel; // true
    @api fieldLabel;
    @api showInlineHelpText; //false
    @api inlineHelpText; // "Ini help text"

    @api displayValue;
    latitude;
    longitude;
    scale=0;
    jimCompoClass="slds-m-bottom_x-small jim-compo";

    @api showEditField;
    @api fieldValid;
    @api fieldRegistered = false;
    @wire(MessageContext) messageContext;
    
    connectedCallback() {
        if(!this.objectName) {
            if(!this.objectApiName){
                this.objectApiName = "Global";
            }
            this.objectName = this.objectApiName;
        }
        if(!this.compoType) this.compoType = "String";
        if(!this.showLabel) this.showLabel = true;
        if(!this.fieldAttr) this.fieldAttr = "None";
        if(!this.showInlineHelpText) this.showInlineHelpText = false;

        //if(!this.fieldValue) this.fieldValue = this.fieldLabel;
        if(!this.fieldPlaceholder) this.fieldPlaceholder = this.fieldLabel;
        if(!this.showEditField) this.showEditField = false;

        this.fieldReadOnly = (this.fieldAttr==="Readonly");
        this.fieldRequired = (this.fieldAttr==="Required");
        
        //setup displayValue for Global scope
        if(this.isTypeCurrency){
            console.log("before => this.fieldValue : ",this.fieldValue);
            if((this.fieldValue===undefined) || (!this.fieldValue) || isNaN(this.fieldValue)){
                this.fieldValue = 0;
            }else if( (typeof this.fieldValue == "string")) {
                this.fieldValue = parseFloat(this.fieldValue);
            }
            console.log("after => this.fieldValue : ",this.fieldValue);

            if(!this.displayValue) this.displayValue = new Intl.NumberFormat("id-ID", {
                style: "currency",
                currency: "IDR",
                trailingZeroDisplay: 'stripIfInteger'
            }).format(this.fieldValue);        
        }else if(this.isTypePicklist){
            if(!this.displayValue) this.displayValue = this.fieldValue;
        }

        this.subscribeToMessageChannel();
        //console.log('compo.connectedCallback() : ',this.compoType,'|this.objectName:',this.objectName, "|this.fieldAttr:", this.fieldAttr, "|this.showLabel:", this.showLabel);
    }
    
    renderedCallback(){
        if(!this.fieldRegistered){
            //this.displayValue = this.fieldValue;
            this.publishToMessageChannel(this.objectName+".Register", this.fieldName);
            //this.fieldRegistered = true;
        }
        //console.log('compo.renderedCallback() : this.displayValue => ', this.displayValue);
    }

    changeHandler_NotNull(event) {
        // Display field-level errors and disable button if field is empty.
        console.log('event', event);
        if (!event.target.value) {
            event.target.reportValidity();
            this.fieldValid = false;
        } else {
            this.fieldValid = true;
        }

        this.fieldValue = event.target.value;
        //this.displayValue = this.fieldValue;

        const fieldNameContex = this.objectName+"."+this.fieldName;
        this.publishToMessageChannel(fieldNameContex, this.fieldValue, this.fieldValid ? "valid" : "invalid");
        this.publishToFlowAttribute("fieldValue", this.fieldValue);
    }

    changeHandler_Picklist(event){
        this.fieldValue = event.target.value;
        this.fieldValid = true;
        const fieldNameContex = this.objectName+"."+this.fieldName;
        this.publishToFlowAttribute("fieldValue", this.fieldValue);

        if(this.fieldAttr==="Next"){
            this.navigateNextFlowScreen();
        }else{
            this.publishToMessageChannel(fieldNameContex, this.fieldValue, this.fieldValid ? "valid" : "invalid");
        }
        
    }

    //----------------------------------------------------

    @track computedFieldClass = SLDS_FIELD_CLASS;
    set fieldClass(val) {
        this.computedFieldClass = `${val} ${SLDS_FIELD_CLASS}`;
    }
    @api get fieldClass() {
        return this.computedFieldClass;
    }

    @api optionsPicklist;
    get picklistItems() {
        console.log("optionsPicklist :", this.optionsPicklist);
        return JSON.parse(this.optionsPicklist);
    }

    //----------------------------------------------------
    publishToFlowAttribute(context, value) {
        this.dispatchEvent(new FlowAttributeChangeEvent(
            context,
            value,
        ));
    }

    publishToMessageChannel(context, value, status) {
        const message = {
            sender : (this.objectName+"."+this.fieldName),
            context: context,
            value: value,
            status : status
        }
        console.log(('%c'+this.fieldName+' ==> form/*').padEnd(40,' '), 'color: #00AA00', JSON.stringify(message));
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

    handleMessage(message) {
        //if(message.sender==this.objectName+"."+this.fieldName) return;
        const fieldNameContex = this.objectName+"."+this.fieldName;
        if(message.sender!==fieldNameContex) {
            if(message.context.includes(fieldNameContex)){
                console.log(('%c'+this.fieldName+' <== '+message.sender).padEnd(40,' '), 'color: #FE8A18', message);
            }
        }
        if (message.context == this.objectName+".Status"){
                console.log(('%c'+this.fieldName+' <== '+message.sender).padEnd(40,' '), 'color: #FE8A18', message);
        }
        
        if (message.context == this.objectName+".Status"){
            if(message.value == "Ready"){
                if(!this.fieldRegistered){
                    this.publishToMessageChannel(this.objectName+".Register", this.fieldName);
                    this.fieldRegistered = true;
                }
            }else if(message.value == "EditMode"){
                //__compo.EditMode <<<
                if(!this.fieldReadOnly){
                    this.showEditField = true;
                    this.publishToFlowAttribute("showEditField", this.showEditField);
                }
            }else if(message.value == "Saved"){
                this.showEditField = false;
                this.publishToFlowAttribute("showEditField", this.showEditField);
            }else if(message.value == "Reset"){
                /*
                const inputFields = this.template.querySelectorAll('.jim-compo');
                
                if (inputFields) {
                    inputFields.forEach(field => {
                        console.log("Reseting ", field);
                        field.reset();
                    });
                }
                */
                this.showEditField = false;
                this.publishToFlowAttribute("showEditField", this.showEditField);
                this.fieldRegistered = false;
                this.publishToMessageChannel(this.objectName+".Register", this.fieldName);
            }else if(message.value == "revokeFlow"){
                this.publishToFlowAttribute("fieldValue", this.fieldValue);
            }
        }else if (message.context.includes(fieldNameContex) && (message.sender!=fieldNameContex)){
            if(message.context == fieldNameContex+".DefaultValue"){
                const compoValue = JSON.parse(message.value);
                //console.log("|__compo.compoValue => ", message.value);

                this.fieldValue = compoValue.value;
                this.displayValue = compoValue.displayValue;
                this.fieldRegistered = true;
        
            }else if(message.context == fieldNameContex+".ObjectInfo"){
                const compoInfo = JSON.parse(message.value);
                //console.log("|__compo.compoInfo => ", message.value);

                this.fieldLabel = compoInfo.label;
                this.compoType = compoInfo.dataType;
                this.fieldRequired = (compoInfo.required || this.fieldRequired); //this.fieldAttr
                this.fieldReadOnly = (!compoInfo.updateable || this.fieldReadOnly); //this.fieldAttr
                this.inlineHelpText = compoInfo.inlineHelpText;
                this.showLabel = (this.showLabel && this.fieldLabel);
                this.showEditField = (this.showEditField && this.fieldReadOnly);

            }else if(message.context == fieldNameContex){
                //this.fieldValue = message.value;
            }
        }
        
    }

    getInputAndOutputComponents() {
        return [
            ...this.querySelectorAll('lightning-input,lightning-output')
        ];
    }

    //----------------------------------------------------

    handleEdit(event) {
        //console.log("handleEdit => ", event.target.value);
        //console.log("handleEdit => this.fieldRegistered : ", this.fieldRegistered);
        if(!this.fieldRegistered){
            //console.log("%chandleEdit => Masuk sini",'color: #FF0000');
            this.navigateNextFlowScreen();
        }else if(!this.fieldReadOnly) {
            this.showEditField = true;
            this.publishToFlowAttribute("showEditField", this.showEditField); //kabari ke flow
            this.publishToMessageChannel(this.objectName+".Status", "EditMode"); // kabari ke jimCompo lain
            //__compo.EditMode >>>
        } 
    }

    //<lightning-button type="cancel" onclick={handleCancel}></lightning-button>
    handleCancel(event) {
        console.log("handleCancel = > ", event.target.value);
        if(!this.fieldReadOnly) {
            this.showEditField = false;
            this.publishToFlowAttribute("showEditField", this.showEditField); //kabari ke flow
            this.publishToMessageChannel(this.objectName+".Status", "EditMode"); // kabari ke jimCompo lain
        }
    }
    
    //<lightning-record-edit-form onsuccess={handleSuccess}></lightning-record-edit-form>
    handleSuccess(event) {
        console.log("handleSuccess = > ", event.target.value);
        if(!this.fieldReadOnly) {
            this.showEditField = false;
            this.publishToFlowAttribute("showEditField", this.showEditField); //kabari ke flow
        }
    }

    //----------------------------------------------------
    @api availableActions = [];
    get isNextAction() {
        return this.availableActions.includes('NEXT');
    }

    navigateNextFlowScreen() {
        console.log("GO TO NEXT");
        if (this.isNextAction) {
            const navigateNext = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNext);
        }
    }

    //----------------------------------------------------
    //String,Boolean,Currency,Date,Datetime,Email,Location,Int,Double,Percent,
    //Phone,Picklist,MultiPicklist,TextArea,Richtext,
    //EncriptedString,Url,Name,Address,Reference
    
    get isTypeString() {
        //console.log("masuk -> this.compoType : ", this.compoType);
        return this.compoType === "String";
    }

    get isTypeBoolean() {
        return this.compoType === "Boolean";
    }

    rupiah(number){
        return new Intl.NumberFormat("id-ID", {
            style: "currency",
            currency: "IDR",
            trailingZeroDisplay: 'stripIfInteger'
        }).format(number);
    }

    get isTypeCurrency() {
        return this.compoType === "Currency";
    }

    get isTypeDate() {
        return this.compoType === "Date";
    } 

    get isTypeDateTime() {
        return this.compoType === "Datetime";
    }

    get isTypeEmail() {
        return this.compoType === "Email";
    } 

    get isTypeLocation() {
        return this.compoType === "Location";
    }

    get isTypeInt() {
        return this.compoType === "Int";
    }

    get isTypeDouble() {
        return this.compoType === "Double";
    }

    get isTypePercent() {
        return this.compoType === "Percent";
    }

    get isTypePhone() {
        return this.compoType === "Phone";
    } 

    get isTypePicklist() {
        return this.compoType === "Picklist";
    } 

    get isTypeMultiPicklist() {
        return this.compoType === "MultiPicklist";  
    } 

    get isTypeTextArea() {
        return this.compoType === "TextArea";
    } 

    get isTypeRichText() {
        return this.compoType === "Richtext";   
    }

    get isTypeEncriptedString() {
        return this.compoType === "EncriptedString";
    } 

    get isTypeUrl() {
        return this.compoType === "Url";
    } 

    get isTypeName() {
        return this.compoType === "Name";
    }

    get isTypeAddress() {
        return this.compoType === "Address";
    } 

    get isTypeReference() {
        return this.compoType === "Reference";
    }
    
}