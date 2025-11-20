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
private class SCC_Batch_AutoClosed_Pulsa_Test {



     public class MultiEndpointMock implements HttpCalloutMock {

        private Map<String, String> responseMap;

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

    private static String buildQueryById(Id caseId){
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String addfield = ',SCC_Call_Type__r.External_Id__c';
        String cond     = 'IsClosed = false AND Id = \'' + caseId + '\'';
        return SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
    }

    @TestSetup
    static void makeData(){

        // Call Type & Feature
        SSC_Call_Type__c ct = Object_Test.setCallType('8434'); insert ct;

        SCC_Call_Type_Feature__c ctf = Object_Test.setFitur(ct.Id); insert ctf;

        // Master KOR (dipakai untuk 8809 → rekening koran)
        insert Object_test_RTGS.setMasterKor('KorPulSIM',  ct.Id, 'Telkomsel');

         // Master Mapping Feature (dipakai untuk → rekon)
        insert Object_test_RTGS.setMappingFeature('PULTSL002', ct.Id, ctf.Id, '', 'PUL-SIM MP', 'Telkomsel');

        List<Case> cases = new List<Case>();

        Case cs1 = Object_Test.setCase(ct.id);
        cs1.SCC_Amount__c = 100000;
        cs1.Status = 'New';
        cs1.SCC_Transaction_Date__c = Date.today();
        cs1.SCC_Account_Number__c = '20601031885500';
        cs1.scc_Provider__c = 'Telkomsel';
        cs1.scc_Billing_Number__c = '81278654453';
        cases.add(cs1);

        Case cs2 = Object_Test.setCase(ct.id);
        cs2.SCC_Amount__c = 100000;
        cs2.Status = 'New';
        cs2.SCC_Transaction_Date__c = Date.today();
        cs2.SCC_Account_Number__c = '20601031885500';
        cs2.scc_Provider__c = 'Telkomsel';
        cs2.scc_Billing_Number__c = '081390284127';
        cs2.scc_Notes__c = '{"Provider":"TELKOMSEL","Nomor HP":"081390284127","Channel":"BRimo","Waktu Transaksi":"2025-07-24 04:30:42","Remark":"PUL-SIM 081290808797MP 6032984864955061","Keterangan Tambahan":"Top Up Pulsa Gagal"}';
        cases.add(cs2);

        Case cs3 = Object_Test.setCase(ct.id);
        cs3.SCC_Amount__c = 100000;
        cs3.Status = 'New';
        cs3.SCC_Transaction_Date__c = Date.today();
        cs3.SCC_Account_Number__c = '20601031885500';
        cs3.scc_Billing_Number__c = '081390284128';
        cs3.Description = 'Provider: telkomsel - transaksi gagal';
        cases.add(cs3);
        


        insert cases;

        
    }

