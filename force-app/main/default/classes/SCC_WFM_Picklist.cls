/*
Created by = Femy
UST  = WFM
*/
public with sharing class SCC_WFM_Picklist {
    @AuraEnabled
    public static List<PicklistValue> getPicklistValue(Date tanggal,String userid1,Boolean isrequester,String jkid1,String jkid2,String type) {
        List<PicklistValue> options = new List<PicklistValue>();
        String cond = 'Tanggal__c = :tanggal';
        String tipeoff = 'OFF';
        String libur = 'LIBUR';
        if(type.toUpperCase().contains(tipeoff)){
            cond+=' and Opsi_Jadwal__r.Kode__c = :tipeoff';
        }
        else{
            cond+=' and Opsi_Jadwal__r.Kode__c != :tipeoff and Opsi_Jadwal__r.Kode__c != :libur';
        }
        if(isrequester){
            cond+=' and Nama_Karyawan__c = :userid1';
        }
        else{
            cond+=' and Nama_Karyawan__c != :userid1 and Id != : jkid1';
        }
        String addfield = ',Nama_Karyawan__r.Name,Opsi_Jadwal__r.Name';
        String allfield = SOQL_SOBJECT.getallfield('Jadwal_Karyawan__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Jadwal_Karyawan__c', cond, '', '', '');
        
        List<Jadwal_Karyawan__c> listjk = Database.query(queries);
        Boolean s = true;
        PicklistValue pv1 = new PicklistValue();
        pv1.label = '';
        pv1.value = '';
        options.add(pv1);
        for(Jadwal_Karyawan__c jk:listjk){
            PicklistValue pv = new PicklistValue();
            pv.label = jk.Nama_Karyawan__r.Name +' ('+ String.valueOf(jk.Jam_Masuk__c).substringBefore('.')+' - '+String.valueof(jk.Jam_Pulang__c).substringBefore('.')+')';
            pv.value = jk.id;
            if((jkid1==pv.value && isrequester) || (jkid2==pv.value && !isrequester)){
                pv.selected = true;  
            }
            options.add(pv);
        }
        return options;
    }

    @AuraEnabled
    public static List<PicklistValue> getPicklistList(String objnm,String fldnm,String val) {
        List<PicklistValue> options = new List<PicklistValue>();
        Schema.DescribeFieldResult describeResult = Schema.getGlobalDescribe().get(objnm).getDescribe().fields.getMap().get(fldnm).getDescribe();
        List<Schema.PicklistEntry> entries = describeResult.getPicklistValues();
        PicklistValue pv1 = new PicklistValue();
        pv1.label = '';
        pv1.value = '';
        options.add(pv1);
        for (Schema.PicklistEntry pEntry : entries) {
            if (pEntry.isActive()) {
                PicklistValue pv = new PicklistValue();
                pv.label = String.valueOf(pEntry.getLabel());
                pv.value = String.valueOf(pEntry.getValue());
                if(val==pv.value){
                    pv.selected = true;  
                }
                options.add(pv);
            }
        }
        return options;
    }

    @AuraEnabled
    public static List<PicklistValue> getPicklistListSpecial(String objnm,String fldnm,String val) {
        List<PicklistValue> options = getPicklistList(objnm, fldnm, val);
        List<PicklistValue> options2 = new List<PicklistValue>();
        for(PicklistValue  pv: options){
            if(pv.value!='Request Off' && objnm =='Request_Change_Shift__c' && fldnm=='Type__c'){
                options2.add(pv);
            }
        }
        return options2;
    }

    @AuraEnabled
    public static Jadwal_Karyawan__c getJadwalKaryawan(String idjk) {
        String cond = 'Id = :idjk';
        String addfield = ',Nama_Karyawan__r.Name';
        String allfield = SOQL_SOBJECT.getallfield('Jadwal_Karyawan__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Jadwal_Karyawan__c', cond, '', '', '');
        Jadwal_Karyawan__c jk = Database.query(queries);
        return jk;
    }

    @AuraEnabled
    public static User getUser(String idus) {
        String cond = 'Id = :idus';
        String addfield = '';
        String allfield = 'Id,Name';
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'User', cond, '', '', '');
        system.debug(idus);
        system.debug(queries);
        User jk = Database.query(queries);
        return jk;
    }

    public class PicklistValue{
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public Boolean selected {get;set;}
    }
}