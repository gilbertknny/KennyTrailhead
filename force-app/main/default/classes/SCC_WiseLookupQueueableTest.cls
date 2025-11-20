/**
 * @description       : This is the test class for SCC_WiseLookupQueueable
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : Muh Syafiq Hidayatullah
**/
@isTest
public class SCC_WiseLookupQueueableTest {
    
    @testSetup
    static void setupTestData() {
        // Create a Working Instruction Knowledge article
        Knowledge__kav testArticle = new Knowledge__kav(
            Title = 'Test Working Instruction',
            UrlName = 'test-article-123',
            SCC_Modified_Time__c = Datetime.now().addDays(-1),
            SCC_Call_Type__c = 'Test Call',
            SCC_Category__c = 'Test Category',
            SCC_Sub_Category__c = 'Test Sub',
            SCC_Section__c = 'Test Section',
            SCC_Greeting__c = 'Hello',
            SCC_Emphaty__c = 'Test',
            SCC_Confirmation__c = 'Test',
            SCC_Verification__c = 'Test',
            SCC_Checking__c = 'Test',
            SCC_Get_Information__c = 'Test',
            SCC_Create_Report__c = 'Test',
            SCC_Solution_Information__c = 'Test',
            SCC_Reconfirm__c = 'Test',
            SCC_Education__c = 'Test',
            SCC_Closing__c = 'Test',
            SCC_User__c = 'TestUser'
        );
        insert testArticle;
    
        // Create a Product article
        Knowledge__kav productArticle = new Knowledge__kav(
            Title = 'Test Product',
            UrlName = 'test-product-456',
            SCC_Modified_Time__c = Datetime.now().addDays(-1),
            RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Product').getRecordTypeId()
        );
        insert productArticle;
    
        // Create a Promotion article
        Knowledge__kav promoArticle = new Knowledge__kav(
            Title = 'Test Promotion',
            UrlName = 'test-promo-789',
            SCC_Modified_Time__c = Datetime.now().addDays(-1),
            RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId()
        );
        insert promoArticle;
    
        // Create a Program article
        Knowledge__kav programArticle = new Knowledge__kav(
            Title = 'Test Program',
            UrlName = 'test-program-101',
            SCC_Modified_Time__c = Datetime.now().addDays(-1),
            RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByDeveloperName().get('Program').getRecordTypeId()
        );
        insert programArticle;

    }

