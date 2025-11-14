@IsTest(SeeAllData=false)
public class ClsUserLimit_Test {
	@TestSetup
    static void setTestData(){
        String strRTIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ACC12345';
        acc.RecordTypeId = strRTIndividual;
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.Today();
        opp.Sum_Insured__c = 100000;
        insert opp;
        
        Quote qu = new Quote();
        qu.OpportunityId = opp.Id;
        qu.Name = 'Test';
        insert qu;
        
        String strRTMd = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Approval Limit').getRecordTypeId();
        Master_Data__c md = new Master_Data__c();
        md.RecordTypeId = strRTMd;
        md.AUTHORITY_TYPE__c = 'UW';
        md.LIMIT_AMOUNT__c = 1000000;
        md.Status__c = 'Approved';
        md.USER_ID__c = UserInfo.GetUserId();
        insert md;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            Quote qu = [SELECT Id FROM Quote LIMIT 1];
            List<ID> ids = new List<ID>();
            ids.Add(qu.Id);
            List<string> listdata = ClsUserLimit.getUserIds(ids);
            system.assertEquals(listdata.size(),1);
            Test.stopTest();
        }
    }
}