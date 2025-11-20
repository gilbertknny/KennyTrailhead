/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 09-16-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SCC_AVAYA {
    public static SCC_AVAYA_Wrapper.ResponseToken getToken(SCC_AVAYA_Wrapper.RequestToken cdh,String menu,String recid){
        SCC_AVAYA_Wrapper.ResponseToken cps = new  SCC_AVAYA_Wrapper.ResponseToken();
        SCC_API.WrapperRequest wr = setWrapperRequest(JSON.serialize(cdh,true), 'AvayaToken', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            cps = (SCC_AVAYA_Wrapper.ResponseToken) JSON.deserialize(wapi.res.getBody(), SCC_AVAYA_Wrapper.ResponseToken.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        // if(label.Dummy_Response=='true'){
        //     cps = Object_TestAvaya.setResponseToken();
        // }
        return cps;
    }

    public static List<SCC_AVAYA_Wrapper.ResponseReportHistorical> getReportHistorical(String menu,String recid){
        List<SCC_AVAYA_Wrapper.ResponseReportHistorical> cps = new  List<SCC_AVAYA_Wrapper.ResponseReportHistorical>();
        SCC_API.WrapperRequest wr = setWrapperRequest('', 'AvayaReportHistorical', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            cps = (List<SCC_AVAYA_Wrapper.ResponseReportHistorical>) JSON.deserialize(wapi.res.getBody(), List<SCC_AVAYA_Wrapper.ResponseReportHistorical>.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        // if(label.Dummy_Response=='true'){
        //     cps = Object_TestAvaya.setResponseReportHistorical();
        // }
        return cps;
    }

    public static List<SCC_AVAYA_Wrapper.ResponseReportAgent> getReportAgent(String menu,String recid){
        List<SCC_AVAYA_Wrapper.ResponseReportAgent> cps = new  List<SCC_AVAYA_Wrapper.ResponseReportAgent>();
        SCC_API.WrapperRequest wr = setWrapperRequest('', 'AvayaReportAgent', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            String rbody = wapi.res.getBody().replace('"date"', '"dates"');
            cps = (List<SCC_AVAYA_Wrapper.ResponseReportAgent>) JSON.deserialize(rbody, List<SCC_AVAYA_Wrapper.ResponseReportAgent>.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        // if(label.Dummy_Response=='true'){
        //     cps = Object_TestAvaya.setResponseReportAgent();
        // }
        return cps;
    }

    public static List<SCC_AVAYA_Wrapper.ResponseReportSkills> getReportSkills(String menu,String recid){
        List<SCC_AVAYA_Wrapper.ResponseReportSkills> cps = new  List<SCC_AVAYA_Wrapper.ResponseReportSkills>();
        SCC_API.WrapperRequest wr = setWrapperRequest('', 'AvayaReportSkills', menu, recid);
        SCC_API.WrapperError we = setWrapperError(wr);
        SCC_API.WrapperAPI wapi = SCC_API.getResponseAPIUI(wr);
        try{
            cps = (List<SCC_AVAYA_Wrapper.ResponseReportSkills>) JSON.deserialize(wapi.res.getBody(), List<SCC_AVAYA_Wrapper.ResponseReportSkills>.class);
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,wapi.req,wapi.res,we); 
        }
        // if(label.Dummy_Response=='true'){
        //     cps = Object_TestAvaya.setResponseReportSkills();
        // }
        return cps;
    }
    
    @future(callout=true) 
    public static void setReportAgent(){
        Date dt = system.today();
        List<SCC_AVAYA_Wrapper.ResponseReportAgent> lres = SCC_AVAYA.getReportAgent('System', null);
        Map<String,Avaya_Agent__c> mapskl = new Map<String,Avaya_Agent__c>();
        if(!lres.isEmpty()){
            for(SCC_AVAYA_Wrapper.ResponseReportAgent resa:lres){
                if(String.isNotBlank(resa.dates)){
                    dt = Date.valueOf(resa.dates);
                }
                String ext2 ='TOTAL-'+resa.agentGroup+'-'+String.valueOf(dt);
                SCC_AVAYA_Wrapper.ReportAgent res2 = resa.totals;
                Avaya_Agent__c skl2 = new Avaya_Agent__c(Date__c=dt,Agent_Group__c=resa.agentGroup, External_ID__c=ext2, AHT__c=res2.aht, AUX_Isi_Form__c=res2.auxIsiForm, 
                                                            AUX_Rest_Room__c=res2.auxRestRoom, AUX_Sholat__c=res2.auxSholat, Avail_Time__c=res2.availTime,
                                                            Login_ID__c = '', Name__c='TOTAL', Staffed_Time__c=res2.staffedTime);
                mapskl.put(ext2,skl2);
                for(SCC_AVAYA_Wrapper.ReportAgent res:resa.agents){
                    String ext = res.loginID+'-'+res.name+'-'+String.valueOf(dt);
                    Avaya_Agent__c skl = new Avaya_Agent__c(Date__c=dt,Agent_Group__c=resa.agentGroup, External_ID__c=ext, AHT__c=res.aht, AUX_Isi_Form__c=res.auxIsiForm, 
                                                            AUX_Rest_Room__c=res.auxRestRoom, AUX_Sholat__c=res.auxSholat, Avail_Time__c=res.availTime,
                                                            Login_ID__c = String.valueOf(res.loginID), Name__c=res.name, Staffed_Time__c=res.staffedTime);
                    mapskl.put(ext,skl);
                }
            }
            if(!mapskl.isempty()){
                upsert mapskl.values() external_id__c;
            }   
        }
    }
    
    @future(callout=true) 
    public static void setReportSkill(){
        Date dt = system.today();
        List<SCC_AVAYA_Wrapper.ResponseReportSkills> lres = SCC_AVAYA.getReportSkills('System', null);
        Map<String,Avaya_Skills__c> mapskl = new Map<String,Avaya_Skills__c>();
        if(!lres.isEmpty()){
            for(SCC_AVAYA_Wrapper.ResponseReportSkills res:lres){
                String ext = res.seksiSkill+'-'+String.valueOf(dt);
                Avaya_Skills__c skl = new Avaya_Skills__c(Date__c=dt, External_ID__c=ext, Abandoned_Calls__c=res.abanCalls, Acceptable__c=res.acceptable, ACD_Calls__c=res.acdCalls, 
                                        Agents_Available__c=res.agentsAvail, Agents_Staffed__c=res.agentsStaffed, Call_Offered__c=res.callOffered, Seksi_Skill__c=res.seksiSkill, Service_Level__c=res.serviceLevel);
                mapskl.put(ext,skl);
            }
            if(!mapskl.isempty()){
                upsert mapskl.values() external_id__c;
            }   
        }
    }
    
	@future(callout=true) 
    public static void setReportHistorical(){
        Date dt = system.today();
        List<SCC_AVAYA_Wrapper.ResponseReportHistorical> lres = SCC_AVAYA.getReportHistorical('System', null);
        Map<String,Avaya_Historical__c> mapskl = new Map<String,Avaya_Historical__c>();
        if(!lres.isEmpty()){
            for(SCC_AVAYA_Wrapper.ResponseReportHistorical res:lres){
                String ext = res.headerHistorical+'-'+String.valueOf(dt);
                Avaya_Historical__c skl = new Avaya_Historical__c(Date__c=dt, External_ID__c=ext, Historical_Type__c=res.headerHistorical, Duration__c=res.valueHistorical);
                if(mapskl.containskey(ext)){
                    Avaya_Historical__c skl2 = mapskl.get(ext);
                    skl.Duration__c += skl2.Duration__c;
                }
                mapskl.put(ext,skl);
            }
            if(!mapskl.isempty()){
                upsert mapskl.values() external_id__c;
            }   
        }
    }
    
    public static SCC_API.WrapperRequest setWrapperRequest(String bd,String metanm,String menu,String recid){
        SCC_API.WrapperRequest wr = new SCC_API.WrapperRequest();
        wr.bodyreq = bd;
        wr.clsName = 'SCC_AVAYA';
        wr.menu = menu;
        wr.metaname = metanm;
        wr.recid = recid;
        wr.token = '';
        if(String.isNotBlank(recid)){
            Id idsf = id.valueOf(recid);
            wr.objnm =  idsf.getSObjectType().getDescribe().getName();
        }
        return wr;
    }

    public static SCC_API.WrapperError setWrapperError(SCC_API.WrapperRequest wr){
        String urlCurrent = url.getCurrentRequestUrl().tostring().replace('Url:[delegate=','').substringBeforeLast(']');
        SCC_API.WrapperError we = new SCC_API.WrapperError(urlCurrent,wr.clsName);
        we.menu = wr.menu;
        we.recid = wr.recid;
        we.objnm = wr.objnm;
        return we;
    }

    public static void removeAvayaReport(String reportname){
        List<CronTrigger> ctlists = [SELECT Id, CronJobDetail.name, CronJobDetail.jobtype, NextFireTime, PreviousFireTime, State, StartTime, EndTime, 
                                             CronExpression, TimeZoneSidKey, OwnerId, LastModifiedById, CreatedById, CreatedDate, TimesTriggered 
                                             FROM CronTrigger 
                                             where CronJobDetail.name =  :reportname];
        if(CTlists.size()>0){
            for(CronTrigger apxjob:CTlists){
                System.abortJob(apxJob.Id);
            }
        }
    }
}