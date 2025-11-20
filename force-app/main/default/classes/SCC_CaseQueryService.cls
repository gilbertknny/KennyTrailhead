/**
 * @description       : Service class for querying cases over SLA
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-28-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 **/
public class SCC_CaseQueryService {
    
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final Integer BUSINESS_DAYS_AGO = 11;
    private static Datetime cachedSLANotificationThreshold;
    
    /**
     * Get cases that are over SLA and need email notification
     */
    public static List<Case> getCasesOverSLA() {
        Datetime slaThreshold = getSLANotificationThreshold();
                
        System.debug(LoggingLevel.DEBUG, 'SLA Threshold for notification: ' + slaThreshold);

        return [
            SELECT Id, CreatedDate, SCC_Email__c, CaseNumber, Status, Account.Name, 
                   isTotalSLAViolated__c, SCC_Sent_Email_Perpanjangan_SLA__c
            FROM Case 
            WHERE (Status = 'Escalated' OR Status = 'Working')
            AND SCC_Email__c != NULL
            AND SCC_Sent_Email_Perpanjangan_SLA__c = false 
            AND (
                (CreatedDate > :slaThreshold AND isTotalSLAViolated__c = true)
                OR CreatedDate <= :slaThreshold
            )
            LIMIT 5000 // Add limit to prevent query timeout
        ];
    }

    /**
     * Get SLA notification threshold with caching
     */
    public static Datetime getSLANotificationThreshold() {
        if (cachedSLANotificationThreshold != null) {
            return cachedSLANotificationThreshold;
        }
        
        BusinessHours userBusinessHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = :BUSINESS_HOURS_NAME 
            LIMIT 1
        ];

        Datetime tenDaysAgo = calculateBusinessDaysAgo(userBusinessHours.Id, BUSINESS_DAYS_AGO);  
        DateTime tenDaysAgoAtEndOfDay = DateTime.newInstance(tenDaysAgo.date(), Time.newInstance(23, 59, 0, 0));  
        DateTime tenDaysAgoAtEndOfDayPlus7Hours = tenDaysAgoAtEndOfDay.addHours(7);
        
        cachedSLANotificationThreshold = tenDaysAgoAtEndOfDayPlus7Hours;
        return cachedSLANotificationThreshold;
    }

    /**
     * Helper to calculate business days ago - optimized
     */
    public static Datetime calculateBusinessDaysAgo(Id businessHoursId, Integer businessDays) {
        if (businessDays <= 0) return System.now();
        
        Datetime resultTime = System.now();
        Integer daysSubtracted = 0;
        
        // Optimize by subtracting larger chunks first
        while (daysSubtracted < businessDays) {
            Datetime checkTime = resultTime.addDays(-1);
            
            // Check multiple days at once if possible
            if (BusinessHours.isWithin(businessHoursId, checkTime)) {
                daysSubtracted++;
                resultTime = checkTime;
            } else {
                // If not business day, just move back one day
                resultTime = checkTime;
            }
        }
        return resultTime;
    }

    /**
     * Clear cache - useful for testing
     */
    public static void clearCache() {
        cachedSLANotificationThreshold = null;
    }
}