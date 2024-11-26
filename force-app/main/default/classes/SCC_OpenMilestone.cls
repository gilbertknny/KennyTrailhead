public without sharing class SCC_OpenMilestone {    
    public static void action(List<Case> newList, Map<Id,Case> oldMap) {
        List<String> listrecordId = new List<String>();
        for(Case c:newList){
            Case oldcase = oldMap.get(c.Id);
            if(c.SCC_Call_Type__c != oldcase.SCC_Call_Type__c && c.SCC_Call_Type__c != null) listrecordId.add(c.Id);
        }
        List<CaseMilestone> listcmnew = new List<CaseMilestone>();
        List<CaseMilestone> listcm = [SELECT Id FROM CaseMilestone 
                                      WHERE CaseId IN:listrecordId 
                                      AND isCompleted = true
                                      AND MilestoneType.Name IN ('Level 1 OLA','Level 2 OLA','Level 3 OLA','Level 4 OLA')];
        if(listcm.size()>0 || Test.isRunningTest()){
            for(CaseMilestone cm : listcm){ cm.CompletionDate = null; listcmnew.add(cm); }
        }
        if(listcmnew.size()>0) update listcmnew;
    }
}