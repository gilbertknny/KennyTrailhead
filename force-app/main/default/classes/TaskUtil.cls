public with sharing class TaskUtil {
    public static String getTaskPriority(String leadState) {
        // Sample Jimmy untuk Full 100% Coverage
        // Validate input
        if(String.isBlank(leadState) || leadState.length() > 2) {
            return null;
        }

        String taskPriority;
        if(leadState == 'CA') {
            taskPriority = 'High';
        } else {
            taskPriority = 'Normal';
        }
        return taskPriority;
    }
}