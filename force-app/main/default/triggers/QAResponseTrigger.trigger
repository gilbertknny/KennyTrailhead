/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 05-02-2025
 * @last modified by  : Ardyta Yudianto
**/
trigger QAResponseTrigger on QA_Response__c (after update) {
    List<Id> updatedResponseIds = new List<Id>();

    for (QA_Response__c qaResponse : Trigger.new) {
        // Cek apakah Status_Approval__c telah berubah
        if (qaResponse.Status_Approval__c != Trigger.oldMap.get(qaResponse.Id).Status_Approval__c) {
            updatedResponseIds.add(qaResponse.Id);
        }
    }

    // Panggil future method jika ada perubahan
    if (!updatedResponseIds.isEmpty()) {
        SCC_QAResponse_ApproverComment.processApprovalComments(updatedResponseIds);
    }
}