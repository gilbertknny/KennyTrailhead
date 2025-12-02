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
 * 
 * @description APILog_Test
 */
@IsTest
private class APILog_Test {

    @IsTest
    static void getResponseAPITokenTest() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            String x = '{ "grantType" : "client_credentials" }';
            // TO DO: implement unit test
            APILog.WrapperRequest wr = new APILog.WrapperRequest();
            wr.bodyblob = Blob.valueOf(x);
            wr.clsName = 'abc';
            wr.externalID = '123';
            wr.metaname = 'LintaswataOauth';
            wr.objnm = 'Account';
            wr.timestamp = String.valueOf(System.now());
            wr.token = '123';
            APILog.WrapperAPI wa = APILog.getResponseAPI(wr);
            System.assertEquals('{ "grantType" : "client_credentials" }', x);
        }
    }
    
    @IsTest
    static void getResponseAPIBlobTest() {
        String x = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        Integer i = x.length();
        do{
            x = x+x;
            i = x.length();
        }while (i<=131072) ;
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Map<String,Object> ms = new Map<String,Object>{ 'test' => x };
            // TO DO: implement unit test
            APILog.WrapperRequest wr = new APILog.WrapperRequest();
            wr.bodyblob = Blob.valueOf(JSON.serialize(ms));
            wr.clsName = 'abc';
            wr.externalID = '123';
            wr.metaname = 'LintaswataSFAWT17';
            wr.objnm = 'Account';
            wr.timestamp = String.valueOf(System.now());
            wr.token = '123';
            APILog.WrapperAPI wa = APILog.getResponseAPI(wr);
            System.assertEquals('123', wr.token);
        }
    }

    @IsTest
    static void getResponseAPITextTest() {
        String x = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        Integer i = x.length();
        do{
            x = x+x;
            i = x.length();
        }while (i<=131072) ;
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Map<String,Object> ms = new Map<String,Object>{ 'test' => x };
            // TO DO: implement unit test
            APILog.WrapperRequest wr = new APILog.WrapperRequest();
            wr.bodyreq = JSON.serialize(ms);
            wr.clsName = 'abc';
            wr.externalID = '123';
            wr.metaname = 'LintaswataSFAWT17';
            wr.objnm = 'Account';
            wr.timestamp = String.valueOf(System.now());
            wr.token = '123';
            APILog.WrapperAPI wa = APILog.getResponseAPI(wr);
            System.assertEquals('123', wr.token);
        }
    }

    @IsTest
    static void insertErrorLogTest() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            Map<String,String> maphhd = new Map<String,String>{ 'test' => 'test' };
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SFAWT17_InboundAPIAccountContactCreation');
            req.requestBody = Blob.valueOf('{ "key": "value" }');
            APILog.WrapperError we = new APILog.WrapperError('https://google.com','ABC');
            we.inEndpoint = 'https://google.com';
            we.mapheader = maphhd;
            we.objnm = 'Account';
            we.recid = null;
            we.requestApi = req;
            we.req = new HttpRequest();
            we.res = new HttpResponse();
            we.respondApi = new RestResponse();
            we.stringToSign = '123';
            we.typeApi = 'Inbound';
            APILog.insertErrorLog(null, we,'ok');
            System.assertEquals('123', we.stringToSign);
        }
    }

    @IsTest
    static void insertErrorLogTest2() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            String x = '1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
            Integer i = x.length();
            do{
                x = x+x;
                i = x.length();
            }while (i<=131072) ;
            Map<String,String> maphhd = new Map<String,String>{ 'test' => x };
            RestRequest req = new RestRequest();
            req.requestUri = '/services/apexrest/webserviceAPI/';
            req.httpMethod = 'POST';
            req.params.put('meta', 'SFAWT17_InboundAPIAccountContactCreation');
            req.requestBody = Blob.valueOf('{ "key": "value" }');
            APILog.WrapperError we = new APILog.WrapperError('https://google.com','ABC');
            we.inEndpoint = 'https://google.com';
            we.mapheader = maphhd;
            we.objnm = 'Account';
            we.recid = null;
            we.requestApi = req;
            we.req = new HttpRequest();
            we.res = new HttpResponse();
            we.respondApi = new RestResponse();
            we.stringToSign = '123';
            we.typeApi = 'Inbound';
            APILog.insertErrorLog(null, we,'ok');
            System.assertEquals('123', we.stringToSign);
        }
    }
}