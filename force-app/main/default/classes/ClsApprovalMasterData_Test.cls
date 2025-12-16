@IsTest(SeeAllData=false)
public class ClsApprovalMasterData_Test {
	@TestSetup
    static void setTestData(){
        String RT1 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Policy Distribution').getRecordTypeId();
        Master_Data__c md1 = new Master_Data__c();
        md1.RecordTypeId = RT1;
        md1.Status__c = 'Draft';
        md1.Name = '1';
        insert md1;
        
        String RT2 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Treaty Capacity').getRecordTypeId();
        Master_Data__c md2 = new Master_Data__c();
        md2.RecordTypeId = RT2;
        md2.Status__c = 'Draft';
        md2.Name = '2';
        insert md2;
        
        String RT3 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Approval Limit').getRecordTypeId();
        Master_Data__c md3 = new Master_Data__c();
        md3.RecordTypeId = RT3;
        md3.Status__c = 'Draft';
        md3.Name = '3';
        md3.AUTHORITY_TYPE__c = 'UW';
        insert md3;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            String strType = 'Policy_Distribution';
            String strAuth = '';
            List<Master_Data__c> listmd = ClsApprovalMasterData.getMasterData(strType,strAuth);
            system.assertEquals(listmd.size(),1);
            ClsApprovalMasterData.approveData(strType,strAuth);
            strType = 'Treaty_Capacity';
            List<Master_Data__c> listmd1 = ClsApprovalMasterData.getMasterData(strType,strAuth);
            system.assertEquals(listmd1.size(),1);
            ClsApprovalMasterData.rejectData(strType,strAuth);
            strType = 'Approval_Limit';
            strAuth = 'UW';
            List<Master_Data__c> listmd2 = ClsApprovalMasterData.getMasterData(strType,strAuth);
            system.assertEquals(listmd2.size(),1);
            ClsApprovalMasterData.getPermission();
            Test.stopTest();
        }
    }
}