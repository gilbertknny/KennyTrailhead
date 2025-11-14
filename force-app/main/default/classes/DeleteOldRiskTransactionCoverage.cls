global with sharing class DeleteOldRiskTransactionCoverage implements System.Callable {

    // Required method for Callable interface
    
    public Object call(String action, Map<String, Object> args) {
        if (action == 'deleteAllByOpportunityId') {
            // Extract nested map
            Map<String, Object> inputMap = (Map<String, Object>) args.get('input');
            String opptyId = (String) inputMap.get('opptyId');
            return deleteAllByOpportunityId(opptyId);
        } else {
            throw new IllegalArgumentException('Unknown action: ' + action);
        }
    }


    // Your existing logic
    public static Map<String, Object> deleteAllByOpportunityId(String opptyId) {
        Map<String, Object> response = new Map<String, Object>();

        if (String.isBlank(opptyId)) {
            response.put('status', 'ERROR');
            response.put('message', 'Opportunity Id is required.');
            return response;
        }

        try {
            List<Asset> assetList = [
                SELECT Id FROM Asset WHERE Opportunity__c = :opptyId
            ];

            List<Transaction_Data__c> trxDataList = [
                SELECT Id FROM Transaction_Data__c WHERE Opportunity__c = :opptyId
            ];

            List<InsurancePolicyCoverage> coverageList = [
                SELECT Id FROM InsurancePolicyCoverage WHERE Opportunity__c = :opptyId
            ];

            System.debug('>>> DELETE PROCESS STARTED for Opportunity: ' + opptyId);
            System.debug('>>> Asset found: ' + assetList.size());
            System.debug('>>> Transaction_Data__c found: ' + trxDataList.size());
            System.debug('>>> Coverage found: ' + coverageList.size());

            // Combine into one list
            List<SObject> toDelete = new List<SObject>();
            toDelete.addAll(assetList);
            toDelete.addAll(trxDataList);
            toDelete.addAll(coverageList);

            if (!toDelete.isEmpty()) {
                delete toDelete;  // Soft delete
            }

            response.put('status', 'SUCCESS');
            response.put('opportunityId', opptyId);
            response.put('assetDeleted', assetList.size());
            response.put('transactionDataDeleted', trxDataList.size());
            response.put('coverageDeleted', coverageList.size());

        } catch (Exception e) {
            response.put('status', 'ERROR');
            response.put('message', e.getMessage());
        }

        return response;
    }
}