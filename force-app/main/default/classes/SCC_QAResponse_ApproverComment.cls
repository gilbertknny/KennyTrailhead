/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Ardyta Yudianto
**/
public class SCC_QAResponse_ApproverComment {
    
    public static void handleApprovalComment(List<QA_Response__c> newRecords) {
        System.debug('### START handleApprovalComment ###');
        System.debug('Input Records: ' + newRecords);
        
        Set<Id> qaResponseIds = new Set<Id>();
        for(QA_Response__c qa : newRecords) {
            qaResponseIds.add(qa.Id);
        }
        System.debug('QA Response IDs: ' + qaResponseIds);
        
        // Get Process Definitions
        Map<String, ProcessDefinition> pdMap = new Map<String, ProcessDefinition>();
        for(ProcessDefinition pd : [SELECT Id, DeveloperName 
                                  FROM ProcessDefinition 
                                  WHERE DeveloperName IN ('Approval_Penilaian_QA', 'Approval_Banding_QA')]) {
            pdMap.put(pd.DeveloperName, pd);
        }
        System.debug('Process Definitions: ' + pdMap);
        
        // Get Process Instances
        Map<Id, List<ProcessInstance>> qaToProcessInstances = new Map<Id, List<ProcessInstance>>();
        Set<Id> processInstanceIds = new Set<Id>();
        
        for(ProcessInstance pi : [SELECT Id, ProcessDefinitionId, TargetObjectId 
                                FROM ProcessInstance 
                                WHERE ProcessDefinitionId IN :pdMap.values() 
                                AND TargetObjectId IN :qaResponseIds]) {
            if(!qaToProcessInstances.containsKey(pi.TargetObjectId)) {
                qaToProcessInstances.put(pi.TargetObjectId, new List<ProcessInstance>());
            }
            qaToProcessInstances.get(pi.TargetObjectId).add(pi);
            processInstanceIds.add(pi.Id);
        }
        System.debug('Process Instances Map: ' + qaToProcessInstances);
        System.debug('Process Instance IDs: ' + processInstanceIds);
        
        // Get Process Instance Steps
        Map<Id, ProcessInstanceStep[]> piToSteps = new Map<Id, ProcessInstanceStep[]>();
        for(ProcessInstanceStep step : [SELECT Id, ProcessInstanceId, ActorId, Actor.Name, 
                                      CreatedDate, Comments, StepStatus 
                                      FROM ProcessInstanceStep 
                                      WHERE ProcessInstanceId IN :processInstanceIds
                                      AND StepStatus IN ('Approved', 'Rejected')]) {
            if(!piToSteps.containsKey(step.ProcessInstanceId)) {
                piToSteps.put(step.ProcessInstanceId, new ProcessInstanceStep[]{});
            }
            piToSteps.get(step.ProcessInstanceId).add(step);
        }
        System.debug('Process Instance Steps Map: ' + piToSteps);
        
        // Process records and update approval fields
        List<QA_Response__c> recordsToUpdate = new List<QA_Response__c>();
        
        for(QA_Response__c qa : [SELECT Id, Agent_Leader_Lookup__c, Nama_QA_Lookup__c 
                                FROM QA_Response__c 
                                WHERE Id IN :qaResponseIds]) {
            System.debug('Processing QA Response: ' + qa);
            
            String agentLeaderApproval = '';
            String qaApproval = '';
            String qaPembinaApproval = '';
            
            if(qaToProcessInstances.containsKey(qa.Id)) {
                for(ProcessInstance pi : qaToProcessInstances.get(qa.Id)) {
                    if(pi.ProcessDefinitionId == pdMap.get('Approval_Penilaian_QA').Id) {
                        System.debug('Processing Sanggahan Approval for PI: ' + pi);
                        // Process Sanggahan steps
                        if(piToSteps.containsKey(pi.Id)) {
                            for(ProcessInstanceStep step : piToSteps.get(pi.Id)) {
                                String approvalData = String.format('{0};{1};{2}', 
                                    new String[]{
                                        step.Actor.Name,
                                        step.CreatedDate.format('yyyy-MM-dd HH:mm:ss'),
                                        step.Comments != null ? step.Comments : ''
                                    });
                                
                                if(step.ActorId == qa.Agent_Leader_Lookup__c) {
                                    agentLeaderApproval = approvalData;
                                    System.debug('Agent Leader Approval Data: ' + agentLeaderApproval);
                                } else if(step.ActorId == qa.Nama_QA_Lookup__c) {
                                    qaApproval = approvalData;
                                    System.debug('QA Approval Data: ' + qaApproval);
                                }
                            }
                        }
                    } else if(pi.ProcessDefinitionId == pdMap.get('Approval_Banding_QA').Id) {
                        System.debug('Processing Banding Approval for PI: ' + pi);
                        // Process Banding step
                        if(piToSteps.containsKey(pi.Id)) {
                            for(ProcessInstanceStep step : piToSteps.get(pi.Id)) {
                                qaPembinaApproval = String.format('{0};{1};{2}', 
                                    new String[]{
                                        step.Actor.Name,
                                        step.CreatedDate.format('yyyy-MM-dd HH:mm:ss'),
                                        step.Comments != null ? step.Comments : ''
                                    });
                                System.debug('QA Pembina Approval Data: ' + qaPembinaApproval);
                            }
                        }
                    }
                }
            }
            
            QA_Response__c qaToUpdate = new QA_Response__c(
                Id = qa.Id,
                Approval_Sanggahan__c = agentLeaderApproval,
                Approval_QA_Sanggahan__c = qaApproval,
                Approval_QA_Pembina_Banding__c = qaPembinaApproval
            );
            
            recordsToUpdate.add(qaToUpdate);
            System.debug('QA Response to update: ' + qaToUpdate);
        }
        
        if(!recordsToUpdate.isEmpty()) {
            try {
                update recordsToUpdate;
                System.debug('Successfully updated ' + recordsToUpdate.size() + ' records');
            } catch(Exception e) {
                System.debug('Error updating records: ' + e.getMessage());
                throw e;
            }
        }
        
        System.debug('### END handleApprovalComment ###');
    }

    @future
    public static void processApprovalComments(List<Id> qaResponseIds) {
        List<QA_Response__c> qaResponses = [SELECT Id, Status_Approval__c FROM QA_Response__c WHERE Id IN :qaResponseIds];
        handleApprovalComment(qaResponses);
    }
}