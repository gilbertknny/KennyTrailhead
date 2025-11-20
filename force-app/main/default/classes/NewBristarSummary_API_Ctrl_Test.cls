@isTest
private class NewBristarSummary_API_Ctrl_Test {
    @TestSetup
    static void setupTestData() {
        Orgeh__c og = Object_Test.setOrgeh();
        insert og;
        // Create test data
        Orgeh__c og1 = new Orgeh__c(
            Cost_Center__c = 'PS85000',
            Cost_Center_Description__c = 'DIVISI SENTRA OPERASI'
        );
        Orgeh__c og2 = new Orgeh__c(
            Cost_Center__c = 'PS98502',
            Cost_Center_Description__c = 'DIVISI SERVICE & CONTACT CENTER'
        );
        insert new List<Orgeh__c>{og1, og2};
        Branch_Unit__c bu1 = Object_Test.setBranchUnit('113','CABANG','113','B');
        Branch_Unit__c bu2 = Object_Test.setBranchUnit('51','KANWIL','51','D');
        Branch_Unit__c bu3 = Object_Test.setBranchUnit('52','KANWIL','52','E');
        Branch_Unit__c bu4 = Object_Test.setBranchUnit('53','KANWIL','53','F');
        Branch_Unit__c bu5 = Object_Test.setBranchUnit('54','CABANG','54','G');
        Branch_Unit__c bu6 = Object_Test.setBranchUnit('55','CABANG','55','H');
        Branch_Unit__c bu7 = Object_Test.setBranchUnit('56','CABANG','56','I');
        insert new List<Branch_Unit__c>{bu1, bu2, bu3, bu4, bu5, bu6, bu7};

        Bristar_Summary__c bs1 = new Bristar_Summary__c(
            area__c = 'KP00',
            costCenter__c = 'PS98502',
            costCenterDesc__c = 'DIVISI SERVICE & CONTACT CENTER',
            openTicket__c = 2,
            closedTicket__c = 1,
            onSla__c = 3,
            overSla__c = 0,
            onSlaOpen__c = 3,
            overSlaClosed__c = 0,
            onSlaClosed__c = 0,
            overSlaOpen__c = 0,
            date__c = Datetime.now().addDays(-1).date()
        );
        Bristar_Summary__c bs2 = new Bristar_Summary__c(
            area__c = 'KP00',
            costCenter__c = 'PS98501',
            costCenterDesc__c = 'DIVISI SERVICE & CONTACT',
            openTicket__c = 4,
            closedTicket__c = 1,
            onSla__c = 3,
            overSla__c = 2,
            onSlaOpen__c = 2,
            onSlaClosed__c = 1,
            overSlaClosed__c = 0,
            date__c = Datetime.now().addDays(-1).date()
        );
        Bristar_Summary__c bs3 = new Bristar_Summary__c(
            area__c = 'KW',
            region__c = 'B',
            regionDesc__c = 'DIVISI SERVICE & CONTACT',
            mainBranch__c = '113',
            mainBranchDesc__c = '113 divisi',
            branch__c = '00113',
            branchDesc__c = '00123 divisi',
            openTicket__c = 4,
            closedTicket__c = 1,
            onSla__c = 3,
            overSla__c = 2,
            onSlaOpen__c = 2,
            onSlaClosed__c = 1,
            overSlaClosed__c = 0,
            overSlaOpen__c = 0,
            date__c = Datetime.now().addDays(-1).date()
        );
        Bristar_Summary__c bs4 = new Bristar_Summary__c(
            area__c = 'KW',
            region__c = 'B',
            regionDesc__c = 'DIVISI SERVICE & CONTACT',
            mainBranch__c = '113',
            mainBranchDesc__c = '124 divisi',
            branch__c = '00113',
            branchDesc__c = '00124 divisi',
            openTicket__c = 4,
            closedTicket__c = 1,
            onSla__c = 3,
            overSla__c = 2,
            onSlaOpen__c = 2,
            onSlaClosed__c = 1,
            overSlaClosed__c = 0,
            overSlaOpen__c = 0,
            date__c = Datetime.now().addDays(-1).date()
        );

        insert new List<Bristar_Summary__c>{bs1, bs2, bs3, bs4};

        SSC_Call_Type__c ct = Object_Test.setCaseType('8812');
        insert ct;
        Case cs = Object_Test.setCaseBristar('Escalate', ct.id);
        Case cs1 = Object_Test.setCaseBristar('New', ct.id);
        Case cs2 = Object_Test.setCaseBristar('Returned', ct.id);
        insert new List<Case>{cs, cs1, cs2};

        list<Case> lcs = [SELECT Region__c, Main_Branch__c, Branch_Code__c, Cost_Center__c FROM Case];
        System.debug('listCase :'+lcs);
    }   

