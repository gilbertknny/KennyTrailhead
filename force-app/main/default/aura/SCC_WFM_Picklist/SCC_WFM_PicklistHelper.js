({
    optionShift1 : function(component, event) {
        var tgl1 = component.get("v.tanggal1");  
        var usr1 = component.get("v.userid1");
        var jkid1 = component.get("v.jkid1");
        var tgl2 = component.get("v.tanggal2");  
        var usr2 = component.get("v.userid2");
        var jkid2 = component.get("v.jkid2");
        var type = component.get("v.type");
        var req = true;
        var tgl = tgl1;
        if(jkid1 === undefined){
            jkid1 = null;
        }
        if(jkid2 === undefined){
            jkid2 = null;
        }

        this.server(component,'c.getPicklistValue', { "tanggal": tgl, "userid1" : usr1, "isrequester" : req, "jkid1" : jkid1, "jkid2" : jkid2, "type" : type })
        .then(result => { component.set("v.optionsshf1", result); })
        .catch(error => { /* there was an error, deal with it */ });
    },
    optionShift2 : function(component, event) {
        var tgl1 = component.get("v.tanggal2");  
        var usr1 = component.get("v.userid1");
        var jkid1 = component.get("v.jkid1");
        var tgl2 = component.get("v.tanggal2");  
        var usr2 = component.get("v.userid2");
        var jkid2 = component.get("v.jkid2");
        var type = component.get("v.type");
        var req = false;
        var tgl = tgl1;
        if(jkid1 === undefined){
            jkid1 = null;
        }
        if(jkid2 === undefined){
            jkid2 = null;
        }
        if(tgl2){
            tgl = tgl2;
        }
        this.server(component,'c.getPicklistValue', { "tanggal": tgl, "userid1" : usr1, "isrequester" : req, "jkid1" : jkid1, "jkid2" : jkid2, "type" : type })
        .then(result => { component.set("v.optionsshf2", result); })
        .catch(error => { /* there was an error, deal with it */ });

    },
    optionPicklistType : function(component, event) {
        var type = component.get("v.type");  
        this.server(component,'c.getPicklistListSpecial', { 'objnm': 'Request_Change_Shift__c', 'fldnm' : 'Type__c','val' : type })
        .then(result => { component.set("v.optiontype", result); })
        .catch(error => { /* there was an error, deal with it */ });
    },
    selectedShift1 : function(component, event) {
        var jkid1 = component.get("v.jkid1");
        this.server(component,'c.getJadwalKaryawan', { "idjk": jkid1 })
        .then(result => { 
            var jk = result;
            component.set("v.jkid1", jk.Id);
            component.set("v.lokasi1", jk.Lokasi__c);
            component.set("v.userid1", jk.Nama_Karyawan__c);
            component.set("v.shfid1", jk.Opsi_Jadwal__c);
            component.set("v.nama1", jk.Nama_Karyawan__r.Name);

        })
        .catch(error => { /* there was an error, deal with it */ });
    },
    selectedShift2 : function(component, event) {
        var jkid2 = component.get("v.jkid2");
        var action1 = component.get("c.getJadwalKaryawan");
        action1.setParams({
            "idjk": jkid2   
        });
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            console.log('Jadwal Kerja 2: ',response1.getReturnValue());
            if(state1 === "SUCCESS") {
                var jk = response1.getReturnValue();
                component.set("v.jkid2", jk.Id);
                component.set("v.lokasi2", jk.Lokasi__c);
                component.set("v.userid2", jk.Nama_Karyawan__c);
                component.set("v.shfid2", jk.Opsi_Jadwal__c);
                component.set("v.nama2", jk.Nama_Karyawan__r.Name);
            }
        });
        $A.enqueueAction(action1);
    },
    selectedUser1 : function(component, event) {
        var userid1 = component.get("v.userid1");
        this.server(component,'c.getUser', { "idus": userid1 })
        .then(result => { 
            var us1 = result;
            component.set("v.userid1", us1.Id);
            component.set("v.nama1", us1.Name); 
        })
        .catch(error => { /* there was an error, deal with it */ });
    },
    selectedUser2 : function(component, event) {
        var userid2 = component.get("v.userid2");
        this.server(component,'c.getUser', { "idus": userid2 })
        .then(result => { 
            var us2 = result;
            component.set("v.userid2", us2.Id);
            component.set("v.nama2", us2.Name);
        })
        .catch(error => { /* there was an error, deal with it */ });
    },
    selecttype : function(component, event) {
        var type = component.get("v.type"); 
        var tgl1 = component.get("v.tanggal1");
        console.log("type",type);
        if(type){
            component.set("v.typechs",true);
            if(type=='Request Shift'){
                component.set("v.tglshw2",false);
                component.set("v.tanggal2",tgl1);
                this.optionShift2(component, event);
            }
            else{
                component.set("v.tglshw2",true);
            }
            if(type=='Request Off'){
                component.set("v.typechs2",false);
            }
            else{
                component.set("v.typechs2",true);
            }
        }
        else{
            component.set("v.typechs",false);
            component.set("v.typechs2",false);
        }
    },
    server: function(component, actionName, params) {
        return new Promise($A.getCallback((resolve, reject) => {
            var action = component.get(actionName);
            params && action.setParams(params);
            action.setCallback(this, result => {
                console.log('state',result.getState());
                console.log('return',result.getReturnValue());
                switch (result.getState()) {
                    case "DRAFT":
                    case "SUCCESS":
                        resolve(result.getReturnValue());
                        break;
                    default:
                        reject(result.getError());
                }
            });
            $A.enqueueAction(action);
        }));
    }
})