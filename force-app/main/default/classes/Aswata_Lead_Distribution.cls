/**
 * Lead distribution using round-robin logic.
 * Author: Fikri Hailal
 */

public with sharing class Aswata_Lead_Distribution {

    @InvocableMethod(label='Distribute Lead' description='Distribute a single Lead using round robin logic by Branch or Account Segmentation')
    public static List<LeadDistributionResult> distributeLead(List<LeadInput> leads) {
        List<LeadDistributionResult> results = new List<LeadDistributionResult>();
        LeadDistributionResult result = new LeadDistributionResult();

        if (leads == null || leads.isEmpty()) {
            result.errorMessage = 'No Lead record provided.';
            results.add(result);
            return results;
        }

        // Expect only one lead per call
        Lead lead = leads[0].lead;
        result.leadId = lead.Id;

        try {
            Master_Data__c selectedSalesman;
            Boolean isBranchLogic = false;

            // === CASE 1: Lead has Branch__c ===
            if (!String.isBlank(lead.Branch__c)) {
                isBranchLogic = true;
                List<Master_Data__c> mdList = [
                    SELECT Id, Round_Robin_Member__c, Round_Robin_Member__r.Name, Branch__c,
                           Round_Robin_Counter_Branch__c, Round_Robin_Counter_Account__c
                    FROM Master_Data__c
                    WHERE Salesman_Branch__r.BRANCH_ID__c  = :lead.Branch__c and RecordType.Name = 'Round Robin Member'
                    WITH SECURITY_ENFORCED
                    ORDER BY Round_Robin_Counter_Branch__c ASC
                    LIMIT 1
                ];

                if (!mdList.isEmpty()) {
                    selectedSalesman = mdList[0];
                } else {
                    result.errorMessage = 'No salesman found for Branch: ' + lead.Branch__c;
                    results.add(result);
                    return results;
                }
            }
            // === CASE 2: Lead does NOT have Branch__c ===
            else {
                List<Master_Data__c> mdList = [
                    SELECT Id, Round_Robin_Member__c, Round_Robin_Member__r.Name, Round_Robin_Counter_Branch__c,
                           Round_Robin_Counter_Account__c,
                           Account_Type__c, Account_Segment__c, Account_Sub_Segment__c,
                           Pipeline_Status__c, Business_Segmentation__c
                    FROM Master_Data__c
                    WHERE Account_Type__c = :lead.Account_Type__c
                    AND Account_Segment__c = :lead.Account_Segment__c
                    AND Account_Sub_Segment__c = :lead.Account_Sub_Segment__c
                    AND Pipeline_Status__c = :lead.Account_Pipeline_Status__c
                    AND Business_Segmentation__c = :lead.Business_Segmentation__c
                    AND RecordType.Name = 'Round Robin Member Account Matrix'
                    WITH SECURITY_ENFORCED
                    ORDER BY Round_Robin_Counter_Account__c ASC
                    LIMIT 1
                ];

                if (!mdList.isEmpty()) {
                    selectedSalesman = mdList[0];
                } else {
                    result.errorMessage = 'No salesman found for given segmentation criteria.';
                    results.add(result);
                    return results;
                }
            }

            // === Assign and update ===
            if (selectedSalesman != null) {
                //lead.OwnerId = selectedSalesman.Salesman__c;
                if (Schema.sObjectType.Lead.isUpdateable()) {
                    lead.OwnerId = selectedSalesman.Round_Robin_Member__c;
                    update lead;
                }

                // Increment the appropriate counter
                if (isBranchLogic) {
                    selectedSalesman.Round_Robin_Counter_Branch__c = (selectedSalesman.Round_Robin_Counter_Branch__c == null ? 1 : selectedSalesman.Round_Robin_Counter_Branch__c + 1);
                } else {
                    selectedSalesman.Round_Robin_Counter_Account__c = (selectedSalesman.Round_Robin_Counter_Account__c == null ? 1 : selectedSalesman.Round_Robin_Counter_Account__c + 1);
                }

                if (Schema.sObjectType.Master_Data__c.isUpdateable()) {
                    update selectedSalesman;
                }

                result.errorMessage = 'Successfully assigned lead to ' + selectedSalesman.Round_Robin_Member__r.Name;
            }

        } catch (Exception ex) {
            result.errorMessage = 'Error during lead distribution: ' + ex.getMessage();
        }

        results.add(result);
        return results;
    }

    public class LeadDistributionResult {
        @InvocableVariable
        public String leadId;

        @InvocableVariable
        public String errorMessage;
    }

    public class LeadInput {
        @InvocableVariable(required=true)
        public Lead lead;
    }
 
}