public without sharing class SCC_CustomerVerificationWrapper {
    public SCC_CustomerVerificationWrapper() {

    }
    public class Demografi {  
       @AuraEnabled  public Integer umur;                          // Age
       @AuraEnabled  public String tipeNasabahDesc;                // Customer type description
       @AuraEnabled  public String tipeNasabah;                    // Customer type
       @AuraEnabled  public String tipeIdCorp;                     // Corporate ID type
       @AuraEnabled  public String tempatPendirian;                // Place of establishment
       @AuraEnabled  public String tempatLahir;                    // Place of birth
       @AuraEnabled  public String teleponKantor;                  // Office phone number
       @AuraEnabled  public String telepon3;                       // Additional phone number 3
       @AuraEnabled  public String telepon2;                       // Additional phone number 2
       @AuraEnabled  public String telepon1;                       // Additional phone number 1
       @AuraEnabled  public String telepon;                        // Phone number
       @AuraEnabled  public String tanggalTerbit;                  // Issue date
       @AuraEnabled  public String tanggalLahir;                   // Birth date
       @AuraEnabled  public String tanggalAktaPendirian;           // Establishment deed date
       @AuraEnabled  public String statusPerkawinan;               // Marital status
       @AuraEnabled  public String rwSesuaiID;                     // ID address RW
       @AuraEnabled  public String rwKantor;                       // Office address RW
       @AuraEnabled  public String rwDomisili;                     // Domicile address RW
       @AuraEnabled  public String rtSesuaiID;                     // ID address RT
       @AuraEnabled  public String rtKantor;                       // Office address RT
       @AuraEnabled  public String rtDomisili;                     // Domicile address RT
       @AuraEnabled  public String propinsiSesuaiID;               // ID address province
       @AuraEnabled  public String propinsiKantor;                 // Office address province
       @AuraEnabled  public String propinsiDomisili;               // Domicile address province
       @AuraEnabled  public String pendidikanTerakhir;             // Last education
       @AuraEnabled  public String nomorIdentitas;                 // Identity number
       @AuraEnabled  public String noIdCorp;                       // Corporate ID number
       @AuraEnabled  public String noAktaPendirian;                // Establishment deed number
       @AuraEnabled  public String negara;                         // Country
       @AuraEnabled  public String nasabahPrioritas;               // Priority customer
       @AuraEnabled  public String namaTempatBekerja;              // Workplace name
       @AuraEnabled  public String namaSesuaiIdentitas;            // Name as per identity
       @AuraEnabled  public String namaGadisIbuKandung;            // Mother's maiden name
       @AuraEnabled  public String nama3;                          // Additional name 3
       @AuraEnabled  public String nama2;                          // Additional name 2
       @AuraEnabled  public String nama1;                          // Additional name 1
       @AuraEnabled  public String lastModifiedDate;               // Last modified date
       @AuraEnabled  public String kotaSesuaiID;                   // ID address city
       @AuraEnabled  public String kotaKantor;                     // Office address city
       @AuraEnabled  public String kotaDomisili;                   // Domicile address city
       @AuraEnabled  public String kodePosSesuaiID;                // ID address postal code
       @AuraEnabled  public String kodePosKantor;                  // Office address postal code
       @AuraEnabled  public String kodePosDomisili;                // Domicile address postal code
       @AuraEnabled  public String kodeBidangUsaha;                // Business field code
       @AuraEnabled  public String kewarganegaraan;                // Nationality
       @AuraEnabled  public String keteranganAgama;                // Religion description
       @AuraEnabled  public String kelurahanSesuaiID;              // ID address sub-district
       @AuraEnabled  public String kelurahanKantor;                // Office address sub-district
       @AuraEnabled  public String kelurahanDomisili;              // Domicile address sub-district
       @AuraEnabled  public String kecamatanSesuaiID;              // ID address district
       @AuraEnabled  public String kecamatanKantor;                // Office address district
       @AuraEnabled  public String kecamatanDomisili;              // Domicile address district
       @AuraEnabled  public String jenisPekerjaan;                 // Job type
       @AuraEnabled  public String jenisKelamin;                   // Gender
       @AuraEnabled  public String jenisIdentitas;                 // Identity type
       @AuraEnabled  public String jabatan3;                       // Job position 3
       @AuraEnabled  public String jabatan2;                       // Job position 2
       @AuraEnabled  public String jabatan1;                       // Job position 1
       @AuraEnabled  public String handphone;                      // Mobile phone number
       @AuraEnabled  public String gelarSetelahNama;               // Title after name
       @AuraEnabled  public String gelarSebelumNama;               // Title before name
       @AuraEnabled  public String email3;                         // Additional email 3
       @AuraEnabled  public String email2;                         // Additional email 2
       @AuraEnabled  public String email1;                         // Additional email 1
       @AuraEnabled  public String email;                          // Email address
       @AuraEnabled  public String createdDate;                    // Creation date
       @AuraEnabled  public String bidangUsaha;                    // Business field
       @AuraEnabled  public String bidangPekerjaan;                // Job field
       @AuraEnabled  public String alamatSuratMenyurat;            // Mailing address
       @AuraEnabled  public String alamatSesuaiID2;                // ID address line 2
       @AuraEnabled  public String alamatSesuaiID;                 // ID address line 1
       @AuraEnabled  public String alamatKantor2;                  // Office address line 2
       @AuraEnabled  public String alamatKantor;                   // Office address line 1
       @AuraEnabled  public String alamatDomisili2;                // Domicile address line 2
       @AuraEnabled  public String alamatDomisili;                 // Domicile address line 1
       @AuraEnabled  public String PEP;                            // Politically Exposed Person (PEP) status
       @AuraEnabled  public String NPWP;                           // Tax ID number
       @AuraEnabled  public String prioritas;                      // Priority status
       @AuraEnabled  public String alamatId1;                      // Additional ID address 1
       @AuraEnabled  public String alamatId2;                      // Additional ID address 2
       @AuraEnabled  public String alamatId3;                      // Additional ID address 3
       @AuraEnabled  public String alamatId4;                      // Additional ID address 4     
    }
     
    public class PortofolioPerbankan {
        @AuraEnabled
        public List<Simpanan> simpanan;
        @AuraEnabled
        public List<Pinjaman> pinjaman;
        @AuraEnabled
        public List<Investasi> investasi;
        @AuraEnabled
        public List<Cardlink> cardlink;
    }

    @AuraEnabled
    public List<Data> data;
    @AuraEnabled
    public Object errors;
    @AuraEnabled
    public String responseMessage;
    @AuraEnabled
    public String responseCode;
    @AuraEnabled
    public String errorCode;
    @AuraEnabled
    public Integer statusCode;

   
    public class Data {
        @AuraEnabled
        public PortofolioPerbankan portofolioPerbankan;
        @AuraEnabled
        public Demografi demografi;
        @AuraEnabled
        public String cifno;
    }

    
    public class Pinjaman {
         
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public String accountNumber; 
    }

    
    public class Simpanan {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public String accountNumber; 
    }

    
    public class Investasi {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public String accountNumber; 
    }

  
    public class Cardlink {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
    
        @AuraEnabled
        public String cardNumber; 
    }

    public static SCC_CustomerVerificationWrapper parse(String json) {
        if (json == null) {
        	return null;
    	}

        try{
            return (SCC_CustomerVerificationWrapper) System.JSON.deserialize(json, SCC_CustomerVerificationWrapper.class);
        }catch (JSONException e) {
            System.debug('Error parsing JSON: ' + e.getMessage());
            return null; 
    	} 
    }  
}