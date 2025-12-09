public with sharing class Aswata_EditLeadInformation_Controller {
    
    public class JsonInput {
        @InvocableVariable(required=true description='JSON string containing Lead data')
        public String jsonString;
    }

    @InvocableMethod(
        label='Update Lead Information (JSON Input)' 
        description='Takes a JSON string and updates Lead fields accordingly'
    )
    public static void updateLeadInformationFromJson(List<JsonInput> inputs) {
        if (inputs == null || inputs.isEmpty()) {
            throw new AuraHandledException('No input received.');
        }

        for (JsonInput input : inputs) {
            if (String.isBlank(input.jsonString)) continue;

            try {
                // 🔹 Parse JSON into a Map
                Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(input.jsonString);

                if (!data.containsKey('id')) {
                    throw new AuraHandledException('Missing Lead Id in JSON.');
                }

                Id leadId = (Id) data.get('id');

                Lead leadRecord = new Lead(
                    Id = leadId,
                    Account_Type__c = (String) data.get('accountType'),
                    Account_Segment__c = (String) data.get('accountSegment'),
                    Account_Sub_Segment__c = (String) data.get('accountSubSegment'),
                    Account_Pipeline_Status__c = (String) data.get('pipelineStatus'),
                    Business_Segmentation__c = (String) data.get('businessSegmentation')
                );

                update leadRecord;

            } catch (Exception e) {
                System.debug('❌ Error updating Lead: ' + e.getMessage());
                throw new AuraHandledException('Failed to parse or update Lead. ' + e.getMessage());
            }
        }
    }

}