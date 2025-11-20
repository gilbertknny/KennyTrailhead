({
    getCardDetails: function (component, recordId) {
        var action = component.get("c.getCaseDetails"); // Apex method
        action.setParams({ caseId: recordId });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.caseRecord", response.getReturnValue());
            } else {
                console.error("Failed to fetch case details");
            }
            component.set("v.loaded", true);
        });

        $A.enqueueAction(action);
    },

    processReplace : function(component,event){
        console.log('helper adjust 1 deposit');
        var cs = component.get("v.caseRecord");
        console.log('Case Id = ',cs.Id);
        var action = component.get("c.retryReplace");
        // var ct = component.get("v.calltypeObj");
        console.log('hit api');
        console.log('Case Id = ',cs.Id);
        action.setParams({
            "csid": cs.Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var oRes = response.getReturnValue();
                console.log('oRes =',oRes);
                console.log('data =',response);
                if(oRes.responseDesc == "success"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Success. Ref Number "+oRes.refNumber,
                        "type" : "success"
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    toastEvent.fire();
                }else{   
                    var toastEvent2 = $A.get("e.force:showToast");
                    toastEvent2.setParams({
                        "title": "Error",
                        "message": "Retry Replace Card. "+oRes.responseDesc,
                        "type" : "error"
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                    toastEvent2.fire();
                } 
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    }
})