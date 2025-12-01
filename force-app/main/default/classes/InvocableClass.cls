/*** @description InvocableClass */
public without sharing class InvocableClass {
    @InvocableMethod(label='Invocable Class' description='Call apex' category='Invocable')
    /*** @description Invocablevoid @param inputVariable  @return listout*/
    public static List<OutputVariable> invocablevoid(List<InputVariable> inputVariable){
        List<OutputVariable> listout = new List<OutputVariable>();
        try {
            for(InputVariable iv: inputVariable){
                OutputVariable ov = new OutputVariable();
                if(iv.param == 'BatchRiskAssetCoverage') {
                    batchRiskAssetCoverage(iv);
                }
                else if(iv.param=='UnderwritingApproval'){
                    ClsUserLimit.userlimit ul = ClsUserLimit.getUserId(iv.sumInsured);
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
        /** @description newoptyId */  
        @InvocableVariable
        public Decimal sumInsured;

        @InvocableVariable
        public Boolean lintaswataSync;

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