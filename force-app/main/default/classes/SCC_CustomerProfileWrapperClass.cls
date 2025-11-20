/**
 * This class represents a wrapper for customer profiles in the SCC system.
 * It contains nested classes for demographic information and banking portfolios,
 * along with methods for parsing JSON data.
 */
public class SCC_CustomerProfileWrapperClass {
    // Inner class representing demographic information
	public class Demografi {
		public Integer umur;
		public String tipeNasabahDesc;
		public String tipeNasabah;
		public String tipeIdCorp;
		public String tempatPendirian;
		public String tempatLahir;
		public String teleponKantor;
		public String telepon3;
		public String telepon2;
		public String telepon1;
		public String telepon;
		public String tanggalTerbit;
		public String tanggalLahir;
		public String tanggalAktaPendirian;
		public String statusPerkawinan;
		public String rwSesuaiID;
		public String rwKantor;
		public String rwDomisili;
		public String rtSesuaiID;
		public String rtKantor;
		public String rtDomisili;
		public String propinsiSesuaiID;
		public String propinsiKantor;
		public String propinsiDomisili;
		public String pendidikanTerakhir;
		public String nomorIdentitas;
		public String noIdCorp;
		public String noAktaPendirian;
		public String negara;
		public String nasabahPrioritas;
		public String namaTempatBekerja;
		public String namaSesuaiIdentitas;
		public String namaGadisIbuKandung;
		public String nama3;
		public String nama2;
		public String nama1;
		public String lastModifiedDate;
		public String kotaSesuaiID;
		public String kotaKantor;
		public String kotaDomisili;
		public String kodePosSesuaiID;
		public String kodePosKantor;
		public String kodePosDomisili;
		public String kodeBidangUsaha;
		public String kewarganegaraan;
		public String keteranganAgama;
		public String kelurahanSesuaiID;
		public String kelurahanKantor;
		public String kelurahanDomisili;
		public String kecamatanSesuaiID;
		public String kecamatanKantor;
		public String kecamatanDomisili;
		public String jenisPekerjaan;
		public String jenisKelamin;
		public String jenisIdentitas;
		public String jabatan3;
		public String jabatan2;
		public String jabatan1;
		public String handphone;
		public String gelarSetelahNama;
		public String gelarSebelumNama;
		public String email3;
		public String email2;
		public String email1;
		public String email;
		public String createdDate;
		public String bidangUsaha;
		public String bidangPekerjaan;
		public String alamatSuratMenyurat;
		public String alamatSesuaiID2;
		public String alamatSesuaiID;
		public String alamatKantor2;
		public String alamatKantor;
		public String alamatDomisili2;
		public String alamatDomisili;
		public String PEP;
		public String NPWP;
	}

    // Inner class representing banking portfolios
	public class PortofolioPerbankan {
		public List<Simpanan> simpanan;
		public List<Simpanan> pinjaman;
		public List<Simpanan> investasi;
		public List<Simpanan> cardlink;
	}

	public List<Data> data;
	public Object errors;
	public String responseMessage;
	public String responseCode;
	public String errorCode;
	public Integer statusCode;

    // Inner class representing data
	public class Data {
		public PortofolioPerbankan portofolioPerbankan;
		public Demografi demografi;
		public String cifno;
	}

    // Inner class representing simpanan
	public class Simpanan {
	}

	/**
     * Parses the JSON string and returns a SCC_CustomerProfileWrapperClass object.
     *
     * @param json The JSON string to be parsed.
     * @return SCC_CustomerProfileWrapperClass object parsed from the JSON string.
     */
	public static SCC_CustomerProfileWrapperClass parse(String json) {
		return (SCC_CustomerProfileWrapperClass) System.JSON.deserialize(json, SCC_CustomerProfileWrapperClass.class);
	}
}