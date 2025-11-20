trigger CalculateNetworkDaysTrigger on Case (before insert, before update) {
    for (Case record : Trigger.new) {
        if (record.Tanggal_Pengaduan_Regulator__c != null) {
            // Determine the end date
            Date endDate = (record.Status == 'Closed' && record.ClosedDate != null)
                ? record.ClosedDate.date() // Convert Datetime to Date
                : Date.today();

            // Calculate the network days
            record.Menghitung_SLA_Regulator2__c = NetworkDaysCalculator.calculateNetworkDays(record.Tanggal_Pengaduan_Regulator__c, endDate);
        }
    }
}