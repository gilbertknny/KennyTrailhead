@isTest(seealldata=false)
public class SCC_HttpReq_NotificationCaseTest {
    
    static testMethod void testProcess(){
		User u1 = [SELECT Id FROM User WHERE BranchCode__c = '00229' AND SCC_Orgeh__c != null LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE BranchCode__c NOT IN('00229','0000') AND BranchCode__c != null AND SCC_Orgeh__c != null LIMIT 1];
        
        Case cs = new Case();
        cs.OwnerId = u2.Id;
        insert cs;
        
        Case cs1 = new Case();
        cs1.OwnerId = u1.Id;
        insert cs1;
        
        Case cs2 = new Case();
        cs2.OwnerId = u2.Id;
        insert cs2;
        
        Test.startTest();
        
        Date dt = Date.Today();
        SCC_HttpReq_NotificationCase.execute(dt);
        Test.stopTest();
    }
}