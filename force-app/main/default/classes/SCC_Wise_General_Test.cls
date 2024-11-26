@isTest
private class SCC_Wise_General_Test {

    @IsTest
    static void testWrapperWiseGeneral() {

        Integer total = 2;

        Map<Integer,String> testMap = new Map<Integer,String>();
        testMap.put(1, 'id1_27/01/2024T00:00:00_Wise_Produk');
        testMap.put(2, 'id2_27/01/2024T00:00:00_Wise_Program');

        Test.startTest();
        SCC_Wise_General.wrapperWiseGeneral wrapper = new SCC_Wise_General.wrapperWiseGeneral(testMap,total);
        Test.stopTest();

        System.assertEquals(testMap, wrapper.categorize, 'Categorize map should match');
        System.assertEquals(total, wrapper.total, 'Total should match');
    }

    @IsTest
    static void testReqCons() {
        Test.startTest();
        SCC_WiseWrapper.RequestWorkingInstruction result = SCC_Wise_General.reqCons(20, 1);
        Test.stopTest();
        
        System.assertEquals(20, result.limits, 'Limits should be 20');
        System.assertEquals(1, result.page, 'Page should be 1');
        System.assertEquals('desc', result.sort_at, 'Sort at should be desc');
        System.assertEquals('modified_date', result.sort_by, 'Sort by should be modified_date');
        System.assertEquals(0, result.user.size(), 'User list should be empty');
    }

    @IsTest
    static void testReqProds() {
        Test.startTest();
        SCC_WiseWrapper.RequestProduk result = SCC_Wise_General.reqProds(20, 1);
        Test.stopTest();
        
        System.assertEquals(20, result.limits, 'Limits should be 20');
        System.assertEquals(1, result.page, 'Page should be 1');
        System.assertEquals('desc', result.sort_at, 'Sort at should be desc');
        System.assertEquals('modified_date', result.sort_by, 'Sort by should be modified_date');
        System.assertEquals(0, result.produk.size(), 'Produk list should be empty');
        System.assertEquals(0, result.jenis_produk.size(), 'Jenis produk list should be empty');
    }

    @IsTest
    static void testReqProgs() {
        Test.startTest();
        SCC_WiseWrapper.RequestProgram result = SCC_Wise_General.reqProgs(20, 1);
        Test.stopTest();
        
        System.assertEquals(20, result.limits, 'Limits should be 20');
        System.assertEquals(1, result.page, 'Page should be 1');
        System.assertEquals('desc', result.sort_at, 'Sort at should be desc');
        System.assertEquals('modified_date', result.sort_by, 'Sort by should be modified_date');
        System.assertEquals(null, result.start_date, 'Start date should be null');
        System.assertEquals(null, result.end_date, 'End date should be null');
    }

    @IsTest
    static void testReqPromos() {
        Test.startTest();
        SCC_WiseWrapper.RequestPromo result = SCC_Wise_General.reqPromos(20, 1);
        Test.stopTest();
        
        System.assertEquals(20, result.limits, 'Limits should be 20');
        System.assertEquals(1, result.page, 'Page should be 1');
        System.assertEquals('desc', result.sort_at, 'Sort at should be desc');
        System.assertEquals('modified_date', result.sort_by, 'Sort by should be modified_date');
        System.assertEquals(0, result.kategori.size(), 'Kategori list should be empty');
        System.assertEquals(0, result.channel.size(), 'Channel list should be empty');
    }

    @IsTest
    static void testFormatedRichText() {
        String testContent1 = 'This is a test content with no URLs';
        String result1 = SCC_Wise_General.formatedRichText(testContent1);
        // System.assertEquals(testContent1, result1, 'Content with no URLs should remain unchanged');
        
        String testContent2 = 'Visit http://example.com for more info';
        String result2 = SCC_Wise_General.formatedRichText(testContent2);
        // System.assert(result2.contains('<a href="http://example.com">http://example.com</a>'), 
        //              'HTTP URL should be converted to anchor tag');
        
        String testContent3 = 'Visit www.example.com for more info';
        String result3 = SCC_Wise_General.formatedRichText(testContent3);
        // System.assert(result3.contains('<a href="http://www.example.com">www.example.com</a>'), 
        //              'WWW URL should be converted to anchor tag');
        
        String result4 = SCC_Wise_General.formatedRichText('');
        // System.assertEquals('', result4, 'Blank content should return blank');
        
        String result5 = SCC_Wise_General.formatedRichText(null);
        // System.assertEquals(null, result5, 'Null content should return null');
    }

   @IsTest
   static void testGetWiseListId_WI() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseWorkingInstruction());
        SCC_Wise_General.wrapperWiseGeneral response = SCC_Wise_General.getWiseListId('WI');
        Test.stopTest();
   }

   @IsTest
   static void testGetWiseListId_Produk() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseProduk());
        SCC_Wise_General.wrapperWiseGeneral response = SCC_Wise_General.getWiseListId('Produk');
        Test.stopTest();
   }

   @IsTest
   static void testGetWiseListId_Program() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponseProgram());
        SCC_Wise_General.wrapperWiseGeneral response = SCC_Wise_General.getWiseListId('Program');
        Test.stopTest();
   }

   @IsTest
   static void testGetWiseListId_Promo() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Wise_ListMock.ResponsePromo());
        SCC_Wise_General.wrapperWiseGeneral response = SCC_Wise_General.getWiseListId('Promo');
        Test.stopTest();
   }

}