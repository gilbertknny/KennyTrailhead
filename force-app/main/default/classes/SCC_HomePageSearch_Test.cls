@istest
public with sharing class SCC_HomePageSearch_Test {
    @IsTest
    static void customerProfile(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CustomerProfileResponse());
        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = Object_Test.CustomerProfileRequest();
        SCC_HomePageSearch.getCustomerProfile(req);
    }

    @IsTest
    static void cardLinkCardNo(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkCardNumberResponse());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink(req.cardNumber, '', '', '');
    }

    @IsTest
    static void cardLinkCardNoError(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink(req.cardNumber, '', '', '');
    }

    @IsTest
    static void cardLinkphoneNumber(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkPhoneNumberResponse());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink('', req.phoneNumber, '', '');
    }

    @IsTest
    static void cardLinkphoneNumberError(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink('', req.phoneNumber, '', '');
    }

    @IsTest
    static void cardLinkcustomerNumber(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkCustomerNumberResponse());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink('', '', req.customerNumber, '');
    }

    @IsTest
    static void cardLinkcustomerNumberError(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink('', '', req.customerNumber, '');
    }

    @IsTest
    static void cardLinknik(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkNIKResponse());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink('', '', '', req.nik);
    }

    @IsTest
    static void cardLinknikError(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkError());
        SCC_CaseResoultion_DataHub_Wrapper.CardLinkRequest req = Object_Test.CardLinkRequest();
        SCC_HomePageSearch.getCardLink('', '', '', req.nik);
    }

    @IsTest
    static void dplkidNumber(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DPLKResponse());
        SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest req = Object_Test.DPLKRequest();
        SCC_HomePageSearch.getDPLK(req.idNumber, '');
    }

    @IsTest
    static void dplkacctNo(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DPLKResponse());
        SCC_CaseResoultion_DataHub_Wrapper.DPLKRequest req = Object_Test.DPLKRequest();
        SCC_HomePageSearch.getDPLK('', req.acctNo);
    }

    @IsTest
    static void merchantTID(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.MerchantProfileResposne());
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest req = Object_Test.MerchantProfileRequest();
        SCC_HomePageSearch.getMerchant(req.tid, '');
    }

    @IsTest
    static void merchantMID(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.MerchantProfileResposne());
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest req = Object_Test.MerchantProfileRequest();
        SCC_HomePageSearch.getMerchant('', req.mid);
    }

    @IsTest
    static void merchantError(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.MerchantProfileError());
        SCC_CaseResoultion_DataHub_Wrapper.MerchantProfileRequest req = Object_Test.MerchantProfileRequest();
        SCC_HomePageSearch.getMerchant('', req.mid);
    }

    @IsTest
    static void briLinkTID(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRILinkProfileResponse());
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = Object_Test.BRILinkProfileRequest();
        SCC_HomePageSearch.getBRILink(req.tid, '');
    }

    @IsTest
    static void briLinkMID(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRILinkProfileResponse());
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = Object_Test.BRILinkProfileRequest();
        SCC_HomePageSearch.getBRILink('', req.mid);
    }

    @IsTest
    static void briLinkError(){
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRILinkProfileError());
        SCC_CaseResoultion_DataHub_Wrapper.BRILinkProfileRequest req = Object_Test.BRILinkProfileRequest();
        SCC_HomePageSearch.getBRILink('', req.mid);
    }
}