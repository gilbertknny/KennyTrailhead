@isTest
private class TestReloadPage {
    @isTest
    static void testRefreshPage() {        
        Document_Type__c acc = new Document_Type__c(Name = 'Test Account');
        insert acc;
        
        List<Id> recordIds = new List<Id>{ acc.Id };
        Test.startTest();
        ReloadPage.refreshPage(recordIds);
        Test.stopTest();        
    }
}