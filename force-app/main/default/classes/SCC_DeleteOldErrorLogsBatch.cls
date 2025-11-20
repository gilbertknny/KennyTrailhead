global class SCC_DeleteOldErrorLogsBatch implements Database.Batchable<SObject> {

    global database.QueryLocator start(database.BatchableContext BC) {
        String query = 'SELECT Id FROM Error_Log__c WHERE CreatedDate < LAST_N_DAYS:7';
        return Database.getQueryLocator(query);
    }

    global void execute(database.BatchableContext BC, List<Error_Log__c> scope) {
        Database.delete(scope);
    }

    global void finish(database.BatchableContext BC) {
    }
}