/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class SCC_CaseResoultion_DataHub_Test {

    @isTest
    static void searchCustomerProfile() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CustomerProfileResponse());
        SCC_CaseResoultion_DataHub.searchCustomerProfile(Object_Test.customerProfileRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void searchSavingMutation() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.SavingMutationResponse());
        SCC_CaseResoultion_DataHub.searchSavingMutation(Object_Test.SavingMutationRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void searchSavingStatement() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.SavingMutationResponse());
        SCC_CaseResoultion_DataHub.SearchSavingStatement(Object_Test.SavingMutationRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void dataMachineResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DataMachineResponse());
        SCC_CaseResoultion_DataHub.SearchDataMachine(Object_Test.DataMachineRequest(),'DataHubDataMachine','System','');
        Test.stopTest();
    }

    @isTest
    static void searchCustomerProfileError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.ResponseError());
        SCC_CaseResoultion_DataHub.SearchCustomerProfile(Object_Test.CustomerProfileRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void searchSavingMutationError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.ResponseError());
        SCC_CaseResoultion_DataHub.SearchSavingMutation(Object_Test.SavingMutationRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void dataMachineError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DataMachineError());
        SCC_CaseResoultion_DataHub.SearchDataMachine(Object_Test.DataMachineRequest(),'DataHubDataMachine','System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkCardNumberResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkCardNumberResponse());
        SCC_CaseResoultion_DataHub.CardLinkCardNumber(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkCardNumberError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub.CardLinkCardNumber(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkPhoneNumberResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkPhoneNumberResponse());
        SCC_CaseResoultion_DataHub.CardLinkPhoneNumber(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkPhoneNumberError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub.CardLinkPhoneNumber(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkNIKResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkNIKResponse());
        SCC_CaseResoultion_DataHub.CardLinkNIK(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkNIKError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub.CardLinkNIK(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkCustomerNumberResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkCustomerNumberResponse());
        SCC_CaseResoultion_DataHub.CardLinkCustomerNumber(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void cardLinkCustomerNumberError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub.CardLinkCustomerNumber(Object_Test.CardLinkRequest(),'System','');
        Test.stopTest();
    }

    @isTest
    static void briLinkProfileResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRILinkProfileResponse());
        SCC_CaseResoultion_DataHub.BRILinkProfile(Object_Test.BRILinkProfileRequest(),'DataHubBRILinkProfileMID','System','');
        Test.stopTest();
    }

    @isTest
    static void briLinkProfileError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRILinkProfileError());
        SCC_CaseResoultion_DataHub.BRILinkProfile(Object_Test2.setBRILinkProfileRequest(),'DataHubBRILinkProfileMID','System','');
        Test.stopTest();
    }

    @isTest
    static void merchantProfileResposne() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.MerchantProfileResposne());
        SCC_CaseResoultion_DataHub.MerchantProfile(Object_Test.MerchantProfileRequest(),'DataHubMerchantProfileTID','System','');
        Test.stopTest();
    }

    @isTest
    static void merchantProfileError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.MerchantProfileError());
        SCC_CaseResoultion_DataHub.MerchantProfile(Object_Test.MerchantProfileRequest(),'DataHubMerchantProfileTID','System','');
        Test.stopTest();
    }

    @isTest
    static void dplkResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DPLKResponse());
        SCC_CaseResoultion_DataHub.DPLK(Object_Test.DPLKRequest(),'DataHubDPLKIdNumber','System','');
        Test.stopTest();
    }

    @isTest
    static void dplkError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DPLKError());
        SCC_CaseResoultion_DataHub.DPLK(Object_Test.DPLKRequest(),'DataHubDPLKIdNumber','System','');
        Test.stopTest();
    }

    @isTest
    static void cardActivityResposnse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardActivityResposnse());
        SCC_CaseResoultion_DataHub.CardActivity(Object_Test.CardActivityRequest(),'DataHubCardActivity','System','');
        Test.stopTest();
    }

    @isTest
    static void cardActivityError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardActivityError());
        SCC_CaseResoultion_DataHub.CardActivity(Object_Test.CardActivityRequest(),'DataHubCardActivity','System','');
        Test.stopTest();
    }

    @isTest
    static void pctdResponse() {
        // TO DO: implement unit test
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.PCTDResponse());
        SCC_CaseResoultion_DataHub.PCTD(Object_Test.PCTDRequest(), 'DataHubPCTD', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void pctdError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.PCTDError());
        SCC_CaseResoultion_DataHub.PCTD(Object_Test.PCTDRequest(),'DataHubPCTD','System','');
        Test.stopTest();
    }

    @isTest
    static void cardApplicationResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardApplicationResponse());
        SCC_CaseResoultion_DataHub.CardApplication(Object_Test.CardApplicationRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void cardApplicationError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardApplicationError());
        SCC_CaseResoultion_DataHub.CardApplication(Object_Test.CardApplicationRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void briMolaResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRIMolaResponse());
        SCC_CaseResoultion_DataHub.BRIMola(Object_Test.BRIMolaRequest(),'DataHubBRIMolaIdTrx', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void briMolaError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRIMolaError());
        SCC_CaseResoultion_DataHub.BRIMola(Object_Test.BRIMolaRequest(),'DataHubBRIMolaIdTrx', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void cardResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardResponse());
        SCC_CaseResoultion_DataHub.CardDetailDebit(Object_Test.CardRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void cardError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardError());
        SCC_CaseResoultion_DataHub.CardDetailDebit(Object_Test.CardRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void trxMerchantResponse() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.TrxMerchantResponse());
        SCC_CaseResoultion_DataHub.TrxMerchant(Object_Test.TrxMerchantRequest(),'DataHubDetailTransaction', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void trxMerchantError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.TrxMerchantError());
        SCC_CaseResoultion_DataHub.TrxMerchant(Object_Test.TrxMerchantRequest(), 'DataHubDetailTransaction','System', '');
        Test.stopTest();
    }

    @isTest
    static void holdStatus() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.HoldStatusResponse());
        SCC_CaseResoultion_DataHub.holdStatus(Object_Test.holdStatusRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void holdStatusError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.HoldStatusError());
        SCC_CaseResoultion_DataHub.holdStatus(Object_Test.holdStatusRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void inquiryBCCM() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.InquiryBCCMResponse());
        SCC_CaseResoultion_DataHub.inquiryBCCM(Object_Test2.setInquiryBCCMRequest(),'DataHubinquiryBCCMbyCardNumber', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void inquiryPelacakanCC() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.InquiryPelacakanCCResponse());
        SCC_CaseResoultion_DataHub.inquiryPelacakanCC(Object_Test2.setInquiryPelacakanCCRequest(),'DataHubinquiryPelacakanCCbyCardNumber', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void inquiryDataIbbiz() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.InquiryIbbizResponse());
        SCC_CaseResoultion_DataHub.inquiryDataIbbiz(Object_Test2.setInquiryIbbizRequest(),'DataHubinquiryIbbizDataByNoRek', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void inquiryDataIbbizError() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.InquiryIbbizResponseError());
        SCC_CaseResoultion_DataHub.inquiryDataIbbiz(Object_Test2.setInquiryIbbizRequest(),'DataHubinquiryIbbizDataByNoRek', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void inquiryCeria() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.InquiryCeriaResponse());
        SCC_CaseResoultion_DataHub.inquiryCeria(Object_Test2.setInquiryCeriaRequest(),'DataHubinquiryCeriaByIdNumber', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void pengajuanCC() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.PengajuanCCResponse());
        SCC_CaseResoultion_DataHub.pengajuanCC(Object_Test2.setPengajuanCCRequest(),'DataHubpengajuanCardlinkByIdnumber', 'System', '');
        Test.stopTest();
    }

    @isTest
    static void lastTransaction() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.LastTransationResponse());
        SCC_CaseResoultion_DataHub.lastTransaction(Object_Test2.setLastTransactionRequest(), 'System', '');
        Test.stopTest();
    }

    @isTest
    static void reportTransactionBRIVA() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.ReportTransactionBRIVAResponse());
        SCC_CaseResoultion_DataHub.reportTransactionBRIVA(Object_Test2.setReportTransactionBRIVARequest(), 'System', '');
        Test.stopTest();
    }
}