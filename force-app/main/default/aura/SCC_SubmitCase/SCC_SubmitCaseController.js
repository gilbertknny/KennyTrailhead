({
    handleSubmit : function(component, event, helper) {
        // Find the flow and overlay library components
        var flow = component.find("flowData");
        var overlayLib = component.find("overlayLib");
        
        // Get flow API name
        var flowName = component.get("v.flowApiName");
        
        // Create modal content
        $A.createComponent(
            "lightning:flow",
            {
                "aura:id": "flowData",
                "onstatuschange": component.getReference("c.handleFlowStatusChange")
            },
            function(flowComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    // Start the flow in the modal
                    console.log('Record ID Submit :',component.get("v.recordId"));
                    var inputVariables = [
                        {
                            name : "recordId",
                            type : "String",
                            value: component.get("v.recordId")
                        }
                    ];
                    flowComponent.startFlow(flowName, inputVariables);
                    
                    // Create modal
                    overlayLib.showCustomModal({
                        header: "Submit",
                        body: flowComponent,
                        showCloseButton: true,
                        closeCallback: function() {
                            // Optional: Add any cleanup logic when modal is closed
                        }
                    });
                } else {
                    console.error('Error creating flow component: ' + errorMessage);
                }
            }
        );
    },
    
    handleFlowStatusChange : function(component, event, helper) {
        var flowStatus = event.getParam("status");
        console.log('Flow status :', flowStatus);
        // Handle flow completion or other status changes
        if (flowStatus === "FINISHED") {
            // Flow completed successfully
            console.log('Flow');
            console.log('Flow finish');
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
               "recordId": component.get("v.recordId"),
               "isredirect": "true"
            });
            urlEvent.fire();
            // var navigate = component.get("v.navigateFlow");
            console.log('Flow finished');
        } else if (flowStatus === "FAILED") {
            // Handle flow failure
            console.error('Flow failed');
        }
    },

    // Show confirmation dialog when submit button is clicked
    // showConfirmDialog : function(component, event, helper) {
    //     component.set("v.showConfirmDialog", true);
    // },

    // // Handle cancel button in confirmation dialog
    // handleCancel : function(component, event, helper) {
    //     component.set("v.showConfirmDialog", false);
    // }
})