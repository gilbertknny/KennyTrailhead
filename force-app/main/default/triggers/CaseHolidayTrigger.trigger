trigger CaseHolidayTrigger on Case (before insert, before update) {
/*
    // Fetch the default Business Hours ID
    BusinessHours defaultBusinessHours = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];

    // Get all holidays from Salesforce
    Set<Date> holidayDates = new Set<Date>();
    for (Holiday h : [SELECT ActivityDate, IsRecurrence, RecurrenceType, RecurrenceDayOfWeekMask FROM Holiday]) {
        if (h.IsRecurrence) {
            if (h.RecurrenceType == 'RecursYearly') {
                holidayDates.add(Date.newInstance(System.today().year(), h.ActivityDate.month(), h.ActivityDate.day()));
            } else if (h.RecurrenceType == 'RecursWeekly' && h.RecurrenceDayOfWeekMask != null) {
                for (Integer i = 0; i < 7; i++) {
                    if ((h.RecurrenceDayOfWeekMask & (1 << i)) > 0) {
                        Date nextHoliday = CaseHolidayHelper.getNextRecurringDay(i + 1);
                        holidayDates.add(nextHoliday);
                    }
                }
            }
        } else {
            holidayDates.add(h.ActivityDate);
        }
    }

    for (Case c : Trigger.new) {
        if (String.isNotBlank(c.SCC_Call_Type__c)) {
            DateTime startDate = c.CreatedDate;
            DateTime endDate = c.IsClosed ? c.ClosedDate : System.now();

            System.debug('Processing Case ID: ' + c.Id + ', Start Date: ' + startDate + ', End Date: ' + endDate);

            // Calculate total calendar hours
            Long totalMillis = endDate.getTime() - startDate.getTime();
            Integer totalHours = (Integer)(totalMillis / (1000 * 60 * 60));

            // Calculate business hours using Salesforce Business Hours
            Long businessMillis = BusinessHours.diff(defaultBusinessHours.Id, startDate, endDate);
            Integer businessHours = (businessMillis != null) ? (Integer)(businessMillis / (1000 * 60 * 60)) : 0;

            // Calculate non-business hours
            Integer nonBusinessHours = totalHours - businessHours;

            // Count the number of holidays within the date range
            Integer holidayCount = CaseHolidayHelper.countHolidays(startDate.date(), endDate.date(), holidayDates);

            System.debug('Calculated Holiday Count for Case ID ' + c.Id + ': ' + holidayCount);

            c.Holiday__c = holidayCount;
        }
    }
*/
}