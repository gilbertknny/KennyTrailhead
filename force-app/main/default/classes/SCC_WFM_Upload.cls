/*
Created by = Femy
UST  = WFM
*/
public with sharing class SCC_WFM_Upload {
    @AuraEnabled
    public static returnvalue uploadFile(String base64, String delimiter,String type) {
        returnvalue reval = new returnvalue();
        if(delimiter=='|'){
            delimiter = '\\|';
        }
        String err = '';
        String result = '';
        Integer x = 0;
        Integer y = 0;
        List<String> listerr = new List<String>();    
        
        Map<String,Jadwal_Karyawan__c> mapjw = new Map<String,Jadwal_Karyawan__c>();
        Map<String,Cuti_Karyawan__c> mapct = new Map<String,Cuti_Karyawan__c>();
        Map<String,Poin_Karyawan__c> mappk = new Map<String,Poin_Karyawan__c>();

        Map<String,String> mapstr = new Map<String,String>();

        String myFile = EncodingUtil.base64Decode(base64).toString();
        List<String> csvFileLines = myFile.split('\n'); 
        Map<String,User> mapuser = new Map<String,User>();
        Map<String,Opsi_Jadwal__c> mapjdw = new Map<String,Opsi_Jadwal__c>();
        Map<String,Cuti_Poin_Karyawan__c> mapcpk = new Map<String,Cuti_Poin_Karyawan__c>();
        Map<String,String> mapckid = new Map<String,String>();
        Map<String,Map<String,poin_penilaian__c>> mappoin = new Map<String,Map<String,poin_penilaian__c>>();
        Map<String,Integer> mapthn = new Map<String,Integer>();
        List<User> listus = [SELECT Id, EmployeeNumber, Agent_Type__c FROM User where EmployeeNumber!=null and IsActive=true];
        for(User us:listus){
            mapuser.put(us.EmployeeNumber,us);
        }
        List<Opsi_Jadwal__c> listjdw = [select id,Kode__c from Opsi_Jadwal__c where Kode__c!=null]; 
        for(Opsi_Jadwal__c jdw: listjdw){
            mapjdw.put(jdw.Kode__c,jdw);
        }
        if(type=='Cuti Karyawan' || type =='Poin Karyawan'){
            for(Integer i=1;i<csvFileLines.size();i++){
                string replaceNewLine ='';
                replaceNewLine = csvFileLines[i].replace('\r\n', '');
                replaceNewLine = replaceNewLine.replace('\n','');
                replaceNewLine = replaceNewLine.replace('\r','');
                List<String> csvRecordData = replaceNewLine.split(delimiter);
                User us = mapuser.get(csvRecordData[0]);
                Cuti_Poin_Karyawan__c cpk = new Cuti_Poin_Karyawan__c();
                cpk.Nama_Karyawan__c = us?.id;
                cpk.Unique_Id__c = csvRecordData[0];
                if(String.isNotBlank(cpk.Nama_Karyawan__c) && String.isNotBlank(cpk.Unique_Id__c)){
                    mapcpk.put(csvRecordData[0],cpk);
                }
                if(type=='Cuti Karyawan'){
                    if(String.isNotBlank(csvRecordData[2]) && csvRecordData[2].isNumeric()){
                        mapthn.put(csvRecordData[2],Integer.valueOf(csvRecordData[2]));
                    }
                }
            }
            if(!mapcpk.isempty()){
                upsert mapcpk.values() Unique_Id__c;
            }
        }

        if(!mapthn.isEmpty()){
            List<Cuti_Karyawan__c> listck = [select id,Nama_Karyawan__c,Unique_ID__c,Tahun__c from Cuti_Karyawan__c where Tahun__c in : mapthn.values()];
            for(Cuti_Karyawan__c ck:listck){
                mapckid.put(ck.Nama_Karyawan__c+'-'+ck.Tahun__c,ck.id);
            }
        }

        List<Cuti_Poin_Karyawan__c> listcpk = [select id,Nama_Karyawan__c,Unique_ID__c From Cuti_Poin_Karyawan__c where Unique_ID__c in : mapcpk.keySet()];
        for(Cuti_Poin_Karyawan__c cpk:listcpk){
            mapcpk.put(cpk.Unique_ID__c,cpk);
        }
        List<Poin_Penilaian__c> listpp = [SELECT Id, Kriteria__c, Score_Maximum__c, Score_Minimum__c, Poin__c, Agent_Type__c FROM Poin_Penilaian__c];
        for(Poin_Penilaian__c p:listpp){
            for(String str:p.Agent_Type__c.split(';')){
                Map<String,Poin_Penilaian__c> mp = new Map<String,Poin_Penilaian__c>();
                if(mappoin.containskey(str)){
                    mp = mappoin.get(str);
                }
                mp.put(p.Kriteria__c,p);
                mappoin.put(str,mp);
            }
        }
        
        for(Integer i=1;i<csvFileLines.size();i++){
            Boolean cek = false;
            err = '';
            string replaceNewLine ='';
            replaceNewLine = csvFileLines[i].replace('\r\n', '');
            replaceNewLine = replaceNewLine.replace('\n','');
            replaceNewLine = replaceNewLine.replace('\r','');
            List<String> csvRecordData = replaceNewLine.split(delimiter);
            User us = mapuser?.get(csvRecordData[0]);
            Opsi_Jadwal__c jdw = mapjdw?.get(csvRecordData[1]);
            Cuti_Poin_Karyawan__c cpk = mapcpk?.get(csvRecordData[0]);
            Map<String,Poin_Penilaian__c> mp = mappoin?.get(us?.Agent_Type__c);
            String str = '';
            if(type=='Jadwal Karyawan'){
                Jadwal_Karyawan__c jk = new Jadwal_Karyawan__c();
                if(mapjw.containsKey(us?.Id+'-'+csvRecordData[2])){
                    jk = mapjw.get((us?.Id+'-'+csvRecordData[2]));
                    str = mapstr.get((us?.Id+'-'+csvRecordData[2]));
                    cek = true;
                }
                if(String.isNotBlank(us?.Id)){
                    jk.Nama_Karyawan__c = us?.id;
                }
                else{
                    err += '.User tidak ditemukan / Non Aktif';
                }
                if(String.isNotBlank(jdw?.Id)){
                    jk.Opsi_Jadwal__c = jdw?.Id;
                }
                else{
                    err += '.Kode Jadwal tidak ditemukan';
                }
                try{
                    jk.Tanggal__c = Date.valueOf(csvRecordData[2]);
                }
                catch(exception exc){
                    err += '.Format tanggal tidak valid';
                }
                jk.Lokasi__c = csvRecordData[3];
                jk.Unique_ID__c = jk.Nama_Karyawan__c+'-'+jk.Tanggal__c;
                mapstr.put(jk.Unique_ID__c,csvFileLines[i]);
                if(jk.Tanggal__c!=null && jk.Opsi_Jadwal__c!=null && jk.Nama_Karyawan__c!=null && String.isNotBlank(jk.Lokasi__c)){
                    if(cek){
                        err += '.Duplikasi row ditemukan';
                    }
                    mapjw.put(jk.Unique_ID__c,jk);
                }
            }
            if(type=='Cuti Karyawan'){
                Cuti_Karyawan__c ck = new Cuti_Karyawan__c();
                if(mapct.containsKey(us?.Id+'-'+csvRecordData[2])){
                    ck = mapct.get((us?.Id+'-'+csvRecordData[2]));
                    str = mapstr.get((us?.Id+'-'+csvRecordData[2]));
                    cek = true;
                }
                Integer thn = system.today().year();
                if(String.isNotBlank(us?.Id)){
                    ck.Nama_Karyawan__c = us?.id;
                }
                else{
                    err += '.User tidak ditemukan / Non Aktif';
                }
                ck.Cuti_Poin_Karyawan__c = cpk?.id;
                ck.Tahun_Cuti__c = 'Tahun Lalu';
                if(String.isNotBlank(csvRecordData[1]) && csvRecordData[1].isNumeric() ){
                    ck.Quota_Cuti__c = Decimal.valueOf(csvRecordData[1]);
                }
                else{
                    err += '.Kuota cuti tidak valid';
                }
                if(String.isNotBlank(csvRecordData[2]) && csvRecordData[2].isNumeric()){
                    ck.Tahun__c = Decimal.valueOf(csvRecordData[2]);
                    if(ck.Tahun__c>thn){
                        ck.Tahun_Cuti__c = 'Tahun Depan';
                    }
                    if(ck.Tahun__c==thn){
                        ck.Tahun_Cuti__c = 'Tahun Ini';
                    }
                }
                else{
                    err += '.Tahun tidak valid';
                }
                ck.Cuti_Tahun_Lalu__c = mapckid.get(ck.Nama_Karyawan__c+'-'+(ck.Tahun__c-1));
                ck.Unique_Id__c = ck.Nama_Karyawan__c+'-'+ck.Tahun__c;
                mapstr.put(ck.Unique_ID__c,csvFileLines[i]);
                if(String.isNotBlank(ck.Nama_Karyawan__c) && String.isNotBlank(ck.Cuti_Poin_Karyawan__c) && (ck.Quota_Cuti__c!=null ) && ck.Tahun__c!=null){
                    if(cek){
                        err += '.Duplikasi row';
                    }
                    mapct.put(ck.Unique_Id__c,ck);
                }
            }
            if(type=='Poin Karyawan'){
                Poin_Karyawan__c  pk = new Poin_Karyawan__c();
                if(mappk.containsKey(us?.Id)){
                    pk = mappk.get((us?.Id));
                    str = mapstr.get((us?.Id));
                    cek = true;
                }
                if(String.isNotBlank(us?.Id)){
                    pk.Nama_Karyawan__c = us?.id;
                }
                else{
                    err += '.User tidak ditemukan / Non Aktif';
                }
                pk.Cuti_Poin_Karyawan__c = cpk?.id;
                if(mp!=null && checkdecimal(csvRecordData[1])){ //csvRecordData[1].isNumeric()){
                    pk.Score__c = Decimal.valueOf(csvRecordData[1]);
                    Boolean cekerr = true;
                    for(Poin_Penilaian__c pp:mp.values()){
                        if(pk.Score__c>=pp.Score_Minimum__c && pk.Score__c<=pp.Score_Maximum__c){
                            pk.Poin__c = pp.Poin__c;
                            cekerr = false;
                            break;
                        }
                    }
                    if(cekerr){
                        err += '.Poin tidak ditemukan';
                    }
                }
                else{
                    err += '.Skor tidak valid';
                }
                mapstr.put(pk.Nama_Karyawan__c,csvFileLines[i]);
                if(String.isNotBlank(pk.Nama_Karyawan__c) && String.isNotBlank(pk.Cuti_Poin_Karyawan__c) && pk.Poin__c!=null && pk.Score__c!=null){
                    if(cek){
                        err += '.Duplikasi row ditemukan';
                    }
                    mappk.put(pk.Nama_Karyawan__c,pk);
                }
            }
            if(String.isNotBlank(err)){
                listerr.add(err);
            }
        }
        try{
            if(!mappk.isempty()){
                insert mappk.values() ;
                x = mappk.size();
            }
            
            if(!mapjw.isEmpty()){
                upsert mapjw.values() Unique_ID__c;
                x = mapjw.size();
            }
    
            if(!mapct.isEmpty()){
                upsert mapct.values() Unique_ID__c;
                x = mapct.size();
            }
    
            if(!listerr.isEmpty()){
                y = listerr.size();
                err = String.valueOf(listerr);
            }
        }
        catch(Exception exc){
            x = 0;
            y = csvFileLines.size()-1;
            err = exc.getMessage();
            SCC_BulkApprovalProccess.insertErrorLog(exc,'SCC_WFM_Upload');
        }
        reval.berhasil = x;
        reval.gagal = y;
        reval.deskripsi = err;
        //result = 'Diproses = '+x+' & Gagal = '+y+' '+err;
        return reval;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getKodeValues() {
        // Query the Kode__c field from Opsi_Jadwal__c and filtering
        List<Opsi_Jadwal__c> records = [SELECT Kode__c FROM Opsi_Jadwal__c WHERE Kode__c != NULL];
        
        // Map the Kode__c field directly into a list of strings
        List<String> kodeValues = new List<String>();
        for (Opsi_Jadwal__c record : records) {
            kodeValues.add(record.Kode__c);
        }
        
        return kodeValues;
    }

    public class returnvalue{
        @AuraEnabled public Integer berhasil {get;set;}
        @AuraEnabled public Integer gagal {get;set;}
        @AuraEnabled public String deskripsi {get;set;}
    }
    
    public static Boolean checkdecimal(String var){
        Boolean cek = false;
        try{
            Decimal.valueOf(var);
            cek = TRUE; 
        }
        catch(exception exc){
            cek=false;
        }
        return cek;
    }
}