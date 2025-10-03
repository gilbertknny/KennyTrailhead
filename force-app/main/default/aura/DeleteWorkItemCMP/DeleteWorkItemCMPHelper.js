({
    
    fetchProjects : function(component, event) {
        var action = component.get("c.fetchProjects");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                records.forEach(function(record) {
                    record.label = record.Name;
                    record.value = record.Name;
                    
                });
                component.set("v.projectList", records);                
            }            
        });
        $A.enqueueAction(action);
    },
    fetchWorkItems : function(component, event, pName) {
        var action = component.get("c.getAllWorkItems");
        action.setParams({ projectName : pName });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                records.forEach(function(record) {
                    record.linkName = '/' + record.Id;
                    record.CheckBool = false;
					console.log(record);                    
                });
                component.set("v.workItemList", records);  
                component.set("v.showWorkItem", true);
            }            
        });
        $A.enqueueAction(action);
    },
})