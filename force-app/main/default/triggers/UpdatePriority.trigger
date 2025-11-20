trigger UpdatePriority on Case (before insert, before update) {
    Set<Id> callTypeIds = new Set<Id>();
    for (Case c : Trigger.new) {
        if (c.SCC_Call_Type__c != null) {
            callTypeIds.add(c.SCC_Call_Type__c);
        }
    }

    Map<Id, SSC_Call_Type__c> callTypeMap = new Map<Id, SSC_Call_Type__c>(
        [SELECT Id, SCC_Priority__c FROM SSC_Call_Type__c WHERE Id IN :callTypeIds]
    );

    for (Case c : Trigger.new) {
        SSC_Call_Type__c callType = callTypeMap.get(c.SCC_Call_Type__c);
        if (callType != null && callType.SCC_Priority__c == true) {
            c.Priority = 'High (Urgent/Critical)';
        }
    }
}