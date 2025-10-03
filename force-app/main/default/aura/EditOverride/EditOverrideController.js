({
    doInit: function(component, event, helper) {
        //alert('Mantapu : '+component.get('v.sObjectName')+'|'+component.get('v.recordId')+'|'+component.get('v.record.Link__c'));
    },
    handleRecordUpdated: function(component, event, helper) {
        const recordId = component.get('v.recordId');
        const sObjectName = component.get('v.sObjectName');
        var PopEditUrl = "/lightning/action/quick/"+sObjectName+".Pop_Edit?objectApiName&context=RECORD_DETAIL&recordId="+recordId+"&backgroundContext=%2Flightning%2Fr%2F"+sObjectName+"%2F"+recordId+"%2Fview";

        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // Record is loaded
            //alert("Record loaded successfully!");
            PopEditUrl = component.get('v.obj.Pop_Edit_Url__c');            
        } else if(eventParams.changeType === "CHANGED") {
            // Record is changed
            alert("Record changed!");
        } else if(eventParams.changeType === "REMOVED") {
            // Record is deleted
            alert("Record removed!");
        } else if(eventParams.changeType === "ERROR") {
            // There's an error in loading or deleting the record
            //alert("Ada Error: " + eventParams.message);
        }
        
        /*
        const urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": PopEditUrl
        });
        urlEvent.fire();
        */
        component.find("navigationService").navigate({ 
            type: "standard__webPage", 
            attributes: { 
                url: PopEditUrl
            } 
        });
        
        //-----------
    }
})