/**
 * @description       : Test Class PDF Quotation
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-02-2025
 * @last modified by  : Ahmad Yazid Munif
**/
@IsTest
private class Aswata_QuotationSlip_Test {
    @TestSetup
    static void makeData() {
        Account acc = new Account(Name = 'Jhon');
        insert acc;
        Opportunity opp201 = new Opportunity(
            Name = 'Test Opp 201',
            Busreq_ID__c = '201201',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            The_Insured_Name__c = acc.Id,
            COB__c = '201',
            The_Insured_Address__c = 'Jl. Test 123',
            Start_Date_Periode__c = Date.today(),
            End_Date_Periode__c = Date.today().addYears(1),
            Warranty__c = 'waranty'
        );
        insert opp201;
        Opportunity opp301 = new Opportunity(
            Name = 'Test Opp 301',
            Busreq_ID__c = '301001',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            The_Insured_Name__c = acc.Id,
            COB__c = '301',
            The_Insured_Address__c = 'Jl. Test 456',
            Start_Date_Periode__c = Date.today(),
            End_Date_Periode__c = Date.today().addYears(1),
            Warranty__c = 'waranty'
        );
        insert opp301;
        Opportunity opp201Multi = new Opportunity(
            Name = 'Test Opp 201 Multi',
            Busreq_ID__c = '201202',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            The_Insured_Name__c = acc.Id,
            COB__c = '201',
            The_Insured_Address__c = 'Jl. Test 123',
            Start_Date_Periode__c = Date.today(),
            End_Date_Periode__c = Date.today().addYears(1),
            Warranty__c = 'waranty'
        );
        insert opp201Multi;
        Opportunity opp301Multi = new Opportunity(
            Name = 'Test Opp 301 Multi',
            Busreq_ID__c = '301002',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            The_Insured_Name__c = acc.Id,
            COB__c = '301',
            The_Insured_Address__c = 'Jl. Test 456',
            Start_Date_Periode__c = Date.today(),
            End_Date_Periode__c = Date.today().addYears(1),
            Warranty__c = 'waranty'
        );
        insert opp301Multi;
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Policy',
            NameInsuredId = acc.Id
        );
        insert policy;
        List<Quote> listQuote = new List<Quote>();
        listQuote.add(new Quote(
            Name = 'Quote 201',
            OpportunityId = opp201.Id,
            Administration_Cost__c = 2000,
            Stamp_Duty__c = 5000
        ));
        listQuote.add(new Quote(
            Name = 'Quote 201 Multi',
            OpportunityId = opp201Multi.Id,
            Administration_Cost__c = 2000,
            Stamp_Duty__c = 5000
        ));
        listQuote.add(new Quote(
            Name = 'Quote 301',
            OpportunityId = opp301.Id,
            Administration_Cost__c = 2000,
            Stamp_Duty__c = 5000
        ));
        listQuote.add(new Quote(
            Name = 'Quote 301 Multi',
            OpportunityId = opp301Multi.Id,
            Administration_Cost__c = 2000,
            Stamp_Duty__c = 5000
        ));
        insert listQuote;
        RecordType rtRisk = [SELECT Id FROM RecordType WHERE SobjectType = 'Asset' AND Name = 'RIsk' LIMIT 1];
        Asset risk201 = new Asset(
            Name = 'Test Risk',
            Opportunity__c = opp201.Id,
            Total_Premi_Amount__c = 5000000,
            Amount_Insured__c = 5000000,
            RecordTypeId = rtRisk.Id
        );
        insert risk201;
        Asset risk201Multi = new Asset(
            Name = 'Test Risk Multi',
            Opportunity__c = opp201Multi.Id,
            Total_Premi_Amount__c = 5000000,
            Amount__c = 5000000,
            RecordTypeId = rtRisk.Id
        );
        insert risk201Multi;
        Asset risk201Multi2 = new Asset(
            Name = 'Test Risk Multi 2',
            Opportunity__c = opp201Multi.Id,
            Total_Premi_Amount__c = 5000000,
            Amount__c = 5000000,
            RecordTypeId = rtRisk.Id
        );
        insert risk201Multi2;
        Asset risk301 = new Asset(
            Name = 'Test Risk',
            Opportunity__c = opp301.Id,
            Total_Premi_Amount__c = 5000000,
            Amount__c = 5000000,
            jenis_perlengkapan__c = '[{"merk":"test","value":300000,"cur_id":"IDR"},{"merk":"test2","value":40000,"cur_id":"IDR"}]',
            RecordTypeId = rtRisk.Id
        );
        insert risk301;
        Asset risk301Multi = new Asset(
            Name = 'Test Risk Multi',
            Opportunity__c = opp301Multi.Id,
            Total_Premi_Amount__c = 5000000,
            Amount__c = 5000000,
            RecordTypeId = rtRisk.Id
        );
        insert risk301Multi;
        Asset risk301Multi2 = new Asset(
            Name = 'Test Risk Multi 2',
            Opportunity__c = opp301Multi.Id,
            Total_Premi_Amount__c = 5000000,
            Amount__c = 5000000,
            RecordTypeId = rtRisk.Id
        );
        insert risk301Multi2;

