({
    getCardDetails: function (component, recordId) {
        var action = component.get("c.getCaseDetails"); // Apex method
        action.setParams({ caseId: recordId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.caseRecord", response.getReturnValue());
            } else {
                console.error("Failed to fetch case details");
            }
            component.set("v.loaded", true);
        });

        $A.enqueueAction(action);
    },
    
    processAdjustment1: function(component, amount, reduceBalance) {
        // Show spinner
        this.showSpinner(component);
        
        var action = component.get("c.adjustDeposit");
        action.setParams({
            recordId: component.get("v.recordId"),
            amount: amount,
            reduceBalance: reduceBalance
        });
        
        action.setCallback(this, function(response) {
            this.hideSpinner(component);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast("Success", "Deposit adjusted successfully", "success");
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                this.showToast("Error", "Failed to adjust deposit", "error");
            }
        });
        
        $A.enqueueAction(action);
    },

    searchKartuBrizzi : function(component,event){
        console.log('helper kartu brizzi');
        var action = component.get("c.getBrizziCardInquiry");
        var cs = component.get("v.caseRecord");
        // var ct = component.get("v.calltypeObj");
        var toastEvent4 = $A.get("e.force:showToast");
        if(cs.SCC_Brizzi_Card_Number__c === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Brizzi tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log('hit api');
            action.setParams({
                "cs": cs
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes.data.length > 0){
                        component.set('v.DataBrizzi', oRes); 
                        component.set('v.saldo', oRes.data[0].saldo); 
                        component.set('v.saldoDeposit', oRes.data[0].saldo_topup);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }else{   
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Warning",
                            "message": "Data Tidak Ditemukan - "+oRes.responseDesc,
                            "type" : "warning"
                        });
                        toastEvent2.fire();
                    } 
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            });
            $A.enqueueAction(action); 
        }
    },

    processAdjustment : function(component,event){
        console.log('helper adjust deposit');
        var action = component.get("c.adjustDeposit");
        var cs = component.get("v.caseRecord");
        var amount = component.get("v.adjustDeposit");
        console.log('cek amount =',amount);
        var kurangi = component.get("v.reduceBalance");
        // var ct = component.get("v.calltypeObj");
        var toastEvent4 = $A.get("e.force:showToast");
        if(cs.SCC_Brizzi_Card_Number__c === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Brizzi tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(amount === undefined || amount == null || amount == ''){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nominal Adjustment tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log('hit api');
            action.setParams({
                "cs": cs,
                "cardNumber": cs.SCC_Brizzi_Card_Number__c,
                "amount": amount,
                "reduceBalance": kurangi,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('oRes =',oRes);
                    console.log('data =',response);
                    if(oRes.responseDesc == "success"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success. Ref Number "+oRes.refNumber,
                            "type" : "success"
                        });
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        toastEvent.fire();
                    }else{   
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Error",
                            "message": "Adjustment Deposit gagal. "+oRes.responseDesc,
                            "type" : "error"
                        });
                        toastEvent2.fire();
                    } 
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            });
            $A.enqueueAction(action); 
        }
    },

    insertDataAdjust : function(component,event){
        console.log('helper adjust deposit');
        var action = component.get("c.insertDataAdjustment");
        var cs = component.get("v.caseRecord");
        var amount = component.get("v.adjustDeposit");
        console.log('cek amount =',amount);
        var kurangi = component.get("v.reduceBalance");
        console.log('cek kurangi =',kurangi);
        var saldo = component.get("v.saldo");
        var saldoDeposit = component.get("v.saldoDeposit");
        var validateAdjust = saldoDeposit + amount;
        var jumlahValid = 10000000 - saldoDeposit;
        console.log('saldo brizzii =',saldo);
        console.log('saldoDeposit brizzi =',saldoDeposit);
        console.log('validateAdjust =',validateAdjust);
        console.log('jumlahValid =',jumlahValid);
        console.log('amount =',amount);
        console.log('kurangi =',kurangi);
        // var ct = component.get("v.calltypeObj");
        var toastEvent4 = $A.get("e.force:showToast");
        if(cs.SCC_Brizzi_Card_Number__c === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Brizzi tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(saldo === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Saldo Kartu tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(amount === undefined || amount == null || amount == ''){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nominal Adjustment tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        // Check if amount is negative
        else if (amount < 0) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nominal Adjustment tidak boleh Minus",
                "type": "error"
            });
            toastEvent4.fire();
        }
        else if (validateAdjust > 10000000){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Saldo Deposit ditambah Nominal Adjust menebihi 10.000.000",
                "type": "error"
            });
            toastEvent4.fire();
        }
        // Check if amount exceeds 10,000,000
        else if (amount > 10000000) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Jumlah yang di inputkan tidak boleh lebih dari 10.000.000",
                "type": "error"
            });
            toastEvent4.fire();
        }
        else if(kurangi && amount > saldo){
            console.log("masuk ke notif Nominal adjust tidak boleh melebihi saldo kartu");
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nominal adjust tidak boleh melebihi saldo kartu",
                "type": "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log('hit api');
            action.setParams({
                "cs": cs,
                "cardNumber": cs.SCC_Brizzi_Card_Number__c,
                "cardBalance": saldo,
                "depositBalance": saldoDeposit,
                "adjustAmount": amount,
                "reduceBalance": kurangi,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    toastEvent4.setParams({
                        "title": "Success!",
                        "message": "Data Berhasil Disimpan. Menunggu Approval Signer",
                        "type": "success"
                    });
                    toastEvent4.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    this.invoke(component);
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                    toastEvent4.fire();
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            });
            $A.enqueueAction(action); 
        }
    },
    
    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type
        });
        toastEvent.fire();
    },
    
    showSpinner: function(component) {
        $A.util.addClass(component.find("spinner"), "slds-show");
    },
    
    hideSpinner: function(component) {
        $A.util.removeClass(component.find("spinner"), "slds-show");
    },

    parseErrorMsg: function(errors){
        console.log("errors",errors);
        var msg = '';
        if (errors[0] ) {
            for(var i=0;i<errors.length;i++){
                if(errors[i].message){
                    msg = msg+'\n'+errors[i].message;
                }
                else if(Object.keys(errors[i].fieldErrors).length>0){
                    console.log('fieldErrors',errors[i].fieldErrors);
                    msg = msg+'\n'+JSON.stringify(errors[i].fieldErrors);
                    msg = this.parseFieldErrors(msg);
                }
                    else if(errors[i].pageErrors.length>0){
                        console.log('pageErrors',errors[i].pageErrors);
                        for(var j=0;j<errors[i].pageErrors.length;j++){
                            console.log('message',errors[i].pageErrors[j].message);
                            msg = msg+'\n'+errors[i].pageErrors[j].message;
                        }
                    }
            }
            var toastEvent3 = $A.get("e.force:showToast");
            toastEvent3.setParams({
                "title": "Error",
                "message": msg,
                "type" : "error"
            });
            toastEvent3.fire();
        }
    },

    invoke : function(component) {
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: component.get("v.recordId"),
                objectApiName: component.get("v.objectApiName"),
                actionName: 'view'
            }
        };
        navService.navigate(pageReference, true); // The 'true' here means to replace the current page in the browser history
    }
})