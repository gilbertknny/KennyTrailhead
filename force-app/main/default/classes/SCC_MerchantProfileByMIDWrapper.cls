/** @description
 * This class wraps merchant profile data by MID (Merchant Identification Number) 
 * and provides functionality to parse JSON into an instance of SCC_MerchantProfileByMIDWrapper.
 */
public without sharing class SCC_MerchantProfileByMIDWrapper {
    
    // List to hold MERCHANT_PROFILE objects representing merchant profiles
    @AuraEnabled
    public List<MERCHANT_PROFILE> MERCHANT_PROFILE;
    @AuraEnabled
    public String errorMessage;

    /** @description
     * Inner class representing the profile of a merchant.
     */
    public class MERCHANT_PROFILE {
        @AuraEnabled
        public String vendor_pemasang;              // Vendor who installed the equipment
        @AuraEnabled
        public String user_pemrakarsa;              // Initiating user
        @AuraEnabled
        public String tipe_merchant;                // Merchant type
        @AuraEnabled
        public String tipe;                         // Type
        @AuraEnabled
        public String telpon;                       // Phone number
        @AuraEnabled
        public String tanggal_update_data;          // Data update date
        @AuraEnabled
        public String tanggal_pasang;               // Installation date
        @AuraEnabled
        public String tanggal_modifikasi_terakhir;  // Last modification date
        @AuraEnabled
        public String tanggal_dibuat;               // Creation date
        @AuraEnabled
        public String status_ticket;                // Ticket status
        @AuraEnabled
        public String status_pemasangan;            // Installation status
        @AuraEnabled
        public String regional_office_pengelola;    // Managing regional office
        @AuraEnabled
        public String rc;                           // Response code
        @AuraEnabled
        public String pn_pic_unit_kerja;            // PIC unit work number
        @AuraEnabled
        public String pic_merchant;                 // Merchant PIC
        @AuraEnabled
        public String perangkat;                    // Device
        @AuraEnabled
        public String nomor_telepon_merchant;       // Merchant phone number
        @AuraEnabled
        public String nomor_rekening_penampungan;   // Account number for holding
        @AuraEnabled
        public String no_batch;                     // Batch number
        @AuraEnabled
        public String nama_pic_unit_kerja;          // PIC unit work name
        @AuraEnabled
        public String nama_merchant_qris;           // QRIS merchant name
        @AuraEnabled
        public String nama_merchant_edc;            // EDC merchant name
        @AuraEnabled
        public String modifikasi_oleh;              // Modified by
        @AuraEnabled
        public String mdr_unik;                     // Unique MDR
        @AuraEnabled
        public String mdr_onus;                     // On-us MDR
        @AuraEnabled
        public String mdr_offus;                    // Off-us MDR
        @AuraEnabled
        public String mdr_mastercard;               // Mastercard MDR
        @AuraEnabled
        public String mdr_debit_pl;                 // Debit PL MDR
        @AuraEnabled
        public String mdr_debit_npg;                // Debit NPG MDR
        @AuraEnabled
        public String mcc_visa;                     // Visa MCC
        @AuraEnabled
        public String mcc_npg;                      // NPG MCC
        @AuraEnabled
        public String mcc_master;                   // Master MCC
        @AuraEnabled
        public String kode_unit_kerja;              // Work unit code
        @AuraEnabled
        public String kanwil;                       // Regional office
        @AuraEnabled
        public String kantor_wilayah;               // Regional office
        @AuraEnabled
        public String jenis_usaha_merchant;         // Merchant business type
        @AuraEnabled
        public String jenis_merchant;               // Merchant type
        @AuraEnabled
        public String email;                        // Email address
        @AuraEnabled
        public String detail_edc;                   // EDC details
        @AuraEnabled
        public String detail;                       // Details
        @AuraEnabled
        public String data_promo;                   // Promo data
        @AuraEnabled
        public String code_reffnum;                 // Reference number code
        @AuraEnabled
        public String channel_merchant;             // Merchant channel
        @AuraEnabled
        public String alamat_merchant;              // Merchant address
        @AuraEnabled
        public String mid;                          // Merchant ID
        @AuraEnabled
        public String tid;                          // Terminal ID
        @AuraEnabled
        public String showSection;     
    }

    /** @description
     * Parses a JSON string and returns an instance of SCC_MerchantProfileByMIDWrapper.
     *
     * @param json The JSON string to parse.
     * @return An instance of SCC_MerchantProfileByMIDWrapper.
     */
    public static SCC_MerchantProfileByMIDWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_MerchantProfileByMIDWrapper object
        return (SCC_MerchantProfileByMIDWrapper) System.JSON.deserialize(json, SCC_MerchantProfileByMIDWrapper.class);
    }
}