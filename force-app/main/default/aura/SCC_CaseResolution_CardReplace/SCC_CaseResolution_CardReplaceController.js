({
    doInit: function(component, event, helper) {
        // Get record ID from the quick action context
        var recordId = component.get("v.recordId");
        console.log("awal",component.get("v.loaded"));
        // Optionally, call an Apex method
        if (recordId) {
            helper.getCardDetails(component, recordId);
        }
    },

    searchKartuBrizziLama: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchKartuBrizziLama(component, event);
    },

    searchKartuBrizziBaru: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchKartuBrizziBaru(component, event);
    },

    replaceCard: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("replace");
        let oldCard = component.find("kartuLama").get("v.value");
        let newCard = component.find("kartuBaru").get("v.value");
        let saldoKartu = component.find("saldoLama").get("v.value");
        let saldoDeposit = component.find("saldoDepositLama").get("v.value");
        let statusOldCard = component.get("v.DataKartuLama.status_kartu");
        let statusNewCard = component.get("v.DataKartuBaru.status_kartu");
        console.log("statusOldCard = ",statusOldCard);
        console.log("statusNewCard = ", statusNewCard);
        if(oldCard === undefined || oldCard == null){
            var toastEvent4 = $A.get("e.force:showToast");
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Lama tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(newCard === undefined || newCard == null){
            var toastEvent4 = $A.get("e.force:showToast");
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Kartu Baru tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        } else if(statusOldCard != 'na' && statusOldCard != 'aa'){
            var toastEvent4 = $A.get("e.force:showToast");
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Status Kartu Lama harus Aktif",
                "type" : "error"
            });
            toastEvent4.fire();
        } else if(statusNewCard != 'na' && statusNewCard != 'aa'){
            var toastEvent4 = $A.get("e.force:showToast");
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Status Kartu Baru harus Aktif",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            console.log("oldCard",oldCard);
            console.log("newCard", newCard);
            component.set("v.oldCard", oldCard);
            component.set("v.newCard", newCard);
            component.set("v.saldoKartu", saldoKartu);
            component.set("v.saldoDeposit", saldoDeposit);
            component.set("v.loaded", true);
            component.set("v.isOpen", true);
            console.log("modal open =",component.set("v.isOpen", true));
        }
    },

    closeModal: function (component, event, helper) {
        component.set("v.isOpen", false);
    },

    handleReplace: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        component.set("v.isOpenAlert", true);
        helper.handleReplace(component, event);
    },

    handleReplaceAlert: function (component, event, helper) {
        let saldoKartuLama = component.find("saldoLama").get("v.value");
        var saldoKartu = component.get("v.saldoKartu");
        var toastEvent4 = $A.get("e.force:showToast");
        if (parseFloat(saldoKartu) > parseFloat(saldoKartuLama)){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nominal yang anda masukkan melebihi nilai dari Saldo Kartu Lama",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(parseFloat(saldoKartu) == 0){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nominal yang anda masukkan harus lebih dari 0",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            component.set("v.isOpen", false);
            component.set("v.isOpenAlert", true);
        }
    },

    cancelAction: function(component, event, helper) {
        component.set("v.isOpen", false);
        // $A.get("e.force:closeQuickAction").fire();
    },

    cancelActionAlert: function(component, event, helper) {
        component.set("v.isOpenAlert", false);
        // $A.get("e.force:closeQuickAction").fire();
    },

    insertDataReplace: function(component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        // Call apex method to process adjustment
        helper.insertDataReplace(component, event);
    },
})