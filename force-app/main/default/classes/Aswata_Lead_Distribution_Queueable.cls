public class Aswata_Lead_Distribution_Queueable implements Queueable {
    private List<Id> leadIds;

    // Constructor to accept lead Ids
    public Aswata_Lead_Distribution_Queueable(List<Id> leadIds) {
        this.leadIds = leadIds;
    }

    public void execute(QueueableContext context) {
        String masterDataRecordTypeRoundRobin = 'Round Robin Member';

        System.debug('Queueable leadIds: ' + leadIds);
        if (leadIds == null || leadIds.isEmpty()) {
            System.debug('No Lead Ids were provided.');
            return;
        }

        try {
            // Step 1: Query all leads with branch
            List<Lead> leads = [
                SELECT Id, Branch__c, OwnerId
                FROM Lead
                WHERE Id IN :leadIds
            ];

            System.debug('Queueable leads: ' + leads);

            // Group leads by branch
            Map<String, List<Lead>> branchToLeadsMap = new Map<String, List<Lead>>();
            Set<String> branchIds = new Set<String>();

            for (Lead lead : leads) {
                if (String.isNotBlank(lead.Branch__c)) {
                    branchIds.add(lead.Branch__c);
                    if (!branchToLeadsMap.containsKey(lead.Branch__c)) {
                        branchToLeadsMap.put(lead.Branch__c, new List<Lead>());
                    }
                    branchToLeadsMap.get(lead.Branch__c).add(lead);
                }
            }

            System.debug('branchIds: ' + branchIds);

            // Step 2: Query all salesmen per branch (round robin members)
            List<Master_Data__c> masterList = [
                SELECT Id, Salesman_branch__c, Salesman_branch__r.BRANCH_ID__c, 
                       Round_Robin_Member__c, Round_Robin_Counter_Branch__c
                FROM Master_Data__c
                WHERE RecordType.Name = :masterDataRecordTypeRoundRobin
                AND Salesman_branch__r.BRANCH_ID__c IN :branchIds
                ORDER BY Round_Robin_Counter_Branch__c ASC
            ];

            System.debug('masterList.size: ' + masterList.size());

            // Group salesmen by branch
            Map<String, List<Master_Data__c>> branchToSalesmenMap = new Map<String, List<Master_Data__c>>();
            for (Master_Data__c md : masterList) {
                if (!branchToSalesmenMap.containsKey(md.Salesman_branch__r.BRANCH_ID__c)) {
                    branchToSalesmenMap.put(md.Salesman_branch__r.BRANCH_ID__c, new List<Master_Data__c>());
                }
                branchToSalesmenMap.get(md.Salesman_branch__r.BRANCH_ID__c).add(md);
            }

            System.debug('Queueable branchToSalesmenMap: ' + branchToSalesmenMap);

            // Step 3: Assign leads in round-robin per branch
            List<Lead> leadsToUpdate = new List<Lead>();
            Map<String, Master_Data__c> salesmanToUpdate = new Map<String, Master_Data__c>();

            for (String branchId : branchToLeadsMap.keySet()) {
                List<Lead> branchLeads = branchToLeadsMap.get(branchId);
                System.debug('Queueable branchLeads: ' + branchLeads);
                List<Master_Data__c> salesmen = branchToSalesmenMap.get(branchId);
                System.debug('Queueable salesmen: ' + salesmen);

                if (branchLeads == null || salesmen == null || salesmen.isEmpty()) {
                    continue; // skip if no salesmen
                }

                Integer salesmanCount = salesmen.size();
                Integer counter = 0;

                for (Lead lead : branchLeads) {
                    try {
                        Master_Data__c assignedSalesman = salesmen.get(Math.mod(counter, salesmanCount));
                        lead.OwnerId = assignedSalesman.Round_Robin_Member__c;
                        leadsToUpdate.add(lead);

                        // Update counter for that salesman
                        if (!salesmanToUpdate.containsKey(assignedSalesman.Id)) {
                            assignedSalesman.Round_Robin_Counter_Branch__c += 1;
                            salesmanToUpdate.put(assignedSalesman.Id, assignedSalesman);
                        } else {
                            salesmanToUpdate.get(assignedSalesman.Id).Round_Robin_Counter_Branch__c += 1;
                        }
                        counter++;
                    } catch (Exception innerEx) {
                        System.debug('Error assigning lead ' + lead.Id + ': ' + innerEx.getMessage());
                    }
                }
            }

            // Step 4: DML Updates
            if (!leadsToUpdate.isEmpty()) {
                update leadsToUpdate;
            }

            if (!salesmanToUpdate.isEmpty()) {
                update salesmanToUpdate.values();
            }

        } catch (Exception ex) {
            System.debug('Unexpected error: ' + ex.getMessage());
        }
    }
}