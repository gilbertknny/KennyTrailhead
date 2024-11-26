@istest
public with sharing class SCC_LegacyCaseAPICtrl_Test {
    @TestSetup
    static void testsetup(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8812');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
    }
    @IsTest
    static void createGetCase(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CustomerProfileResponse());
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc1 = Object_Test.CreateCaseRequestModel('','Lala','1234567890123456','MMS');
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc2 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc2.TID = '00000001';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc21 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc21.TID = '+0000001';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc3 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc3.TglTransaksi = 'xxxxx';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc4 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc4.Nominal = 'xxxxxx';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc5 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc5.NomorKartu = 'xxxxx';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc51 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc51.NomorKartu = '';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc52 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc52.NomorKartu = '11111111111';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc6 = Object_Test.CreateCaseRequestModel('8812','Lala','1234567890123456','MMS');
        rcc6.NoTelpPIC = 'xxxxxx';
        SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel rcc7 = Object_Test.CreateCaseRequestModel('8812','Lala','12345678901234','MMS');
        rcc7.NoRekening = '123456';
        SCC_LegacyCaseAPICtrl.CreateCase(rcc);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc1);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc2);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc21);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc3);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc4);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc5);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc51);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc52);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc6);
        SCC_LegacyCaseAPICtrl.CreateCase(rcc7);
        SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel resrcc = Object_Test.CreateCaseResponseModel();
        SCC_LegacyCaseAPICtrl.returnAPI(resrcc);
        SCC_LegacyCaseAPIWrapper.GetCaseRequestModel rgc = Object_Test.GetCaseRequestModel('CallTypeIdTxt=\'8812\'');
        SCC_LegacyCaseAPICtrl.GetCase(rgc);
        SCC_LegacyCaseAPIWrapper.GetCaseResponseModel resrgc = Object_Test.GetCaseResponseModel();
        SCC_LegacyCaseAPICtrl.returnAPIGetCase(resrgc);
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse cpr = Object_Test.CustomerProfileResponse();
        SCC_LegacyCaseAPICtrl.returnAccount(cpr.data[0].demografi, null, '123');
        SCC_LegacyCaseAPICtrl.calculateAge('1990-01-01');
        SCC_LegacyCaseAPICtrl.validateAndSetEmail('budi@gmail.com');       
        Test.stopTest();
    }
}