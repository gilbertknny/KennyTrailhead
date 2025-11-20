public class CaseHolidayTriggerHandler {
    public static void updateHoliday(List<Case> newCases, Map<Id, Case> oldMap) {
        BusinessHours bh = [SELECT Id, Name, IsActive, IsDefault, SundayStartTime, SundayEndTime, MondayStartTime, MondayEndTime, TuesdayStartTime, TuesdayEndTime, 
                        WednesdayStartTime, WednesdayEndTime, ThursdayStartTime, ThursdayEndTime, FridayStartTime, FridayEndTime, SaturdayStartTime, SaturdayEndTime FROM BusinessHours
                        WHERE NAME = : label.Business_Hours_Default AND IsActive = TRUE LIMIT 1];
        Time jammasuk = Time.newInstance(Integer.valueOf(label.Jam_Masuk), 1, 0, 0);
        Time jampulang = Time.newInstance(Integer.valueOf(label.Jam_Pulang), 1, 0, 0);
        List<Id> listidct = new List<Id>();
        Map<Id,Decimal> mapsla = new Map<Id,Decimal>();
        for(Case c : newCases){
            if (String.isNotBlank(c.SCC_Call_Type__c)) {
                listidct.add(c.SCC_Call_Type__c);
            }
         }
         if(!listidct.isEmpty()){
            List<SSC_Call_Type__c> listct = [Select Id, SCC_Total_SLA__c	from SSC_Call_Type__c where Id IN: listidct];
            for(SSC_Call_Type__c ct :listct){
                mapsla.put(ct.Id,ct.SCC_Total_SLA__c);
            }
         }
        for(Case c : newCases){
            Date tpr = c.Tanggal_Pengaduan_Regulator__c;
            Date ttkea = c.Tanggal_Tanggapan_ke_EMAIL_APPK__c;
            Date tskku = c.Tanggal_Surat_Keluar_ke_Uker__c;
            Datetime startDate;
            Datetime startDateSLAPelaporan;
            Datetime startDateUker;
            Datetime startDateregulator;
            Datetime startDatePIC;
            DateTime endDate;
            DateTime endDateSLAPelaporan;
            DateTime endDateUker;
            DateTime endDateregulator;
            DateTime endDatePIC;
            DateTime createddate = system.now();
            if(c.CreatedDate!=null){
                createddate = c.createddate;
            }
            DateCalculator dc = new DateCalculator();
            DateCalculator dc1 = new DateCalculator();
            DateCalculator dc2 = new DateCalculator();
            DateCalculator dc3 = new DateCalculator();
            DateCalculator dc4 = new DateCalculator();
            /* start CaseHoliday count */
            Decimal totsla = mapsla.get(c.SCC_Call_Type__c);
            startDate = c.CreatedDate != null ? c.CreatedDate : System.now();
            startDate = startdate.addDays(1);
            startDate = Datetime.newInstance(startDate.date(),jammasuk);
            //endDate = c.IsClosed ? c.ClosedDate : CreatedDate.addDays(integer.valueOf(totsla));
            //endDate = !c.IsClosed && system.now() > endDate ? system.now() : endDate;
            endDate = c.IsClosed ? c.ClosedDate : system.now();
            dc = setdateCalculator(startDate, endDate, bh, true); 
            c.Holiday__c = dc.totholiday;
            /* end CaseHoliday count */
            /** start NetworkDaysSLARegulatorCalculatorTrigger */
            if (c.Tanggal_Pengaduan_Regulator__c != null) {
                startDateregulator = Datetime.newInstance(tpr,jammasuk).addDays(1);
                if(C.Tanggal_Tanggapan_ke_EMAIL_APPK__c!=null){
                    endDateregulator = Datetime.newInstance(ttkea.year(),ttkea.month(),ttkea.day()).addHours(Integer.valueof(label.Jam_Pulang));
                }
                else{
                    endDateregulator = c.IsClosed ? c.ClosedDate : system.now();
                }
                dc1 = setdateCalculator(startDateregulator, endDateregulator, bh, true);
                endDateregulator = dc1.enddate;
                c.Menghitung_SLA_Regulator2__c = dc1.totwork;
            }
            else{
                c.Menghitung_SLA_Regulator2__c = null;
            }
            /** end NetworkDaysSLARegulatorCalculatorTrigger */
            /** start DueDatePICCalculatorTrigger */
            if (c.Tanggal_Pengaduan_Regulator__c != null && C.Jumlah_hari_SLA_Regulator__c != null) {
                startDatePIC = Datetime.newInstance(tpr,jammasuk).addDays(1);
                endDatePIC = startDatePIC.addDays(Integer.valueOf(C.Jumlah_hari_SLA_Regulator__c));
                dc2 = setdateCalculator(startDatePIC, endDatePIC, bh, false);
                c.Due_Date_PIC__c = dc2.enddate.date();
            }
            else{
                c.Due_Date_PIC__c = null;
            }
            /** end DueDatePICCalculatorTrigger */
            /** start DueDateUkerCalculatorTrigger */
            if (c.Tanggal_Surat_Keluar_ke_Uker__c != null && c.Jumlah_hari_SLA_Regulator__c != null) {
                startDateUker = Datetime.newInstance(tskku,jammasuk).addDays(1);
                endDateUker = startDateUker.addDays(Integer.valueOf(C.Jumlah_hari_SLA_Regulator__c)-1);
                dc3 = setdateCalculator(startDateUker, endDateUker, bh, false);
                c.Due_Date_Uker__c = dc3.enddate.date(); 
            } else {
                c.Due_Date_Uker__c = null; 
            }
            /** end DueDateUkerCalculatorTrigger */
            /** start NetworkDaysCalculatorTrigger */
            if (c.Tanggal_Pengaduan_Regulator__c != null) {
                startDateSLAPelaporan = Datetime.newInstance(tpr.year(),tpr.month(),tpr.day(),Integer.valueof(label.Jam_Masuk),0,0).addDays(1);
                endDateSLAPelaporan = c.Tanggal_Tanggapan_ke_EMAIL_APPK__c!=null ?  Datetime.newInstance(ttkea.year(),ttkea.month(),ttkea.day()).addHours(Integer.valueof(label.Jam_Pulang)) : system.now();
                dc4 = setdateCalculator(startDateSLAPelaporan, endDateSLAPelaporan, bh, true);
                c.SLA_Pelaporan2__c = dc4.totwork;
            } else {
                c.SLA_Pelaporan2__c = null; // Set to null if start date is null
            }
            /** end NetworkDaysCalculatorTrigger */
        }
    }

    public static Datetime setstardate(Datetime startDate,BusinessHours bh,Time jammasuk,Time jampulang){
        for(integer i=1;i>0;i++){
            system.debug('startDate : '+startDate);
            Boolean bu = BusinessHours.isWithin(bh.id, startDate);
            Datetime startbutdy = Datetime.newInstance(startDate.date(),jammasuk);
            Datetime endbutdy = Datetime.newInstance(startDate.date(),jampulang);
            if(!bu){
                if(startDate<startbutdy){
                    startDate = startbutdy;
                }
                else{
                    startDate = startDate.addDays(1);
                    startDate = Datetime.newInstance(startDate.date(),jammasuk);
                }
            }
            else{
                break;
            }
        }
        return startDate;
    }

    public static DateCalculator setdateCalculator(Datetime startdate, Datetime enddate, BusinessHours bh, Boolean ckcur){
        DateCalculator dc = new DateCalculator();
        dc.startdate = startdate;
        Decimal libur = 0;
        Decimal masuk = 0;
        for(Datetime strdt = startDate; strdt<=endDate; strdt=strdt.addDays(1)){
            Boolean isWithin = BusinessHours.isWithin(bh.id, strdt);
            if(!isWithin){
                libur++;
                if(!ckcur){
                    endDate = endDate.addDays(1);
                }
            }
            else{
                masuk++;
            }
        }
        dc.enddate = enddate;
        dc.totholiday = libur;
        dc.totwork = masuk;
        return dc;
    }

    public class DateCalculator{
        public Datetime startdate {get;set;}
        public Datetime enddate {get;set;}
        public Decimal totholiday {get;set;}
        public Decimal totwork {get;set;}
    }
    
}