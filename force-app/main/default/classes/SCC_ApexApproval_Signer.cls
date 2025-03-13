public with sharing class SCC_ApexApproval_Signer {
    @AuraEnabled
    public Integer pageNumber { get; set; }
    @AuraEnabled
    public Integer pageSize { get; set; }
    @AuraEnabled
    public Integer totalRecords { get; set; }
    @AuraEnabled
    public Integer totalPages { get; set; }
    @AuraEnabled
    public Integer permissionNFT { get; set; }
    @AuraEnabled
    public List<Case> caseList { get; set; }
    @AuraEnabled
    public List<Id> allCaseIds { get; set; }

    public SCC_ApexApproval_Signer(Integer pageNum, Integer pageSz) {
        pageNumber = pageNum;
        pageSize = pageSz;
        getCases();
    }

    @AuraEnabled
    public static SCC_ApexApproval_Signer getInstance(Integer pageNumber, Integer pageSize) {
        return new SCC_ApexApproval_Signer(pageNumber, pageSize);
    }

    @AuraEnabled
    public void getCases() {
        try {
           	List<PermissionSetAssignment> listpsa = [SELECT Id FROM PermissionSetAssignment 
                                              	WHERE AssigneeId =:UserInfo.getUserId() 
                                               	AND IsActive = TRUE
                                               	AND PermissionSet.Label IN ('BO Agent NFT','BO Agent Leader','BO Supervisor NFT')];
            permissionNFT = listpsa.size();
            
            Map<Id, Case> allCases = new Map<Id, Case>([SELECT Id FROM Case WHERE Approval_Status__c = 'Waiting for Signer' and SCC_Call_Type__c != null and status = 'Escalated' and SCC_Card_Number__c != null and isclosed__c = false]);
            allCaseIds = new List<Id>(allCases.keySet());
            
            totalRecords = allCaseIds.size();
            totalPages = (Integer)Math.ceil((Decimal)totalRecords / pageSize);

            caseList = [SELECT Id, CaseNumber, SCC_Call_Type__r.Name, SCC_Call_Type_Feature__c, SCC_Card_Number__c, CreatedDate, SCC_Amount__c, Priority, Net_SLA_Saat_Ini__c, Approval_Status__c, Count_Nota__c, SCC_Count_Queuetrans__c, SCC_Call_Type_Feature__r.Name
                        FROM Case 
                        WHERE Approval_Status__c = 'Waiting for Signer' and SCC_Call_Type__c != null and status = 'Escalated' and SCC_Card_Number__c != null and isclosed__c = false
                        ORDER BY CreatedDate
                        LIMIT :pageSize OFFSET :((pageNumber - 1) * pageSize)];
        } catch (Exception e) {
            System.debug('Error in getCases: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public void getNextCases() {
        if (pageNumber < totalPages) {
            pageNumber++;
            getCases();
        }
    }

    @AuraEnabled
    public void getPreviousCases() {
        if (pageNumber > 1) {
            pageNumber--;
            getCases();
        }
    }

    @AuraEnabled
    public static Map<String, Object> getSearchCases(Integer pageNumber, Integer pageSize, String calltype, String noTicket, String tanggalKomplain, String priority, String cekNota) {
        Map<String, Object> result = new Map<String, Object>();
        try {
            String baseQuery = ' FROM Case WHERE Approval_Status__c = \'Waiting for Signer\' and SCC_Call_Type__c != null and SCC_Card_Number__c != null and isclosed__c = false and status = \'Escalated\'';
            List<String> conditions = new List<String>();
            Integer offset = (pageNumber - 1) * pageSize;

            if (!String.isEmpty(calltype)) {
                conditions.add('SCC_Call_Type__r.Name = :calltype');
            }
            if (!String.isEmpty(noTicket)) {
                conditions.add('CaseNumber = :noTicket');
            }
            if (!String.isEmpty(tanggalKomplain)) {
                Date tanggalKomplainDate = Date.valueOf(tanggalKomplain);
                conditions.add('DAY_ONLY(CreatedDate) = :tanggalKomplainDate');
            }
            if (!String.isEmpty(priority)) {
                conditions.add('Priority = :priority');
            }
            if (!String.isEmpty(cekNota)) {
                if (cekNota == 'Ada Nota') {
                    conditions.add('SCC_Count_Queuetrans__c > 0'); 
                }
                else if (cekNota == 'Tidak Ada Nota') { 
                    conditions.add('SCC_Count_Queuetrans__c = 0'); 
                }
            }

            if (conditions.size() > 0) {
                String conditionString = ' AND ' + String.join(conditions, ' AND ');
                baseQuery += conditionString;
            }

            String query = 'SELECT Id, CaseNumber, SCC_Call_Type__r.Name, SCC_Call_Type_Feature__c, SCC_Card_Number__c, CreatedDate, SCC_Amount__c, Priority, Net_SLA_Saat_Ini__c, Approval_Status__c, Count_Nota__c, SCC_Count_Queuetrans__c, SCC_Call_Type_Feature__r.Name' + baseQuery;
            query += ' ORDER BY CreatedDate LIMIT :pageSize OFFSET :offset';

            String queryCount = 'SELECT COUNT()' + baseQuery;

            List<Case> data = Database.query(query);
            Integer totalRecords = Database.countQuery(queryCount);
			
            Map<Id, Case> allCases = new Map<Id, Case>((List<Case>) Database.query(query));
            List<Id> allCaseIds = new List<Id>(allCases.keySet());
            //Integer totalRecords = allCaseIds.size();
            
            result.put('data', data);
            result.put('allCaseIds', allCaseIds);
            result.put('totalRecords', totalRecords);
            result.put('totalPages', (Integer)Math.ceil((Decimal)totalRecords / pageSize));
        } catch (Exception e) {
            System.debug('Error in getSearchCases: ' + e.getMessage());
        }

        return result;
    }

    @AuraEnabled
    public static void approveTickets(List<Id> ticketIds, Id userId) {
        try {
            System.debug('User ID: ' + userId);
            System.debug('Ticket IDs: ' + ticketIds);

            List<Approval.ProcessWorkitemRequest> allReq = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ActorId, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :ticketIds order by CreatedDate ASC];
            Id signerId;
            for (ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkItemId(workItem.Id);
                req.setAction('Approve');
                allReq.add(req);
                //signerId = workItem.ActorId;
            }
            if(allReq.size()>0){
                Approval.ProcessResult[] result =  Approval.process(allReq);
                for(Approval.ProcessResult rs : result){
                    if (!rs.isSuccess()) {
                        System.debug('Error in approving work item: ' + rs.getErrors());
                    }
                }
            }
            
            List<Case> listcasenew = new List<Case>();
            List<Case> casesToUpdate = [SELECT Id, Approval_Status__c, Signer__c FROM Case WHERE Id IN :ticketIds];
            for (Case c : casesToUpdate) {
                c.Approval_Status__c = 'Approved';
                c.Signer__c = userId;
                listcasenew.add(c);
                System.debug('Updating Case ID: ' + c.Id + ' with Signer__c: ' + userId);
            }
            if(listcasenew.size()>0) update listcasenew;
        } catch (Exception e) {
            System.debug('Error in approveTickets: ' + e.getMessage());
        }
    }

    @InvocableMethod(Label='Approve Signer')
    public static List<Result> approvalProcess(List<InputVariable> inputVariable) {
        Result res = new Result();
        List<Result> results = new List<Result>{res};
        Id recordId;
        Id userId;
        String status;
        String ticketNo;

        recordId = inputVariable[0].recordId;
        userId = inputVariable[0].userId;
        status = inputVariable[0].status;
        ticketNo = inputVariable[0].ticketNo;

        String errorMsg = 'Gagal '+status+' Ticket '+ticketNo;
        String successMsg = 'Berhasil '+status+' Ticket '+ticketNo;

        try {
            System.debug('approvalProcess');

            System.debug('User ID: ' + userId);
            System.debug('Ticket IDs: ' + recordId);
            System.debug('Status: ' + status);

            List<Case> casesToUpdate = [SELECT Id, Approval_Status__c, Signer__c FROM Case WHERE Id =:recordId];

            List<ProcessInstanceWorkitem> workItems = [SELECT Id, ActorId, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =:recordId];
            Id signerId;
            for (ProcessInstanceWorkitem workItem : workItems) {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setWorkItemId(workItem.Id);
                req.setAction(status);
                Approval.ProcessResult result = Approval.process(req);

                if (!result.isSuccess()) {
                    results[0].success = false;
                    results[0].message = errorMsg;
                    System.debug(errorMsg + result.getErrors());
                } else {
                    results[0].success = true;
                    results[0].message = successMsg;
                    System.debug(successMsg);
                }
            }
        } catch (Exception e) {
            System.debug('Error in approveTickets: ' + e.getMessage());
        }

        return results;
    }

    public class Result {
        @InvocableVariable public Boolean success;
        @InvocableVariable public String message;
    }

    public class InputVariable {
        @InvocableVariable
        public Id recordId;
        @InvocableVariable
        public Id userId;
        @InvocableVariable
        public String status;
        @InvocableVariable
        public String ticketNo;
    }

    @AuraEnabled
    public static void updateSigner(List<Case> newList, Map<Id,Case> oldMap) {
    
        List<Id> caseUpdate = new List<Id>();
           for(Case c:newList){
            if(c.Approval_Status__c == 'Approved' && oldMap.get(c.Id).Approval_Status__c != 'Approved'){
                caseUpdate.add(c.Id);
    
            }
           }
    
           if(caseUpdate.size() > 0){
            try {
                List<Case> casesToUpdate = [SELECT Id, Approval_Status__c, CreatedBy.Name,CreatedById, Signer__c FROM Case WHERE Id IN :caseUpdate];
                 Id processInstanceId;
                 Id checkerId;
        
                List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId, ActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :caseUpdate];
                system.debug('wo '+workItems);
                system.debug('casesToUpdate '+casesToUpdate);
                if(workItems.size() > 0){
                    for (ProcessInstanceWorkitem workItem : workItems) {
                        System.debug('workItem');
                            processInstanceId = workItem.ProcessInstanceId;
                    }
    
                    for(ProcessInstanceStep pi : [ SELECT Id, ActorId FROM ProcessInstanceStep
                                                   WHERE ProcessInstanceId =:processInstanceId AND StepStatus = 'Approved'
                    ]){
    
                        checkerId = pi.ActorId;
                    }
    
    
                    for (Case c : newList) {
                            c.Signer__c = UserInfo.getUserId();
                    }
    
                }
            } catch (Exception e) {
                System.debug('Error in approveTickets: ' + e.getMessage());
            }
       }
    }
}