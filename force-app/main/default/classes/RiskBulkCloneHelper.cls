/**
 * @author [Marco Lie]
 * @date [2025-11-26]
 * @description Helper class for bulk risk cloning operations that initiates asynchronous
 * cloning processes for multiple risk records. This class is designed to be called
 * from Flows to handle mass risk cloning operations in a governor-limit aware manner.
 */
public class RiskBulkCloneHelper {
    
    /**
     * @description Invocable method that starts bulk asynchronous risk cloning processes
     * @param clonedRiskIds List of risk record IDs that need child records cloned
     */
    @InvocableMethod(label='Start Bulk Async Risk Cloning' 
                    description='Starts async process to clone multiple Risks with children via Flow')
    public static void startBulkAsyncRiskCloning(List<Id> clonedRiskIds) {
        if (clonedRiskIds == null || clonedRiskIds.isEmpty()) {
            return; // Exit if no IDs provided
        }
        
        // Check governor limits before processing
        Integer availableQueueableJobs = Limits.getLimitQueueableJobs() - Limits.getQueueableJobs();
        if (availableQueueableJobs <= 0) {
            return; // No available queueable jobs, exit gracefully
        }
        
        // Process only up to available queueable jobs
        Integer jobsToProcess = Math.min(clonedRiskIds.size(), availableQueueableJobs);
        processRiskCloning(clonedRiskIds, jobsToProcess);
    }
    
    /**
     * @description Processes risk cloning within governor limits
     * @param clonedRiskIds List of risk record IDs to process
     * @param jobsToProcess Number of jobs that can be processed within limits
     */
    private static void processRiskCloning(List<Id> clonedRiskIds, Integer jobsToProcess) {
        // Process only the number of jobs we can handle within limits
        for (Integer i = 0; i < jobsToProcess; i++) {
            System.enqueueJob(new RiskCloneOrchestrator(clonedRiskIds[i]));
        }
    }
}
// Before PMD
/*
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
} */
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