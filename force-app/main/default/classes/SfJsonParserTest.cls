@isTest
public with sharing class SfJsonParserTest {
    @isTest
    static void testParseJSONtoDocumentBFI() {
        String jsonString = '[{"Name": "test1", "DMS_Doc_Id__c": "12345", "Document_Type_Lookup__c": "TYPE1"}, {"Name": "test2", "DMS_Doc_Id__c": "67890", "Document_Type_Lookup__c": "TYPE2"}]';
        
        List<String> lstJson = new List<String>();
        lstJson.add(jsonString);
        
        Test.startTest();
        List<List<Document_BFI__c>> result = SfJsonParser.parseJSONtoDocumentBFI(lstJson);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(2, result[0].size());
        System.assertEquals('test1', result[0][0].Name);
        System.assertEquals('12345', result[0][0].DMS_Doc_Id__c);
        System.assertEquals('TYPE1', result[0][0].Document_Type_Lookup__c);
        
        System.assertEquals('test2', result[0][1].Name);
        System.assertEquals('67890', result[0][1].DMS_Doc_Id__c);
        System.assertEquals('TYPE2', result[0][1].Document_Type_Lookup__c);
    }
}