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

                Date todayz = Date.today();
                String tgl = DateTime.newInstance(todayz, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                
                Date tgl2Date = s.SCC_Transaction_Date__c;
                String tgl2 = DateTime.newInstance(tgl2Date, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

                if(netSLA > 5){
                    s.Status = 'Closed';
                    s.SCC_Status_Transaksi__c = 'Gagal';
                    String amount = s.SCC_Amount__c.format();
                    s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                    s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                    s.SCC_Drone_Remark_Update__c = 'Berdasarkan penelitian yang kami lakukan, transaksi yang di komplainkan nasabah gagal. '
                            + 'Pengembalian dana telah terkredit ke Rekening Nasabah pada tanggal ' + tgl2
                            + ' sebesar Rp' + amount
                            + ' Mohon nasabah melakukan pengecekan Mutasi Rekening Koran.';

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