    @isTest
    static void getBristarSummaryKPBlank() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKPBlankModel();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.BristarResponseKPModel();
        NewBristarSummary_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryKPBlank2() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKPBlank2Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.BristarResponseKPModel();
        NewBristarSummary_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryKPBlank3() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKPBlank3Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.BristarResponseKPModel();
        NewBristarSummary_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryKPBlank4() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKPBlank4Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.BristarResponseKPModel();
        NewBristarSummary_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryKPFalse() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKPFalseModel();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.BristarResponseKPModel();
        NewBristarSummary_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryKP() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKPModel();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.BristarResponseKPModel();
        NewBristarSummary_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryKP1() {
        list<Case> lcs = [SELECT Id, OwnerId, Region__c, Main_Branch__c, Branch_Code__c, Cost_Center__c FROM Case WHERE Status != 'Closed'];
        User us = [SELECT Id, SCC_Area__c, SCC_Branch__c, Branch_Unit__c, BranchCode__c, SCC_Cost_Center__c from user WHERE SCC_Area__c != null AND BranchCode__c != null AND SCC_Cost_Center__c != null AND IsActive = true AND SCC_Area__c = 'KP00' AND SCC_Cost_Center__c = 'PS98502' AND BranchCode__c = '00229' LIMIT 1];
        System.debug('user test :'+us);
        ID newOwnerId = us.Id; // Replace with the actual User or Queue Id

        // Loop through the list and update the owner
        for(Case c : lcs) {
            c.OwnerId = newOwnerId;
            c.Region__c = '';
        }
        // Perform the update
        try {
            update lcs;
        } catch(Exception e) {
            System.debug('Error updating cases: ' + e.getMessage());
        }
        list<Case> lcs2 = [SELECT Id, OwnerId, Region__c, Main_Branch__c, Branch_Code__c, Cost_Center__c, Area__c FROM Case WHERE Status != 'Closed'];
        System.debug('listCase :'+lcs2);
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type__r.Name,SCC_Call_Type__r.SSC_Case_Description__c', 'Case', '', '', '', '1');
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestKP1Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        BristarSummary_API_Ctrl.processDetailDataKP(Object_Test.getTestCaseKP(), maprc, 'KP','CC001','2024-11-01','2024-11-13',1,2,'OPEN');
        BristarSummary_API_Ctrl.processDetailDataKP(Object_Test.getTestCaseKP(), maprc, 'KP','CC001','2024-11-01','2024-11-13',1,2,'Closed');
        BristarSummary_API_Ctrl.createTicketModelKP(cs,'Closed');
        BristarSummary_API_Wrapper.GetResponseKP1_Model resrcc = Object_Test.BristarResponseKP1Model();
        NewBristarSummary_API_Ctrl.returnAPIKP1(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryRO() {
        List<Bristar_Summary__c> bs = [SELECT Id, costCenter__c, costCenterDesc__c, region__c, regionDesc__c, mainBranch__c, mainBranchDesc__c, branch__c, branchDesc__c, onSla__c, overSla__c, onSlaClosed__c, onSlaOpen__c, openTicket__c, closedTicket__c FROM Bristar_Summary__c];
        System.debug('Bristar Test Class:'+bs);
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestROModel();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO_Model resrcc = Object_Test.BristarResponseROModel();
        NewBristarSummary_API_Ctrl.returnAPIRO(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryROOpen() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestROModel1();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO_Model resrcc = Object_Test.BristarResponseROModel();
        NewBristarSummary_API_Ctrl.returnAPIRO(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryROClosed() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestROModel2();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO_Model resrcc = Object_Test.BristarResponseROModel();
        NewBristarSummary_API_Ctrl.returnAPIRO(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryROCancel() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestROModel3();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO_Model resrcc = Object_Test.BristarResponseROModel();
        NewBristarSummary_API_Ctrl.returnAPIRO(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryRO1() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestRO1Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO1_Model resrcc = Object_Test.BristarResponseRO1Model();
        NewBristarSummary_API_Ctrl.returnAPIRO1(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryRO2() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestRO2Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO2_Model resrcc = Object_Test.BristarResponseRO2Model();
        NewBristarSummary_API_Ctrl.returnAPIRO2(resrcc);
        Test.stopTest();
    }

    @isTest
    static void getBristarSummaryRO3() {
        Test.startTest();
        BristarSummary_API_Wrapper.GetRequest_Model rcc = Object_Test.BristarRequestRO3Model();
        NewBristarSummary_API_Ctrl.getBristarSummary(rcc);
        BristarSummary_API_Wrapper.GetResponseRO3_Model resrcc = Object_Test.BristarResponseRO3Model();
        NewBristarSummary_API_Ctrl.returnAPIRO3(resrcc);
        Test.stopTest();
    }
}