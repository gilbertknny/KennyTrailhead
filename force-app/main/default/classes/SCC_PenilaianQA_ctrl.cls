/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 16-06-2025
 * @last modified by  : Christian Vieri
**/
public without sharing class SCC_PenilaianQA_ctrl {

    // Variabel untuk menyimpan PenilaianQARecordId
    public static String GlobalrecordId;
    public static String GlobalTimestamp;

    //function untuk get Record Type dari object QA_Master__c
    @AuraEnabled(cacheable=true)
    public static List<RecordType> getQARecordType() {
        List<RecordType> rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'QA_Master__c' AND IsActive = true];

        Return rt;
    }
    

    //function untuk get picklist value sub-voice
    @AuraEnabled
    public static List<String> getSubVoicePicklistValues() {
        // Mendapatkan deskripsi dari field picklist
        Schema.DescribeFieldResult fieldResult = QA_Master__c.Sub_Voice__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        // Mengembalikan nilai picklist sebagai list string
        List<String> values = new List<String>();
        for (Schema.PicklistEntry entry : picklistValues) {
            values.add(entry.getLabel());
        }
        return values;
    }

    //function untuk get Detail Case
    @AuraEnabled(cacheable=true)
    public static List<Case> getCaseDetails(Id caseId) {
        List<Case> recordCase =  [SELECT caseNumber, Account.Name, SCC_Card_Number__c, SCC_Account_Number__c, Cust_Current_Phone__c, OwnerId, Owner.Name, SCC_Nama_Pelapor__c FROM Case  WHERE Id = :caseId LIMIT 1];

        return recordCase;
    }

    //function untuk get all QA_Master__c data
    @AuraEnabled(cacheable=true)
    public static List<QA_Master__c> getCaseMasterData(String recordTypeName) {
        try{
            // Query the RecordType for the QA_Master__c object
            RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'QA_Master__c' AND IsActive = TRUE AND DeveloperName = :recordTypeName LIMIT 1];

            List<QA_Master__c> qaData = [SELECT Id, Name, Bobot__c, Section_Penilaian__c, Section__r.Name, Section__r.Bobot__c, RecordType.Name FROM QA_Master__c WHERE RecordTypeId = :rt.Id ORDER BY section__r.Name ASC];
            
            return qaData;
        }catch(Exception e){
            throw new AuraHandledException('Error Get Data ' + e.getMessage());
        }   
    }

    //function untuk get QA_Master_Item__c untuk picklist Finding
    @AuraEnabled(cacheable=true)
    public static List<QA_Master_Item__c> getPicklistOptions(String recordTypeName) {
        try {
            // Query the RecordType for the QA_Master__c object
            RecordType rt = [SELECT Id, name FROM RecordType WHERE SObjectType = 'QA_Master__c' AND DeveloperName = :recordTypeName LIMIT 1];

            List<QA_Master_Item__c> picklistData = [SELECT Id, Name, Aspek_Penilaian__r.Name FROM QA_Master_Item__c WHERE Record_Type__c = :rt.name];
            system.debug('ini hasil query: '+ picklistData);
            return picklistData;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching picklist options: ' + e.getMessage());
        }
    }

    //Function untuk create Records QA Response
    @AuraEnabled
    public static Id saveFormData(Map<String, String> formData) {
        try {
            // Cek apakah ID ada untuk menentukan insert atau update
            if (formData.containsKey('Id') && String.isNotBlank(formData.get('Id'))) {
                // Update Record
                QA_Response__c existingRecord = [SELECT Id FROM QA_Response__c WHERE Id = :formData.get('Id') LIMIT 1];
                
                existingRecord.Ext_Avaya_ID_Login__c = formData.get('extAvayaIdLogin');
                existingRecord.Durasi_Percakapan__c = formData.get('durasiPercakapan');
                existingRecord.Tanggal_Callmon__c = formData.containsKey('tanggalCallmon') ? Date.valueOf(formData.get('tanggalCallmon')) : null;
                existingRecord.Call_Type__c = formData.get('calltype');
                existingRecord.Perihal__c = formData.get('perihal');
                existingRecord.Nama_QA__c = formData.get('namaQA');
                existingRecord.Inisial_Agent__c = formData.get('inisialAgent');
                existingRecord.Channel__c = formData.get('channel');
                existingRecord.Tanggal_Interaksi__c = formData.containsKey('tanggalInteraksi') ? Date.valueOf(formData.get('tanggalInteraksi')) : null;
                existingRecord.Respon_Jawab__c = formData.get('responJawab');
                existingRecord.Nama_Agent__c = formData.get('namaAgent');
                existingRecord.Agent_Lookup__c = formData.get('AgentId');
                existingRecord.Waktu_Interaksi__c = formData.get('waktuInteraksi');
                existingRecord.Kategori_Penilaian__c = formData.get('kategoriPenilaian');
                // existingRecord.Sub_Kategori_Penilaian__c = formData.get('subKategoriPenilaian');
                existingRecord.Sanggahan__c = formData.get('sanggahanFlag') != null && formData.get('sanggahanFlag').toLowerCase() == 'true';
                // convert String to Integer
                existingRecord.Total_Critical_Error__c = formData.containsKey('totalCriticalError') && String.isNotBlank((String)formData.get('totalCriticalError'))
                    ? Integer.valueOf((String) formData.get('totalCriticalError')) 
                    : 0;

                existingRecord.Total_Non_Critical_Error__c = formData.containsKey('totalNonCriticalError') && String.isNotBlank((String)formData.get('totalNonCriticalError'))
                    ? Integer.valueOf((String) formData.get('totalNonCriticalError')) 
                    : 0;

                existingRecord.Total_Sikap_Melayani__c = formData.containsKey('totalPenilaian') && String.isNotBlank((String)formData.get('totalPenilaian'))
                    ? Integer.valueOf((String) formData.get('totalPenilaian')) 
                    : 0;

                existingRecord.Total_0_Critical_Error__c = formData.containsKey('countCriticalZero') && String.isNotBlank((String)formData.get('countCriticalZero'))
                    ? Decimal.valueOf((String) formData.get('countCriticalZero')) 
                    : 0.0;

                existingRecord.Total_0_Non_Critical_Error__c = formData.containsKey('countNonCriticalZero') && String.isNotBlank((String)formData.get('countNonCriticalZero'))
                    ? Decimal.valueOf((String) formData.get('countNonCriticalZero')) 
                    : 0.0;
                //For Sanggahan    
                existingRecord.Sanggahan_Total_Critical_Error__c = formData.containsKey('totalCriticalErrorSanggahan') && String.isNotBlank((String)formData.get('totalCriticalErrorSanggahan'))
                    ? Integer.valueOf((String) formData.get('totalCriticalErrorSanggahan')) 
                    : 0;

                existingRecord.Sanggahan_Total_Non_Critical_Error__c = formData.containsKey('totalNonCriticalErrorSanggahan') && String.isNotBlank((String)formData.get('totalNonCriticalErrorSanggahan'))
                    ? Integer.valueOf((String) formData.get('totalNonCriticalErrorSanggahan')) 
                    : 0;

                existingRecord.Sanggahan_Total_Keseluruhan_Penilaian__c = formData.containsKey('totalPenilaianSanggahan') && String.isNotBlank((String)formData.get('totalPenilaianSanggahan'))
                    ? Integer.valueOf((String) formData.get('totalPenilaianSanggahan')) 
                    : 0;

                existingRecord.Sanggahan_Total_0_Critical_Error__c = formData.containsKey('countCriticalErrorSanggahan') && String.isNotBlank((String)formData.get('countCriticalErrorSanggahan'))
                    ? Decimal.valueOf((String) formData.get('countCriticalErrorSanggahan')) 
                    : 0.0;

                existingRecord.Sanggahan_Total_0_Non_Critical_Error__c = formData.containsKey('countNonCriticalErrorSanggahan') && String.isNotBlank((String)formData.get('countNonCriticalErrorSanggahan'))
                    ? Decimal.valueOf((String) formData.get('countNonCriticalErrorSanggahan')) 
                    : 0.0;


                update existingRecord;
                return existingRecord.Id;

            } else {
                // Insert Record
                QA_Response__c newRecord = new QA_Response__c();
                newRecord.No_Tiket_New__c = formData.get('noTiketBricare');
                newRecord.Nama_Nasabah__c = formData.get('namaNasabah');
                newRecord.Nomor_Kartu__c = formData.get('nomorKartu');
                newRecord.Nomor_Rekening__c = formData.get('nomorRekening');
                newRecord.Nomor_Ponsel_Telepon__c = formData.get('nomorPonsel');
                newRecord.Ext_Avaya_ID_Login__c = formData.get('extAvayaIdLogin');
                newRecord.Durasi_Percakapan__c = formData.get('durasiPercakapan');
                newRecord.Tanggal_Callmon__c = formData.containsKey('tanggalCallmon') ? Date.valueOf(formData.get('tanggalCallmon')) : null;
                newRecord.Call_Type__c = formData.get('calltype');
                newRecord.Perihal__c = formData.get('perihal');
                newRecord.Nama_QA__c = formData.get('namaQA');
                newRecord.Inisial_Agent__c = formData.get('inisialAgent');
                newRecord.Channel__c = formData.get('channel');
                newRecord.Tanggal_Interaksi__c = formData.containsKey('tanggalInteraksi') ? Date.valueOf(formData.get('tanggalInteraksi')) : null;
                newRecord.Respon_Jawab__c = formData.get('responJawab');
                newRecord.Agent_Lookup__c = formData.get('AgentId');
                newRecord.Nama_Agent__c = formData.get('namaAgent');
                newRecord.Waktu_Interaksi__c = formData.get('waktuInteraksi');
                newRecord.Kategori_Penilaian__c = formData.get('kategoriPenilaian');
                newrecord.Sub_Kategori_Penilaian__c = formData.get('subKategoriPenilaian');
                newRecord.isDirect_Penilaian_QA__c = Boolean.valueOf(formData.get('isDirect_Penilaian_QA__c'));
                // Safely convert String to Integer for Total_Critical_Error__c
                newRecord.Total_Critical_Error__c = Integer.valueOf(formData.get('totalCriticalError'));
                newRecord.Total_Non_Critical_Error__c = Integer.valueOf(formData.get('totalNonCriticalError'));
                newRecord.Total_Sikap_Melayani__c = Integer.valueOf(formData.get('totalPenilaian'));
                newRecord.Total_0_Critical_Error__c = Decimal.valueOf(formData.get('countCriticalZero'));
                newRecord.Total_0_Non_Critical_Error__c = Decimal.valueOf(formData.get('countNonCriticalZero'));

                insert newRecord;
                return newRecord.Id;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error saat menyimpan atau memperbarui data: ' + e.getMessage());
        }
    }


    // Method to receive data from LWC and creation records QA_Response_Item__c
    @AuraEnabled
    public static void saveQAResponseItems(List<QA_Response_Item__c> records) {
        List<QA_Response_Item__c> recordsToInsert = new List<QA_Response_Item__c>();
        List<QA_Response_Item__c> recordsToUpdate = new List<QA_Response_Item__c>();

        try {
            for (QA_Response_Item__c record : records) {
                if (record.Id != null) {
                    // Record memiliki ID -> Update
                    recordsToUpdate.add(record);
                } else {
                    // Record tidak memiliki ID -> Insert
                    recordsToInsert.add(record);
                }
            }

            // Insert jika ada record baru
            if (!recordsToInsert.isEmpty()) {
                system.debug('Insert QA Response Items');
                insert recordsToInsert;
            }

            // Update jika ada record yang sudah ada
            if (!recordsToUpdate.isEmpty()) {
                system.debug('Update QA Response Items');
                update recordsToUpdate;
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error saat menyimpan atau memperbarui QA Response Items: ' + e.getMessage());
        }
    }


    public class InsertQAResponseQueueable implements Queueable {
        private List<QA_Response_Item__c> records;

        public InsertQAResponseQueueable(List<QA_Response_Item__c> recordsToInsert) {
            this.records = recordsToInsert;
        }

        public void execute(QueueableContext context) {
        	insert records;
        }
    }

    @AuraEnabled
    public static void enqueueRecords(List<QA_Response_Item__c> records) {
        if (records == null || records.isEmpty()) {
            return;
        }
        System.enqueueJob(new InsertQAResponseQueueable(records));
    }

    //function untuk get QA Response record
    @AuraEnabled(cacheable=true)
    public static List<QA_Response__c> getQAResponse(Id RecordId) {
        List<QA_Response__c> qaResponse = [SELECT Id, Name, No_Tiket_New__c, Ext_Avaya_ID_Login__c, Durasi_Percakapan__c, Tanggal_Callmon__c, Call_Type__c, Perihal__c, Nama_QA__c, Inisial_Agent__c, 
                                                  Tanggal_Interaksi__c, Channel__c, Respon_Jawab__c, Nama_Agent__c, Waktu_Interaksi__c, Kategori_Penilaian__c, Sub_Kategori_Penilaian__c, Total_Critical_Error__c,
                                                  Total_Non_Critical_Error__c, Total_Sikap_Melayani__c, Total_0_Non_Critical_Error__c, Total_0_Critical_Error__c, Nama_Nasabah_New__c, 
                                                  Nomor_Kartu_New__c, Nomor_Rekening_New__c, Nomor_Ponsel_Telepon_New__c, Agent_Lookup__c, Nama_Nasabah__c, Nomor_Kartu__c, Nomor_Rekening__c, Nomor_Ponsel_Telepon__c
                                           FROM QA_Response__c WHERE Id=:RecordId];

        Return qaResponse;
    }

    //get QA Response Item
    @AuraEnabled(cacheable=true)
    public static List<QA_Response_Item__c> qaResponseItems(Id RecordId){
        List<QA_Response_Item__c> qaResponseItems = [SELECT Id, Name, Hasil__c, Master_QA__c,Keterangan_Penilaian_QA__c, Finding__c, Sanggahan_Finding__c, Sanggahan_Hasil__c, Sanggahan_Keterangan_Penilaian_QA__c
                                                     FROM QA_Response_Item__c WHERE Fitur_Penilaian_QA__c =:RecordId];
        Return qaResponseItems;
    }

    //Get User
    @AuraEnabled(cacheable=true)
    public static List<User> searchUsers(String searchKeyword) {
        if (String.isBlank(searchKeyword)) {
            return new List<User>();
        }
        return [SELECT Id, Name, EmployeeNumber FROM User WHERE Name LIKE :('%' + searchKeyword + '%') AND Profile.Name = 'Contact Center User' LIMIT 10];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean hasQAPermission() {
        String permissionSetName = 'Quality_Assuranse';
        System.debug('User ID: ' + UserInfo.getUserId());
        System.debug('Checking Permission Set: ' + permissionSetName);

        List<PermissionSetAssignment> psaList = [ 
            SELECT AssigneeId
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name = :permissionSetName
            LIMIT 1
        ];
        System.debug('Permission Set Assignment Result: ' + psaList);

        return !psaList.isEmpty();
    }

    @AuraEnabled(cacheable=true)
    public static List<FiturQAConfigWrapper> getFiturQAConfig() {
        List<FiturQAConfigWrapper> result = new List<FiturQAConfigWrapper>();

        for (Fitur_QA__mdt config : [
            SELECT QA_Master_Record_Type__c, Hidden_Fields__c, Is_Agent_Leader_View__c FROM Fitur_QA__mdt
        ]) {
            FiturQAConfigWrapper wrapper = new FiturQAConfigWrapper();
            wrapper.recordType = config.QA_Master_Record_Type__c;
            wrapper.hiddenFields = config.Hidden_Fields__c != null ? config.Hidden_Fields__c.replace(' ', '').split(',') : new List<String>();
            wrapper.showAgentLeaderView = config.Is_Agent_Leader_View__c;
            result.add(wrapper);
        }

        return result;
    }

    public class FiturQAConfigWrapper {
        @AuraEnabled public String recordType;
        @AuraEnabled public List<String> hiddenFields;
        @AuraEnabled public Boolean showAgentLeaderView;
    }

}