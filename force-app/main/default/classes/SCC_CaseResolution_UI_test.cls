@isTest
public with sharing class SCC_CaseResolution_UI_test {
    @TestSetup
    static void setupdata(){
        SSC_Call_Type__c ct = Object_Test.setCallType('8812');
        insert ct;
        SCC_Call_Type_Feature__c ft = Object_Test.setFitur(ct.id);
        insert ft;
        SCC_Terminal_ID__c tm = Object_Test.setTerminalID();
        insert tm;
        Branch_Unit__c bu = Object_Test.setBranchUnit('52','KANWIL','52','E');
        insert bu;
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        cs.Unit_Kerja_2__c = bu.id;
        insert cs;
        SCC_Rekening_Koran__c rek = Object_Test.setRekeningKoran(cs.id);
        insert rek;
        SCC_Rekon__c rk = Object_Test.setRekon(cs.id);
        insert rk;
        SCC_Berita_Acara_Opname__c bao = Object_Test.setBeritaAcaraOpname(cs.id);
        insert bao;
        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;
        Adjust_Deposit__c ad = Object_Test_Brizzi.setAdjustDeposit(cs.id);
        insert ad;
        Brizzi_Card__c bc = Object_Test_Brizzi.setChangeCard(cs.id);
        insert bc;
    }

    @isTest
    static void CaseTest(){
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type__r.Name,SCC_Call_Type__r.External_Id__c', 'Case', '', '', '', '1');
        Branch_Unit__c bu = (Branch_Unit__c) SOQL_SOBJECT.SingleSobject('', 'Branch_Unit__c', '', '', '', '1');
        Test.startTest();
        SCC_CaseResolution_UI.getCaseDetail(cs.id);
        SCC_CaseResolution_UI.getNotifWA(cs);
        SCC_CaseResolution_UI.getListRekeningKoran(cs.id);
        SCC_CaseResolution_UI.getListRekon(cs.id);
        SCC_CaseResolution_UI.getListAktivitasKartu(cs.id);
        SCC_CaseResolution_UI.getListEJ(cs.id);
        SCC_CaseResolution_UI.getListBAO(cs.id);
        SCC_CaseResolution_UI.getListQueuetrans(cs.id);
        SCC_CaseResolution_UI.getCallTypeDetail(cs.SCC_Call_Type__c);
        SCC_CaseResolution_UI.getUnitKerjaDetail(bu.id);
        SCC_CaseResolution_UI.getFiturDetail(cs.SCC_Call_Type_Feature__c);
        SCC_CaseResolution_UI.getTerminalDetail(cs.Terminal_ID__c);
        SCC_CaseResolution_UI.updateCase(cs, 'test');
        SCC_CaseResolution_UI.CustomerProfileDetail(cs);
        SCC_CaseResolution_UI.getListAdjustment(cs.id);
        SCC_CaseResolution_UI.getListReplace(cs.id);
        Test.stopTest();
    }

    @isTest
    static void RekeningKoran() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.SavingMutationResponse());
        SCC_CaseResolution_UI.getRekeningKoran('1000','2024-01-01','2024-01-01',cs);
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse res1 = Object_Test.SavingMutationResponse();
        List<SCC_Rekening_Koran__c> listrek = SCC_CaseResolution_UI.insertRekeningKoran(cs,res1.data);
        SCC_CaseResolution_UI.deleteRekeningKoran(listrek);
        Test.stopTest();
    }

    @isTest
    static void Rekon() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseRekon());
        SCC_RekonWrapper.ResponseRekon res1 = Object_Test.ResponseRekon();
        SCC_CaseResolution_UI.getRekon(cs, '2022-01-01', cs.SCC_Call_Type_Feature__c, cs.SCC_Call_Type__r.name);
        SCC_CaseResolution_UI.insertRekon(cs,res1.RESPONSE_DATA.result,'2024-01-01');
        List<SCC_Rekon__c> listrekon = SOQL_SOBJECT.ListSobject('','SCC_Rekon__c','','','','');
        SCC_CaseResolution_UI.deleteRekon(listrekon, cs);
        Test.stopTest();
    }

    @IsTest
    static void RekonToken() {
        
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseTokenRekon());
        SCC_RekonWrapper.RekonTokenResponse res1 = Object_Test.rekonTokenResponse();
        SCC_CaseResolution_UI.getNewRekon(cs, '2024-01-01', '', cs.SCC_Call_Type_Feature__c,cs.SCC_Call_Type_Feature__c);
        SCC_CaseResolution_UI.insertNewRekon(cs,res1.responseData.detailData,'2024-01-01');
        Test.stopTest();
    }

    // @isTest
    // static void newRekon() {
    //     Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.RekonTokenResponse());
    //     SCC_RekonWrapper.RekonTokenResponse res1 = Object_Test3.setRekonTokenResponse();
    //     SCC_CaseResolution_UI.getNewRekon(cs, '2022-01-01', cs.SCC_Call_Type_Feature__c, cs.SCC_Call_Type__r.name, 'BRIZZI001');
    //     SCC_CaseResolution_UI.insertNewRekon(cs,res1.responseData.detailData,'2024-01-01');
    //     List<SCC_Rekon__c> listrekon = SOQL_SOBJECT.ListSobject('','SCC_Rekon__c','','','','');
    //     SCC_CaseResolution_UI.deleteRekon(listrekon, cs);
    //     Test.stopTest();
    // }

    @isTest
    static void brizzi() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_CardInquiry_Mock.CardInquiry());
        SCC_BrizziWrapper.CardInquiryResponse res1 = Object_Test_Brizzi.cardInquiryResponse();
        SCC_CaseResolution_UI.getBrizziCardInquiry(cs);
        Test.stopTest();
    }

    @isTest
    static void brizziTrxHistory() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_TrxHistory_Mock.TrxHistory());
        SCC_BrizziWrapper.TrxHistoryResponse res1 = Object_Test_Brizzi.trxHistoryResponse();
        SCC_CaseResolution_UI.getTrxHistory(cs,1,1);
        Test.stopTest();
    }

    @isTest
    static void brizziPtrTrxHistory() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_Brizzi_PartnerTrxHistory_Mock.PartnerTrxHistory());
        SCC_BrizziWrapper.CardHistoryPartnerResponse res1 = Object_Test_Brizzi.ptrTrxHistoryResponse();
        SCC_CaseResolution_UI.getPtrTrxHistory(cs,1,1);
        Test.stopTest();
    }

    @isTest
    static void AdjustDeposit() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        List<Adjust_Deposit__c> listrek = [SELECT id, IsDeleted__c FROM Adjust_Deposit__c WHERE Case__c = :cs.id];
        Test.startTest();
        SCC_CaseResolution_UI.deleteAdjustDeposit(listrek);
        Test.stopTest();
    }

    @isTest
    static void ChangeCard() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        List<Brizzi_Card__c> listrek = [SELECT id, IsDeleted__c FROM Brizzi_Card__c WHERE Case__c = :cs.id];
        Test.startTest();
        SCC_CaseResolution_UI.deleteReplaceCard(listrek);
        Test.stopTest();
    }

    @isTest
    static void RekonTokenEdc() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type_Feature__r.Fitur_ID__c,SCC_Call_Type__r.name,SCC_Call_Type__r.external_id__c', 'Case', '', '', '', '1');
        Test.setMock(HttpCalloutMock.class, new SCC_RekonMock.ResponseTokenRekonEdc());
        SCC_RekonWrapper.RekonTokenEdcResponse res1 = Object_Test.rekonTokenResponseEdc();
        Test.startTest();
        SCC_CaseResolution_UI.getNewRekonEdc(cs, '2024-01-01', '', cs.SCC_Call_Type_Feature__c,cs.SCC_Call_Type_Feature__c);
        SCC_CaseResolution_UI.insertNewRekonEdc(cs,res1.responseData.detailData,'2024-01-01');
        Test.stopTest();
    }

    @isTest
    static void AktivitasKartu() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResoultion_DataHubMock.CardActivityResposnse());
        SCC_CaseResolution_UI.getAktivitasKartu(cs,'2024-07-01','2024-07-01','1','213601000363564','1');
        SCC_CaseResoultion_DataHub_Wrapper.CardActivityResponse res1 = Object_Test.CardActivityResponse();
        List<Aktivitas_Kartu__c> listrek = SCC_CaseResolution_UI.insertAktivitasKartu(cs,res1.data,'Success');
        SCC_CaseResolution_UI.deleteAktivitasKartu(listrek);
        Test.stopTest();
    }

    @isTest
    static void EJLog() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_EJOLMock.EJOL());
        SCC_CaseResolution_UI.getEJLog('6666','2024-09-05','NFS');
        SCC_CaseResolution_EJOLWrapper.EJLogResponse res1 = Object_Test.EJLogResponse();
        SCC_CaseResolution_UI.getEJLog('6666','2024-09-05','Kaseya');
        SCC_CaseResolution_EJOLWrapper.EJLogResponse res2 = Object_Test.EJLogResponse();

        // Prepare a list of EJLogData
        List<SCC_CaseResolution_EJOLWrapper.EJLogData> listEJData1 = new List<SCC_CaseResolution_EJOLWrapper.EJLogData>();
        listEJData1.add(res1.data); // Add the single EJLogData to the list

        // Prepare a list of EJLogData
        List<SCC_CaseResolution_EJOLWrapper.EJLogData> listEJData2 = new List<SCC_CaseResolution_EJOLWrapper.EJLogData>();
        listEJData2.add(res2.data); // Add the single EJLogData to the list

        // Pass the list to the insertEJ method
        List<EJ__c> listrek1 = SCC_CaseResolution_UI.insertEJ(cs, listEJData1, '2024-12-01', 'NFS');
        EJ__c ej = new EJ__c();
        ej.id = listrek1[0].id;
        ej.EJ_Log__c = '05/14/2023 00:17:27 PING Success!';
        List<EJ__c> listEJ = new List<EJ__c>();
        listEJ.add(ej);
        SCC_CaseResolution_UI.updateEJ(listEJ);
        SCC_CaseResolution_UI.deleteEJ(listrek1);
        SCC_CaseResolution_UI.deleteAllEJRecords(cs.id);
        // Pass the list to the insertEJ method
        List<EJ__c> listrek2 = SCC_CaseResolution_UI.insertEJ(cs, listEJData2, '2024-12-01', 'Kaseya');
        EJ__c ej2 = new EJ__c();
        ej2.id = listrek2[0].id;
        ej2.EJ_Log__c = '05/14/2023 00:17:27 PING Success!';
        List<EJ__c> listEJ2 = new List<EJ__c>();
        listEJ2.add(ej2);
        SCC_CaseResolution_UI.updateEJ(listEJ2);
        SCC_CaseResolution_UI.deleteEJ(listrek2);
        Test.stopTest();
    }

    @isTest
    static void BAO() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        Test.startTest();
        SCC_RekonWrapper.ResponseBeritaAcaraOpname res1 = Object_Test.ResponseBeritaAcaraOpname();
        SCC_CaseResolution_UI.getBAO('2022-02-02', cs.terminal_id__c);
        List<SCC_Berita_Acara_Opname__c> listbao = SCC_CaseResolution_UI.insertBAO(cs,res1.RESPONSE_DATA.result);
        SCC_CaseResolution_UI.deleteBAO(listbao);
        Test.stopTest();
    }

    @isTest
    static void File() {
        Case cs = (Case) SOQL_SOBJECT.SingleSobject('', 'Case', '', '', '', '1');
        id condocid = Object_Test.setFile();
        Test.startTest();
        SCC_CaseResolution_UI.insertFile(cs.id, condocid);
        Test.stopTest();
    }
}