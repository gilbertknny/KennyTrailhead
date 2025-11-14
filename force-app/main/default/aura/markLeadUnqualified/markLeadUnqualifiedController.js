({
    doInit : function(component, event, helper) {
        var action = component.get("c.markUnqualified");
        action.setParams({ leadId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                $A.get("e.force:refreshView").fire();
            } else {
                console.error(response.getError());
            }
        });
        
        $A.enqueueAction(action);
    }
})