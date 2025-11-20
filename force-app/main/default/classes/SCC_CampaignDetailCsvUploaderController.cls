/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 08-13-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SCC_CampaignDetailCsvUploaderController {
    private static final Map<String, String> FIELD_MAPPINGS = new Map<String, String>{
        // Customer Name variations
        'customer name' => 'Customer_Name__c',
        'nama nasabah' => 'Customer_Name__c',
        'nama' => 'Customer_Name__c',
        'nama_lengkap' => 'Customer_Name__c',
        'name brimo' => 'Customer_Name__c',
        'name' => 'Customer_Name__c',
        'customer' => 'Customer_Name__c',

        // Phone variations
        'phone' => 'Phone__c',
        'cellphone brimo' => 'Phone__c',
        'phone 1' => 'Phone__c',
         'phone_1' => 'Phone__c',

        // Address variations
        'alamat__c' => 'Alamat__c',
        'alamat merchant' => 'Alamat_Merchant__c',
        'alamat_merchant' => 'Alamat_Merchant__c',
        'alamat domisili' => 'Alamat_Domisili__c',
        
        // CIF variations
        'cif' => 'CIF__c',
        'cif_no' => 'CIF__c',
        'cif brimo' => 'CIF__c',
        'cif_brinets' => 'CIF_BRINETS__c',
        'cif brinets' => 'CIF_BRINETS__c',
        
        // Standard fields
        'dial_phone_no' => 'Dial_Phone_No__c',
        'note' => 'Note__c',
        'outbound_category' => 'Outbound_Category__c',
        'outbound_category_detail' => 'Outbound_Category_Detail__c',
        'status' => 'Status__c',
        'ktp' => 'KTP__c',
        'case_number__c' => 'Case_Number__c',
        'compare' => 'Compare__c',
        'device id' => 'Device_ID__c',
        'dukcapil' => 'Dukcapil__c',
        
        // Email variations
        'email' => 'Email__c',
        
        // Card related fields
        'jenis kartu' => 'Jenis_Kartu__c',
        'nomor cc' => 'Nomor_CC__c',
        'nomor kartu' => 'Nomor_Kartu__c',
        'card number' => 'Nomor_Kartu__c',
        
        // Location related
        'kabupaten' => 'Kabupaten__c',
        'kecamatan' => 'Kecamatan__c',
        'kelurahan' => 'Kelurahan__c',
        'provinsi' => 'Provinsi__c',
        
        // Office related
        'nama kantor cabang' => 'Kantor_Cabang__c',
        'kantor_cabang' => 'Kantor_Cabang__c',
        'kode_kanca' => 'Kode_Kanca__c',
        'kode_uker' => 'Kode_Uker__c',
        'nama_kanca' => 'Nama_Kanca__c',
        'nama_kanwil' => 'Nama_Kanwil__c',
        'kanwil' => 'Nama_Kanwil__c',
        'nama_uker' => 'Nama_Uker__c',
        
        // Merchant related
        'nama_merchant' => 'Nama_Merchant__c',
        'mid' => 'MID__c',
        'tid' => 'TID__c',
        'pic merchant' => 'pic_merchant__c',
        
        // Number fields (requiring decimal conversion)
        'nominal pengajuan' => 'Nominal_Pengajuan__c',
        'nominal transaksi pengajuan' => 'Nominal_Pengajuan__c',
        'outstanding' => 'Outstanding__c',
        'plafond' => 'Plafond__c',
        'sales_volume' => 'Sales_Volume__c',
        'sales volume' => 'Sales_Volume__c',
        'sisa fasilitas' => 'Sisa_Fasilitas__c',
        'baki debet' => 'Baki_Debet__c',
        
        // Date fields
        'tanggal pengajuan' => 'Tanggal_Pengajuan__c',
        'tanggal_register__c' => 'Tanggal_Register__c',
        'tanggal register brimo' => 'Tanggal_Register__c',
        'trx date' => 'TRX_Date__c',
        
        // Report and Response fields
        'nomor laporan' => 'Nomor_Laporan__c',
        'nomor_laporan' => 'Nomor_Laporan__c',
        'response code' => 'Response_Code__c',
        'response_desc' => 'Response_Desc__c',
        
        // Status and Solutions
        'status_transaksi__c' => 'Status_Transaksi__c',
        'status transaksi' => 'Status_Transaksi__c',
        'solution__c' => 'Solution__c',
        'solution' => 'Solution__c',
        
        // Account and Program fields
        'account number' => 'ACCOUNT_NUMBER__c',
        'rek rdn' => 'Rekening_RDN__c',
        'rek tabungan bri (terdaftar di sekuritas)' => 'Rekening_Tabungan__c',
        'program_atau_promo__c' => 'Program_Atau_Promo__c',
        'program atau promo untuk customer' => 'Program_atau_Promo_untuk_Customer__c',
        'program atau promo untuk merchant' => 'Program_atau_Promo_untuk_Merchant__c',
        
        // Additional fields
        'name_brinets' => 'NAME_BRINETS__c',
        'name brinets' => 'NAME_BRINETS__c',
        'userid' => 'userId__c',
        'created' => 'created__c',
        'nik' => 'NIK__c',
        'status privy' => 'Status_Privy__c',
        'ket_mcc' => 'KET_MCC__c',
        'nomor trouble tiket bricare (pengaduan)' => 'Nomor_Trouble_Tiket_Bricare_Pengaduan__c',
        'tiering_sv' => 'Tiering_SV__c',
        'tiering sv' => 'Tiering_SV__c',
        'nomor' => 'Nomor__c',
        'pn_user_pemrakarsa' => 'PN_USER_PEMRAKARSA__c',
        'nama_user_pemrakarsa' => 'NAMA_USER_PEMRAKARSA__c',
        'deskripsi' => 'Deskripsi__c',
        'tindaklanjut rm' => 'Tindaklanjut_RM__c',
        'face' => 'Face__c',
        'jenis' => 'Jenis__c',
        'karakter nasabah' => 'Karakter_Nasabah__c',
        'liveness' => 'Liveness__c',
        'reason' => 'Reason__c',
        'sid' => 'SID__c',
        'home address' => 'Home_Address__c',
        'home city' => 'Home_City__c',
        'office address' => 'Office_Address__c',
        'rekom rate / bulan' => 'Rekom_Rate_Bulan__c',
        'rekom tenor max' => 'Rekom_Tenor_Max__c',
        'rekom plafon max' => 'Rekom_Plafon_Max__c',
        'detail' => 'detail__c'
    };

    // Updated sets for special field handling
    private static final Set<String> NUMERIC_FIELDS = new Set<String>{
        'Nominal_Pengajuan__c'
        // 'Outstanding__c',
        // 'Plafond__c',
        // 'Sales_Volume__c',
        // 'Sisa_Fasilitas__c',
        // 'Baki_Debet__c'
    };

    private static final Set<String> DATE_FIELDS = new Set<String>{
        'Tanggal_Pengajuan__c',
        'Tanggal_Register__c',
        'TRX_Date__c'
    };

    @AuraEnabled    
    public static void uploadCsvFile(String csvContent, Id campaignId) {    
        try {    
            List<Campaign_Detail__c> campaignDetails = new List<Campaign_Detail__c>();    
            List<String> rows = csvContent.split('\n');    
            
            if (rows.isEmpty()) return;
            
            Map<String, Integer> headerMap = createHeaderMap(rows[0].split(';'));
            
            for (Integer i = 1; i < rows.size(); i++) {
                if (String.isNotBlank(rows[i])) {
                    Campaign_Detail__c detail = processCsvRow(rows[i], headerMap, campaignId);
                    if (detail != null) {
                        campaignDetails.add(detail);
                    }
                }
            }
            
            if (!campaignDetails.isEmpty()) {
                insert campaignDetails;
            }
        } catch (Exception e) {    
            throw new AuraHandledException('Error processing CSV file: ' + e.getMessage());    
        }    
    }

    private static Map<String, Integer> createHeaderMap(List<String> headers) {
        Map<String, Integer> headerMap = new Map<String, Integer>();
        for (Integer i = 0; i < headers.size(); i++) {
            headerMap.put(headers[i].trim().toLowerCase(), i);
        }
        return headerMap;
    }

    private static Campaign_Detail__c processCsvRow(String row, Map<String, Integer> headerMap, Id campaignId) {
        List<String> columns = row.split(';');
        if (columns.size() < 1) return null;

        Campaign_Detail__c detail = new Campaign_Detail__c(Campaign__c = campaignId);
        
        for (String headerKey : headerMap.keySet()) {
            Integer columnIndex = headerMap.get(headerKey);
            if (columnIndex >= columns.size()) continue;
            
            String value = columns[columnIndex].trim();
            if (String.isBlank(value)) continue;
            
            // Get the corresponding field API name
            String fieldName = FIELD_MAPPINGS.get(headerKey);
            if (fieldName == null) continue;
            
            try {
                if (NUMERIC_FIELDS.contains(fieldName)) {
                    detail.put(fieldName, Decimal.valueOf(value));
                } else if (DATE_FIELDS.contains(fieldName)) {
                    detail.put(fieldName, Date.valueOf(value));
                } else {
                    detail.put(fieldName, value);
                }
            } catch (Exception e) {
                System.debug('Error processing field ' + fieldName + ': ' + e.getMessage());
            }
        }
        
        return detail;
    }

    @AuraEnabled
    public static String downloadTemplate(String templateName) {
        try {
            StaticResource template = [SELECT Id, Body FROM StaticResource 
                                    WHERE Name = :templateName LIMIT 1];
            return template.Body.toString();
        } catch (Exception e) {
            throw new AuraHandledException('Error downloading template: ' + e.getMessage());
        }
    }
}