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
    
    cancelAction: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleAdjust: function(component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        // Call apex method to process adjustment
        helper.processAdjustment(component, event);
    },

    insertDataAdjust: function(component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        // Call apex method to process adjustment
        helper.insertDataAdjust(component, event);
    },

    searchKartuBrizzi: function (component, event, helper) {
        component.set("v.loaded", false);
        component.set("v.showModal", true);
        console.log("awal",component.get("v.loaded"));
        helper.searchKartuBrizzi(component, event);
    },
})