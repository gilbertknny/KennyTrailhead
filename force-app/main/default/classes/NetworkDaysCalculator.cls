public class NetworkDaysCalculator {
    public static Integer calculateNetworkDays(Date startDate, Date endDate) {
        if (startDate == null || endDate == null || startDate > endDate) {
            return 0; // Return 0 for invalid inputs
        }

        // Fetch holidays between startDate and endDate
        Set<Date> holidays = getHolidaysBetween(startDate, endDate);
        System.debug('Fetched Holidays: ' + holidays);

        Integer networkDays = 0;

        // Start from the day *after* the start date
        for (Date currentDate = startDate.addDays(1); currentDate <= endDate; currentDate = currentDate.addDays(1)) {
            Boolean isHoliday = holidays.contains(currentDate);
            Boolean isWeekend = isWeekend(currentDate);

            // Log for debugging
            System.debug('Processing Date: ' + currentDate + ', Is Weekend: ' + isWeekend + ', Is Holiday: ' + isHoliday);

            if (!isWeekend && !isHoliday) {
                networkDays++;
            }
        }

        System.debug('Total Network Days (Excluding Start Date): ' + networkDays);
        return networkDays;
    }

    private static Set<Date> getHolidaysBetween(Date startDate, Date endDate) {
        List<Holiday> holidayList = [
            SELECT ActivityDate FROM Holiday 
            WHERE ActivityDate >= :startDate AND ActivityDate <= :endDate
        ];
        Set<Date> holidays = new Set<Date>();
        for (Holiday h : holidayList) {
            holidays.add(h.ActivityDate);
        }
        return holidays;
    }

    private static Boolean isWeekend(Date inputDate) {
        Integer dayOfWeek = inputDate.toStartOfWeek().daysBetween(inputDate) + 1; // 1 (Sunday) to 7 (Saturday)
        return dayOfWeek == 1 || dayOfWeek == 7; // Sunday or Saturday
    }
}