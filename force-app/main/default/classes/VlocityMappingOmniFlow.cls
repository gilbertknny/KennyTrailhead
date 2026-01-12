/** @description VlocityMappingOmniFlow  hanya run menggunakan global class */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
global without sharing class VlocityMappingOmniFlow implements callable{
    /** @description Call  @param action @param args @return invokemethod */
    public Object call(String action, Map<String, Object> args){
        VlocityMapping.VlocityParam vp = new VlocityMapping.VlocityParam();
        vp.methodName = action;
        vp.inputMap = (Map<String, Object>)args.get('input');
        vp.outMap = (Map<String, Object>)args.get('output');
        vp.options = (Map<String, Object>)args.get('options');
        return invokeMethod(vp);
    }
    /** @description VlocityMapping  @param vp @return boolean */
    public Boolean invokeMethod(VlocityMapping.VlocityParam vp) {
        Boolean result = true;
        List<Object> ldclauses = new List<Object>();
        List<ApexDefinedFlow> listClause = new List<ApexDefinedFlow>();
        String recid = null;
        String objnm = null;
        String fldnm = null;
        String val = null;
        Map<String,Object> maplc = new Map<String,Object>();
        Map<String,Object> maprec = new Map<String,Object>();
        String methodName = vp.methodName;
        Map<String, Object> inputMap = vp.inputMap;
        Map<String, Object> outMap = vp.outMap;
        Map<String, Object> options = vp.options;
        
        try{
            if(methodName.equals('Clause')){
                ldclauses = (List<Object>) inputMap.get('document_clauses') ;
                listClause = (List<ApexDefinedFlow>) JSON.deserialize(JSON.serialize(ldclauses), List<ApexDefinedFlow>.class);
                maplc.put('ListClause',listClause);
                Flow.Interview myFlow = Flow.Interview.createInterview('Upsert_Insurance_Policy_Product_Clause', maplc);
                myFlow.start();
                if(myFlow.getVariableValue('LClauseUpsert') != null){
                    outMap.put('result',JSON.deserializeUntyped(JSON.serialize(myFlow.getVariableValue('LClauseUpsert'))));
                }
                
            }else if(methodName.equals('DefaultClause')){
                recid = (String) inputMap.get('recid');
                List<InsurancePolicyProductClause> lippc = getclause('InsurancePolicyProductClause','Opportunity__c',recid);
                if(!lippc.isEmpty() && Schema.sObjectType.InsurancePolicyProductClause.isUpdateable()){
                    for(InsurancePolicyProductClause ippc : lippc){
                        ippc.Lintaswata_Sync__c = false;
                    }
                    update lippc;
                }
                outMap.put('result',lippc);
            }
            else if(methodName.equals('CurrentClause')){
                recid = (String) inputMap.get('recid');
                outMap.put('result',getclause('InsurancePolicyProductClause','Opportunity__c',recid));
            }
            else if(methodName.equals('GetPicklistLabel')){
                objnm = (String) inputMap.get('objnm');
                fldnm = (String) inputMap.get('fldnm');
                val = (String) inputMap.get('val');
                outMap.put('result',getPicklistLabel(objnm, fldnm, val));
            }
            else if(methodName.equals('ConvertTemplate')){
                objnm = (String) inputMap.get('objnm');
                maprec = (Map<String,Object>) inputMap.get('record');
                outMap.put('result',convertTemplate(objnm, maprec));
            }
        }
        catch(Exception exc){
            ErrorLogRecord.DebugLog dl = ErrorLogRecord.setError(null, 'VlocityMappingOmniFlow', exc);
            ErrorLogRecord.seteventerror(JSON.serialize(dl));
            result = false;
        }
        return result;
    }
    /** @description getClause  @param sobjnm @param param @param paramval @return lippc */
    public static List<InsurancePolicyProductClause> getClause(String sobjnm,String param,String paramval){
        List<InsurancePolicyProductClause> lippc = new List<InsurancePolicyProductClause>();
        String cond = param+'=:paramval';
        String dpFields = SOQL_SOBJECT.getallfield(sobjnm);
        SOQL_SOBJECT.SOQL_Param sp = new SOQL_SOBJECT.SOQL_Param();
        sp.sobjectName = sobjnm;
        sp.condition = cond;
        sp.fields = dpFields;
        String dpquery = SOQL_SOBJECT.SOQL(sp);// +' WITH SECURITY_ENFORCED';
        lippc = (List<InsurancePolicyProductClause>) database.query(dpquery);
        return lippc;
    }
    /** @description getPicklistLabel  @param objnm @param fldnm @param val @return mapval */
    public static Map<String,Object> getPicklistLabel(String objnm,String fldnm,String val){
        Map<String,Object> mapobj = SOQL_SOBJECT.getPicklistValue(objnm,fldnm);
        Map<String,Object> mapval = new Map<String,Object>();
        if(mapobj.containsKey(val)){
           mapval.put(val,mapobj.get(val)); 
        }
        return mapval;
    }
    /** @description convertTemplate  @param objnm @param maprec @return mapobj */
    public static Map<String,Object> convertTemplate(String objnm,Map<String,Object> maprec){
        Map<String,Object> mapobj = new Map<String,Object>();
        Map<String,Object> mapval = new Map<String,Object>();
        for(String fldnm:maprec.keySet()){
            mapval = getPicklistLabel(objnm, fldnm,(String) maprec.get(fldnm));
            if(mapval.size()>0){
                mapobj.put(fldnm,mapval.get((String) maprec.get(fldnm)));
            }
            else{
                mapobj.put(fldnm,maprec.get(fldnm));
            }
        }
        return mapobj;
    }
}