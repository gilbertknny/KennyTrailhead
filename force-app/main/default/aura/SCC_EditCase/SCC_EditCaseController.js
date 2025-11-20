({
    init : function(component, event, helper) {
        var csid = component.get("v.recordId");  
        var action1 = component.get("c.getCaseDetail");
        action1.setParams({
            "idcs": csid   
        });
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            console.log('Response 1',response1.getReturnValue());
            if(state1 === "SUCCESS") {
                component.set("v.case", response1.getReturnValue());
                var cs = component.get("v.case");
                var action2 = component.get("c.getParentCase");
                console.log('cs',cs);
                console.log('parentId',cs.ParentId	);
                if (cs.ParentId	 === undefined) {
                    
                }else{
                    action2.setParams({
                        "idcs": cs.ParentId	   
                    });
                    action2.setCallback(this, function(response2) {
                        var state2 = response2.getState();
                        console.log('Parent Case',response2.getReturnValue());
                        if(state2 === "SUCCESS") {
                            component.set("v.parentObj", response2.getReturnValue());
                        }
                        else{
                            
                        }
                    });
                    $A.enqueueAction(action2);
                }
            }
        });
        $A.enqueueAction(action1);
    },
    handleLoad : function(component, event, helper) {
        
    },
    
    
    handleSuccess : function(component, event, helper) {
       
    },
    
    handleSubmit : function(component, event, helper) {
        var pr = component.get("v.parentObj");
        var cs = component.get("v.case");   
        var csid = component.get("v.recordId"); 
        component.set("v.loaded",false);
        if(pr==''){
            cs.ParentId = '';
        }
        else{
            cs.ParentId = pr.value;
        }
        var action = component.get("c.updateCase");
        action.setParams({
            "cs" : cs
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            $A.get('e.force:refreshView').fire();
            component.set("v.loaded",true);
            console.log('finish');
        });
        $A.enqueueAction(action);
    }
})