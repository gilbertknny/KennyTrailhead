/**
 * @description       : Unit Test lengkap untuk SCC_Batch_AutoClosed_Briva
 * @author            : Suherbing Septian
 * @last modified on  : 10/16/2025
 * @last modified by  : Suherbing Septian
**/
@isTest
private class SCC_Batch_AutoClosed_Briva_Test {

    // =========================
    // MultiMockup untuk Rekening Koran dan Rekon
    // =========================
    public class MultiEndpointMock implements HttpCalloutMock {

        // Map untuk menyimpan naskah respons: Key -> pengenal endpoint, Value -> body respons
        private Map<String, String> responseMap;

        // Constructor untuk "mengajarkan" mock respons apa yang harus diberikan
        public multiEndpointMock(Map<String, String> responses) {
            this.responseMap = responses;
        }

        public HTTPResponse respond(HTTPRequest req) {
            String endpoint = req.getEndpoint();
            System.debug('endpoint test : '+endpoint);
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            
            // Logika baru: Cari respons yang sesuai dari Map berdasarkan endpoint
            if (endpoint.contains('savingStatement') && responseMap.containsKey('savingStatement')) {
                System.debug('endpoint test berhasil rekor');
                res.setBody(responseMap.get('savingStatement'));
                res.setStatusCode(200);
                
            } else if (endpoint.contains('inquiry-status-recon-transaction') && responseMap.containsKey('recon')) {
                res.setBody(responseMap.get('recon'));
                res.setStatusCode(200);
                System.debug('endpoint test berhasil rekon : '+res);

            }else if (endpoint.contains('briva') && responseMap.containsKey('briva')) {
                res.setBody(responseMap.get('briva'));
                res.setStatusCode(200);
                System.debug('endpoint test berhasil briva : '+res);

            } else {
                System.debug('endpoint test gagal');
                res.setBody('{ "error": "Mock response untuk endpoint ini tidak didefinisikan" }');
                res.setStatusCode(404);
            }
            
            return res;
        }
    }

    // =========================
    // Test data setup (master)
    // =========================
    @TestSetup
    static void makeData(){
        // Call Type & Feature
        SSC_Call_Type__c ct = Object_Test.setCallType('8433'); insert ct;

        SCC_Call_Type_Feature__c ctf = Object_Test.setFitur(ct.Id); insert ctf;

        // Master Mapping Feature (dipakai untuk → rekon)
        insert Object_test_RTGS.setMappingFeature('korPLN', ct.Id, ctf.Id, '', 'AYOPOP', '');

        // Master KOR (dipakai untuk 8809 → rekening koran)
        insert Object_test_RTGS.setMasterKor('korPLN',  ct.Id, '');

        // [FIX] Membuat data Case yang lengkap untuk pengujian
        List<Case> casesToInsert = new List<Case>();
        
        // Case untuk skenario 8809
        Case cBriva = Object_Test.setCase(ct.Id);
        cBriva.SCC_Amount__c = 130000000;
        cBriva.Status = 'New';
        cBriva.SCC_Transaction_Date__c = Date.today();
        cBriva.SCC_Account_Number__c = 'BRIVA-8433';
        cBriva.scc_Billing_Number__c = ''; // ID unik untuk query
        cBriva.SCC_Nomor_Briva_Tagihan__c = '896895786576';
        casesToInsert.add(cBriva);

        // Case untuk skenario 8808
        Case cNonBriva = Object_Test.setCase(ct.Id);
        cNonBriva.SCC_Amount__c = 130000000;
        cNonBriva.Status = 'New';
        cNonBriva.SCC_Transaction_Date__c = Date.today();
        cNonBriva.SCC_Account_Number__c = 'NON-8433';
        cNonBriva.scc_Billing_Number__c = 'NON-8433'; // ID unik untuk query
        cNonBriva.SCC_Nomor_Briva_Tagihan__c = '';
        casesToInsert.add(cNonBriva);

        insert casesToInsert;
    }

