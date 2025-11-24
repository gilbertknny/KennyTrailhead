public class RiskBulkCloneHelper {
    
    @InvocableMethod(label='Start Bulk Async Risk Cloning' 
                    description='Starts async process to clone multiple Risks with children via Flow')
    public static void startBulkAsyncRiskCloning(List<Id> clonedRiskIds) {
        if (clonedRiskIds == null || clonedRiskIds.isEmpty()) {
            return; // Exit if no IDs provided
        }
        
        // Enqueue separate job for each cloned Risk
        for (Id clonedRiskId : clonedRiskIds) {
            System.enqueueJob(new RiskCloneOrchestrator(clonedRiskId));
        }
        
        System.debug('Enqueued ' + clonedRiskIds.size() + ' async cloning jobs');
    }
}
/*
public class RiskBulkCloneHelper {
    
    @InvocableMethod(label='Start Bulk Async Risk Cloning' 
                    description='Starts async process to clone multiple Risks with children via Flow')
    public static void startBulkAsyncRiskCloning(List<Id> clonedRiskIds) {
        if (clonedRiskIds == null || clonedRiskIds.isEmpty()) {
            system.debug('clonedRiskIds null or empty');
            return; // Exit if no IDs provided
        }
        
        // Query all cloned Risks to get their original Risk IDs
        Map<Id, Asset> clonedRisksMap = new Map<Id, Asset>([
            SELECT Id, Origin_Risk__c 
            FROM Asset 
            WHERE Id IN :clonedRiskIds 
            AND Origin_Risk__c != null
        ]);
        
        System.debug('Found ' + clonedRisksMap.size() + ' Risks to process');
        
        // Enqueue separate job for each Risk
        for (Asset clonedRisk : clonedRisksMap.values()) {
            System.enqueueJob(new RiskCloneOrchestrator(
                clonedRisk.Origin_Risk__c, // Original Risk ID from the field
                clonedRisk.Id              // Cloned Risk ID
            ));
        }
        
        System.debug('Enqueued ' + clonedRisksMap.size() + ' async cloning jobs');
    }
} */
/* 
public class RiskBulkCloneHelper {
    
    @InvocableMethod(label='Start Bulk Async Risk Cloning' 
                    description='Starts async process to clone multiple Risks with children via Flow')
    /*public static void startBulkAsyncRiskCloning(List<BulkCloneRequest> requests) {
        // Enqueue separate job for each Risk
        for (BulkCloneRequest request : requestList) {
            for (RiskPair riskPair : request.riskPairs) {
                System.enqueueJob(new RiskCloneOrchestrator(
                    riskPair.originalRiskId, 
                    riskPair.clonedRiskId
                ));
            }
        }
    }*//*
    
    // Alternative method for simple list of IDs
    public static void startBulkAsyncRiskCloning(List<Id> originalRiskIds, List<Id> clonedRiskIds) {
        if (originalRiskIds.size() != clonedRiskIds.size()) {
            throw new IllegalArgumentException('Original and cloned Risk ID lists must be same size');
        }
        
        for (Integer i = 0; i < originalRiskIds.size(); i++) {
            System.enqueueJob(new RiskCloneOrchestrator(
                originalRiskIds[i], 
                clonedRiskIds[i]
            ));
        }
    }
    
    // Wrapper classes
    public class BulkCloneRequest {
        @InvocableVariable(label='Risk Pairs')
        public List<RiskPair> riskPairs;
    }
    
    public class RiskPair {
        @InvocableVariable(label='Original Risk ID' required=true)
        public Id originalRiskId;
        
        @InvocableVariable(label='Cloned Risk ID' required=true)
        public Id clonedRiskId;
        
        // Constructor for easy creation
        public RiskPair(Id originalId, Id clonedId) {
            this.originalRiskId = originalId;
            this.clonedRiskId = clonedId;
        }
    }
} */