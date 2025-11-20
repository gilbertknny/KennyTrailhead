({
    initialCase : function(component){
        var csid = component.get("v.recordId");  
        var action1 = component.get("c.getCaseDetail");
        action1.setParams({
            "idcs": csid   
        });
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            console.log('Case',response1.getReturnValue());
            if(state1 === "SUCCESS") {
                component.set("v.case", response1.getReturnValue());
            }
        });
        $A.enqueueAction(action1);
    }
})