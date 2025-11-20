public class SCC_ReturnTicketDrone {
    public static void handleReturnTicket(Case[] newList, Map<Id, Case> oldMap) {
        String CC_Queue = 'SCC - Contact Center';
        
        String profileName = '';
        if(UserInfo.getUserType() == 'Standard'){
            Id profileId = userinfo.getProfileId();
            profileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId].Name;
        }
        
        Map<Id, List<Case>> returnedCases = new Map<Id, List<Case>>(); //userId : Case
        for(Case c : newList){
            if(profileName == 'Salesforce API Only System Integrations' && ((c.Status == 'Returned' && oldMap.get(c.Id).Status != 'Returned') || (c.Status == 'Working'))){
                Id createdById = c.CreatedById;
                if(!returnedCases.containsKey(createdById)){
                    returnedCases.put(createdById, new List<Case>{ c });
                }else if(returnedCases.containsKey(createdById)){
                    List<Case> ownedCases = returnedCases.get(createdById);
                    ownedCases.add(c);
                    returnedCases.put(createdById, ownedCases);
                }
            }
        }
        
        List<Id> createdByIds = new List<Id>( returnedCases.keySet() );
        if(createdByIds.size() > 0){
            List<Id> kpUsers = new List<Id>();
            Map<String, String> branchUsers = new Map<String, String>(); //userId : userBranchCode
            List<String> branchCodes = new List<String>();
            for(User u : [SELECT Id, SCC_Area_Description__c, SCC_Branch__c, SCC_Orgeh__c FROM User WHERE Id IN :createdByIds]){
                if(u.SCC_Area_Description__c == 'Kantor Pusat'){
                    kpUsers.add(u.Id);
                }else if(u.SCC_Area_Description__c != 'Kantor Pusat' && !branchUsers.containsKey(u.Id)){
                    branchUsers.put(u.Id, u.SCC_Branch__c);
                    branchCodes.add(u.SCC_Branch__c);
                }
            }
            
            Map<String, String> branchMap = new Map<String, String>(); //userBranchCode : branchUnitName
            List<String> branchNames = new List<String>();            
            for(Branch_Unit__c b : [SELECT Id, Name, BranchCode__c FROM Branch_Unit__c WHERE BranchCode__c IN :branchCodes]){
                if(!branchMap.containsKey(b.BranchCode__c)){
                    branchMap.put(b.BranchCode__c, b.Name);
                    branchNames.add(b.Name);
                }
            }
            
            Map<String, String> queueMap = new Map<String, String>(); //branchUnitName : branchUnitId
            for(Group q : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :branchNames]){
                if(!queueMap.containsKey(q.Name)){
                    queueMap.put(q.Name, q.Id);
                }
            }
            
            List<Case> updatedCases = new List<Case>();
            if(kpUsers.size() > 0){
                Group ccQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name =: CC_Queue LIMIT 1];
                for(Integer i = 0; i < kpUsers.size(); i++){
                    List<Case> cases = returnedCases.get(kpUsers[i]);
                    for(Integer j = 0; j < cases.size(); j++){
                        cases[j].OwnerId = ccQueue.Id;
                        cases[j].Returned_Case__c = true;
                        cases[j].SCC_Sub_Escalation_Level__c = null;
                        cases[j].Status = 'Working';
                        cases[j].SCC_Drone_Ticket_ID__c = null;
                        updatedCases.add(cases[j]);
                    }
                }
            }
            
            List<String> branchUserIds = new List<String>( branchUsers.keySet() );
            if(branchUserIds.size() > 0){
                for(Integer i = 0; i < branchUserIds.size(); i++){
                    List<Case> cases = returnedCases.get(branchUserIds[i]);
                    for(Integer j = 0; j < cases.size(); j++){
                        cases[j].OwnerId = queueMap.get(branchMap.get(branchUsers.get(branchUserIds[i])));
                        cases[j].Returned_Case__c = true;
                        cases[j].SCC_Sub_Escalation_Level__c = null;
                        cases[j].Status = 'Working';
                        cases[j].SCC_Drone_Ticket_ID__c = null;
                        updatedCases.add(cases[j]);
                    }
                }
            }
        }
    }
}