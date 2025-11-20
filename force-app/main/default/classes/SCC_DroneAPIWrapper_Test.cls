@isTest
public with sharing class SCC_DroneAPIWrapper_Test {
    @IsTest
    static void testObject(){
        SCC_Drone_Object_Test.CheckManualReconRequestModel();
        SCC_Drone_Object_Test.CheckManualReconResponseModel();
        SCC_Drone_Object_Test.CheckManualReconRequestModelFalse();
        SCC_Drone_Object_Test.UpdateCaseRequestModel('TICKET001',null,'',false);
        SCC_Drone_Object_Test.UpdateCaseResponseModel();
        SCC_Drone_Object_Test.RequestCreateTicketDrone();
        SCC_Drone_Object_Test.ResponseCreateTicket();
        SCC_Drone_Object_Test.RequestUpdateTicketDrone();
   }
}