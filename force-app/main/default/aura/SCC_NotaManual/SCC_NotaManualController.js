({
    createNotaManual: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        // Fetch case details
        var action = component.get("c.getCaseDetails");
        action.setParams({
            "caseId": recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseDetails = response.getReturnValue();
                component.set("v.caseDetails", caseDetails);
                
                var notaManual = {
                    'sobjectType': 'SCC_Nota_Manual__c',
                    'Case__c': recordId,
                    'SCC_Jenis_Transaksi__c': caseDetails.SCC_Call_Type__r.Name,
                    'SCC_No_Rekening__c': caseDetails.SCC_Account_Number__c,
                    'SCC_No_Telepon__c': caseDetails.Cust_Current_Phone__c,
                    'SCC_Nama_Nasabah__c': caseDetails.Account.Name,
                    'SCC_No_Kartu__c': caseDetails.SCC_Card_Number__c,
                    'SCC_Keterangan__c': '',
                    'SCC_Jumlah_Debit__c': caseDetails.SCC_Amount__c,
                    'SCC_Jumlah_Fee__c': 0,
                    'SCC_Total__c': caseDetails.SCC_Amount__c, 
                    'SCC_Rekening_Nasabah__c': caseDetails.SCC_Account_Number__c,
                    'SCC_Nama__c': caseDetails.Account.Name,
                    'SCC_Jumlah_Kredit__c': caseDetails.SCC_Amount__c
                }

                
                if(caseDetails.SCC_Call_Type__r.External_Id__c != '8713'){
                    if(caseDetails.Terminal_ID__r){
                        notaManual.SCC_Branchcode__c = caseDetails.Terminal_ID__r.SCC_Branch_Code__c;
                        notaManual.SCC_Rekening_Titipan__c = caseDetails.Terminal_ID__r.SCC_Account_Number__c;
                    }
                    notaManual.SCC_Terminal_ID__c = caseDetails.SCC_Terminal_ID__c;
                } else{
                    component.set("v.isRekening8713", true);
                }


                component.set("v.notaManual", notaManual);
            } else {
                var errors = response.getError();
                var message = "Unknown error"; 
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error("Failed to fetch case details: " + message);
            }
            component.set("v.showSpinner", false); 
        });

        //component.set("v.showSpinner", true); 
        $A.enqueueAction(action);
    },

    handleSave: function(component, event, helper) {
        // Show spinner
        component.set("v.showSpinner", true);
        console.log('Form Nota Manual = '+component.get("v.notaManual"));
        var action = component.get("c.createNotaManualFromForm");
        action.setParams({
            "notaManual": component.get("v.notaManual"),
            'cs': component.get("v.caseDetails")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false); 
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "Nota manual berhasil disimpan."
                });
                toastEvent.fire();
    
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // Reload the page
                //$A.get('e.force:refreshView').fire();
                
                var recordId = component.get("v.recordId");
                window.open('/'+recordId,'_self');
                
            } else {
                var errors = response.getError();
                console.log('errors ' + errors);
                
                var message = "Unknown error"; // Default error message
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                console.error("Terjadi kesalahan saat menyimpan nota manual: " + message);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": "Terjadi kesalahan saat menyimpan nota manual: " + message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
        handleCancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },

    calculateTotal: function(component, event, helper) {
        var notaManual = component.get("v.notaManual");
        var jumlahDebit = parseFloat(notaManual.SCC_Jumlah_Debit__c);
        var jumlahFee = parseFloat(notaManual.SCC_Jumlah_Fee__c);
        var jumlahKredit = parseFloat(notaManual.SCC_Jumlah_Kredit__c);
    
        if(!isNaN(jumlahDebit) && !isNaN(jumlahFee)){
            var total = jumlahDebit + jumlahFee;
            notaManual.SCC_Total__c = total;
            component.set("v.notaManual", notaManual);
    
            if (jumlahDebit > jumlahKredit) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Peringatan!",
                    "message": "Jumlah yang diinput melebihi nominal.",
                    "type": "warning"
                });
                toastEvent.fire();
            }
        } else {
            console.error("Invalid amount for debit or fee");
        }
    }    
})