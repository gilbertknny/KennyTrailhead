global class CalculateCaseHolidaysBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private BusinessHours defaultBusinessHours;
    private Set<Date> holidayDates = new Set<Date>();
    private String startDate;
    private String endDate;

    // Constructor to accept date range parameters
    public CalculateCaseHolidaysBatch(String startDate, String endDate) {
        this.startDate = startDate;
        this.endDate = endDate;
        
        // Fetch the default business hours
        defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];

        // Fetch holidays and store them in a set for quick lookup
        for (Holiday h : [SELECT ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfWeekMask 
                          FROM Holiday]) {
            if (h.IsRecurrence) {
                if (h.RecurrenceType == 'RecursYearly') {
                    holidayDates.add(Date.newInstance(System.today().year(), h.ActivityDate.month(), h.ActivityDate.day()));
                } else if (h.RecurrenceType == 'RecursWeekly' && h.RecurrenceDayOfWeekMask != null) {
                    for (Integer i = 0; i < 7; i++) {
                        if ((h.RecurrenceDayOfWeekMask & (1 << i)) > 0) {
                            Date nextHoliday = getNextRecurringDay(i + 1);
                            holidayDates.add(nextHoliday);
                        }
                    }
                }
            } else {
                holidayDates.add(h.ActivityDate);
            }
        }
        System.debug('Loaded Holidays: ' + holidayDates);
    }

// Query cases to process with dynamic date filtering
global Database.QueryLocator start(Database.BatchableContext BC) {
    String query = 'SELECT Id, CreatedDate, ClosedDate, IsClosed, SCC_Call_Type__c, Holiday__c FROM Case WHERE SCC_Call_Type__c != NULL';
    
    if (startDate != null && endDate != null) {
        query += ' AND CreatedDate >= ' + startDate + ' AND CreatedDate <= ' + endDate;
    }
    
    return Database.getQueryLocator(query);
}

    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
        List<Case> casesToUpdate = new List<Case>();

        for (Case c : caseList) {
            DateTime startDateTime = c.CreatedDate;
            DateTime endDateTime = c.IsClosed ? c.ClosedDate : System.now();

            System.debug('Processing Case ID: ' + c.Id + ', Start Date: ' + startDateTime + ', End Date: ' + endDateTime);

            try {
                // Calculate total calendar hours
                Long totalMillis = endDateTime.getTime() - startDateTime.getTime();
                Integer totalHours = (Integer)(totalMillis / (1000 * 60 * 60));

                // Calculate business hours using Salesforce Business Hours
                Long businessMillis = BusinessHours.diff(defaultBusinessHours.Id, startDateTime, endDateTime);
                Integer businessHours = (businessMillis != null) ? (Integer)(businessMillis / (1000 * 60 * 60)) : 0;

                // Calculate non-business hours
                Integer nonBusinessHours = totalHours - businessHours;

                // Count the number of holidays in the given date range
                Integer holidayCount = countHolidays(startDateTime.date(), endDateTime.date());

                System.debug('Calculated Holiday Count for Case ID ' + c.Id + ': ' + holidayCount);

                c.Holiday__c = holidayCount;
                casesToUpdate.add(c);

            } catch (Exception ex) {
                System.debug('Error processing Case ID: ' + c.Id + ', Error: ' + ex.getMessage());
            }
        }

        if (!casesToUpdate.isEmpty()) {
            Database.SaveResult[] results = Database.update(casesToUpdate, false);
            
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()) {
                    for (Database.Error err : results[i].getErrors()) {
                        System.debug('Failed to update Case ID: ' + casesToUpdate[i].Id + ' Error: ' + err.getMessage());
                    }
                }
            }
        }
    }

    // Count the number of holidays in the given date range
    private Integer countHolidays(Date startDate, Date endDate) {
        Integer count = 0;
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            if (holidayDates.contains(d)) {
                count++;
            }
        }
        return count;
    }

    // Calculate next recurring day based on recurrence pattern (handling Sunday = 1 to Saturday = 7)
    private Date getNextRecurringDay(Integer dayOfWeek) {
        Date today = System.today();
        Integer todayDayOfWeek = today.toStartOfWeek().daysBetween(today) + 1; // Monday = 1, Sunday = 7

        // Use Math.mod to handle week cycles correctly
        Integer daysUntilNext = Math.mod(dayOfWeek - todayDayOfWeek + 7, 7);
        return today.addDays(daysUntilNext == 0 ? 7 : daysUntilNext);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch processing complete!');
    }
}