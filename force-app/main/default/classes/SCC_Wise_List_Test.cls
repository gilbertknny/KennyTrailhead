@isTest
private class SCC_Wise_List_Test {

    @isTest
    static void getWorkingInstructionList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseWorkingInstruction());
        SCC_Wise_List.getWorkingInstructionList(Object_Test_Wise.requestWi());
        Test.stopTest();
    }


    @isTest
    static void getProdukList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseProduk());
        SCC_Wise_List.getProdukList(Object_Test_Wise.requestProduk());
        Test.stopTest();
    }


    @isTest
    static void getProgramList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseProgram());
        SCC_Wise_List.getProgramList(Object_Test_Wise.requestProgram());
        Test.stopTest();
    }

    @isTest
    static void getPromoList() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponsePromo());
        SCC_Wise_List.getPromoList(Object_Test_Wise.requestPromo());
        Test.stopTest();
    }

    @IsTest
    static void getWorkingInstructionListError(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseError());
        SCC_Wise_List.getWorkingInstructionList(Object_Test_Wise.requestWi());
        Test.stopTest();
    }

    @IsTest
    static void getProdukListError(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseError());
        SCC_Wise_List.getProdukList(Object_Test_Wise.requestProduk());
        Test.stopTest();
    }

    @IsTest
    static void getProgramListError(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseError());
        SCC_Wise_List.getProgramList(Object_Test_Wise.requestProgram());
        Test.stopTest();
    }

    @IsTest
    static void getPromoListError(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseError());
        SCC_Wise_List.getPromoList(Object_Test_Wise.requestPromo());
        Test.stopTest();
    }

    
}