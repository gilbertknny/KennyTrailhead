@IsTest
public with sharing class SCC_IncidentUpadet_Test {
    @TestSetup
    static void setupData() {

        Incident incident = new Incident(
            Subject = 'Ticket001 - Test',
            Urgency = 'Low',
            Impact = 'Minor / Localized',
            Nomor_tiket_iRIS__c = 'INC001',
            Resolution_Type__c = 'Initial',
            Root_Cause__c = 'None',
            Status = 'Open'
        );
        insert incident;
    }

    @IsTest
    static void testUpdateIncidentSuccess() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/updateIncident/INC001';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"resolutionType":"Resolved","rootCause":"Software Issue","status":"Closed","actionItem":"Reboot system","reopenStatus":"","reopenJustification":""}');
        RestContext.request = req;
        RestContext.response = res;
        SCC_IncidentUpdate.updateIncident();
        Test.stopTest();
    }

    @IsTest
    static void testUpdateIncidentMandatoryFieldMissing() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/updateIncident/INC001';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"resolutionType":"","rootCause":"Software Issue","status":"Resolved","actionItem":"","reopenStatus":"","reopenJustification":""}');
        RestContext.request = req;
        RestContext.response = res;
        SCC_IncidentUpdate.updateIncident();
        Test.stopTest();
    }

    @IsTest
    static void testUpdateIncidentMandatoryFieldMissing2() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/updateIncident/INC001';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"resolutionType":"test","rootCause":"","status":"Resolved","actionItem":"test","reopenStatus":"","reopenJustification":""}');
        RestContext.request = req;
        RestContext.response = res;
        SCC_IncidentUpdate.updateIncident();
        Test.stopTest();
    }

    @IsTest
    static void testUpdateIncidentMandatoryFieldMissing3() {
        
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/updateIncident/INC001';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('{"resolutionType":"test","rootCause":"","actionItem":"test","reopenStatus":"","reopenJustification":""}');
        RestContext.request = req;
        RestContext.response = res;
        SCC_IncidentUpdate.updateIncident();
        Test.stopTest();
    }

    @IsTest
    static void testUpdateIncidentMandatoryFieldMissing4(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.remoteAddress = '192.178.100.20';
        req.requestURI = '/services/apexrest/updateIncident/INC001';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        RestContext.response = res;
        SCC_IncidentUpdate.updateIncident();
        Test.stopTest();
    }
}