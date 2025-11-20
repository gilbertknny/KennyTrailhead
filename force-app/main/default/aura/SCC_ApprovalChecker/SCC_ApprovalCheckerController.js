({
    doInit : function(component, event, helper) {
        helper.fetchCases(component,helper);
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
    goToCaseDetail : function(component, event, helper) {
        var caseId = event.currentTarget.dataset.id;
        helper.navigateToRecord(component, caseId);
    },
    approveTicket: function(component, event, helper) {
        helper.approveSelectedTickets(component);
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
            action.setParams({
                ticketIds: selectedCases
            });

            action.setCallback(this, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    // Perbarui tampilan kasus setelah perubahan status
                    helper.fetchCases(component);
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
        helper.searchCases(component);
    },
    approveTicket: function(component, event, helper) {
        helper.approveSelectedTickets(component);
    }
})