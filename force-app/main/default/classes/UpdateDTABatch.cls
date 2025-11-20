global class UpdateDTABatch implements Database.Batchable<SObject> {

    /*  Database.executeBatch(new UpdateDTABatch(), 1);
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id FROM Case WHERE Response_Time_Minutes_v2__c < 0 AND FromSosmed__c = TRUE AND ID = '500MR000004mD8mYAE'
        ]);
    }*/
    
    // Database.executeBatch(new UpdateDTABatch('SELECT Id FROM Case WHERE Response_Time_Minutes_v2__c < 0 AND FromSosmed__c = TRUE AND ID = \'500MR000004mDlUYAU\''), 1);
    public String Query;
    public UpdateDTABatch(String q) {
        this.query = q;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Case> scope) {
        Set<Id> caseIds = new Set<Id>();
        for (Case c : scope) {
            caseIds.add(c.Id);
        }

        List<AggregateResult> earliestPostsAgg = [
            SELECT SproutSocialApp__ParentId__c, MIN(CreatedDate) minDate
            FROM SproutSocialApp__Sprout_Social_Post__c 
            WHERE SproutSocialApp__ParentId__c IN :caseIds AND SproutSocialApp__IsOutbound__c = TRUE
            GROUP BY SproutSocialApp__ParentId__c 
        ];

        Map<Id, DateTime> caseToMinDateMap = new Map<Id, DateTime>();
        for (AggregateResult ar : earliestPostsAgg) {
            caseToMinDateMap.put((Id)ar.get('SproutSocialApp__ParentId__c'), (DateTime)ar.get('minDate'));
        }
        
        List<Case> casesToUpdate = new List<Case>();
        for (Case c : scope) {
            if (caseToMinDateMap.containsKey(c.Id)) {
                c.Date_Time_Answer__c = caseToMinDateMap.get(c.Id);
                casesToUpdate.add(c);
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch complete.');
    }
}