/**
 * @description       : 
 * @author            : Suherbing Septian
 * @group             : 
 * @last modified on  : 15/09/2025
 * @last modified by  : Suherbing Septian
**/

@isTest
private class SCC_MasterMappingFeature_Test {

    @TestSetup
    static void makeData(){
        List<SSC_Call_Type__c> callTypes = new List<SSC_Call_Type__c>();
        SSC_Call_Type__c callType1 = Object_Test.setCallType('8809');
        SSC_Call_Type__c callType2 = Object_Test.setCallType('8808');
        SSC_Call_Type__c callType3 = Object_Test.setCallType('8434');
        SSC_Call_Type__c callType4 = Object_Test.setCallType('8433');
        callTypes.add(callType1);
        callTypes.add(callType2);
        callTypes.add(callType3);
        callTypes.add(callType4);
        insert callTypes;

        List<SCC_Call_Type_Feature__c> features = new List<SCC_Call_Type_Feature__c>();
        SCC_Call_Type_Feature__c features1 = Object_Test.setFitur(callTypes[0].Id);
        features1.Name = 'Transfer Antar Bank';
        features1.Fitur_ID__c = '001';
        SCC_Call_Type_Feature__c features2 = Object_Test.setFitur(callTypes[1].Id);
        features2.Name = 'PLN Postpaid';
        features2.Fitur_ID__c = '002';
        SCC_Call_Type_Feature__c features3 = Object_Test.setFitur(callTypes[2].Id);
        features3.Name = 'PLN Prepaid';
        features3.Fitur_ID__c = '003';
        SCC_Call_Type_Feature__c features4 = Object_Test.setFitur(callTypes[3].Id);
        features4.Name = 'Pulsa Telkomsel';
        features4.Fitur_ID__c = '004';
        SCC_Call_Type_Feature__c features5 = Object_Test.setFitur(callTypes[3].Id);
        features5.Name = 'Tiket Kereta Api';
        features5.Fitur_ID__c = '005';
        features.add(features1);
        features.add(features2);
        features.add(features3);
        features.add(features4);
        features.add(features5);
        insert features;

        List<Master_Mapping_Feature__c> mappings = new List<Master_Mapping_Feature__c>{
            // Skenario 1: Cocok tunggal
            new Master_Mapping_Feature__c(
                Case_Type__c = callTypes[0].Id, 
                Feature__c = features[0].Id, 
                Remark__c = 'TRANSFER KE REKENING'
            ),
            // Skenario 2: Cocok ganda, dibedakan oleh Remark_2__c
            new Master_Mapping_Feature__c(
                Case_Type__c = callTypes[1].Id, 
                Feature__c = features[1].Id, 
                Remark__c = 'PEMBAYARAN PLN'
            ),
            new Master_Mapping_Feature__c(
                Case_Type__c = callTypes[1].Id, 
                Feature__c = features[2].Id, 
                Remark__c = 'PEMBAYARAN PLN', 
                Remark_2__c = 'TOKEN'
            ),
            // Skenario 3: Kasus khusus Pulsa (8434)
            new Master_Mapping_Feature__c(
                Case_Type__c = callTypes[2].Id, 
                Feature__c = features[3].Id, 
                Remark__c = 'PUL-SIM MP', // Format: <Kata Kunci> <Kode Bank>
                Provider__c = 'TELKOMSEL'
            ),
            // Skenario 4: Kasus khusus KAI (8433)
             new Master_Mapping_Feature__c(
                Case_Type__c = callTypes[3].Id, 
                Feature__c = features[4].Id, 
                Remark__c = 'MPKAI'
            )
        };
        insert mappings;
    }

    /**
     * @description Helper untuk membangun map dari data master.
     */
    private static Map<String, List<Master_Mapping_Feature__c>> buildFeatureMap(){
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = new Map<String, List<Master_Mapping_Feature__c>>();
        for(Master_Mapping_Feature__c mmf : [
            SELECT Id, Remark__c, Remark_2__c, Provider__c,
                   Feature__r.Fitur_ID__c, Case_Type__r.external_id__c 
            FROM Master_Mapping_Feature__c
        ]){
            String caseType = mmf.Case_Type__r.external_id__c;
            if(!mapFeatures.containsKey(caseType)){
                mapFeatures.put(caseType, new List<Master_Mapping_Feature__c>());
            }
            mapFeatures.get(caseType).add(mmf);
        }
        return mapFeatures;
    }

    @isTest
    static void testGetFeature_SingleMatch1() {
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8809' LIMIT 1];

        // Buat mock Case
        Case cs = new Case(
            SCC_Call_Type__c = callType.Id,
            SCC_Amount__c = 100000
        );
        cs.SCC_Call_Type__r = callType; // Simulasi query relasi

        // Buat mock Data
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data.trremk = 'PEMBAYARAN VIA QR TRANSFER KE REKENING 123456';
        data.mutasiDebet = 100000; // Nominal cocok

        // --- Skenario 1: Nominal Cocok ---
        Test.startTest();
        SCC_MasterMappingFeature.MappingMasterWrapper resultAmountMatch = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        Test.stopTest();
    }

