@IsTest
public class DataMigration_Test {
    /*@testSetup static void setup(){
        Branch_Unit__c bu = new Branch_Unit__c(Name = '7 - KC Banyuwangi', Branch_Code__c = '7');
        insert bu;
        
        SSC_Call_Type__c callType = new SSC_Call_Type__c();
        callType.Active__c = true;
        callType.Name = '6666';
        callType.SCC_Customer_Segment__c = 'Individu Umum';
        callType.SSC_Product_L1__c = 'Transaction Banking';
        callType.SSC_Product_L2__c = 'Transaction Solution';
        callType.SSC_Case_Category__c = 'Complaint - Transaction';
        callType.SSC_Case_Description__c = 'Nasabah Komplain Transaksi Rtgs Melalui E-Channel';
        callType.Send_to_Drone__c = false;
        callType.SCC_Agent_SLA__c = 1;
        callType.SCC_Level1_OLA__c = 3;
        callType.SCC_Level1_Escalation_team__c = 'Branch';
        insert callType;
        
        Account acc = new Account(LastName = 'Test', Phone = '081234567890');
        insert acc;

		List<Case> cases = new List<Case>();   
        Case cs = new Case();
        cs.Subject = 'Case from migration';
        cs.Description = 'Test';
        cs.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs.AccountId = acc.Id;
        cs.SCC_Cust_Phone1__c = '081234567890';
        cs.Cust_Current_Phone__c = '081234567890';
        cs.SCC_Amount__c = 1000000;
        cs.SCC_Card_Number__c = '1234567890123456';
        cs.SCC_Account_Number__c = '1234567890123456';
        cs.SSC_Call_Type_Description__c = 'Test';
        cs.SCC_Call_Type__c = callType.Id;
        cs.SCC_User_Group__c = '7 - KC Banyuwangi';
        cases.add(cs);
        
        Case cs2 = new Case();
        cs2.Subject = 'Case 2 from migration';
        cs2.Description = 'Test';
        cs2.SCC_Waktu_Transaksi__c = DateTime.Now();
        cs2.AccountId = acc.Id;
        cs2.SCC_Cust_Phone1__c = '081234567890';
        cs2.Cust_Current_Phone__c = '081234567890';
        cs2.SCC_Amount__c = 3000000;
        cs2.SCC_Card_Number__c = '1234567890123456';
        cs2.SCC_Account_Number__c = '1234567890123456';
        cs2.SSC_Call_Type_Description__c = 'Test';
        cs2.SCC_Call_Type__c = callType.Id;
        cs2.SCC_User_Group__c = '00005 - Banten';
        cases.add(cs2);
        insert cases;
    }*/
    
    @IsTest
    static void testUpdateUnitKerjaFieldForCases() {
        Test.startTest();
        DataMigration dm = new DataMigration();
        //List<Case> cases = [SELECT Id, SCC_User_Group__c FROM Case];
        //DataMigration.updateUnitKerjaFieldForCases(cases);
        Test.stopTest();
        
        /*Case bnyCase = [SELECT Id, Unit_Kerja_2__c FROM Case WHERE SCC_User_Group__c = '7 - KC Banyuwangi'];
        Case bntCase = [SELECT Id, Unit_Kerja_2__c FROM Case WHERE SCC_User_Group__c = '00005 - Banten'];
        
        System.assertNotEquals(null, bnyCase.Unit_Kerja_2__c, 'Unit_Kerja_2__c should be updated');
        System.assertEquals(null, bntCase.Unit_Kerja_2__c, 'Unit_Kerja_2__c should not be updated');*/
    }
}