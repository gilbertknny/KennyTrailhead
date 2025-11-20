@isTest
private class EventMonitoring_API_Wrapper_Test {
    
    @isTest
    static void testGetRequestModel() {
        // Test GetRequest_Model
        EventMonitoring_API_Wrapper.GetRequest_Model request = new EventMonitoring_API_Wrapper.GetRequest_Model();
        request.startDate = '2024-01-01';
        request.endDate = '2024-01-31';
        request.area = 'Test Area';
        request.costCenter = 'CC001';
        request.region = 'Region1';
        request.mainBranch = 'MB001';
        request.branch = 'B001';
        request.page = '1';
        request.lmt = '10';
        
        System.assertNotEquals(null, request);
        System.assertEquals('2024-01-01', request.startDate);
        System.assertEquals('Test Area', request.area);
    }
    
    @isTest
    static void testGetKPModels() {
        // Test GetActivitiesKP_Model
        EventMonitoring_API_Wrapper.GetActivitiesKP_Model activities = new EventMonitoring_API_Wrapper.GetActivitiesKP_Model();
        activities.anomalyType = 'Type1';
        activities.total = '5';
        
        System.assertEquals('Type1', activities.anomalyType);
        
        // Test GetDetailKP_Model
        EventMonitoring_API_Wrapper.GetDetailKP_Model detail = new EventMonitoring_API_Wrapper.GetDetailKP_Model();
        detail.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesKP_Model>{activities};
        detail.cosCenter = 'CC001';
        detail.cosCenterDesc = 'Cost Center 1';
        detail.totalActivities = '5';
        
        System.assertEquals(1, detail.activities.size());
        
        // Test GetResponseKP_Model
        EventMonitoring_API_Wrapper.GetResponseKP_Model response = new EventMonitoring_API_Wrapper.GetResponseKP_Model();
        response.divisionSummary = new List<EventMonitoring_API_Wrapper.GetDetailKP_Model>{detail};
        response.responseCode = '200';
        response.responseMessage = 'Success';
        response.area = 'Test Area';
        
        System.assertEquals('200', response.responseCode);
    }
    
    @isTest
    static void testGetKPCostCenterModels() {
        // Test GetDataActivitiesKP1_Model
        EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model activities = new EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model();
        activities.user_Name = 'Test User';
        activities.total = '10';
        activities.tanggal = '2024-01-01';
        activities.monitoringSummary_Name = 'Summary1';
        activities.anomalyCategory_RecordType = 'Type1';
        
        // Test GetResponseKP1_Model
        EventMonitoring_API_Wrapper.GetResponseKP1_Model response = new EventMonitoring_API_Wrapper.GetResponseKP1_Model();
        response.dataActivities = new List<EventMonitoring_API_Wrapper.GetDataActivitiesKP1_Model>{activities};
        response.responseMessage = 'Success';
        response.responseCode = '200';
        response.area = 'Test Area';
        response.costCenter = 'CC001';
        response.costCenterDesc = 'Cost Center 1';
        response.totalActivities = '10';
        
        System.assertEquals(1, response.dataActivities.size());
        System.assertEquals('CC001', response.costCenter);
    }
    
    @isTest
    static void testGetROModels() {
        // Test GetActivitiesRO_Model
        EventMonitoring_API_Wrapper.GetActivitiesRO_Model activities = new EventMonitoring_API_Wrapper.GetActivitiesRO_Model();
        activities.anomalyType = 'Type1';
        activities.total = '5';
        
        // Test GetDetailRO_Model
        EventMonitoring_API_Wrapper.GetDetailRO_Model detail = new EventMonitoring_API_Wrapper.GetDetailRO_Model();
        detail.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO_Model>{activities};
        detail.region = 'Region1';
        detail.regionDesc = 'Region 1';
        detail.totalActivities = '5';
        
        // Test GetResponseRO_Model
        EventMonitoring_API_Wrapper.GetResponseRO_Model response = new EventMonitoring_API_Wrapper.GetResponseRO_Model();
        response.regionalOfficeSummary = new List<EventMonitoring_API_Wrapper.GetDetailRO_Model>{detail};
        response.responseMessage = 'Success';
        response.responseCode = '200';
        response.area = 'Test Area';
        
        System.assertEquals(1, response.regionalOfficeSummary.size());
    }
    
