public without sharing class SCC_HttpReq_Monitoring {
    public static void execute(Date dt){
        if(dt==null) dt = Date.Today().addDays(-1);
        String msgKonsolidasi = Label.Monitoring_Konsolidasi;
        String msgNonKonsolidasi = Label.Monitoring_non_konsolidasi;
        List<Branch_Unit__c> listbu = [SELECT Id,Uker_Type__c,BranchCode__c FROM Branch_Unit__c WHERE Uker_Type__c != ''];
        Map<String,String> mapbu = new Map<String,String>();
        for(Branch_Unit__c bu : listbu){
            mapbu.put(bu.BranchCode__c,bu.Uker_Type__c);
        }
        List<Monitoring_Summary__c> listms = [SELECT Id,Branch_Code__c,Total__c,Orgeh__c,User__c,
                                              Kode_Cabang__c,Kode_Kanwil__c
                                              FROM Monitoring_Summary__c 
                                              WHERE Date__c =:dt 
                                              AND Branch_Code__c != NULL
                                              AND Branch_Code__c != '00000'
                                              ORDER BY Kode_Kanwil__c ASC,Kode_Cabang__c ASC,Branch_Code__c ASC,Orgeh__c ASC];
        Map<String,Integer> mapbranchtotal = new Map<String,Integer>();
        Map<String,Integer> mapcabangtotal = new Map<String,Integer>();
        Map<String,Integer> mapregiontotal = new Map<String,Integer>();
        Map<String,Integer> maporgehtotal = new Map<String,Integer>();
        Map<String,Set<String>> mapbranchuser = new Map<String,Set<String>>();
        Map<String,Set<String>> mapcabanguser = new Map<String,Set<String>>();
        Map<String,Set<String>> mapregionuser = new Map<String,Set<String>>();
        Map<String,Set<String>> maporgehuser = new Map<String,Set<String>>();
        system.debug('dt:'+dt);
        system.debug('listms.size:'+listms.size());
        if(listms.size()>0){
            for(Monitoring_Summary__c ms : listms){
                if(ms.Branch_Code__c == '00229'){ //KANTOR PUSAT
                    if(ms.Orgeh__c != null){
                        Integer total = maporgehtotal.get(ms.Orgeh__c);
                        if(total == null) maporgehtotal.put(ms.Orgeh__c,Integer.valueOf(ms.Total__c));
                        else maporgehtotal.put(ms.Orgeh__c,Integer.valueOf(ms.Total__c)+total);
                        if(!maporgehuser.containsKey(ms.Orgeh__c)) maporgehuser.put(ms.Orgeh__c, new Set<String>{ms.User__c});
                    	else maporgehuser.get(ms.Orgeh__c).add(ms.User__c);
                    }
                }else{ //BRANCH
                    String Uker_Type = mapbu.get(ms.Branch_Code__c); 
                    if(Uker_Type != 'RO'){ //EXCLUDE UKER TYPE (RO) -> GS 08.11.24
                        //PER BRANCH
                        Integer total = mapbranchtotal.get(ms.Branch_Code__c);
                        if(total == null) mapbranchtotal.put(ms.Branch_Code__c,Integer.valueOf(ms.Total__c));
                        else mapbranchtotal.put(ms.Branch_Code__c,Integer.valueOf(ms.Total__c)+total);
                        //BRANCH USER
                        if(!mapbranchuser.containsKey(ms.Branch_Code__c)) mapbranchuser.put(ms.Branch_Code__c, new Set<String>{ms.User__c});
                        else mapbranchuser.get(ms.Branch_Code__c).add(ms.User__c);
                        
                        //PER CABANG
                        if(ms.Kode_Cabang__c != null){
                            Integer totalcabang = mapcabangtotal.get(ms.Kode_Cabang__c);
                            if(totalcabang == null) mapcabangtotal.put(ms.Kode_Cabang__c,Integer.valueOf(ms.Total__c));
                            else mapcabangtotal.put(ms.Kode_Cabang__c,Integer.valueOf(ms.Total__c)+totalcabang);
                            
                            //CABANG USER
                            if(!mapcabanguser.containsKey(ms.Kode_Cabang__c)) mapcabanguser.put(ms.Kode_Cabang__c, new Set<String>{ms.User__c});
                            else mapcabanguser.get(ms.Kode_Cabang__c).add(ms.User__c);
                        }
                        //PER REGION
                        if(ms.Kode_Kanwil__c != null){
                            
                            Integer totalregion = mapregiontotal.get(ms.Kode_Kanwil__c);
                            if(totalregion == null) mapregiontotal.put(ms.Kode_Kanwil__c,Integer.valueOf(ms.Total__c));
                            else mapregiontotal.put(ms.Kode_Kanwil__c,Integer.valueOf(ms.Total__c)+totalregion);
                            
                            //REGION USER
                            if(!mapregionuser.containsKey(ms.Kode_Kanwil__c)) mapregionuser.put(ms.Kode_Kanwil__c, new Set<String>{ms.User__c});
                            else mapregionuser.get(ms.Kode_Kanwil__c).add(ms.User__c);
                            
                        }
                    }
                }
            }
        }
        system.debug('mapbranchtotal:'+mapbranchtotal);
        system.debug('mapcabangtotal:'+mapcabangtotal);
        system.debug('mapregiontotal:'+mapregiontotal);
        system.debug('maporgehtotal:'+maporgehtotal);
        system.debug('mapbranchuser:'+mapbranchuser);
        system.debug('mapcabanguser:'+mapcabanguser);
        system.debug('mapregionuser:'+mapregionuser);
        system.debug('maporgehuser:'+maporgehuser);
        List<Monitoring_Summary__c> listmsdata = new List<Monitoring_Summary__c>();
        //NON KONSOLIDASI - BRANCH
        listmsdata.addAll(addMonitoring(mapbranchtotal,mapbranchuser,msgNonKonsolidasi,dt,'BRANCH',false,mapbu));
        //KONSOLIDASI - CABANG
       	listmsdata.addAll(addMonitoring(mapcabangtotal,mapcabanguser,msgKonsolidasi,dt,'BRANCH',true,mapbu));
        //KONSOLIDASI - REGION
        listmsdata.addAll(addMonitoring(mapregiontotal,mapregionuser,msgKonsolidasi,dt,'BRANCH',true,mapbu));
        //KONSOLIDASI - PUSAT
        listmsdata.addAll(addMonitoring(maporgehtotal,maporgehuser,msgNonKonsolidasi,dt,'PUSAT',false,mapbu));
        
        system.debug('listmsdata-size:'+listmsdata.size());
        if(listmsdata.size()>0){
            // BATCH for callout 
            database.executebatch(new SCC_Batch_Monitoring(listmsdata),100);
        }
    }
    
    public static void sendNotif(String message,String start_date,String orgeh,String branch,Boolean is_konsolidasi,String uker_type){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            //Detail from monitoring summary
            detail dt = new detail();
            dt.type = 1;
            dt.messages = message;
            dt.start_date = start_date;
            dt.orgeh = orgeh;
            dt.branch = branch;
            dt.is_konsolidasi = is_konsolidasi;
            dt.uker_type = uker_type;
            
            SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('MonitoringSummary', JSON.serialize(dt),'','SCC_HttpReq_Monitoring');
            req = wapi.req;
            res = wapi.res;
            system.debug('req:'+req);
            system.debug('res:'+res);
        }catch(exception exc){
            SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError('','SCC_HttpReq_Monitoring')); 
        }
    }
    
    public static List<Monitoring_Summary__c> addMonitoring(Map<String,Integer> maptotal,
                                                           Map<String,Set<String>> mapuser,
                                                           String msg,Date dt,String tipe,
                                                           Boolean is_konsolidasi,Map<String,String> mapbu){
        List<Monitoring_Summary__c> result = new List<Monitoring_Summary__c>();  
        String strmsg;                                                       
        for(String code : maptotal.keySet()){
            strmsg = msg;
            Set<String> setUser = mapuser.get(code);
            Integer total = maptotal.get(code); 
            if(strmsg != null){
                String strTotal = '';
                String strTotalUser = '';
                if(setUser.size()>0) strTotalUser = String.ValueOf(setUser.size()); 
                if(total != null) strTotal = String.ValueOf(total);
                strmsg = strmsg.replace('#TOTALUSER',strTotalUser);
                strmsg = strmsg.replace('#TOTAL',strTotal);
            }
            system.debug('code:'+code);
            system.debug('total:'+total);
            system.debug('setUser-Size:'+setUser.size());
            system.debug('strmsg:'+strmsg);
            if(code != null && code != '' && tipe != 'PUSAT') code = ('00000'+code).right(5);
            String uker_type = mapbu.get(code);
            if(tipe == 'PUSAT') uker_type = 'KP';
            if(uker_type != null && uker_type != ''){
                if(uker_type == 'RO') is_konsolidasi = true;
                else if (uker_type == 'KCP' || uker_type == 'U' || uker_type == 'KK') is_konsolidasi = false; //Add KK non Konsolidasi -> GS 06.12.24
                Monitoring_Summary__c ms = new Monitoring_Summary__c();
                if(tipe == 'BRANCH'){
                    ms.Branch_API__c = code;
                    ms.Orgeh_API__c = '';
                }else if(tipe == 'PUSAT'){
                    ms.Branch_API__c = '';
                    ms.Orgeh_API__c = code;
                }
                ms.Cost_Center_Desc__c = uker_type; //TYPE UKER
                ms.is_konsolidasi__c = is_konsolidasi;            
                ms.Message_API__c = strmsg;
                ms.Date__c = dt;
                result.add(ms);
            }
        }
        return result;
    }
    
    public class detail {
        public integer type;
        public string messages;
        public string start_date;
        public string orgeh;
        public string branch;
        public boolean is_konsolidasi;
        public string uker_type;
    }
}