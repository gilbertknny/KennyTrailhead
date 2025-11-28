/*** @description InvocableClass */
public without sharing class InvocableClass {
    @InvocableMethod(label='Invocable Class' description='Call apex' category='Invocable')
    /*** @description Invocablevoid @param inputVariable  */
    public static List<OutputVariable> invocablevoid(List<InputVariable> inputVariable){
        List<OutputVariable> listout = new List<OutputVariable>();
        try {
            for(InputVariable iv: inputVariable){
                OutputVariable ov = new OutputVariable();
                if(iv.param == 'BatchRiskAssetCoverage') {
                    String query = 'SELECT Id from Asset where Opportunity__c = '+'\''+iv.oldoptyId+'\' and Recordtype.Name = '+'\'Risk'+'\' and Lintaswata_Sync__c = '+iv.LintaswataSync;
                    BatchRiskAssetCoverage batch = new BatchRiskAssetCoverage(query,iv.newoptyId,iv.accountId);
                    Database.executeBatch(batch,1);
                }
                else if(iv.param=='UnderwritingApproval'){
                    ClsUserLimit.userlimit ul = ClsUserLimit.getUserId(iv.sumInsured);
                    ov.userId = ul.userId;
                    listout.add(ov);
                }
            }
        } catch (Exception error) {
            System.debug('Error occured'+error.getMessage());
        } 
        return listout;
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
        public Boolean LintaswataSync;

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