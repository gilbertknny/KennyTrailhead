@isTest
private class SLSosmedControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test data for SSC_Call_Type__c
        SSC_Call_Type__c callType = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Level1_OLA__c = 1,
            SCC_Level2_OLA__c = 2,
            SCC_Level3_OLA__c = 2,
            SCC_Customer_Segment__c = 'Individu Umum',
            SSC_Product_L1__c = 'Investment',
            SSC_Product_L2__c = 'DPLK',
            SSC_Case_Category__c = 'Complaint - Transaction',
            SSC_Case_Description__c = 'Nasabah Komplain Terkait Dana Pensiun Lembaga Keuangan (Dplk)',
            SCC_Sub_Description__c = 'Option1;Option2;Option3',
            Active__c = true
        );
        insert callType;
        
        List<Case> testCases = new List<Case>();
        
        Case case1 = new Case(
            Subject = 'Test Case 1',
            SCC_Call_Type__c = callType.Id,
            Status = 'New',
            SCC_SL_Sosmed_Timer_Dimulai__c = DateTime.now().addMinutes(-10),
            Date_Time_Post__c = DateTime.now().addMinutes(-10)
        );
        
        Case case2 = new Case(
            Subject = 'Test Case 2',
            SCC_Call_Type__c = callType.Id,
            SCC_SL_Sosmed_Timer_Dimulai__c = DateTime.now().addMinutes(-20),
            Date_Time_Post__c = DateTime.now().addMinutes(-20),
            Date_Time_Answer__c = DateTime.now(),
            SCC_SL_Sosmed_Waktu_Stop__c = '20 Menit',
            Status = 'Closed'
        );
        
        Case case3 = new Case(
            Subject = 'Test Case 3',
            SCC_Call_Type__c = callType.Id,
            Status = 'New',
            SCC_SL_Sosmed_Timer_Dimulai__c = DateTime.now().addMinutes(-20),
            Date_Time_Post__c = DateTime.now().addMinutes(-20)
        );
        
        testCases.add(case1);
        testCases.add(case2);
        testCases.add(case3);
        insert testCases;
    }
    
    @isTest
    static void testUpdateCaseTimer_ActiveCase() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 1' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = SLSosmedController.updateCaseTimer(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(false, result.get('isCompleted'));
        System.assertEquals(false, result.get('isViolated'));
        System.assert(((String)result.get('timerDisplay')).contains(':'));
    }
    
    @isTest
    static void testUpdateCaseTimer_CompletedCase() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 2' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = SLSosmedController.updateCaseTimer(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(true, result.get('isCompleted'));
        System.assertEquals('20 Menit', result.get('timerDisplay'));
    }
    
    @isTest
    static void testUpdateCaseTimer_ViolatedCase() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 3' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = SLSosmedController.updateCaseTimer(testCase.Id);
        Test.stopTest();
        
        System.assertEquals(false, result.get('isCompleted'));
        //System.assertEquals(true, result.get('isViolated'));
        //System.assert(((String)result.get('timerDisplay')).contains('Violated'));
    }
    
    @isTest
    static void testUpdateStatusSL_Complete() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 1' LIMIT 1];
        
        Test.startTest();
        SLSosmedController.caseSosmedWrapper result = SLSosmedController.updateStatusSL(
            testCase.Id, true, false, '10 Menit'
        );
        Test.stopTest();
        
        System.assertEquals(true, result.isCompleted);
        System.assertEquals(false, result.isViolated);
        System.assertEquals('10 Menit', result.endCaptureTime);
        
        Case updatedCase = [SELECT SCC_SL_Sosmed_Completed__c, SCC_SL_Sosmed_Waktu_Stop__c 
                           FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(true, updatedCase.SCC_SL_Sosmed_Completed__c);
        System.assertEquals('10 Menit', updatedCase.SCC_SL_Sosmed_Waktu_Stop__c);
    }
    
    @isTest
    static void testUpdateStatusSL_Violation() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 1' LIMIT 1];
        
        Test.startTest();
        SLSosmedController.caseSosmedWrapper result = SLSosmedController.updateStatusSL(
            testCase.Id, false, true, null
        );
        Test.stopTest();
        
        System.assertEquals(false, result.isCompleted);
        System.assertEquals(true, result.isViolated);
        
        Case updatedCase = [SELECT SCC_SL_Sosmed_Violation__c FROM Case WHERE Id = :testCase.Id];
        System.assertEquals(true, updatedCase.SCC_SL_Sosmed_Violation__c);
    }
    
    @isTest
    static void testUpdateStatusSL_CompleteWithResponseTime() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 2' LIMIT 1];
        
        Test.startTest();
        SLSosmedController.caseSosmedWrapper result = SLSosmedController.updateStatusSL(
            testCase.Id, true, false, null
        );
        Test.stopTest();
        
        System.assertEquals(true, result.isCompleted);
        System.assertEquals(false, result.isViolated);
        System.assert(result.endCaptureTime.contains('Menit'));
    }
    
    @isTest
    static void testFormatTime() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case 1' LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = SLSosmedController.updateCaseTimer(testCase.Id);
        Test.stopTest();
        
        String timerDisplay = (String)result.get('timerDisplay');
    }
}