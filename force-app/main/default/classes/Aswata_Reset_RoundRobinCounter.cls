public with sharing class Aswata_Reset_RoundRobinCounter implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Query all master data records that have counters
        List<Master_Data__c> masterList = [
            SELECT Id, Round_Robin_Counter_Branch__c, Round_Robin_Counter_Account__c
            FROM Master_Data__c
            WHERE (Round_Robin_Counter_Branch__c != NULL OR Round_Robin_Counter_Account__c != NULL)
            WITH SECURITY_ENFORCED
        ];

        for (Master_Data__c md : masterList) {
            md.Round_Robin_Counter_Branch__c = 0;
            md.Round_Robin_Counter_Account__c = 0;
        }

        if (Schema.sObjectType.Master_Data__c.isUpdateable()) {
            if (!masterList.isEmpty()) {
                update masterList;
            }
        }
        

        System.debug('✅ Round robin counters reset successfully.');
    }
}