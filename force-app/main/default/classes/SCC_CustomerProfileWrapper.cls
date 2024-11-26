/**
 * @description SCC_CustomerProfileWrapper
 */
public class SCC_CustomerProfileWrapper {
    
    // List to hold Data objects representing customer data
    public List<Data> data;
    public Object errors;                             // Object to hold errors
    public String responseMessage;                    // Response message
    public String responseCode;                       // Response code
    public String errorCode;                          // Error code
    public Integer statusCode;                        // Status code
    
    /**
     * @description Nested class representing demographic details of a customer
     */
    public class Demografi {
        public Integer umur;                          // Age
        public String tipeNasabahDesc;                // Customer type description
        public String tipeNasabah;                    // Customer type
        public String tipeIdCorp;                     // Corporate ID type
        public String tempatPendirian;                // Place of establishment
        public String tempatLahir;                    // Place of birth
        public String teleponKantor;                  // Office phone number
        public String telepon3;                       // Additional phone number 3
        public String telepon2;                       // Additional phone number 2
        public String telepon1;                       // Additional phone number 1
        public String telepon;                        // Phone number
        public String tanggalTerbit;                  // Issue date
        public String tanggalLahir;                   // Birth date
        public String tanggalAktaPendirian;           // Establishment deed date
        public String statusPerkawinan;               // Marital status
        public String rwSesuaiID;                     // ID address RW
        public String rwKantor;                       // Office address RW
        public String rwDomisili;                     // Domicile address RW
        public String rtSesuaiID;                     // ID address RT
        public String rtKantor;                       // Office address RT
        public String rtDomisili;                     // Domicile address RT
        public String propinsiSesuaiID;               // ID address province
        public String propinsiKantor;                 // Office address province
        public String propinsiDomisili;               // Domicile address province
        public String pendidikanTerakhir;             // Last education
        public String nomorIdentitas;                 // Identity number
        public String noIdCorp;                       // Corporate ID number
        public String noAktaPendirian;                // Establishment deed number
        public String negara;                         // Country
        public String nasabahPrioritas;               // Priority customer
        public String namaTempatBekerja;              // Workplace name
        public String namaSesuaiIdentitas;            // Name as per identity
        public String namaGadisIbuKandung;            // Mother's maiden name
        public String nama3;                          // Additional name 3
        public String nama2;                          // Additional name 2
        public String nama1;                          // Additional name 1
        public String lastModifiedDate;               // Last modified date
        public String kotaSesuaiID;                   // ID address city
        public String kotaKantor;                     // Office address city
        public String kotaDomisili;                   // Domicile address city
        public String kodePosSesuaiID;                // ID address postal code
        public String kodePosKantor;                  // Office address postal code
        public String kodePosDomisili;                // Domicile address postal code
        public String kodeBidangUsaha;                // Business field code
        public String kewarganegaraan;                // Nationality
        public String keteranganAgama;                // Religion description
        public String kelurahanSesuaiID;              // ID address sub-district
        public String kelurahanKantor;                // Office address sub-district
        public String kelurahanDomisili;              // Domicile address sub-district
        public String kecamatanSesuaiID;              // ID address district
        public String kecamatanKantor;                // Office address district
        public String kecamatanDomisili;              // Domicile address district
        public String jenisPekerjaan;                 // Job type
        public String jenisKelamin;                   // Gender
        public String jenisIdentitas;                 // Identity type
        public String jabatan3;                       // Job position 3
        public String jabatan2;                       // Job position 2
        public String jabatan1;                       // Job position 1
        public String handphone;                      // Mobile phone number
        public String gelarSetelahNama;               // Title after name
        public String gelarSebelumNama;               // Title before name
        public String email3;                         // Additional email 3
        public String email2;                         // Additional email 2
        public String email1;                         // Additional email 1
        public String email;                          // Email address
        public String createdDate;                    // Creation date
        public String bidangUsaha;                    // Business field
        public String bidangPekerjaan;                // Job field
        public String alamatSuratMenyurat;            // Mailing address
        public String alamatSesuaiID2;                // ID address line 2
        public String alamatSesuaiID;                 // ID address line 1
        public String alamatKantor2;                  // Office address line 2
        public String alamatKantor;                   // Office address line 1
        public String alamatDomisili2;                // Domicile address line 2
        public String alamatDomisili;                 // Domicile address line 1
        public String PEP;                            // Politically Exposed Person (PEP) status
        public String NPWP;                           // Tax ID number
        public String prioritas;                      // Priority status
        public String alamatId1;                      // Additional ID address 1
        public String alamatId2;                      // Additional ID address 2
        public String alamatId3;                      // Additional ID address 3
        public String alamatId4;                      // Additional ID address 4
    }

    /**
     * @description Nested class representing a customer's banking portfolio
     */ 
    public class PortofolioPerbankan {
        public List<Simpanan> simpanan;               // List of savings accounts
        public List<Simpanan> pinjaman;               // List of loans
        public List<Simpanan> investasi;              // List of investments
        public List<Simpanan> cardlink;               // List of card links
    }

    

    /** 
     * @description Nested class representing data including demographic and banking portfolio
     */
     public class Data {
        public PortofolioPerbankan portofolioPerbankan;  // Customer banking portfolio
        public Demografi demografi;                      // Customer demographics
        public String cifno;                             // Customer Information File number
    }

    /** 
     * @description Placeholder class for Simpanan (to be detailed later)
     */
    public class Simpanan {
        public String status;
        public String cifno;
        public String productType;
        public String productDescription;
        public String product;
        public String balance;
        public String accountNumber;
        public String openAccountDate;
    }

    /**
     * @description Parses a JSON string and returns an instance of SCC_CustomerProfileWrapper.
     *
     * @param json The JSON string to parse.
     * @return An instance of SCC_CustomerProfileWrapper, or null if the JSON is invalid.
     */
    public static SCC_CustomerProfileWrapper parse(String json) {
        if (json == null) {
            return null;  // Return null if the input JSON string is null
        }

        try {
            // Deserialize the JSON string into an SCC_CustomerProfileWrapper object
            return (SCC_CustomerProfileWrapper) System.JSON.deserialize(json, SCC_CustomerProfileWrapper.class);
        } catch (JSONException e) {
            // Handle any JSON parsing exceptions here
            return null;  // Return null in case of a JSON parsing error
        }
    }
}