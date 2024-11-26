public without sharing class SCC_HttpReq_NotificationCase {
    public static void execute(Date dt){
        if(dt==null) dt = Date.Today().addDays(-1);
        String msgKonsolidasi = Label.Case_Konsolidasi;
        String msgNonKonsolidasi = Label.Case_non_konsolidasi;
        List<Branch_Unit__c> listbu = [SELECT Id,Uker_Type__c,BranchCode__c FROM Branch_Unit__c WHERE Uker_Type__c != ''];
        Map<String,String> mapbu = new Map<String,String>();
        for(Branch_Unit__c bu : listbu){
            mapbu.put(bu.BranchCode__c,bu.Uker_Type__c);
        }
        List<Case> listcs = [SELECT Id,Kode_Kanwil__c,Branch_Code__c,Main_Branch__c,SCC_Owner_Orgeh__c
                             FROM Case 
                             WHERE Date__c <=:dt
                             AND Branch_Code__c != null
                             AND Branch_Code__c != '00000'
                             AND ((Area__c = 'KP00' AND Cost_Center__c != null) OR (Area__c != 'KP00' AND Region__c != null AND Main_Branch__c != null))
                             AND IsClosed = FALSE
                             ORDER BY Kode_Kanwil__c ASC,Main_Branch__c ASC,Branch_Code__c ASC,SCC_Owner_Orgeh__c ASC
                             LIMIT 50000];
        if(Test.isRunningTest()) listcs = [SELECT Id,Kode_Kanwil__c,Branch_Code__c,Main_Branch__c,SCC_Owner_Orgeh__c FROM Case LIMIT 10];
        Map<String,Integer> mapbranchtotal = new Map<String,Integer>();
        Map<String,Integer> mapcabangtotal = new Map<String,Integer>();
        Map<String,Integer> mapregiontotal = new Map<String,Integer>();
        Map<String,Integer> maporgehtotal = new Map<String,Integer>();
        system.debug('dt:'+dt);
        system.debug('listcs.size:'+listcs.size());
        if(listcs.size()>0){
            for(Case cs : listcs){
                if(cs.Branch_Code__c == '00229'){ //KANTOR PUSAT
                    if(cs.SCC_Owner_Orgeh__c != null){
                        Integer total = maporgehtotal.get(cs.SCC_Owner_Orgeh__c);
                        if(total == null) maporgehtotal.put(cs.SCC_Owner_Orgeh__c,1);
                        else maporgehtotal.put(cs.SCC_Owner_Orgeh__c,total+1);
                    }
                }else{ //BRANCH
                    String Uker_Type = mapbu.get(cs.Branch_Code__c);
                    if(Uker_Type != 'RO'){ //EXCLUDE UKER TYPE (RO) -> GS 08.11.24
                        //PER BRANCH
                        Integer total = mapbranchtotal.get(cs.Branch_Code__c);
                        if(total == null) mapbranchtotal.put(cs.Branch_Code__c,1);
                        else mapbranchtotal.put(cs.Branch_Code__c,total+1);
                        //PER CABANG
                        if(cs.Main_Branch__c != null){
                            Integer totalcabang = mapcabangtotal.get(cs.Main_Branch__c);
                            if(totalcabang == null) mapcabangtotal.put(cs.Main_Branch__c,1);
                            else mapcabangtotal.put(cs.Main_Branch__c,totalcabang+1);
                        }
                        //PER REGION
                        if(cs.Kode_Kanwil__c != null){
                            Integer totalregion = mapregiontotal.get(cs.Kode_Kanwil__c);
                            if(totalregion == null) mapregiontotal.put(cs.Kode_Kanwil__c,1);
                            else mapregiontotal.put(cs.Kode_Kanwil__c,totalregion+1);
                        }
                    }
                }
            }
        }
        system.debug('mapbranchtotal:'+mapbranchtotal);
        system.debug('mapcabangtotal:'+mapcabangtotal);
        system.debug('mapregiontotal:'+mapregiontotal);
        system.debug('maporgehtotal:'+maporgehtotal);
        List<Case> listcsdata = new List<Case>();
        //NON KONSOLIDASI - BRANCH
        listcsdata.addAll(addData(mapbranchtotal,msgNonKonsolidasi,dt,'BRANCH',false,mapbu));
        //KONSOLIDASI - CABANG
        listcsdata.addAll(addData(mapcabangtotal,msgKonsolidasi,dt,'BRANCH',true,mapbu));
        //KONSOLIDASI - REGION
        listcsdata.addAll(addData(mapregiontotal,msgKonsolidasi,dt,'BRANCH',true,mapbu));
        //NON KONSOLIDASI - PUSAT
        listcsdata.addAll(addData(maporgehtotal,msgNonKonsolidasi,dt,'PUSAT',false,mapbu));
        system.debug('listcsdata-size:'+listcsdata.size());
        if(listcsdata.size()>0){
            // BATCH for callout 
            if(Test.isRunningTest()) {
               	List<Case> listcsdatanew = new List<Case>();
                listcsdatanew.add(listcsdata[0]);
                database.executebatch(new SCC_Batch_NotificationCase(listcsdatanew),1);
            }
            else database.executebatch(new SCC_Batch_NotificationCase(listcsdata),100);
        }
    }
    
    public static void sendNotif(String message,String start_date,String orgeh,String branch,Boolean is_konsolidasi,String uker_type){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            //Detail from monitoring summary
            detail dt = new detail();
            dt.type = 2;
            dt.messages = message;
            dt.start_date = start_date;
            dt.orgeh = orgeh;
            dt.branch = branch;
            dt.is_konsolidasi = is_konsolidasi;
            dt.uker_type = uker_type;
            
            SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('NotificationCase', JSON.serialize(dt),'','SCC_HttpReq_NotificationCase');
            req = wapi.req;
            res = wapi.res;
            system.debug('req:'+req);
            system.debug('res:'+res);
        }catch(exception exc){
            SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError('','SCC_HttpReq_NotificationCase')); 
        }
    }
    
    public static List<Case> addData(Map<String,Integer> maptotal,
                                     String msg,Date dt,String tipe,
                                     Boolean is_konsolidasi,Map<String,String> mapbu)
    {
        List<Case> result = new List<Case>();  
        String strmsg;                                                       
        for(String code : maptotal.keySet()){
            strmsg = msg;
            Integer total = maptotal.get(code); 
            if(strmsg != null){
                String strTotal = '';
                if(total != null) strTotal = String.ValueOf(total);
                strmsg = strmsg.replace('#TOTAL',strTotal);
            }
            system.debug('code:'+code);
            system.debug('total:'+total);
            system.debug('strmsg:'+strmsg);
            String uker_type = mapbu.get(code);
            if(tipe == 'PUSAT') uker_type = 'KP';
            
            if(uker_type != null && uker_type != ''){
                if(uker_type == 'RO') is_konsolidasi = true;
                else if (uker_type == 'KCP' || uker_type == 'U') is_konsolidasi = false;
                Case cs = new Case();
                if(tipe == 'BRANCH'){
                    cs.Main_Branch__c = code; //BRANCH API
                    cs.Main_Branch_Description__c = ''; //ORGEH API
                }else if(tipe == 'PUSAT'){
                    cs.Main_Branch__c = ''; //BRANCH API
                    cs.Main_Branch_Description__c = code; //ORGEH API
                }
                cs.SCC_Bank_BRI__c = uker_type; //TYPE UKER
                cs.SCC_Attachment__c = is_konsolidasi; //IS_KONSOLIDASI
                cs.Sosmed_Message_Content__c = strmsg; //MESSAGE API
                cs.Approved_Date_Checker__c = dt; //DATE API
                result.add(cs);
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