    @isTest
    static void testGetRORegionModels() {
        // Test GetActivitiesRO1_Model and GetDetailRO1_Model
        EventMonitoring_API_Wrapper.GetActivitiesRO1_Model activities = new EventMonitoring_API_Wrapper.GetActivitiesRO1_Model();
        activities.anomalyType = 'Type1';
        activities.total = '5';
        
        EventMonitoring_API_Wrapper.GetDetailRO1_Model detail = new EventMonitoring_API_Wrapper.GetDetailRO1_Model();
        detail.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO1_Model>{activities};
        detail.mainBranch = 'MB001';
        detail.mainBranchDesc = 'Main Branch 1';
        detail.totalActivities = '5';
        
        // Test GetDetailActivitiesRO1_Model with all fields
        EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model detailActivities = new EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model();
        detailActivities.user_Name = 'Test User';
        detailActivities.mainBranch = 'MB001';
        detailActivities.mainBranchDesc = 'Main Branch 1';
        detailActivities.branchCode = 'B001';
        detailActivities.branchDesc = 'Branch 1';
        detailActivities.total = '10';
        detailActivities.tanggal = '2024-01-01';
        detailActivities.monitoringSummary_Name = 'Summary1';
        detailActivities.anomalyCategory_RecordType = 'Type1';
        
        // Test GetResponseRO1_Model with all fields
        EventMonitoring_API_Wrapper.GetResponseRO1_Model response = new EventMonitoring_API_Wrapper.GetResponseRO1_Model();
        response.branchOfficeSummary = new List<EventMonitoring_API_Wrapper.GetDetailRO1_Model>{detail};
        response.DataActivities = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO1_Model>{detailActivities};
        response.responseMessage = 'Success';
        response.responseCode = '200';
        response.area = 'Test Area';
        response.region = 'Region1';
        response.regionDesc = 'Region 1';
        response.totalActivities = '15';
        
        // Add assertions for all fields
        System.assertEquals('Test User', response.DataActivities[0].user_Name);
        System.assertEquals('2024-01-01', response.DataActivities[0].tanggal);
        System.assertEquals('Summary1', response.DataActivities[0].monitoringSummary_Name);
        System.assertEquals('Type1', response.DataActivities[0].anomalyCategory_RecordType);
        System.assertEquals('Region1', response.region);
        System.assertEquals('Region 1', response.regionDesc);
        System.assertEquals('15', response.totalActivities);
    }
    
    @isTest
    static void testGetRORegionMainBrModels() {
        // Test GetActivitiesRO2_Model
        EventMonitoring_API_Wrapper.GetActivitiesRO2_Model activities = new EventMonitoring_API_Wrapper.GetActivitiesRO2_Model();
        activities.anomalyType = 'Type1';
        activities.total = '5';
        
        // Test GetDetailRO2_Model
        EventMonitoring_API_Wrapper.GetDetailRO2_Model detail = new EventMonitoring_API_Wrapper.GetDetailRO2_Model();
        detail.activities = new List<EventMonitoring_API_Wrapper.GetActivitiesRO2_Model>{activities};
        detail.branchCode = 'B001';
        detail.branchDesc = 'Branch 1';
        detail.totalActivities = '5';
        
        // Test GetDetailActivitiesRO2_Model with all fields
        EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model detailActivities = new EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model();
        detailActivities.user_Name = 'Test User';
        detailActivities.branchCode = 'B001';
        detailActivities.branchDesc = 'Branch 1';
        detailActivities.total = '10';
        detailActivities.tanggal = '2024-01-01';
        detailActivities.monitoringSummary_Name = 'Summary1';
        detailActivities.anomalyCategory_RecordType = 'Type1';
        
        // Test GetResponseRO2_Model with all fields
        EventMonitoring_API_Wrapper.GetResponseRO2_Model response = new EventMonitoring_API_Wrapper.GetResponseRO2_Model();
        response.BranchSummary = new List<EventMonitoring_API_Wrapper.GetDetailRO2_Model>{detail};
        response.DataActivities = new List<EventMonitoring_API_Wrapper.GetDetailActivitiesRO2_Model>{detailActivities};
        response.responseMessage = 'Success';
        response.responseCode = '200';
        response.area = 'Test Area';
        response.region = 'Region1';
        response.regionDesc = 'Region 1';
        response.mainBranch = 'MB001';
        response.mainBranchDesc = 'Main Branch 1';
        response.totalActivities = '15';
        
        // Add assertions for all fields
        System.assertEquals('Test User', response.DataActivities[0].user_Name);
        System.assertEquals('2024-01-01', response.DataActivities[0].tanggal);
        System.assertEquals('Summary1', response.DataActivities[0].monitoringSummary_Name);
        System.assertEquals('Type1', response.DataActivities[0].anomalyCategory_RecordType);
        System.assertEquals('Region1', response.region);
        System.assertEquals('Region 1', response.regionDesc);
        System.assertEquals('MB001', response.mainBranch);
        System.assertEquals('Main Branch 1', response.mainBranchDesc);
        System.assertEquals('15', response.totalActivities);
    }
    
