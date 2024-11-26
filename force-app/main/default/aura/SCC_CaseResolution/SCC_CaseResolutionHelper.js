({
    helperMethod : function() {

    },
    initialCase : function(component){
        var csid = component.get("v.recordId");  
        var action1 = component.get("c.getCaseDetail");
        action1.setParams({
            "idcs": csid   
        });
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            console.log('Case',response1.getReturnValue());
            if(state1 === "SUCCESS") {
                component.set("v.case", response1.getReturnValue());
                var cs = component.get("v.case");
                var filrec = "";
                if (cs.SCC_Call_Type__c === undefined) {
                    console.log('SCC_Status_Transaksi__c',cs.SCC_Status_Transaksi__c);
                    component.set("v.valwa",'');
                }
                else{
                    component.set("v.valwa",cs.SCC_Status_Transaksi__c);
                }

                var action2 = component.get("c.getCallTypeDetail");
                if (cs.SCC_Call_Type__c === undefined) {
                    console.log('SCC_Call_Type__c',cs.SCC_Call_Type__c);
                }else{
                    action2.setParams({
                        "idcs": cs.SCC_Call_Type__c   
                    });
                    action2.setCallback(this, function(response2) {
                        var state2 = response2.getState();
                        console.log('Call Type',response2.getReturnValue());
                        if(state2 === "SUCCESS") {
                            component.set("v.calltypeObj", response2.getReturnValue());
                        }
                        else{
                            component.set("v.filrec","");
                        }
                    });
                    $A.enqueueAction(action2);
                }

                if (cs.SCC_Call_Type_Feature__c === undefined) {
                    console.log('SCC_Call_Type_Feature__c',cs.SCC_Call_Type_Feature__c);
                }else{
                    var action3 = component.get("c.getFiturDetail");
                    action3.setParams({
                        "idcs": cs.SCC_Call_Type_Feature__c   
                    });
                    action3.setCallback(this, function(response3) {
                        var state3 = response3.getState();
                        console.log('Fitur',response3.getReturnValue());
                        if(state3 === "SUCCESS") {
                            component.set("v.fituridObj", response3.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action3);
                }

                if (cs.Terminal_ID__c === undefined) {
                    console.log('Terminal_ID__c',cs.Terminal_ID__c);
                }else{
                    var action4 = component.get("c.getTerminalDetail");
                    action4.setParams({
                        "idcs": cs.Terminal_ID__c   
                    });
                    action4.setCallback(this, function(response4) {
                        var state4 = response4.getState();
                        console.log('Terminal',response4.getReturnValue());
                        if(state4 === "SUCCESS") {
                            component.set("v.tidObj", response4.getReturnValue());
                            var tidobj = component.get("v.tidObj");
                            component.set("v.tid", tidobj.label);
                        }
                    });
                    $A.enqueueAction(action4);
                }
                
                if (cs.SCC_Account_Number__c === undefined) {
                    console.log('SCC_Account_Number__c',cs.SCC_Account_Number__c);
                }else{
                    var action5 = component.get("c.CustomerProfileDetail");
                    action5.setParams({
                        "cs": cs   
                    });
                    action5.setCallback(this, function(response5) {
                        var state5 = response5.getState();
                        console.log('Customer Profile',response5.getReturnValue());
                        if(state5 === "SUCCESS") {
                            component.set("v.cuspro", response5.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action5);
                }

                if(cs.SCC_Status_Transaksi__c=='Berhasil' || cs.SCC_Status_Transaksi__c=='Gagal'){
                    var action6 = component.get("c.getNotifWA");
                    action6.setParams({
                        "cs": cs   
                    });
                    action6.setCallback(this, function(response6) {
                        var state6 = response6.getState();
                        console.log('isiwa',response6.getReturnValue());
                        if(state6 === "SUCCESS") {
                            component.set("v.isiwa", response6.getReturnValue());
                        }
                    });
                    $A.enqueueAction(action6);
                }
                else{
                    component.set("v.isiwa", "");
                }
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action1);
    },
    uploadFile : function(component, uploadedFiles){
        var csid = component.get("v.recordId");
        for(var i = 0; i<uploadedFiles.length;i++){
            var file = uploadedFiles[i];
            console.log('contentBodyId',file.contentBodyId);
            console.log('contentVersionId',file.contentVersionId);
            console.log('documentId',file.documentId);
            console.log('mimeType',file.mimeType);
            console.log('name',file.name);
            var action = component.get("c.insertFile");
            action.setParams({
                "csid": csid,
                "condocid" : file.documentId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                console.log(response.getReturnValue());
                if (state === "SUCCESS"){
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
                    this.parseErrorMsg(errors);
                }
            });
            $A.enqueueAction(action);
        }
        $A.get('e.force:refreshView').fire();
    },
    getSrcMutRekData : function(component) {
        var csid = component.get("v.recordId");  
        var action = component.get("c.getListRekeningKoran");
        action.setParams({
            "idcs": csid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.mutrekcolumns",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
    },
    getSrcRekonData : function(component) {
        var csid = component.get("v.recordId");  
        var action = component.get("c.getListRekon");
        action.setParams({
            "idcs": csid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.rekoncolumns",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
    },
    getSrcBAOData : function(component) {
        var csid = component.get("v.recordId");  
        var action = component.get("c.getListBAO");
        action.setParams({
            "idcs": csid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.baocolumns",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
    },
    getSrcQueuetransData : function(component) {
        console.log('getSrcQueuetransData');
        var csid = component.get("v.recordId"); 
        console.log('csid:'+csid);
        var action = component.get("c.getListQueuetrans");
        action.setParams({
            "idcs": csid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.quetrncolumns",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
    },
    searchRekeningKoran : function(component,event){
        var action = component.get("c.getRekeningKoran");
        var cs = component.get("v.case");
        var tgl_awal = component.get("v.tgl_awal");
        var tgl_akhir = component.get("v.tgl_akhir");
        var varawal = new Date(tgl_awal);
        varawal.setHours(0, 0, 0, 0);
        var varakhir = new Date(tgl_akhir);
        varakhir.setHours(0, 0, 0, 0);
        var today = new Date();
        component.set("v.currentPageRekeningKoran",1);
        console.log("currentPageRekeningKoran",component.get("v.currentPageRekeningKoran"));
        console.log('Nomor Kartu',cs.SCC_Account_Number__c);
        console.log('tgl awal',tgl_awal);
        console.log('tgl akhir',tgl_akhir);
        var toastEvent4 = $A.get("e.force:showToast");
        if(cs.SCC_Account_Number__c === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Nomor Rekening tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(tgl_awal == null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(tgl_akhir == null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Akhir tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(varawal > today) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh lebih besar dari hari ini",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(varakhir > today) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Akhir tidak boleh lebih besar dari hari ini",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(varawal > varakhir) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh lebih besar dari Tanggal Akhir",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            action.setParams({
                "accnum": cs.SCC_Account_Number__c,
                "strdt" : tgl_awal,
                "enddt" : tgl_akhir,
                "cs"    : cs  
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                console.log(response.getReturnValue());
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes.length > 0){
                        component.set('v.listRekeningKoran', oRes);
                        var pageSize = component.get("v.pageSize");
                        var totalRecordsList = oRes;
                        var totalLength = totalRecordsList.length ;
                        component.set("v.totalRekeningKoran", totalLength);
                        component.set("v.startPageRekeningKoran",0);
                        component.set("v.endPageRekeningKoran",pageSize-1);
                        
                        var PaginationLst = [];
                        for(var i=0; i < pageSize; i++){
                            if(component.get("v.listRekeningKoran").length > i){
                                PaginationLst.push(oRes[i]);    
                            } 
                        }
                        component.set('v.PaginationRekeningKoran', PaginationLst);
                        component.set("v.selectedRekeningKoran" , 0);
                        component.set("v.totalPagesRekeningKoran", Math.ceil(totalLength / pageSize));    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }else{
                        //component.set("v.bNoRecordsFoundRekeningKoran" , true);
                        component.set("v.listRekeningKoran", []);
                        component.set("v.totalRekeningKoran", 0);
                        component.set("v.startPageRekeningKoran",0);
                        component.set("v.endPageRekeningKoran",0);
                        component.set('v.PaginationRekeningKoran', []);
                        component.set("v.selectedRekeningKoran" , 0);
                        component.set("v.totalPagesRekeningKoran", 0);
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Warning",
                            "message": "Data Not Found.",
                            "type" : "warning"
                        });
                        toastEvent2.fire();
                    } 
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            });
            $A.enqueueAction(action); 
        }
    },
    searchRekon : function(component,event){
        var action = component.get("c.getRekon");
        var cs = component.get("v.case");
        var tgl = component.get("v.tgl_trx_rekon");
        var tid = component.get("v.tidObj");
        var ct = component.get("v.calltypeObj");
        var vartgl = new Date(tgl);
        component.set("v.currentPageRekon",1);
        console.log("currentPageRekon",component.get("v.currentPageRekon"));
        vartgl.setHours(0, 0, 0, 0);
        var today = new Date();
        var toastEvent4 = $A.get("e.force:showToast");
        console.log("tid",tid.value);
        console.log("ct",ct.value);
        if(tid.value === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "TID tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(ct.value === undefined) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Case Type tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(tgl == null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Transaksi tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(vartgl > today) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Transaksi tidak boleh lebih besar dari hari ini",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            action.setParams({
                "cs": cs,
                "tgl" : tgl,
                "trmid" : tid.label,
                "ctid" : ct.label   
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                console.log(response.getReturnValue());
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes.length > 0){
                        component.set('v.listRekon', oRes);
                        var pageSize = component.get("v.pageSize");
                        var totalRecordsList = oRes;
                        var totalLength = totalRecordsList.length ;
                        component.set("v.totalRekon", totalLength);
                        component.set("v.startPageRekon",0);
                        component.set("v.endPageRekon",pageSize-1);
                        
                        var PaginationLst = [];
                        for(var i=0; i < pageSize; i++){
                            if(component.get("v.listRekon").length > i){
                                PaginationLst.push(oRes[i]);    
                            } 
                        }
                        component.set('v.PaginationRekon', PaginationLst);
                        component.set("v.selectedRekon" , 0);
                        component.set("v.totalPagesRekon", Math.ceil(totalLength / pageSize));    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }else{
                        //component.set("v.bNoRecordsFoundRekon" , true);
                        
                        component.set("v.listRekon", []);
                        component.set("v.totalRekon", 0);
                        component.set("v.startPageRekon", 0);
                        component.set("v.endPageRekon", 0);
                        component.set("v.PaginationRekon", []);
                        component.set("v.selectedRekon", 0);
                        component.set("v.totalPagesRekon", 0);    
                        
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Warning",
                            "message": "Data Not Found.",
                            "type" : "warning"
                        });
                        toastEvent2.fire();
                    } 
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            });
            $A.enqueueAction(action); 
        }
    },
    searchBAO : function(component,event){
        var action = component.get("c.getBAO");
        var cs = component.get("v.case");
        var tgl = component.get("v.tgl_trx_bao");
        var tid = component.get("v.tidObj");
        var ct = component.get("v.calltypeObj");
        component.set("v.currentPageBAO",1);
        console.log("currentPageBAO",component.get("v.currentPageBAO"));
        var vartgl = new Date(tgl);
        vartgl.setHours(0, 0, 0, 0);
        var today = new Date();
        var toastEvent4 = $A.get("e.force:showToast");
        if(tid.value === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "TID tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(vartgl > today && tgl!=null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Transaksi tidak boleh lebih besar dari hari ini",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            action.setParams({
                "tgl" : tgl,
                "trmid" : tid.label 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                console.log(response.getReturnValue());
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes.length > 0){
                        component.set('v.listBAO', oRes);
                        var pageSize = component.get("v.pageSize");
                        var totalRecordsList = oRes;
                        var totalLength = totalRecordsList.length ;
                        component.set("v.totalBAO", totalLength);
                        component.set("v.startPageBAO",0);
                        component.set("v.endPageBAO",pageSize-1);
                        
                        var PaginationLst = [];
                        for(var i=0; i < pageSize; i++){
                            if(component.get("v.listBAO").length > i){
                                PaginationLst.push(oRes[i]);    
                            } 
                        }
                        component.set('v.PaginationBAO', PaginationLst);
                        component.set("v.selectedBAO" , 0);
                        component.set("v.totalPagesBAO", Math.ceil(totalLength / pageSize));    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                    }else{
                        //component.set("v.bNoRecordsFoundBAO" , true);
                        
                        component.set("v.listBAO", []);
                        component.set("v.totalBAO", 0);
                        component.set("v.startPageBAO", 0);
                        component.set("v.endPageBAO", 0);
                        component.set("v.PaginationBAO", PaginationLst);
                        component.set("v.selectedBAO", 0);
                        component.set("v.totalPagesBAO", 0);
                        
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Warning",
                            "message": "Data Not Found.",
                            "type" : "warning"
                        });
                        toastEvent2.fire();
                    } 
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
            });
            $A.enqueueAction(action); 
        }
    },
    changedatestart: function(component, event){
        var date  = event.getSource().get("v.value");
        var tglakhir = component.get("v.tgl_akhir");
        var varDate = new Date(date);
        varDate.setHours(0, 0, 0, 0);
        var vartglakhir = new Date(tglakhir); 
        vartglakhir.setHours(0, 0, 0, 0);
        var today = new Date();
        console.log("date",date);
        console.log("varDate",varDate);
        console.log("vartglakhir",vartglakhir);
        console.log("tglakhir",tglakhir);
        console.log("today",today);
        var toastEvent3 = $A.get("e.force:showToast");
        if(varDate > today) {
            toastEvent3.setParams({
                "title": "Error",
                "message": "Tanggal tidak boleh lebih dari hari ini",
                "type" : "error"
            });
            toastEvent3.fire();
        }
        else if(varDate > vartglakhir && tglakhir!=null){
            toastEvent3.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh lebih besar dari Tanggal Akhir",
                "type" : "error"
            });
            toastEvent3.fire();
        }
    },
    changedateend: function(component, event){
        var date  = event.getSource().get("v.value");
        var tglawal = component.get("v.tgl_awal");
        var varDate = new Date(date); 
        varDate.setHours(0, 0, 0, 0);
        var vartglawal = new Date(tglawal); //dd-mm-YYYY
        vartglawal.setHours(0, 0, 0, 0);
        var today = new Date();
        console.log("date",date);
        console.log("varDate",varDate);
        console.log("vartglawal",vartglawal);
        console.log("tglawal",tglawal);
        console.log("today",today);
        var toastEvent3 = $A.get("e.force:showToast");
        if(varDate > today) {
            toastEvent3.setParams({
                "title": "Error",
                "message": "Tanggal tidak boleh lebih dari hari ini",
                "type" : "error"
            });
            toastEvent3.fire();
        }
        else if(varDate < vartglawal  && tglawal!=null){
            toastEvent3.setParams({
                "title": "Error",
                "message": "Tanggal Akhir tidak boleh lebih kecil dari Tanggal Awal",
                "type" : "error"
            });
            toastEvent3.fire();
        }
    },
    parseErrorMsg: function(errors){
        console.log("errors",errors);
        var msg = '';
        if (errors[0] ) {
            for(var i=0;i<errors.length;i++){
                if(errors[i].message){
                    msg = msg+'\n'+errors[i].message;
                }
                else if(Object.keys(errors[i].fieldErrors).length>0){
                    console.log('fieldErrors',errors[i].fieldErrors);
                    msg = msg+'\n'+JSON.stringify(errors[i].fieldErrors);
                    msg = this.parseFieldErrors(msg);
                }
                    else if(errors[i].pageErrors.length>0){
                        console.log('pageErrors',errors[i].pageErrors);
                        for(var j=0;j<errors[i].pageErrors.length;j++){
                            console.log('message',errors[i].pageErrors[j].message);
                            msg = msg+'\n'+errors[i].pageErrors[j].message;
                        }
                    }
            }
            var toastEvent3 = $A.get("e.force:showToast");
            toastEvent3.setParams({
                "title": "Error",
                "message": msg,
                "type" : "error"
            });
            toastEvent3.fire();
        }
    },
    parseFieldErrors: function(msg){
        //msg = '[{"SCC_Drone_Remark_Update__c":[{"statusCode":"STRING_TOO_LONG","message":"Drone Remark Update: data value too large: uwu"}, {"SCC_Drone_Remark_Update__c":[{"statusCode":"STRING_TOO_LONG","message":"2 Drone Remark Update: data value too large: uwu"}]';                    
        const regex = new RegExp('"message":"([^"]+)"', 'g');
        const regexLimit = new RegExp('(.+) Update: data value too large: ');
        var listErr = [];
        var match;
        while((match = regex.exec(msg)) !== null){
            var errMsg = match[1];
            var match2;
            if((match2 = regexLimit.exec(errMsg)) !== null){
                listErr.push(match2[1] + ' melebihi limit karakter maksimum');
            }else if(match2 == null){
                listErr.push(errMsg);
            }
        }
        if(listErr.length > 0){
            console.log('listerr');
            console.log(listErr);
            msg = listErr.join(", ");
        }
        return msg;
    },

    // Addtional Code By : Herbing
    // Start
    searchAktivitasKartu : function(component,event){
        var action = component.get("c.getAktivitasKartu");
        var cs = component.get("v.case");
        var fiturName = component.get("v.fiturName");
        var tgl_awal = component.get("v.tgl_awal");
        var tgl_akhir = component.get("v.tgl_akhir");
        var varawal = new Date(tgl_awal);
        varawal.setHours(0, 0, 0, 0);
        var varakhir = new Date(tgl_akhir);
        varakhir.setHours(0, 0, 0, 0);
        var today = new Date();
        var ct = component.get("v.calltypeObj");
        var fitur = "";
        console.log('fiturName',fiturName);
        if(fiturName === "1"){
            fitur = cs.SCC_Account_Number__c;
        }else if(fiturName === "2"){
            fitur = cs.SCC_Card_Number__c;
        }else if(fiturName === "3"){
            fitur = cs.SCC_Cust_Phone1__c;
        }
        component.set("v.currentPageKartu",1);
        console.log("currentPageKartu",component.get("v.currentPageKartu"));
        var today = new Date();
        var toastEvent4 = $A.get("e.force:showToast");
        console.log("ct",ct.value);
        if(fiturName === '0'){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Fitur harus dipilih",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(ct.value === undefined) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Case Type tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(tgl_awal == null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(tgl_akhir == null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Akhir tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(varawal > today) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh lebih besar dari hari ini",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(varakhir > today) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Akhir tidak boleh lebih besar dari hari ini",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(varawal > varakhir) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Awal tidak boleh lebih besar dari Tanggal Akhir",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            action.setParams({
                "cs": cs,
                "posisiawal": tgl_awal,
                "posisiakhir" : tgl_akhir,
                "fitur" : fiturName,
                "nomor" : fitur,
                "scope" : "1"
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var messg = response;
                console.log(messg);
                console.log("debug");
                console.log(state);
                console.log(response.getReturnValue());
                if (state === "SUCCESS"){
                    var oRes = response.getReturnValue();
                    if(oRes.length > 0){
                        component.set('v.listAktivitasKartu', oRes);
                        var pageSize = component.get("v.pageSize");
                        var totalRecordsList = oRes;
                        var totalLength = totalRecordsList.length ;
                        component.set("v.totalAktivitasKartu", totalLength);
                        component.set("v.startPageKartu",0);
                        component.set("v.endPageKartu",pageSize-1);
                        
                        var PaginationLst = [];
                        for(var i=0; i < pageSize; i++){
                            if(component.get("v.listAktivitasKartu").length > i){
                                PaginationLst.push(oRes[i]);    
                            } 
                        }
                        component.set('v.PaginationKartu', PaginationLst);
                        component.set("v.selectedKartu" , 0);
                        component.set("v.totalPagesKartu", Math.ceil(totalLength / pageSize));    
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "Success.",
                            "type" : "success"
                        });
                        toastEvent.fire();
                        component.set("v.tgl_awal", null);
                        component.set("v.tgl_akhir", null);
                        component.set("v.fiturName", "");
                    }else{
                        //component.set("v.bNoRecordsFoundRekon" , true);
                        
                        component.set("v.listAktivitasKartu", []);
                        component.set("v.totalAktivitasKartu", 0);
                        component.set("v.startPageKartu", 0);
                        component.set("v.endPageKartu", 0);
                        component.set("v.PaginationKartu", []);
                        component.set("v.selectedKartu", 0);
                        component.set("v.totalPagesKartu", 0);    
                        
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Warning",
                            "message": "Data Not Found.",
                            "type" : "warning"
                        });
                        toastEvent2.fire();
                    } 
                }
                else{
                    var errors = response.getError();
                    this.parseErrorMsg(errors);
                }
                component.set("v.loaded", true);
                console.log("akhir",component.get("v.loaded"));
                component.set("v.tgl_awal", null);
                component.set("v.tgl_akhir", null);
                component.set("v.fiturName", "");
            });
            $A.enqueueAction(action); 
        }
    },

    getSrcKartuData : function(component) {
        var csid = component.get("v.recordId");  
        var action = component.get("c.getListAktivitasKartu");
        action.setParams({
            "idcs": csid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.Aktivitaskartucolumns",response.getReturnValue());
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        $A.enqueueAction(action);
    },

    selectFiturKartu : function(component) {
        console.log("masuk sini lagi terus");
        var csid = component.get("v.recordId");
        var cs = component.get("v.case");
        var fitur = component.get("v.fiturName");
        var toastEvent4 = $A.get("e.force:showToast");
        var valueToSet = '';
        console.log(csid);
        console.log(cs);
        console.log(fitur);
        if(fitur === "1"){
            valueToSet = cs.SCC_Account_Number__c; // Set to Nomor Rekening
            if(valueToSet === undefined){
                toastEvent4.setParams({
                    "title": "Error",
                    "message": "Nomor Rekening masih kosong",
                    "type" : "error"
                });
                toastEvent4.fire();
            }
        }else if(fitur === "2"){
            valueToSet = cs.SCC_Card_Number__c; // Set to Nomor Kartu
            if(valueToSet === undefined){
                toastEvent4.setParams({
                    "title": "Error",
                    "message": "Nomor Kartu masih kosong",
                    "type" : "error"
                });
                toastEvent4.fire();
            }
        }else if(fitur === "3"){
            valueToSet = cs.SCC_Cust_Phone1__c; // Set to Nomor Hp
            if(valueToSet === undefined){
                toastEvent4.setParams({
                    "title": "Error",
                    "message": "Nomor Handphone masih kosong",
                    "type" : "error"
                });
                toastEvent4.fire();
            }
        }
        component.find("fieldFitur").set("v.value", valueToSet);
    },

    searchEJ: function(component,event){
        var action = component.get("c.getEJLog");
        var cs = component.get("v.case");
        console.log("masuk sini");
        var tidInput = component.find("tidej");  // Get the component with aura:id="tidej"
        var tid = tidInput.get("v.value");  // Get the value from the input field
        //cs.Terminal_ID__c;
        //console.log(cs);
        // if (tid == null){
        //     tid = '00004444';
        // }
        console.log(tid);
        var dateRequest = component.get("v.tgl_input_awal");
        var varawal = new Date(dateRequest);
        varawal.setHours(0, 0, 0, 0);
        console.log(tid);
        console.log(dateRequest);
        component.set("v.currentPageEJ",1);
        console.log("currentPageEJ",component.get("v.currentPageEJ"));
        var toastEvent4 = $A.get("e.force:showToast");
        if(tid === undefined){
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "TID tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else if(dateRequest == null) {
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
            toastEvent4.setParams({
                "title": "Error",
                "message": "Tanggal Request tidak boleh kosong",
                "type" : "error"
            });
            toastEvent4.fire();
        }
        else{
            // Clear previous data to avoid duplication
            component.set('v.listEJ', []); // Clear the main list data
            component.set('v.PaginationEJ', []); // Clear the pagination data (if any)
            action.setParams({
                "tid" : tid,
                "dateReq" : dateRequest
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                console.log('Response State:', state);
            
                if (state === "SUCCESS") {
                    var oRes = response.getReturnValue(); // Get the response data
                    console.log("oRes:",oRes);
                    if (oRes && oRes.length > 0) {
                        var code = oRes[0].code || null;
                        var message = oRes[0].message || 'No message available';
                        var ejlog = oRes[0].data && oRes[0].data.ejlog ? oRes[0].data.ejlog : 'No EJ log available';
                        
                        console.log('Response Data:', ejlog);
                        console.log('Message:', message);
                        console.log('code:', code);
            
                        if (code === 200) {
                            console.log("success:");
                            // Successful response, set listEJ, and other variables
                            //component.set('v.listEJ', oRes);
                            // var pageSize = component.get("v.pageSize");
                            var totalRecordsList = oRes;
                            var totalLength = totalRecordsList.length;
            
                            component.set("v.totalEJ", totalLength);
                            // component.set("v.startPageEJ",0);
                            // component.set("v.endPageEJ",pageSize-1);

                            // var PaginationLst = [];
                            // for(var i=0; i < pageSize; i++){
                            //     if(component.get("v.listEJ").length > i){
                            //         PaginationLst.push(oRes[i]);    
                            //     } 
                            // }
                            //var limitedRecords = totalRecordsList.slice(0, 2000);
                            //component.set("v.PaginationEJ", totalRecordsList);
                            // var PaginationLst = totalRecordsList.slice(0, pageSize);
                            component.set("v.PaginationEJ", totalRecordsList);
                            component.set("v.listEJ", totalRecordsList);
                            //component.set('v.PaginationEJ', oRes);
                            component.set("v.originalEJData", oRes);
                            component.set("v.originalEJTotal", totalLength);
                            console.log('PaginationEJ',totalRecordsList);
                            // Reset selected EJ and show success toast
                            component.set("v.selectedItems", []);
                            component.set("v.selectedEJ", 0);
                            // component.set("v.totalPagesEJ", Math.ceil(totalLength / pageSize)); 

                            var toastEvent3 = $A.get("e.force:showToast");
                            toastEvent3.setParams({
                                "title": "Success!",
                                "message": "Data retrieved successfully.",
                                "type": "success"
                            });
                            toastEvent3.fire();
                        } else {
                            console.log("errormsg");
                            // Error response from the server
                            var errorMsg = oRes[0].data ? oRes[0].data.message : 'Unknown error occurred';
                            console.log("errorMsg:", errorMsg);
                            component.set("v.listEJ", []);
                            component.set("v.totalEJ", 0);
                            component.set("v.startPageEJ", 0);
                            component.set("v.endPageEJ", 0);
                            component.set('v.PaginationEJ', []);
                            component.set("v.selectedEJ", 0);
                            component.set("v.totalPagesEJ", 0);
                            component.set("v.selectedItems", []);
                            var toastEvent1 = $A.get("e.force:showToast");
                            toastEvent1.setParams({
                                "title": "Data tidak ditemukan.",
                                "message": "Status : " + message + " / Description : " + errorMsg,
                                "type": "warning"
                            });
                            toastEvent1.fire();
                        }
                    } else {
                        console.log("error");
                        // No data returned from the server
                        component.set("v.selectedItems", []);
                        component.set("v.listEJ", []);
                        component.set("v.totalEJ", 0);
                        component.set("v.startPageEJ", 0);
                        component.set("v.endPagEJ", 0);
                        component.set('v.PaginationEJ', []);
                        component.set("v.selectedEJ", 0);
                        component.set("v.totalPagesEJ", 0);
                        
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Warning",
                            "message": "Data Not Found.",
                            "type": "warning"
                        });
                        toastEvent2.fire();
                    }
                } else {
                    // Handle the error response
                    var errors = response.getError();
                    console.log("errors:", errors);
                    this.parseErrorMsg(errors); // You should define a `parseErrorMsg` function for better error handling
                }
            
                // Set loading to false
                component.set("v.loaded", true);
                console.log("Loading state at the end:", component.get("v.loaded"));
            
                // Open the modal
                component.set("v.isOpen", true);
                component.set("v.tgl_input_awal", null);
            });
            
            $A.enqueueAction(action);
        }
    },

    setEJData : function(component) {
        console.log('jalan');
        component.set('v.PaginationEJ',  component.get("v.originalEJData"));
        // Open the modal
        component.set("v.isOpen", true);
        component.set("v.tgl_input_awal", null);
    },

    getSrcEJ : function(component) {
        var csid = component.get("v.recordId");  
        var action = component.get("c.getListEJ");
        action.setParams({
            "idcs": csid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getReturnValue());
            if (state === "SUCCESS"){
                component.set("v.EJcolumns",response.getReturnValue());
                // Refresh the view
                $A.get('e.force:refreshView').fire();
            }
            else{
                var errors = response.getError();
                this.parseErrorMsg(errors);
            }
            component.set("v.loaded", true);
            console.log("akhir",component.get("v.loaded"));
        });
        component.set("v.isOpen", false);
        $A.enqueueAction(action);
    },

    filterData: function(component) {
        console.log("Entering filterData");
        // Reset the selected count to 0
        // component.set("v.selectedEJ", 0);
        var allData = component.get("v.originalEJData");
        var searchKey = component.get("v.filter").toLowerCase();
        var pageSize = component.get("v.pageSize");

        console.log("Search key:", searchKey);

        if (!Array.isArray(allData)) {
            console.error("originalEJData is not an array");
            return;
        }

        var filteredData = searchKey ? 
            allData.filter(item => item.data && item.data.ejlog && 
                item.data.ejlog.toLowerCase().includes(searchKey)) : 
            allData;

        var totalLength = filteredData.length;
        console.log("Filtered data length:", totalLength);

        component.set("v.totalEJ", totalLength);
        component.set("v.startPageEJ", 0);
        component.set("v.endPageEJ", pageSize - 1);
        component.set("v.totalPagesEJ", Math.ceil(totalLength / pageSize));
        component.set("v.currentPageEJ", 1);

        var PaginationLst = filteredData.slice(0, pageSize);

        // Update the full filtered dataset
        component.set('v.listEJ', filteredData);
        
        // Update the current page data
        component.set("v.PaginationEJ", PaginationLst);

        // Count checked items in the current page
        var checkedCount = PaginationLst.reduce((count, obj) => obj.isChecked ? count + 1 : count, 0);
        component.set("v.selectedEJ", checkedCount);

        console.log('Current page data length:', PaginationLst.length);
        console.log('Total filtered data length:', filteredData.length);
    },

    automateCheckbox: function(component, event) {
        // Reset selectedEJ to 0
        //component.set("v.selectedEJ", 0);
        
        var selectedRec = event.getSource().get("v.value");
        console.log("Selected Checkbox Value is: ", selectedRec);

        // Get the index of the current checkbox
        var checkbox = event.getSource();
        var index = parseInt(checkbox.get("v.name"), 10);
        console.log("Selected Checkbox Index: ", index);

        var records = component.get("v.PaginationEJ");
        var allRecords = component.get("v.listEJ");
        var selectedItems = component.get("v.selectedItems") || [];
        if (selectedRec === true) {
            console.log("Entering true state for automation");

            // Check the next 9 boxes (or fewer if we're near the end of the list)
            // for (var i = index + 1; i < Math.min(index + 10, records.length); i++) {
            //     if (!records[i].isDisabled) {
            //         records[i].isChecked = true;
            //     }
            // }
            // for (var i = index; i < Math.min(index + 10, records.length); i++) {
            //     if (!records[i].isDisabled) {
            //         records[i].isChecked = true;
            //         var globalIndex = component.get("v.startPageEJ") + i;
            //         if (!selectedItems.includes(globalIndex)) {
            //             selectedItems.push(globalIndex);
            //         }
            //     }
            // }

            // Only handle the current checkbox
            var globalIndex = component.get("v.startPageEJ") + index;
            if (!selectedItems.includes(globalIndex)) {
                selectedItems.push(globalIndex);
            }
        } else {
            console.log('unselect');
            //component.find("selectAllIdEJ").set("v.value", false);
            component.find("selectAllIdEJ").set("v.value", false);
            var globalIndex = component.get("v.startPageEJ") + index;
            var itemIndex = selectedItems.indexOf(globalIndex);
            if (itemIndex > -1) {
                selectedItems.splice(itemIndex, 1);
            }
        }

        // Count all checked checkboxes and update selectedEJ
        var checkedCount = records.reduce(function(count, obj) {
            return obj.isChecked ? count + 1 : count;
        }, 0);

        // console.log("Number of checked checkboxes: " + checkedCount);
        
        // Update the records in the component
        component.set("v.PaginationEJ", records);
        component.set("v.selectedItems", selectedItems);
        // Update the count of selected checkboxes
        component.set("v.selectedEJ", checkedCount);
        component.set("v.selectedEJ", selectedItems.length);

        console.log("Updated selected number: ", selectedItems);

        // If all checkboxes are checked, set the header checkbox to true
        // if (checkedCount === component.get("v.totalEJ")) {
        //     component.find("selectAllIdEJ").set("v.value", true);
        // }
        if (selectedItems.length === component.get("v.totalEJ")) {
            console.log('slected all');
            component.find("selectAllIdEJ").set("v.value", true);
        }
    },

    generateDummyData: function(numRecords) {
        let dummyData = [];
        for (let i = 0; i < numRecords; i++) {
            dummyData.push({
                code: 200,
                num: i + 1,
                ejlog: '05/14/2023 00:17:39 TRANSACTION DATA (COMPLETED)' + (i + 1),
                isChecked: false
            });
        }
        return dummyData;
    }
    // End
})