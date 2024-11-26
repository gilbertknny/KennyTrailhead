@isTest
private class BristarSummary_API_Wrapper_Test {
    
    @isTest
    static void testGetRequestModel() {
        Test.startTest();
        
        BristarSummary_API_Wrapper.GetRequest_Model request = new BristarSummary_API_Wrapper.GetRequest_Model();
        request.startDate = '2024-01-01';
        request.endDate = '2024-12-31';
        request.statusTicket = 'Open';
        request.area = 'Test Area';
        request.costCenter = 'CC001';
        request.region = 'Region1';
        request.mainBranch = 'MB001';
        request.branch = 'B001';
        request.page = '1';
        request.lmt = '10';
        
        System.assertNotEquals(null, request);
        System.assertEquals('2024-01-01', request.startDate);
        System.assertEquals('2024-12-31', request.endDate);
        System.assertEquals('Open', request.statusTicket);
        System.assertEquals('Test Area', request.area);
        System.assertEquals('CC001', request.costCenter);
        System.assertEquals('Region1', request.region);
        System.assertEquals('MB001', request.mainBranch);
        System.assertEquals('B001', request.branch);
        System.assertEquals('1', request.page);
        System.assertEquals('10', request.lmt);
        
        Test.stopTest();
    }
    
    @isTest
    static void testKantorPusatModels() {
        Test.startTest();
        
        // Test GetDetailKP_Model
        BristarSummary_API_Wrapper.GetDetailKP_Model detailKP = new BristarSummary_API_Wrapper.GetDetailKP_Model();
        detailKP.costCenter = 'CC001';
        detailKP.costCenterDesc = 'Cost Center 1';
        detailKP.openTicket = '5';
        detailKP.closedTicket = '3';
        detailKP.overSla = '1';
        detailKP.onSla = '7';
        
        System.assertEquals('CC001', detailKP.costCenter);
        System.assertEquals('Cost Center 1', detailKP.costCenterDesc);
        System.assertEquals('5', detailKP.openTicket);
        System.assertEquals('3', detailKP.closedTicket);
        System.assertEquals('1', detailKP.overSla);
        System.assertEquals('7', detailKP.onSla);
        
        // Test GetResponseKP_Model
        BristarSummary_API_Wrapper.GetResponseKP_Model responseKP = new BristarSummary_API_Wrapper.GetResponseKP_Model();
        responseKP.divisionSummary = new List<BristarSummary_API_Wrapper.GetDetailKP_Model>{detailKP};
        responseKP.responseCode = '200';
        responseKP.responseMessage = 'Success';
        responseKP.area = 'Test Area';
        
        System.assertEquals(1, responseKP.divisionSummary.size());
        System.assertEquals('200', responseKP.responseCode);
        System.assertEquals('Success', responseKP.responseMessage);
        System.assertEquals('Test Area', responseKP.area);
        
        Test.stopTest();
    }
    
    @isTest
    static void testKantorPusatDivisiModels() {
        Test.startTest();
        
        // Test GetDetailKP1_Model
        BristarSummary_API_Wrapper.GetDetailKP1_Model detailKP1 = new BristarSummary_API_Wrapper.GetDetailKP1_Model();
        detailKP1.caseNumber = 'CASE001';
        detailKP1.createdTime = '2024-01-01';
        detailKP1.closedTime = '2024-01-02';
        detailKP1.status = 'Closed';
        detailKP1.caseType = 'Support';
        detailKP1.caseDescription = 'Test Case';
        detailKP1.slaSaatIni = '24';
        detailKP1.targetSla = '48';
        detailKP1.gapTerhadapSla = '24';
        
        System.assertEquals('CASE001', detailKP1.caseNumber);
        System.assertEquals('2024-01-01', detailKP1.createdTime);
        System.assertEquals('2024-01-02', detailKP1.closedTime);
        System.assertEquals('Closed', detailKP1.status);
        System.assertEquals('Support', detailKP1.caseType);
        System.assertEquals('Test Case', detailKP1.caseDescription);
        
        // Test GetResponseKP1_Model
        BristarSummary_API_Wrapper.GetResponseKP1_Model responseKP1 = new BristarSummary_API_Wrapper.GetResponseKP1_Model();
        responseKP1.ticketSummary = new List<BristarSummary_API_Wrapper.GetDetailKP1_Model>{detailKP1};
        responseKP1.responseMessage = 'Success';
        responseKP1.responseCode = '200';
        responseKP1.area = 'Test Area';
        responseKP1.costCenter = 'CC001';
        responseKP1.costCenterDesc = 'Cost Center 1';
        responseKP1.openTicket = '5';
        responseKP1.closedTicket = '3';
        responseKP1.overSla = '1';
        responseKP1.onSLa = '7';
        
        System.assertEquals(1, responseKP1.ticketSummary.size());
        System.assertEquals('Success', responseKP1.responseMessage);
        System.assertEquals('200', responseKP1.responseCode);
        
        Test.stopTest();
    }
    
    @isTest
    static void testKantorWilayahModels() {
        Test.startTest();
        
        // Test GetDetailRO_Model
        BristarSummary_API_Wrapper.GetDetailRO_Model detailRO = new BristarSummary_API_Wrapper.GetDetailRO_Model();
        detailRO.region = 'Region1';
        detailRO.regionDesc = 'Region One';
        detailRO.openTicket = '5';
        detailRO.closedTicket = '3';
        detailRO.overSla = '1';
        detailRO.onSla = '7';
        
        System.assertEquals('Region1', detailRO.region);
        System.assertEquals('Region One', detailRO.regionDesc);
        
        // Test GetResponseRO_Model
        BristarSummary_API_Wrapper.GetResponseRO_Model responseRO = new BristarSummary_API_Wrapper.GetResponseRO_Model();
        responseRO.regionSummary = new List<BristarSummary_API_Wrapper.GetDetailRO_Model>{detailRO};
        responseRO.responseCode = '200';
        responseRO.responseMessage = 'Success';
        responseRO.area = 'Test Area';
        
        System.assertEquals(1, responseRO.regionSummary.size());
        System.assertEquals('200', responseRO.responseCode);
        
        Test.stopTest();
    }
    
