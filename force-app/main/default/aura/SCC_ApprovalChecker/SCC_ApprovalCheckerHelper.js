({
    fetchCases: function(component) {
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
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
    
                // Format tanggal sebelum diset ke atribut
                result.caseList.forEach(function(caseItem) {
                    caseItem.CreatedDate = new Date(caseItem.CreatedDate).toISOString().split('T')[0];
                });
    
                component.set("v.cases", result.caseList);
                component.set("v.totalRecords", result.totalRecords);
                component.set("v.totalPages", result.totalPages);
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
                    this.fetchCases(component); // Refresh the case list
                } else {
                    console.error(response.getError());
                }
            });
            $A.enqueueAction(action);
        } else {
            this.showToast("Error", "Pilih setidaknya satu tiket untuk disetujui.", "error");
        }
    },

    searchCases: function(component) {
        var action = component.get("c.getSearchCases");

        var pageNumber = component.get("v.pageNumber");
        var pageSize = component.get("v.pageSize");
        var searchCalltype = component.get("v.searchCalltype");
        var searchNoTicket = component.get("v.searchNoTicket");
        var searchTanggalKomplain = component.get("v.searchTanggalKomplain");
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
                } else {
                    console.error(response.getError());
                }
            });
            $A.enqueueAction(action);
        }
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
    }
})