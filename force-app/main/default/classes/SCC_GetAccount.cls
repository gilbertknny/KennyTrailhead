public with sharing class SCC_GetAccount  implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    public String query;
    public SCC_GetAccount(String q){
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
     }
  
    public void execute(Database.BatchableContext bc, List<Case> scope){
        for(Case cs : scope){
            Account acc = new Account();
            SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
            SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
            req.acctNo = cs.SCC_Account_Number__c;
            req.channelId = 'CHMS';
            req.personalNumber = label.Personal_Number;
            res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req,'System',cs.id);
            if(res?.data!=null){
                for(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData dt:res?.data){
                    String cifno = dt.cifno;
                    String condacc = 'SCC_cifno__c=:cifno';
                    String allfieldacc = SOQL_SOBJECT.getallfield('Account');
                    String queriesacc = SOQL_SOBJECT.SOQL(allfieldacc, '', 'Account', condacc, '', '', '1');
                    List<Account> listacc = Database.query(queriesacc);
                    SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi demographicInfo = dt?.demografi;
                    if(!listacc.isEmpty()){
                        acc = SCC_LegacyCaseAPICtrl.returnAccount(demographicInfo, listacc[0].id, dt?.cifno);
                    }
                    else{   
                        acc = SCC_LegacyCaseAPICtrl.returnAccount(demographicInfo, null, dt?.cifno);
                    }
                } 
                cs.AccountId = acc?.id;
            }
        }
        update scope;
    }
  
    public void finish(Database.BatchableContext bc){
        String cond = '(Accountid!=null and status='+'\'Escalated'+'\' and Sent_to_Drone__c=true and createdby.name!='+'\'Migration'+'\' and createdby.name!='+'\'Bondan Hartawan'+'\' and SCC_Drone_Ticket_ID__c='+'\'-'+'\')';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Case', cond, 'createddate', 'DESC', '');
        Database.executeBatch(new scc_BatchSendToDrone(queries), 1);
    }
}