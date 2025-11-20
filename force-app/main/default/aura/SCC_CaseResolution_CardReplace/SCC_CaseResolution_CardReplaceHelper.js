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

    searchKartuBrizziLama : function(component,event){
        console.log('helper kartu brizzi');
        var action = component.get("c.getBrizziCardInquiry");
        var cs = component.get("v.caseRecord");
        var cardNumberLama = component.get("v.cardNumberLama");
        console.log("cardNumberLama",cardNumberLama);
        var toastEvent4 = $A.get("e.force:showToast");
        if(cardNumberLama === undefined || cardNumberLama == null || cardNumberLama == ''){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Lama tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if (!(/^\d{1,16}$/).test(cardNumberLama)) {
            // This regex checks for digits only and length between 1-16
            component.set("v.loaded", true);
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nomor Kartu Lama harus berupa angka dan maksimal 16 digit",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log('hit api');
            action.setParams({
                "cs": cs,
                "cnumber": cardNumberLama
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('response =',response);
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('oRes =',oRes);
                    if(oRes.responseDesc == 'success'){
                        component.set('v.DataKartuLama', oRes.data[0]);
                        console.log('data kartu lama = ',oRes.data[0]); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }else{   
                        console.log('masuk error');
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

    searchKartuBrizziBaru : function(component,event){
        console.log('helper kartu brizzi');
        var action = component.get("c.getBrizziCardInquiry");
        var cs = component.get("v.caseRecord");
        var cardNumberBaru = component.get("v.cardNumberBaru");
        console.log('kartu brizzi Baru=',cardNumberBaru);
        var cardNumberLama = component.get("v.DataKartuLama.cardnum");
        console.log('kartu brizzi =',cardNumberLama);
        var toastEvent4 = $A.get("e.force:showToast");
        if(cardNumberBaru === undefined || cardNumberBaru == null || cardNumberBaru == ''){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Baru tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(isNaN(cardNumberBaru) || !(/^\d{1,16}$/).test(cardNumberBaru)){
            component.set("v.loaded", true);
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Baru harus berupa angka dan maksimal 16 digit",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(cardNumberBaru === cardNumberLama){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Baru tidak boleh sama dengan Kartu Lama",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log('hit api');
            action.setParams({
                "cs": cs,
                "cnumber": cardNumberBaru
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('response baru = ',response);
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    console.log('response oRes = ',oRes.responseDesc);
                    if(oRes.responseDesc == 'success'){
                        component.set('v.DataKartuBaru', oRes.data[0]);
                        console.log('data kartu baru = ',oRes.data[0]); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }else{   
                        console.log('masuk error = ',oRes);
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

    handleReplace : function(component,event){
        console.log('helper hanlde replace 10');
        var action = component.get("c.replaceBrizziCard");
        console.log('helper hanlde replace 2');
        var cs = component.get("v.caseRecord");
        var cardNumberBaru = component.get("v.oldCard");
        console.log('new card =',cardNumberBaru);
        var cardNumberLama = component.get("v.newCard");
        console.log('old card =',cardNumberLama);
        var obc = component.get("v.saldoKartu");
        console.log('balance =',obc);
        console.log('hit api');
        action.setParams({
            "cs": cs,
            "oldCard": cardNumberLama,
            "newCard": cardNumberBaru,
            "obc": obc
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('response = ',oRes);
                if(oRes.responseDesc === "success"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Success. Ref Number - "+oRes.refNumber,
                        "type" : "success"
                    });
                    toastEvent.fire();
                }else{   
                    var toastEvent2 = $A.get("e.force:showToast");
                    toastEvent2.setParams({
                        "title": "Warning",
                        "message": "Gagal Replcace Kartu - "+oRes.responseDesc,
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
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },

    insertDataReplace : function(component,event){
        console.log('helper Replace');
        var cs = component.get("v.caseRecord");
        var oldCard = component.get("v.oldCard");
        var newCard = component.get("v.newCard");
        var saldoKartu = component.get("v.saldoKartu");
        var saldoDeposit = component.get("v.saldoDeposit");
        var action = component.get("c.insertDataReplaceCard");
        // var ct = component.get("v.calltypeObj");
        var toastEvent4 = $A.get("e.force:showToast");
        if(oldCard === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Brizzi Lama tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(newCard === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Brizzi Baru tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log('hit api');
            action.setParams({
                "cs": cs,
                "oldCard": oldCard,
                "newCard": newCard,
                "saldoKartu": saldoKartu,
                "saldoDeposit": saldoDeposit
                
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

    openAlert: function(cmp, event) {
        this.LightningAlert.open({
            message: 'this is the alert message',
            theme: 'error',
            label: 'Error!',
        }).then(function() {
            console.log('alert is closed');
        });
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