@istest
public with sharing class SCC_DroneCheckManualReconCtrl_Test {
    
    @IsTest
    static void GetCase() {
        Test.startTest();
        SCC_DroneAPIWrapper.CheckManualReconRequestModel req = SCC_Drone_Object_Test.CheckManualReconRequestModel();
        SCC_DroneCheckManualReconCtrl.GetCaseManualRecon(req);

        SCC_DroneAPIWrapper.CheckManualReconResponseModel res = SCC_Drone_Object_Test.CheckManualReconResponseModel();
        SCC_DroneCheckManualReconCtrl.returnAPIGetCase(res);
        Test.stopTest();
    }
}