    @isTest
    static void nominalNotMatch() {
        Case c = [SELECT Id FROM Case WHERE scc_Billing_Number__c = '81278654453' LIMIT 1 ];
        c.SCC_Amount__c = 4000;
        update c;

        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)), 200);
        Test.stopTest();
    }

    @IsTest
    static void rekeningKoranMatch() {

        Case c = [SELECT Id FROM Case WHERE scc_Billing_Number__c = '81278654453' LIMIT 1 ];

        Map<String,String> responseMock = new Map<String,String>();

        String mockRekeningKoran = '{' +
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
                        '"mutasiKredit": 100000,' +
                        '"noRek": "20601031885500",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "KorPulSIM:081278654453:250719:56499",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';

        responseMock.put('savingStatement', mockRekeningKoran);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(responseMock));
        
        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)),200);
        Test.stopTest();
    }


    @IsTest
    static void rekeningKoranNotes() {

        Case c = [SELECT Id FROM Case WHERE scc_Billing_Number__c = '081390284127' LIMIT 1 ];

        Map<String,String> responseMock = new Map<String,String>();

        String mockRekeningKoran = '{' +
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
                        '"mutasiKredit": 100000,' +
                        '"noRek": "20601031885500",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "KorPulSIM:081278654453:250719:56499",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';

        responseMock.put('savingStatement', mockRekeningKoran);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(responseMock));
        
        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)),200);
        Test.stopTest();
    }

     @IsTest
    static void rekeningKoranDescription() {

        Case c = [SELECT Id FROM Case WHERE scc_Billing_Number__c = '081390284128' LIMIT 1 ];

        Map<String,String> responseMock = new Map<String,String>();

        String mockRekeningKoran = '{' +
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
                        '"mutasiKredit": 100000,' +
                        '"noRek": "20601031885500",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "KorPulSIM:081278654453:250719:56499",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';

        responseMock.put('savingStatement', mockRekeningKoran);

        Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(responseMock));
        
        Test.startTest();
        Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)),200);
        Test.stopTest();
    }

   @IsTest
   static void rekonMatch() {

    Case c = [SELECT Id , SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = '81278654453' LIMIT 1 ];

     Map<String,String> responseMock = new Map<String,String>();

        String mockRekeningKoran = '{' +
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
                        '"mutasiDebet": 100000,' +
                        '"mutasiKredit": 2000000,' +
                        '"noRek": "20601031885500",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "PUL-SIM 081278654453MP 6032984864955061",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';

        responseMock.put('savingStatement', mockRekeningKoran);

        String mockRekon = '{' +
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
                        '"Remark":"PUL-SIM 081278654453MP 6032984864955061",' +
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
        
        responseMock.put('recon', mockRekon);

    Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(responseMock));
    
    Test.startTest();
    Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)), 200);
    Test.stopTest();
   }


    @IsTest
   static void rekonUnmatch00() {

    Case c = [SELECT Id , SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = '81278654453' LIMIT 1 ];

     Map<String,String> responseMock = new Map<String,String>();

        String mockRekeningKoran = '{' +
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
                        '"mutasiDebet": 100000,' +
                        '"mutasiKredit": 2000000,' +
                        '"noRek": "20601031885500",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "PUL-SIM 081278654453MP 6032984864955061",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';

        responseMock.put('savingStatement', mockRekeningKoran);

        String mockRekon = '{' +
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
                        '"Remark":"PUL-SIM 081278654453MP 6032984864955061",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"StatusRecon":"Unmatch",' +
                        '"Seq":"5041015",' +
                        '"StatusMCSDesc":"Success",' +
                        '"StatusMCS":"00",' +
                        '"TanggalTrans":"'+ Date.today().format() +'"' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        
        responseMock.put('recon', mockRekon);

    Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(responseMock));
    
    Test.startTest();
    Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)), 200);
    Test.stopTest();
   }


    @IsTest
   static void rekonUnmatch() {

    Case c = [SELECT Id , SCC_Amount__c FROM Case WHERE scc_Billing_Number__c = '81278654453' LIMIT 1 ];

     Map<String,String> responseMock = new Map<String,String>();

        String mockRekeningKoran = '{' +
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
                        '"mutasiDebet": 100000,' +
                        '"mutasiKredit": 2000000,' +
                        '"noRek": "20601031885500",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "PUL-SIM 081278654453MP 6032984864955061",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';

        responseMock.put('savingStatement', mockRekeningKoran);

        String mockRekon = '{' +
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
                        '"Remark":"PUL-SIM 081278654453MP 6032984864955061",' +
                        '"Nominal":"' + String.valueOf(c.SCC_Amount__c) + '",' +
                        '"NoToken":"1111222233334444",' +
                        '"StatusRecon":"Unmatch",' +
                        '"Seq":"5041015",' +
                        '"StatusMCSDesc":"Success",' +
                        '"StatusMCS":"69",' +
                        '"TanggalTrans":"'+ Date.today().format() +'"' +
                    '}' +
                '],' +
                '"statusScheduler":"Done"' +
            '}' +
        '}';
        
        responseMock.put('recon', mockRekon);

    Test.setMock(HttpCalloutMock.class, new MultiEndpointMock(responseMock));
    
    Test.startTest();
    Database.executeBatch(new SCC_Batch_AutoClosed_Pulsa_Token(buildQueryById(c.Id)), 200);
    Test.stopTest();
   }



    @isTest
    static void testInsertError() {
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