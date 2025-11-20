/**
 * @description       : Test Class for SCC_QueueController
 * @last modified on  : 03-06-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_QueueController_Test {
    @TestSetup
    static void makeData(){
        Group groupQueue = new Group();
        groupQueue.Name = 'TestQueue';
        groupQueue.Type = 'Queue';
        insert groupQueue;

        SSC_Call_Type__c callType = new SSC_Call_Type__c(
            Name = '8412',
            External_Id__c = '8412',
            SCC_Customer_Segment__c = 'Segment 1',
            SSC_Product_L1__c = 'Savings',
            SSC_Product_L2__c = 'Digital Savings',
            SSC_Case_Category__c = 'Inquiry',
            SSC_Case_Description__c = 'Description 1',
            Active__c = true);
        insert callType;
    }
    @isTest
    static void testSearchQueueNames() {
        Test.startTest();
        List<String> result = SCC_QueueController.searchQueueNames('TestQueue');
        Test.stopTest();

        System.assertNotEquals(0, result.size(), 'Queue list kosong');
        System.assertEquals('TestQueue', result[0], 'Nama queue tidak sesuai');
    }
    @IsTest
    static void testSaveQueueToCustomObjectLevel1() {
        SSC_Call_Type__c resultTestRecord = [SELECT id FROM SSC_Call_Type__c LIMIT 1];
        String customObjectId = resultTestRecord.Id;
        Test.startTest();
        SCC_QueueController.saveQueueToCustomObject(customObjectId, 'TestQueue', 'SCC_Level1_Escalation_team__c');
        Test.stopTest();

        SSC_Call_Type__c getUpdatedRecord = [SELECT 
                                            Id, 
                                            SCC_Level1_Escalation_team__c,
                                            SCC_Level2_Escalation_team__c,
                                            SCC_Level3_Escalation_team__c,
                                            SCC_Level4_Escalation_team__c
                                            FROM SSC_Call_Type__c 
                                            WHERE Id = :customObjectId
                                            LIMIT 1
                                        ];
        System.assertEquals('TestQueue', getUpdatedRecord.SCC_Level1_Escalation_team__c, 'Queue name tidak tersimpan dengan benar');
    }
    @IsTest
    static void testSaveQueueToCustomObjectLevel2() {
        SSC_Call_Type__c resultTestRecord = [SELECT id FROM SSC_Call_Type__c LIMIT 1];
        String customObjectId = resultTestRecord.Id;
        Test.startTest();
        SCC_QueueController.saveQueueToCustomObject(customObjectId, 'TestQueue', 'SCC_Level2_Escalation_team__c');
        Test.stopTest();

        SSC_Call_Type__c getUpdatedRecord = [SELECT 
                                            Id, 
                                            SCC_Level1_Escalation_team__c,
                                            SCC_Level2_Escalation_team__c,
                                            SCC_Level3_Escalation_team__c,
                                            SCC_Level4_Escalation_team__c
                                            FROM SSC_Call_Type__c 
                                            WHERE Id = :customObjectId
                                            LIMIT 1
                                        ];
        System.assertEquals('TestQueue', getUpdatedRecord.SCC_Level2_Escalation_team__c, 'Queue name tidak tersimpan dengan benar');
    }
    @IsTest
    static void testSaveQueueToCustomObjectLevel3() {
        SSC_Call_Type__c resultTestRecord = [SELECT id FROM SSC_Call_Type__c LIMIT 1];
        String customObjectId = resultTestRecord.Id;
        Test.startTest();
        SCC_QueueController.saveQueueToCustomObject(customObjectId, 'TestQueue', 'SCC_Level3_Escalation_team__c');
        Test.stopTest();

        SSC_Call_Type__c getUpdatedRecord = [SELECT 
                                            Id, 
                                            SCC_Level1_Escalation_team__c,
                                            SCC_Level2_Escalation_team__c,
                                            SCC_Level3_Escalation_team__c,
                                            SCC_Level4_Escalation_team__c
                                            FROM SSC_Call_Type__c 
                                            WHERE Id = :customObjectId
                                            LIMIT 1
                                        ];
        System.assertEquals('TestQueue', getUpdatedRecord.SCC_Level3_Escalation_team__c, 'Queue name tidak tersimpan dengan benar');
    }
    @IsTest
    static void testSaveQueueToCustomObjectLevel4() {
        SSC_Call_Type__c resultTestRecord = [SELECT id FROM SSC_Call_Type__c LIMIT 1];
        String customObjectId = resultTestRecord.Id;
        Test.startTest();
        SCC_QueueController.saveQueueToCustomObject(customObjectId, 'TestQueue', 'SCC_Level4_Escalation_team__c');
        Test.stopTest();

        SSC_Call_Type__c getUpdatedRecord = [SELECT 
                                            Id, 
                                            SCC_Level1_Escalation_team__c,
                                            SCC_Level2_Escalation_team__c,
                                            SCC_Level3_Escalation_team__c,
                                            SCC_Level4_Escalation_team__c
                                            FROM SSC_Call_Type__c 
                                            WHERE Id = :customObjectId
                                            LIMIT 1
                                        ];
        System.assertEquals('TestQueue', getUpdatedRecord.SCC_Level4_Escalation_team__c, 'Queue name tidak tersimpan dengan benar');
    }
}