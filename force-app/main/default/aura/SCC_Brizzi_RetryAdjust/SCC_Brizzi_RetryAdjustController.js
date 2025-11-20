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

    cancelActionAlert: function(component, event, helper) {
        component.set("v.isOpenAlert", false);
        // $A.get("e.force:closeQuickAction").fire();
    },
    handleAdjust: function(component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        // Call apex method to process adjustment
        helper.processAdjustment(component, event);
    }
})