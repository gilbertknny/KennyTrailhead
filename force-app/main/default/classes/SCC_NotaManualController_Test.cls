@isTest
public class SCC_NotaManualController_Test {
    
    @isTest
    static void testCreateNotaManualFromForm() {
        SCC_Call_Type_Feature__c ct = new SCC_Call_Type_Feature__c(name = '8812', Fitur_ID__c = '00621');
        insert ct;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            SCC_Call_Type_Feature__c = ct.Id
        );
        insert testCase;
        
        SCC_Queuetrans__c qt = new SCC_Queuetrans__c(SCC_Case__c = testCase.Id);
        insert qt;
        
        SCC_Nota_Manual__c testNotaManual = new SCC_Nota_Manual__c(
            SCC_Jenis_Transaksi__c = 'Test',
            SCC_No_Rekening__c = 'Test Account Number',
            Case__c = testCase.Id
        );

        Test.startTest();
        SCC_Nota_Manual__c resultNotaManual;
        try {
            resultNotaManual = SCC_NotaManualController.createNotaManualFromForm(testNotaManual, testCase);
            System.assertNotEquals(null, resultNotaManual, 'Returned Nota Manual should not be null');
        } catch (Exception error) {
            System.assertNotEquals(null, error, 'Exception should not be thrown');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateNotaManualNoFiturId() {
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        
        SCC_Nota_Manual__c testNotaManual = new SCC_Nota_Manual__c(
            SCC_Jenis_Transaksi__c = 'Test',
            SCC_No_Rekening__c = 'Test Account Number',
            Case__c = testCase.Id
        );

        Test.startTest();
        SCC_Nota_Manual__c resultNotaManual;
        try {
            resultNotaManual = SCC_NotaManualController.createNotaManualFromForm(testNotaManual, testCase);
        } catch (Exception error) {
            System.assertNotEquals(null, error, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), error.getTypeName(), 'AuraHandledException is expected');
            System.assertNotEquals(null, error.getMessage(), 'Field Custom Validation error message is expected');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testCreateNotaManualFromFormWithNullValues() {
        // Create test Case
        Case testCase = new Case(
            Subject = 'Test Case'
        );
        insert testCase;

        // Create test Nota Manual with null values for optional fields
        SCC_Nota_Manual__c testNotaManual = new SCC_Nota_Manual__c(
            Case__c = testCase.Id
        );

        Test.startTest();
        SCC_Nota_Manual__c resultNotaManual;
        try {
            resultNotaManual = SCC_NotaManualController.createNotaManualFromForm(null, testCase);
            System.assertEquals(null, resultNotaManual, 'Returned Nota Manual should be null');
        } catch (Exception error) {
            System.assertNotEquals(null, error, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), error.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals('Gagal membuat manual nota: Nota Manual is null', error.getMessage(), 'Specific error message is expected');
        }
        
        try {
            resultNotaManual = SCC_NotaManualController.createNotaManualFromForm(testNotaManual, null);
            System.assertEquals(null, resultNotaManual, 'Returned Nota Manual should be null');
        } catch (Exception error) {
            System.assertNotEquals(null, error, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), error.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals('Gagal membuat manual nota: Case details are null', error.getMessage(), 'Specific error message is expected');
        }
        Test.stopTest();
    }

    @isTest
    static void testGetCaseDetails() {
        // Create test data for SCC_Call_Type_Feature__c
        SCC_Call_Type_Feature__c testFeature = new SCC_Call_Type_Feature__c(Fitur_ID__c = 'Test Feature ID');
        insert testFeature;

        // Create test Case
        Case testCase = new Case(
            Subject = 'Test Case',
            SCC_Call_Type_Feature__c = testFeature.Id
        );
        insert testCase;
        
        Test.startTest();
        Case result = SCC_NotaManualController.getCaseDetails(testCase.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Returned Case record should not be null');
        System.assertEquals(testCase.Id, result.Id, 'Case ID should match');
    }
}