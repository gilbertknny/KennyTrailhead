/**
 * Class : BRI_CustomCustomerSearchTest
 * description : This is test class for BRI_CustomCustomerSearch
 * 
 **/
@isTest
private class BRI_CustomCustomerSearchTest {
    
    @TestSetup
    static void createTestData() {
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account testAccount = new Account(
            firstName = 'John ',
            Lastname ='mcGray',
            PersonMobilePhone = '999999999',
            SCC_NIK__c = 'BPLPS5695Q',
            recordtypeid = personAccountRecordTypeId
        );
        insert testAccount;
    }
    
    @isTest
    static void testRetriveAccountsWithMobAndNIK() {
        
        Test.startTest();
        List<Account> resultAccounts = BRI_CustomCustomerSearch.retriveAccounts('999999999', 'BPLPS5695Q');
        Test.stopTest();
        System.assertEquals(resultAccounts.size(),1);
    }
    
    @isTest
    static void testRetriveAccountsWithNIK() {
        
        Test.startTest();
        List<Account> resultAccounts = BRI_CustomCustomerSearch.retriveAccounts('', 'BPLPS5695Q');
        Test.stopTest();
        System.assertEquals(resultAccounts.size(),1);
    }
    
    @isTest
    static void testRetriveAccountsWithDiffVal() {
        
        Test.startTest();
         List<Account> resultAccounts = new  List<Account>();
        try{
            resultAccounts = BRI_CustomCustomerSearch.retriveAccounts('999999998', 'BPLPS5695Q');
        }
        catch (Exception ex){
            System.assertEquals(resultAccounts.size(),0);
        }
        Test.stopTest();
        
    }
}