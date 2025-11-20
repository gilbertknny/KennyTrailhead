/**
 * @description       : Unit Test lengkap untuk SCC_Batch_AutoClosed_8809
 * @author            : Suherbing Septian
 * @last modified on  : 10/13/2025
 * @last modified by  : Suherbing Septian
**/
@isTest
private class SCC_Batch_AutoClosed_8809_Test {

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
        SSC_Call_Type__c ct8809 = Object_Test.setCallType('8809'); insert ct8809;
        SSC_Call_Type__c ct8808 = Object_Test.setCallType('8808'); insert ct8808;

        SCC_Call_Type_Feature__c f8809 = Object_Test.setFitur(ct8809.Id); insert f8809;
        SCC_Call_Type_Feature__c f8808 = Object_Test.setFitur(ct8808.Id); insert f8808;

        // Master Mapping Feature (dipakai untuk 8808 → rekon)
        insert Object_test_RTGS.setMappingFeature('PLNPRE001', ct8808.Id, f8808.Id, '', 'PLN-PRA', '');
        insert Object_test_RTGS.setMappingFeature('PLNPST001', ct8809.Id, f8809.Id, '', 'PLNPOST', '');

        // Master KOR (dipakai untuk 8809 → rekening koran)
        insert Object_test_RTGS.setMasterKor('KORPLNPRE',  ct8808.Id, '');
        insert Object_test_RTGS.setMasterKor('KORPLNPOST', ct8809.Id, '');

        // [FIX] Membuat data Case yang lengkap untuk pengujian
        List<Case> casesToInsert = new List<Case>();
        
        // Case untuk skenario 8809
        Case c8809 = Object_Test.setCase(ct8809.Id);
        c8809.SCC_Amount__c = 130000000;
        c8809.Status = 'New';
        c8809.SCC_Transaction_Date__c = Date.today();
        c8809.SCC_Account_Number__c = 'ACCOUNT-8809';
        c8809.scc_Billing_Number__c = 'BILLING-8809'; // ID unik untuk query
        casesToInsert.add(c8809);

        // Case untuk skenario 8808
        Case c8808 = Object_Test.setCase(ct8808.Id);
        c8808.SCC_Amount__c = 130000000;
        c8808.Status = 'New';
        c8808.SCC_Transaction_Date__c = Date.today();
        c8808.SCC_Account_Number__c = 'ACCOUNT-8808';
        c8808.scc_Billing_Number__c = 'BILLING-8808'; // ID unik untuk query
        casesToInsert.add(c8808);

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
    static void test_EarlyClose_8809(){
        Case c = [SELECT Id FROM Case WHERE scc_Billing_Number__c = 'BILLING-8809' LIMIT 1];
        c.SCC_Amount__c = 5000;
        update c;
        
        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 2) 8809 → jalur Rekening Koran (match)
    // ==========================================
    @isTest
    static void test_8809_ViaRekeningKoran(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8809' LIMIT 1];
        
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
                        '"trremk": "KORPLNPOST Transfer Credit",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    @isTest
    static void test_8809_ViaRekonMatch(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8809' LIMIT 1];
        
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
                        '"trremk": "KORPLNPOST Transfer Credit",' +
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
                        '"Remark":"PLNPOST  14361525604NBMB5221840977221143",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    @isTest
    static void test_8809_ViaRekonUnmatch(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8809' LIMIT 1];
        
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
                        '"trremk": "KORPLNPOST Transfer Credit",' +
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
                        '"Remark":"PLNPOST  14361525604NBMB5221840977221143",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 3) 8808 → jalur Rekon (MATCH)
    // ==========================================
    @isTest
    static void test_8808_Rekon_MATCH(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8808' LIMIT 1];

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
                        '"trremk": "KORPLNPRE Transfer Credit",' +
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
                        '"Remark":"PLN-PRA  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"StatusRecon":"Match",' +
                        '"Seq":"5041015",' +
                        '"StatusMCSDesc":"",' +
                        '"StatusMCS":"0",' +
                        '"TanggalTrans":""' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        customResponses.put('recon', mockBodyRekon);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(customResponses));

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 4) 8808 → jalur Rekon (UNMATCH + MCS=00)
    // ==========================================
    @isTest
    static void test_8808_Rekon_UNMATCH(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8808' LIMIT 1];

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
                        '"trremk": "KORPLNPRE Transfer Credit",' +
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
                        '"Remark":"PLN-PRA  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"Seq":"5041015",' +
                        '"StatusRecon":"Unmatch",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 4) 8808 → jalur Rekon (UNMATCH + MCS=00)
    // ==========================================
    @isTest
    static void test_8808_RekeningKoran_ViaRekon(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8808' LIMIT 1];

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
                        '"trremk": "KORPLNPRE Transfer Credit",' +
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
                        '"Remark":"PLN-PRA  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"Seq":"5041015",' +
                        '"StatusRecon":"Unmatch",' +
                        '"StatusMCSDesc":"",' +
                        '"StatusMCS":"0",' +
                        '"TanggalTrans":""' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        customResponses.put('recon', mockBodyRekon);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(customResponses));

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 4) 8808 → jalur Rekon (UNMATCH + MCS=00)
    // ==========================================
    @isTest
    static void test_8808_RekonMatch_ViaRekeningKoran(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8808' LIMIT 1];
        SCC_Call_Type_Feature__c ft = [SELECT Id, Fitur_ID__c FROM SCC_Call_Type_Feature__c WHERE Call_Type__r.External_Id__c = '8808' LIMIT 1];
        ft.Fitur_ID__c = '';
        update ft;  
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
                        '"trremk": "PLN-PRA Transfer Credit",' +
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
                        '"Remark":"PLN-PRA  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"Seq":"5041015",' +
                        '"StatusRecon":"Match",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 4) 8808 → jalur Rekon (UNMATCH + MCS=00)
    // ==========================================
    @isTest
    static void test_8808_RekonUnmatch_ViaRekeningKoran(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8808' LIMIT 1];
        SCC_Call_Type_Feature__c ft = [SELECT Id, Fitur_ID__c FROM SCC_Call_Type_Feature__c WHERE Call_Type__r.External_Id__c = '8808' LIMIT 1];
        ft.Fitur_ID__c = '';
        update ft;  
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
                        '"trremk": "PLN-PRA Transfer Credit",' +
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
                        '"Remark":"PLN-PRA  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"Seq":"5041015",' +
                        '"StatusRecon":"Unmatch",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // ==========================================
    // 4) 8808 → jalur Rekon (UNMATCH + MCS=00)
    // ==========================================
    @isTest
    static void test_8808_ViaRekeningKoran(){
        Case c = [SELECT Id, SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = 'BILLING-8808' LIMIT 1];
        c.SCC_Amount__c = 700000;
        update c;
        SCC_Call_Type_Feature__c ft = [SELECT Id, Fitur_ID__c FROM SCC_Call_Type_Feature__c WHERE Call_Type__r.External_Id__c = '8808' LIMIT 1];
        ft.Fitur_ID__c = '';
        update ft;  
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
                        '"mutasiDebet": 70000,' +
                        '"mutasiKredit": 700000,' +
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
                        '"trremk": "KORPLNPRE Transfer Credit",' +
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
                        '"Remark":"PLN-PRA  14361525604NBMB5221840977221143",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"Seq":"5041015",' +
                        '"StatusRecon":"Match",' +
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
        Database.executeBatch(new SCC_Batch_AutoClosed_8809(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    // =========================
    // 7) Cover logging error
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
            SCC_Batch_AutoClosed_8809.InsertErrorLog(exc);
        }
        test.stopTest();
    }
}