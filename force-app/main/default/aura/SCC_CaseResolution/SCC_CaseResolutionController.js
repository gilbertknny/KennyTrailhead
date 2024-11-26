({
    myAction : function(component, event, helper) {

    },
    init: function (cmp, event, helper) {
        console.log('Case Resolution');
        cmp.set('v.attcolumns', [
            { label: 'Open', fieldName: 'open', type: 'text'},
            { label: 'File', fieldName: 'file', type: 'text'}
        ]);
        cmp.set('v.aktkarcolumns', [
            { label: 'No Kartu', fieldName: 'nokar', type: 'text'},
            { label: 'Tanggal Trx', fieldName: 'tgltrx', type: 'text'},
            { label: 'Jam Trx', fieldName: 'jamtrx', type: 'text'},
            { label: 'Fitur Name', fieldName: 'fitur', type: 'text'},
            { label: 'Keterangan', fieldName: 'ket', type: 'text'},
            { label: 'Termminal', fieldName: 'terminal', type: 'text'},
            { label: 'Tipe Terminal', fieldName: 'tpterm', type: 'text'},
            { label: 'SeqNum', fieldName: 'seq', type: 'text'},
            { label: 'issuer code', fieldName: 'issue', type: 'text'},
            { label: 'Error Code', fieldName: 'error', type: 'text'},
            { label: 'Status Trx', fieldName: 'status', type: 'text'},
            { label: 'Amount', fieldName: 'amount', type: 'text'}
        ]);
        cmp.set('v.srcaktkarcolumns', [
            { label: 'No Kartu', fieldName: 'nokar', type: 'text'},
            { label: 'Tanggal Trx', fieldName: 'tgltrx', type: 'text'},
            { label: 'Jam Trx', fieldName: 'jamtrx', type: 'text'},
            { label: 'Fitur Name', fieldName: 'fitur', type: 'text'},
            { label: 'Keterangan', fieldName: 'ket', type: 'text'},
            { label: 'Termminal', fieldName: 'terminal', type: 'text'},
            { label: 'Tipe Terminal', fieldName: 'tpterm', type: 'text'},
            { label: 'SeqNum', fieldName: 'seq', type: 'text'},
            { label: 'issuer code', fieldName: 'issue', type: 'text'},
            { label: 'Error Code', fieldName: 'error', type: 'text'},
            { label: 'Status Trx', fieldName: 'status', type: 'text'},
            { label: 'Amount', fieldName: 'amount', type: 'text'}
        ]);
      
        helper.getSrcMutRekData(cmp);
        helper.getSrcRekonData(cmp);
        helper.getSrcBAOData(cmp);
        helper.getSrcKartuData(cmp);
        helper.getSrcEJ(cmp);
        helper.getSrcQueuetransData(cmp);
        helper.initialCase(cmp);

    },
    handleLoad : function(component, event, helper) {
        
    },
    handleSuccess : function(component, event, helper) {
       
    },
    handleChange: function(cmp, event, helper) {
        var firstname = component.find("call_type").get("v.value");
    },
    handleFileUpload : function( component, event, helper ) {
        let selectedFiles = component.find("fileId").get("v.files");
        let selectedFile = selectedFiles[ 0 ];
        console.log('File Name is',selectedFile.name );
        component.set( "v.fileName",selectedFile.name );
        console.log('File Size is', selectedFile.size);
       
    }, 
    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        helper.uploadFile( component, uploadedFiles);
    },
    
    searchRekeningKoran: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchRekeningKoran(component, event);
    },
    navigationRekeningKoran: function(component, event, helper) {
        var sObjectList = component.get("v.listRekeningKoran");
        var end = component.get("v.endPageRekeningKoran");
        var start = component.get("v.startPageRekeningKoran");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        var Paginationlist = [];
        var counter = 0;
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPageRekeningKoran", component.get("v.currentPageRekeningKoran") + 1);
            //helper.next(component, event, sObjectList, end, start, pageSize);
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){ 
                    if(component.find("selectAllIdRekeningKoran").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]);  
                    }
                }
                counter ++ ;
            }
            console.log('Paginationlist',Paginationlist);
            start = start + counter;
            end = end + counter;
            component.set("v.startPageRekeningKoran",start);
            component.set("v.endPageRekeningKoran",end);
            component.set('v.PaginationRekeningKoran', Paginationlist);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPageRekeningKoran", component.get("v.currentPageRekeningKoran") - 1);
            //helper.previous(component, event, sObjectList, end, start, pageSize);
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    if(component.find("selectAllIdRekeningKoran").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]); 
                    }
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.startPageRekeningKoran",start);
            component.set("v.endPageRekeningKoran",end);
            component.set('v.PaginationRekeningKoran', Paginationlist);
        }
    },
    selectAllRekeningKoran: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listRekeningKoran");
        var PaginationList = component.get("v.PaginationRekeningKoran");
        console.log('listRekeningKoran',listOfAllAccounts);
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedRekeningKoran", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedRekeningKoran", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listRekeningKoran", updatedAllRecords);
        component.set("v.PaginationRekeningKoran", updatedPaginationList);
    },
    checkboxRekeningKoran: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedRekeningKoran");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllIdRekeningKoran").set("v.value", false);
        }
        component.set("v.selectedRekeningKoran", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRekeningKoran")) {
            component.find("selectAllIdRekeningKoran").set("v.value", true);
        }
    },
    setRekeningKoran: function(component, event, helper) {
        var allRecords = component.get("v.listRekeningKoran");
        var cs = component.get("v.case"); 
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        console.log("cs",cs);
        console.log("allRecords",allRecords);
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].data);
            }
        }
        console.log("selectedRecords",JSON.stringify(selectedRecords));
        var action = component.get("c.insertRekeningKoran");
        action.setParams({
            "cs" : cs,
            "listrekening" : selectedRecords 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcMutRekData(component);
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },
    searchRekon: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchRekon(component, event);
    },
    navigationRekon: function(component, event, helper) {
        var sObjectList = component.get("v.listRekon");
        var end = component.get("v.endPageRekon");
        var start = component.get("v.startPageRekon");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        var Paginationlist = [];
        var counter = 0;
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPageRekon", component.get("v.currentPageRekon") + 1);
            //helper.next(component, event, sObjectList, end, start, pageSize);
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){ 
                    Paginationlist.push(sObjectList[i]);
                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.startPageRekon",start);
            component.set("v.endPageRekon",end);
            component.set('v.PaginationRekon', Paginationlist);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPageRekon", component.get("v.currentPageRekon") - 1);
            //helper.previous(component, event, sObjectList, end, start, pageSize);
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    Paginationlist.push(sObjectList[i]); 
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.startPageRekon",start);
            component.set("v.endPageRekon",end);
            component.set('v.PaginationRekon', Paginationlist);
        }
    },
    selectAllRekon: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listRekon");
        var PaginationList = component.get("v.PaginationRekon");
        // play a for loop on all records list 
        var cnt = 0;
        console.log('listOfAllAccounts',listOfAllAccounts);
        console.log('PaginationList',PaginationList);
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true && listOfAllAccounts[i].isDisabled == false) {
                listOfAllAccounts[i].isChecked = true;
                cnt++;
            } else {
                listOfAllAccounts[i].isChecked = false;
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true  && PaginationList[i].isDisabled == false) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        console.log('updatedAllRecords',updatedAllRecords);
        console.log('updatedPaginationList',updatedPaginationList);
        component.set("v.selectedRekon", cnt);
        component.set("v.listRekon", updatedAllRecords);
        component.set("v.PaginationRekon", updatedPaginationList);
    },

    checkboxRekon: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedRekon");
        var allRecords = component.get("v.listRekon");
        var PaginationList = component.get("v.PaginationRekon");
        var selectedRecords = [];
        var updatedPaginationList = [];
        if (selectedRec == true) {
            getSelectedNumber++;
            for (var i = 0; i < allRecords.length; i++) {
                var recd = allRecords[i];
                if (recd.isChecked == false) {
                    recd.isDisabled = true;
                }
                selectedRecords.push(recd);
            }
            for (var i = 0; i < PaginationList.length; i++) {
                if (PaginationList[i].isChecked == false) {
                    PaginationList[i].isDisabled = true;
                } 
                updatedPaginationList.push(PaginationList[i]);
            }
        } else {
            getSelectedNumber--;
            //component.find("selectAllIdRekon").set("v.value", false);
            for (var i = 0; i < allRecords.length; i++) {
                var recc = allRecords[i];
                console.log("StatusPenyelesaian",recc.data.StatusPenyelesaian);
                if (recc.data.StatusPenyelesaian != 'Sedang Dikerjakan') {
                    recc.isDisabled = false;
                }
                selectedRecords.push(recc);
            }
            for (var i = 0; i < PaginationList.length; i++) {
                if (PaginationList[i].data.StatusPenyelesaian != 'Sedang Dikerjakan') {
                    PaginationList[i].isDisabled = false;
                } 
                updatedPaginationList.push(PaginationList[i]);
            }
        }
        component.get("v.listRekon",selectedRecords);
        component.set("v.PaginationRekon", updatedPaginationList);
        component.set("v.selectedRekon", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        /*
        if (getSelectedNumber == component.get("v.totalRekon")) {
            component.find("selectAllIdRekon").set("v.value", true);
        }
        */
    },
    setRekon: function(component, event, helper) {
        var allRecords = component.get("v.listRekon");
        var cs = component.get("v.case");
        var tgl = component.get("v.tgl_trx_rekon");
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        console.log("cs",cs);
        console.log("allRecords",allRecords);
        var selectedRecords = [];
        var x=0;
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].data);
            	x++;
            }
        }
        console.log("selectedRecords",JSON.stringify(selectedRecords));
        var action = component.get("c.insertRekon");
        var toastEvent = $A.get("e.force:showToast");
        action.setParams({
            "cs" : cs,
            "listrekon" : selectedRecords,
            "tgl" : tgl
        });
        if(x>1){
            toastEventerror.setParams({
                "title": "Error",
                "message": 'Rekon hanya boleh 1',
                "type" : "error"
            });
            toastEventerror.fire();
        } 
        else{
            action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                var res = response.getReturnValue();
                console.log('RESPONSE_CODE',res.RESPONSE_CODE);
                if(res.RESPONSE_CODE === '00'){
                    helper.getSrcRekonData(component);
                    helper.getSrcQueuetransData(component);
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Success.",
                        "type" : "success"
                    });
                    toastEvent.fire();
                }
                else{
                    var resmsg = '{'+res.ERROR_CODE+' '+res.RESPONSE_MESSAGE+'} - {koneksi ke rekon gagal}';
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": resmsg,
                        "type" : "error"
                    });
                    toastEvent.fire();
                }
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
        }
    },
    searchBAO: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchBAO(component, event);
    },
    navigationBAO: function(component, event, helper) {
        var sObjectList = component.get("v.listBAO");
        var end = component.get("v.endPageBAO");
        var start = component.get("v.startPageBAO");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        var Paginationlist = [];
        var counter = 0;
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPageBAO", component.get("v.currentPageBAO") + 1);
            //helper.next(component, event, sObjectList, end, start, pageSize);
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){ 
                    if(component.find("selectAllIdBAO").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]);  
                    }
                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.startPageBAO",start);
            component.set("v.endPageBAO",end);
            component.set('v.PaginationBAO', Paginationlist);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPageBAO", component.get("v.currentPageBAO") - 1);
            //helper.previous(component, event, sObjectList, end, start, pageSize);
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    if(component.find("selectAllIdBAO").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]); 
                    }
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.startPageBAO",start);
            component.set("v.endPageBAO",end);
            component.set('v.PaginationBAO', Paginationlist);
        }
    },
    selectAllBAO: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listBAO");
        var PaginationList = component.get("v.PaginationBAO");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedBAO", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedBAO", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listBAO", updatedAllRecords);
        component.set("v.PaginationBAO", updatedPaginationList);
    },

    checkboxBAO: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedBAO");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllIdBAO").set("v.value", false);
        }
        component.set("v.selectedBAO", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalBAO")) {
            component.find("selectAllIdBAO").set("v.value", true);
        }
    },
    setBAO: function(component, event, helper) {
        var allRecords = component.get("v.listBAO");
        var cs = component.get("v.case"); 
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        console.log("cs",cs);
        console.log("allRecords",allRecords);
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].data);
            }
        }
        console.log("selectedRecords",JSON.stringify(selectedRecords));
        var action = component.get("c.insertBAO");
        action.setParams({
            "cs" : cs,
            "listbao" : selectedRecords 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcBAOData(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },
    setCase: function(component, event, helper) {
        var cs = component.get("v.case"); 
        var ct = component.get("v.calltypeObj"); 
        var tid = component.get("v.tidObj"); 
        var fid = component.get("v.fituridObj"); 
        var rmk = component.get("v.kol_rmk");
        var wanotif = component.get("v.valwa"); 
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        if(ct==''){
            cs.SCC_Call_Type__c = '';
        }
        else{
            cs.SCC_Call_Type__c = ct.value;
        }
        if(fid==''){
            cs.SCC_Call_Type_Feature__c = '';
        }
        else{
            cs.SCC_Call_Type_Feature__c = fid.value;
        }
        if(tid==''){
            cs.Terminal_ID__c = '';
        }
        else{
            cs.Terminal_ID__c = tid.value;
        }
        cs.SCC_Status_Transaksi__c = wanotif;
        var action = component.get("c.updateCase");
        action.setParams({
            "cs" : cs,
            "rmk" : rmk
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.initialCase(component);
                component.set("v.kol_rmk","");
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            }
        });
        $A.enqueueAction(action);
    },
    selectBAO: function(component, event, helper) {
        var records = component.get("v.baocolumns");
        console.log('records',records);
    },
    selectRekon: function(component, event, helper) {
        var records = component.get("v.rekoncolumns");
        console.log('records',records);
    },
    selectRekeningKoran: function(component, event, helper) {
        var records = component.get("v.mutrekcolumns");
        console.log('records',records);
    },
    deletedBAO: function(component, event, helper) {
        var records = component.get("v.baocolumns");
        var action = component.get("c.deleteBAO");
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        action.setParams({
            "listbao" : records 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcBAOData(component);
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },
    deletedRekon: function(component, event, helper) {
        var records = component.get("v.rekoncolumns");
        var action = component.get("c.deleteRekon");
        var cs = component.get("v.case"); 
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        action.setParams({
            "listrek" : records,
            "cs" : cs 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcRekonData(component);
                helper.getSrcQueuetransData(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },
    deletedRekeningKoran: function(component, event, helper) {
        var records = component.get("v.mutrekcolumns");
        var action = component.get("c.deleteRekeningKoran");
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        action.setParams({
            "listrek" : records 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcMutRekData(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },
    changedate: function(component, event, helper){
        var date  = event.getSource().get("v.value");
        var varDate = new Date(date); //dd-mm-YYYY
        var today = new Date();
        if(varDate > today) {
            //Do something..
            var toastEvent3 = $A.get("e.force:showToast");
            toastEvent3.setParams({
                "title": "Error",
                "message": "Tanggal tidak boleh lebih dari hari ini",
                "type" : "error"
            });
            toastEvent3.fire();
        }
    },
    changedatestart: function(component, event, helper){
        helper.changedatestart(component, event);
    },
    changedateend: function(component, event, helper){
        helper.changedateend(component, event);
    },
    

    // Addtional Code By : Herbing
    // Start

    searchAktivitasKartu: function (component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchAktivitasKartu(component, event);
    },
    
    checkboxAktivitasKartu: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedKartu");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllIdKartu").set("v.value", false);
        }
        component.set("v.selectedKartu", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalAktivitasKartu")) {
            component.find("selectAllIdKartu").set("v.value", true);
        }
    },

    setAktivitasKartu: function(component, event, helper) {
        var allRecords = component.get("v.listAktivitasKartu");
        var cs = component.get("v.case"); 
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].data);
            }
        }
        console.log("selectedRecords",JSON.stringify(selectedRecords));
        var action = component.get("c.insertAktivitasKartu");
        action.setParams({
            "cs" : cs,
            "listrekening" : selectedRecords,
            "msg" :  allRecords[0].description
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcKartuData(component);
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },

    selectAllAktivitasKartu: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listAktivitasKartu");
        var PaginationList = component.get("v.PaginationKartu");
        console.log('listAktivitasKartu',listOfAllAccounts);
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true) {
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedKartu", listOfAllAccounts.length);
            } else {
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedKartu", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listAktivitasKartu", updatedAllRecords);
        component.set("v.PaginationKartu", updatedPaginationList);
    },

    navigationAktivitasKartu: function(component, event, helper) {
        var sObjectList = component.get("v.listAktivitasKartu");
        var end = component.get("v.endPageKartu");
        var start = component.get("v.startPageKartu");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        var Paginationlist = [];
        var counter = 0;
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPageKartu", component.get("v.currentPageKartu") + 1);
            //helper.next(component, event, sObjectList, end, start, pageSize);
            for(var i = end + 1; i < end + pageSize + 1; i++){
                if(sObjectList.length > i){ 
                    if(component.find("selectAllIdKartu").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]);  
                    }
                }
                counter ++ ;
            }
            start = start + counter;
            end = end + counter;
            component.set("v.startPageKartu",start);
            component.set("v.endPageKartu",end);
            component.set('v.PaginationKartu', Paginationlist);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPageKartu", component.get("v.currentPageKartu") - 1);
            //helper.previous(component, event, sObjectList, end, start, pageSize);
            for(var i= start-pageSize; i < start ; i++){
                if(i > -1){
                    if(component.find("selectAllIdKartu").get("v.value")){
                        Paginationlist.push(sObjectList[i]);
                    }else{
                        Paginationlist.push(sObjectList[i]); 
                    }
                    counter ++;
                }else{
                    start++;
                }
            }
            start = start - counter;
            end = end - counter;
            component.set("v.startPageKartu",start);
            component.set("v.endPageKartu",end);
            component.set('v.PaginationKartu', Paginationlist);
        }
    },

    selectAktivitasKartu: function(component, event, helper) {
        var records = component.get("v.Aktivitaskartucolumns");
        console.log('records',records);
        var selectedItems = component.get("v.Aktivitaskartucolumns").filter(item => item.IsDeleted__c);
        component.set("v.noSelectionKartu", selectedItems.length === 0);
    },

    deletedAktivitasKartu: function(component, event, helper) {
        var records = component.get("v.Aktivitaskartucolumns");
        var action = component.get("c.deleteAktivitasKartu");
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        action.setParams({
            "listrek" : records 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                // Reset the selection state
                component.set("v.noSelectionKartu", true);
                helper.getSrcKartuData(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();
                // Refresh the view
                $A.get('e.force:refreshView').fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },

    selectFiturKartu: function(component, event, helper) {
        helper.selectFiturKartu(component, event);
    },

    searchEJ: function(component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        helper.searchEJ(component, event);
    },

    closeModal: function(component, event, helper) {
        // Close the modal
        component.set("v.isOpen", false);
    },

    saveChanges: function(component, event, helper) {
        // Add your save logic here
        // After saving, close the modal
        component.set("v.isOpen", false);
    },

    handleFilter: function(component, event, helper) {
        try {
            helper.filterData(component);
        } catch (error) {
            console.error('Error in handleFilter:', error);
            // Optionally, show an error message to the user
            component.set("v.errorMessage", "An error occurred while filtering. Please try again.");
        }
    },

    checkboxEJ: function(component, event, helper) {
        // Get the index of the checkbox clicked
        //var index = parseInt(event.target.getAttribute('data-index'), 10);
        
        // Call helper to handle checkbox automation
        // console.log("masuk check lagi");
        // helper.automateCheckbox(component, event);

        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedEJ");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllIdEJ").set("v.value", false);
        }
        component.set("v.selectedEJ", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalEJ")) {
            component.find("selectAllIdEJ").set("v.value", true);
        }
    },

    setEJ: function(component, event, helper) {
        component.set("v.isProcessing", true);
        var allRecords = component.get("v.listEJ");
        var cs = component.get("v.case"); 
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].data);
            }
        }
        console.log('Selected Records:', JSON.stringify(selectedRecords));

        // Check if selectedRecords has data
        if (!selectedRecords || selectedRecords.length === 0) {
            throw new Error('No records selected');
        }

        var splitRecords = [];
        selectedRecords.forEach(function(record) {
            // Extract the ejlog content
            var logContent = record.ejlog;
            console.log('Processing log content');
            
            // Split by both \n and \r\n
            var lines = logContent.split(/\r?\n/);
            console.log('Number of lines found:', lines.length);

            lines.forEach(function(line) {
                if (line && line.trim()) {
                    console.log('Processing line:', line.trim());
                    splitRecords.push({
                        ejlog: line.trim()
                    });
                }
            });
        });

        console.log('Total split records:', splitRecords.length);
        console.log('Split Records:', JSON.stringify(splitRecords));

        var action = component.get("c.insertEJ");
        action.setParams({
            "cs" : cs,
            "listrekening" : splitRecords 
        });
        var toastEvent4 = $A.get("e.force:showToast");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                helper.getSrcEJ(component);
                toastEvent4.setParams({
                    "title": "Success!",
                    "message": "Data Berhasil Disimpan.",
                    "type": "success"
                });
                toastEvent4.fire();
                component.set("v.isProcessing", false);
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
                toastEvent4.fire();
                component.set("v.isProcessing", false);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },

    selectEJ: function(component, event, helper) {
        // Prevent multiple rapid executions
        if (component.get("v.processing")) {
            return;
        }
        
        var selected = event.getSource().get("v.value");
        var recordId = event.getSource().get("v.text");
        var records = component.get("v.EJcolumns");
        
        // Update the specific record in the array
        records = records.map(function(record) {
            if (record.Id === recordId) {
                record.IsDeleted__c = selected;
            }
            return record;
        });
        
        // Set the updated records back to the component
        component.set("v.EJcolumns", records);
        
        // Update noSelectionMade attribute
        var hasSelection = records.some(function(record) {
            return record.IsDeleted__c;
        });
        
        component.set("v.noSelectionMade", !hasSelection);
    },

    selectAllEJ: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var listOfAllAccounts = component.get("v.listEJ");
        var PaginationList = component.get("v.PaginationEJ");
        var selectedItems = [];

        // Update all records
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            if (!listOfAllAccounts[i].isDisabled) {
                listOfAllAccounts[i].isChecked = selectedHeaderCheck;
                if (selectedHeaderCheck) {
                    selectedItems.push(i);
                }
            }
        }

        // Update pagination list
        for (var i = 0; i < PaginationList.length; i++) {
            if (!PaginationList[i].isDisabled) {
                PaginationList[i].isChecked = selectedHeaderCheck;
            }
        }

        // Update component attributes
        component.set("v.listEJ", listOfAllAccounts);
        component.set("v.PaginationEJ", PaginationList);
        component.set("v.selectedItems", selectedItems);
        component.set("v.selectedEJ", selectedItems.length);
    },

    deletedEJ: function(component, event, helper) {
        var records = component.get("v.EJcolumns");
        var action = component.get("c.deleteEJ");
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        action.setParams({
            "listrek" : records 
        });
        console.log('record deleted :', records);
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            console.log('return',response.getReturnValue());
            if (state === "SUCCESS"){
                // Reset the selection state
                component.set("v.noSelectionMade", true);
                helper.getSrcEJ(component);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Success.",
                    "type" : "success"
                });
                toastEvent.fire();

                // Refresh the view
                $A.get('e.force:refreshView').fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action); 
    },

    highlightEJ: function(component, event, helper) {
        if (component.get("v.processing")) {
            return;
        }
        
        // Set processing flag
        component.set("v.processing", true);

        var records = component.get("v.EJcolumns");
        var action = component.get("c.updateEJ");
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));
        var selectedRecords = [];
        records.forEach(function(record) {
            if(record.IsDeleted__c) {
                selectedRecords.push(record);
            }
        });
        action.setParams({
            "ejList" : selectedRecords 
        });
        console.log('record EJ selected :', JSON.stringify(selectedRecords));
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS"){
                // Reset the selection state
                component.set("v.noSelectionMade", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record berhasil di update.",
                    "type" : "success"
                });
                toastEvent.fire();

                // Refresh the view
                helper.getSrcEJ(component);
                $A.get('e.force:refreshView').fire();
            }
            else{
                var errors = response.getError();
                helper.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            component.set("v.processing", false);
        });
        $A.enqueueAction(action); 
    },

    deletedAllEJ: function(component, event, helper) {
        component.set("v.loaded", false);
        console.log("awal",component.get("v.loaded"));

        // Get the case ID from the component
        var caseId = component.get("v.recordId");  // Assuming you're using force:hasRecordId

        // Call the Apex method
        var action = component.get("c.deleteAllEJRecords");
        action.setParams({ caseId : caseId });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Reset the selection state
                component.set("v.noSelectionMade", true);
                helper.getSrcEJ(component);
                var result = response.getReturnValue();
                
                // Show a toast message with the result
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Delete Operation",
                    "message": result,
                    "type": result.startsWith("Error") ? "error" : "success"
                });
                toastEvent.fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                var message = "Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Show an error toast
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Proses hapus data EJ error: " + message,
                    "type": "error"
                });
                toastEvent.fire();
            }
            // Set loading to false
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
    },

    navigationEJ: function(component, event, helper) {
        var sObjectList = component.get("v.listEJ");  // This now contains all filtered data
        var end = component.get("v.endPageEJ");
        var start = component.get("v.startPageEJ");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        var selectedItems = component.get("v.selectedItems") || [];
        console.log('selectedItems :',selectedItems.length);
        console.log('Total data length:', sObjectList.length);
        console.log('Current start:', start, 'Current end:', end);

        if (whichBtn == 'next') {
            start = end + 1;
            end = Math.min(start + pageSize - 1, sObjectList.length - 1);
        } else if (whichBtn == 'previous') {
            end = start - 1;
            start = Math.max(end - pageSize + 1, 0);
        }

        console.log('New start:', start, 'New end:', end);

        var Paginationlist = sObjectList.slice(start, end + 1).map(function(record, index) {
            var globalIndex = start + index;
            return Object.assign({}, record, {
                isChecked: selectedItems.indexOf(globalIndex) !== -1,
                visible: record.visible !== undefined ? record.visible : true
            });
        });

        component.set("v.startPageEJ", start);
        component.set("v.endPageEJ", end);
        component.set('v.PaginationEJ', Paginationlist);

        var currentPage = Math.floor(start / pageSize) + 1;
        component.set("v.currentPageEJ", currentPage);

        console.log('Current page:', currentPage);
        console.log('Page data length:', Paginationlist.length);
    }
    //END Herbing
})