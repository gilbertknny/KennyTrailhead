global class SCC_DeleteOldErrorLogsBatch implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM Error_Log__c WHERE CreatedDate < LAST_N_DAYS:7';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Error_Log__c> scope) {
        Database.delete(scope);
    }

    global void finish(Database.BatchableContext BC) {
    }
}