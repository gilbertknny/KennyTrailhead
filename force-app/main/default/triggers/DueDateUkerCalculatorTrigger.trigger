trigger DueDateUkerCalculatorTrigger on Case (before insert, before update) {
    // Fetch all holidays for efficient calculation
    Set<Date> holidays = new Set<Date>();
    for (Holiday h : [SELECT ActivityDate FROM Holiday]) {
        holidays.add(h.ActivityDate);
    }

    for (Case record : Trigger.new) {
        if (record.Tanggal_Surat_Keluar_ke_Uker__c != null && 
            record.Jumlah_hari_SLA_Regulator__c != null) {
            
            record.Due_Date_Uker__c = DueDateUkerCalculator.calculateDueDate(
                record.Tanggal_Surat_Keluar_ke_Uker__c,
                Integer.valueOf(record.Jumlah_hari_SLA_Regulator__c),
                holidays
            );
        } else {
            record.Due_Date_Uker__c = null; // Set null if prerequisites are missing
        }
    }
}