public class NetworkDaysSLARegulatorCalculator {
    public static Integer calculateNetworkDays(Date startDate, Date endDate) {
        if (startDate == null || endDate == null || startDate > endDate) {
            System.debug('Invalid dates: Start Date = ' + startDate + ', End Date = ' + endDate);
            return null; // Return null if dates are invalid or missing
        }

        // Fetch holidays between startDate and endDate
        Set<Date> holidays = getHolidaysBetween(startDate, endDate);
        Integer networkDays = 0;

        System.debug('Start Date: ' + startDate);
        System.debug('End Date: ' + endDate);
        System.debug('Holidays: ' + holidays);

        // Loop through dates starting from startDate + 1
        for (Date currentDate = startDate.addDays(1); currentDate <= endDate; currentDate = currentDate.addDays(1)) {
            System.debug('Processing Date: ' + currentDate);
            if (!isWeekend(currentDate) && !holidays.contains(currentDate)) {
                networkDays++;
                System.debug('Included Date: ' + currentDate);
            } else {
                System.debug('Excluded Date: ' + currentDate);
            }
        }

        System.debug('Total Network Days: ' + networkDays);
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
        System.debug('Fetched Holidays: ' + holidays);
        return holidays;
    }

    private static Boolean isWeekend(Date inputDate) {
        Datetime dt = Datetime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
        Integer dayOfWeek = Integer.valueOf(dt.format('u')); // 1 (Monday) to 7 (Sunday)
        Boolean isWeekend = (dayOfWeek == 6 || dayOfWeek == 7); // Saturday or Sunday
        System.debug('Date: ' + inputDate + ', Day of Week: ' + dayOfWeek + ', Is Weekend: ' + isWeekend);
        return isWeekend;
    }
}