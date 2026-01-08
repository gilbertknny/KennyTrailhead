@IsTest(SeeAllData=false)
public class ClsPolicyDistribution_Test {
    @TestSetup
    static void setTestData(){
        String strRTIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ACC12345';
        acc.RecordTypeId = strRTIndividual;
        insert acc;
        
        Contact ct = new Contact();
        ct.AccountId = acc.Id;
        ct.LastName = 'Test';
        insert ct;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.Today();
        opp.Sum_Insured__c = 100000;
        opp.Total_Sum_Insured__c = 100000;
        opp.COB__c = '201';
        insert opp;
        
        String strRTMd = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Policy Distribution').getRecordTypeId();
        Master_Data__c md = new Master_Data__c();
        md.RecordTypeId = strRTMd;
        md.AUTHORITY_TYPE__c = 'UW';
        md.LIMIT_AMOUNT__c = 100000;
        md.Status__c = 'Approved';
        md.BSN_ID__c = '201';
        md.USER_PIC__c = ct.Id;
        md.USER_ID__c = UserInfo.getUserId();
        insert md;
        
        String strRT2 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Filter Policy Distribution').getRecordTypeId();
        Master_Data__c md2 = new Master_Data__c();
        md2.BSN_ID__c = '201';
        md2.Status__c = 'Active';
        md2.showData__c = '[{"param1":"BSN_ID__c","param2":"COB__c"}]';
        md2.RecordTypeId = strRT2;
        insert md2;
        
        Quote qu = new Quote();
        qu.OpportunityId = opp.Id;
        qu.Name = 'Test';
        insert qu;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Quote qu = [SELECT Id FROM Quote LIMIT 1];
            ClsPolicyDistribution.data data = ClsPolicyDistribution.getUserIdFilter(opp.Id);
            system.assertNotEquals(data.userid,null);
            List<ID> ids = new List<ID>();
            ids.add(qu.Id);
            ClsPolicyDistribution.getUserIds(ids);
            Test.stopTest();
        }
    }
}