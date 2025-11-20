/**
 * This class wraps DPLK data by account number and provides functionality
 * to parse JSON into an instance of SCC_DPLK_ByAccountNumberWrapper.
 */
public without sharing class SCC_DPLK_ByAccountNumberWrapper {
    
    // List to hold TRX_DPLK objects representing transactions
    public List<TRX_DPLK> TRX_DPLK;
    // List to hold SI_DPLK objects representing subscriber information
    public List<SI_DPLK> SI_DPLK;

    /**
     * Inner class representing subscriber information for DPLK.
     */
    public class SI_DPLK {
        public String nik;                          // National ID number
        public String nomor_rekening_bri;           // BRI account number
        public String nomor_kartu_dplk;             // DPLK card number
        public String total_saldo;                  // Total balance
        public String tgl_registrasi;               // Registration date
        public String tanggal_lahir;                // Date of birth
        public String status_dplk;                  // DPLK status
        public String sistem_pembayaran_iuran;      // Contribution payment system
        public String pengembangan;                 // Development
        public String pengalihan;                   // Transfer
        public String nomor_handphone;              // Mobile phone number
        public String nomor_akun_dplk;              // DPLK account number
        public String no_pegawai_korporat;          // Corporate employee number
        public String nama_nasabah;                 // Customer name
        public String kantor_pembukaan_cabang;      // Branch opening office
        public String jenis_investasi;              // Investment type
        public String iuran;                        // Contribution
        public String cif_dplk;                     // DPLK CIF (Customer Information File)
        public String anggota_korporat_individu;    // Corporate/Individual member
        public String alamat_email;                 // Email address
    }

    /**
     * Inner class representing transaction data for DPLK.
     */
    public class TRX_DPLK {
        public String nik;                          // National ID number
        public String no_rekening;                  // Account number
        public String nomor_kartu_dplk;             // DPLK card number
        public String tanggal_transaksi;            // Transaction date
        public String nomor_handphone;              // Mobile phone number
        public String nama_transaksi;               // Transaction name
        public String nama_nasabah;                 // Customer name
        public String kode_jenis_transaksi;         // Transaction type code
        public String keterangan;                   // Description
        public String iscommitted;                  // Committed status
        public String id_transaksi;                 // Transaction ID
        public String branch_code;                  // Branch code
    }

    /**
     * Parses a JSON string and returns an instance of SCC_DPLK_ByAccountNumberWrapper.
     *
     * @param json The JSON string to parse.
     * @return An instance of SCC_DPLK_ByAccountNumberWrapper.
     */
    public static SCC_DPLK_ByAccountNumberWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_DPLK_ByAccountNumberWrapper object
        return (SCC_DPLK_ByAccountNumberWrapper) System.JSON.deserialize(json, SCC_DPLK_ByAccountNumberWrapper.class);
    }
}