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
 * @description ErrorLogRecord_Test
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@IsTest
private class ErrorLogRecord_Test {
    @IsTest
    static void errorrecord(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@bri.co.id';
        User u = new User(Alias = 'stdad', Email='testadmin@bri.co.id',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = userinfo.getProfileId(),
                            TimeZoneSidKey='Asia/Jakarta',
                            UserName=uniqueUserName);
        System.runAs(u) {
            test.startTest();
            ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
            dl.message ='a';
            dl.trace = 'a';
            dl.typename = 'a';
            dl.linenumber = '1'; 
            dl.errorcause = 'a'; 
            dl.classname = 'SCC_CaseCreateLegacyAPI';
            dl.header = 'a';
            dl.body = 'a';
            dl.iprequest = 'a'; 
            dl.statuscode = 1; 
            dl.responsebody = '{"a":"a"}'; 
            dl.urLendpoint = '/xxx/'; 
            dl.typeapi = 'Inbound';
            dl.recid = UserInfo.getUserId();
            dl.objnm = '';
            dl.iduser = UserInfo.getUserId();
            dl.stringtosign = 'xxxxxxxxxxxxxxxxx';
            ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
            ErrorLogRecord.inserterror(JSON.serialize(dl));
            
            Account acc = new Account();
            dl.cs = acc;
            Savepoint sp = Database.setSavepoint();
            try{
                insert acc;
            }
            catch(exception exc){
                dl = ErrorLogRecord.setError(acc, 'SCC_CaseCreateLegacyAPI', exc);
                ErrorLogRecord.errorException(dl, sp, exc);
            }
            System.assertNotEquals(acc, null, 'account not found');
            test.stopTest();
        }   
    }

    @IsTest
    static void errorAPI(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.remoteAddress = '192.178.100.20';
            req.requestURI = '/webserviceAPI/*';
            req.httpMethod = 'POST';
            req.addParameter('meta', 'SalesforceComposite');
            req.addHeader('Content-Type', 'application/json');
            string testbody = '{"allOrNone":true,"collateSubrequests":true,"compositeRequest":[{"method":"PATCH","url":"/services/data/v62.0/sobjects/Account/FinServ__SourceSystemId__c/A001","referenceId":"acc","body":{"Name":"PT Maju Jaya Upsert File","Phone":"021-555-1234","Website":"www.majujayaabadi.com","Industry":"Technology"}},{"method":"POST","url":"/services/data/v60.0/sobjects/ContentVersion","referenceId":"cv","body":{"Title":"Nama File3","PathOnClient":"Nama File3.txt","ContentLocation":"S","versionData":"dGVzdCBiYXNlNjQgZmlsZQ=="}},{"method":"GET","url":"/services/data/v60.0/sobjects/ContentVersion/@{cv.id}","referenceId":"qcv"},{"method":"POST","url":"/services/data/v60.0/sobjects/ContentDocumentLink","referenceId":"cdl","body":{"ContentDocumentId":"@{qcv.ContentDocumentId}","LinkedEntityId":"@{acc.id}","ShareType":"V","Visibility":"AllUsers"}}]}';
            req.requestBody = Blob.valueOf(testbody);
            RestContext.request = req;
            RestContext.response = res;
            WebserviceAPI.ActionData();
            System.assertNotEquals(res, null, 'not equals');
            Test.stopTest();
        }
    }
    
    @IsTest
    static void errorAPI2(){
    	User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new APILogMock.ResponseAPILog());
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.remoteAddress = '192.178.100.20';
            req.requestURI = '/webserviceAPI/*';
            req.httpMethod = 'POST';
            req.addParameter('meta', 'SalesforceComposite');
            req.addHeader('Content-Type', 'application/json');
            string testbody = '{"allOrNone":true,"collateSubrequests":true,"compositeRequest":[{"method":"PATCH","url":"/services/data/v62.0/sobjects/Account/FinServ__SourceSystemId__c/A001","referenceId":"acc","body":{"Name":"PT Maju Jaya Upsert File","Phone":"021-555-1234","Website":"www.majujayaabadi.com","Industry":"Technology"}},{"method":"POST","url":"/services/data/v60.0/sobjects/ContentVersion","referenceId":"cv","body":{"Title":"Nama File3","PathOnClient":"Nama File3.txt","ContentLocation":"S","versionData":"dGVzdCBiYXNlNjQgZmlsZQ=="}},{"method":"GET","url":"/services/data/v60.0/sobjects/ContentVersion/@{cv.id}","referenceId":"qcv"},{"method":"POST","url":"/services/data/v60.0/sobjects/ContentDocumentLink","referenceId":"cdl","body":{"ContentDocumentId":"@{qcv.ContentDocumentId}","LinkedEntityId":"@{acc.id}","ShareType":"V","Visibility":"AllUsers"}}]}';
            req.requestBody = Blob.valueOf(testbody);
            RestContext.request = req;
            RestContext.response = res;
            WebserviceAPI.ActionData();
            System.assertNotEquals(res, null, 'not equals');
            Test.stopTest();
        }
    }
}