public with sharing class SCC_InquiryBriva {
    
    @future(callout=true)
    public static void inquiryBriva(String brivaNo, String recordId){

        SCC_BrivaWrapper.requestBrivaWrapper reqBriva = new SCC_BrivaWrapper.requestBrivaWrapper();
        SCC_BrivaWrapper.bodyBriva bodyBriva = new SCC_BrivaWrapper.bodyBriva();

        bodyBriva.brivaNo = brivaNo;
        bodyBriva.channelId = 'CHMS';
        bodyBriva.externalId = '124123137';
        bodyBriva.serviceId = '100CB';

        reqBriva.request = bodyBriva;

        String bodyReq = JSON.serialize(reqBriva,true);
        String menu = 'Case - BRICare';
        String objectName = 'Case';
        String metaname = 'Briva';
        String className = 'SCC_InquiryBriva';
        String token = '';
        String recId = '';

        SCC_API.WrapperRequest wrapReq = new SCC_API.WrapperRequest();
        wrapReq.bodyreq = bodyReq;
        wrapReq.clsName = className;
        wrapReq.menu = menu;
        wrapReq.metaname = metaname;
        wrapReq.objnm = objectName;
        wrapReq.recid = recId;
        wrapReq.token = token;

        //SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wrapReq);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI(metaname, bodyreq, token, classname);
        System.debug('api request before map' + wapi.req.getBody());
        System.debug('api response before map' + wapi.res.getBody());
        SCC_BrivaWrapper.responseBrivaCustom res = new SCC_BrivaWrapper.responseBrivaCustom();

        try{
            Map<String,Object> mapres = (Map<String,Object>) JSON.deserializeUntyped(wapi.res.getBody());
            //kalo error disini
            Map<String,Object> responseMap = (Map<String,Object>) mapres.get('response');
            Map<String, Object> responseData  =  (Map<String, Object>) responseMap.get('data');
            String errorCode = (String) responseData.get('errorCode');
            String corpAccounNumber = (String) responseData.get('corpAccountNo');
            String responseCode = (String) responseMap.get('responseCode');
            String responseMessage = (String) responseMap.get('responseMessage');

            System.debug('response data' + responseData);
            System.debug('error code '+ errorCode);
            System.debug('account number' + corpAccounNumber);
            System.debug('response code ' + responseCode);
            System.debug(' response message' + responseMessage);
            
            // SCC_BrivaWrapper.responseBriva resBriva = getbrivaResponse(responseMap);

            if(responseCode == '00' && responseMessage == 'Success'){
                System.debug('akan update');

                System.debug('record id' + recordId);


                Case caseToUpdate = [SELECT Id, SCC_Account_Number__c 
                    FROM Case 
                    WHERE Id = :recordId 
                    LIMIT 1];

                if (caseToUpdate != null) {
                    System.debug(caseToUpdate);
                    caseToUpdate.SCC_Account_Number__c = corpAccounNumber;
                    
                    System.debug('Case to update ID: ' + caseToUpdate.Id);
                    update caseToUpdate;
                }

            } else {
                res.errorCode = errorCode;
                res.responseCode = responseCode;
                res.responseMessage = responseMessage;
                res.corpAccountNo = '';
            }

        }
        catch(exception exc){
            SCC_API.insertErrorLog(exc, wapi.req, wapi.res, new SCC_API.WrapperError(wapi.urlCurrent,'SCC_InquiryBriva'));
        }

    }


    @AuraEnabled
    public static SCC_BrivaWrapper.responseBrivaCustom inquiryBrivaUI(String brivaNo){

        SCC_BrivaWrapper.requestBrivaWrapper reqBriva = new SCC_BrivaWrapper.requestBrivaWrapper();
        SCC_BrivaWrapper.bodyBriva bodyBriva = new SCC_BrivaWrapper.bodyBriva();
        BRIMO__c br = BRIMO__c.getinstance('extId Briva');
        Integer extIdBriva = Integer.valueOf(br.request_refnum__c);
        String externalId = SCC_Brimo.setreffnum(extIdBriva);


        bodyBriva.brivaNo = brivaNo;
        bodyBriva.channelId = 'CHMS';
        bodyBriva.externalId = externalId;
        bodyBriva.serviceId = '100CB';

        reqBriva.request = bodyBriva;

        String bodyReq = JSON.serialize(reqBriva,true);
        String menu = 'Case - BRICare';
        String objectName = 'Case';
        String metaname = 'Briva';
        String className = 'SCC_InquiryBriva';
        String token = '';
        String recId = '';

        SCC_API.WrapperRequest wrapReq = new SCC_API.WrapperRequest();
        wrapReq.bodyreq = bodyReq;
        wrapReq.clsName = className;
        wrapReq.menu = menu;
        wrapReq.metaname = metaname;
        wrapReq.objnm = objectName;
        wrapReq.recid = recId;
        wrapReq.token = token;

        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI(metaname, bodyreq, token, classname);
        System.debug('api request before map' + wapi.req.getBody());
        System.debug('api response before map' + wapi.res.getBody());
        SCC_BrivaWrapper.responseBrivaCustom res = new SCC_BrivaWrapper.responseBrivaCustom();


        try{
            br.request_refnum__c = decimal.valueOf(bodyBriva.externalId);
            update br;
            
            Map<String,Object> mapres = (Map<String,Object>) JSON.deserializeUntyped(wapi.res.getBody());
            //kalo error disini
            Map<String,Object> responseMap = (Map<String,Object>) mapres.get('response');

            
            String errorCode = (String) responseMap.get('errorCode');
            String responseCode = (String) responseMap.get('responseCode');
            String responseMessage = (String) responseMap.get('responseMessage');
            Map<String, Object> responseData  =  (Map<String, Object>) responseMap.get('data');
            // String specialSegment = (String) responseData.get('specialSegment');
            // String corpAccounNumber = (String) responseData.get('corpAccountNo');

            String jsonBodyData = JSON.serialize(responseData);
            SCC_BrivaWrapper.dataBriva brivaObj = (SCC_BrivaWrapper.dataBriva) JSON.deserialize(jsonBodyData, SCC_BrivaWrapper.dataBriva.class);
            res.corpAccountNo = brivaObj.corpAccountNo;
            res.errorCode = errorCode;
            res.responseCode = responseCode;
            res.responseMessage = responseMessage;
            res.corpName = brivaObj.corpName;
            res.specialSegment = brivaObj.specialSegment;

            if(brivaObj.specialSegment == 'Y'){
                res.brivaco = brivaObj.brivaco;
            }
            
            

        }
        catch(Exception exc){
            SCC_API.insertErrorLog(exc, wapi.req, wapi.res, new SCC_API.WrapperError(wapi.urlCurrent,'SCC_InquiryBriva'));
            res.responseMessage = 'Error: ' + exc.getMessage();
        }

        return res;

    }

    @AuraEnabled
    public static Map<String, Object> updateCaseAccountNumber(Id recordId, String corpAccountNumber) {
        Map<String, Object> response = new Map<String, Object>();
        
        try {
            Case caseToUpdate = [SELECT Id, SCC_Account_Number__c 
                                FROM Case 
                                WHERE Id = :recordId 
                                LIMIT 1];
            
            if (caseToUpdate != null) {
                System.debug('Previous account number: ' + caseToUpdate.SCC_Account_Number__c);
                caseToUpdate.SCC_Account_Number__c = corpAccountNumber;
                System.debug('New account number: ' + corpAccountNumber);
                System.debug('Case to update ID: ' + caseToUpdate.Id);
                
                update caseToUpdate;
                System.debug('Case updated successfully');
                
                response.put('success', true);
                response.put('message', 'Case updated successfully');
            }
            
        } catch (Exception e) {
            System.debug('Error updating case: ' + e.getMessage());
            response.put('success', false);
            response.put('message', 'Error updating case: ' + e.getMessage());
            throw new AuraHandledException('Error updating case: ' + e.getMessage());
        }
        
        return response;
    }

    @AuraEnabled
    public static SCC_BrivaWrapper.ReportBrivaResponse getReportBriva(SCC_BrivaWrapper.ReportBrivaRequest reqReportBriva, String menu , String recid){
        SCC_BrivaWrapper.ReportBrivaResponse res = new SCC_BrivaWrapper.ReportBrivaResponse();
        SCC_API.WrapperRequest wrapperRequest = setWrapperRequest(JSON.serialize(reqReportBriva,true), '', 'ReportBriva', 'SCC_InquiryBriva', recid, menu);
        SCC_API.WrapperError wrapperError = SCC_CaseResoultion_DataHub.setWrapperError(wrapperRequest);
        //SCC_API.WrapperAPI wrapperApi = SCC_API.getResponseAPIUI(wrapperRequest);
        SCC_API.WrapperAPI wrapperApi = SCC_API.getResponseAPI('ReportBriva',JSON.serialize(reqReportBriva,true) , '', 'SCC_InquiryBriva');
        try{
           Map<String,Object> jsonMap = (Map<String,Object>) JSON.deserializeUntyped(wrapperApi.res.getBody());
           String errorCode = (String) jsonMap.get('errorCode');
           Integer statusCode = (Integer) jsonMap.get('statusCode');
           String errors = (String) jsonMap.get('errors');
           System.debug('Response Report Briva : ' + wrapperApi.res.getBody());
           System.debug('Error Code : ' + errorCode);
           System.debug('Status code :' + statusCode);
           System.debug('Errors :' + errors);

            if(statusCode == 200 && errors == null){
                res = (SCC_BrivaWrapper.ReportBrivaResponse) JSON.deserialize(wrapperApi.res.getBody(), SCC_BrivaWrapper.ReportBrivaResponse.class);
            }else {
                res.responseCode = (String)jsonMap.get('responseCode');
                res.responseMessage = (String)jsonMap.get('responseMessage');
            }

        }
        catch(exception exc){
            SCC_API.insertErrorLog(exc, wrapperApi.req, wrapperApi.res, wrapperError);
        }

        return res;
    }

    public static SCC_API.WrapperRequest setWrapperRequest(String bodyReq , String token , String metaname , String clsName , String recid , String menu){
        SCC_API.WrapperRequest wq = new SCC_API.WrapperRequest();
        wq.bodyreq = bodyReq;
        wq.clsName = clsName;
        wq.menu = menu;
        wq.token = token;
        wq.metaname = metaname;
        wq.recid = recid;
        if(String.isNotBlank(recid)){
            Id idsf = id.valueOf(recid);
            wq.objnm =  idsf.getSObjectType().getDescribe().getName();
        }

        return wq;
    }
}