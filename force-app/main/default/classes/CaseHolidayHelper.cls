public class CaseHolidayHelper {
    // Count the number of holidays within the given date range
    public static Integer countHolidays(Date startDate, Date endDate, Set<Date> holidayDates) {
        Integer count = 0;
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            if (holidayDates.contains(d)) {
                count++;
            }
        }
        return count;
    }

    // Calculate next recurring holiday based on the recurrence pattern
    public static Date getNextRecurringDay(Integer dayOfWeek) {
        Date today = System.today();
        Integer todayDayOfWeek = today.toStartOfWeek().daysBetween(today) + 1; // Monday = 1, Sunday = 7

        // Use Math.mod to handle week cycles correctly
        Integer daysUntilNext = Math.mod(dayOfWeek - todayDayOfWeek + 7, 7);
        return today.addDays(daysUntilNext == 0 ? 7 : daysUntilNext);
    }
}