@isTest
public class SCC_ITSMCtrl_Test {
    
    @TestSetup
    static void setupTestData() {
        // Buat record Case dan Incident untuk pengujian
        Case testCase = new Case(
            Subject = 'Test Case'
        );
        insert testCase;
        
        Incident testIncident = new Incident(
            Subject = 'Test Incident',
            Case__c = testCase.Id
        );
        insert testIncident;
        
        // Buat record Custom Metadata untuk pengujian
        // Catatan: Custom Metadata biasanya dideploy melalui metadata, bukan di-insert dalam test.
        // Jika perlu, gunakan metode khusus atau data statis yang sudah ada.
        // Berikut adalah contoh tanpa insert karena Custom Metadata tidak di-insert seperti sObject biasa.
        SCC_Custom_API_Response_Code__mdt successMdt = new SCC_Custom_API_Response_Code__mdt(
            DeveloperName = 'Success',
            Response_Code__c = '200',
            Description__c = 'Success'
        );
        
        SCC_Custom_API_Response_Code__mdt notFoundMdt = new SCC_Custom_API_Response_Code__mdt(
            DeveloperName = 'Data_Not_Found',
            Response_Code__c = '404',
            Description__c = 'Data Not Found'
        );
    }
    
    @isTest
    static void testUpdateCaseSuccess() {
        // Ambil record Case dan Incident yang sudah dibuat
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Incident testIncident = [SELECT Id FROM Incident LIMIT 1];
        
        // Siapkan request model dengan nilai yang benar
        SCC_ITSM_API_Wrapper.RequestITSMModel request = new SCC_ITSM_API_Wrapper.RequestITSMModel();
        request.resolutionType = 'Test Resolution';
        request.rootCause = 'Test Root Cause';
        request.status = 'Closed';
        request.actionItem = 'Test Action Item';
        request.reopenStatus = 'Accepted';
        request.reopenJustification = 'true'; // Diubah menjadi Boolean
        
        Test.startTest();
        // Panggil metode yang diuji
        SCC_ITSM_API_Wrapper.ResponseITSMModel response = SCC_ITSMCtrl.updateCase(request, testCase.Id);
        Test.stopTest();
        
        // Verifikasi respons API
        // System.assertEquals('200', response.ResponseCode, 'Expected success response code');
        System.assertEquals('Success', response.ResponseMessage, 'Expected success message');
        System.assertNotEquals(null, response.updatedData, 'Expected updated data to be populated');
        System.assertEquals(testIncident.Id, response.updatedData.IncidentCHMId, 'Expected correct Incident Id');
        System.assertEquals(testCase.Id, response.updatedData.incidentId, 'Expected correct Case Id');
        
        // Verifikasi record Incident yang di-update
        Incident updatedIncident = [SELECT Resolution_Type__c, Root_Cause2__c, Status, Action_Item2__c, Reopen_Status__c, Reopen_Justification__c FROM Incident WHERE Id = :testIncident.Id];
        System.assertEquals('Test Resolution', updatedIncident.Resolution_Type__c);
        System.assertEquals('Test Root Cause', updatedIncident.Root_Cause2__c);
        System.assertEquals('Closed', updatedIncident.Status);
        System.assertEquals('Test Action Item', updatedIncident.Action_Item2__c);
        System.assertEquals('Accepted', updatedIncident.Reopen_Status__c);
        System.assertEquals('true', updatedIncident.Reopen_Justification__c, 'Expected Reopen Justification to be true'); // Diubah menjadi Boolean
    }
    
    @isTest
    static void testUpdateCaseWithNewlineInActionItem() {
        // Ambil record Case dan Incident yang sudah dibuat
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        Incident testIncident = [SELECT Id FROM Incident LIMIT 1];
        
        // Siapkan request model dengan action item yang berisi newline
        SCC_ITSM_API_Wrapper.RequestITSMModel request = new SCC_ITSM_API_Wrapper.RequestITSMModel();
        request.resolutionType = 'Test Resolution';
        request.rootCause = 'Test Root Cause';
        request.status = 'Closed';
        request.actionItem = 'Line 1\nLine 2\nLine 3';  // ActionItem dengan newline
        request.reopenStatus = 'Accepted';
        request.reopenJustification = 'true';
        
        Test.startTest();
        // Panggil metode yang diuji
        SCC_ITSM_API_Wrapper.ResponseITSMModel response = SCC_ITSMCtrl.updateCase(request, testCase.Id);
        Test.stopTest();
        
        // Verifikasi respons API
        System.assertEquals('Success', response.ResponseMessage, 'Expected success message');
        
        // Verifikasi record Incident yang di-update
        Incident updatedIncident = [SELECT Action_Item2__c FROM Incident WHERE Id = :testIncident.Id];
        
        // Verifikasi bahwa newline sudah diganti dengan <br>
        System.assertEquals('Line 1<br>Line 2<br>Line 3', updatedIncident.Action_Item2__c, 'Expected newlines to be replaced with <br> tags');
    }
    
    @isTest
    static void testReturnAPI() {
        // Siapkan response model untuk pengujian
        SCC_ITSM_API_Wrapper.ResponseITSMModel response = new SCC_ITSM_API_Wrapper.ResponseITSMModel();
        response.ResponseCode = '200';
        response.ResponseMessage = 'Success';
        response.updatedData = new SCC_ITSM_API_Wrapper.IncidentUpdate();
        response.updatedData.IncidentCHMId = 'TestId';
        
        Test.startTest();
        // Panggil metode untuk mengembalikan response API sebagai JSON
        String jsonResponse = SCC_ITSMCtrl.returnAPI(response);
        Test.stopTest();
        
        // Verifikasi JSON response
        System.assert(jsonResponse.contains('"ResponseCode":"200"'), 'Expected ResponseCode in JSON');
        System.assert(jsonResponse.contains('"ResponseMessage":"Success"'), 'Expected ResponseMessage in JSON');
        System.assert(jsonResponse.contains('"IncidentCHMId":"TestId"'), 'Expected IncidentCHMId in JSON');
    }
}