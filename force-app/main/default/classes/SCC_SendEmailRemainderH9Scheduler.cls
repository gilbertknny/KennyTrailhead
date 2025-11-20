/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 19-03-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_SendEmailRemainderH9Scheduler implements Schedulable {
    // Define the Business Hours name as a static final variable
    private static final String BUSINESS_HOURS_NAME = 'Branch User';
    private static final Integer BATCH_SIZE = 50;

    public void execute(SchedulableContext SC) {
        // Get the Business Hours ID for "Branch User"
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1].Id;
        
        // Get the current time
        Datetime now = Datetime.now();
        
        // Check if the current time is within business hours
        Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, now);
        
        if (isBusinessDay) {
            // Menjalankan batch untuk mengirim email reminder
            SCC_SendEmailRemainderH9Batch emailBatch = new SCC_SendEmailRemainderH9Batch();
            Database.executeBatch(emailBatch, BATCH_SIZE);
        } else {
            // Log a message indicating that it is not a business day
            System.debug('Today is not a business day according to "' + BUSINESS_HOURS_NAME + '" Business Hours. Batch job for sending email reminders is skipped.');
        }
    }
}