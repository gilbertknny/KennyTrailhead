/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 30-10-2025
 * @last modified by  : Christian Vieri
**/
public class SCC_SendEmailNotificationOverSLA_Sch implements Schedulable {
    // Define the Business Hours name as a static final variable
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final Integer BATCH_SIZE = 5;

    public void execute(SchedulableContext SC) {
        // Get the Business Hours ID for "Branch User"
        Id businessHoursId = [SELECT Id FROM BusinessHours WHERE Name = :BUSINESS_HOURS_NAME LIMIT 1].Id;
        
        // Get the current time
        //Datetime now = Datetime.now();

        
        Date today = Date.today();
        system.debug('today: ' + today);
        Time noon = Time.newInstance(12, 0, 0, 0);
        system.debug('noon: ' + noon);

        // bikin jam 12 siang 
        Datetime now = DateTime.newInstanceGMT(today, noon).addHours(-7);
        system.debug('now: ' + now);
       
        // Check if the current time is within business hours
        Boolean isBusinessDay = BusinessHours.isWithin(businessHoursId, now);
        system.debug('isbusiness day: ' + isBusinessDay);
        
        if (isBusinessDay) {
            system.debug('masuk if');
            // Menjalankan batch untuk mengirim email reminder dengan batch size 10
            SCC_SendEmailNotificationOverSLA emailBatch = new SCC_SendEmailNotificationOverSLA();
            Database.executeBatch(emailBatch, BATCH_SIZE);
        } else {
            // Log a message indicating that it is not a business day
            System.debug('Today is not a business day according to "' + BUSINESS_HOURS_NAME + '" Business Hours. Batch job for sending email reminders is skipped.');
        }
    }
}