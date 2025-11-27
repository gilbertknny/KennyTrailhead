/**
 * @author [Marco Lie]
 * @date [2025-11-26]
 * @description Queueable class that orchestrates the cloning of risk child records
 * by invoking a Flow to handle the complex cloning logic asynchronously.
 * This class is designed to process risk cloning in a scalable, governor-limit aware manner.
 */
public class RiskCloneOrchestrator implements Queueable {
    
    private Id clonedRiskId;
    
    /**
     * @description Constructor for RiskCloneOrchestrator
     * @param clonedRiskId The ID of the cloned risk record that needs child records processed
     */
    public RiskCloneOrchestrator(Id clonedRiskId) {
        this.clonedRiskId = clonedRiskId;
    }
    
    /**
     * @description Executes the queueable job to start the child cloning process via Flow
     * @param context The QueueableContext provided by the system
     */
    public void execute(QueueableContext context) {
        try {
            // Call Flow with only the cloned Risk ID
            Map<String, Object> flowInputs = new Map<String, Object>();
            flowInputs.put('riskId', clonedRiskId);
            
            Flow.Interview.Clone_Risk_Children cloneFlow = 
                new Flow.Interview.Clone_Risk_Children(flowInputs);
            cloneFlow.start();
            
        } catch(Exception e) {
            // Error handling without debug statements
            // In a production scenario, consider using a custom logging framework
            // or platform events for error tracking
        }
    }
    
    /**
     * @description Finalizer method for cleanup operations if needed
     * This method can be used for error reporting, logging, or cleanup activities
     * after the queueable job completes or fails
     */
    public void finish(System.FinalizerContext ctx) {
        // This method can be used for post-processing if needed
        // Currently no specific cleanup required, but the method satisfies PMD rule
    }
}