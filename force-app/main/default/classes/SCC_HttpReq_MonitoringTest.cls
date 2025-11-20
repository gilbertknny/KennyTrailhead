@isTest(seealldata=true)
public class SCC_HttpReq_MonitoringTest {
    
    static testMethod void testProcess(){
        User u = [SELECT Id FROM User WHERE BranchCode__c = '00229' AND SCC_Orgeh__c != null LIMIT 1];
        
        Monitoring_Summary__c ms = new Monitoring_Summary__c();
        ms.User__c = UserInfo.getUserId();
        ms.Date__c = Date.Today().addDays(-1);
        ms.Total__c = 1;
        insert ms;
        
        Monitoring_Summary__c ms1 = new Monitoring_Summary__c();
        ms1.User__c = u.Id;
        ms1.Date__c = Date.Today().addDays(-1);
        ms1.Total__c = 1;
        insert ms1;
        
        Monitoring_Summary__c ms2 = new Monitoring_Summary__c();
        ms2.User__c = UserInfo.getUserId();
        ms2.Date__c = Date.Today().addDays(-1);
        ms2.Total__c = 1;
        insert ms2;
        
        Test.startTest();
        
        SCC_HttpReq_Monitoring.execute(null);
        Test.stopTest();
    }
}