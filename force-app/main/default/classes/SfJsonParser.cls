public with sharing class SfJsonParser {

    @InvocableMethod (label = 'parseJSONtoDocumentBFI' description = 'Convert JSON String to Object')
    public static List<List<Document_BFI__c>> parseJSONtoDocumentBFI(List<String> strJson){
        List<List<Document_BFI__c>> retval = new List<List<Document_BFI__c>>();
            List<Document_BFI__c> documentList = (List<Document_BFI__c>) JSON.deserialize(strJson[0], List<Document_BFI__c>.class);
            retval.add(documentList);
        return retval;
    }

    /*
    public static void test() {
        String jsonString = '[{"Name": "aaabbb", "DMS_Doc_Id__c": "db579eaf", "Document_Type_Lookup__c": "COURTRULINGADOPTION"}, {"Name": "bbbccc", "DMS_Doc_Id__c": "db579eaf", "Document_Type_Lookup__c": "POWEROFATTORNEYABROAD"}]';
        
        List<String> lstJson = new List<String> ();
            lstJson.add(jsonString);
        List<List<Document_BFI__c>> tmp = parseJSONtoDocumentBFI(lstJson);

        List<Document_BFI__c> documents = tmp[0];
        for (Document_BFI__c doc : documents) {
            System.debug('Name: ' + doc.Name);
            System.debug('DMS_Doc_Id__c: ' + doc.DMS_Doc_Id__c);
            System.debug('Document_Type_Lookup__c: ' + doc.Document_Type_Lookup__c);
        }
    }
    */

}