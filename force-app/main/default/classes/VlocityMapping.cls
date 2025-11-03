/** @description VlocityMapping  hanya run menggunakan global class */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class VlocityMapping implements callable{
    /** @description VlocityMapping
     *
     *
    public VlocityMapping() {

    }
    */

    /** @description VlocityMapping  @param ipname @param jsonInput @return map */
    public static Map<String,Object> callIP(String ipname,String jsonInput){
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        input = (Map<String, Object>) JSON.deserializeUntyped(jsonInput);
        output = (Map<String,Object>) omnistudio.IntegrationProcedureService.runIntegrationService(ipname,input,options);
        return output;
    }
    /** @description VlocityMapping @param action @param args @return object */
    public Object call(String action, Map<String, Object> args){
        VlocityParam vp = new VlocityParam();
        vp.methodName = action;
        vp.inputMap = (Map<String, Object>)args.get('input');
        vp.outMap = (Map<String, Object>)args.get('output');
        vp.options = (Map<String, Object>)args.get('options');
        return invokeMethod(vp);
    }
    /** @description VlocityMapping  @param vp @return boolean */
    public Boolean invokeMethod(VlocityParam vp) {
        Boolean result = true;
        String meta;
        String metafile;
        String token;
        String name;
        String varout;
        String externalId;
        String recordtypeId;
        Object body;
        Id recordId;
        List<Object> listconsf ;
        List<Object> listconasw;
        String methodName = vp.methodName;
        Map<String, Object> inputMap = vp.inputMap;
        Map<String, Object> outMap = vp.outMap;
        Map<String, Object> options = vp.options;
        Map<String, Object> mapobj = new Map<String, Object>();

        try{
            if(methodName.equals('APICall')){
                meta = (String) inputMap.get('meta') ;
                body = (Object) inputMap.get('body') ;
                token = (String) inputMap.get('token') ;
                RequestAPI reqapi = new RequestAPI();
                reqapi.meta = meta;
                reqapi.body = body;
                reqapi.token = token;
                outMap.put(meta, callAPI(reqapi));
            }
            else if(methodName.equals('Permission')){
                name = (String) inputMap.get('name') ;
                Boolean hasPermission = FeatureManagement.checkPermission(name);
                outMap.put(name, hasPermission);
            }
            else if(methodName.equals('Session')){
                outMap.put('SessionID', userinfo.getSessionID());
            }
            else if(methodName.equals('APIUploadFile')){
                meta = (String) inputMap.get('meta') ;
                metafile = (String) inputMap.get('metafile') ;
                token = (String) inputMap.get('token') ;
                recordId = (Id) inputMap.get('recordId') ;
                externalId = (String) String.valueOf(inputMap.get('externalId')) ;
                RequestAPI reqapi = new RequestAPI();
                reqapi.meta = meta;
                reqapi.metafile = metafile;
                reqapi.token = token;
                reqapi.recordId = recordId;
                reqapi.externalId = externalId;
                outMap.put(meta, setupFileUpload(reqapi));
            }
            else if(methodName.equals('MappingContact')){
                listconsf = (List<Object>) inputMap.get('listconsf') ;
                listconasw = (List<Object>) inputMap.get('listconasw') ;
                outMap.put('Contacts', setupContactMaping(listconsf,listconasw));
            }
            else if(methodName.equals('callFlow')){
                name = (String) inputMap.get('name');
                varout = (String) inputMap.get('varout');
                body = (Object) inputMap.get('body');
                mapobj = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(body));
                outMap.put(varout, callFlow(name,mapobj,varout));
            }
            else if(methodName.equals('queueableIP')){
                outMap.put('jobId', callQueue(inputMap,0));
            }
            else if(methodName.equals('SFAWT05')){
                outMap.put('jobId', sfawt05Extend(inputMap));
            }
        }
        catch(Exception exc){
            ErrorLogRecord.DebugLog dl = ErrorLogRecord.setError(null, 'VlocityMapping', exc);
            ErrorLogRecord.seteventerror(JSON.serialize(dl));
            result = false;
        }
        return result;
    }
    /** @description VlocityMapping  @param inputMap @return mapjobid */
    public static Map<String,Object> sfawt05Extend(Map<String, Object> inputMap){
        Map<String, Object> mapobj = new Map<String, Object>();
        Map<String, Object> mapobjcv = new Map<String, Object>();
        Map<String, Object> mapobjas = new Map<String, Object>();
        Map<String, Object> mapobjrs = new Map<String, Object>();
        Map<String, Object> mapobjin = new Map<String, Object>();
        Map<String, Object> mapobjbc = new Map<String, Object>();
        Map<String, Object> mapobjqq = new Map<String, Object>();
        Map<String, Object> mapobjcl = new Map<String, Object>();
        Map<String, Object> mapobjsp = new Map<String, Object>();
        List<Object> lrisk = (List<Object>) inputMap.get('risk') ;
        List<Object> lcoverages = (List<Object>) inputMap.get('coverages') ;
        List<Object> lasset = (List<Object>) inputMap.get('detail_insured') ;
        List<Object> linstallments = (List<Object>) inputMap.get('installments') ;
        List<Object> lbusinesscompanies = (List<Object>) inputMap.get('business_companies') ;
        List<Object> lbusinessqq = (List<Object>) inputMap.get('business_request_qq');
        List<Object> ldocumentclauses = (List<Object>) inputMap.get('document_clauses') ;
        Object documentPolicy = (Object) inputMap.get('documentPolicy');
        Boolean r = false;

        //Risk
        if(!lrisk.isEmpty()){
            Integer max3 = lrisk.size() > 20 ? 20 : lrisk.size();
            mapobjrs.put('name','SFAWT05Extend_RiskAssetCoverage');
            mapobjrs.put('varout','risk');
            mapobjrs.put('start',0);
            mapobjrs.put('chunk',max3);
            mapobjrs.put('recordtypeId', SOQL_SOBJECT.getRecordTypeIdbyDevName('Asset', 'Risk'));
            mapobjrs.put('externalId','');
            mapobjrs.put('listconasw',lrisk);
            mapobj.put('risk',callQueue(mapobjrs,0));
            r = true;
        }
        //Installment
        if(!linstallments.isEmpty()){
            Integer max4 = linstallments.size() > 20 ? 20 : linstallments.size();
            mapobjin.put('name','SFAWT05Extend_Transaction');
            mapobjin.put('varout','installments');
            mapobjin.put('start',0);
            mapobjin.put('chunk',max4);
            mapobjin.put('recordtypeId', SOQL_SOBJECT.getRecordTypeIdbyDevName('Transaction_Data__c', 'Installment'));
            mapobjin.put('externalId','');
            mapobjin.put('listconasw',linstallments);
            mapobj.put('installments',callQueue(mapobjin,0));
        }
        //Installment
        if(!lbusinesscompanies.isEmpty()){
            Integer max5 = lbusinesscompanies.size() > 20 ? 20 : lbusinesscompanies.size();
            mapobjbc.put('name','SFAWT05Extend_Transaction');
            mapobjbc.put('varout','business_companies');
            mapobjbc.put('start',0);
            mapobjbc.put('chunk',max5);
            mapobjbc.put('recordtypeId', SOQL_SOBJECT.getRecordTypeIdbyDevName('Transaction_Data__c', 'CoInsurer'));
            mapobjbc.put('externalId','');
            mapobjbc.put('listconasw',lbusinesscompanies);
            mapobj.put('business_companies',callQueue(mapobjbc,0));
        }
        //QQ
        if(!lbusinessqq.isEmpty()){
            Integer max6 = lbusinessqq.size() > 20 ? 20 : lbusinessqq.size();
            mapobjqq.put('name','SFAWT05Extend_Transaction');
            mapobjqq.put('varout','business_request_qq');
            mapobjqq.put('start',0);
            mapobjqq.put('chunk',max6);
            mapobjqq.put('recordtypeId', SOQL_SOBJECT.getRecordTypeIdbyDevName('Transaction_Data__c', 'Member_of_QQ'));
            mapobjqq.put('externalId','');
            mapobjqq.put('listconasw',lbusinessqq);
            mapobj.put('business_request_qq',callQueue(mapobjqq,0));
        }
        //Clausas
        if(!ldocumentclauses.isEmpty()){
            Integer max7 = ldocumentclauses.size() > 20 ? 20 : ldocumentclauses.size();
            mapobjcl.put('name','SFAWT05Extend_Transaction');
            mapobjcl.put('varout','document_clauses');
            mapobjcl.put('start',0);
            mapobjcl.put('chunk',max7);
            mapobjcl.put('recordtypeId', SOQL_SOBJECT.getRecordTypeIdbyDevName('Transaction_Data__c', 'Clause'));
            mapobjcl.put('externalId','');
            mapobjcl.put('listconasw',ldocumentclauses);
            mapobj.put('document_clauses',callQueue(mapobjcl,0));
        }

        //InsurancePolicyCoverage
        if(!lcoverages.isEmpty() && r == true){
            Integer max1 = lcoverages.size() > 20 ? 20 : lcoverages.size();
            mapobjsp = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(documentPolicy));
            mapobjcv.put('name','SFAWT05Extend_RiskAssetCoverage');
            mapobjcv.put('varout','coverages');
            mapobjcv.put('start',0);
            mapobjcv.put('chunk', max1);
            mapobjcv.put('recordtypeId', null);
            if(mapobjsp.containsKey('policy_number')){
                mapobjcv.put('externalId', (String) mapobjsp.get('policy_number'));
            }
            mapobjcv.put('listconasw',lcoverages);
            mapobj.put('coverages',callQueue(mapobjcv,1));
        }
        //Asset
        if(!lasset.isEmpty() && r == true){
            Integer max2 = lasset.size() > 20 ? 20 : lasset.size();
            mapobjas.put('name','SFAWT05Extend_RiskAssetCoverage');
            mapobjas.put('varout','detail_insured');
            mapobjas.put('start',0);
            mapobjas.put('chunk',max2);
            mapobjas.put('recordtypeId', SOQL_SOBJECT.getRecordTypeIdbyDevName('Asset', 'Asset'));
            mapobjas.put('externalId','');
            mapobjas.put('listconasw',lasset);
            mapobj.put('detail_insured',callQueue(mapobjas,1));
        }
        return mapobj;
    }
    
    /** @description VlocityMapping  @param inputMap @param mnt @return jobid */
    public static Id callQueue(Map<String, Object> inputMap,Integer mnt){
        Map<Integer, Object> mapq = new Map<Integer, Object>();
        String name = (String) inputMap.get('name');
        String varout = (String) inputMap.get('varout');
        Integer start = (Integer) inputMap.get('start');
        Integer chunk = (Integer) inputMap.get('chunk');
        String recordtypeId = (String) inputMap.get('recordtypeId');
        String externalId = (String) inputMap.get('externalId');
        List<Object> listconasw = (List<Object>) inputMap.get('listconasw') ;
        Integer i  = 0;
        for(Object obj:listconasw){
            mapq.put(i, obj);
            i++;
        }
        SFAWT05Queueable.Queueableparam qp = new SFAWT05Queueable.Queueableparam();
        qp.chunk = chunk;
        qp.ipname = name;
        qp.mapobj = mapq;
        qp.externalId = externalId;
        qp.recordtypeId = recordtypeId;
        qp.start = start;
        qp.varout = varout;
        ID jobID = System.enqueueJob(new SFAWT05Queueable(qp), mnt);
        return jobID;
    }
    /** @description VlocityMapping  @param flowName @param inputs @param varout @return val */
    public static Map<String,Object> callFlow(String flowName, Map <String, Object> inputs,String varout) {
        Map<String,Object> mapout = new Map<String, Object>();
        Flow.Interview myFlow = Flow.Interview.createInterview(flowName, inputs);
        myFlow.start();
        if(myFlow.getVariableValue(varout) != null){
            mapout = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(myFlow.getVariableValue(varout)));
        }
        return mapout;
    }

    /** @description VlocityMapping  @param reqapi @return map */
    public  Map<String,Object> callAPI(RequestAPI reqapi){
        APILog.WrapperRequest wr = new APILog.WrapperRequest();
        wr.bodyreq = JSON.serialize(reqapi.body);
        wr.clsName = 'VlocityMapping';
        wr.metaname = reqapi.meta;
        wr.token = reqapi.token;
        APILog.WrapperAPI wapi = APILog.getResponseAPI(wr);
        Map<String,Object> mapres = (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody()) ;
        return mapres;
    }
    /** @description VlocityMapping  @param reqapi @return map */
    public Map<String,Object> setupFileUpload(RequestAPI reqapi){
        Map<String,Object> mapres = new Map<String,Object>();
        String query = 'select ContentDocumentId from ContentDocumentLink where LinkedEntityId = '+'\''+reqapi.recordId+'\'';
        if(!system.isBatch()){
            Database.executeBatch(new BatchFileSFAWT6(query,reqapi), 1);
            mapres.put('Batch','BatchFileSFAWT6');
        }
        else{
            mapres.put('Schedule','');
        }
        return mapres;
    }
    /** @description VlocityMapping  @param listconsf  @param listconasw @return map */
    public Map<String,Object> setupContactMaping(List<Object> listconsf, List<Object> listconasw){
        Map<String,Id> mapconsf = new Map<String,Id>();
        Map<String,Contact> mapconupdt = new Map<String,Contact>();
        Map<String,Object> mapconupdt2 = new Map<String,Object>();
        for(Object c:listconsf){
            String jsonStr = JSON.serialize(c);
            Map<String,Object> mapcon = (Map<String,Object>) JSON.deserializeUntyped(jsonStr);
            String cpid = (String) mapcon.get('Contact_Person_ID__c');
            String lastname = (String) mapcon.get('Lastname');
            String cid = (String) mapcon.get('SFID');
            if(String.isNotBlank(cpid)){
                mapconsf.put(cpid, cid);
            }
            else{
                mapconsf.put(lastname, cid);
            }
        }
        for(Object c:listconasw){
            String jsonStr = JSON.serialize(c);
            Map<String,Object> mapcon = (Map<String,Object>) JSON.deserializeUntyped(jsonStr);
            String cpid = (String) String.valueOf(mapcon.get('Contact_Person_ID__c'));
            String lastname = (String) mapcon.get('Lastname');
            Id conid;
            if(mapconsf.containsKey(cpid)){
                conid = mapconsf.get(cpid);
            }
            else{
                conid = mapconsf.get(lastname);
            }
            mapconupdt.put(conid,new Contact(id = conid,Contact_Person_ID__c = cpid));
            mapconupdt2.put(conid, new Contact(id = conid,Contact_Person_ID__c = cpid));

        }
        if(!mapconupdt.isEmpty()){
            Update mapconupdt.values();
        }
        return mapconupdt2;
    }
    /** @description RequestAPI */
    public class RequestAPI{
        /** @description RequestAPI */
        public String meta {get;set;}
        /** @description RequestAPI */
        public String metafile {get;set;}
        /** @description RequestAPI */
        public String token {get;set;}
        /** @description RequestAPI */
        public Object body {get;set;}
        /** @description RequestAPI */
        public Id recordId {get;set;}
        /** @description RequestAPI */
        public String externalId {get;set;}
    }

    /** @description RequestAPI */
    public class VlocityParam{
        /** @description RequestAPI */
        public String methodName {get;set;}
        /** @description RequestAPI */
        public Map<String,Object> inputMap {get;set;}
        /** @description RequestAPI */
        public Map<String,Object> outMap {get;set;}
        /** @description RequestAPI */
        public Map < String, Object > options {get;set;}
    }
}