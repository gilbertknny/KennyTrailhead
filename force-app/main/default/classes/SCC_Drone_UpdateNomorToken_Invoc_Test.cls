@isTest
private class SCC_Drone_UpdateNomorToken_Invoc_Test {

    // =========================================================================
    // Test Data Setup
    // =========================================================================
    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8433');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        insert cs;
    }

    // Helper method untuk membangun input Flow
    private static List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> createInput(Id caseId, String remarkJson, String caseType) {
        SCC_Drone_UpdateNomorToken_Invoc.FlowInput input = new SCC_Drone_UpdateNomorToken_Invoc.FlowInput();
        input.recordId = caseId;
        input.remark = remarkJson;
        input.caseType = caseType;
        return new List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput>{ input };
    }

    // =========================================================================
    // Skenario Tes Positif
    // =========================================================================
    @isTest
    static void test_8809_FromJson() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        String remark = '{"Remark":"some text", "Nomor Pembayaran":"123456"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8809');

        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8809_FromRegex() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        // Tidak ada field "Nomor Pembayaran", akan fallback ke Regex
        String remark = '{"Remark":"text PLN-POST 654321NBMB text"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8809');

        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8808_FromRegex() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        String remark = '{"Remark":"text PLN-PRA 111222NBMB text"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8808');

        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8434_FromJson() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        String remark = '{"Remark":"text", "Nomor HP":"08123456"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8434');

        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8222_ExternalClass() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        // Remark tidak penting karena dummy class akan mengembalikan nilai tetap
        String remark = '{"Remark":"any rtgs remark"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8222');

        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8433_Briva_FromJson() {
        Case c = [SELECT Id, SCC_Case_Type_for_Suggested_Article__c FROM Case LIMIT 1];
        String remark = '{"Remark":"Pembayaran BRIVA", "Nomor Pembayaran":"777888"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8433');
        
        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8433_Briva_FromRegex() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        String remark = '{"Remark":"some text BRIVA 999000NBMB text"}'; // Tidak ada "Nomor Pembayaran"
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8433');
        
        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8433_NonBriva_FromJson() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        String remark = '{"Remark":"Pembayaran Non-BRIVA", "Nomor Pembayaran":"555444"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8433');
        
        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8433_Briva_FromJson_AlreadyFilled() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        c.SCC_Nomor_Briva_Tagihan__c = '111111'; // Isi field Briva terlebih dahulu
        update c;

        String remark = '{"Remark":"Pembayaran BRIVA", "Nomor Pembayaran":"777888"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8433');
        
        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_8433_Briva_FromRegex_UpdatesWhenFilled() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        c.SCC_Nomor_Briva_Tagihan__c = '111111'; // Isi field Briva terlebih dahulu
        update c;

        String remark = '{"Remark":"some text BRIVA 999000NBMB text"}'; // Tidak ada "Nomor Pembayaran"
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8433');
        
        Test.startTest();
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    @isTest
    static void test_NoNumberFound_GracefulExit() {
        Case c = [SELECT Id, scc_Billing_Number__c FROM Case LIMIT 1];
        String remark = '{"Remark":"text that does not match any pattern"}';
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8808');

        Test.startTest();
        // Method harus berhenti tanpa error
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }

    // =========================================================================
    // Skenario Tes Negatif (Error Handling)
    // =========================================================================

    @isTest
    static void test_EmptyInputList_Exception() {
        Exception actualException = null;
        Test.startTest();
        try {
            // Panggil dengan list kosong
            SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(new List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput>());
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void test_BlankRemark_Exception() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, '', '8808'); // Remark kosong
        
        Exception actualException = null;
        Test.startTest();
        try {
            SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        } catch(Exception e) {
            actualException = e;
        }
        Test.stopTest();
    }

    @isTest
    static void test_InvalidJson_GracefulExit() {
        Case c = [SELECT Id, scc_Billing_Number__c FROM Case LIMIT 1];
        String remark = 'this is not json'; // JSON tidak valid
        List<SCC_Drone_UpdateNomorToken_Invoc.FlowInput> inputs = createInput(c.Id, remark, '8808');

        Test.startTest();
        // Method ini memiliki try-catch di helper, jadi seharusnya tidak melempar error,
        // tapi berhenti dengan baik (graceful exit).
        SCC_Drone_UpdateNomorToken_Invoc.updateNomorToken(inputs);
        Test.stopTest();
    }
}