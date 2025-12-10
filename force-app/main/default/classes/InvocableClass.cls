/*** @description InvocableClass */
public without sharing class InvocableClass {
    @InvocableMethod(label='Invocable Class' description='Call apex' category='Invocable')
    /*** @description Invocablevoid @param inputVariable  @return listout*/
    public static List<OutputVariable> invocablevoid(List<InputVariable> inputVariable){
        List<OutputVariable> listout = new List<OutputVariable>();
        String cond  = '';
        try {
            for(InputVariable iv: inputVariable){
                OutputVariable ov = new OutputVariable();
                if(iv.param == 'BatchRiskAssetCoverage') {
                    batchRiskAssetCoverage(iv);
                }
                else if(iv.param=='UnderwritingApproval'){
                    cond = UnderwritingApproval(iv);
                    ClsUserLimit.userlimit ul = ClsUserLimit.getUserId(iv.sumInsured,cond); //AND BSN_ID__c = ‘201’
                    ov.userId = ul.userId;
                    listout.add(ov);
                }
            }
        } catch (Exception error) {
            System.debug(LoggingLevel.WARN, 'Error occured'+error.getMessage());
        } 
        return listout;
    }
    /*** @description Invocablevoid @param iv */
    public static void batchRiskAssetCoverage(inputVariable iv){
        String query = 'SELECT Id from Asset where Opportunity__c = '+'\''+iv.oldoptyId+'\' and Recordtype.Name = '+'\'Risk'+'\' and Lintaswata_Sync__c = '+iv.lintaswataSync;
        BatchRiskAssetCoverage batch = new BatchRiskAssetCoverage(query,iv.newoptyId,iv.accountId);
        Database.executeBatch(batch,1);
    }

    /*** @description Invocablevoid @param iv */
    public static String UnderwritingApproval(inputVariable iv){
        String cond ='';
        if(String.isNotBlank(iv.cob)){
            List<Master_Data__c> listmd = [SELECT Id,showData__c FROM Master_Data__c WHERE BSN_ID__c =:iv.cob AND RecordType.Name = 'User Limit' AND Status__c = 'Active' WITH SECURITY_ENFORCED];
            if(!listmd.isEmpty() && String.isNotBlank(iv.oldoptyId)){
                List<Object> untypedList = (List<Object>) JSON.deserializeUntyped(listmd[0]?.showData__c);
                String dpquery = getQuery('Opportunity', 'Id', iv.oldoptyId);
                List<Opportunity> listopp = (List<Opportunity>) database.query(dpquery);
                for (Object item : untypedList) {
                    Map<String, Object> itemMap = (Map<String, Object>) item;
                    if(itemMap.containsKey('param1') && itemMap.containsKey('param2')){
                        cond  += ' AND '+itemMap.get('param1')+' = '+'\''+itemMap.get('param2')+'\'';
                    }
                }
            }
            else{
                cond  = ' AND BSN_ID__c = '+'\''+iv.cob+'\'';
            }
        }
        return cond;
    }

     /** @description getClause  @param sobjnm @param param @param paramval @return lippc */
    public static String getQuery(String sobjnm,String param,String paramval){
        String cond = param+'=:paramval';
        String dpFields = SOQL_SOBJECT.getallfield(sobjnm);
        SOQL_SOBJECT.SOQL_Param sp = new SOQL_SOBJECT.SOQL_Param();
        sp.sobjectName = sobjnm;
        sp.condition = cond;
        sp.fields = dpFields;
        String dpquery = SOQL_SOBJECT.SOQL(sp)+' WITH SECURITY_ENFORCED';
        return dpquery;
    }

    /** @description InputVariable */
    public class InputVariable {
        /** @description accountId */
        @InvocableVariable
        public Id accountId;
        /** @description oldoptyId */
        @InvocableVariable
        public Id oldoptyId;
        /** @description newoptyId */  
        @InvocableVariable
        public Id newoptyId;
        /** @description sumInsured */  
        @InvocableVariable
        public Decimal sumInsured;
        /** @description lintaswataSync */ 
        @InvocableVariable
        public Boolean lintaswataSync;
        /** @description COB */ 
        @InvocableVariable
        public String cob;
        /** @description param */
        @InvocableVariable
        public String param;
    }

    /** @description OutputVariable */
    public class OutputVariable {
        /** @description userId */
        @InvocableVariable
        public Id userId;
    }
}