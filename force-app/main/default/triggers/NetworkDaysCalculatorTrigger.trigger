trigger NetworkDaysCalculatorTrigger on Case (before insert, before update) {
    for (Case record : Trigger.new) {
        if (record.Tanggal_Pengaduan_Regulator__c != null) {
            // Determine the end date
            Date endDate = (record.Tanggal_Tanggapan_ke_EMAIL_APPK__c != null)
                ? record.Tanggal_Tanggapan_ke_EMAIL_APPK__c
                : Date.today();

            // Calculate the network days
            record.SLA_Pelaporan2__c = NetworkDaysCalculator.calculateNetworkDays(
                record.Tanggal_Pengaduan_Regulator__c, 
                endDate
            );
        } else {
            record.SLA_Pelaporan2__c = null; // Set to null if start date is null
        }
    }
}