    // Util untuk membangun query
    private static String buildQueryById(Id caseId){
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String addfield = ',SCC_Call_Type__r.External_Id__c';
        String cond     = 'IsClosed = false AND Id = \'' + caseId + '\'';
        return SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
    }

    // =========================
    // 1) Early-close (<= 6000)
    // =========================
    @isTest
    static void test_EarlyClose_8433(){
        Case c = [SELECT Id FROM Case WHERE scc_Billing_Number__c = 'NON-8433' LIMIT 1];
        c.SCC_Amount__c = 5000;
        update c;
        
        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 2) 8433 → jalur NON BRIVA REKENING KORAN
    // ==========================================
    @isTest
    static void test_8433_Nonbriva_RekeningKoran(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'NON-8433' LIMIT 1];
        
        Map<String, String> customResponses = new Map<String, String>();

        String mockBodyRekor = '{' +
                '"data": [' +
                    '{' +
                        '"auxtrc": "AUX123",' +
                        '"deskTran": "Transfer Credit",' +
                        '"glsign": "C",' +
                        '"idNum": 12345,' +
                        '"idNum2": 67890,' +
                        '"idNum3": 11223,' +
                        '"jamTran": 1435,' +
                        '"kodeTran": "ABC123",' +
                        '"mutasiDebet": 0,' +
                        '"mutasiKredit": 130000000,' +
                        '"noRek": "326301020301234",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "korPLN Transfer Credit",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';
        customResponses.put('savingStatement', mockBodyRekor);