    @isTest
    static void testKantorWilayahRegionModels() {
        Test.startTest();
        
        // Test GetDetailRO1_Model
        BristarSummary_API_Wrapper.GetDetailRO1_Model detailRO1 = new BristarSummary_API_Wrapper.GetDetailRO1_Model();
        detailRO1.mainBranch = 'MB001';
        detailRO1.mainBranchDesc = 'Main Branch One';
        detailRO1.openTicket = '5';
        detailRO1.closedTicket = '3';
        detailRO1.overSla = '1';
        detailRO1.onSla = '7';
        
        System.assertEquals('MB001', detailRO1.mainBranch);
        System.assertEquals('Main Branch One', detailRO1.mainBranchDesc);
        
        // Test GetResponseRO1_Model
        BristarSummary_API_Wrapper.GetResponseRO1_Model responseRO1 = new BristarSummary_API_Wrapper.GetResponseRO1_Model();
        responseRO1.mainBranchSummary = new List<BristarSummary_API_Wrapper.GetDetailRO1_Model>{detailRO1};
        responseRO1.responseCode = '200';
        responseRO1.responseMessage = 'Success';
        responseRO1.area = 'Test Area';
        responseRO1.region = 'Region1';
        responseRO1.regionDesc = 'Region One';
        
        System.assertEquals(1, responseRO1.mainBranchSummary.size());
        System.assertEquals('200', responseRO1.responseCode);
        
        Test.stopTest();
    }
    
    @isTest
    static void testKantorWilayahRegionMainBrModels() {
        Test.startTest();
        
        // Test GetDetailRO2_Model
        BristarSummary_API_Wrapper.GetDetailRO2_Model detailRO2 = new BristarSummary_API_Wrapper.GetDetailRO2_Model();
        detailRO2.branch = 'B001';
        detailRO2.branchDesc = 'Branch One';
        detailRO2.openTicket = '5';
        detailRO2.closedTicket = '3';
        detailRO2.overSla = '1';
        detailRO2.onSla = '7';
        
        System.assertEquals('B001', detailRO2.branch);
        System.assertEquals('Branch One', detailRO2.branchDesc);
        
        // Test GetResponseRO2_Model
        BristarSummary_API_Wrapper.GetResponseRO2_Model responseRO2 = new BristarSummary_API_Wrapper.GetResponseRO2_Model();
        responseRO2.branchSummary = new List<BristarSummary_API_Wrapper.GetDetailRO2_Model>{detailRO2};
        responseRO2.responseCode = '200';
        responseRO2.responseMessage = 'Success';
        responseRO2.area = 'Test Area';
        responseRO2.region = 'Region1';
        responseRO2.regionDesc = 'Region One';
        responseRO2.mainBranch = 'MB001';
        responseRO2.mainBranchDesc = 'Main Branch One';
        
        System.assertEquals(1, responseRO2.branchSummary.size());
        System.assertEquals('200', responseRO2.responseCode);
        
        Test.stopTest();
    }
    
    @isTest
    static void testKantorWilayahRegionMainBrBranchModels() {
        Test.startTest();
        
        // Test GetDetailRO3_Model
        BristarSummary_API_Wrapper.GetDetailRO3_Model detailRO3 = new BristarSummary_API_Wrapper.GetDetailRO3_Model();
        detailRO3.caseNumber = 'CASE002';
        detailRO3.createdTime = '2024-01-01';
        detailRO3.closedTime = '2024-01-02';
        detailRO3.status = 'Closed';
        detailRO3.caseType = 'Support';
        detailRO3.caseDescription = 'Test Case';
        detailRO3.slaSaatIni = '24';
        detailRO3.targetSla = '48';
        detailRO3.gapTerhadapSla = '24';
        
        System.assertEquals('CASE002', detailRO3.caseNumber);
        System.assertEquals('2024-01-01', detailRO3.createdTime);
        
        // Test GetResponseRO3_Model
        BristarSummary_API_Wrapper.GetResponseRO3_Model responseRO3 = new BristarSummary_API_Wrapper.GetResponseRO3_Model();
        responseRO3.ticketSummary = new List<BristarSummary_API_Wrapper.GetDetailRO3_Model>{detailRO3};
        responseRO3.responseMessage = 'Success';
        responseRO3.responseCode = '200';
        responseRO3.area = 'Test Area';
        responseRO3.region = 'Region1';
        responseRO3.regionDesc = 'Region One';
        responseRO3.mainBranch = 'MB001';
        responseRO3.mainBranchDesc = 'Main Branch One';
        responseRO3.branch = 'B001';
        responseRO3.branchDesc = 'Branch One';
        responseRO3.openTicket = '5';
        responseRO3.closedTicket = '3';
        responseRO3.overSla = '1';
        responseRO3.onSLa = '7';
        
        System.assertEquals(1, responseRO3.ticketSummary.size());
        System.assertEquals('Success', responseRO3.responseMessage);
        
        Test.stopTest();
    }
    
    @isTest
    static void testGetResponseModel() {
        Test.startTest();
        
        BristarSummary_API_Wrapper.GetResponseModel response = new BristarSummary_API_Wrapper.GetResponseModel();
        response.responseCode = '200';
        response.responseMessage = 'Success';
        
        System.assertEquals('200', response.responseCode);
        System.assertEquals('Success', response.responseMessage);
        
        Test.stopTest();
    }
}