/**
 * @description       : Test class for SCC_Batch_AutoClosed_EDC
 * @last modified on  : 03-04-2025
 * @last modified by  : Ahmad Yazid Munif
 */
@isTest
private class SCC_Batch_AutoClosed_EDC_Test {
    @testSetup
    static void setupTestData() {
        List<SSC_Call_Type__c> caseType = new List<SSC_Call_Type__c>();
        SSC_Call_Type__c type = new SSC_Call_Type__c(
            Name = '8412',
            External_Id__c = '8412',
            SCC_Customer_Segment__c = 'Segment 1',
            SSC_Product_L1__c = 'Savings',
            SSC_Product_L2__c = 'Digital Savings',
            SSC_Case_Category__c = 'Inquiry',
            SSC_Case_Description__c = 'Description 1',
            Active__c = true);
        SSC_Call_Type__c type2 = new SSC_Call_Type__c(
            Name = 'Other',
            External_Id__c = 'Other',
            SCC_Customer_Segment__c = 'Segment 2',
            SSC_Product_L1__c = 'Savings',
            SSC_Product_L2__c = 'Digital Savings',
            SSC_Case_Category__c = 'Inquiry',
            SSC_Case_Description__c = 'Description 2',
            Active__c = true);
        caseType.add(type);
        caseType.add(type2);
        insert caseType;

        // List<SCC_Call_Type_Feature__c> caseTypeFeatures = new List<SCC_Call_Type_Feature__c>();
        // SCC_Call_Type_Feature__c callTypeFeature = new SCC_Call_Type_Feature__c(
        //     Name = '8412',
        //     Call_Type__c = type.Id
        // );
        // SCC_Call_Type_Feature__c callTypeFeatureOther = new SCC_Call_Type_Feature__c(
        //     Name = '8422',
        //     Call_Type__c = type2.Id
        // );
        // caseTypeFeatures.add(callTypeFeature);
        // caseTypeFeatures.add(callTypeFeatureOther);
        // insert caseTypeFeatures;
        List<Master_Kor__c> masterKorList = new List<Master_Kor__c>();
        Master_Kor__c masterKor1 = new Master_Kor__c(
            Name = '089656675766',
            Case_Type__c = type.Id);
        Master_Kor__c masterKor2 = new Master_Kor__c(
            Name = '601301324190401500861115',
            Case_Type__c = type2.Id);
        // for (Integer i = 0; i < 2; i++) {
        //     Master_Kor__c masterKor = new Master_Kor__c(
        //         Name = '089656675766',
        //         Case_Type__c = (i==0)?type.Id:type2.Id
        //     );
        //     masterKorList.add(masterKor);
        // }
        masterKorList.add(masterKor1);
        masterKorList.add(masterKor2);
        insert masterKorList;
        // List<Case> cases = new List<Case>();
        // for (Integer i = 0; i < 3; i++) {
        //     String idType = (Math.mod(i, 2) == 0) ? type.Id: type2.Id;
        //     System.debug('idType >> '+idType);
        //     Case c = new Case(
        //         Status = 'Working',
        //         SCC_Account_Number__c = '1234567890',
        //         SCC_Transaction_Date__c = Date.today().addDays(-5),
        //         SCC_Amount__c = 1000,
        //         No_Remintance__c = '089656675766',
        //         SCC_Call_Type__c = idType
        //     );
        //     cases.add(c);
        // }
        // insert cases;
        List<Case> cases = new List<Case>();
        Case testCase = new Case(
            Status = 'Working',
            SCC_Account_Number__c = '1234567890',
            SCC_Transaction_Date__c = Date.today().addDays(-5),
            SCC_Amount__c = 0,
            No_Remintance__c = '089656675766',
            SCC_Call_Type__c = type.Id
        );
        Case testCase2 = new Case(
            Status = 'Working',
            SCC_Account_Number__c = '1234567891',
            SCC_Transaction_Date__c = Date.today().addDays(-5),
            SCC_Amount__c = 100000,
            No_Remintance__c = '089656675766',
            SCC_Call_Type__c = type2.Id
        );
        cases.add(testCase);
        cases.add(testCase2);
        System.debug(
            'Number of cases: ' + cases.size()
        );
        insert cases;
        List<SCC_Rekening_Koran__c> rekKoran = new List<SCC_Rekening_Koran__c>();
        for (Case c : cases) {
            SCC_Rekening_Koran__c rek = new SCC_Rekening_Koran__c(
                SCC_Case__c = c.Id,
                SCC_trremk__c = 'Test Remark'
            );
            rekKoran.add(rek);
        }
        System.debug(
            'Number of rekKoran: ' + rekKoran.size()
        );
        insert rekKoran;
    }

