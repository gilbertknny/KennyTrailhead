/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCC_Account_UI_Test {
    @isTest
    static void testClass() {
        // TO DO: implement unit test
        Account acc = Object_Test.setAccount('PersonAccount');
        insert acc;
        Account acc2 = Object_Test.setAccount('IndustriesBusiness');
        insert acc2;
        Test.startTest();
        SCC_Account_UI.getInformasiCustomer(acc.id);
        SCC_Account_UI.getInformasiCustomer(acc2.id);
        SCC_Account_UI.getInformasiFinansial(acc.id);
        SCC_Account_UI.getMutasiKartu(acc.scc_cifno__c, acc.id);
        SCC_Account_UI.getMutasiRekening(acc.scc_cifno__c, '2022-01-01', '2022-01-01', acc.id);  
        SCC_Account_UI.getHoldStatus('3432434324234', acc.id);
        Test.stopTest();
    }
}