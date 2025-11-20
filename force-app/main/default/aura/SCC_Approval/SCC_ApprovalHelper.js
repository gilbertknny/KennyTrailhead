({
    fetchCases: function(component,type) {
        var action = component.get("c.getInstance");
    
        var currentPage = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
    
        console.log("pageNumber " + currentPage);
    
        action.setParams({
            "pageNumber": currentPage,
            "pageSize": pageSize,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.debug('state',state);
            console.debug('response',response.getReturnValue());
            if (state === "SUCCESS") {
                var result = response.getReturnValue();

                result.caseList.forEach(function(caseItem) {
                    caseItem.CreatedDate = new Date(caseItem.CreatedDate).toISOString().split('T')[0];
                });
    
                component.set("v.cases", result.caseList);
                component.set("v.totalRecords", result.totalRecords);
                component.set("v.totalPages", result.totalPages);
                component.set("v.permissionNFT",result.permissionNFT);
                
                if(type == 'init'){
                    component.find("allCaseCheckbox").set("v.checked", true);
                    component.set("v.allCaseIds", result.allCaseIds);
                    component.set("v.selectedCaseIds", result.allCaseIds);
                    
                    console.log('tes selectedCaseIds');
                    console.log(result.allCaseIds);
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
            }
        });
        $A.enqueueAction(action);
    },    

    changePage: function(component, direction) {
        var action = direction === "next" ? component.get("c.getNextCases") : component.get("c.getPreviousCases");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                this.fetchCases(component);
            } else {
                console.error(response.getError());
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

    approveSelectedTickets: function(component) {
        var selectedCases = [];
        var checkboxes = component.find("caseCheckbox");
        if (!Array.isArray(checkboxes)) {
            checkboxes = [checkboxes];
        }
        checkboxes.forEach(function(checkbox) {
            if (checkbox.get("v.checked")) {
                selectedCases.push(checkbox.get("v.value"));
            }
        });

        if (selectedCases.length > 0) {
            var action = component.get("c.approveTickets");
            action.setParams({
                ticketIds: selectedCases
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    this.showToast("Success", "Tickets approved successfully", "success");
                    this.fetchCases(component); 
                } else {
                    console.error(response.getError());
                }
            });
            $A.enqueueAction(action);
        } else {
            this.showToast("Error", "Pilih setidaknya satu tiket untuk disetujui.", "error");
        }
    },
    searchCases: function(component, type) {
        var action = component.get("c.getSearchCases");

        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var searchCalltype = component.get("v.searchCalltype");
        var searchNoTicket = component.get("v.searchNoTicket");
        var searchTanggalKomplain = component.get("v.searchTanggalKomplain");
        var searchPriority = component.get("v.searchPriority");
        var searchNota = component.get("v.searchNota");
        
        if(new Date(searchTanggalKomplain) > new Date()){
            this.showToast("Error", "Tanggal komplain tidak boleh melebihi hari ini.", "error");
        }else{
            // Konversi tanggal ke format yang sesuai
            if (searchTanggalKomplain) {
                var dateObj = new Date(searchTanggalKomplain);
                searchTanggalKomplain = dateObj.toISOString().split('T')[0];
            }
    
            action.setParams({
                "pageNumber": pageNumber,
                "pageSize": pageSize,
                "calltype": searchCalltype,
                "noTicket": searchNoTicket,
                "tanggalKomplain": searchTanggalKomplain, // Gunakan nilai yang telah dikonversi
                "priority": searchPriority,
                "cekNota": searchNota
            });
    
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var formattedCases = [];
                    var searchNotaValue = component.get("v.searchNota");
    
                    result.data.forEach(function(caseItem) {
                        caseItem.CreatedDate = new Date(caseItem.CreatedDate).toISOString().split('T')[0];
    
                        if ((searchNotaValue === 'Ada Nota' && caseItem.SCC_Count_Queuetrans__c > 0) ||
                            (searchNotaValue === 'Tidak Ada Nota' && caseItem.SCC_Count_Queuetrans__c === 0) ||
                            searchNotaValue === '') {
                            if (!searchTanggalKomplain || caseItem.CreatedDate === searchTanggalKomplain) {
                                formattedCases.push(caseItem);
                            }
                        }
                    });
    
                    component.set("v.cases", formattedCases);
                    component.set("v.totalRecords", result.totalRecords);
                    component.set("v.totalPages", Math.ceil(result.totalRecords / component.get("v.pageSize")));
                    
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
                }
            });
            $A.enqueueAction(action);
        }
    },

    formattedDate: function(result) {
        return result.map(data => {
            return {
                data,
                CreatedDate: CreatedDate.substring(0, 10)
            };
        });
    },

    getSelectedCases: function(component, checkboxId) {
        var selectedCases = [];
        var checkboxes = component.find(checkboxId);
        if (!Array.isArray(checkboxes)) {
            checkboxes = [checkboxes];
        }
        checkboxes.forEach(function(checkbox) {
            if (checkbox.get("v.checked")) {
                selectedCases.push(checkbox.get("v.value"));
            }
        });
        return selectedCases;
    },

    showToast: function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },
    approveTicket: function(component, event, helper) {
        helper.approveSelectedTickets(component);
    }
})