    @isTest
    static void testGetRORegionMainBrBranchModels() {
        // Test GetDetailRO3_Model and GetResponseRO3_Model
        EventMonitoring_API_Wrapper.GetDetailRO3_Model detail = new EventMonitoring_API_Wrapper.GetDetailRO3_Model();
        detail.user_Name = 'Test User';
        detail.total = '5';
        detail.tanggal = '2024-01-01';
        detail.monitoringSummary_Name = 'Summary1';
        detail.anomalyCategory_RecordType = 'Type1';
        
        EventMonitoring_API_Wrapper.GetResponseRO3_Model response = new EventMonitoring_API_Wrapper.GetResponseRO3_Model();
        response.DataActivities = new List<EventMonitoring_API_Wrapper.GetDetailRO3_Model>{detail};
        response.responseMessage = 'Success';
        response.responseCode = '200';
        response.area = 'Test Area';
        response.region = 'Region1';
        response.regionDesc = 'Region 1';
        response.mainBranch = 'MB001';
        response.mainBranchDesc = 'Main Branch 1';
        response.branchCode = 'B001';
        response.branchDesc = 'Branch 1';
        response.totalActivities = '5';
        
        System.assertEquals(1, response.DataActivities.size());
        System.assertEquals('Success', response.responseMessage);
    }
    
    @isTest
    static void testGetResponseModel() {
        // Test GetResponseModel
        EventMonitoring_API_Wrapper.GetResponseModel response = new EventMonitoring_API_Wrapper.GetResponseModel();
        response.responseMessage = 'Success';
        response.responseCode = '200';
        
        System.assertEquals('Success', response.responseMessage);
        System.assertEquals('200', response.responseCode);
    }

    // Add these new test methods at the end of your class
    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{invalid_json}');
        
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        
        EventMonitoring_API.GetEventMonitoring();
        
        System.assertEquals(200, res.statusCode);
        String responseBody = res.responseBody.toString();
        System.assert(responseBody.contains('responseCode'));
        System.assert(responseBody.contains('responseMessage'));
        
        Test.stopTest();
    }

    @isTest
    static void testDifferentExceptionTypes() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        RestResponse res = new RestResponse();
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        
        // Test case 1: NullPointerException
        req.requestBody = null;
        EventMonitoring_API.GetEventMonitoring();
        
        // Test case 2: JSONException with different message
        req.requestBody = Blob.valueOf('{"malformed": "json"');
        EventMonitoring_API.GetEventMonitoring();
        
        // Test case 3: Custom exception scenario
        req.requestBody = Blob.valueOf('{"startDate": "invalid_date"}');
        EventMonitoring_API.GetEventMonitoring();
        
        Test.stopTest();
    }

    @isTest
    static void testInsertErrorLog() {
        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/EventMonitoringQuery/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('test body');
        req.headers.put('Test-Header', 'test value');
        
        RestResponse res = new RestResponse();
        res.statusCode = 400;
        
        Exception testException = new NullPointerException();
        try {
            String s = null;
            s.length();
        } catch (Exception e) {
            testException = e;
        }
        
        Test.startTest();
        EventMonitoring_API.InsertErrorLog(
            testException,
            req,
            res,
            'test return json'
        );
        Test.stopTest();
    }
}