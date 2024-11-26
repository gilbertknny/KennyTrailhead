@isTest
public with sharing class SCC_Wise_Lookup_Test {
    
    @IsTest
    static void getWorkingInstructionLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseWiLookup());
        SCC_Wise_Lookup.getWorkingInstructionLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProgramLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseProgramLookup());
        SCC_Wise_Lookup.getProgramLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getPromoLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponsePromoLookup());
        SCC_Wise_Lookup.getPromoLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProdukLookup () {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseProdukLookup());
        SCC_Wise_Lookup.getProdukLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getWorkingInstructionLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getWorkingInstructionLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getPromoLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getPromoLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProdukLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getProdukLookup('123');
        Test.stopTest();
    }

    @IsTest
    static void getProgramLookupError() {
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_LookupMock.ResponseError());
        SCC_Wise_Lookup.getProgramLookup('123');
        Test.stopTest();
    }
}