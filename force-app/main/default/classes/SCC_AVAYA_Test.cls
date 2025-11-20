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
private class SCC_AVAYA_Test {

    @isTest
    static void getToken() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_AVAYA_Mock.ResponseToken());
        SCC_AVAYA.getToken(Object_Test3.setRequestToken(), '', null);
        test.stopTest();
    }

    @isTest
    static void getReportHistorical() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_AVAYA_Mock.ReportHistorical());
        //SCC_AVAYA.getReportHistorical('', null);
        SCC_AVAYA_ScheduleHistorical sch = new SCC_AVAYA_ScheduleHistorical();
        sch.execute(null);
        test.stopTest();
    }

    @isTest
    static void getReportAgent() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_AVAYA_Mock.ReportAgent());
        //SCC_AVAYA.getReportAgent('', null);
        SCC_AVAYA_ScheduleAgent sch = new SCC_AVAYA_ScheduleAgent();
        sch.execute(null);
        test.stopTest();
    }

    @isTest
    static void getReportSkills() {
        // TO DO: implement unit test
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_AVAYA_Mock.ReportSkills());
        //SCC_AVAYA.getReportSkills('', null);
        SCC_AVAYA_ScheduleSkill sch = new SCC_AVAYA_ScheduleSkill();
        sch.execute(null);
        test.stopTest();
    }
}