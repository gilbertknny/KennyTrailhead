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
 * @description UploadFileQueueable_Test
 */
@IsTest
private class UploadFileQueueable_Test {

    @IsTest
    static void myUnitTest() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.setMock(HttpCalloutMock.class, new APILogMock.LintaswataOauth());
            Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account acc = new Account(Name='Test Account',RecordtypeId = rtId,Client_id__c = 'CLIENT123');
            insert acc;
            String fileContent = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
            Map<String, Object> fileData = new Map<String, Object>{
                'LinkedEntityId__c' => acc.Id,
                'fieldtype__c' => 'Salesforce',
                'PathOnClient' => 'test.txt',
                'Title' => 'Test File',
                'VersionData' => fileContent,
                'ID_Type__c' => 'OTHER'
            };
            Blob b = Blob.valueOf(JSON.serialize(fileData));
            ID jobID = System.enqueueJob(new UploadFileQueueable(b));
            system.assertEquals('CLIENT123', acc.Client_id__c);
        }
    }
}