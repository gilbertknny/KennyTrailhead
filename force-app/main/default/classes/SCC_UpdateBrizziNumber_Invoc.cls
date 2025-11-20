public with sharing class SCC_UpdateBrizziNumber_Invoc {
    // Inner class to define input parameters from Flow
    public class FlowInput {
        @InvocableVariable(required=true)
        public Id recordId;
        
        @InvocableVariable(required=true)
        public String remark;
    }

    // Constants
    private static final String BRIZZI_KEY = 'Nomor Kartu BRIZZI';
    private static final Integer BRIZZI_NUMBER_LENGTH = 16;
    
    // Invocable method that can be called from Flow
    @InvocableMethod(label='Invocable Case Update Brizzi' category='Invocable')
    public static void updateBrizziNumber(List<FlowInput> inputs) {
        try {
            if (inputs == null || inputs.isEmpty()) {
                throw new AuraHandledException('No input received from Flow');
            }
            
            // Get the first input since Flow will always pass a list
            FlowInput input = inputs[0];
            
            // Validate input parameters
            if (String.isBlank(input.remark)) {
                throw new AuraHandledException('Remark field cannot be empty');
            }
            
            // Extract Brizzi number from remark
            String brizziNumber = extractBrizziNumber(input.remark);
            
            if (String.isBlank(brizziNumber)) {
                throw new AuraHandledException('Unable to extract valid Brizzi number from remark');
            }
            
            // Query and update the Case record
            Case caseRecord = [SELECT Id, SCC_Brizzi_Card_Number__c 
                             FROM Case 
                             WHERE Id = :input.recordId 
                             LIMIT 1];
            
            caseRecord.SCC_Brizzi_Card_Number__c = brizziNumber;
            update caseRecord;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Helper method to extract Brizzi number from remark
    private static String extractBrizziNumber(String remark) {
        try {
            // Clean up the input to remove unnecessary characters (carriage returns, newlines)
            String sanitizedRemark = remark.replace('\r', '').replace('\n', '').trim();

            // Parse the cleaned JSON string
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(sanitizedRemark);
            
            // Get the Brizzi number from the parsed JSON
            String brizziNumber = (String) jsonData.get(BRIZZI_KEY);
            
            // Clean and validate the number
            if (String.isNotBlank(brizziNumber)) {
                // Remove any quotes or spaces
                brizziNumber = brizziNumber.replaceAll('["\' ]', '');
                
                // Validate the number is numeric and correct length
                if (brizziNumber.isNumeric() && brizziNumber.length() == BRIZZI_NUMBER_LENGTH) {
                    return brizziNumber;
                }
            }

            return null;

        } catch (Exception e) {
            // If JSON parsing fails, return null
            return null;
        }
    }
}