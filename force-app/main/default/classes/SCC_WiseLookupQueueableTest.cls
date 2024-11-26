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
        mapStr.put(1,'123_2023-09-18T00:00:00_Wise_Produk');
        System.enqueueJob(new SCC_WiseLookupQueueable2(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '456'];
        System.assertEquals(1, articles.size(), 'Product article should be created');
    }
    
    @isTest
    static void testPromotionExecute() {
        SCC_WiseLookupQueueable3.doChainJob = false;
        // Mock HTTP callout response
        Test.setMock(HttpCalloutMock.class, new WiseLookupMock('Promotion'));
        
        Test.startTest();
        Integer startIdx = 1;
        Map<Integer, String> mapStr = new Map<Integer, String>{
            1 => '789_2023-09-17T00:00:00_Wise_Promo'
        };
        Integer endIdx = 1;
        
        System.enqueueJob(new SCC_WiseLookupQueueable3(startIdx, mapStr, endIdx));
        mapStr.put(1,'123_2023-09-18T00:00:00_Wise_Promo');
        System.enqueueJob(new SCC_WiseLookupQueueable3(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '789'];
        System.assertEquals(1, articles.size(), 'Promotion article should be created');
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
        mapStr.put(1,'123_2023-09-18T00:00:00_Wise_Program');
        System.enqueueJob(new SCC_WiseLookupQueueable4(startIdx, mapStr, endIdx));
        Test.stopTest();
        
        // Verify results
        List<Knowledge__kav> articles = [SELECT Id, Title FROM Knowledge__kav WHERE UrlName = '101'];
        System.assertEquals(1, articles.size(), 'Program article should be created');
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
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"456","jenis_produk":"Test Product","produk":"Test","varian_produk":"Test Variant","syarat_pembukaan":"Test","syarat_pencairan_penutupan":"Test","fitur":"Test","limits":"Test","bunga":"Test","biaya":"Test","definisi":"Test","panduan_penggunaan":"Test","image":[{"url":"test.jpg"}]}}';
            }
            else if (mockType == 'Promotion') {
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"789","kategori":"Test Promo","merchant":"Test Merchant","syarat_dan_ketentuan":"Test","lokasi":"Test","benefit":"Test","channel":["channel1","channel2"],"start":"2023-09-17T00:00:00","ends":"2023-12-31T00:00:00","image":[{"url":"test.jpg"}]}}';
            }
            else if (mockType == 'Program') {
                jsonResponse = '{"status":200,"message":"Success","data":{"id":"101","nama":"Test Program","deskripsi":"Test Desc","benefit":"Test Benefit","syarat_ketentuan":"Test Terms","start":"2023-09-17T00:00:00","ends":"2023-12-31T00:00:00","image":[{"url":"test.jpg"}]}}';
            }
            
            res.setBody(jsonResponse);
            return res;
        }
    }
}