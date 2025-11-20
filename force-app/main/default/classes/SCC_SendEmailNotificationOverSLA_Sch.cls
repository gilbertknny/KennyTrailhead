/**
 * @description       : Scheduler for SLA email notifications
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class SCC_SendEmailNotificationOverSLA_Sch implements Schedulable {
    // Define the Business Hours name as a static final variable
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final Integer BATCH_SIZE = 5; // Increased from 1 for better performance

    public void execute(SchedulableContext SC) {
        try {
            // Get the Business Hours ID
            List<BusinessHours> businessHoursList = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1];
            
            if (businessHoursList.isEmpty()) {
                System.debug('Business Hours not found: ' + BUSINESS_HOURS_NAME);
                return;
            }
            
            Id businessHoursId = businessHoursList[0].Id;
            
            // Get the current time adjusted for business hours check
            Date today = Date.today();
            Time noon = Time.newInstance(12, 0, 0, 0);
            Datetime now = DateTime.newInstanceGMT(today, noon).addHours(-7);
           
            // Check if the current time is within business hours
            Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, now);
            
            if (isBusinessDay) {
                System.debug('Business hours detected, starting batch job...');
                SCC_SendEmailNotificationOverSLA.runBatch();
            } else {
                // Log a message indicating that it is not a business day
                System.debug('Today is not a business day according to "' + BUSINESS_HOURS_NAME + '" Business Hours. Batch job for sending email reminders is skipped.');
            }
        } catch (Exception e) {
            System.debug('Error in scheduler execution: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        }
    }
    
    /**
     * Method to schedule the job
     */
    public static void scheduleJob() {
        String jobName = 'SCC_SendEmailNotificationOverSLA_' + System.now().format('yyyyMMddHHmmss');
        String cronExpression = '0 0 22 * * ?'; // Run daily at 22:00 PM
        
        try {
            System.schedule(jobName, cronExpression, new SCC_SendEmailNotificationOverSLA_Sch());
            System.debug('Scheduled job: ' + jobName);
        } catch (Exception e) {
            System.debug('Error scheduling job: ' + e.getMessage());
        }
    }
}