    @isTest
    static void testInsertErrorLog() {
        Test.startTest();
        try {
            Integer i = 1/0;
        } catch (Exception e) {
            SCC_Batch_AutoClosed_EDC.insertErrorLog(e);
        }
        Test.stopTest();
    }
    @isTest
    static void testBatchWithEmptyResult() {
        // Menguji kasus di mana query tidak mengembalikan hasil apa pun
        String emptyQuery = 'SELECT Id FROM Case WHERE CreatedDate > TODAY';
        
        Test.startTest();
        SCC_Batch_AutoClosed_EDC batch = new SCC_Batch_AutoClosed_EDC(emptyQuery);
        Database.executeBatch(batch, 10);
        Test.stopTest();
        
        // Tidak ada perubahan yang diharapkan, tetapi batch harus berjalan tanpa error
        System.assertEquals(0, [SELECT COUNT() FROM Case WHERE Status = 'Closed'], 'Tidak ada Case yang seharusnya closed');
    }
    @isTest
    static void testBatchExecution() {
        Integer initialOpenCount = [SELECT COUNT() FROM Case WHERE Status = 'Working'];
        System.debug('initialOpenCount '+initialOpenCount);
        
        SavingMutationMock mock = new SavingMutationMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,mock);
        // Execute the batch
        String query = 'SELECT Id, No_Remintance__c, SCC_Account_Number__c, SCC_Transaction_Date__c, ' +
                      'SCC_Amount__c, Status, SCC_Status_Transaksi__c, SCC_Call_Type__c, SCC_Call_Type__r.external_id__c ' +
                      'FROM Case WHERE Status = \'Working\'';
        
        SCC_Batch_AutoClosed_EDC batchJob = new SCC_Batch_AutoClosed_EDC(query);
        System.debug('batchJob '+batchJob);
        Database.executeBatch(batchJob);
        
        Test.stopTest();
        
        // Verify results
        List<Case> updatedCases = [
            SELECT Id, Status, SCC_Status_Transaksi__c,No_Remintance__c, 
            SCC_Nomor_Remittence__c 
            FROM Case 
            WHERE SCC_Closure_Comments__c = 'testClass'
        ];

        Integer closedCasesCount = [SELECT COUNT() FROM Case WHERE Status = 'Closed' AND SCC_Status_Transaksi__c = 'Gagal'];
        Integer remainingWorkingCount = [SELECT COUNT() FROM Case WHERE Status = 'Working'];
        List<SCC_Rekening_Koran__c> createdRK = [SELECT Id, SCC_Case__c FROM SCC_Rekening_Koran__c];

        System.assertEquals(initialOpenCount, closedCasesCount + remainingWorkingCount, 'Jumlah total case tidak sama yang close ditambah dengan yang masih Working');
        Map<Id, SCC_Rekening_Koran__c> rekKoranByCaseId = new Map<Id, SCC_Rekening_Koran__c>();
        for (SCC_Rekening_Koran__c rk : createdRK) {
            rekKoranByCaseId.put(rk.SCC_Case__c, rk);
        }