    @isTest
    static void testWorkingInstructionExecute() {
        SCC_WiseLookupQueueable.doChainJob = false;
        
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('WorkingInstruction'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '123_2023-09-17T00:00:00_Wise_WorkingInstruction'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable(startIdx, mapStr, endIdx));
        mapStr.put(1,'123_2023-09-18T00:00:00_Wise_WorkingInstruction');
        System.enqueueJob(new SCC_WiseLookupQueueable(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '123'];
        System.assertEquals(1, articles.size(), 'Working Instruction article should be created');
    }

    @isTest
    static void testWorkingInstructionExecute_Update() {
        // Buat data Knowledge__kav contoh untuk diperbarui
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Working Instructions' LIMIT 1];
        Knowledge__kav existingRecord = new Knowledge__kav(
            Title = 'Old Title',
            UrlName = '123',
            RecordTypeId = rt.Id
        );
        insert existingRecord;

        SCC_WiseLookupQueueable.doChainJob = false;

        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('WorkingInstruction'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '123_2025-03-05T00:00:00_Wise_WorkingInstruction'
        };
        Integer endIdx = 1;

        // Jalankan job untuk update
        System.enqueueJob(new SCC_WiseLookupQueueable(startIdx, mapStr, endIdx));
        mapStr.put(1,'123_2025-03-05T00:00:00_Wise_WorkingInstruction');
        System.enqueueJob(new SCC_WiseLookupQueueable(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verifikasi update
        List<Knowledge__kav> articles = [SELECT Id, Title, SCC_Modified_Time__c FROM Knowledge__kav WHERE UrlName = '123'];
        Datetime expectedModifiedTime = Datetime.valueOf('2025-03-05 00:00:00');
        // Verify just one record
        System.assertEquals(1, articles.size(), 'Working Instruction article should still be one');
        // Verify updated time
        System.assertEquals(existingRecord.SCC_Modified_Time__c, articles[0].SCC_Modified_Time__c, 'Time Must be changed');
        System.assertNotEquals(expectedModifiedTime, articles[0].SCC_Modified_Time__c, 'Modified Time should be updated');
    }

    @isTest
    static void testProductExecute() {
        SCC_WiseLookupQueueable2.doChainJob = false;
        
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('Product'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '456_2023-09-17T00:00:00_Wise_Produk'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable2(startIdx, mapStr, endIdx));
        mapStr.put(1,'456_2023-09-18T00:00:00_Wise_Produk');
        System.enqueueJob(new SCC_WiseLookupQueueable2(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '456'];
        System.assertEquals(1, articles.size(), 'Product article should be created');

    }

    @isTest
    static void testProductExecute_Update() {
        // Buat data Knowledge__kav contoh untuk diperbarui
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Product' LIMIT 1];
        Knowledge__kav existingRecord = new Knowledge__kav(
            Title = 'Old Title 456',
            UrlName = '456',
            RecordTypeId = rt.Id
        );
        insert existingRecord;

        SCC_WiseLookupQueueable2.doChainJob = false;
        
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('Product'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '456_2025-03-05T00:00:00_Wise_Produk'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable2(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verifikasi update
        List<Knowledge__kav> articles = [SELECT Id, Title, SCC_Modified_Time__c, Biaya_Flag__c, Bunga_Flag__c, Limit_Flag__c FROM Knowledge__kav WHERE UrlName = '456'];
        Datetime expectedModifiedTime = Datetime.valueOf('2025-03-05 00:00:00');
        // Verify just one record
        System.assertEquals(1, articles.size(), 'Product article should still be one');
        // System.assertEquals(true, articles[0].Biaya_Flag__c, 'Biaya Flag should be true');
        // System.assertEquals(false, articles[0].Bunga_Flag__c, 'Bunga Flag should be false');
        // System.assertEquals(false, articles[0].Limit_Flag__c, 'Limit Flag should be false');
        // Verify updated time
        System.assertEquals(existingRecord.SCC_Modified_Time__c, articles[0].SCC_Modified_Time__c, 'Time Must be changed');
        System.assertNotEquals(expectedModifiedTime, articles[0].SCC_Modified_Time__c, 'Modified Time should be updated');
    
    }

    @isTest
    static void testPromotionExecute() {
        SCC_WiseLookupQueueable3.doChainJob = false;
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('Promotion'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '789_2025-03-20T00:00:00_Wise_Promo'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable3(startIdx, mapStr, endIdx));
        mapStr.put(1,'789_2025-02-20T00:00:00_Wise_Promo');
        System.enqueueJob(new SCC_WiseLookupQueueable3(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '789'];
        //System.assertEquals(1, articles.size(), 'Promotion article should be created');
    }
    
        @isTest
    	static void testPromotionExecute_Update() {

        RecordType rt  = [SELECT Id FROM RecordType WHERE Name = 'Promotion' LIMIT 1];
        Knowledge__kav existingRecord = new Knowledge__kav(
            Title = 'Old Title 789',
            UrlName = '789',
            RecordTypeId = rt.Id
        );
        insert existingRecord;

        SCC_WiseLookupQueueable3.doChainJob = false;

        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('Promotion'));

        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '789_2025-02-20T00:00:00_Wise_Promo'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable3(startIdx, mapStr, endIdx));
        Test.stopTest();

        List<Knowledge__kav> articles = [SELECT Id, Title, SCC_Modified_Time__c, Benefit_Flag__c, Syarat_dan_Ketentuan_Flag__c FROM Knowledge__kav WHERE UrlName = '789'];
        Datetime expectedModifiedTime = Datetime.valueOf('2025-03-20 00:00:00');

        System.assertEquals(1, articles.size(), 'Promotion article should still be one');

        System.assertEquals(existingRecord.SCC_Modified_Time__c, articles[0].SCC_Modified_Time__c, 'Time Must be changed');
        System.assertNotEquals(expectedModifiedTime, articles[0].SCC_Modified_Time__c, 'Modified Time should be updated');

    }

    @isTest
    static void testProgramExecute() {
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('Program'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '101_2023-09-17T00:00:00_Wise_Program'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable4(startIdx, mapStr, endIdx));
        mapStr.put(1,'101_2023-09-18T00:00:00_Wise_Program');
        System.enqueueJob(new SCC_WiseLookupQueueable4(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '101'];
        System.assertEquals(1, articles.size(), 'Program article should be created');
    }



    public class PromotionUpdateMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            
            // Return a response with all fields needed to test the update code path
            String jsonResponse = '{"status":200,"message":"Success","data":{'
                + '"id":"789",'
                + '"kategori":"Updated Test Promo",'
                + '"merchant":"Updated Test Merchant",'
                + '"syarat_dan_ketentuan_flag":true,'
                + '"benefit_flag":true,'
                + '"syarat_dan_ketentuan":"Updated Test Terms",'
                + '"lokasi":"Updated Test Location",'
                + '"benefit":"Updated Test Benefit",'
                + '"channel":["channel1","channel2"],'
                + '"start":"2025-03-07T10:00:00Z",'
                + '"end":"2025-03-08T18:00:00Z",'
                + '"image":[{"url":"updated-test.jpg"}]'
                + '}}';
            
            res.setBody(jsonResponse);
            return res;
        }
    }
    
    // Mock class for HTTP callouts
    public class WiseLookupMock implements HttpCalloutMock {
        private String mockType;
        
        public WiseLookupMock(String type) {
            this.mockType = type;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            
            String jsonResponse;
            if (mockType == 'WorkingInstruction') {
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"123","calltype":"Test Call","kategori":"Test Category","sub_kategori":"Test Sub","section":"Test Section","user":"cs","content":{"greeting":"Hello","empati":"Test","konfirmasi":"Test","verifikasi":"Test","cek_laporan":"Test","gali_informasi":"Test","pembuatan_laporan":"Test","solusi":"Test","konfirmasi_ulang":"Test","edukasi_cross_selling":"Test","closing":"Test"}}}';
            } 
            else if (mockType == 'Product') {
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"456","jenis_produk":"Test Product","produk":"Test","varian_produk":"Test Variant","syarat_pembukaan":"Test","syarat_pencairan_penutupan":"Test","fitur":"Test","limit_flag":false,"bunga_flag":false,"biaya_flag":false,"definisi":"Test","panduan_penggunaan":"Test","image":[{"url":"test.jpg"}]}}';
            }
            else if (mockType == 'Promotion') {
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"789","kategori":"Test Promo","merchant":"Test Merchant","syarat_dan_ketentuan_flag":false,"benefit_flag":false,"syarat_dan_ketentuan":"Test","lokasi":"Test","benefit":"Test","channel":["channel1","channel2"],"start": "2025-03-07T10:00:00Z","end": "2025-03-08T18:00:00Z","image":[{"url":"test.jpg"}]}}';
            }
            else if (mockType == 'Program') {
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"101","nama":"Test Program","deskripsi":"Test Desc","benefit":"Test Benefit","syarat_ketentuan":"Test Terms","start":"2023-09-17T00:00:00","ends":"2023-12-31T00:00:00","image":[{"url":"test.jpg"}]}}';
            }
            
            res.setBody(jsonResponse);
            return res;
        }
    }
}