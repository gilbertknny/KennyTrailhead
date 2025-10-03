public class DeleteWorkItemHandler {
    @AuraEnabled
    public static list<sf_devops__Project__c> fetchProjects() {
        return [ SELECT Id, Name FROM sf_devops__Project__c];    
    }
    @AuraEnabled
    public static list<sf_devops__Work_Item__c> getAllWorkItems(String projectName) {
        return [SELECT name,sf_devops__Subject__c,sf_devops__State__c,sf_devops__Assigned_To__r.Name FROM sf_devops__Work_Item__c WHERE sf_devops__Project__r.name =: projectName];
    }
    @AuraEnabled
    public static void deleteSelectedWorkItem(list<sf_devops__Work_Item__c> wItemList) {
        system.debug(wItemList);
        list<String> workItemNames = new list<String>();
        for(sf_devops__Work_Item__c WI: wItemList){
            workItemNames.add(WI.name);
            
        }
        system.debug(workItemNames);
        delete [SELECT Id, sf_devops__Change_Submission__r.name FROM sf_devops__Remote_Change__c where sf_devops__Change_Submission__c in (SELECT Id FROM sf_devops__Change_Submission__c where sf_devops__Work_Item__r.name in: workItemNames)];
        delete [SELECT Id FROM sf_devops__Change_Submission__c where sf_devops__Work_Item__r.name in: workItemNames];
        delete [SELECT Id FROM sf_devops__Work_Item__c where name in: workItemNames];
    }
}