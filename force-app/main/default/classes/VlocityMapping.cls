/** @description VlocityMapping  hanya run menggunakan global class */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')

global without sharing class VlocityMapping implements callable{
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
        Map<String, InsurancePolicy> mappolicy = new Map<String, InsurancePolicy>();
        List<Object> lcoverages = inputMap.containsKey('coverages')? (List<Object>) inputMap.get('coverages') : new List<Object>() ;
        List<Object> lasset =  inputMap.containsKey('detail_insured')? (List<Object>) inputMap.get('detail_insured') : new List<Object>() ;
        List<Object> ldocumentclauses = inputMap.containsKey('document_clauses')? (List<Object>) inputMap.get('document_clauses') : new List<Object>() ;
        Object documentPolicy = (Object) inputMap.get('documentPolicy');
        Object businessrequest = (Object) inputMap.get('business_request');
        Map<String, Object> mapobjsp = documentPolicy!=null ? (Map<String, Object>) documentPolicy : new Map<String, Object>();
        String extid = mapobjsp.containsKey('policy_number') ? (String) mapobjsp.get('policy_number') : '';
        if(String.isNotBlank(extid) && Schema.sObjectType.InsurancePolicy.isAccessible()){
            List<InsurancePolicy> lip = [select id,SourceOpportunityId,NameInsuredId,BUSREQ_ID__c,Aswata_Policy_Number__c,COB__c from InsurancePolicy where Aswata_Policy_Number__c=:extid];
            for(InsurancePolicy ip:lip){
                mappolicy.put(ip.Aswata_Policy_Number__c,ip);
                mappolicy.put(ip.BUSREQ_ID__c,ip);
            }
        }
        mapobj = setmapall(mapobj, getmapobject(inputMap, 'risk', extid));
        mapobj = setmapall(mapobj, getmapobject(inputMap, 'installments', null));
        mapobj = setmapall(mapobj, getmapobject(inputMap, 'business_companies', null));
        mapobj = setmapall(mapobj, getmapobject(inputMap, 'transhipments', null));
        mapobj = setmapall(mapobj, getmapobject(inputMap, 'business_request_qq', null));
        if(ldocumentclauses!=null){
            if(!ldocumentclauses.isEmpty()){
                List<ApexDefinedFlow> lclauseflow = setclause(ldocumentclauses,mappolicy);
                SFAWT05 sfawt = setSFAWT5(lclauseflow, 'document_clauses', extid);
                mapobj.putAll(setmapObjmap(sfawt));
            }
        }
        if(lcoverages!=null){
            if(!lcoverages.isEmpty()){
                lasset = setAssetMatrix(lcoverages, lasset);
                Integer max1 = lcoverages.size() > 20 ? 20 : lcoverages.size();
                SFAWT05 sfawt = setSFAWT5(lcoverages, 'coverages', extid);
                mapobj.putAll(setmapObjmap(sfawt));
            }
        }
        if(lasset!=null){
            if(!lasset.isEmpty()){
                SFAWT05 sfawt = setSFAWT5(lasset, 'detail_insured', extid);
                mapobj.putAll(setmapObjmap(sfawt));
            }
        }
        return mapobj;
    }
    
    /** @description setmapall  @param mapobjall @param mapobj  @return mapobjall */
    public static Map<String,Object> setmapall(Map<String,Object> mapobjall, Map<String,Object> mapobj){
        if(mapobj!=null){
            mapobjall.putAll(mapobj);
        }
        return mapobjall;
    }

    /** @description setAssetMatrix  @param inputMap @param param @param extid @return setmapObjmap */
    public static Map<String,Object> getmapobject(Map<String,Object> inputMap,String param,String extid){
        List<Object> lobj = inputMap.containsKey(param) ? (List<Object>) inputMap.get(param) :new List<Object>() ;
        if(lobj!=null ){
            if(!lobj.isEmpty()){
                SFAWT05 sfawt = setSFAWT5(lobj, param, extid);
                return setmapObjmap(sfawt);
            }
        }
        return null;
    }

    /** @description setAssetMatrix  @param ldocumentclauses @param mappolicy @return lclauseflow */
    public static List<ApexDefinedFlow>  setclause(List<Object> ldocumentclauses, Map<String,InsurancePolicy> mappolicy){
        List<ApexDefinedFlow> lclauseflow = new List<ApexDefinedFlow>();
        Map<String, Object> mapdc = new Map<String, Object>();
        Map<String, Object> mapcl = new Map<String, Object>();
        InsurancePolicy ip = new InsurancePolicy();
        for(InsurancePolicy v : mappolicy.values()){
            ip = v;
        }
        for(Object dc : ldocumentclauses){
            mapdc = (Map<String,Object>) dc;
            mapcl.put(String.valueOf(mapdc.get('clausa_id')),null);
        }
        if(!mapcl.isEmpty()  && Schema.sObjectType.Master_Data__c.isAccessible()){
            List<Master_Data__c> lmd = [select id,Clause_Id__c from Master_Data__c where Clause_Id__c in :mapcl.keySet() and BSN_ID__c=:ip?.COB__c];
            for(Master_Data__c md:lmd){
                mapcl.put(md.Clause_Id__c,md.id);
            }
        }
        for(Object dc : ldocumentclauses){
            mapdc = (Map<String,Object>) dc;
            String clausaid = String.valueOf(mapdc.get('clausa_id'));
            String busreqid = (String) mapdc.get('busreq_id');
            ApexDefinedFlow adf = new ApexDefinedFlow();
            adf.busreqid = busreqid;
            adf.clausaid = clausaid;
            adf.clausedesccl = (String) mapdc.get('clause_desc_cl');
            adf.clausename = (String) mapdc.get('clause_name');
            adf.insurancepolicyid = ip?.Id;
            adf.isadditional = mapdc.get('is_additional') == 'Y' ? true : false;
            adf.ischanged = mapdc.get('is_changed') == 'Y' ? true : false;
            adf.mdclausaid = (String) mapcl.get(clausaid);
            adf.opportunityid = ip?.SourceOpportunityId;
            adf.partitionCode = (String) mapdc.get('partitionCode');
            adf.policynum = ip?.Aswata_Policy_Number__c;
            adf.uniqueid = clausaid+busreqid;
            lclauseflow.add(adf);
        }
        return lclauseflow;
    }

    /** @description setAssetMatrix  @param lcoverages @param lasset @return lasset */
    public static List<Object> setAssetMatrix(List<Object> lcoverages, List<Object> lasset){
        List<Object> listcovid = new List<Object>();
        List<Object> listmd = new List<Object>();
        Map<String,Object> md = new Map<String,Object>();
        Map<String,Object> mapobj1 = new Map<String,Object>();
        Map<String,Object> mapobj2 = new Map<String,Object>();
        Map<String,Object> mapobj3 = new Map<String,Object>();
        Map<String,Object> mapobj4 = new Map<String,Object>();
        Map<String,Object> mapobj5 = new Map<String,Object>();
        Map<String,Object> mapobj6 = new Map<String,Object>();
        Map<String,Object> mapobj7 = new Map<String,Object>();
        Map<String,Object> mapast = new Map<String,Object>();
        Map<String,Object> mac = new Map<String,Object>();
        Map<String,Object> msc = new Map<String,Object>();
        Map<String, SFAWT05AssetCoverages__mdt> mascov = SFAWT05AssetCoverages__mdt.getAll();
        Integer x = 0;
        for(Object obj:lcoverages){
            mapobj1 = (Map<String,Object>) obj;
            mapobj2 = new Map<String,Object>();
            if(mapobj1.containsKey('m_coverage_ref_id')){
                mapobj2.put('listref',mapobj1.get('m_coverage_ref_id'));
                listcovid.add(mapobj2);
            }
        }
        
        if(!listcovid.isEmpty()){
            mapobj3.put('covid',listcovid);
            md = callIP('Get_CoverageAsset', JSON.serialize(mapobj3));
            listmd = (List<Object>) md.get('output') ;
            if(listmd!=null){
                for(Object md1:listmd){
                    mapobj4 = (Map<String,Object>) md1;
                    mapobj5.put((String) mapobj4.get('COVERAGE_REF_ID__c'),mapobj4);
                }
            }
        }
        
        if(!mapobj5.isEmpty()){
            for(Object obj:lcoverages){
                x++;
                String jsobj = JSON.serialize(obj);
                jsobj = jsobj.replace('"busreqId"','"busreq_id"');
                mapast = new Map<String,Object>();
                mapobj7 = (Map<String,Object>) JSON.deserializeUntyped(jsobj);
                String coverageid = String.valueOf(mapobj7.get('m_coverage_ref_id'));
                if(mapobj5.containsKey(coverageid)){
                    mapobj6 = (Map<String,Object>) mapobj5.get(coverageid);
                    mac = (Map<String,Object>) mapobj6.get('Asset_Category__r');
                    msc = (Map<String,Object>) mapobj6.get('Asset_Section__r');
                    for(SFAWT05AssetCoverages__mdt mdt: mascov.values() ){
                        mapast.put(mdt.DeveloperName,mapobj7.get(mdt.coverage__c));
                    }    
                    mapast.put('detail_description',mac.get('Name')+' '+msc.get('Name'));
                    mapast.put('risk_detail_flag',null);
                    mapast.put('risk_detail_id',x);
                    lasset.add(mapast);
                }
            }
        }
        return lasset; 
    }
    /** @description setAssetMatrix  @param sfawt @return mapobj */
    public static Map<String,Object> setmapObjmap(SFAWT05 sfawt){
        Map<String, Object> mapin = new Map<String, Object>();
        Map<String, Object> mapobj = new Map<String, Object>();
        Integer max = sfawt.lobj.size() > 20 ? 20 : sfawt.lobj.size();
        mapin.put('name',sfawt.nameIP);
        mapin.put('varout',sfawt.varout);
        mapin.put('start',0);
        mapin.put('chunk',max);
        mapin.put('recordtypeId', sfawt.rtId);
        mapin.put('externalId',sfawt.externalId);
        mapin.put('listconasw',sfawt.lobj);
        mapobj.put(sfawt.varout,callQueue(mapin,sfawt.mnt));   
        return mapobj;
    }
     /** @description setAssetMatrix  @param lobj @param varout @param extid @return sfawt */
    public static SFAWT05 setSFAWT5(List<Object> lobj, String varout,String extid){
        SFAWT05__mdt sfm = SFAWT05__mdt.getInstance(varout);
        SFAWT05 sfawt = new SFAWT05();
        sfawt.externalId = extid;
        sfawt.lobj = lobj;
        sfawt.mnt = Integer.valueOf(sfm.start__c);
        sfawt.nameIP = sfm.Integration_Procedure__c;
        sfawt.rtId = null;
        if(String.isNotBlank(sfm.RecordType_DeveloperName__c) && String.isNotBlank(sfm.RecordType_Object__c)){
            sfawt.rtId = SOQL_SOBJECT.getRecordTypeIdbyDevName(sfm.RecordType_Object__c, sfm.RecordType_DeveloperName__c);
        }
        sfawt.varout = varout;
        return sfawt;
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
    /** @description RequestAPI */
    public class SFAWT05{
        /** @description RequestAPI */
        public String varout {get;set;}
        /** @description RequestAPI */
        public String nameIP {get;set;}
        /** @description RequestAPI */
        public Id rtId {get;set;} 
        /** @description RequestAPI */
        public String externalId {get;set;} 
        /** @description RequestAPI */
        public Integer mnt {get;set;} 
        /** @description RequestAPI */
        public List<Object> lobj {get;set;}
    }
}