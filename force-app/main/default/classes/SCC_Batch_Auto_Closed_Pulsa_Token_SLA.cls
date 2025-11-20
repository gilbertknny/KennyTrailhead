public with sharing class SCC_Batch_Auto_Closed_Pulsa_Token_SLA implements Database.Batchable<SObject>, Database.AllowsCallouts {
    
    public String query;

    public SCC_Batch_Auto_Closed_Pulsa_Token_SLA(String q){
        this.query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc , List<Case> scope){
        try {
            List<Case> listcs = new List<Case>();

            for(Case s : scope){
                Double netSLA = s.Net_SLA_Saat_Ini__c;

                if(netSLA > 5){
                    s.Status = 'Closed';
                    s.SCC_Status_Transaksi__c = 'Berhasil';
                    String amount = s.SCC_Amount__c.format();
                    s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                    s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                    s.SCC_Drone_Remark_Update__c = 'Transaksi sukses masuk ke Provider. Harap nasabah menghubungi Provider untuk konfirmasi.';

                   listcs.add(s);         
                }
            }

            if(!listcs.isEmpty()){
                update listcs;
            }

        } catch (Exception exc){
            insertErrorLog(exc);
        }
    }

    public void finish(Database.BatchableContext bc){
        System.debug('finish execute auto closes pulsa token sla');
        if (!Test.isRunningTest()) {
            String cond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8433\' and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\') and CreatedDate = LAST_WEEK';
            String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Database.executeBatch(new SCC_Batch_AutoClosed_Briva(queries), 200);
        }
    }

    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed_Pulsa_token_sla';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}