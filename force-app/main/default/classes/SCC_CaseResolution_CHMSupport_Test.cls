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
private class SCC_CaseResolution_CHMSupport_Test {
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
        insert cs;
        SCC_Rekening_Koran__c rek = Object_Test.setRekeningKoran(cs.id);
        insert rek;
        SCC_Rekon__c rk = Object_Test.setRekon(cs.id);
        insert rk;
        SCC_Berita_Acara_Opname__c bao = Object_Test.setBeritaAcaraOpname(cs.id);
        insert bao;
        List<SCC_Queuetrans__c> listque = new List<SCC_Queuetrans__c>();
        for(integer i = 0;i<5;i++){
            SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
            listque.add(que);
        }
        insert listque;
    }

    @isTest
    static void inquiryRoleUserCHM() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.InquiryRoleUserCHMResponse());
        SCC_CaseResolution_CHMSupport.SearchInquiryRoleUser(Object_Test.InquiryRoleUserCHMRequest());
        test.stopTest();
    }

    @isTest
    static void paymentResolutionService() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.PaymentResolutionServiceResponse());
        SCC_CaseResolution_CHMSupport.PaymentResolution(Object_Test.PaymentResolutionServiceRequest());
        test.stopTest();
    }

    @isTest
    static void terminalID() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.TerminalIDResponse());
        SCC_CaseResolution_CHMSupport.SearchTerminalID(Object_Test.TerminalIDRequest('1000'));
        test.stopTest();
    }

    @isTest
    static void terminalIDList() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.TerminalIDListResponse());
        SCC_CaseResolution_CHMSupport.SearchTerminalIDList(Object_Test.TerminalIDListRequest('1000'));
        test.stopTest();
    }

    @isTest
    static void generateToken() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.GenerateTokenCHMSResponse());
        SCC_CaseResolution_CHMSupport.GenerateTokenCHMS();
        test.stopTest();
    }

    @isTest
    static void inquiryRoleUserCHMError() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.ResponseError());
        SCC_CaseResolution_CHMSupport.SearchInquiryRoleUser(Object_Test.InquiryRoleUserCHMRequest());
        test.stopTest();
    }

    @isTest
    static void paymentResolutionServiceError() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.ResponseError());
        SCC_CaseResolution_CHMSupport.PaymentResolution(Object_Test.PaymentResolutionServiceRequest());
        test.stopTest();
    }

    @isTest
    static void terminalIDError() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.ResponseError());
        SCC_CaseResolution_CHMSupport.SearchTerminalID(Object_Test.TerminalIDRequest('1000'));
        test.stopTest();
    }

    @isTest
    static void terminalIDListError() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.ResponseError());
        SCC_CaseResolution_CHMSupport.SearchTerminalIDList(Object_Test.TerminalIDListRequest('1000'));
        test.stopTest();
    }

    @isTest
    static void generateTokenError() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.ResponseError());
        SCC_CaseResolution_CHMSupport.GenerateTokenCHMS();
        test.stopTest();
    }
    
    @isTest
    static void pembukuan(){
        Case cs = [select id from case limit 1];
        test.startTest();
        SCC_CaseResolution_CHMSupport.PembukuanFuture(cs.id);
        test.stopTest();
    }
    
    @isTest
    static void checkTerminal(){
        Case cs = [select id from case limit 1];
        test.startTest();
        SCC_CaseResolution_CHMSupport.CheckTerminal(cs.id);
        test.stopTest();
    }
}