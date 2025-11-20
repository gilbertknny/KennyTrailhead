trigger NetworkDaysSLARegulatorCalculatorTrigger on Case (before insert, before update) {
    for (Case record : Trigger.new) {
        if (record.Tanggal_Pengaduan_Regulator__c != null && record.Tanggal_Tanggapan_ke_EMAIL_APPK__c != null) {
            // Calculate Menghitung SLA Regulator if both dates are present
            record.Menghitung_SLA_Regulator2__c = NetworkDaysSLARegulatorCalculator.calculateNetworkDays(
                record.Tanggal_Pengaduan_Regulator__c, 
                record.Tanggal_Tanggapan_ke_EMAIL_APPK__c
            );
        } else {
            record.Menghitung_SLA_Regulator2__c = null; // Set to null if either date is null
        }
    }
}