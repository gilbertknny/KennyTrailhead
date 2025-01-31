public class SCC_BristarSummary implements Database.Batchable<SObject>, Database.Stateful {
    private Date processDate2;
    private Date processDate1;
    private String lmDate;
    private String batchRunIdentifier;
    private Integer excute;
    private String conditions;
    private Set<Date> uniqueDates = new Set<Date>();
    private static final Integer CHUNK_SIZE = 10000;
    
    // Stateful map to track cumulative summary across batch chunks
    private Map<String, Bristar_Summary__c> cumulativeSummaryMap = new Map<String, Bristar_Summary__c>();
    
    // Constructor to allow date to be passed in
    public SCC_BristarSummary(Date processDate1, Date processDate2, Integer excute) {
        this.processDate2 = (processDate2 == null) ? Date.today().addDays(-1) : processDate2;
        this.processDate1 = (processDate1 == null) ? Date.today().addDays(-1) : processDate1;
        System.debug('processDate1 :'+processDate1);
        // Generate a unique batch run identifier for this entire scheduler execution
        this.batchRunIdentifier = String.valueOf(System.now().getTime());
        if(excute == null){
            List<AggregateResult> results = [SELECT Date__c FROM case WHERE LastModifiedDate = YESTERDAY AND ((Area__c = 'KP00' AND Cost_Center__c != null) OR (Area__c != 'KP00' AND Region__c != null AND Main_Branch__c != null AND Branch_Code__c != null)) AND Status IN ('New','Waiting Document','Working','Escalated','Returned','Closed') GROUP BY Date__c];

            // Populate the sets with unique values from the query results
            for (AggregateResult record : results) {
                this.uniqueDates.add((Date)record.get('Date__c'));
            }
            System.debug('uniqueDates :'+uniqueDates);
            // Construct the conditions string with dynamic IN clauses
            this.conditions = 
            ' AND Date__c IN :uniqueDates';

        }else{
            this.conditions = ' AND Date__c <= :processDate2 AND Date__c >= :processDate1';
        }
    }

    // Batch start method - define the query to retrieve cases
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        String query = 'SELECT ' +
            'Id, Area__c, Date__c, IsClosed__c, Cost_Center__c, ' +
            'Status, Region_Code__c, Region_Description__c, Main_Branch__c, ' +
            'Main_Branch_Description__c, Branch_Code__c, ' +
            'Within_Target_SLA__c, Branch_Unit_Name__c, Cost_Center_Description__c ' +
            'FROM Case ' +
            'WHERE Status IN (\'New\', \'Waiting Document\', \'Working\', \'Escalated\', \'Returned\',\'Closed\') ' +
            ''+conditions+'';
        return Database.getQueryLocator(query);
    }
    
    // Batch execute method - process cases in batches
    public void execute(Database.BatchableContext BC, List<Case> scope) {
        // Prepare map to aggregate summary data for this batch chunk
        Map<String, Bristar_Summary__c> batchSummaryMap = new Map<String, Bristar_Summary__c>();
        
        // Process each case in the current batch
        for (Case cs : scope) {
            // Generate unique external ID
            String externalID = generateExternalIDBristar(cs);
            
            // Initialize or get existing summary record for this batch chunk
            Bristar_Summary__c batchSummary = batchSummaryMap.get(externalID);
            if (batchSummary == null) {
                batchSummary = new Bristar_Summary__c(
                    External_ID__c = externalID,
                    Date__c = cs.Date__c,
                    area__c = cs.Area__c,
                    branch__c = cs.Branch_Code__c,
                    mainBranch__c = cs.Main_Branch__c,
                    region__c = cs.Region_Code__c,
                    costCenter__c = cs.Cost_Center__c,
                    branchDesc__c = cs.Branch_Unit_Name__c,
                    mainBranchDesc__c = cs.Main_Branch_Description__c,
                    regionDesc__c = cs.Region_Description__c,
                    costCenterDesc__c = cs.Cost_Center_Description__c,
                    closedTicket__c = 0,
                    openTicket__c = 0,
                    onSla__c = 0,
                    overSla__c = 0,
                    onSlaOpen__c = 0,
                    onSlaClosed__c = 0,
                    overSlaOpen__c = 0,
                    overSlaClosed__c = 0
                );
            }
            
            // Increment ticket counters
            if (cs.IsClosed__c) {
                batchSummary.closedTicket__c++;
            } else {
                batchSummary.openTicket__c++;
            }
            
            // SLA Tracking
            if (cs.Within_Target_SLA__c == 'Sesuai SLA') {
                batchSummary.onSla__c++;
                if (cs.IsClosed__c) {
                    batchSummary.onSlaClosed__c++;
                } else {
                    batchSummary.onSlaOpen__c++;
                }
            } else if (cs.Within_Target_SLA__c == 'Melebihi SLA') {
                batchSummary.overSla__c++;
                if (cs.IsClosed__c) {
                    batchSummary.overSlaClosed__c++;
                } else {
                    batchSummary.overSlaOpen__c++;
                }
            }
            
            // Update batch summary map
            batchSummaryMap.put(externalID, batchSummary);
        }
        
        // Merge batch summary with cumulative summary
        mergeSummaryMaps(batchSummaryMap);
    }
    
    // Helper method to merge batch summary with cumulative summary
    private void mergeSummaryMaps(Map<String, Bristar_Summary__c> batchSummaryMap) {
        for (String externalId : batchSummaryMap.keySet()) {
            Bristar_Summary__c batchSummary = batchSummaryMap.get(externalId);
            
            // Get or create cumulative summary for this external ID
            Bristar_Summary__c cumulativeSummary = cumulativeSummaryMap.get(externalId);
            if (cumulativeSummary == null) {
                cumulativeSummary = batchSummary.clone(false, true, false, false);
            } else {
                // Aggregate counters
                cumulativeSummary.closedTicket__c += batchSummary.closedTicket__c;
                cumulativeSummary.openTicket__c += batchSummary.openTicket__c;
                cumulativeSummary.onSla__c += batchSummary.onSla__c;
                cumulativeSummary.overSla__c += batchSummary.overSla__c;
                cumulativeSummary.onSlaOpen__c += batchSummary.onSlaOpen__c;
                cumulativeSummary.onSlaClosed__c += batchSummary.onSlaClosed__c;
                cumulativeSummary.overSlaOpen__c += batchSummary.overSlaOpen__c;
                cumulativeSummary.overSlaClosed__c += batchSummary.overSlaClosed__c;
            }
            
            // Update cumulative summary map
            cumulativeSummaryMap.put(externalId, cumulativeSummary);
        }
    }
    
    private void performUpsertChunk(List<Bristar_Summary__c> summaryList) {
        if (summaryList.isEmpty()) return;
        
        Database.UpsertResult[] results = Database.upsert(summaryList, Bristar_Summary__c.External_ID__c, false);
        
        // Error handling
        List<String> errorMessages = new List<String>();
        for (Database.UpsertResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    errorMessages.add('Upsert Error: ' + error.getStatusCode() + ' - ' + error.getMessage());
                }
            }
        }
        
        // Log errors if any
        if (!errorMessages.isEmpty()) {
            for (String errorMsg : errorMessages) {
                System.debug(errorMsg);
            }
        }
        
        System.debug('Upsert Chunk Processed: ' + summaryList.size() + ' records');
    }
    
    // Modify the Queueable class to remove static from performUpsertChunk
    public class SummaryUpsertQueue implements Queueable {
        private List<Bristar_Summary__c> recordsToUpsert;
        private Integer startIndex;
        private SCC_BristarSummary parentBatchClass; // Add reference to parent class
    
        // Modify constructors to accept parent class reference
        public SummaryUpsertQueue(List<Bristar_Summary__c> records, SCC_BristarSummary parentClass) {
            this.recordsToUpsert = records;
            this.startIndex = 0;
            this.parentBatchClass = parentClass;
        }
    
        // Constructor for subsequent chunks
        public SummaryUpsertQueue(List<Bristar_Summary__c> records, Integer startIndex, SCC_BristarSummary parentClass) {
            this.recordsToUpsert = records;
            this.startIndex = startIndex;
            this.parentBatchClass = parentClass;
        }
    
        public void execute(QueueableContext context) {
            // Calculate the end index for this chunk
            Integer endIndex = Math.min(startIndex + 10000, recordsToUpsert.size());
            
            // Create a new list to hold the current chunk
            List<Bristar_Summary__c> currentChunk = new List<Bristar_Summary__c>();
            
            // Manually copy the chunk of records
            for (Integer i = startIndex; i < endIndex; i++) {
                currentChunk.add(recordsToUpsert[i]);
            }
            
            // Perform upsert on the current chunk using parent class method
            parentBatchClass.performUpsertChunk(currentChunk);
            
            // If there are more records, enqueue the next chunk
            if (endIndex < recordsToUpsert.size()) {
                System.enqueueJob(new SummaryUpsertQueue(recordsToUpsert, endIndex, parentBatchClass));
            }
        }
    }
    
    // Modify finish method to pass 'this'
    public void finish(Database.BatchableContext BC) {
        if (!cumulativeSummaryMap.isEmpty()) {
            List<Bristar_Summary__c> summaryList = cumulativeSummaryMap.values();
            
            // If the list is large, use a queueable job to process in chunks
            if (summaryList.size() > 10000) {
                System.enqueueJob(new SummaryUpsertQueue(summaryList, this));
            } else {
                // Perform direct upsert for smaller lists
                performUpsertChunk(summaryList);
            }
        }
        
        System.debug('Bristar Summary Batch Process Completed');
    }
    
    // Helper method to generate external ID
    public static String generateExternalIDBristar(Case cs) {
        String area = cs.Area__c != null ? cs.Area__c : '-';
        String costCenter = cs.Cost_Center__c != null ? cs.Cost_Center__c : '-';
        String region = cs.Region_Code__c != null ? cs.Region_Code__c : '-';
        String mainBranch = cs.Main_Branch__c != null ? cs.Main_Branch__c : '-';
        String branch = cs.Branch_Code__c != null ? cs.Branch_Code__c : '-';
        String dtcs = cs.Date__c != null ? String.valueOf(cs.Date__c) : '-';
        
        return area + '-' + costCenter + '-' + region + '-' + mainBranch + '-' + branch + '-' + dtcs;
    }
}