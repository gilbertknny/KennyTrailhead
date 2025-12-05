/**
* Class for Trigger_Opportunity
* TC : GS
* DATE : 03/11/25
*/
 
public class Aswata_TriggerHandler_Opportunity extends TriggerHandler {
    public override void beforeUpdate(){ 
        for(Opportunity data : (List<Opportunity>) Trigger.new) {
            assignPICId(data.Id);
        }
    } 
    
    @future
    public static void assignPICId(String recordId){
        ClsPolicyDistribution.data result = ClsPolicyDistribution.getUserIdFilter(recordId);
        Opportunity opp = new Opportunity();
        opp.Id = recordId;
        opp.Policy_Distribution__c = result.Id; 
        if(result.userid != null){ opp.User_PIC__c = result.userid; }
        if(!Test.isRunningTest()){ update opp; }
    }
}