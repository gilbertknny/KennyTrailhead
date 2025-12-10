/*** @description InvocableOmniFlow */
public without sharing class InvocableOmniFlow {
    @InvocableMethod(label='InvocableOmniFlow' description='Call apex' category='Invocable')
    /*** @description Invocablevoid @param inputVariable  */
    public static void invocablevoid(List<List<ApexDefinedFlow>> inputVariable){
        List<InsurancePolicyProductClause> listippc = new List<InsurancePolicyProductClause>();
        for(List<ApexDefinedFlow> iv: inputVariable){
            for(ApexDefinedFlow apx:iv){
                InsurancePolicyProductClause ippc = new InsurancePolicyProductClause();
            }
        }
    }
}