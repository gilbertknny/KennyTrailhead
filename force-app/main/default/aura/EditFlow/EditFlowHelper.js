({
    doSave : function(component) {
        var navService = component.find("navigationService");
        var pageReference = {
            type: "standard__recordPage",
            attributes: {
                recordId: component.get("v.recordId"),
                actionName: "view"
            }
        };
        navService.navigate(pageReference);
    },

    doCancel : function(component) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})