@istest
public with sharing class SCC_LegacyCaseAPIWrapper_Test {
    @IsTest
    static void testObject(){
        Object_Test.CreateCaseRequestModel('3100','Lala','1234567890123456','MMS');
        Object_Test.GetCaseRequestModel('CallTypeIdTxt=\'3100\'');
        Object_Test.CreateCaseResponseModel();
        Object_Test.GetCaseResponseModel();
   }
}