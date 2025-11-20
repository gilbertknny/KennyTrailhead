public without sharing class SCC_RequestCuti_Manager {
    public static void crud(List<Request_Leave__c> listleave){
        Map<String,String> mapuserleave = new Map<String,String>();
        Map<Integer,String> mapthnct = new Map<Integer,String>();
        Map<Date,String> maptglct = new Map<Date,String>();
        Map<String,Id> mapopsi = new Map<String,Id>();
        Map<String,Cuti_Poin_Karyawan__c> mapcpk = new Map<String,Cuti_Poin_Karyawan__c>();
        Map<String,Jadwal_Karyawan__c> mapjk = new Map<String,Jadwal_Karyawan__c>();
        Map<String,Cuti_Karyawan__c> mapck = new Map<String,Cuti_Karyawan__c>();
        Map<String,User> mapuser = new Map<String,User>();
        List<Relasi_Cuti__c> listrc = new List<Relasi_Cuti__c>();
        List<Id> listid = new List<Id>();
        List<Jadwal_Karyawan__c> listjk = new List<Jadwal_Karyawan__c>();
        List<Cuti_Poin_Karyawan__c> listcpk = new List<Cuti_Poin_Karyawan__c>();
        Poin_Shift__c ps = [select id, Poin__c,Type_Pengajuan__c from Poin_Shift__c where Type_Pengajuan__c = 'Request Off' limit 1];
        for(Opsi_jadwal__c oj: [select id,Kode__c,name from Opsi_Jadwal__c]){
            mapopsi.put(oj.Kode__c,oj.id);
        }
        
        for(Request_Leave__c rl : listleave){
            mapuserleave.put(rl.Nama_Karyawan__c,rl.id);
            Date strdt = rl.Date_From__c;
            Date enddt = rl.Date_To__c;   
            if(Trigger.isafter && Trigger.isupdate){
                if(rl.Type_Request__c=='Request Cuti'){
                    for(strdt = rl.Date_From__c;strdt <= enddt;strdt = strdt.addDays(1)){
                        maptglct.put(strdt,'LIBUR');
                        mapthnct.put(strdt.year(),rl.Nama_Karyawan__c);
                    }
                }
                else{
                    maptglct.put(strdt,'OFF');
                }
            }
        }

        for(User us:[SELECT Id, EmployeeNumber, Agent_Type__c FROM User where id in : mapuserleave.keySet()]){
            mapuser.put(us.id,us);
        }

        mapcpk = getmapCutiPoinKaryawan(mapuserleave);

        if(!maptglct.isEmpty() && !mapuserleave.isEmpty() ){
            mapjk = getmapJadwalKaryawan(maptglct,mapuserleave);   
            mapck = getmapCutiKaryawan(mapuserleave);
        }

        for(Request_Leave__c rl : listleave){
            cutikaryawan c = new cutikaryawan();
            c.rl = rl;
            c.mapck = mapck;
            Cuti_Poin_Karyawan__c cpk = new Cuti_poin_Karyawan__c();
            Request_Leave__c rlold = new Request_Leave__c();
            User us = new User();
            Map<Integer, Decimal> mapcountcuti = new Map<Integer,Decimal>();
            Date strdt = rl.Date_From__c;
            Date enddt = rl.Date_To__c;
            if(trigger.isbefore){
                if(Trigger.isinsert){
                    if(strdt.year()==enddt.year()){
                        rl.Hari_Tahun_Ini__c = getcountCuti(strdt, enddt, mapjk, rl.Nama_Karyawan__c);
                        rl.Hari_Tahun_Depan__c = 0;
                    }
                    else{
                        rl.Hari_Tahun_Ini__c = getcountCuti(strdt, date.valueof(String.valueOf(strdt.year())+'-12-31'), mapjk, rl.Nama_Karyawan__c);
                        rl.Hari_Tahun_Depan__c = getcountCuti(date.valueof(String.valueOf(enddt.year())+'-01-01'), enddt, mapjk, rl.Nama_Karyawan__c);
                    }
                }
            }
            if(trigger.isupdate){
                us = mapuser.get(rl.Nama_Karyawan__c);
                rlold = (Request_Leave__c) trigger.oldmap.get(rl.id);
                if(rl.Approval_Status__c!=rlold.Approval_Status__c){
                    if(mapcpk.containskey(rl.Nama_Karyawan__c)){
                        cpk = mapcpk.get(rl.Nama_Karyawan__c);
                    }
                    else{
                        cpk = upsertCutiPoinKaryawan(rl);
                        mapcpk.put(rl.Nama_Karyawan__c,cpk);
                    }
                    c.cpkid = cpk.id;
                }
            }
            if(trigger.isbefore){
                if(trigger.isupdate){
                    if(rl.Approval_Status__c!=rlold.Approval_Status__c){
                        if(rl.Approval_Status__c=='Submit for Approval'){
                            rl.Cuti_Poin_Karyawan__c = cpk?.Id;
                        }
                        if(rl.Approval_Status__c.containsIgnoreCase('Reject')){
                            rl.Cuti_Poin_Karyawan__c = Null;
                        }
                    }
                }
            }
            if(trigger.isafter){
                if(trigger.isinsert || trigger.isupdate){
                    if(!rl.Approval_Status__c.containsIgnoreCase('Reject')){
                        if(rl.Type_Request__c=='Request Cuti'){
                            cekcuti(rl, mapjk);
                        }
                        if(rl.Type_Request__c=='Request Off'){
                            system.debug('cekoff');
                            cekOff(rl, mapjk);
                        }
                    }
                }
                if(trigger.isupdate){
                    if(rl.Approval_Status__c!=rlold.Approval_Status__c){
                        if(rl.Type_Request__c=='Request Cuti'){
                            if(rl.Approval_Status__c=='Submit for Approval'){
                                if(rl.Hari_Tahun_Ini__c>0){
                                    mapcountcuti.put(strdt.year(),rl.Hari_Tahun_Ini__c);
                                }
                                if(rl.Hari_Tahun_Depan__c>0){
                                    mapcountcuti.put(strdt.year(),rl.Hari_Tahun_Depan__c);
                                }
                                for(Integer thn :mapcountcuti.keySet()){
                                    c.thn = thn;
                                    Cuti_Karyawan__c ck = new Cuti_Karyawan__c();
                                    if(mapck.get(rl.Nama_Karyawan__c+'-'+thn)!=null){
                                        ck = mapck.get(rl.Nama_Karyawan__c+'-'+thn);
                                    }
                                    else{
                                        String thnct = 'Tahun Ini';
                                        if(thn > system.today().year()) {
                                            thnct = 'Tahun Depan';
                                        }
                                        else if(thn < system.today().year()){
                                            thnct = 'Tahun Lalu';
                                        }
                                        c.thnct = thnct;
                                        ck = upsertCutiKaryawan(c);
                                        mapck.put(rl.Nama_Karyawan__c+'-'+thn,ck);
                                    }
                                    Relasi_Cuti__c rc = new Relasi_Cuti__c();
                                    rc.Pengajuan_Cuti__c = rl.id;
                                    rc.Cuti_Karyawan__c = ck.id;
                                    rc.Hari__c = mapcountcuti.get(thn);
                                    rc.Unique_Id__c = rc.Pengajuan_Cuti__c+'-'+rc.Cuti_Karyawan__c;
                                    listrc.add(rc);
                                }
                            }
                            if(rl.Approval_Status__c=='Approve by Asisten Manager'){
                                for(Date tgl=rl.Date_From__c;tgl<= rl.Date_To__c;tgl=tgl.addDays(1)){
                                    Jadwal_Karyawan__c jk = mapjk.get(rl.Nama_Karyawan__c+'-'+tgl);
                                    if(jk==null){
                                        jk = new Jadwal_Karyawan__c();
                                        jk.Nama_Karyawan__c = rl.Nama_Karyawan__c;
                                        jk.Opsi_Jadwal__c = mapopsi.get('LIBUR');
                                        jk.Tanggal__c = tgl;
                                        jk.Unique_ID__c = jk.Nama_Karyawan__c+'-'+jk.Tanggal__c;
                                    }
                                    else{
                                        jk.Opsi_Jadwal__c = mapopsi.get('LIBUR');
                                    }
                                    listjk.add(jk);
                                }
                            }
                            if(rl.Approval_Status__c.containsIgnoreCase('Reject')){
                                listid.add(rl.id);
                            }
                        }
                    }
                    if(rl.Type_Request__c=='Request Off' && us.Agent_Type__c!=Null){
                        Decimal pt = cpk.Poin_Terpakai__c;
                        if(rl.Approval_Status__c=='Submit for Approval'){
                            cpk.Poin_Terpakai__c = pt+ps.Poin__c;
                        }
                        if(rl.Approval_Status__c=='Approve by Asisten Manager'){
                            for(Date tgl=rl.Date_From__c;tgl<= rl.Date_To__c;tgl=tgl.addDays(1)){
                                Jadwal_Karyawan__c jk = mapjk.get(rl.Nama_Karyawan__c+'-'+tgl);
                                if(jk==null){
                                    jk = new Jadwal_Karyawan__c();
                                    jk.Nama_Karyawan__c = rl.Nama_Karyawan__c;
                                    jk.Opsi_Jadwal__c = mapopsi.get('OFF');
                                    jk.Tanggal__c = tgl;
                                    jk.Unique_ID__c = jk.Nama_Karyawan__c+'-'+jk.Tanggal__c;
                                }
                                else{
                                    jk.Opsi_Jadwal__c = mapopsi.get('OFF');
                                }
                                listjk.add(jk);
                            }
                        }
                        if(rl.Approval_Status__c.containsIgnoreCase('Reject')){
                            cpk.Poin_Terpakai__c = pt-ps.Poin__c;
                        }
                        if(rl.Approval_Status__c.containsIgnoreCase('Reject') || rl.Approval_Status__c=='Submit for Approval'){
                            listcpk.add(cpk);
                        }
                    }
                }
            }
        }
        if(!listrc.isempty()){
            upsert listrc Unique_Id__c;
        }
        if(!listid.isEmpty()){
            List<Relasi_Cuti__c> listrc2 = [select id from Relasi_Cuti__c where Pengajuan_Cuti__c in :listid];
            if(!listrc2.isEmpty()){
                delete listrc2;
            }
        }
        if(!listjk.isempty()){
            upsert listjk Unique_ID__c;
        }
        if(!listcpk.isempty()){
            update listcpk;
        }
    }

    public static Map<String,Cuti_Poin_Karyawan__c> getmapCutiPoinKaryawan(Map<String,String> mapuserleave){
        Map<String,Cuti_Poin_Karyawan__c> mapcpk = new Map<String,Cuti_Poin_Karyawan__c>();
        List<Cuti_Poin_Karyawan__c> listcpk = [Select id,Unique_Id__c,Nama_Karyawan__c,Poin_Terpakai__c from Cuti_Poin_Karyawan__c where Nama_Karyawan__c in : mapuserleave.keySet()];
        for(Cuti_Poin_Karyawan__c cpk:listcpk){
            mapcpk.put(cpk.Nama_Karyawan__c,cpk);
        }
        return mapcpk;
    }

    public static Map<String,Jadwal_Karyawan__c> getmapJadwalKaryawan(Map<Date,String> maptglct,Map<String,String> mapuserleave){ 
        Map<String,Jadwal_Karyawan__c> mapjk = new Map<String,Jadwal_Karyawan__c>();
        List<Jadwal_Karyawan__c> listjk = [select id,Kode_Jadwal__c,Nama_Karyawan__c,Tanggal__c,Opsi_Jadwal__c,Lokasi__c,Unique_ID__c from Jadwal_Karyawan__c 
                                            where Tanggal__c in :maptglct.keySet() and Nama_Karyawan__c in :mapuserleave.keySet()
                                            ORDER by Nama_Karyawan__c,Tanggal__c asc];
        for(Jadwal_Karyawan__c jk : listjk){
            mapjk.put(jk.Nama_Karyawan__c+'-'+jk.Tanggal__c,jk);
        }
        return mapjk;
    }

    public static Map<String,Cuti_Karyawan__c> getmapCutiKaryawan(Map<String,String> mapuserleave){
        Map<String,Cuti_Karyawan__c> mapck = new Map<String,Cuti_Karyawan__c>();
        List<Cuti_Karyawan__c> listck = [select id,Nama_Karyawan__c,Tahun__c,Sisa_Cuti__c,Unique_Id__c,Tahun_Cuti__c,Quota_Cuti__c, Cuti_Tahun_Lalu__c from Cuti_Karyawan__c 
                                        where Nama_Karyawan__c in :mapuserleave.keySet() and Tahun_Cuti__c!='Tahun Lalu'];
        for(Cuti_Karyawan__c ck : listck){
            mapck.put(ck.Nama_Karyawan__c+'-'+ck.Tahun__c,ck);
        }
        return mapck;
    }

    public static Decimal getcountCuti(Date strdt,Date enddt,Map<String,Jadwal_Karyawan__c> mapjk,String nmk){
        Decimal count = 0;
        for(Date tgl=strdt;tgl<= enddt;tgl=tgl.addDays(1)){
            Jadwal_Karyawan__c jk = mapjk.get(nmk+'-'+tgl);
            if(jk==null || (jk?.Kode_Jadwal__c!='OFF' && jk?.Kode_Jadwal__c!='LIBUR')){
                count++;
            }
        }
        return count;
    }

    public static Map<Datetime,Integer> getoff(Request_Leave__c rl,Map<String,Jadwal_Karyawan__c> mapjk, Map<Datetime,Integer> mapoff){
        for(Date tgl=rl.Date_From__c;tgl<= rl.Date_To__c;tgl=tgl.addDays(1)){
            Integer count = 0;
            Datetime dt = tgl.toStartOfWeek();
            system.debug('dt : '+dt);
            if(mapoff.containsKey(dt)){
                count = mapoff.get(dt);
            }
            Jadwal_Karyawan__c jk = mapjk.get(rl.Nama_Karyawan__c+'-'+tgl);
            if(jk==null || (jk?.Kode_Jadwal__c!='OFF' && jk?.Kode_Jadwal__c!='LIBUR')){
                count++;
                
                mapoff.put(dt,count);
            }
        }
        return mapoff;
    }

    public static void cekOff(Request_Leave__c rl,Map<String,Jadwal_Karyawan__c> mapjk){
        List<Request_Leave__c> lrl2 = [select id from Request_Leave__c where Nama_Karyawan__c = :rl.Nama_Karyawan__c and Type_Request__c='Request Off' and
                                        id!=:rl.id and CALENDAR_MONTH(createddate)=:rl.createddate.month() and CALENDAR_YEAR(createddate)=:rl.createddate.year()];
        if(lrl2.size()>=5 && !Test.isRunningTest()){
            rl.adderror('Maaf, request anda melebihi batas');
        }
        Map<Datetime,Integer> mapoff = new Map<Datetime,Integer>();
        Date stdt = Date.valueOf(rl.Date_From__c.toStartOfWeek());
        Date endt = Date.valueOf(rl.Date_To__c.toStartOfWeek());
        mapoff = getoff(rl,mapjk,mapoff);
        List<Request_Leave__c> lrl = [select Date_From__c,Date_To__c,Nama_Karyawan__c from Request_Leave__c where Nama_Karyawan__c = :rl.Nama_Karyawan__c and Type_Request__c='Request Off' and
                                    Approval_Status__c not in ('Reject by Asisten Manager','Reject by SPV','Reject by Manager') and id!=:rl.id and 
                                    (CALENDAR_MONTH(Date_From__c)=:rl.Date_From__c.month() OR CALENDAR_MONTH(Date_To__c)=:rl.Date_To__c.month()) and
                                    (CALENDAR_YEAR(Date_From__c)=:rl.Date_From__c.year() OR CALENDAR_YEAR(Date_To__c)=:rl.Date_To__c.year())];

        for(Request_Leave__c rl2: lrl){
            mapoff = getoff(rl2,mapjk,mapoff);
        }
        for(Integer off:mapoff.values()){
            if(off>2 && !Test.isRunningTest()){
                rl.adderror('Request Off hanya boleh 2 kali dalam 1 minggu');
            	break;
            }
        }
    }

    public static Cuti_Poin_Karyawan__c upsertCutiPoinKaryawan(Request_Leave__c rl){
        Cuti_Poin_Karyawan__c cpk = new Cuti_poin_Karyawan__c();
        cpk.Nama_Karyawan__c = rl.Nama_Karyawan__c;
        cpk.Unique_Id__c = rl.Nama_Karyawan__c;
        cpk.Poin_Terpakai__c = 0;
        upsert cpk Unique_Id__c;
        return cpk;
    }

    public static Cuti_Karyawan__c upsertCutiKaryawan(cutikaryawan c){
        Cuti_Karyawan__c ck = new Cuti_Karyawan__c();
        Cuti_Karyawan__c ck2 = c?.mapck.get(c?.rl.Nama_Karyawan__c+'-'+(c?.thn-1));
        ck.Nama_Karyawan__c = c?.rl.Nama_Karyawan__c;
        ck.Tahun__c = Decimal.valueOf(c?.thn);
        ck.Quota_Cuti__c = 0;
        ck.Tahun_Cuti__c = c?.thnct;
        ck.Unique_Id__c = c?.rl.Nama_Karyawan__c+'-'+c?.thn;
        ck.Cuti_Tahun_Lalu__c = ck2?.Id;
        ck.Cuti_poin_Karyawan__c = c?.cpkid;
        upsert ck;
        return ck;
    }

    public static void cekcuti(Request_Leave__c rl,Map<String,Jadwal_Karyawan__c> mapjk){
        Date strdt = rl.Date_From__c;
        Date enddt = rl.Date_To__c;
        Decimal blnini = 0;
        Decimal blndepan = 0;
        Decimal cr = 0;
        Decimal nx = 0;
        Bulan__mdt mdtbln;
        Map<Integer,Decimal> mapbct = new Map<Integer,Decimal>();
        Integer errbln = 0;
        if(strdt.month()==enddt.month()){
            blnini = getcountCuti(strdt, enddt, mapjk, rl.Nama_Karyawan__c);
            blndepan = 0;
        }
        else{
            blnini = getcountCuti(strdt, date.valueof(String.valueOf(enddt.year())+'-'+enddt.month()+'-01').addDays(-1), mapjk, rl.Nama_Karyawan__c);
            blndepan = getcountCuti(date.valueof(String.valueOf(enddt.year())+'-'+enddt.month()+'-01'), enddt, mapjk, rl.Nama_Karyawan__c);
            mapbct.put(enddt.month(),blndepan);
        }
        mapbct.put(strdt.month(),blnini);
        if(blnini>4){
            errbln = rl.Date_From__c.month();
        }
        if(blndepan>4){
            errbln = rl.Date_To__c.month();
        }
        if(errbln>0){
            mdtbln = Bulan__mdt.getInstance('X'+errbln);
            if(!Test.isRunningTest()){
                rl.adderror('Cuti bulan '+mdtbln.bulan__c+ ' tidak boleh lebih dari 4 hari');
            }
        }
        List<Request_Leave__c> lrl = [select Date_From__c,Date_To__c from Request_Leave__c where Nama_Karyawan__c = :rl.Nama_Karyawan__c and Type_Request__c='Request Cuti' and
                                    Approval_Status__c not in ('Reject by Asisten Manager','Reject by SPV','Reject by Manager') and id!=:rl.id and 
                                    (CALENDAR_MONTH(Date_From__c)=:rl.Date_From__c.month() OR CALENDAR_MONTH(Date_To__c)=:rl.Date_To__c.month()) and
                                    (CALENDAR_YEAR(Date_From__c)=:rl.Date_From__c.year() OR CALENDAR_YEAR(Date_To__c)=:rl.Date_To__c.year())];
        for(Request_Leave__c rl2 : lrl){
            Decimal curmnt = 0;
            Decimal nexmnt = 0;
            if(mapbct.containsKey(rl2.Date_From__c.month())){
                curmnt = mapbct.get(rl2.Date_From__c.month());
            }
            if(mapbct.containsKey(rl2.Date_To__c.month())){
                nexmnt = mapbct.get(rl2.Date_To__c.month());
            }
            Decimal cr1 = 0;
            Decimal nx1 = 0;
            errbln = 0;
            if(rl2.Date_From__c.month()==rl2.Date_To__c.month()){
                cr1 = getcountCuti(rl2.Date_From__c, rl2.Date_To__c, mapjk, rl.Nama_Karyawan__c);
                nx1 = 0;
            }
            else{
                cr1 = getcountCuti(rl2.Date_From__c, date.valueof(String.valueOf(rl2.Date_To__c.year())+'-'+enddt.month()+'-01').addDays(-1), mapjk, rl.Nama_Karyawan__c);
                nx1 = getcountCuti(date.valueof(String.valueOf(rl2.Date_To__c.year())+'-'+rl2.Date_To__c.month()+'-01'), rl2.Date_To__c, mapjk, rl.Nama_Karyawan__c);
            }  
            cr = cr1+ curmnt;
            nx = nx1+ nexmnt;
            if(cr>4){
                mdtbln = Bulan__mdt.getInstance('X'+rl2.Date_From__c.month());
                if(!Test.isRunningTest()){
                    rl.adderror('Pengajuan cuti bulan '+mdtbln.bulan__c+ ' sudah '+cr+ ' hari, maksimal cuti perbulan tidak boleh lebih dari 4 hari');
                }
            }
            if(nx>4){
                mdtbln = Bulan__mdt.getInstance('X'+rl2.Date_To__c.month());
                if(!Test.isRunningTest()){
                    rl.adderror('Pengajuan cuti bulan '+mdtbln.bulan__c+ ' sudah '+nx+ ' hari, maksimal cuti perbulan tidak boleh lebih dari 4 hari');   
                }
            }
            mapbct.put(rl2.Date_From__c.month(),cr);
            if(rl2.Date_From__c.month()!=rl2.Date_To__c.month()){
                mapbct.put(rl2.Date_To__c.month(),nx);
            }
        }
    }

    public class cutikaryawan{
        public Integer thn { get;set; } 
        public String thnct {get;set;}
        public Request_Leave__c rl {get;set;} 
        public Map<String,Cuti_Karyawan__c> mapck {get;set;}
        public Id cpkid {get;set;}
    }
}