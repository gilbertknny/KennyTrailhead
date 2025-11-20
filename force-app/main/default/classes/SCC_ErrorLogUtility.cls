/**
 * @description Utility class to capture Integration Logs
 */
public without sharing class SCC_ErrorLogUtility {
    /**
     * @description Method to insert an error log using the wrapper class
     * @param errorLogWrapper SCC_ErrorLogWrapper class instance
     */
    public static void insertErrorLog(SCC_ErrorLogWrapper errorLogWrapper) {
        if (errorLogWrapper == null) {
            throw new IllegalArgumentException('ErrorLogWrapper cannot be null');
        }
        
        // Create a new Error Log SObject
        Error_Log__c errorLog = new Error_Log__c();
        errorLog.put('API_Type__c', errorLogWrapper.apiType);
        errorLog.put('Class_Name__c', errorLogWrapper.className);
        errorLog.put('Endpoint__c', errorLogWrapper.endPoint);
        errorLog.put('Endpoint_Long__c', errorLogWrapper.endPointLong);
        errorLog.put('Error_Cause__c', errorLogWrapper.errorCause);
        errorLog.put('Error_Messages__c', errorLogWrapper.errorMessages);
        errorLog.put('Line_Number__c', errorLogWrapper.lineNumber);
        errorLog.put('Request_Header__c', errorLogWrapper.requestHeader);
        errorLog.put('Request_IP__c', errorLogWrapper.requestIP);
        errorLog.put('Request_IP_Long__c', errorLogWrapper.requestIPLong);
        errorLog.put('Request_Body__c', errorLogWrapper.requestBody);
        errorLog.put('Response_Header__c', errorLogWrapper.responseHeader);
        errorLog.put('Response_Status__c', errorLogWrapper.responseStatus);
        errorLog.put('Response_Status_Code__c', errorLogWrapper.responseStatusCode);
        errorLog.put('Response_Body__c', errorLogWrapper.responseBody);
        errorLog.put('Stack_Trace__c', errorLogWrapper.stackTrace);
        errorLog.put('Error_Datetime__c', errorLogWrapper.errorDatetime);
        errorLog.put('Type_Name__c', errorLogWrapper.typeName);
        errorLog.put('User_Run__c', errorLogWrapper.userRun);
        
        try {
            if(Schema.sObjectType.Error_Log__c.isCreateable()){
                insert errorLog;
            }
        } catch (DmlException e) {
            throw e;
        }
    }
}