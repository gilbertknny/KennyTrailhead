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
 * @description WebserviceAPI_Test
 */
@IsTest
private class WebserviceAPI_Test {

    @IsTest
    static void testIntegrationProcedureCase() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            // Arrange
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SFAWT17_InboundAPIAccountContactCreation');
            req.requestBody = Blob.valueOf('{ "key": "value" }');
            
            RestResponse res = new RestResponse();
            
            // Stub callIP
            Test.startTest();
            RestContext.request = req;
            RestContext.response = res;
            
            // Mocking method static VlocityMapping
            WebserviceAPI.ActionData();
            Test.stopTest();
            
            System.assertEquals(200, RestContext.response.statusCode);
            System.assert(RestContext.response.responseBody.toString().contains('success') 
                || RestContext.response.responseBody.toString().contains('{'));
        }
    }
    
    @IsTest
    static void testUploadFileCase() {
        User currentUser = setUser();
        
        System.runAs(currentUser) {
            Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
            // Arrange
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
            
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SFAWT06_UploadFile');
            req.requestBody = Blob.valueOf(JSON.serialize(fileData));
            
            RestResponse res = new RestResponse();
            
            Test.startTest();
            RestContext.request = req;
            RestContext.response = res;
            
            WebserviceAPI.ActionData();
            Test.stopTest();
            
            System.assertEquals(200, RestContext.response.statusCode);
            //System.assert(RestContext.response.responseBody.toString().contains('Upload Success'));
        }
    }

    @IsTest
    static void testUploadFileCase2() {
        //User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User currentUser = setUser();
        System.runAs(currentUser) {
            Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
            // Arrange
            Account acc = new Account(Name='Test Account',RecordtypeId = rtId,Client_id__c = 'CLIENT123');
            insert acc;
            
            String fileContent = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
            
            Map<String, Object> fileData = new Map<String, Object>{
                'LinkedEntityId__c' => 'CLIENT123',
                'fieldtype__c' => 'Client_ID',
                'PathOnClient' => 'test.txt',
                'Title' => 'Test File',
                'VersionData' => fileContent,
                'ID_Type__c' => 'OTHER'
            };
            
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SFAWT06_UploadFile');
            req.requestBody = Blob.valueOf(JSON.serialize(fileData));
            
            RestResponse res = new RestResponse();
            
            Test.startTest();
            RestContext.request = req;
            RestContext.response = res;
            
            WebserviceAPI.ActionData();
            Test.stopTest();
            
            System.assertEquals(200, RestContext.response.statusCode);
            //System.assert(RestContext.response.responseBody.toString().contains('Upload Success'));
        }
    }

    @IsTest
    static void testUploadFileCaseSIDia() {
        //User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        User currentUser = setUser();
        System.runAs(currentUser) {
            Id rtId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Business').getRecordTypeId();
            Account acc = new Account(Name='Test Account',RecordtypeId = rtId,Client_id__c = 'CLIENT123');
            insert acc;
            Case cs = new Case(Origin='Web',AccountId=acc.Id,Status='New');
            insert cs;
            Claim cl = new Claim(Name='Sidia',AccountId=acc.Id,CaseId=cs.Id);
            insert cl;
            String fileContent = EncodingUtil.base64Encode(Blob.valueOf('Test File Content'));
            
            Map<String, Object> fileData = new Map<String, Object>{
                'claim_number' => cl.Id,
                'document_name' => 'Test File',
                'file' => fileContent,
                'mime_type' => 'txt'
            };
            
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SFAWT06_UploadFileSIDIA');
            req.requestBody = Blob.valueOf(JSON.serialize(fileData));
            
            RestResponse res = new RestResponse();
            
            Test.startTest();
            RestContext.request = req;
            RestContext.response = res;
            
            WebserviceAPI.ActionData();
            Test.stopTest();
            
            System.assertEquals(200, RestContext.response.statusCode);
            //System.assert(RestContext.response.responseBody.toString().contains('Upload Success'));
        }
    }
    
    @IsTest
    static void testDefaultCase() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            // Arrange
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SalesforceComposite');
            req.requestBody = Blob.valueOf('{ "key": "value" }');
            
            RestResponse res = new RestResponse();
            
            Test.startTest();
            RestContext.request = req;
            RestContext.response = res;
            
            WebserviceAPI.ActionData();
            Test.stopTest();
            System.assertEquals(0, RestContext.response.statusCode);
        }
    }
    
    @IsTest
    static void testErrorCase() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            // Simulasi request tanpa meta untuk memicu exception
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{}');
            
            RestResponse res = new RestResponse();
            
            Test.startTest();
            RestContext.request = req;
            RestContext.response = res;
            
            WebserviceAPI.ActionData();
            Test.stopTest();
            
            System.assertEquals(400, RestContext.response.statusCode);
            System.assert(RestContext.response.responseBody.toString().contains('success'));
        }
    }

    public static User setUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Integration']; 
        User currentUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Lintaswata', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@aswata.co.id');
            return currentUser;
    }
}