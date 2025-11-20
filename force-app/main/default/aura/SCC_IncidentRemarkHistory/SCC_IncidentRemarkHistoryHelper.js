({
    initialCase: function(component){
        var incidentId = component.get('v.recordId');
        var action1 = component.get('c.getIncidentDetail');

        console.log('id incident' , incidentId);
        console.log('action 1' , action1);
        
        
        action1.setParams({
            "idIncident" : incidentId
        });
        action1.setCallback(this, function(response1){
            var state1 = response1.getState();
            console.log('Incident' , response1.getReturnValue());
            if(state1 === "SUCCESS"){
                component.set("v.incident" , response1.getReturnValue());
            }
        });

        $A.enqueueAction(action1);
    }
})