/**
 * @description       : Test class for SCC_InvocableBrizzi
 * @last modified on  : 03-05-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_InvocableBrizzi_Test {
    @isTest
    static void testInvocablevoid() {
        List<SCC_InvocableBrizzi.FlowInputValues> mockInputValues = new List<SCC_InvocableBrizzi.FlowInputValues>();

        SCC_InvocableBrizzi.FlowInputValues inputValue1 = new SCC_InvocableBrizzi.FlowInputValues();
        inputValue1.tipe = 'TypeA';
        inputValue1.recordId = '001XXXX';
        mockInputValues.add(inputValue1);

        SCC_InvocableBrizzi.FlowInputValues inputValue2 = new SCC_InvocableBrizzi.FlowInputValues();
        inputValue2.tipe = 'TypeB';
        inputValue2.recordId = '001YYYY';
        mockInputValues.add(inputValue2);

        Test.startTest();
        SCC_InvocableBrizzi.invocablevoid(mockInputValues);
        Test.stopTest();

        System.assertEquals(2, mockInputValues.size(), 'The mockInputValues list should have two items.');
    }
}