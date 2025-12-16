({
    doInit : function(component, event, helper) {
        var navService = component.find("navService");
        var workspaceAPI = component.find("workspace");
        var recordId = component.get("v.recordId");
        
        var pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'omnistudio__vlocityLWCOmniWrapper'
            },
            state: {
                "c__target": "c:accountRegistrationEnglish",
                "c__layout": "lightning",
                "c__tabIcon": "standard:account",
                "c__tabLabel": "Account_Registration",
                "c__ContextId": recordId
            }
        };

        navService.navigate(pageReference, true);

    }
})