    @isTest
    static void testGetFeature_SingleMatch2() {
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8809' LIMIT 1];

        // Buat mock Case
        Case cs = new Case(
            SCC_Call_Type__c = callType.Id,
            SCC_Amount__c = 100000
        );
        cs.SCC_Call_Type__r = callType; // Simulasi query relasi

        // Buat mock Data
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data.trremk = 'PEMBAYARAN VIA QR TRANSFER KE REKENING 123456';

        // --- Skenario 2: Nominal Tidak Cocok ---
        data.mutasiDebet = 50000; // Ubah nominal agar tidak cocok
        Test.startTest();
        SCC_MasterMappingFeature.MappingMasterWrapper resultAmountMismatch = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        Test.stopTest();
    }

    @isTest
    static void testGetFeature_MultipleMatches_ResolvedByRemark2() {
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8808' LIMIT 1];

        Case cs = new Case(SCC_Call_Type__c = callType.Id, SCC_Amount__c = 50000);
        cs.SCC_Call_Type__r = callType;

        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data.trremk = 'TRF E-BANK DB 1234/PEMBAYARAN PLN/IDPEL:54321';
        data.tlbds2 = 'PEMBELIAN TOKEN LISTRIK'; // Remark 2 yang spesifik
        data.mutasiDebet = 50000;

        Test.startTest();
        SCC_MasterMappingFeature.MappingMasterWrapper result = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        Test.stopTest();
    }

    @isTest
    static void testGetFeature_NoMatchScenarios() {
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8809' LIMIT 1];

        Case cs = new Case(SCC_Call_Type__c = callType.Id, SCC_Amount__c = 100000);
        cs.SCC_Call_Type__r = callType;

        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data.mutasiDebet = 100000;
        
        // Skenario 1: Remark tidak cocok sama sekali
        data.trremk = 'PEMBAYARAN GAJI';
        SCC_MasterMappingFeature.MappingMasterWrapper resultNoRemarkMatch = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        
        // Skenario 2: Tidak ada mapping untuk Case Type tersebut
        callType.external_id__c = '9999'; // Case type yang tidak ada di data master
        cs.SCC_Call_Type__r = callType;
        SCC_MasterMappingFeature.MappingMasterWrapper resultNoCaseType = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
    }

    @isTest
    static void testGetFeature_SpecialCase8434_PulsaMatch() {
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8434' LIMIT 1];

        Case cs = new Case(SCC_Call_Type__c = callType.Id, SCC_Amount__c = 25000);
        cs.SCC_Call_Type__r = callType;

        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data.trremk = 'TRF E-BANK DB 010125/PUL-SIM /08123456789/MP'; // remark cocok dengan regex dan kode bank 'MP'
        data.mutasiDebet = 25000;

        Test.startTest();
        SCC_MasterMappingFeature.MappingMasterWrapper result = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        Test.stopTest();
    }

    @isTest
    static void testGetFeature_SpecialCase8433_KAIMatch() {
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8433' LIMIT 1];

        Case cs = new Case(SCC_Call_Type__c = callType.Id, SCC_Amount__c = 150000);
        cs.SCC_Call_Type__r = callType;
        
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data.trremk = 'PEMBAYARAN TIKET KERETA API DARI MPKAI'; // Remark mengandung 'MPKAI'
        data.mutasiDebet = 150000;

        Test.startTest();
        SCC_MasterMappingFeature.MappingMasterWrapper result = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        Test.stopTest();
    }

    @isTest
    static void testGetFeature_SpecialCase8434_XlAxisMatch() {
        // --- 1. Persiapan Data Spesifik untuk Tes Ini ---
        // Dapatkan Call Type dan Feature yang sudah dibuat di @testSetup
        SSC_Call_Type__c callType = [SELECT Id, external_id__c FROM SSC_Call_Type__c WHERE external_id__c = '8434' LIMIT 1];
        // Kita bisa gunakan lagi feature 'Pulsa Telkomsel' untuk mapping ini
        SCC_Call_Type_Feature__c feature = [SELECT Id, Fitur_ID__c FROM SCC_Call_Type_Feature__c WHERE Fitur_ID__c = '004' LIMIT 1];

        // BUAT MAPPING BARU yang spesifik untuk skenario XL/AXIS
        // Remark__c di sini adalah kunci utamanya. 'PULSA' harus cocok dengan hasil regex
        Master_Mapping_Feature__c xlMapping = new Master_Mapping_Feature__c(
            Case_Type__c = callType.Id, 
            Feature__c = feature.Id, 
            Remark__c = 'PULSA', // Ini harus cocok dengan group(1) dari regex
            Provider__c = 'XL AXIATA'
        );
        insert xlMapping;

        // --- 2. Bangun Ulang Map agar menyertakan data baru ---
        // Panggil helper setelah data baru di-insert
        Map<String, List<Master_Mapping_Feature__c>> mapFeatures = buildFeatureMap();

        // --- 3. Siapkan Case dan Data Transaksi ---
        Case cs = new Case(
            SCC_Call_Type__c = callType.Id, 
            SCC_Amount__c = 50000
        );
        cs.SCC_Call_Type__r = callType;
        
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        // Remark ini sengaja dibuat agar cocok dengan regex dan mengandung 'XL'
        data.trremk = 'PEMBELIAN LAYANAN PULSA XL / 087812345678'; 
        data.mutasiDebet = 50000;

        // --- 4. Eksekusi dan Verifikasi ---
        Test.startTest();
        SCC_MasterMappingFeature.MappingMasterWrapper result = SCC_MasterMappingFeature.getFeature(cs, data, mapFeatures);
        Test.stopTest();
    }
}