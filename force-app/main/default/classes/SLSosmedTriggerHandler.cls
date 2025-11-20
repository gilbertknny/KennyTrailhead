public class SLSosmedTriggerHandler {
    public static void handleBeforeTrigger(List<Case> newCases, Map<Id, Case> oldMap) {
        for (Case c : newCases) {
            if ((c.SproutExId__c != null || c.Date_Time_Post__c != null) && c.Date_Time_Answer__c == null) {
                if (Trigger.isInsert || c.SCC_SL_Sosmed_Timer_Dimulai__c == null) {
                    c.SCC_SL_Sosmed_Timer_Dimulai__c = DateTime.now();
                }
            }
        }
    }
}