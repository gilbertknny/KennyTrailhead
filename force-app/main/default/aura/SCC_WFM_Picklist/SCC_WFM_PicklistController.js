({
    doinit : function(component, event, helper) {
        helper.optionPicklistType(component, event);
        helper.selectedUser1(component, event);
        helper.selectedUser2(component, event);
        helper.selecttype(component, event);
        helper.optionShift1(component, event);
        helper.optionShift2(component, event);
    },
    selecttype : function(component, event, helper) {
        helper.selecttype(component, event);
    },
    optionShift1 : function(component, event, helper) {
        helper.optionShift1(component, event);
    },
    optionShift2 : function(component, event, helper) {
        helper.optionShift2(component, event);
    },
    selectedShift1 : function(component, event, helper) {
        helper.selectedShift1(component, event);
        helper.selecttype(component, event);
    },
    selectedShift2 : function(component, event, helper) {
        helper.selectedShift2(component, event);
    }
})