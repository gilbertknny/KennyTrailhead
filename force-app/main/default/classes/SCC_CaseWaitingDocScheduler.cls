/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 16-04-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_CaseWaitingDocScheduler implements Schedulable {
    // Define the Business Hours name as a static final variable
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final Integer BATCH_SIZE = 50;

    public void execute(SchedulableContext SC) {
        // Get the Business Hours ID for "Branch User"
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1].Id;
        
        // Get the current time
        Datetime now = Datetime.now();
        
        // Check if the current time is within business hours
        Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, now);
        
        if (isBusinessDay) {
            // Menjalankan batch untuk menutup kasus yang menunggu dokumen
            SCC_CloseWaitingDocumentCasesBatch closeBatch = new SCC_CloseWaitingDocumentCasesBatch();
            Database.executeBatch(closeBatch, BATCH_SIZE); 
        } else {
            // Log a message indicating that it is not a business day
            System.debug('Today is not a business day according to "' + BUSINESS_HOURS_NAME + '" Business Hours. Batch job for closing waiting document cases is skipped.');
        }
    }
}