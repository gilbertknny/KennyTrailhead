({
    doInit: function(component, event, helper) {
        helper.searchCases(component, 'init');
        helper.fetchBackOfficeAgents(component);
    },
    
    searchCase: function(component, event, helper) {
        component.set("v.pageNumber", 1);
        helper.searchCases(component, 'init');
    },
    
    handleAgentChange : function(component, event, helper) {
        var isSelected = event.getSource().get("v.checked");
        var selectedAgentId = event.getSource().get("v.value");
        var selectedAgentIds = component.get("v.selectedAgentIds");
        var selectedCaseIds = component.get("v.selectedCaseIds");
        if(isSelected && (selectedAgentIds.length + 1) > selectedCaseIds.length){
            helper.showToast("Error", "Jumlah agent yang dipilih lebih besar dari jumlah ticket yang dipilih.", "error");
            event.getSource().set("v.checked", false);
        }else if(isSelected && !selectedAgentIds.includes(selectedAgentId)){
            selectedAgentIds.push(selectedAgentId);
        }else if(!isSelected && selectedAgentIds.includes(selectedAgentId)){
            selectedAgentIds.splice(selectedAgentIds.indexOf(selectedAgentId), 1);
        }
        component.set("v.selectedAgentIds", selectedAgentIds);
    },
    
    assignCases : function(component, event, helper) {
        var selectedAgentIds = component.get("v.selectedAgentIds");
        var selectedCaseIds = component.get("v.selectedCaseIds");
        if(selectedAgentIds.length < 1){
            helper.showToast("Error", "Tolong pilih agent terlebih dahulu.", "error");
        }
        if(selectedCaseIds.length < 1){
            helper.showToast("Error", "Tolong pilih case terlebih dahulu.", "error");
        }
        if(selectedAgentIds.length > 0 && selectedCaseIds.length > 0){
            helper.assignCases(component);
        }
    },
    
    handleChecklistAllChange: function(component, event, helper) {
        var checklistAllChecked = event.getSource().get("v.checked");
        var caseCheckboxes = component.find("caseCheckbox");
        if(caseCheckboxes != null){
            if (Array.isArray(caseCheckboxes)) {
                caseCheckboxes.forEach(function(checkbox) {
                    checkbox.set("v.checked", checklistAllChecked);
                });
            } else {
                caseCheckboxes.set("v.checked", checklistAllChecked);
            }
        }

        if(checklistAllChecked){
            component.set("v.selectedCaseIds", component.get("v.allCaseIds"));
        }else{
            component.set("v.selectedCaseIds", []);
        }
    },
    
    handleCaseChange : function(component, event, helper) {
        var isSelected = event.getSource().get("v.checked");
        var selectedCaseId = event.getSource().get("v.value");
        var selectedCaseIds = component.get("v.selectedCaseIds");
        if(isSelected && !selectedCaseIds.includes(selectedCaseId)){
            selectedCaseIds.push(selectedCaseId);
        }else if(!isSelected && selectedCaseIds.includes(selectedCaseId)){
            selectedCaseIds.splice(selectedCaseIds.indexOf(selectedCaseId), 1);
        }
        
        var totalRecords = component.get("v.totalRecords");
        var checkAll = component.find("allCaseCheckbox");
        if(selectedCaseIds.length == totalRecords){
            checkAll.set("v.checked", true);
        }else if(selectedCaseIds.length != totalRecords){
            checkAll.set("v.checked", false);
        }
        component.set("v.selectedCaseIds", selectedCaseIds);
    },

    goToCaseDetail: function(component, event, helper) {
        var caseId = event.currentTarget.dataset.id;
        helper.navigateToRecord(component, caseId);
    },

    nextPage: function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber + 1);
        helper.searchCases(component);
    },

    previousPage: function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber - 1);
        helper.searchCases(component);
    }
})