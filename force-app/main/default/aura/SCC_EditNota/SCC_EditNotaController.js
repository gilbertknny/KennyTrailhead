({
    getExistingNotaManual: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        // Fetch existing nota manual
        var action = component.get("c.getNotaManual");
        action.setParams({
            "caseId": recordId
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var notaManual = response.getReturnValue();
                if(notaManual){
                    component.set("v.notaManual", notaManual);
                    component.set("v.notaManual.SCC_Total__c", notaManual.SCC_Jumlah_Kredit__c);

                    var jenisTransaksiValue = notaManual.SCC_Jenis_Transaksi__c;
                    console.log("Jenis Transaksi: " + jenisTransaksiValue);
                    
                    if(jenisTransaksiValue == '8713'){
                        component.set("v.isRekening8713", true);
                    }

                    
                }
            } else {
                console.error("Failed to fetch existing nota manual: " + response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handleSave: function(component, event, helper) {
        component.set("v.showSpinner", true);
    
        var action = component.get("c.updateNotaManualFromForm");
        action.setParams({
            "notaManual": component.get("v.notaManual"),
            "queueTransList": component.get("v.queueTransList") // Assuming queueTransList is a list of SCC_Queuetrans__c records
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.showSpinner", false); 
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "title": "Success!",
                    "message": "Nota manual berhasil diupdate."
                });
                toastEvent.fire();
        
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                
                // Refresh the view
                //$A.get('e.force:refreshView').fire();
                
                var recordId = component.get("v.recordId");
                window.open('/'+recordId,'_self');
                
            } else {
                var errors = response.getError();
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