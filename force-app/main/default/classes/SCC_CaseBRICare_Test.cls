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
private class SCC_CaseBRICare_Test {
    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8812');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        cs.scc_account_number__c = '1234123412341234';
        insert cs;
        Branch_unit__c bc = new Branch_unit__c();
        bc.name = 'Cabang';
        bc.nama_cabang__c = 'KC Cabang';
        bc.kode_cabang__c = '666';
        insert bc;
    }
    @isTest
    static void customerProfile() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CustomerProfileResponse());
        SCC_CaseBRICare.getPortofolio(cs.id);
        SCC_CaseBRICare.getCustomer('123412341234123', '1234123412341234', cs.id);
        Test.stopTest();
    }

    @isTest
    static void savingMutation() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.SavingMutationResponse());
        SCC_CaseBRICare.getMutation('123412341234123', '2024-01-01', '2024-01-01', cs.id);
        Test.stopTest();
    }

    @isTest
    static void card() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardResponse());
        SCC_CaseBRICare.getCardDetailDebit('1234123412341234', cs.id);
        Test.stopTest();
    }

    @isTest
    static void dataMachine() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DataMachineResponse());
        SCC_CaseBRICare.getMachine('aaaa', '', cs.id);
        Test.stopTest();
    }

    @isTest
    static void cardLinkCardNumber() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardLinkCardNumberResponse());
        SCC_CaseBRICare.getCardLink( cs.id);
        Test.stopTest();
    }

    @isTest
    static void pctdResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.PCTDResponse());
        SCC_CaseBRICare.getTrxCredit('1234123412341234', cs.id);
        Test.stopTest();
    }

    @isTest
    static void cardApplicationResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardApplicationResponse());
        SCC_CaseBRICare.getPengajuanKartu('1234123412341234', cs.id);
        Test.stopTest();
    }

    @isTest
    static void briLinkProfileResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRILinkProfileResponse());
        SCC_CaseBRICare.getBRILink('123','123', cs.id);
        Test.stopTest();
    }

    @isTest
    static void merchantProfileResposne() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.MerchantProfileResposne());
        SCC_CaseBRICare.getMerchant('123','123', cs.id);
        Test.stopTest();
    }

    @isTest
    static void trxMerchantResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.TrxMerchantResponse());
        SCC_CaseBRICare.getMerchantTrx(Object_Test.TrxMerchantRequest(), cs.id);
        Test.stopTest();
    }

    @isTest
    static void briMolaResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.BRIMolaResponse());
        SCC_CaseBRICare.getWholeSaleBRIMola('123','2022-01-01','2022-01-01', cs.id);
        Test.stopTest();
    }

    @isTest
    static void dplkResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.DPLKResponse());
        SCC_CaseBRICare.getDPLK('123','123', cs.id);
        Test.stopTest();
    }

    @isTest
    static void holdStatusResponse() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.HoldStatusResponse());
        SCC_CaseBRICare.getHoldStatus('123', cs.id);
        Test.stopTest();
    }

    @isTest
    static void branchUnit() {
        // TO DO: implement unit test
        Test.startTest();
        SCC_CaseBRICare.getBranch('666');
        SCC_CaseBRICare.getBranch('777');
        Test.stopTest();
    }

    @isTest
    static void verification() {
        // TO DO: implement unit test
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Customer_Verification__c cv = new Customer_Verification__c();
        cv.case__c = cs.id;
        cv.name = '123456789012345';
        SCC_CaseBRICare.ResponseVerification rv = SCC_CaseBRICare.UpdateVerification(cv);
        List<Customer_Verification__c> lcv = SCC_CaseBRICare.getCustomerVerification(cv.name,cv.case__c);
        rv = SCC_CaseBRICare.UpdateVerification(lcv[0]);
        Test.stopTest();
    }

    @isTest
    static void tid() {
        // TO DO: implement unit test
        Test.startTest();
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData dt1 = Object_Test.SavingMutationData(100000,0,'2022-08-29T00:00:00Z');
        dt1.auxtrc = '2501';
        dt1.kodeTran = '2501';
        dt1.trremk = '089656675766 00861145 861145025100';
        SCC_CaseBRICare.getTID(dt1);
        dt1.auxtrc = '8554';
        dt1.kodeTran = '8554';
        dt1.noRek = Decimal.valueOf('1116010021215330');
        dt1.trremk = '11160100212153300861145861145025103';
        SCC_CaseBRICare.getTID(dt1);
        dt1.auxtrc = '8501';
        dt1.kodeTran = '8501';
        dt1.trremk = '601301324190401500861161';
        SCC_CaseBRICare.getTID(dt1);
        dt1.auxtrc = '8553';
        dt1.kodeTran = '8553';
        dt1.trremk = '601301324190401500861115';
        SCC_CaseBRICare.getTID(dt1);
        Test.stopTest();
    }

    @isTest
    static void errorLog() {
        // TO DO: implement unit test
        Test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(exception exc){
            SCC_CaseBRICare.errorLog(exc);
        }
        Test.stopTest();
    }
}