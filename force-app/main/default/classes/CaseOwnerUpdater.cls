public class CaseOwnerUpdater {
    
    /*public static List<Case> updateCaseOwners(List<Case> newCases) {
        System.debug('Entering updateCaseOwners method.');
        List<Case> listcs = new List<Case>();*/
      
        /*if (FeatureManagement.checkPermission('Change_owner_Custom_permission')) {
            System.debug('User has Change_owner_Custom_permission.');**/
            
            //Set<Id> callTypeIds = new Set<Id>();
            /*Map<Id, Case> casesToUpdate = new Map<Id, Case>();
            for (Case c : newCases) {
                if (c.SCC_Call_Type__c != null) {
                    casesToUpdate.put(c.Id, c);
                    //callTypeIds.add(c.SCC_Call_Type__c);
                }
            }*/

            //System.debug('Collected Call_Type_Numbers: ' + callTypeIds);

            
            //Id caseMigrationRecordTypeId;
            //for (RecordType rt : [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND Name = 'Case Migration' LIMIT 1]) {
            //    caseMigrationRecordTypeId = rt.Id;
            //}

            //System.debug('Case Migration Record Type ID: ' + caseMigrationRecordTypeId);

            
            /*Map<Id, SSC_Call_Type__c> callTypeMap = new Map<Id, SSC_Call_Type__c>();
            if (!callTypeIds.isEmpty()) {
                for (SSC_Call_Type__c callType : [
                    SELECT Id, SCC_Level1_Escalation_team__c, SCC_Level2_Escalation_team__c,
                           SCC_Level3_Escalation_team__c, SCC_Level4_Escalation_team__c
                    FROM SSC_Call_Type__c
                    WHERE Id IN :callTypeIds
                ]) {
                    callTypeMap.put(callType.Id, callType);
                }
            }

            System.debug('Queried SSC_Call_Type__c records: ' + callTypeMap);

            Set<String> teamNames = new Set<String>();
            for (SSC_Call_Type__c callType : callTypeMap.values()) {
                if (callType.SCC_Level1_Escalation_team__c != null) {
                    teamNames.add(callType.SCC_Level1_Escalation_team__c);
                }
                if (callType.SCC_Level2_Escalation_team__c != null) {
                    teamNames.add(callType.SCC_Level2_Escalation_team__c);
                }
                if (callType.SCC_Level3_Escalation_team__c != null) {
                    teamNames.add(callType.SCC_Level3_Escalation_team__c);
                }
                if (callType.SCC_Level4_Escalation_team__c != null) {
                    teamNames.add(callType.SCC_Level4_Escalation_team__c);
                }
            }*/

           
            /*Map<String, Id> queueMap = new Map<String, Id>();
            for (Group queue : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :teamNames]) {
                queueMap.put(queue.Name, queue.Id);
                System.debug('Queue Name: ' + queue.Name + ', Queue ID: ' + queue.Id);
            }*/

            //casesToUpdate.values()
            /*for (Case c : newCases) {
                // && callTypeMap.containsKey(c.SCC_Call_Type__c) 
                if (c.SCC_Call_Type__c != null 
                    //&& c.RecordTypeId == caseMigrationRecordTypeId
                   ) {
                       system.debug('caseid '+c.id);
					 // Nama Flow yang akan dipanggil
                    String flowName = 'case_Automation_Intgration';
                    
                    // Membuat map untuk input parameter
                    Map<String, Object> inputParams = new Map<String, Object>();
                    inputParams.put('CaseId', c.Id); // Ganti 'param1' dan 'value1' sesuai dengan Flow Anda
            
                    // Memulai Flow
                    Flow.Interview interview = Flow.Interview.createInterview(flowName, inputParams);
                    interview.start();
                       System.debug('interview: ' + interview);
                    // Jika Flow menghasilkan output, Anda bisa mengambilnya seperti ini
                    Case outputValue = (Case) interview.getVariableValue('CaseOutput'); // Ganti 'outputParam1' sesuai dengan Flow Anda
            
                    System.debug('Output dari Flow: ' + outputValue);
                    listcs.add(outputValue);
                } else {
                    c.OwnerId = System.Label.SCC_Contact_Center;
                    System.debug('Case: ' + c.Id + ' does not meet criteria or call type not found.');
                }
            }

            System.debug('Exiting updateCaseOwners method.');
        } else {
            System.debug('User does not have Change_owner_Custom_permission.');
        }**/
        /*return listcs;
    }*/
}