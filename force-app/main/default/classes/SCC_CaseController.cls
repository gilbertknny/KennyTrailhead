public with sharing class SCC_CaseController {
    public Case caseObj { get; set; }
    public Boolean renderForm { get; set; }
    public Boolean renderErrorForm { get; set; }

    public SCC_CaseController(ApexPages.StandardController controller) {
        caseObj = (Case)controller.getRecord();
        String curUserName = UserInfo.getName();
        renderForm = true;
        renderErrorForm = false;
        List <PermissionSetAssignment> listPermissionSetAssignment = [SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name FROM PermissionSetAssignment WHERE (PermissionSet.Name = 'SCC_CC_Maker' OR PermissionSet.Name = 'SCC_Branch_Maker' OR PermissionSet.Name = 'SCC_BO_Agent_Create_Case' OR PermissionSet.Name = 'CC_Agent_Leader' OR PermissionSet.Name = 'SCC_Telesales_Maker') AND Assignee.Name = :curUserName];
        if(listPermissionSetAssignment.size()==0){
            renderForm = false;
            renderErrorForm = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Anda tidak mempunyai akses untuk membuat case'));   
        }
    }

    public PageReference saveCase() {
        try {
            insert caseObj;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Case created successfully.'));
            return new PageReference('/' + caseObj.Id);
        } catch (Exception e) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;
        }
    }
}