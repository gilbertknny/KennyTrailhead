({
    init : function (component) {
       // Find the component whose aura:id is "flowData"
       var flow = component.find("flowData");
       // In that component, start your flow. Reference the flow's API Name.
       flow.startFlow("WFM_Request_Shift");
    },
                                 
    handleStatusChange : function (component, event) {
       if(event.getParam("status") === "FINISHED") {
          // Get the output variables and iterate over them
          /** 
          var outputVariables = event.getParam("recordId");
          var outputVar;
          for(var i = 0; i < outputVariables.length; i++) {
            outputVar = outputVariables[i];
             // Pass the values to the component's attributes
          }
          **/
        /** 
          var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
        "recordId": outputVar.value,
        "slideDevName": "Detail"
        });
        navEvt.fire();
        */
       }
    }
 })