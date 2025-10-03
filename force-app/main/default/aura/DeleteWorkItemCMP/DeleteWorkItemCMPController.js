({
    
    init : function(component, event, helper) {
        
        component.set('v.mycolumns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {label: 'Subject', fieldName: 'sf_devops__Subject__c', type: 'text'},
            {label: 'State', fieldName: 'sf_devops__State__c', type: 'text'}            
        ]);
        
        helper.fetchProjects(component, event);
        
    },
    handleProjectSelect : function(component, event, helper) {
        
        var selectedProject = event.getParam('value'); 
        //alert(selectedProject);
        helper.fetchWorkItems(component, event, selectedProject);
        
    },
    handleSelect : function(component, event, helper) {
        
        var selectedRows = event.getParam('selectedRows');
        if(selectedRows.length > 0)
            component.set("v.hideDeleteButton", false);
        if(selectedRows.length == 0)
            component.set("v.hideDeleteButton", true);
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedWorkItems", setRows);
        
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    deleteWorkItems: function(component, event, helper) {
        component.set("v.loaded", true);
        var finalRecords = component.get("v.selectedWorkItems");
        var successMsg = 'Selected ' + finalRecords.length + ' Work Item Deleted';
        console.log(successMsg);
        component.set("v.isModalOpen", false);
        var action = component.get("c.deleteSelectedWorkItem");
        action.setParams({ "wItemList" : finalRecords });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.loaded", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: successMsg,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
        		dismissActionPanel.fire();
            }            
            
        });
        
        $A.enqueueAction(action);
    },
    confirmSelection : function(component, event, helper) {
        component.set("v.isModalOpen", true);
        var records = component.get("v.selectedWorkItems");
    }
    
})