@isTest
public with sharing class SCC_DroneUpdateCase_Test {
    @TestSetup
    static void testsetup(){
        Case cs = new Case();
        cs.Origin = 'YouTube';
        cs.Status= 'New';
        cs.Priority = 'Low';
        cs.Subject = 'Test Subject';
        cs.Description = 'Desc';
        cs.SCC_Segment__c = 'Individu Umum';
        cs.SCC_Product_L1__c = 'Savings';
        insert cs;
    }

    @isTest
    static void UpdateCase() {
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        List<Case> cs = Database.query(queries);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/droneUpdateCase'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_DroneAPIWrapper.UpdateCaseRequestModel rcc = SCC_Drone_Object_Test.UpdateCaseRequestModel(String.valueOf(cs[0].Case_Number__c),1001,'1003',false,'');
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_DroneUpdateCase.UpdateCase();
        Test.stopTest();
    }
    
    @isTest
    static void CloseCase() {
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        List<Case> cs = Database.query(queries);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/droneUpdateCase'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        SCC_DroneAPIWrapper.UpdateCaseRequestModel rcc = SCC_Drone_Object_Test.UpdateCaseRequestModel(String.valueOf(cs[0].Case_Number__c),1001,'1003',true,'Closed');
        string testbody = json.serialize(rcc);
        req.requestBody = Blob.valueOf(testbody);
        RestContext.request = req;
        RestContext.response = res;
        SCC_DroneUpdateCase.UpdateCase();
        Test.stopTest();
    }

    @isTest
    static void UpdateCaseFalse() {
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        List<Case> cs = Database.query(queries);

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/droneUpdateCase'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        SCC_DroneUpdateCase.UpdateCase();
        Test.stopTest();
    }
}