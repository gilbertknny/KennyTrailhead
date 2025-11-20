/** @description
 * SCC_CustPersWrapper is a wrapper class for handling customer data .
 * 
 * The class provides a method to parse JSON strings into SCC_CustPersWrapper objects.
 */
public class SCC_CustPersWrapper {
  /** @description namaNasabahLengkap */
  @AuraEnabled
    public String namaNasabahLengkap { get; set; }
   /** @description nik */
    @AuraEnabled
    public String nik { get; set; }
    /** @description tanggalLahir */
    @AuraEnabled
    public String tanggalLahir	 { get; set; }
   /** @description nomorAplikasiPengajuan */
    @AuraEnabled
    public String nomorAplikasiPengajuan { get; set; }
    /** @description tanggalPengajuan */
    @AuraEnabled
    public String tanggalPengajuan { get; set; }
     /** @description channelPengajuan */ 
    @AuraEnabled
    public String channelPengajuan { get; set; }
     /** @description nomorKartuKredit */ 
    @AuraEnabled
    public String nomorKartuKredit { get; set; }
     /** @description progressPengajuan */
    @AuraEnabled
    public String progressPengajuan { get; set; }
       /** @description
 * Constructs an instance of SCC_CustPersWrapper with the specified parameters.
 * @param namaNasabahLengkap Full name of the customer.
 * @param nik Customer's identification number.
 * @param tanggalLahir Customer's date of birth.
 * @param nomorAplikasiPengajuan Application number associated with the customer.
 * @param tanggalPengajuan Date of application submission.
 * @param channelPengajuan Channel through which the application was submitted.
 * @param nomorKartuKredit Credit card number associated with the customer (if applicable).
 * @param progressPengajuan Current status or progress of the application.
 */
     public SCC_CustPersWrapper(String namaNasabahLengkap, String nik, String tanggalLahir,String nomorAplikasiPengajuan,String tanggalPengajuan,
                                     String channelPengajuan, String nomorKartuKredit, String progressPengajuan ) {
       
        this.namaNasabahLengkap = namaNasabahLengkap;
        this.nik = nik;
        this.tanggalLahir = tanggalLahir;
        this.nomorAplikasiPengajuan = nomorAplikasiPengajuan;
        this.tanggalPengajuan = tanggalPengajuan;
        this.channelPengajuan = channelPengajuan;
        this.nomorKartuKredit = nomorKartuKredit;
        this.progressPengajuan = progressPengajuan;
                                         
                                         
    }
}