        for (Case c : [SELECT Id, Status, SCC_Status_Transaksi__c FROM Case WHERE Status = 'Closed']) {
            System.assert(rekKoranByCaseId.containsKey(c.Id), 
                        'Setiap case yang close harus memiliki rekening koran yang sama');
            System.assertEquals('Gagal', c.SCC_Status_Transaksi__c, 
                        'Closed case harus memiliki SCC_Status_Transaksi__c = Gagal');
        }
    }
    @isTest
    static void testBatchExecutionException() {
        Integer initialOpenCount = [SELECT COUNT() FROM Case WHERE Status = 'Working'];
        System.debug('initialOpenCount '+initialOpenCount);
        
        SavingMutationMock mock = new SavingMutationMock();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class,mock);
        // Execute the batch
        String query = 'SELECT Id, No_Remintance__c, SCC_Account_Number__c, SCC_Transaction_Date__c, ' +
                      'SCC_Amount__c, Status, SCC_Status_Transaksi__c ' +
                      'FROM Case WHERE Status = \'Working\'';
        
        SCC_Batch_AutoClosed_EDC batchJob = new SCC_Batch_AutoClosed_EDC(query);
        System.debug('batchJob '+batchJob);
        Database.executeBatch(batchJob);
        
        Test.stopTest();
        
        // Verify results
        List<Case> updatedCases = [
            SELECT Id, Status, SCC_Status_Transaksi__c,No_Remintance__c, 
            SCC_Nomor_Remittence__c 
            FROM Case 
            WHERE SCC_Closure_Comments__c = 'testClass'
        ];

        Set<Id> closedCasesId = new Set<Id>();
        
        Integer closedCasesCount = [SELECT COUNT() FROM Case WHERE Status = 'Closed' AND SCC_Status_Transaksi__c = 'Gagal'];
        List<Case> closedCasesCase = [SELECT Id FROM Case WHERE Status = 'Closed' AND SCC_Status_Transaksi__c = 'Gagal'];
        Set<Id> closedCaseIds = new Set<Id>();
        for (Case c : closedCasesCase) {
            closedCaseIds.add(c.Id);
        }
        Integer remainingWorkingCount = [SELECT COUNT() FROM Case WHERE Status = 'Working'];
        List<SCC_Rekening_Koran__c> createdRK = [SELECT Id, SCC_Case__c FROM SCC_Rekening_Koran__c WHERE SCC_Case__c in :closedCaseIds];

        System.assertEquals(initialOpenCount, closedCasesCount + remainingWorkingCount, 'Jumlah total case tidak sama yang close ditambah dengan yang masih Working');
        Map<Id, SCC_Rekening_Koran__c> rekKoranByCaseId = new Map<Id, SCC_Rekening_Koran__c>();
        for (SCC_Rekening_Koran__c rk : createdRK) {
            rekKoranByCaseId.put(rk.SCC_Case__c, rk);
        }

        for (Case c : [SELECT Id, Status, SCC_Status_Transaksi__c FROM Case WHERE Status = 'Closed']) {
            System.assert(rekKoranByCaseId.containsKey(c.Id), 
                        'Setiap case yang close harus memiliki rekening koran yang sama');
            System.assertEquals('Gagal', c.SCC_Status_Transaksi__c, 
                        'Closed case harus memiliki SCC_Status_Transaksi__c = Gagal');
        }
    }
    private class SavingMutationMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            
            String responseBody = '{' +
                '"statusCode": 200,' +
                '"errorCode": null,' +
                '"responseCode": "0",' +
                '"responseMessage": "Operation successful",' +
                '"errors": [],' +
                '"data": [';
            List<Case> cases = [SELECT Id, No_Remintance__c FROM Case WHERE Status = 'Working'];
            for (Integer i = 0; i < cases.size(); i++) {
                String noRemittance = cases[i].No_Remintance__c;
                
                responseBody += '{' +
                    '"auxtrc": "AUXTRC' + i + '",' +
                    '"deskTran": "Deskripsi Transaksi ' + i + '",' +
                    '"glsign": "+",' +
                    '"idNum": ' + (1000 + i) + ',' +
                    '"idNum2": ' + (2000 + i) + ',' +
                    '"idNum3": ' + (3000 + i) + ',' +
                    '"jamTran": ' + (100000 + i) + ',' +
                    '"kodeTran": "KT' + i + '",' +
                    '"mutasiDebet": 0,' +
                    '"mutasiKredit": ' + 0 + ',' +
                    '"noRek": ' + (1234567890 + i) + ',' +
                    '"saldoAkhirMutasi": ' + (10000 + (1000 * (i + 1))) + ',' +
                    '"saldoAwalMutasi": 10000,' +
                    '"seq": ' + i + ',' +
                    '"serial": "S' + i + '",' +
                    '"terbilang": "Satu Juta Rupiah",' +
                    '"tglEfektif": "2025-03-03",' +
                    '"tglTran": "2025-03-03",' +
                    '"tlbds1": "TBLDS1' + i + '",' +
                    '"tlbds2": "TBLDS2' + i + '",' +
                    '"trremk": "' + noRemittance + '",' +
                    '"truser": "USER' + i + '"' +
                '}';
                
                if (i < cases.size() - 1) {
                    responseBody += ',';
                }
            }
            
            responseBody += ']}';
            System.debug('responseBody'+responseBody);
            res.setBody(responseBody);
            return res;
        }
    }
}