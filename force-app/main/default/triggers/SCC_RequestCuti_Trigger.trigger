trigger SCC_RequestCuti_Trigger on Request_Leave__c (before insert,after insert,before update,after update) {
    TriggerHandler th = new SCC_RequestCuti_Handler();
    th.run();
}