        String mockBodyRekon = '{' +
            '"errorCode":"",' +
            '"responseCode":"00",' +
            '"responseMessage":"",' +
            '"responseData": {' +
                '"detailData": [' +
                    '{'+
                        '"BillingCode":"14361525604",' +
                        '"Fee":"3000.00",' +
                        '"ID":251019,' +
                        '"RekDebet":"473701026064534",' +
                        '"RekDebetFee":"473701026064534",' +
                        '"RekKredit":"",' +
                        '"Remark":"PLN-POST  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"StatusRecon":"Match",' +
                        '"Seq":"5041015",' +
                        '"StatusMCSDesc":"Success",' +
                        '"StatusMCS":"00",' +
                        '"TanggalTrans":"'+ Date.today().format() +'"' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        customResponses.put('recon', mockBodyRekon);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(customResponses));

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 3) 8433 → jalur NON BRIVA REKON (match)
    // ==========================================
    @isTest
    static void test_8433_Nonbriva_Rekon_Match(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'NON-8433' LIMIT 1];
        
        Map<String, String> customResponses = new Map<String, String>();

        String mockBodyRekor = '{' +
                '"data": [' +
                    '{' +
                        '"auxtrc": "AUX123",' +
                        '"deskTran": "Transfer Credit",' +
                        '"glsign": "C",' +
                        '"idNum": 12345,' +
                        '"idNum2": 67890,' +
                        '"idNum3": 11223,' +
                        '"jamTran": 1435,' +
                        '"kodeTran": "ABC123",' +
                        '"mutasiDebet": 130000000,' +
                        '"mutasiKredit": 13000000,' +
                        '"noRek": "326301020301234",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "AYOPOP Transfer Credit",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';
        customResponses.put('savingStatement', mockBodyRekor);

        String mockBodyRekon = '{' +
            '"errorCode":"",' +
            '"responseCode":"00",' +
            '"responseMessage":"",' +
            '"responseData": {' +
                '"detailData": [' +
                    '{'+
                        '"BillingCode":"14361525604",' +
                        '"Fee":"3000.00",' +
                        '"ID":251019,' +
                        '"RekDebet":"473701026064534",' +
                        '"RekDebetFee":"473701026064534",' +
                        '"RekKredit":"",' +
                        '"Remark":"AYOPOP  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"StatusRecon":"Match",' +
                        '"Seq":"5041015",' +
                        '"StatusMCSDesc":"Success",' +
                        '"StatusMCS":"00",' +
                        '"TanggalTrans":"'+ Date.today().format() +'"' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        customResponses.put('recon', mockBodyRekon);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(customResponses));

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 4) 8433 → jalur NON BRIVA REKON (unmatch)
    // ==========================================
    @isTest
    static void test_8433_Nonbriva_Rekon_Unmatch(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'NON-8433' LIMIT 1];
        
        Map<String, String> customResponses = new Map<String, String>();

        String mockBodyRekor = '{' +
                '"data": [' +
                    '{' +
                        '"auxtrc": "AUX123",' +
                        '"deskTran": "Transfer Credit",' +
                        '"glsign": "C",' +
                        '"idNum": 12345,' +
                        '"idNum2": 67890,' +
                        '"idNum3": 11223,' +
                        '"jamTran": 1435,' +
                        '"kodeTran": "ABC123",' +
                        '"mutasiDebet": 130000000,' +
                        '"mutasiKredit": 13000000,' +
                        '"noRek": "326301020301234",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "AYOPOP Transfer Credit",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';
        customResponses.put('savingStatement', mockBodyRekor);

        String mockBodyRekon = '{' +
            '"errorCode":"",' +
            '"responseCode":"00",' +
            '"responseMessage":"",' +
            '"responseData": {' +
                '"detailData": [' +
                    '{'+
                        '"BillingCode":"14361525604",' +
                        '"Fee":"3000.00",' +
                        '"ID":251019,' +
                        '"RekDebet":"473701026064534",' +
                        '"RekDebetFee":"473701026064534",' +
                        '"RekKredit":"",' +
                        '"Remark":"AYOPOP  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"StatusRecon":"Unmatch",' +
                        '"Seq":"5041015",' +
                        '"StatusMCSDesc":"",' +
                        '"StatusMCS":"00",' +
                        '"TanggalTrans":""' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        customResponses.put('recon', mockBodyRekon);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(customResponses));

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 5) 8433 → jalur BRIVA
    // ==========================================
    @isTest
    static void test_8433_Briva(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE SCC_Account_Number__c = 'BRIVA-8433' LIMIT 1];

        Map<String, String> customResponses = new Map<String, String>();

        String mockBodyBriva = '{' +
                '"statusCode":200,' +
                '"errorCode":"000",' +
                '"responseCode":"00",' +
                '"responseMessage":"Success",' +
                '"errors":null,' +
                '"data": [' +
                    '{' +
                        '"brivaNo": "12345",' +
                        '"uniqueCode": "2513",' +
                        '"custCode": "2513500926",' +
                        '"nama": "Fuad",' +
                        '"keterangan": "",' +
                        '"amount": 130000000,' +
                        '"paymentDate": "2024-04-29 23:21:53",' +
                        '"tellerid": "8888657",' +
                        '"norek": "12345678901123",' +
                        '"seq": 99999,' +
                        '"trremk": "BFVA896895786576 FUAD:GAMING",' +
                        '"seqOther": "",' +
                        '"jaringan": "BFVA",' +
                        '"trstat": "SUKSES",' +
                        '"auxtrc": "7668",' +
                        '"julianDate": "24120",' +
                        '"trxID": "241208888657008999",' +
                        '"totalRow": 526,' +
                        '"pageShow": "1 / 1"' +
                    '}' +
                ']' +
            '}';
        customResponses.put('briva', mockBodyBriva);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(customResponses));

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Briva(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // =========================
    // 6) Cover logging error
    // =========================

    @isTest
    static void testInsertError() {
        // TO DO: implement unit test
        test.startTest();
        Account acc = new Account();
        try{
            insert acc;
        }
        catch(exception exc){
            SCC_Batch_AutoClosed_Briva.InsertErrorLog(exc);
        }
        test.stopTest();
    }
}