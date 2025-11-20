public class SLSosmedProcessed {
    @Future
    public static void processInBackground(Set<Id> caseIds) {
        for (Id caseId : caseIds) {
            try {
                SLSosmedController.updateCaseTimer(caseId);
            } catch (Exception e) {
                // log error.x
                System.debug('Error processing service level timer: ' + e.getMessage());
            }
        }
    }
}