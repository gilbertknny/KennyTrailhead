public class DueDateUkerCalculator {
    public static Date calculateDueDate(Date startDate, Integer networkDays, Set<Date> holidays) {
        if (startDate == null || networkDays == null || networkDays <= 0) {
            return null; // Return null for invalid inputs
        }

        Date currentDate = startDate.addDays(1); // Start from the day after startDate
        Integer validDaysCount = 0;

        while (validDaysCount < networkDays) {
            if (!isWeekend(currentDate) && !holidays.contains(currentDate)) {
                validDaysCount++; // Count valid network day
            }
            currentDate = currentDate.addDays(1); // Move to the next day
        }

        return currentDate.addDays(-1); // Return the last valid day
    }

    private static Boolean isWeekend(Date inputDate) {
        Integer dayOfWeek = inputDate.toStartOfWeek().daysBetween(inputDate) + 1; // 1 (Sunday) to 7 (Saturday)
        return dayOfWeek == 1 || dayOfWeek == 7; // Sunday or Saturday
    }
}