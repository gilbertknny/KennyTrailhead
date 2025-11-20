public class DueDatePICCalculator {
    public static Date calculateDueDate(Date startDate, Integer numNetworkDays, Set<Date> holidays) {
        if (startDate == null || numNetworkDays == null || numNetworkDays <= 0) {
            return null; // Return null if input is invalid
        }

        Date currentDate = startDate.addDays(1); // Start counting from the next day
        Integer networkDaysCounted = 0;

        while (networkDaysCounted < numNetworkDays) {
            // Check if the current date is a working day
            if (!isWeekend(currentDate) && !holidays.contains(currentDate)) {
                networkDaysCounted++;
            }
            if (networkDaysCounted < numNetworkDays) {
                currentDate = currentDate.addDays(1); // Move to the next day
            }
        }

        return currentDate; // Return the final due date
    }

    private static Boolean isWeekend(Date inputDate) {
        // Check if the date falls on a weekend
        Datetime dateTimeValue = Datetime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
        Integer dayOfWeek = Integer.valueOf(dateTimeValue.format('u')); // 1 (Monday) to 7 (Sunday)
        return dayOfWeek == 6 || dayOfWeek == 7; // Saturday or Sunday
    }
}