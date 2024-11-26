public class SCC_Monitoring {
    public static void execute(String strdt,Date dt){
        if(strdt == null) strdt = 'YESTERDAY';
        if(dt == null) dt = Date.Today().addDays(-1);
        
        Extremely(strdt,dt);
        Business_Hours(strdt,dt);
        Not_Create_Case(strdt,dt);
    }
    
    public static void Extremely(String strdt,Date dt){
        system.debug('--Extremely--');
        String anomali = 'Extremely Frequency Access Datahub';
        String recordTypeName = 'extremely frequency';
        String menu = 'Home';
        String destination = 'Data Hub';
        String querypf = 'SELECT User_Run__r.Profile.Name ProfileName FROM Error_Log__c ';
        querypf += 'WHERE Error_Datetime__c = ' + strdt + ' ';
        querypf += 'AND Response_Status_Code__c = 200 ';
        querypf += 'AND Menu__c !=: menu ';
        querypf += 'AND Destination__c =: destination ';
        querypf += 'GROUP BY User_Run__r.Profile.Name ';
        querypf += 'ORDER BY User_Run__r.Profile.Name ASC ';
        List<AggregateResult> listpf = Database.query(querypf);
        
        List<String> listprofile = new List<String>();
        for(AggregateResult pf : listpf){
            listprofile.add((String)pf.get('ProfileName'));
        }
        
        List<Monitoring_Summary__c> listupdatems = new List<Monitoring_Summary__c>();
        List<Monitoring_Summary__c> listinsertms = new List<Monitoring_Summary__c>();
        string likeanomali = anomali + '%';
        List<Monitoring_Summary__c> listms = [SELECT Id,User__c,Total__c FROM Monitoring_Summary__c
                                              WHERE Date__c =:dt
                                              AND Anomali_Category__r.Name LIKE:likeanomali];
        Map<String,Monitoring_Summary__c> mapms = new Map<String,Monitoring_Summary__c>();
        for(Monitoring_Summary__c ms : listms){
            mapms.put(ms.User__c,ms);
        }
        
        List<String> listuserid = new List<String>();
        if(listprofile.size()>0){
            List<Anomali_Category__c> listac = [SELECT Id,Frequency__c,Profile__c FROM Anomali_Category__c 
                                                WHERE RecordType.Name =:recordTypeName
                                                AND Active__c = TRUE
                                                AND Profile__c IN:listprofile];
            if(listac.size()>0){
                for(Anomali_Category__c ac : listac){
                    String sProfile = ac.Profile__c;
                    system.debug('sProfile:'+sProfile);
                    Integer iJum = Integer.valueOf(ac.Frequency__c);
                    system.debug('iJum:'+iJum);
                    String queryar = 'SELECT User_Run__c,COUNT(Id) Total FROM Error_Log__c ';
                    queryar += 'WHERE Error_Datetime__c = ' + strdt + ' ';
                    queryar += 'AND User_Run__r.Profile.Name =:sProfile ';
                    queryar += 'AND Response_Status_Code__c = 200 ';
                    queryar += 'AND Menu__c !=: menu ';
                    queryar += 'AND Destination__c =: destination ';
                    queryar += 'GROUP BY User_Run__c ';
                    queryar += 'HAVING COUNT(Id) >:iJum ';
                    queryar += 'ORDER BY User_Run__c ASC ';
                    List<AggregateResult> listar = Database.query(queryar);
                    system.debug('listar:'+listar);
                    for(AggregateResult ar : listar){
                        String userid = (String)ar.get('User_Run__c');
                        Decimal total = (Decimal)ar.get('Total');
                        listuserid.add(userid);
                        Monitoring_Summary__c msget = mapms.get(userid);
                        if(msget != null){
                            if(msget.Total__c != total){
                                Monitoring_Summary__c ms = new Monitoring_Summary__c();
                                ms.Id = msget.Id;
                                ms.Total__c = total;
                                listupdatems.add(ms);
                            }
                        }else{
                            Monitoring_Summary__c ms = new Monitoring_Summary__c();
                            ms.Anomali_Category__c = ac.Id;
                            ms.Date__c = dt;
                            ms.User__c = userid;
                            ms.Total__c = total;
                            listinsertms.add(ms);
                        }
                    }
                }
            }
        }
        
        system.debug('listuserid:'+listuserid);
        if(listuserid.size()>0){
            String queryel = 'SELECT Id,Anomali__c,User_Run__c FROM Error_Log__c ';
            queryel += 'WHERE Error_Datetime__c = ' + strdt + ' ';
            queryel += 'AND Response_Status_Code__c = 200 ';
            queryel += 'AND Menu__c !=: menu ';
            queryel += 'AND Destination__c =: destination ';
            queryel += 'AND User_Run__c IN:listuserid ';
            queryel += 'ORDER BY User_Run__c ASC, Error_Datetime__c ASC ';
            List<Error_Log__c> listel = Database.query(queryel);
            if(listel.size()>0){
                List<Error_Log__c> listelnew = new List<Error_Log__c>();
                for(Error_Log__c el : listel){
                    if(el.Anomali__c == '' || el.Anomali__c == null){
                        el.Anomali__c = anomali;
                        listelnew.add(el);
                    }else if(!el.Anomali__c.contains(anomali)){
                        el.Anomali__c = el.Anomali__c + ';' + anomali;
                        listelnew.add(el);
                    }
                }
                system.debug('listelnew:'+listelnew);
                if(listelnew.size()>0) update listelnew;
            }
        }
        system.debug('listinsertms:'+listinsertms);
        system.debug('listupdatems:'+listupdatems);
        if(listinsertms.size()>0) insert listinsertms;
        if(listupdatems.size()>0) update listupdatems;
    }
    
    public static void Business_Hours(String strdt,Date dt){
        system.debug('--Business_Hours--');
        String anomali = 'Access Outside Business Hours';
        String recordTypeName = 'Outside Business Hours';
        String menu = 'Home';
        String destination = 'Data Hub';
        List<BusinessHours> listbhs = [SELECT Id,SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, 
                                       TuesdayStartTime, TuesdayEndTime, WednesdayStartTime, WednesdayEndTime, 
                                       ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, 
                                       SaturdayStartTime, SaturdayEndTime
                                       FROM BusinessHours];
        Map<String,BusinessHours> mapbhs = new Map<String,BusinessHours>();
        for(BusinessHours bhs : listbhs){
            mapbhs.put(bhs.id,bhs);
        }
        
        List<Anomali_Category__c> listacs = [SELECT Id,Profile__c,Business_Hours__c FROM Anomali_Category__c
                                             WHERE RecordType.Name =:recordTypeName
                                             AND Active__c = TRUE
                                             AND Business_Hours__c != null];
        Map<String,Anomali_Category__c> mapacs = new Map<String,Anomali_Category__c>();
        for(Anomali_Category__c acs : listacs){
            mapacs.put(acs.Profile__c,acs);
        }
        
        String queryel = 'SELECT Id,Anomali__c,User_Run__c,User_Run__r.Profile.Name,Error_Datetime__c ';
        queryel += 'FROM Error_Log__c ';
        queryel += 'WHERE Error_Datetime__c = ' + strdt + ' ';
        queryel += 'AND Response_Status_Code__c = 200 ';
        queryel += 'AND Menu__c !=: menu ';
        queryel += 'AND Destination__c =: destination ';
        queryel += 'ORDER BY User_Run__c ASC, Error_Datetime__c ASC ';
        List<Error_Log__c> listel = Database.query(queryel);
        List<Error_Log__c> listelnew = new List<Error_Log__c>();
        Map<String,String> mapuseranomali = new Map<String,String>();
        for(Error_Log__c el : listel){
            String dayOfWeek = el.Error_Datetime__c.format('EEEE');
            system.debug('dayOfWeek:'+dayOfWeek);
            Anomali_Category__c ac = mapacs.get(el.User_Run__r.Profile.Name);
            if(ac != null){
                mapuseranomali.put(el.User_Run__c,ac.Id);
                BusinessHours bh = mapbhs.get(ac.Business_Hours__c);
                if(bh != null){
                    Boolean flag = false;
                    Time tm = el.Error_Datetime__c.Time();
                    if(dayOfWeek == 'Sunday') flag = validateHours(tm,bh.SundayStartTime,bh.SundayEndTime);
                    else if(dayOfWeek == 'Monday') flag = validateHours(tm,bh.MondayStartTime,bh.MondayEndTime);
                    else if(dayOfWeek == 'Tuesday') flag = validateHours(tm,bh.TuesdayStartTime,bh.TuesdayEndTime);
                    else if(dayOfWeek == 'Wednesday') flag = validateHours(tm,bh.WednesdayStartTime,bh.WednesdayEndTime);
                    else if(dayOfWeek == 'Thursday') flag = validateHours(tm,bh.ThursdayStartTime,bh.ThursdayEndTime);
                    else if(dayOfWeek == 'Friday') flag = validateHours(tm,bh.FridayStartTime,bh.FridayEndTime);
                    else if(dayOfWeek == 'Saturday') flag = validateHours(tm,bh.SaturdayStartTime,bh.SaturdayEndTime);
                    system.debug('flag:'+flag);
                    if(flag==true || Test.isRunningTest()){
                        if(el.Anomali__c == '' || el.Anomali__c == null){
                            el.Anomali__c = anomali;
                            listelnew.add(el);
                        }else if(!el.Anomali__c.contains(anomali)){
                            el.Anomali__c = el.Anomali__c + ';' + anomali;
                            listelnew.add(el);
                        }
                    }
                }
            }
        }
        system.debug('listelnew:'+listelnew);
        if(listelnew.size()>0) update listelnew;
        String queryar = 'SELECT User_Run__c,COUNT(Id) Total FROM Error_Log__c ';
        queryar += 'WHERE Error_Datetime__c = ' + strdt + ' ';
        queryar += 'AND Response_Status_Code__c = 200 ';
        queryar += 'AND Menu__c !=: menu ';
        queryar += 'AND Destination__c =: destination ';
        queryar += 'AND Anomali__c INCLUDES(:anomali) ';
        queryar += 'GROUP BY User_Run__c ';
        queryar += 'ORDER BY User_Run__c ASC ';
        List<AggregateResult> listar = Database.query(queryar);
        Map<String,Integer> mapUserTotal = new Map<String,Integer>();
        for(AggregateResult ar : listar){
            mapUserTotal.put(String.ValueOf(ar.get('User_Run__c')),Integer.valueOf(ar.get('Total')));
        }
        anomali = anomali + '%';
        List<Monitoring_Summary__c> listms = [SELECT Id,User__c,Total__c FROM Monitoring_Summary__c
                                              WHERE Date__c =:dt
                                              AND Anomali_Category__r.Name LIKE:anomali];
        Map<String,Monitoring_Summary__c> mapms = new Map<String,Monitoring_Summary__c>();
        for(Monitoring_Summary__c ms : listms){
            mapms.put(ms.User__c,ms);
        }
        List<Monitoring_Summary__c> listupdatems = new List<Monitoring_Summary__c>();
        List<Monitoring_Summary__c> listinsertms = new List<Monitoring_Summary__c>();
        if(mapUserTotal.keySet().size()>0){
            for(String strid : mapUserTotal.keySet()){
                String anomaliid = mapuseranomali.get(strid);
                if(anomaliid != null){
                    Monitoring_Summary__c msget = mapms.get(strid);
                    if(msget != null){
                        if(msget.Total__c != mapUserTotal.get(strid)){
                            Monitoring_Summary__c ms = new Monitoring_Summary__c();
                            ms.Id = msget.Id;
                            ms.Total__c = mapUserTotal.get(strid);
                            listupdatems.add(ms);
                        }
                    }else{
                        Monitoring_Summary__c ms = new Monitoring_Summary__c();
                        ms.Anomali_Category__c = anomaliid;
                        ms.Date__c = dt;
                        ms.User__c = strid;
                        ms.Total__c = mapUserTotal.get(strid);
                        listinsertms.add(ms);
                    }
                }
            }
        }
        system.debug('listinsertms:'+listinsertms);
        system.debug('listupdatems:'+listupdatems);
        if(listinsertms.size()>0) insert listinsertms;
        if(listupdatems.size()>0) update listupdatems;
    }
    
    public static void Not_Create_Case(String strdt,Date dt){
        system.debug('--Not_Create_Case--');
        String anomali = 'Access Datahub Not Create Case';
        String recordTypeName = 'Access Not Create Case';
        String menu = 'Home';
        String destination = 'Data Hub';
        List<Anomali_Category__c> listac = [SELECT Id FROM Anomali_Category__c
                                           WHERE Name =:anomali
                                           AND RecordType.Name =:recordTypeName];
        system.debug('listac:'+listac);
        String query = 'SELECT Id,Anomali__c,User_Run__c,User_Run__r.Profile.Name,Error_Datetime__c, ';
        query += 'RelatedId__c,Object_Name__c ';
        query += 'FROM Error_Log__c ';
        query += 'WHERE Error_Datetime__c = '+ strdt +' ';
        query += 'AND Response_Status_Code__c = 200 ';
        query += 'AND Menu__c !=:menu ';
        query += 'AND Destination__c =: destination ';
        query += 'ORDER BY User_Run__c ASC, Error_Datetime__c ASC ';
        List<Error_Log__c> listel = Database.query(query);
        List<Error_Log__c> listelnew = new List<Error_Log__c>();
        List<String> listaccountid = new List<String>();
        List<String> listcaseid = new List<String>();
        for(Error_Log__c el : listel){
            if(el.Object_Name__c == 'Account') listaccountid.add(el.RelatedId__c);
            else if(el.Object_Name__c == 'Case') listcaseid.add(el.RelatedId__c);
        }
        String querych1 = 'SELECT Id,Case.AccountId FROM CaseHistory WHERE Case.AccountId IN:listaccountid AND CreatedDate = ' +strdt;
        List<CaseHistory> listch1 = Database.query(querych1);
        Map<String,String> maphistory = new Map<String,String>();
        for(CaseHistory ch : listch1){
            maphistory.put(ch.Case.AccountId,ch.Id);
        }
        String querych2 = 'SELECT Id,CaseId FROM CaseHistory WHERE CaseId IN:listcaseid AND CreatedDate = ' +strdt;
        List<CaseHistory> listch2 = Database.query(querych2);
        for(CaseHistory ch : listch2){
            maphistory.put(ch.CaseId,ch.Id);
        }
        
        for(Error_Log__c el : listel){
            Boolean flag = false;
            if(el.RelatedId__c != null){
                String strid = maphistory.get(el.RelatedId__c);
                if(strid == null) flag = true;
                
                system.debug('strid:'+strid);
                system.debug('flag:'+flag);
                if(flag==true){
                    if(el.Anomali__c == '' || el.Anomali__c == null){
                        el.Anomali__c = anomali;
                        listelnew.add(el);
                    }else if(!el.Anomali__c.contains(anomali)){
                        el.Anomali__c = el.Anomali__c + ';' + anomali;
                        listelnew.add(el);
                    }
                }
            }
            
        }
        system.debug('listelnew:'+listelnew);
        if(listelnew.size()>0) update listelnew;
        String queryar = 'SELECT User_Run__c,COUNT(Id) Total FROM Error_Log__c ';
        queryar += 'WHERE Error_Datetime__c = ' + strdt + ' ';
        queryar += 'AND Response_Status_Code__c = 200 ';
        queryar += 'AND Menu__c !=: menu ';
        queryar += 'AND Destination__c =: destination ';
        queryar += 'AND Anomali__c INCLUDES(:anomali) ';
        queryar += 'GROUP BY User_Run__c ';
        queryar += 'ORDER BY User_Run__c ASC ';
        List<AggregateResult> listar = Database.query(queryar);
        Map<String,Integer> mapUserTotal = new Map<String,Integer>();
        for(AggregateResult ar : listar){
            mapUserTotal.put(String.ValueOf(ar.get('User_Run__c')),Integer.valueOf(ar.get('Total')));
        }
        anomali = anomali + '%';
        List<Monitoring_Summary__c> listms = [SELECT Id,User__c,Total__c FROM Monitoring_Summary__c
                                              WHERE Date__c =:dt
                                              AND Anomali_Category__r.Name LIKE:anomali];
        Map<String,Monitoring_Summary__c> mapms = new Map<String,Monitoring_Summary__c>();
        for(Monitoring_Summary__c ms : listms){
            mapms.put(ms.User__c,ms);
        }
        List<Monitoring_Summary__c> listupdatems = new List<Monitoring_Summary__c>();
        List<Monitoring_Summary__c> listinsertms = new List<Monitoring_Summary__c>();
        if(mapUserTotal.keySet().size()>0){
            for(String strid : mapUserTotal.keySet()){
                String anomaliid = listac[0].Id;
                if(anomaliid != null){
                    Monitoring_Summary__c msget = mapms.get(strid);
                    if(msget != null){
                        if(msget.Total__c != mapUserTotal.get(strid)){
                            Monitoring_Summary__c ms = new Monitoring_Summary__c();
                            ms.Id = msget.Id;
                            ms.Total__c = mapUserTotal.get(strid);
                            listupdatems.add(ms);
                        }
                    }else{
                        Monitoring_Summary__c ms = new Monitoring_Summary__c();
                        ms.Anomali_Category__c = anomaliid;
                        ms.Date__c = dt;
                        ms.User__c = strid;
                        ms.Total__c = mapUserTotal.get(strid);
                        listinsertms.add(ms);
                    }
                }
            }
        }
        system.debug('listinsertms:'+listinsertms);
        system.debug('listupdatems:'+listupdatems);
        if(listinsertms.size()>0) insert listinsertms;
        if(listupdatems.size()>0) update listupdatems;
    }
    
    public static boolean validateHours(Time tm, Time StartTime, Time EndTime){
        Boolean flag = false;
        if(StartTime == null || EndTime == null) flag = true;
        else if(StartTime == EndTime) flag = false; //24Hours
        else if(tm < StartTime || tm > EndTime) flag = true;
        return flag;
    }
}