trigger CaseTrigger on Case (before update,after update ,after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isUpdate) {
            System.debug('trigger');
            SCC_ApprovalCheckerController.approveTickets(Trigger.new, Trigger.oldMap);
            SCC_ReturnTicketDrone.handleReturnTicket(Trigger.new, Trigger.oldMap);
            SCC_ApexApproval_Signer.updateSigner(Trigger.new, Trigger.oldMap); 
            SCC_OpenMilestone.action(Trigger.new, Trigger.oldMap);
            CaseHandler_UpdateDokumen.action(Trigger.new, Trigger.oldMap);
        }
    }
}