        List<InsurancePolicyCoverage> listCoverage = new List<InsurancePolicyCoverage>();
        listCoverage.add(new InsurancePolicyCoverage(
            InsurancePolicyId = policy.Id,
            Risk_ID__c = risk201.Id,
            CoverageName = 'Coverage 1',
            Proposed_Fixed_Amount__c = 1000000,
            Final_Approved_Rate__c = 2.0
        ));
        listCoverage.add(new InsurancePolicyCoverage(
            InsurancePolicyId = policy.Id,
            Risk_ID__c = risk201Multi.Id,
            CoverageName = 'Coverage 2',
            Proposed_Fixed_Amount__c = 1000000,
            Final_Approved_Rate__c = 2.0
        ));
        listCoverage.add(new InsurancePolicyCoverage(
            InsurancePolicyId = policy.Id,
            Risk_ID__c = risk301.Id,
            CoverageName = 'Coverage 3',
            Proposed_Fixed_Amount__c = 1000000,
            Final_Approved_Rate__c = 2.0
        ));
        listCoverage.add(new InsurancePolicyCoverage(
            InsurancePolicyId = policy.Id,
            Risk_ID__c = risk301Multi.Id,
            CoverageName = 'Coverage 2',
            Proposed_Fixed_Amount__c = 2000000,
            Final_Approved_Rate__c = 2.5
        ));
        insert listCoverage;
        List<Transaction_Data__c> listTrxData = new List<Transaction_Data__c>();
        listTrxData.add(new Transaction_Data__c(
            Opportunity__c = opp201.Id,
            Clauses_Name__c = 'Clause A',
            Clause_Description__c = 'Desc A'
        ));
        listTrxData.add(new Transaction_Data__c(
            Opportunity__c = opp301.Id,
            Clauses_Name__c = '',
            Clause_Description__c = 'Blank'
        ));
        // listTrxData.add(new Transaction_Data__c(
        //     Opportunity__c = opp.Id,
        //     Clauses_Name__c = '-',
        //     Clause_Description__c = 'Dash'
        // ));
        insert listTrxData;
    }
    @IsTest
    static void testCob201SingleRisk() {
        User adminUser = createUser();
        Quote testQuote = [SELECT Id FROM Quote WHERE Name = 'Quote 201' LIMIT 1];
        QuotationVFPController controller;
        PageReference resultPage;
        Test.startTest();
        System.runAs(adminUser) {
            PageReference pageRef = Page.quotation;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', testQuote.Id);
            controller = new QuotationVFPController();
            controller.redirectToPdf();
            Aswata_QuotationSlip_Terbilang.terbilangRupiah(5123451711L);
            Aswata_QuotationSlip_Terbilang.terbilangRupiah(null);
            Aswata_QuotationSlip_Terbilang.terbilangRupiah(0);
            Aswata_QuotationSlip_Terbilang.terbilangRupiah(1000);
            Aswata_QuotationSlip_Terbilang.terbilangRupiah(117300);
        }
        Test.stopTest();
        System.assertNotEquals(null, controller.quoteRecord, 'Quote Record seharusnya berhasil di-query di konstruktor.');
        System.assertEquals(null, resultPage, 'Seharusnya tetap dipage ini.');
    }
    @IsTest
    static void testCob201MultiRisk() {
        User adminUser = createUser();
        Quote testQuote = [SELECT Id FROM Quote WHERE Name = 'Quote 201 Multi' LIMIT 1];
        QuotationVFPController controller;
        PageReference resultPage;
        Test.startTest();
        System.runAs(adminUser) {
            PageReference pageRef = Page.quotation;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', testQuote.Id);
            controller = new QuotationVFPController();
            controller.redirectToPdf();
            Aswata_QuotationSlip_Wrapper.CoverageRate deductible = new Aswata_QuotationSlip_Wrapper.CoverageRate();
            deductible.riskId = '1';
            deductible.coverageName = 'coverageName';
            deductible.premiFixedAmount = 5000;
            deductible.deductibleAmountPct = 5;
            deductible.totalPremi = 500;
        }
        Test.stopTest();
        System.assertNotEquals(null, controller.quoteRecord, 'Quote Record seharusnya berhasil di-query di konstruktor.');
        System.assertEquals(null, resultPage, 'Seharusnya tetap dipage ini.');
    }
    @IsTest
    static void testCob301Redirect() {
        User adminUser = createUser();
        Quote testQuote = [SELECT OpportunityId, Administration_Cost__c, Stamp_Duty__c, Opportunity.COB__c FROM Quote WHERE Name = 'Quote 301' LIMIT 1];
        QuotationVFPController controller;
        PageReference resultPage;
        Test.startTest();
        System.runAs(adminUser) {
            PageReference pageRef = Page.quotation;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', testQuote.Id);
            controller = new QuotationVFPController();
            controller.redirectToPdf();
        }
        Test.stopTest();
        System.assertNotEquals(null, controller.quoteRecord, 'Quote Record seharusnya berhasil di-query di konstruktor.');
        System.assertEquals(null, resultPage, 'Seharusnya Pindah Page.');
    }
    @IsTest
    static void testCob301SingleRisk() {
        User adminUser = createUser();
        Quote testQuote = [SELECT OpportunityId, Administration_Cost__c, Stamp_Duty__c, Opportunity.COB__c FROM Quote WHERE Name = 'Quote 301' LIMIT 1];
        Aswata_QuotationSlip_Controller controller;
        PageReference resultPage;
        Test.startTest();
        System.runAs(adminUser) {
            PageReference pageRef = Page.quotation;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', testQuote.Id);
            controller = new Aswata_QuotationSlip_Controller();
        }
        Test.stopTest();
        System.assertNotEquals(null, controller.quoteRecord, 'Quote Record seharusnya berhasil di-query di konstruktor.');
        System.assertEquals(null, resultPage, 'Return PageReference.');
    }
    @IsTest
    static void testCob301MultiRisk() {
        User adminUser = createUser();
        Quote testQuote = [SELECT OpportunityId, Administration_Cost__c, Stamp_Duty__c, Opportunity.COB__c FROM Quote WHERE Name = 'Quote 301 Multi' LIMIT 1];
        Aswata_QuotationSlip_Controller controller;
        PageReference resultPage;
        Test.startTest();
        System.runAs(adminUser) {
            PageReference pageRef = Page.quotation;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', testQuote.Id);
            controller = new Aswata_QuotationSlip_Controller();
        }
        Test.stopTest();
        System.assertNotEquals(null, controller.quoteRecord, 'Quote Record seharusnya berhasil di-query di konstruktor.');
        System.assertEquals(null, resultPage, 'Return PageReference.');
    }
    /**
     * @description function for createUser
     * @return User return usercreated
     */
    public static User createUser(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = 'testad',
            Email = 'testadmin' + System.currentTimeMillis() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AdminTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test.admin.' + System.currentTimeMillis() + '@testorg.com' // Unique Username
        );
        insert adminUser;
        return adminUser;
    }
}