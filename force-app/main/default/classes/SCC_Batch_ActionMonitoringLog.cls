global class SCC_Batch_ActionMonitoringLog implements Database.AllowsCallouts,Database.Batchable<sObject>{
    private String strdt;
    private String menu;
    private String destination;
    private List<String> listuserid = new List<String>();
    private String anomali;
    
    global SCC_Batch_ActionMonitoringLog(String strdt,String menu,String destination,List<String> listuserid,String anomali){
        this.strdt = strdt;
        this.menu = menu;
        this.destination = destination;
        this.listuserid = listuserid;
        this.anomali = anomali;
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Anomali__c,User_Run__c FROM Error_Log__c ';
            query += 'WHERE Error_Datetime__c = ' + strdt + ' ';
            query += 'AND Response_Status_Code__c = 200 ';
            query += 'AND Menu__c !=: menu ';
            query += 'AND Destination__c =: destination ';
            query += 'AND User_Run__c IN:listuserid ';
            query += 'ORDER BY User_Run__c ASC, Error_Datetime__c ASC LIMIT 50000 ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Error_Log__c> listelnew = new List<Error_Log__c>();
        for(sObject sobj : scope){
            Error_Log__c el = (Error_Log__c)sobj;
            if(el.Anomali__c == '' || el.Anomali__c == null){
                el.Anomali__c = anomali;
                listelnew.add(el);
            }else if(!el.Anomali__c.contains(anomali)){
                el.Anomali__c = el.Anomali__c + ';' + anomali;
                listelnew.add(el);
            }
        }
        if(listelnew.size()>0) update listelnew;
    }

    global void finish(Database.BatchableContext bc) {
        // execute any post-processing operations - send emails, notify clients
    }
   
}