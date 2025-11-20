trigger EventErrorLog on Error_Logs__e (after insert) {
    for(Error_Logs__e dls:trigger.new){
        Error_Log__c el = new Error_Log__c(
                            Class_Name__c=dls.Class_Flow_Name__c,
                            user_run__c=dls.user_run__c,
                            Error_Cause__c=dls.Error_Cause__c,
                            Error_Messages__c=dls.Error_Messages__c,
                            Line_Number__c=dls.Line_Number__c,
                            Stack_Trace__c=dls.Stack_Trace__c,
                            Type_Name__c=dls.Type_Name__c,
                            request_header__c=dls.request_header__c,
                            request_body__c=dls.request_body__c,
                            request_ip__c=dls.request_ip__c,
                            Request_IP_Long__c=dls.Request_IP_Long__c,
                            endpoint__c=dls.endpoint__c,
                            Endpoint_Long__c=dls.Endpoint_Long__c,
                            Response_Header__c=dls.Response_Header__c,
                            Response_Status__c=dls.Response_Status__c,
                            Response_Status_Code__c=dls.Response_Status_Code__c,
                            Response_Body__c=dls.Response_Body__c,
                            API_Type__c=dls.API_Type__c,
                            Menu__c	 = dls.Menu__c,
                            RelatedId__c = dls.RelatedId__c,
                            Object_Name__c = dls.Object_Name__c,
                            Source__c = dls.Source__c,
                            Destination__c = dls.Destination__c);
        system.debug('error log : '+el);
        insert el;
    }
}