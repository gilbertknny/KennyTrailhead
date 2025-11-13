@IsTest (seeAllData=false)
public with sharing class Aswata_Reset_RoundRobinCounter_Test {
    @IsTest
    static void testexecuteResetCounters() {

        Master_Data__c roundRobin = Aswata_TestDataFactory.createMasterData('R Robin 1', 'Round Robin Member');
        roundRobin.Account_Type__c = '0';
        roundRobin.Account_Segment__c = 'I';
        roundRobin.Account_Pipeline_Status__c = 'Direct';
        roundRobin.Business_Segmentation__c = 'Corporate';
        roundRobin.Round_Robin_Counter_Branch__c = 5;
        roundRobin.Round_Robin_Counter_Account__c = 10;
        update roundRobin;

        Test.startTest();
        Aswata_Reset_RoundRobinCounter job = new Aswata_Reset_RoundRobinCounter();
        String jobId = System.schedule('Test Reset Job', '0 0 0 * * ?', job);
        Test.stopTest();

        // 3️⃣ Verify that counters have been reset to 0
        List<Master_Data__c> results = [
            SELECT Round_Robin_Counter_Branch__c, Round_Robin_Counter_Account__c 
            FROM Master_Data__c
            WHERE Id IN :new List<Id>{ roundRobin.Id}
        ];

        System.assertEquals(0, results[0].Round_Robin_Counter_Branch__c, 'Branch counter should be reset to 0');
        System.assertEquals(0, results[0].Round_Robin_Counter_Account__c, 'Account counter should be reset to 0');
    }
}