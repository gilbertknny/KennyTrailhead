@isTest
public class AccountTrigger_Test {
    @isTest
    static void testFormatPhoneAccount() {
        Account acc = new Account(
            Name = 'Test Account', 
            SCC_Address__c = 'Nama Jalan',
            SCC_Tipe_Nasabah__c='Individu', 
            Phone = '6281299928812');
        insert acc;
        
        Account acc2 = [SELECT Id, Phone FROM Account WHERE SCC_Address__c = 'Nama Jalan'];
        System.assertEquals(acc2.Phone, '081299928812', 'Number is in the correct format');
        
        acc2.Phone = '6281299628812';
        update acc2;
        
        Account acc3 = [SELECT Id, Phone FROM Account WHERE SCC_Address__c = 'Nama Jalan'];
        System.assertEquals(acc3.Phone, '081299628812', 'Number is in the correct format');
        
        Account acc4 = new Account(Name = 'Test Account 2', SCC_Address__c = 'Nama Jalan 2', SCC_Tipe_Nasabah__c='Individu');
        insert acc4;
        
        Account acc5 = [SELECT Id, Phone FROM Account WHERE SCC_Address__c = 'Nama Jalan 2'];
        System.assertEquals(acc5.Phone, null, 'Number should be null');
    }
}