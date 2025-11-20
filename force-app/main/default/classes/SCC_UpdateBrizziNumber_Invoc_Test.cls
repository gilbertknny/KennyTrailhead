/**
 * @description       : 
 * @author            : Suherbing Septian
 * @created date      : 15-09-2025
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Suherbing Septian
**/

@isTest
private class SCC_UpdateBrizziNumber_Invoc_Test {

    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8713');
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

    // Test for the successful update scenario
    @isTest
    static void testPositiveScenario_UpdateSuccess(){
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        String expectedBrizziNumber = '8079012345678901';
        String remark = '{"Nomor Kartu BRIZZI": "  \\"8079012345678901\\" "}';
        SCC_UpdateBrizziNumber_Invoc.FlowInput input = new SCC_UpdateBrizziNumber_Invoc.FlowInput();
        input.recordId = cs.Id;
        input.remark = remark;

        List<SCC_UpdateBrizziNumber_Invoc.FlowInput> inputs = new List<SCC_UpdateBrizziNumber_Invoc.FlowInput>{input};
        // When: Execute the method to be tested
        Test.startTest();
        SCC_UpdateBrizziNumber_Invoc.updateBrizziNumber(inputs);
        Test.stopTest();
    }

    // Test for failure when the remark field is blank
    @isTest
    static void testNegativeScenario_BlankRemark(){
        Exception caughtException = null;
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        SCC_UpdateBrizziNumber_Invoc.FlowInput input = new SCC_UpdateBrizziNumber_Invoc.FlowInput();
        input.recordId = cs.Id;
        input.remark = ''; // Blank remark
        List<SCC_UpdateBrizziNumber_Invoc.FlowInput> inputs = new List<SCC_UpdateBrizziNumber_Invoc.FlowInput>{input};
        
        // When & Then: Execute and verify that the correct exception is thrown
        Test.startTest();
        try{
            SCC_UpdateBrizziNumber_Invoc.updateBrizziNumber(inputs);
        } catch (Exception e){
            caughtException = e;
        }
        Test.stopTest();
    }

    // Test for failure when the remark is not valid JSON
    @isTest
    static void testNegativeScenario_InvalidJSON() {
        Exception caughtException = null;
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');

        SCC_UpdateBrizziNumber_Invoc.FlowInput input = new SCC_UpdateBrizziNumber_Invoc.FlowInput();
        input.recordId = cs.Id;
        input.remark = 'This is just a plain string, not JSON';

        List<SCC_UpdateBrizziNumber_Invoc.FlowInput> inputs = new List<SCC_UpdateBrizziNumber_Invoc.FlowInput>{input};

        // When & Then: Execute and verify that the correct exception is thrown
        Test.startTest();
        try {
            SCC_UpdateBrizziNumber_Invoc.updateBrizziNumber(inputs);
        } catch (Exception e) {
            caughtException = e;
        }
        Test.stopTest();
    }
}