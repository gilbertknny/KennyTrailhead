({
    doInit : function(component, event, helper) {
        var flow = component.find("flowData");
        var flowName = component.get("v.flowName");
        var recordId = component.get("v.recordId");

        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recordId
            }
        ];

        flow.startFlow(flowName, inputVariables);
    },

    handleSave : function(component, event, helper) {
        helper.doSave(component);
    },

    handleCancel : function(component, event, helper) {
        helper.doCancel(component);
    },

    handleStatusChange : function (component, event, helper) {
        var status = event.getParam("status");
        var outputVariables = event.getParam("outputVariables");

        if (status === "FINISHED") {
            var isReadOnly = outputVariables.find(function (variable) {
                return variable.name === "isReadOnly";
            });

            if (isReadOnly && isReadOnly.value) {
                component.set("v.isReadOnly", true);
            }

            if (component.get("v.isReadOnly")) {
                helper.doCancel(component);
            } else {
                helper.doSave(component);
            }
        } else if (status === "CLOSED") {
            helper.doCancel(component);
        }
    }
})