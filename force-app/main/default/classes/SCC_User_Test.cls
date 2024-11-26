@istest
public with sharing class SCC_User_Test {
    @IsTest
    static void scc_User1st(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_CaseResolution_CHMSupportMock.InquiryRoleUserCHMResponse());
        System.enqueueJob(new SCC_User1st('1'));
        Test.stopTest();
    }

    @IsTest
    static void scc_User1st_Extended(){
        Test.startTest();
        String val = 'A|00002613|Tetty Siagian|A|066|Customer Service|UN|KW02|RB02|WB33670|50562519|Regional Office Medan|Medan Iskandar|UNIT MEDAN LABUHAN|TERAS PASAR RAMBE|05321|2024-05-07T00:00:00+07:00';
        List<String> liststr = val.split('|');
        System.enqueueJob(new SCC_User1st_Extended(liststr));
        Test.stopTest();
    }

    @IsTest
    static void scc_User2nd1(){
        Test.startTest();
        String val = 'A|00002613|Tetty Siagian|A|066|Customer Service|UN|KW02|RB02|WB33670|50562519|Regional Office Medan|Medan Iskandar|UNIT MEDAN LABUHAN|TERAS PASAR RAMBE|05321|2024-05-07T00:00:00+07:00';
        List<String> liststr = val.split('|');
        Map<Integer,List<String>> mapstr = new Map<Integer,List<String>>();
        mapstr.put(1,liststr);
        System.enqueueJob(new SCC_User2nd(1,mapstr,1));
        Test.stopTest();
    }

    @IsTest
    static void scc_User2nd2(){
        Test.startTest();
        String val = 'C|00002613|Tetty Siagian|A|066|Customer Service|UN|KW02|RB02|WB33670|50562519|Regional Office Medan|Medan Iskandar|UNIT MEDAN LABUHAN|TERAS PASAR RAMBE|05321|2024-05-07T00:00:00+07:00';
        List<String> liststr = val.split('|');
        Map<Integer,List<String>> mapstr = new Map<Integer,List<String>>();
        mapstr.put(1,liststr);
        System.enqueueJob(new SCC_User2nd(1,mapstr,1));
        Test.stopTest();
    }

    @IsTest
    static void scc_User2nd3(){
        Test.startTest();
        String val = 'T|00002613|Tetty Siagian|A|066|Customer Service|UN|KW02|RB02|WB33670|50562519|Regional Office Medan|Medan Iskandar|UNIT MEDAN LABUHAN|TERAS PASAR RAMBE|05321|2024-05-07T00:00:00+07:00';
        List<String> liststr = val.split('|');
        Map<Integer,List<String>> mapstr = new Map<Integer,List<String>>();
        mapstr.put(1,liststr);
        System.enqueueJob(new SCC_User2nd(1,mapstr,1));
        Test.stopTest();
    }
}