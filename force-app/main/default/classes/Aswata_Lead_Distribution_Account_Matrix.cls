public with sharing class Aswata_Lead_Distribution_Account_Matrix {
    
    @InvocableMethod(label='Distribute Leads With Round Robin Account Matrix' description='Distribute Leads With Round Robin Account Matrix')
    public static List<LeadDistributionResult> distributeLeadsAccountMatrix(List<inputWrapperAccountMatrix> inputParams) {
        List<LeadDistributionResult> results = new List<LeadDistributionResult>();
        List<Lead> leadsToUpdate = new List<Lead>();
        List<Master_Data__c> masterDataToUpdate = new List<Master_Data__c>();
        LeadDistributionResult result = new LeadDistributionResult();
        System.debug('inputParams: ' +inputParams );
        String masterDataRecordTypeRoundRobin = 'Round Robin Member Account Matrix';
        String accountSegment  = '';
        String accountType = '';
        String businessSegment = '';
        String channel = '';
        String pipelineStatus = '';
        String leadId = '';
        String userId = '';
        String userName = '';
        for(inputWrapperAccountMatrix inputWrapper : inputParams) {
            if(inputWrapper.leadId == ''){
                result.errorMessage = 'No Lead Ids were provided.';
                //result.leadId = 'true';
                results.add(result);
                return results;
            } else {
                accountSegment = inputWrapper.accountSegment;
                accountType = inputWrapper.accountType;
                businessSegment = inputWrapper.businessSegment;
                channel = inputWrapper.leadChannel;
                pipelineStatus = inputWrapper.accountPipelineStatus;
                leadId = inputWrapper.leadId;
            }
        }

        try {
            // Step 1: Query Master Data for Round Robin Account Matrix
            
            List<Master_Data__c> lstMD = [Select Id, Round_Robin_Member__c, Round_Robin_Member__r.Name/*, Round_Robin_Counter__c*/ From 
                                        Master_Data__c Where Account_Segment__c =: accountSegment AND Account_Type__c =: accountType AND
                                        Business_Segmentation__c =: businessSegment  AND Channel__c =: channel AND Pipeline_Status__c =: pipelineStatus 
                                        AND RecordType.Name =: masterDataRecordTypeRoundRobin ]; //order by Round_Robin_Counter__c asc LIMIT 1];
            if(lstMD.size()>=1){
                for(Master_Data__c md : lstMD){
                    userId = md.Round_Robin_Member__c;
                    userName = md.Round_Robin_Member__r.Name;

                   // md.Round_Robin_Counter__c += 1;
                    masterDataToUpdate.add(md);
                }
            }

            Lead lead = new Lead();
            lead.Id = leadId;
            lead.OwnerId = userId;

            leadsToUpdate.add(lead);

            System.debug('userId: ' + userId);
            System.debug('userName: ' + userName);

            if(leadsToUpdate.size()>=1)
            {
                Database.SaveResult[] saveResults = Database.update(leadsToUpdate, false); 
                
                for (Integer i = 0; i < saveResults.size(); i++) {
                    Database.SaveResult sr = saveResults[i];
                    if (sr.isSuccess()) {
                        update masterDataToUpdate;
                        result.errorMessage = 'Successfully update record: ' + userName;
                    } else {
                        result.errorMessage = 'Failed update record';
                    }
                }
            }
        } catch (Exception ex) {
            
            result.errorMessage = 'Unexpected error : ' + ex.getMessage();
        }

        results.add(result);
        return results;
    }

    public class inputWrapperAccountMatrix {
        @InvocableVariable(required=true)
        public String leadId;

        @InvocableVariable
        public String accountSegment;

        @InvocableVariable
        public String accountType;

        @InvocableVariable
        public String businessSegment;
         
        @InvocableVariable
        public String leadChannel;

        @InvocableVariable
        public String accountPipelineStatus;

        @InvocableVariable
        public String ownerId;
    }

    public class LeadDistributionResult {
        @InvocableVariable
        public String errorMessage;
    }
}