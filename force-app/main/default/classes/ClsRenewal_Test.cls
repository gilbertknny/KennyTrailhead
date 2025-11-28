@IsTest(SeeAllData=false)
public class ClsRenewal_Test {
	@TestSetup
    static void setTestData(){
        String strRTIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ACC12345';
        acc.RecordTypeId = strRTIndividual;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Opportunity';
        opp.Name = 'Test';
        opp.CloseDate = Date.Today();
        insert opp;
        
        InsurancePolicy ip = new InsurancePolicy();
        ip.Name = 'Test';
        ip.NameInsuredId = acc.Id;
        ip.SourceOpportunityId = opp.Id;
        insert ip;
        
        InsurancePolicy ip2 = new InsurancePolicy();
        ip2.Name = 'Test2';
        ip2.NameInsuredId = acc.Id;
        insert ip2;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){	
            InsurancePolicy ip = [SELECT Id FROM InsurancePolicy WHERE Name = 'Test' LIMIT 1];
            InsurancePolicy ip2 = [SELECT Id FROM InsurancePolicy WHERE Name = 'Test2' LIMIT 1];
            Test.startTest();
            ClsRenewal.getUserId();
            ClsRenewal.getPicklist('InsurancePolicy','Status_Renewal__c');
            string result = ClsRenewal.saveData('RN',ip.Id,null,null,null,null);
            result = ClsRenewal.saveData('ED',ip.Id,null,null,'2025-01-01',null);
            system.assertNotEquals(result,null);
            result = ClsRenewal.saveData(null,null,null,null,null,null);
            system.assertEquals(result,'Data must be filled!');
            result = ClsRenewal.saveData('RN',ip2.Id,null,null,null,null);
            system.assertEquals(result,'Opportunity not find, please change the Policy Number!');
            Test.stopTest();
        }
    }
}