trigger DueDatePICCalculatorTrigger on Case (before insert, before update) {
    // Fetch all holidays for efficient calculation
    Set<Date> holidays = new Set<Date>();
    for (Holiday h : [SELECT ActivityDate FROM Holiday]) {
        holidays.add(h.ActivityDate);
    }

    for (Case record : Trigger.new) {
        if (record.Tanggal_Pengaduan_Regulator__c != null && 
            record.Jumlah_hari_SLA_Regulator__c != null) {
            
            record.Due_Date_PIC__c = DueDatePICCalculator.calculateDueDate(
                record.Tanggal_Pengaduan_Regulator__c,
                Integer.valueOf(record.Jumlah_hari_SLA_Regulator__c),
                holidays
            );
        } else {
            record.Due_Date_PIC__c = null; // Set null if prerequisites are missing
        }
    }
}