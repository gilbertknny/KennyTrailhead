/**
 * This class wraps merchant profile data by TID (Terminal Identification Number) 
 * and provides functionality to parse JSON into an instance of SCC_MerchantProfileByTIDWrapper.
 */
public without sharing class SCC_MerchantProfileByTIDWrapper {
    
    // List to hold MERCHANT_PROFILE objects representing merchant profiles
    public List<MERCHANT_PROFILE> MERCHANT_PROFILE;

    /**
     * Inner class representing the profile of a merchant.
     */
    public class MERCHANT_PROFILE {
        public String vendor_pemasang;              // Vendor who installed the equipment
        public String user_pemrakarsa;              // Initiating user
        public String tipe_merchant;                // Merchant type
        public String tipe;                         // Type
        public String telpon;                       // Phone number
        public String tanggal_update_data;          // Data update date
        public String tanggal_pasang;               // Installation date
        public String tanggal_modifikasi_terakhir;  // Last modification date
        public String tanggal_dibuat;               // Creation date
        public String status_ticket;                // Ticket status
        public String status_pemasangan;            // Installation status
        public String regional_office_pengelola;    // Managing regional office
        public String rc;                           // Response code
        public String pn_pic_unit_kerja;            // PIC unit work number
        public String pic_merchant;                 // Merchant PIC
        public String perangkat;                    // Device
        public String nomor_telepon_merchant;       // Merchant phone number
        public String nomor_rekening_penampungan;   // Account number for holding
        public String no_batch;                     // Batch number
        public String nama_pic_unit_kerja;          // PIC unit work name
        public String nama_merchant_qris;           // QRIS merchant name
        public String nama_merchant_edc;            // EDC merchant name
        public String modifikasi_oleh;              // Modified by
        public String mdr_unik;                     // Unique MDR
        public String mdr_onus;                     // On-us MDR
        public String mdr_offus;                    // Off-us MDR
        public String mdr_mastercard;               // Mastercard MDR
        public String mdr_debit_pl;                 // Debit PL MDR
        public String mdr_debit_npg;                // Debit NPG MDR
        public String mcc_visa;                     // Visa MCC
        public String mcc_npg;                      // NPG MCC
        public String mcc_master;                   // Master MCC
        public String kode_unit_kerja;              // Work unit code
        public String kanwil;                       // Regional office
        public String kantor_wilayah;               // Regional office
        public String jenis_usaha_merchant;         // Merchant business type
        public String jenis_merchant;               // Merchant type
        public String email;                        // Email address
        public String detail_edc;                   // EDC details
        public String detail;                       // Details
        public String data_promo;                   // Promo data
        public String code_reffnum;                 // Reference number code
        public String channel_merchant;             // Merchant channel
        public String alamat_merchant;              // Merchant address
        public String mid;                          // Merchant ID
        public String tid;                          // Terminal ID
    }

    /**
     * Parses a JSON string and returns an instance of SCC_MerchantProfileByTIDWrapper.
     *
     * @param json The JSON string to parse.
     * @return An instance of SCC_MerchantProfileByTIDWrapper.
     */
    public static SCC_MerchantProfileByTIDWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_MerchantProfileByTIDWrapper object
        return (SCC_MerchantProfileByTIDWrapper) System.JSON.deserialize(json, SCC_MerchantProfileByTIDWrapper.class);
    }
}