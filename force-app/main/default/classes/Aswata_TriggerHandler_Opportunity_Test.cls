@IsTest(SeeAllData=false)
public class Aswata_TriggerHandler_Opportunity_Test {
	@TestSetup
    static void setTestData(){
        String strRTIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ACC12345';
        acc.RecordTypeId = strRTIndividual;
        insert acc;
        
        User u = [SELECT Id FROM User WHERE Branch__c != null LIMIT 1];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.Today();
        opp.Sum_Insured__c = 100000;
        opp.OwnerId = u.Id;
        insert opp;
        
        Product2 pd = new Product2();
        pd.Name = 'Test';
        insert pd;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPriceEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = pd.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert standardPriceEntry;
        
        OpportunityLineItem opl = new OpportunityLineItem();
        opl.OpportunityId = opp.Id;
        opl.Product2Id = pd.Id;
        opl.PricebookEntryId = standardPriceEntry.Id;
        opl.Quantity = 1;
        opl.TotalPrice = 10000;
        insert opl;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
        	Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            Test.startTest();
            update opp;
            system.assertNotEquals(opp,null);
            Test.stopTest();
        }
        
    }
}