/**
 * @description       : Service class for querying cases over SLA
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 30-10-2025
 * @last modified by  : Christian Vieri
 **/
public class SCC_CaseQueryService {
    
    private static final String BUSINESS_HOURS_NAME = System.Label.Business_Hour;
    private static final Integer BUSINESS_DAYS_AGO = 11;
    
    /**
     * Get cases that are over SLA and need email notification
     */
    public static List<Case> getCasesOverSLA() {
        BusinessHours userBusinessHours = [
            SELECT Id 
            FROM BusinessHours 
            WHERE Name = :BUSINESS_HOURS_NAME 
            LIMIT 1
        ];

        Datetime tenDaysAgo = calculateBusinessDaysAgo(userBusinessHours.Id, BUSINESS_DAYS_AGO);  
        DateTime tenDaysAgoAtEndOfDay = DateTime.newInstance(tenDaysAgo.date(), Time.newInstance(23, 59, 0, 0));  
        DateTime tenDaysAgoAtEndOfDayPlus7Hours = tenDaysAgoAtEndOfDay.addHours(7);  
                
        System.debug(LoggingLevel.DEBUG, 'tenDaysAgo= ' + tenDaysAgo);
        System.debug(LoggingLevel.DEBUG, 'tenDaysAgoAtEndOfDay= ' + tenDaysAgoAtEndOfDay);
        System.debug(LoggingLevel.DEBUG, 'tenDaysAgoAtEndOfDayPlus7Hours= ' + tenDaysAgoAtEndOfDayPlus7Hours);

        return [
            SELECT Id, CreatedDate, SCC_Email__c, CaseNumber, Status, Account.Name, 
                   isTotalSLAViolated__c, SCC_Sent_Email_Perpanjangan_SLA__c
            FROM Case 
            WHERE (Status = 'Escalated' OR Status = 'Working')
            AND SCC_Email__c != NULL
            AND SCC_Sent_Email_Perpanjangan_SLA__c = false 
            AND (
                (CreatedDate >: tenDaysAgoAtEndOfDayPlus7Hours AND isTotalSLAViolated__c = true)
                OR CreatedDate <=: tenDaysAgoAtEndOfDayPlus7Hours
            )
            Order by CreatedDate Desc
        ];
    }

    /**
     * Helper to calculate business days ago
     */
    public static Datetime calculateBusinessDaysAgo(Id businessHoursId, Integer businessDays) {
        Datetime resultTime = System.now().addHours(-7);
        Integer daysSubtracted = 0;
        while (daysSubtracted < businessDays) {
            resultTime = resultTime.addDays(-1);
            if (BusinessHours.isWithin(businessHoursId, resultTime)) {
                daysSubtracted++;
            }
        }
        return resultTime;
    }
}