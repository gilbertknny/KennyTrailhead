public without sharing class SCC_AccountDPLKCtrl {
    @AuraEnabled
    public static String inquiryByIdNumber(String idNumber){
        try {
            Map<String, Object> params = new Map<String, Object>();
            params.put('VarIdNumber', idNumber);
            String response = SCC_IntegrationUtility.sendData('Query_DPLK_By_IdNumber', params);
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            return JSON.serializePretty(jsonMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string inquiryByAccountNumber(String accountNumber){
        try {
            Map<String, Object> params = new Map<String, Object>();
            params.put('VarAcctNo', accountNumber);
            String response = SCC_IntegrationUtility.sendData('Query_DPLK_By_AccountNumber', params);
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            return JSON.serializePretty(jsonMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}