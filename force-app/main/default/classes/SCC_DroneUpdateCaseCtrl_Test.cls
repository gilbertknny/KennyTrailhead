@isTest
public with sharing class SCC_DroneUpdateCaseCtrl_Test {
    @TestSetup
    static void testsetup(){
        Case cs = new Case();
        cs.Origin = 'YouTube';
        cs.Status= 'New';
        cs.Priority = 'Low';
        cs.Subject = 'Test Subject';
        cs.Description = 'Desc';
        cs.SCC_Segment__c = 'Individu Umum';
        cs.SCC_Product_L1__c = 'Savings';
        insert cs;
    }
    @IsTest
    static void UpdateCase(){
        String allfieldCase = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfieldCase, '', 'Case', '', '', '', '');
        List<Case> cs = Database.query(queries);
    
        Test.startTest();
        SCC_DroneAPIWrapper.UpdateCaseRequestModel req = SCC_Drone_Object_Test.UpdateCaseRequestModel(String.valueOf(cs[0].CaseNumber),1001,'1003',false);
        SCC_DroneUpdateCaseCtrl.UpdateCase(req);

        SCC_DroneAPIWrapper.UpdateCaseRequestModel req2 = SCC_Drone_Object_Test.UpdateCaseRequestModel('TICKET0001',null,'',false);
        SCC_DroneUpdateCaseCtrl.UpdateCase(req2);

        SCC_DroneAPIWrapper.UpdateCaseResponseModel res = SCC_Drone_Object_Test.UpdateCaseResponseModel();
        SCC_DroneUpdateCaseCtrl.returnAPI(res);
        Test.stopTest();
    }
}