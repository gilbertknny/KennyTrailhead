public class RiskCloneOrchestrator implements Queueable {
    private Id clonedRiskId;
    
    public RiskCloneOrchestrator(Id clonedRiskId) {
        this.clonedRiskId = clonedRiskId;
    }
    
    public void execute(QueueableContext context) {
        try {
            // Call Flow with only the cloned Risk ID
            Map<String, Object> flowInputs = new Map<String, Object>();
            flowInputs.put('riskId', clonedRiskId);
            
            Flow.Interview.Clone_Risk_Children cloneFlow = 
                new Flow.Interview.Clone_Risk_Children(flowInputs);
            cloneFlow.start();
            
            System.debug('Successfully started child cloning for Risk: ' + clonedRiskId);
            
        } catch(Exception e) {
            System.debug('Error in RiskCloneOrchestrator for Risk ' + clonedRiskId + ': ' + e.getMessage());
            // Optional: Add error logging here
        }
    }
}

/* old code
public class RiskCloneOrchestrator implements Queueable {
    private Id originalRiskId;
    private Id clonedRiskId;
    
    // Constructor for single Risk
    public RiskCloneOrchestrator(Id originalRiskId, Id clonedRiskId) {
        this.originalRiskId = originalRiskId;
        this.clonedRiskId = clonedRiskId;
    }
    
    public void execute(QueueableContext context) {
        try {
            // Call the Flow for this single Risk
            callCloneChildrenFlow(originalRiskId, clonedRiskId);
            System.debug('Successfully cloned children for Risk: ' + clonedRiskId);
            
        } catch(Exception e) {
            System.debug('Error cloning Risk ' + clonedRiskId + ': ' + e.getMessage());
            createErrorLog(originalRiskId, clonedRiskId, e.getMessage());
        }
    }
    
    private void callCloneChildrenFlow(Id origId, Id cloneId) {
        Map<String, Object> flowInputs = new Map<String, Object>();
        flowInputs.put('originalRiskId', origId);
        flowInputs.put('clonedRiskId', cloneId);
        
        Flow.Interview.Clone_Risk_Children cloneFlow = 
            new Flow.Interview.Clone_Risk_Children(flowInputs);
        cloneFlow.start();
    }
    
    private void createErrorLog(Id origId, Id cloneId, String error) {
        // Your error logging logic here
        System.debug('Error: ' + error + ' for Original: ' + origId + ', Clone: ' + cloneId);
    }
} */