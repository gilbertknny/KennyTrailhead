public with sharing class BatchUpdateCuti implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public String query;
    public BatchUpdateCuti(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext bc, List<Cuti_Karyawan__c> scope){
        try{
            Integer thn = system.now().year();
            Map<String,Cuti_Karyawan__c> mapcuti = new Map<String,Cuti_Karyawan__c>();
            for(Cuti_Karyawan__c c : scope){
                Integer x = Integer.valueof(c.Tahun__c-1);
                mapcuti.put(c.Nama_Karyawan__c+'-'+x,null);
            }
            List<Cuti_Karyawan__c> listcuti = [select id,Nama_Karyawan__c,Sisa_Cuti__c,Unique_Id__c,Tahun__c from Cuti_Karyawan__c where Unique_Id__c in :mapcuti.keySet()];
            for(Cuti_Karyawan__c ck : listcuti){
                mapcuti.put(ck.Nama_Karyawan__c+'-'+ck.Tahun__c,ck);
            }
            for(Cuti_Karyawan__c s : scope){
                s.Hutang_Cuti__c = 0;
                Cuti_Karyawan__c ck = mapcuti.get(s.Nama_Karyawan__c+'-'+Integer.valueof(s.Tahun__c-1));
                if(s.Tahun__c>thn){
                    s.Tahun_Cuti__c = 'Tahun Depan';
                }
                if(s.Tahun__c==thn){
                    s.Tahun_Cuti__c = 'Tahun Ini';
                }
                if(s.Tahun__c<thn){
                    s.Tahun_Cuti__c = 'Tahun Lalu';
                }
                if(ck?.Sisa_Cuti__c<0){
                    s.Hutang_Cuti__c = ck?.Sisa_Cuti__c;
                }
                s.Cuti_Tahun_Lalu__c = ck?.id;
            }
            update scope;
        }
        catch(Exception exc){
            InsertErrorLog(exc);
        }
    }
    public void finish(Database.BatchableContext bc){
     
    }

    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'BatchUpdateCuti';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}