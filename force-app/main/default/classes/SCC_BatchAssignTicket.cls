public class SCC_BatchAssignTicket implements Database.Batchable<sObject> {
    public List<Id> ticketIds { get; private set; }
    public Id ownerId { get; private set; }

    public SCC_BatchAssignTicket(List<Id> ticketIds, Id ownerId) {
        this.ticketIds = ticketIds;
        this.ownerId = ownerId;
    }

    public database.QueryLocator start(database.BatchableContext BC) {
        String query = 'SELECT Id, OwnerId FROM Case WHERE Id IN :ticketIds';
        return Database.getQueryLocator(query);
    }

    public void execute(database.BatchableContext BC, List<Case> caseList) {
        List<Case> casesToUpdate = new List<Case>();

        for (Case c : caseList) {
            c.OwnerId = ownerId;
            casesToUpdate.add(c);
        }

        try {
            update casesToUpdate;
        } catch (Exception e) {
            System.debug(e);
        }
    }

    public void finish(database.BatchableContext BC) {
        System.debug('SCC_BatchAssignTicket Complete');
    }
}