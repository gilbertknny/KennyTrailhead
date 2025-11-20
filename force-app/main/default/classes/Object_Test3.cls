/**
 * @description       : test object wrapper
 * @author            : Femy
 * @group             : 
 * @last modified on  : 15-09-2025
 * @last modified by  : Christian Vieri
**/
@istest
public without sharing class Object_Test3 {
    public static SCC_RekonWrapper.RekonTokenResponse setRekonTokenResponse(){
        List<SCC_RekonWrapper.RekonTokenDetailData> listrd = new List<SCC_RekonWrapper.RekonTokenDetailData>();
        SCC_RekonWrapper.RekonTokenDetailData rd = new SCC_RekonWrapper.RekonTokenDetailData();
        rd.BillingCode =   '14361525604';
        rd.Fee =   '3000.00';
        rd.ID =   251019;
        rd.NoToken =   '86080980807';
        rd.Nominal =   '20000';
        rd.RekDebet =   '473701026064534';
        rd.RekDebetFee =   '473701026064534';
        rd.RekKredit =   '';
        rd.Remark =   'PLN-PRA  14361525604NBMB5221840977221143';        
        rd.Seq =   '5041015';
        rd.StatusMCS =   '0';
        rd.StatusMCSDesc =   'Waiting Maker';
        rd.StatusRecon =   'Match';//'Unmatch BRI';
        rd.TanggalTrans =   '2024-10-22T00:00:00Z';
        listrd.add(rd);
        SCC_RekonWrapper.RekonTokenResponseData rtrd = new SCC_RekonWrapper.RekonTokenResponseData();
        rtrd.detailData = listrd;
        rtrd.statusScheduler = 'Done';
        SCC_RekonWrapper.RekonTokenResponse res = new SCC_RekonWrapper.RekonTokenResponse();
        res.errorCode = 'RE-00';
        res.responseCode = '00';
        res.responseMessage = 'Transaction Successful';
        res.responseData = rtrd;
        return res;
    }

    public static SCC_RekonWrapper.RekonTokenRequest setRekonTokenRequest(){
        SCC_RekonWrapper.RekonTokenRequest rd = new SCC_RekonWrapper.RekonTokenRequest();
        rd.FeatureId =   'PLNPR001';
        rd.TransactionDate =   '2024-10-04';
        rd.BillingNumber =   '11007550109';
        return rd;
    }

    public static SCC_AVAYA_Wrapper.RequestToken setRequestToken(){
        SCC_AVAYA_Wrapper.RequestToken req = new SCC_AVAYA_Wrapper.RequestToken();
        req.username = 'username';
        req.password = 'password';
        return req;
    }

    public static SCC_AVAYA_Wrapper.ResponseToken setResponseToken(){
        SCC_AVAYA_Wrapper.ResponseToken res = new SCC_AVAYA_Wrapper.ResponseToken();
        res.status = 401;
        res.type = 'https://tools.ietf.org/html/rfc9110#section-15.5.2';
        res.title = 'Unauthorized';
        res.traceId = '00-42a1be2a1cb58df78df286b289c3a9c6-f71296bd510675df-00';
        res.token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzYWFkbWluIiwianRpIjoiMTA4Y2EyMzktNzAyYS00ZmU3LTkxZjEtYzZhN2M3YWIxNWY4IiwiaHR0cDovL3NjaGVtYXMubWljcm9zb2Z0LmNvbS93cy8yMDA4LzA2L2lkZW50aXR5L2NsYWltcy9yb2xlIjoiQWRtaW4iLCJleHAiOjE3NDAyMzc4NDAsImlzcyI6IkZyZWVUcmFpbmVkIn0.5Ez3S8c1NcoU7z_E0RqkISmokCcU-Zl6u575K-WvDPY';
        return res;
    }

    public static List<SCC_AVAYA_Wrapper.ResponseReportHistorical> setResponseReportHistorical(){
        List<SCC_AVAYA_Wrapper.ResponseReportHistorical> lres = new List<SCC_AVAYA_Wrapper.ResponseReportHistorical>();
        map<Integer,String> mapskill = new Map<Integer,String>();
        mapskill.put(29,'auxoutofcalls');
        mapskill.put(86,'Agents in AUX');
        mapskill.put(77,'Agents Staffed');
        mapskill.put(83,'Split/Skill');
        mapskill.put(74,'ABNCALLS');
        mapskill.put(58,'ACD Calls');
        mapskill.put(94,'Agents Staffed');
        mapskill.put(66,'percentAbn');
        mapskill.put(43,'INQUEUE');
        mapskill.put(58,'percentAbn');
        mapskill.put(12,'auxoutCalls');
        for(Integer i:mapskill.keySet()){
            SCC_AVAYA_Wrapper.ResponseReportHistorical res = new SCC_AVAYA_Wrapper.ResponseReportHistorical();
            res.headerHistorical = mapskill.get(i);
            res.valueHistorical = i;
            lres.add(res);
        }
        return lres;
    }

    public static List<SCC_AVAYA_Wrapper.ResponseReportAgent> setResponseReportAgent(){
        List<SCC_AVAYA_Wrapper.ResponseReportAgent> lres = new List<SCC_AVAYA_Wrapper.ResponseReportAgent>();
        List<SCC_AVAYA_Wrapper.ReportAgent> lagn = new List<SCC_AVAYA_Wrapper.ReportAgent>();
        SCC_AVAYA_Wrapper.ResponseReportAgent resa = new SCC_AVAYA_Wrapper.ResponseReportAgent();
        resa.agentGroup = 'Bank Jakarta';
        resa.dates = '2024-01-01';
        resa.totals = setAgent();
        for(Integer i=4100;i<=4110;i++){
            SCC_AVAYA_Wrapper.ReportAgent res = setAgent();
            res.loginID = i;
            res.name = 'Agent '+i;
            lagn.add(res);
        }
        resa.agents = lagn;
        lres.add(resa);
        return lres;
    }

    public static SCC_AVAYA_Wrapper.ReportAgent setAgent(){
        SCC_AVAYA_Wrapper.ReportAgent res = new SCC_AVAYA_Wrapper.ReportAgent();
        res.availTime = '1:21:41';
        res.staffedTime = '7:22:34';
        res.aht = 212;
        res.auxIsiForm = '0:0:27';
        res.auxRestRoom = '0:0:22';
        res.auxSholat ='0:2:40';
        return res;
    }

    public static List<SCC_AVAYA_Wrapper.ResponseReportSkills> setResponseReportSkills(){
        List<SCC_AVAYA_Wrapper.ResponseReportSkills> lres = new List<SCC_AVAYA_Wrapper.ResponseReportSkills>();
        map<Integer,String> mapskill = new Map<Integer,String>();
        mapskill.put(0,'PSTN_Credit_Ind');
        mapskill.put(1,'PSTN_Banking_Ind');
        mapskill.put(2,'VOIP BANKING INA');
        mapskill.put(3,'Platinum');
        mapskill.put(4,'VOIP CC INA');
        mapskill.put(5,'DPLK');
        mapskill.put(6,'EDC');
        mapskill.put(7,'NIK');
        for(String str : mapskill.values()){
            SCC_AVAYA_Wrapper.ResponseReportSkills res = new SCC_AVAYA_Wrapper.ResponseReportSkills();
            res.seksiSkill = str;
            res.callOffered = 1485;
            res.acceptable = 1477;
            res.acdCalls = 1485;
            res.abanCalls = 2;
            res.agentsAvail = 15;
            res.agentsStaffed = 42;
            res.serviceLevel =78;
            lres.add(res);
        }
        return lres;
    }
}