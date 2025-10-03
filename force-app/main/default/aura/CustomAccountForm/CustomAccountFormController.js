({
    doInit: function(component, event, helper) {
        alert(component.get('v.recordTypeId'));
        // Get the Flow API name
        const flow = component.find("flowData");
        var inputVariables = [
            {
                name: "recordTypeId",
                type: "String",
                value: component.get("v.recordTypeId") // Pass the record ID to the Flow
            }
        ];
        // Start the Flow
        flow.startFlow("Scr_Editor_Account", inputVariables);
    }
})