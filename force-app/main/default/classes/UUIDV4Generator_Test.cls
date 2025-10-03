@isTest
public with sharing class UUIDV4Generator_Test {
    @isTest
    static void testUUIDV4Generator() {
        List<String> lstr = new List<String>();
        lstr.add('CIF');

        Test.startTest();
            List<String> lret = UUIDV4Generator.generateUUID(lstr);
        Test.stopTest();
        //System.assertNotEquals(null, lret, 'Generated payload should not be null');
    }
}