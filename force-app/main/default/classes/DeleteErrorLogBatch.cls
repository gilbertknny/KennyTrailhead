global class DeleteErrorLogBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id FROM Error_Log__c WHERE CreatedDate <= 2025-01-01T00:14:07.000+0000
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Error_Log__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        system.debug('deleted record successsss'+[SELECT Id FROM Error_Log__c WHERE CreatedDate <= 2025-01-01T00:14:07.000+0000]);
    }
}