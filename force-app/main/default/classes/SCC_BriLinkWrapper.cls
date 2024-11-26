/** @description
 * Class representing a wrapper for BRILINK_PROFILE data.
 * This class provides methods to parse JSON into BRILINK_PROFILE objects.
 */
public class SCC_BriLinkWrapper {
    @AuraEnabled 
    public List<BRILINK_PROFILE> BRILINK_PROFILE;
    @AuraEnabled 
    public String errorMsg;
    /**
     * @description
     * Inner class representing BRILINK_PROFILE details.
     */
    public class BRILINK_PROFILE {
        @AuraEnabled 
        public String TID;
        @AuraEnabled 
        public String alamat_agen;
        @AuraEnabled 
        public String jenis_jaringan;
        @AuraEnabled 
        public String jenis_usaha;
        @AuraEnabled 
        public String kode_agen;
        @AuraEnabled 
        public String kode_channel;
        @AuraEnabled 
        public String kode_merchant;
        @AuraEnabled 
        public String kode_uker_pengelola;
        @AuraEnabled 
        public String limit_transaksi;
        @AuraEnabled 
        public String mid;
        @AuraEnabled 
        public String modifikasi_oleh;
        @AuraEnabled 
        public String nama_agen;
        @AuraEnabled 
        public String nama_ibu_kandung;
        @AuraEnabled 
        public String nama_lengkap;
        @AuraEnabled 
        public String nama_merchant;
        @AuraEnabled 
        public String nomor_kartu_debit;
        @AuraEnabled 
        public String nomor_kontak_pab;
        @AuraEnabled 
        public String nomor_ktp;
        @AuraEnabled 
        public String nomor_rekening;
        @AuraEnabled 
        public String nomor_rekening_pelimpahan;
        @AuraEnabled 
        public String nomor_rekening_pinjaman;
        @AuraEnabled 
        public String nomor_siup;
        @AuraEnabled 
        public String pic_uker;
        @AuraEnabled 
        public String region_office_pengelola;
        public String sharing_fee;
        public String status;
        @AuraEnabled 
        public String tanggal_dibuat;
        @AuraEnabled 
        public String tanggal_lahir;
        @AuraEnabled 
        public String tanggal_modifikasi;
        @AuraEnabled 
        public String telepon;
        @AuraEnabled 
        public Boolean showSection;
        @AuraEnabled 
        public String UniqueId;
    }
    
    /**
     * @description Parses a JSON string into an instance of SCC_BriLinkWrapper.
     * @param json The JSON string to parse.
     * @return An instance of SCC_BriLinkWrapper parsed from the JSON string, or null if parsing fails.
     */
    public static SCC_BriLinkWrapper parse(String json) {
        if (json == null) {
            return null;
        }

        try {
            return (SCC_BriLinkWrapper) System.JSON.deserialize(json, SCC_BriLinkWrapper.class);
        } catch (JSONException e) {
            // Handle any JSON parsing exceptions here
            return null;
        } 
    }
}