@IsTest(SeeAllData=false)
public class TriggerHandler_MasterData_Test {
	@TestSetup
    static void setTestData(){
        Contact ct = new Contact();
        ct.FirstName = 'ABC';
        ct.LastName = 'Test';
        insert ct;
        
        String RTPolicyDistribution = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Policy Distribution').getRecordTypeId();
        Master_Data__c md = new Master_Data__c();
        md.RecordTypeId = RTPolicyDistribution;
        md.USER_PIC__c = null;
        md.Name = '1232132';
        insert md;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
        	Contact ct = [SELECT Id FROM Contact LIMIT 1];
            Test.startTest();
            Master_Data__c md = [SELECT Id FROM Master_Data__c LIMIT 1];
            md.USER_PIC__c = ct.Id;
            update md;
            Test.stopTest();
            
            Master_Data__c md1 = [SELECT Id,USER_PIC__c FROM Master_Data__c WHERE Id =:md.Id];
            system.assertEquals(ct.Id,md1.USER_PIC__c);
    	}
    }
}