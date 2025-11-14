/**
 * @description EventErrorLogHandler
 */
public without sharing class EventErrorLogHandler {
    /**
     * @description handleAfterInsert
     * @param newEvents
     */
    public static void handleAfterInsert(List<Error_Logs__e> newEvents) {
        List<Error_Log__c> logsToInsert = new List<Error_Log__c>();
        
        for (Error_Logs__e dls : newEvents) {
            Error_Log__c el = new Error_Log__c(
                Class_Name__c          = dls.Class_Flow_Name__c,
                User_run__c            = dls.User_run__c,
                API_Type__c            = dls.API_Type__c,
                RelatedId__c           = dls.RelatedId__c,
                Object_Name__c         = dls.Object_Name__c,
                Error_Cause__c         = dls.Error_Cause__c,
                Error_Messages__c      = dls.Error_Messages__c,
                Line_Number__c         = dls.Line_Number__c,
                Stack_Trace__c         = dls.Stack_Trace__c,
                Type_Name__c           = dls.Type_Name__c,
                Request_header__c      = dls.Request_header__c,
                Request_body__c        = dls.Request_body__c,
                Request_IP__c          = dls.Request_IP__c,
                Endpoint__c            = dls.Endpoint__c,
                Response_Header__c     = dls.Response_Header__c,
                Response_Status__c     = dls.Response_Status__c,
                Response_Status_Code__c= dls.Response_Status_Code__c,
                Response_Body__c       = dls.Response_Body__c,
                String_To_Sign__c      = dls.String_To_Sign__c
            );
            logsToInsert.add(el);
        }
        
        if (!logsToInsert.isEmpty() && Schema.sObjectType.Error_Log__c.isCreateable()) {
            Database.insert(logsToInsert, false);
        }
    }
}