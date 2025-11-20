({
    searchCases: function(component, type) {
        component.set('v.isLoading', true);
        var action = component.get("c.getSearchCases");
        
        var searchTanggalKomplain = component.get("v.searchTanggalKomplain");
        if (searchTanggalKomplain) {
            var dateObj = new Date(searchTanggalKomplain);
            searchTanggalKomplain = dateObj.toISOString().split('T')[0];
        }
        
        action.setParams({
            "pageNumber": component.get("v.pageNumber"),
            "pageSize": component.get("v.pageSize"),
            "calltype": component.get("v.searchCalltype"),
            "noTicket": component.get("v.searchNoTicket"),
            "tanggalKomplain": searchTanggalKomplain
            //"agentId": component.find("selectedAgent").get("v.value") // Pass selected agent Id
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
                result.data.forEach(function(caseItem) {
                    caseItem.CreatedDate = new Date(caseItem.CreatedDate).toISOString().split('T')[0];
                });
                
                component.set("v.cases", result.data);
                component.set("v.totalRecords", result.totalRecords);
                component.set("v.totalPages", result.totalPages);
                
                if(type == 'init'){
                    component.find("allCaseCheckbox").set("v.checked", true);
                    component.set("v.allCaseIds", result.allCaseIds);
                    component.set("v.selectedCaseIds", result.allCaseIds);
                    var caseCheckboxes = component.find("caseCheckbox");
                    if(caseCheckboxes != null){
                        if (Array.isArray(caseCheckboxes)) {
                            caseCheckboxes.forEach(function(checkbox) {
                                checkbox.set("v.checked", true);
                            });
                        } else {
                            caseCheckboxes.set("v.checked", true);
                        }
                    }
                }else{
                    var selectedCaseIds = component.get("v.selectedCaseIds");
                    var caseCheckboxes = component.find("caseCheckbox");
                    if(caseCheckboxes != null){
                        if (Array.isArray(caseCheckboxes)) {
                            caseCheckboxes.forEach(function(checkbox) {
                                if(selectedCaseIds.includes(checkbox.get("v.value"))){
                                    checkbox.set("v.checked", true);
                                }else{
                                    checkbox.set("v.checked", false);
                                }
                            });
                        } else if (selectedCaseIds.includes(caseCheckboxes.get("v.value"))) {
                            caseCheckboxes.set("v.checked", true);
                        } else if (!selectedCaseIds.includes(caseCheckboxes.get("v.value"))) {
                            caseCheckboxes.set("v.checked", false);
                        }
                    }
                }
            } else {
                console.error(response.getError());
                this.showToast('Error', 'Failed to get cases.', 'error');
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    
    fetchBackOfficeAgents: function(component) {
        var action = component.get("c.getBackOfficeAgents");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.backOfficeAgents", response.getReturnValue());
            } else {
                console.error("Error fetching agents: " + state);
                this.showToast('Error', 'Failed to fetch back office agents.', 'error');
            }
        });
        $A.enqueueAction(action);
    },
    
    assignCases : function(component) {
        console.log('assign cases');
        console.log('agentIds');
        console.log(component.get("v.selectedAgentIds"));
        console.log('caseIds');
        console.log(component.get("v.selectedCaseIds"));
        
        var action = component.get("c.assignCasesToAgent");
        action.setParams({
            agentIds: component.get("v.selectedAgentIds"),
            caseIds: component.get("v.selectedCaseIds")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.showToast("Success", "Tolong tunggu seluruh case untuk diproses.", "success");
                var interval = setInterval($A.getCallback(function () {
                    var action2 = component.get("c.getBatchJobStatus");
                    action2.setParams({ jobID: response.getReturnValue() });
                    action2.setCallback(this, function(response2) {
                        var state2 = response2.getState();
                        if (state2 === "SUCCESS") {
                            var job = response2.getReturnValue();
                            var processedPercent = 0;
                            if (job.JobItemsProcessed != 0) {
                                processedPercent = (job.JobItemsProcessed / job.TotalJobItems) * 100;
                            }
                            if (processedPercent == 100) {
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success",
                                    "message": "Seluruh case telah berhasil diproses.",
                                    "type": "success"
                                });
                                toastEvent.fire();
                                $A.get('e.force:refreshView').fire();
                            }
                        } else {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "message": "Gagal memperbarui Case. Silakan coba lagi.",
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                    })
                    $A.enqueueAction(action2);
                }), 2000);
            } else {
                this.showToast("Error", "Failed to assign cases. Please try again.", "error");
            }
        });
        $A.enqueueAction(action);
    },

    navigateToRecord: function(component, recordId) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId
        });
        navEvt.fire();
    },
    
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})