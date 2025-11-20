({
    invoke : function(component, event, helper) {
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