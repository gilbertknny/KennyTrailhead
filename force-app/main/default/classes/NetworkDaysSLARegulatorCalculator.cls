public with sharing class NetworkDaysSLARegulatorCalculator {
    public static Integer calculateNetworkDays(Date startDate, Date endDate) {
        if (startDate == null || endDate == null || startDate > endDate) {
            return null; // Return null if dates are invalid or missing
        }

        // Fetch holidays between startDate and endDate
        Set<Date> holidays = getHolidaysBetween(startDate, endDate);
        Integer networkDays = 0;

        // Loop through dates starting from startDate + 1
        for (Date currentDate = startDate.addDays(1); currentDate <= endDate; currentDate = currentDate.addDays(1)) {
            System.debug('Processing Date: ' + currentDate);
            if (!isWeekend(currentDate) && !holidays.contains(currentDate)) {
                networkDays++;
            } 
        }

        return networkDays;
    }

    private static Set<Date> getHolidaysBetween(Date startDate, Date endDate) {
        // Using WITH USER_MODE to automatically enforce CRUD and FLS
        List<Holiday> holidayList = [
            SELECT ActivityDate FROM Holiday 
            WHERE ActivityDate >= :startDate AND ActivityDate <= :endDate
            WITH USER_MODE
        ];

        Set<Date> holidays = new Set<Date>();
        for (Holiday h : holidayList) {
            holidays.add(h.ActivityDate);
        }

        return holidays;
    }

    private static Boolean isWeekend(Date inputDate) {
        Datetime dt = Datetime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
        Integer dayOfWeek = Integer.valueOf(dt.format('u')); // 1 (Monday) to 7 (Sunday)
        Boolean isWeekend = (dayOfWeek == 6 || dayOfWeek == 7); // Saturday or Sunday

        return isWeekend;
    }
}