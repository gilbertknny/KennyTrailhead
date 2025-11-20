/**
 * @description SCC_QueueController
 */
public without sharing class SCC_QueueController {
    /**
     * @description searchQueueNames
     * @param searchTerm
     * @return List<String>
     */
    @AuraEnabled(cacheable=true)
    public static List<String> searchQueueNames(String searchTerm) {
        List<String> options = new List<String>();
        String query = '%' + searchTerm + '%';
        for (Group g : [SELECT 
                        Name 
                        FROM Group
                        WHERE Type = 'Queue' 
                        AND Name LIKE :query 
                        LIMIT 500]) {
            options.add(g.Name);
        }
        return options;
    }

    /**
     * @description saveQueueToCustomObject
     * @param customObjectId
     * @param queueName
     * @param fieldName
     */
    @AuraEnabled
    public static void saveQueueToCustomObject(String customObjectId, String queueName, String fieldName) {
        // Replace 'SSC_Call_Type__c' with your custom object's API name
        SSC_Call_Type__c record = [SELECT 
                                    Id, 
                                    SCC_Level1_Escalation_team__c,
                                    SCC_Level2_Escalation_team__c,
                                    SCC_Level3_Escalation_team__c,
                                    SCC_Level4_Escalation_team__c
                                    FROM SSC_Call_Type__c 
                                    WHERE Id = :customObjectId
                                    LIMIT 1];

        if(fieldName == 'SCC_Level1_Escalation_team__c'){
            record.SCC_Level1_Escalation_team__c = queueName; 
        }else if(fieldName == 'SCC_Level2_Escalation_team__c'){
            record.SCC_Level2_Escalation_team__c = queueName;
        }else if(fieldName == 'SCC_Level3_Escalation_team__c'){
            record.SCC_Level3_Escalation_team__c = queueName; 
        }else if(fieldName == 'SCC_Level4_Escalation_team__c'){
            record.SCC_Level4_Escalation_team__c = queueName;
        }
        update record;
    }
}