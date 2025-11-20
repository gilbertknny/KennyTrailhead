trigger SCC_RequestCuti_Trigger on Request_Leave__c (before insert,before update,after insert,after update) {
    TriggerHandler th = new SCC_RequestCuti_Handler();
    th.run();
}