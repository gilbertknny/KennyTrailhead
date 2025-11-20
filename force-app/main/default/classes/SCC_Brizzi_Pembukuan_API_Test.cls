/**
 * @description       : 
 * @author            : Suherbing Septian
 * @created date      : 15-09-2025
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Suherbing Septian
**/

@istest
public with sharing class SCC_Brizzi_Pembukuan_API_Test {
    @isTest
    static void searchCard() {
        // TO DO: implement unit test
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_Pembukuan_Mock.BrizziMock());
        SCC_Brizzi_Pembukuan_API.doPembukuan(Object_Test_Brizzi.brizziPembukuanRequest());
        Test.stopTest();
    }
}