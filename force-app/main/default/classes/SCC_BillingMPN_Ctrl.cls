/**  
 * @description       : Controller for MPN Billing  
 * @last modified on  : 23-01-2025, 03-03-2025
 * @last modified by  : Ardyta Yudianto, Herbing
 */  
public with sharing class SCC_BillingMPN_Ctrl {  

    // Constants defined at class level
    private static final String NOMOR_PEMBAYARAN_KEY = 'Nomor Pembayaran';

    @AuraEnabled(cacheable=true)  
    public static SCC_BillingMPN_Wrapper.BillingMPN_Response searchBillingMPN( String idSetoran, String transactionCurrencyCode, Id csId) {  
        // Create a new request object
        SCC_BillingMPN_Wrapper.BillingMPN_Request req = new SCC_BillingMPN_Wrapper.BillingMPN_Request();
        req.transactionCurrencyCode = transactionCurrencyCode;
        req.idSetoran = idSetoran;
        String menu = 'Case - Bricare';
        String recid = String.valueOf(csId);
        SCC_BillingMPN_Wrapper.BillingMPN_Response res = new SCC_BillingMPN_Wrapper.BillingMPN_Response();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
            res = Object_Test_MPN.billingMPNResponse();
        } 
        else{
            String mtd = SCC_Endpoint_API__mdt.getInstance('Billing_MPN').MasterLabel;
            res = SCC_BillingMPN_API.searchBillingMPN(req,mtd,menu,recid);
        }
        return res;
    }

    public static void updateBillingNumber (Id caseId){
        Case cs = [SELECT Id, scc_Billing_Number__c, SCC_Notes__c FROM Case WHERE Id = :caseId LIMIT 1];

        // Extract Brizzi number from remark
        String billingNumber = extractBillingNumber(cs.SCC_Notes__c);
        
        if (String.isBlank(billingNumber)) {
            throw new AuraHandledException('Unable to extract valid Billing number from note Billing MPN');
        }
        
        cs.scc_Billing_Number__c = billingNumber;
        update cs;
    }

    @AuraEnabled  
    public static void updateCaseMPNId(Id caseId, String mpnId, String billingNumber) {  
        try {  
            Case caseToUpdate = [SELECT Id, MPN_ID__c, scc_Billing_Number__c FROM Case WHERE Id = :caseId LIMIT 1];  
            if (caseToUpdate != null) {  
                caseToUpdate.MPN_ID__c = mpnId;  
                caseToUpdate.scc_Billing_Number__c = billingNumber;  
                update caseToUpdate;  
            }  
        } catch (Exception e) {  
            throw new AuraHandledException('Error updating Case MPN ID: ' + e.getMessage());  
        }  
    }
    
    // Helper method to extract Brizzi number from remark
    private static String extractBillingNumber(String remark) {
        try {
            // Clean up the input to remove unnecessary characters (carriage returns, newlines)
            String sanitizedRemark = remark.replace('\r', '').replace('\n', '').trim();
    
            // Parse the cleaned JSON string
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(sanitizedRemark);
            
            // Get the Nomor Pembayaran value directly from the parsed JSON
            String nomorPembayaran = (String) jsonData.get(NOMOR_PEMBAYARAN_KEY);
            
            if (String.isNotBlank(nomorPembayaran)) {
                return nomorPembayaran;
            }
    
            return null;
    
        } catch (Exception e) {
            // If JSON parsing fails, return null
            return null;
        }
    }
}