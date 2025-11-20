public with sharing class SCC_UnassignedTicketController {
    @AuraEnabled
    public static Map<String, Object> getSearchCases(Integer pageNumber, Integer pageSize, String calltype, String noTicket, String tanggalKomplain) { // , String agentId
        Map<String, Object> result = new Map<String, Object>();
        try {
            String queueOnUs = System.Label.queueNameOnUs; 
            String query = 'SELECT Id, CaseNumber, SCC_Call_Type__r.Name, SCC_Fitur__c, SCC_Card_Number__c, CreatedDate, SCC_Amount__c, Status, SCC_Case_Owner__c, Is_Queue__c ' +
               'FROM Case ' +
               'WHERE Status = \'Escalated\' ' +
               'AND Owner.Name LIKE :queueOnUs ' +
               'AND (SCC_Call_Type__r.Send_to_Drone__c = false ' +
               'OR SCC_Call_Type__r.external_id__c IN ('+'\'8812'+'\','+'\'8915\'))';
            
            List<String> conditions = new List<String>();
            if (!String.isEmpty(calltype)) {
                conditions.add('SCC_Call_Type__r.Name = :calltype');
            }
            if (!String.isEmpty(noTicket)) {
                conditions.add('CaseNumber = :noTicket');
            }
            if (!String.isEmpty(tanggalKomplain)) {
                Date tanggalKomplainDate = Date.valueOf(tanggalKomplain);
                conditions.add('DAY_ONLY(CreatedDate) <= :tanggalKomplainDate');
            }
            if (conditions.size() > 0) {
                String conditionString = ' AND ' + String.join(conditions, ' AND ');
                query += conditionString;
            }
            
            Map<Id, Case> allCases = new Map<Id, Case>((List<Case>) Database.query(query + ' ORDER BY CreatedDate LIMIT 40000'));
            List<Id> allCaseIds = new List<Id>(allCases.keySet());
            
            if(pageSize > 40000) pageSize = 40000;
            Integer offset = (pageNumber - 1) * pageSize;
            if (conditions.size() > 0) {
                query += ' ORDER BY CreatedDate DESC LIMIT :pageSize OFFSET :offset';
            }else{
                query += ' ORDER BY CreatedDate LIMIT :pageSize OFFSET :offset';
            }
            
            List<Case> data = Database.query(query);
            Integer totalRecords = allCaseIds.size();
            
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
    public static List<User> getBackOfficeAgents() {
        return [SELECT Id, Name FROM User WHERE Id IN (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'SCC_BO_NFT')];
    } 
    @AuraEnabled
    public static Id assignCasesToAgent(List<String> agentIds, List<String> caseIds) {
        Id batchJobId;
        if (!agentIds.isEmpty()) {
            if (!caseIds.isEmpty()) {
                List<Case> casesToUpdate = new List<Case>();
                Integer agentCounter = 0;
                for (Integer i = 0; i < caseIds.size(); i++) {
                    Case thisCase = new Case();
                    thisCase.Id = caseIds[i];
                    thisCase.OwnerId = agentIds[agentCounter];
                    thisCase.Maker__c = agentIds[agentCounter];
                    thisCase.Assign_Date_NFT__c = DateTime.Now();
                    casesToUpdate.add(thisCase);
                    
                    agentCounter += 1;
                    if (agentCounter == agentIds.size()){
                        agentCounter = 0;
                    }
                }
                
                /*List<Case> casesToUpdate = [SELECT Id, OwnerId, Status FROM Case WHERE Id IN :caseIds];
                
                Integer numCases = caseIds.size() / agentIds.size();
                Integer remainingCases = math.mod(caseIds.size(), agentIds.size());
                
                Integer caseCounter = 0;
                for (Integer i = 0; i < agentIds.size(); i++) {
                    Integer numCasesForAgent = i < remainingCases ? numCases+1 : numCases;
                    for (Integer j = caseCounter; j < caseCounter + numCasesForAgent; j++) {
                        casesToUpdate[j].OwnerId = agentIds[i];
                        casesToUpdate[j].Maker__c = agentIds[i];
                        casesToUpdate[j].Assign_Date_NFT__c = DateTime.Now();
                        //casesToUpdate[j].Checker__c = UserInfo.getUserId();
                    }
                    caseCounter += numCasesForAgent;
                }*/
                
                System.debug('casesToUpdate');
                System.debug(casesToUpdate);
                
                try {
                    batchJobId = Database.executeBatch(new Cls_Batch_UpdateOwnerCase(casesToUpdate), 15);
                    //update casesToUpdate;
                } catch (Exception e) {
                    System.debug('Error updating cases: ' + e.getMessage());
                    throw new AuraHandledException('Gagal memperbarui Case. Silakan coba lagi.');
                }
            } else {
                AuraHandledException ae = new AuraHandledException('Tidak ada Case yang dipilih.');
                ae.setMessage('Tidak ada Case yang dipilih.');
                throw ae;
            }
            return batchJobId;
        } else {
            AuraHandledException ae = new AuraHandledException('Tidak ada Agen yang dipilih.');
            ae.setMessage('Tidak ada Agen yang dipilih.');
            throw ae;
        }
    }
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
}