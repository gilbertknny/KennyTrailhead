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
        Case cs = Object_Test.setCase(ct.id);
        cs.Terminal_ID__c = tm.id;
        cs.SCC_Call_Type_Feature__c	 = ft.id;
        insert cs;
        SCC_Rekening_Koran__c rek = Object_Test.setRekeningKoran(cs.id);
        insert rek;
        SCC_Rekon__c rk = Object_Test.setRekon(cs.id);
        insert rk;
        SCC_Berita_Acara_Opname__c bao = Object_Test.setBeritaAcaraOpname(cs.id);
        insert bao;
        SCC_Queuetrans__c que = Object_Test.setQueueTrans(cs.id);
        insert que;
    }

    @isTest
    static void CaseTest(){
        Case cs = (Case) SOQL_SOBJECT.SingleSobject(',SCC_Call_Type__r.Name,SCC_Call_Type__r.External_Id__c', 'Case', '', '', '', '1');
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
        SCC_CaseResolution_UI.getFiturDetail(cs.SCC_Call_Type_Feature__c);
        SCC_CaseResolution_UI.getTerminalDetail(cs.Terminal_ID__c);
        SCC_CaseResolution_UI.updateCase(cs, 'test');
        SCC_CaseResolution_UI.CustomerProfileDetail(cs);
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
        SCC_CaseResolution_UI.deleteEJ(listrek1);

        // Pass the list to the insertEJ method
        List<EJ__c> listrek2 = SCC_CaseResolution_UI.insertEJ(cs, listEJData2, '2024-12-01', 'Kaseya');
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