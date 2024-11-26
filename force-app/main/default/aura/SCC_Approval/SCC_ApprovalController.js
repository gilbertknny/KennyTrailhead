({
    doInit : function(component, event, helper) {
        helper.fetchCases(component,'init');
    },
    nextPage : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        helper.searchCases(component);
    },
    previousPage : function(component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        helper.searchCases(component);
    },
    handleChecklistAllChange: function(component, event, helper) {
        /*var checklistAllChecked = event.getSource().get("v.checked");
        component.set("v.checklistAllChecked", checklistAllChecked);

        var caseCheckboxes = component.find("caseCheckbox");
        if (Array.isArray(caseCheckboxes)) {
            caseCheckboxes.forEach(function(checkbox) {
                checkbox.set("v.checked", checklistAllChecked);
            });
        } else {
            //caseCheckboxes.set("v.checked", checklistAllChecked);
        }*/
        
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
    goToCaseDetail : function(component, event, helper) {
        var caseId = event.currentTarget.dataset.id;
        helper.navigateToRecord(component, caseId);
    },
    approveTicket: function(component, event, helper) {
        //helper.approveSelectedTickets(component);
        let selectedCases = [];
        let checkboxes = component.find("caseCheckbox");

        if (Array.isArray(checkboxes)) {
            checkboxes.forEach(function(checkbox) {
                if (checkbox.get("v.checked")) {
                    selectedCases.push(checkbox.get("v.value"));
                }
            });
        } else {
            if (checkboxes.get("v.checked")) {
                selectedCases.push(checkboxes.get("v.value"));
            }
        }

        if (selectedCases.length > 0) {
            let action = component.get("c.approveTickets");
            let userId = $A.get("$SObjectType.CurrentUser.Id"); // Mendapatkan ID pengguna yang sedang login

            action.setParams({
                ticketIds: selectedCases,
                userId: userId
            });

            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Tickets approved successfully.");
                    helper.fetchCases(component);
                    // Refresh halaman setelah tiket disetujui
                    $A.get('e.force:refreshView').fire();
                } else {
                    console.error("Failed to approve tickets: ", response.getError());
                }
            });

            $A.enqueueAction(action);
        } else {
            alert('Pilih setidaknya satu tiket untuk disetujui.');
        }
    },
    searchCase : function(component, event, helper) {
        component.set("v.pageNumber", 1);
        helper.searchCases(component, 'init');
    }
})