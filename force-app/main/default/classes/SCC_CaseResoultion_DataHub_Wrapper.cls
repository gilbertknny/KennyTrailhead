public with sharing class SCC_CaseResoultion_DataHub_Wrapper {
    public class CustomerProfileDemografi{
        //old
        @AuraEnabled public string	cfbrnn	{get;set;}
        //@AuraEnabled public string	gelarSebelumNama	{get;set;}
        @AuraEnabled public string	namaSesuaiId	{get;set;}
        //@AuraEnabled public string	namaSesuaiIdentitas	{get;set;}
        @AuraEnabled public string	gelarSesudahNama	{get;set;}
        @AuraEnabled public string	namaLengkap	{get;set;}
        @AuraEnabled public string	idNumber	{get;set;}
        @AuraEnabled public string	idType	{get;set;}
        @AuraEnabled public string	idDesc	{get;set;}
        @AuraEnabled public string	idIssue	{get;set;}
        @AuraEnabled public string	idExp	{get;set;}
        //@AuraEnabled public string	tipeNasabah	{get;set;}
        //@AuraEnabled public string	tipeNasabahDesc	{get;set;}
        //@AuraEnabled public string	npwp	{get;set;}
        //@AuraEnabled public string	jenisKelamin	{get;set;}
        //@AuraEnabled public string	tanggalLahir	{get;set;}
        //@AuraEnabled public string	tempatLahir	{get;set;}
        @AuraEnabled public string	namaIbuKandung	{get;set;}
        @AuraEnabled public string	statusNikah	{get;set;}
        @AuraEnabled public string	agama	{get;set;}
        @AuraEnabled public string	alamatId1	{get;set;}
        @AuraEnabled public string	alamatId2	{get;set;}
        @AuraEnabled public string	alamatId3	{get;set;}
        @AuraEnabled public string	alamatId4	{get;set;}
        @AuraEnabled public string	rtId	{get;set;}
        @AuraEnabled public string	rwId	{get;set;}
        @AuraEnabled public string	kelurahanId	{get;set;}
        @AuraEnabled public string	kecamatanId	{get;set;}
        @AuraEnabled public string	kotaId	{get;set;}
        @AuraEnabled public string	propinsiIid	{get;set;}
        @AuraEnabled public string	kodeposId	{get;set;}
        @AuraEnabled public string	alamatDomisili1	{get;set;}
        //@AuraEnabled public string	alamatDomisili2	{get;set;}
        @AuraEnabled public string	alamatDomisili3	{get;set;}
        @AuraEnabled public string	alamatDomisili4	{get;set;}
        //@AuraEnabled public string	rtDomisili	{get;set;}
        //@AuraEnabled public string	rwDomisili	{get;set;}
        //@AuraEnabled public string	kelurahanDomisili	{get;set;}
        //@AuraEnabled public string	kecamatanDomisili	{get;set;}
        //@AuraEnabled public string	kotaDomisili	{get;set;}
        //@AuraEnabled public string	propinsiDomisili	{get;set;}
        //@AuraEnabled public string	kodeposDomisili	{get;set;}
        @AuraEnabled public string	alamatKantor1	{get;set;}
        //@AuraEnabled public string	alamatKantor2	{get;set;}
        @AuraEnabled public string	alamatKantor3	{get;set;}
        @AuraEnabled public string	alamatKantor4	{get;set;}
        //@AuraEnabled public string	rtKantor	{get;set;}
        //@AuraEnabled public string	rwKantor	{get;set;}
        //@AuraEnabled public string	kelurahanKantor	{get;set;}
        //@AuraEnabled public string	kecamatanKantor	{get;set;}
        //@AuraEnabled public string	kotaKantor	{get;set;}
        //@AuraEnabled public string	propinsiKantor	{get;set;}
        //@AuraEnabled public string	kodeposKantor	{get;set;}
        @AuraEnabled public string	alamatSurat	{get;set;}
        //@AuraEnabled public string	kewarganegaraan	{get;set;}
        //@AuraEnabled public string	negara	{get;set;}
        @AuraEnabled public string	kodePajak	{get;set;}
        @AuraEnabled public string	prioritas	{get;set;}
        @AuraEnabled public string	prioritasPbo	{get;set;}
        @AuraEnabled public string	prioritasPboContact	{get;set;}
        //@AuraEnabled public string	pep	{get;set;}
        @AuraEnabled public string	pepJabatan	{get;set;}
        @AuraEnabled public string	pepKeluarga	{get;set;}
        @AuraEnabled public string	pepStatusKeluarga	{get;set;}
        //@AuraEnabled public string	handphone	{get;set;}
        @AuraEnabled public string	telpRumah	{get;set;}
        @AuraEnabled public string	telpKantor	{get;set;}
        @AuraEnabled public string	fax	{get;set;}
        //@AuraEnabled public string	email	{get;set;}
        @AuraEnabled public string	kodePendidikan	{get;set;}
        @AuraEnabled public string	pendidikan	{get;set;}
        @AuraEnabled public string	kodeJenisPekerjaan	{get;set;}
        //@AuraEnabled public string	jenisPekerjaan	{get;set;}
        @AuraEnabled public string	namaKantor	{get;set;}
        @AuraEnabled public string	kodeBidangPekerjaan	{get;set;}
        //@AuraEnabled public string	bidangPekerjaan	{get;set;}
        @AuraEnabled public string	kodeJabatan	{get;set;}
        @AuraEnabled public string	jabatan	{get;set;}
        @AuraEnabled public string	lamaBekerjaTahun	{get;set;}
        @AuraEnabled public string	lamaBekerjaBulan	{get;set;}
        @AuraEnabled public string	kodePenghasilanPerBulan	{get;set;}
        @AuraEnabled public string	penghasilanPerBulan	{get;set;}
        @AuraEnabled public string	kodeOmsetPerBulan	{get;set;}
        @AuraEnabled public string	omsetPerBulan	{get;set;}
        @AuraEnabled public string	kodeTrxNormalHarian	{get;set;}
        @AuraEnabled public string	trxNormalHarian	{get;set;}
        @AuraEnabled public string	kodeSumberPenghasilan	{get;set;}
        @AuraEnabled public string	sumberPenghasilan	{get;set;}
        @AuraEnabled public string	kodeTujuanBukaRekening	{get;set;}
        @AuraEnabled public string	tujuanBukaRekening	{get;set;}
        @AuraEnabled public string	tanggalBukaCif	{get;set;}
        @AuraEnabled public string	tanggalMaintenanceCif	{get;set;}
        @AuraEnabled public string	notesBeneficialOwner	{get;set;}
        @AuraEnabled public string	notesIbuKandung	{get;set;}
        @AuraEnabled public string	notesTanggalLahir	{get;set;}
        //@AuraEnabled public string	kodeBidangUsaha	{get;set;}
        //@AuraEnabled public string	bidangUsaha	{get;set;}
        //@AuraEnabled public string	tempatPendirian	{get;set;}
        //@AuraEnabled public string	tipeIdCorp	{get;set;}
        @AuraEnabled public string	tipeIdDescCorp	{get;set;}
        //@AuraEnabled public string	noIdCorp	{get;set;}
        @AuraEnabled public string	tanggalTerbitCorp	{get;set;}
        @AuraEnabled public string	tanggalKadaluarsaCorp	{get;set;}
        //@AuraEnabled public string	noAktaPendirian	{get;set;}
        //@AuraEnabled public string	tanggalAktaPendirian	{get;set;}
        @AuraEnabled public string	noAktaPerubahan	{get;set;}
        @AuraEnabled public string	tanggalAktaPerubahan	{get;set;}
        @AuraEnabled public string	namaPengurus1	{get;set;}
        @AuraEnabled public string	jabatanPengurus1	{get;set;}
        @AuraEnabled public string	teleponPengurus1	{get;set;}
        @AuraEnabled public string	emailPengurus1	{get;set;}
        @AuraEnabled public string	namaPengurus2	{get;set;}
        @AuraEnabled public string	jabatanPengurus2	{get;set;}
        @AuraEnabled public string	teleponPengurus2	{get;set;}
        @AuraEnabled public string	emailPengurus2	{get;set;}
        @AuraEnabled public string	namaPengurus3	{get;set;}
        @AuraEnabled public string	jabatanPengurus3	{get;set;}
        @AuraEnabled public string	teleponPengurus3	{get;set;}
        @AuraEnabled public string	emailPengurus3	{get;set;}
        @AuraEnabled public string	jumlahTanggungan	{get;set;}
        @AuraEnabled public string	statusKepemilikanTempatTinggal	{get;set;}
        @AuraEnabled public string	namaLengkapKontakDarurat	{get;set;}
        @AuraEnabled public string	nomorHandphoneKontakDarurat	{get;set;}
        //@AuraEnabled public string	nasabahPrioritas	{get;set;}

        //new
        @AuraEnabled public string	NPWP	{get;set;}
        @AuraEnabled public string	PEP	{get;set;}
        @AuraEnabled public string	alamatDomisili	{get;set;}
        @AuraEnabled public string	alamatDomisili2	{get;set;}
        @AuraEnabled public string	alamatKantor	{get;set;}
        @AuraEnabled public string	alamatKantor2	{get;set;}
        @AuraEnabled public string	alamatSesuaiID	{get;set;}
        @AuraEnabled public string	alamatSesuaiID2	{get;set;}
        @AuraEnabled public string	alamatSuratMenyurat	{get;set;}
        @AuraEnabled public string	bidangPekerjaan	{get;set;}
        @AuraEnabled public string	bidangUsaha	{get;set;}
        @AuraEnabled public string	createdDate	{get;set;}
        @AuraEnabled public string	email	{get;set;}
        @AuraEnabled public string	email1	{get;set;}
        @AuraEnabled public string	email2	{get;set;}
        @AuraEnabled public string	email3	{get;set;}
        @AuraEnabled public string	gelarSebelumNama	{get;set;}
        @AuraEnabled public string	gelarSetelahNama	{get;set;}
        @AuraEnabled public string	handphone	{get;set;}
        @AuraEnabled public string	jabatan1	{get;set;}
        @AuraEnabled public string	jabatan2	{get;set;}
        @AuraEnabled public string	jabatan3	{get;set;}
        @AuraEnabled public string	jenisIdentitas	{get;set;}
        @AuraEnabled public string	jenisKelamin	{get;set;}
        @AuraEnabled public string	jenisPekerjaan	{get;set;}
        @AuraEnabled public string	kecamatanDomisili	{get;set;}
        @AuraEnabled public string	kecamatanKantor	{get;set;}
        @AuraEnabled public string	kecamatanSesuaiID	{get;set;}
        @AuraEnabled public string	kelurahanDomisili	{get;set;}
        @AuraEnabled public string	kelurahanKantor	{get;set;}
        @AuraEnabled public string	kelurahanSesuaiID	{get;set;}
        @AuraEnabled public string	keteranganAgama	{get;set;}
        @AuraEnabled public string	kewarganegaraan	{get;set;}
        @AuraEnabled public string	kodeBidangUsaha	{get;set;}
        @AuraEnabled public string	kodePosDomisili	{get;set;}
        @AuraEnabled public string	kodePosKantor	{get;set;}
        @AuraEnabled public string	kodePosSesuaiID	{get;set;}
        @AuraEnabled public string	kotaDomisili	{get;set;}
        @AuraEnabled public string	kotaKantor	{get;set;}
        @AuraEnabled public string	kotaSesuaiID	{get;set;}
        @AuraEnabled public string	lastModifiedDate	{get;set;}
        @AuraEnabled public string	nama1	{get;set;}
        @AuraEnabled public string	nama2	{get;set;}
        @AuraEnabled public string	nama3	{get;set;}
        @AuraEnabled public string	namaGadisIbuKandung	{get;set;}
        @AuraEnabled public string	namaSesuaiIdentitas	{get;set;}
        @AuraEnabled public string	namaTempatBekerja	{get;set;}
        @AuraEnabled public string	nasabahPrioritas	{get;set;}
        @AuraEnabled public string	negara	{get;set;}
        @AuraEnabled public string	noAktaPendirian	{get;set;}
        @AuraEnabled public string	noIdCorp	{get;set;}
        @AuraEnabled public string	nomorIdentitas	{get;set;}
        @AuraEnabled public string	pendidikanTerakhir	{get;set;}
        @AuraEnabled public string	propinsiDomisili	{get;set;}
        @AuraEnabled public string	propinsiKantor	{get;set;}
        @AuraEnabled public string	propinsiSesuaiID	{get;set;}
        @AuraEnabled public string	rtDomisili	{get;set;}
        @AuraEnabled public string	rtKantor	{get;set;}
        @AuraEnabled public string	rtSesuaiID	{get;set;}
        @AuraEnabled public string	rwDomisili	{get;set;}
        @AuraEnabled public string	rwKantor	{get;set;}
        @AuraEnabled public string	rwSesuaiID	{get;set;}
        @AuraEnabled public string	statusPerkawinan	{get;set;}
        @AuraEnabled public string	tanggalAktaPendirian	{get;set;}
        @AuraEnabled public string	tanggalLahir	{get;set;}
        @AuraEnabled public string	tanggalTerbit	{get;set;}
        @AuraEnabled public string	telepon	{get;set;}
        @AuraEnabled public string	telepon1	{get;set;}
        @AuraEnabled public string	telepon2	{get;set;}
        @AuraEnabled public string	telepon3	{get;set;}
        @AuraEnabled public string	teleponKantor	{get;set;}
        @AuraEnabled public string	tempatLahir	{get;set;}
        @AuraEnabled public string	tempatPendirian	{get;set;}
        @AuraEnabled public string	tipeIdCorp	{get;set;}
        @AuraEnabled public string	tipeNasabah	{get;set;}
        @AuraEnabled public string	tipeNasabahDesc	{get;set;}
        @AuraEnabled public Integer	umur	{get;set;}

    }

    public class CustomerProfileSavingCard{
        @AuraEnabled public string	cardNo 	{get;set;}
        @AuraEnabled public string	tipeKartu 	{get;set;}
        @AuraEnabled public string	jenisKartu	{get;set;}
        @AuraEnabled public string	kodeStatus	{get;set;}
    }

    public class CustomerProfileSimpanan{
        //old
        @AuraEnabled public string	acctno 	{get;set;}
        @AuraEnabled public string	rataSaldo 	{get;set;}
        @AuraEnabled public string	saldo 	{get;set;}
        @AuraEnabled public string	mataUang 	{get;set;}
        @AuraEnabled public string	per 	{get;set;}
        @AuraEnabled public string	produk 	{get;set;}
        @AuraEnabled public string	tipeProduk 	{get;set;}
        @AuraEnabled public string	deskripsiProduk	{get;set;}
        @AuraEnabled public string	groupProduk 	{get;set;}
        @AuraEnabled public string	openAccountDate	{get;set;}
        @AuraEnabled public List<CustomerProfileSavingCard>	cardList 	{get;set;}

        //new 
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public Decimal balance {get;set;}
        @AuraEnabled public String brimo {get;set;}
        @AuraEnabled public String cardNo {get;set;}
        @AuraEnabled public String cifno {get;set;}
        @AuraEnabled public String productType {get;set;}
        @AuraEnabled public String productDescription {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String status {get;set;}
    }

    public class CustomerProfilePinjaman{
        //old
        @AuraEnabled public string	acctno 	{get;set;}
        @AuraEnabled public string	saldo 	{get;set;}
        @AuraEnabled public string	mataUang 	{get;set;}
        @AuraEnabled public string	per 	{get;set;}
        @AuraEnabled public string	produk	{get;set;}
        @AuraEnabled public string	tipeProduk	{get;set;}
        @AuraEnabled public string	deskripsiProduk	{get;set;}
        @AuraEnabled public string	groupProduk	{get;set;}
        @AuraEnabled public string	openAccountDate	{get;set;}

        //new
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public Decimal balance {get;set;}
        @AuraEnabled public String cifno {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String productDescription {get;set;}
        @AuraEnabled public String productType {get;set;}
    }

    public class CustomerProfileInvestasi{
        //old
        @AuraEnabled public string	acctno	{get;set;}
        @AuraEnabled public string	jumlah	{get;set;}
        @AuraEnabled public string	grup	{get;set;}
        @AuraEnabled public string	tipeProduk	{get;set;}
        @AuraEnabled public string	deskripsiProduk 	{get;set;}
        @AuraEnabled public string	groupProduk	{get;set;}
        
        //new
        @AuraEnabled public String accountNumber {get;set;}
        @AuraEnabled public Decimal balance {get;set;}
        @AuraEnabled public String cifno {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String productDescription {get;set;}
        @AuraEnabled public String productType {get;set;}
        @AuraEnabled public String status {get;set;}
    }

    public class CustomerProfileCardLink{
        //old
        @AuraEnabled public string	idNumber	{get;set;}
        @AuraEnabled public string	 nomorKartu	{get;set;}
        @AuraEnabled public string	 mataUang	{get;set;}
        @AuraEnabled public string	 kolektibilitas	{get;set;}
        @AuraEnabled public string	 produk	{get;set;}
        @AuraEnabled public string	 tipeProduk	{get;set;}
        @AuraEnabled public string	 deskripsiProduk	{get;set;}
        @AuraEnabled public string	 groupProduk	{get;set;}
        @AuraEnabled public string	 openAccountDate	{get;set;}

        //new
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String productType {get;set;}
        @AuraEnabled public String productDescription {get;set;}
        @AuraEnabled public String product {get;set;}
        @AuraEnabled public String cifno {get;set;}
        @AuraEnabled public String cardNumber {get;set;}
        @AuraEnabled public String cardNo {get;set;}
    }

    public class CustomerProfileDukcapil{
        @AuraEnabled public string	nik	{get;set;}
        @AuraEnabled public string	urut	{get;set;}
        @AuraEnabled public string	namaSesuaiId	{get;set;}
        @AuraEnabled public string	namaIbuKandung 	{get;set;}
        @AuraEnabled public string	tempatLahir	{get;set;}
        @AuraEnabled public string	tanggalLahir	{get;set;}
        @AuraEnabled public string	propinsiId	{get;set;}
        @AuraEnabled public string	kotaId	{get;set;}
        @AuraEnabled public string	kecamatanId	{get;set;}
        @AuraEnabled public string	kelurahanId	{get;set;}
        @AuraEnabled public string	alamat	{get;set;}
        @AuraEnabled public string	batas	{get;set;}
        @AuraEnabled public string	nikSiak	{get;set;}
        @AuraEnabled public string	namaLgkpSiak 	{get;set;}
        @AuraEnabled public string	namaLgkpIbuSiak	{get;set;}
        @AuraEnabled public string	tmptLhrSiak 	{get;set;}
        @AuraEnabled public string	tglLhrSiak 	{get;set;}
        @AuraEnabled public string	alamatSiak 	{get;set;}
        @AuraEnabled public string	noProp 	{get;set;}
        @AuraEnabled public string	namaProp 	{get;set;}
        @AuraEnabled public string	noKab 	{get;set;}
        @AuraEnabled public string	namaKab 	{get;set;}
        @AuraEnabled public string	noKec 	{get;set;}
        @AuraEnabled public string	namaKec 	{get;set;}
        @AuraEnabled public string	noKel 	{get;set;}
        @AuraEnabled public string	namaKel 	{get;set;}
        @AuraEnabled public string	sanding 	{get;set;}
        @AuraEnabled public string	kk 	{get;set;}
        @AuraEnabled public string	updatedAt 	{get;set;}
    }

    public class CustomerProfilePortofolioPerbankan{
        @AuraEnabled public List<CustomerProfileSimpanan> simpanan {get;set;}
        @AuraEnabled public List<CustomerProfilePinjaman> pinjaman {get;set;}
        @AuraEnabled public List<CustomerProfileInvestasi> investasi {get;set;}
        @AuraEnabled public List<CustomerProfileCardLink> cardlink {get;set;}
    }

    public class CustomerProfileResponseData{
        @AuraEnabled public String cifno {get;set;}
        @AuraEnabled public CustomerProfileDemografi demografi {get;set;}
        @AuraEnabled public CustomerProfilePortofolioPerbankan portofolioPerbankan {get;set;}
        @AuraEnabled public CustomerProfileDukcapil profileDukcapil {get;set;}
    }

    public class CustomerProfileResponse{
        @AuraEnabled public Integer statusCode {get;set;}
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public List<String> errors {get;set;}
        @AuraEnabled public List<CustomerProfileResponseData> data {get;set;}
    }

    public class CustomerProfileRequest{
        @AuraEnabled public String cardNo {get;set;}
        @AuraEnabled public String acctNo {get;set;}
        @AuraEnabled public String cifNo {get;set;}
        @AuraEnabled public String phoneNumber {get;set;}
        @AuraEnabled public String idType {get;set;}
        @AuraEnabled public String idValue {get;set;}
        @AuraEnabled public String personalNumber {get;set;}
        @AuraEnabled public String channelId {get;set;}
        @AuraEnabled public String feature {get;set;}
    }

    public class SavingMutationRequest{
        @AuraEnabled public String norekVarchar {get;set;}
        @AuraEnabled public String tanggalAwalDatetime {get;set;}
        @AuraEnabled public String tanggalAkhirDatetime {get;set;}
        @AuraEnabled public String channel {get;set;}
    }

    public class SavingMutationResponse{
        @AuraEnabled public Integer statusCode {get;set;}
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public List<String> errors {get;set;}
        @AuraEnabled public List<SavingMutationData> data {get;set;}
    }

    public class SavingMutationData{
        @AuraEnabled public Decimal	idNum3	{get;set;}
        @AuraEnabled public Decimal	idNum2	{get;set;}
        @AuraEnabled public Decimal	seq	{get;set;}
        @AuraEnabled public Decimal	idNum 	{get;set;}
        @AuraEnabled public Decimal	noRek	{get;set;}
        @AuraEnabled public string	tglTran	{get;set;}
        @AuraEnabled public string	tglEfektif	{get;set;}
        @AuraEnabled public Decimal	jamTran	{get;set;}
        @AuraEnabled public string	kodeTran	{get;set;}
        @AuraEnabled public string	deskTran	{get;set;}
        @AuraEnabled public Decimal	saldoAwalMutasi	{get;set;}
        @AuraEnabled public Decimal	mutasiDebet	{get;set;}
        @AuraEnabled public Decimal	mutasiKredit	{get;set;}
        @AuraEnabled public Decimal	saldoAkhirMutasi 	{get;set;}
        @AuraEnabled public string	truser	{get;set;}
        @AuraEnabled public string	glsign 	{get;set;}
        @AuraEnabled public string	terbilang 	{get;set;}
        @AuraEnabled public string	trremk 	{get;set;}
        @AuraEnabled public string	auxtrc 	{get;set;}
        @AuraEnabled public string	serial 	{get;set;}
        @AuraEnabled public string	tlbds1 	{get;set;}
        @AuraEnabled public string	tlbds2 	{get;set;}       
    }

    public class DataMachineRequest{
        //@AuraEnabled public string	tid	{get;set;}
        @AuraEnabled public string	alamatMesin	{get;set;}
    }

    public class DataMachineResponse{
        @AuraEnabled public List<DataMachine> machineDataByAddress {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class DataMachine{
        @AuraEnabled public String tid {get;set;}
        @AuraEnabled public String jenisMesin {get;set;}
        @AuraEnabled public String nomorMesin {get;set;}
        @AuraEnabled public String alamatMesin {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String kontakID {get;set;}
    }

    public class CardLinkAdditionalData{
        @AuraEnabled public String	namaLengkapIbuKandung	{get;set;}
        @AuraEnabled public String	nominalPendapatanPerBulan	{get;set;}
    }

    public class CardLinkSaving{
        @AuraEnabled public	String	acctno	{get;set;}
        @AuraEnabled public	String	balance	{get;set;}
        @AuraEnabled public	String	cifno	{get;set;}
        @AuraEnabled public	String	product	{get;set;}
        @AuraEnabled public	String	productDescription	{get;set;}
        @AuraEnabled public	String	productType	{get;set;}
        @AuraEnabled public	String	status	{get;set;}
    }

    public class CardLinkLoan{
        @AuraEnabled public	String	acctno	{get;set;}
        @AuraEnabled public	String	balance	{get;set;}
        @AuraEnabled public	String	cifno	{get;set;}
        @AuraEnabled public	String	product	{get;set;}
        @AuraEnabled public	String	productDescription	{get;set;}
        @AuraEnabled public	String	productType	{get;set;}
        @AuraEnabled public	String	status	{get;set;}
    }

    public class CardLinkInvestasi{
        @AuraEnabled public	String	acctno	{get;set;}
        @AuraEnabled public	String	balance	{get;set;}
        @AuraEnabled public	String	cifno	{get;set;}
        @AuraEnabled public	String	product	{get;set;}
        @AuraEnabled public	String	productDescription	{get;set;}
        @AuraEnabled public	String	productType	{get;set;}
        @AuraEnabled public	String	status	{get;set;}
    }

    public class CardLinkCreditCard{
        @AuraEnabled public	String	cardNumber	{get;set;}
        @AuraEnabled public	String	cifno	{get;set;}
        @AuraEnabled public	String	product	{get;set;}
        @AuraEnabled public	String	productDescription	{get;set;}
        @AuraEnabled public	String	productType	{get;set;}
        @AuraEnabled public	String	status	{get;set;}
    }

    public class CardLinkCardHolderData{
        @AuraEnabled public String	limitKartuKredit	{get;set;}
        @AuraEnabled public String	expiredKartu	{get;set;}
        @AuraEnabled public String	tanggalCetakCycle	{get;set;}
        @AuraEnabled public String	tanggalJatuhTempo	{get;set;}
        @AuraEnabled public String	sisaLimitKartu	{get;set;}
        @AuraEnabled public String	limitTarikTunaiKartu	{get;set;}
        @AuraEnabled public String	sisaLimitTarikTunaiKartu	{get;set;}
        @AuraEnabled public String	limitCicilanKartu	{get;set;}
        @AuraEnabled public String	sisaLimitCicilanKartu	{get;set;}
        @AuraEnabled public String	customerNumber	{get;set;}
        @AuraEnabled public String	tanggalTerakhirMaintenanceKartu	{get;set;}
        @AuraEnabled public String	namaCetakKartu	{get;set;}
        @AuraEnabled public String	nominalFullPayment	{get;set;}
        @AuraEnabled public String	nominalFullPaymentRtl	{get;set;}
        @AuraEnabled public String	nominalMinimumPayment	{get;set;}
        @AuraEnabled public String	nominalTagihanBerjalan	{get;set;}
        @AuraEnabled public String	nominalPembayaranTerakhir	{get;set;}
        @AuraEnabled public String	tanggalPembayaranTerakhir	{get;set;}
        @AuraEnabled public String	alasanPemblokiran	{get;set;}
        @AuraEnabled public String	fixPayment	{get;set;}
        @AuraEnabled public String	jenisKartu	{get;set;}
        @AuraEnabled public String	namaDataKartuTambahan	{get;set;}
        @AuraEnabled public String	noKartuTambahan	{get;set;}
        @AuraEnabled public String	postingFlag	{get;set;}
        @AuraEnabled public String	tagihanTercetakBulanIni	{get;set;}
    }

    public class CardLinkfinancialInformation{
        @AuraEnabled public String	tagihanBulanLalu	{get;set;}
        @AuraEnabled public String	totalTagihanBulanIni	{get;set;}
        @AuraEnabled public String	nominalTransaksiTarikTunai	{get;set;}
        @AuraEnabled public String	bungaDitagihkan	{get;set;}
    }

    public class CardLinkPortofolio{
        @AuraEnabled public	List<CardLinkCreditCard>	creditCard	{get;set;}
        @AuraEnabled public	List<CardLinkInvestasi>	investasi	{get;set;}
        @AuraEnabled public	List<CardLinkLoan>	loan	{get;set;}
        @AuraEnabled public	List<CardLinkSaving>	saving	{get;set;}
    }

    public class CardLinkCustomerData{
        @AuraEnabled public String	namaDepan	{get;set;}
        @AuraEnabled public String	namaTengah	{get;set;}
        @AuraEnabled public String	namaBelakang	{get;set;}
        @AuraEnabled public String	nomorHandphoneTerdaftar	{get;set;}
        @AuraEnabled public String	nomorTelephoneKerabatTidakSerumah	{get;set;}
        @AuraEnabled public String	nomorTelephoneRumah	{get;set;}
        @AuraEnabled public String	nomorTelephoneKantor	{get;set;}
        @AuraEnabled public String	namaKerabatTidakSerumah	{get;set;}
        @AuraEnabled public String	nomorNik	{get;set;}
        @AuraEnabled public String	nomorNpwp	{get;set;}
        @AuraEnabled public String	sisaLimitNasabah	{get;set;}
        @AuraEnabled public String	limitTarikTunaiNasabah	{get;set;}
        @AuraEnabled public String	sisaLimitTarikTunaiNasabah	{get;set;}
        @AuraEnabled public String	limitCicilanNasabah	{get;set;}
        @AuraEnabled public String	sisaLimitCicilanNasabah	{get;set;}
        @AuraEnabled public String	jenisKelamin	{get;set;}
        @AuraEnabled public String	jabatanKerja	{get;set;}
        @AuraEnabled public String	alamatKantorDepan	{get;set;}
        @AuraEnabled public String	alamatKantorTengah	{get;set;}
        @AuraEnabled public String	alamatKantorBelakang	{get;set;}
        @AuraEnabled public String	alamatRumahDepan	{get;set;}
        @AuraEnabled public String	alamatRumahBelakang	{get;set;}
        @AuraEnabled public String	alamatEmail	{get;set;}
        @AuraEnabled public String	alamatPengirimanKartu	{get;set;}
        @AuraEnabled public String	tanggalLahir	{get;set;}
        @AuraEnabled public String	kota1	{get;set;}
        @AuraEnabled public String	kota2	{get;set;}
        @AuraEnabled public String	kodePos	{get;set;}
        @AuraEnabled public	List<CardLinkCardHolderData>	cardHolderData	{get;set;}
        @AuraEnabled public	List<CardLinkAdditionalData>	additionalData	{get;set;}
        @AuraEnabled public	List<CardLinkfinancialInformation>	financialInformation	{get;set;}
        @AuraEnabled public	CardLinkPortofolio	portofolio	{get;set;}
        @AuraEnabled public String	customerNumber	{get;set;}
    }

    public class CardLinkResponseData{
        @AuraEnabled public List<CardLinkcustomerData> 	customerData	{get;set;}
        @AuraEnabled public List<CardLinkcardHolderData>	cardHolderData	{get;set;}
        @AuraEnabled public List<CardLinkadditionalData>	additionalData	{get;set;}
    }

    public class CardLinkCardNumberResponseData{
        @AuraEnabled public List<CardLinkResponseData> 	data	{get;set;}
        @AuraEnabled public CardLinkPortofolio 	portofolio	{get;set;}
    }

    public class CardLinkCardNumberResponse{
        @AuraEnabled public CardLinkCardNumberResponseData response {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    public class CardLinkPhoneNumberResponseData{
        @AuraEnabled public List<CardLinkcustomerData> 	customerData	{get;set;}
    }

    public class CardLinkPhoneNumberResponse{
        @AuraEnabled public CardLinkPhoneNumberResponseData response {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    public class CardLinkCustomerNumberResponseData{
        @AuraEnabled public List<CardLinkcustomerData> 	customerData	{get;set;}
        @AuraEnabled public List<CardLinkCardHolderData> 	cardHolderData	{get;set;}
        @AuraEnabled public List<CardLinkAdditionalData> 	additionalData	{get;set;}
        @AuraEnabled public List<CardLinkfinancialInformation> 	financialInformation	{get;set;}
        @AuraEnabled public CardLinkPortofolio 	portofolio	{get;set;}
    }

    public class CardLinkCustomerNumberResponse{
        @AuraEnabled public CardLinkCustomerNumberResponseData response {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    public class CardLinkNIKResponseData{
        @AuraEnabled public List<CardLinkcustomerData> 	customerData	{get;set;}
        @AuraEnabled public CardLinkPortofolio 	portofolio	{get;set;}
    }

    public class CardLinkNIKResponse{
        @AuraEnabled public CardLinkNIKResponseData response {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
    }

    public class CardLinkRequest{ 
        @AuraEnabled public String cardNumber {get;set;}
        @AuraEnabled public String phoneNumber {get;set;}
        @AuraEnabled public String customerNumber {get;set;}
        @AuraEnabled public String nik {get;set;}
    }

    public class BRILinkProfile{
        @AuraEnabled public	String	cifno	{get;set;}
        @AuraEnabled public	String	tid	{get;set;}
        @AuraEnabled public	String	jenis_jaringan	{get;set;}
        @AuraEnabled public	String	alamat_agen	{get;set;}
        @AuraEnabled public	String	jenis_usaha	{get;set;}
        @AuraEnabled public	String	kode_agen	{get;set;}
        @AuraEnabled public	String	kode_channel	{get;set;}
        @AuraEnabled public	String	kode_merchant	{get;set;}
        @AuraEnabled public	String	kode_uker_pengelola	{get;set;}
        @AuraEnabled public	String	limit_transaksi	{get;set;}
        @AuraEnabled public	String	mid	{get;set;}
        @AuraEnabled public	String	modifikasi_oleh	{get;set;}
        @AuraEnabled public	String	nama_agen	{get;set;}
        @AuraEnabled public	String	nama_ibu_kandung	{get;set;}
        @AuraEnabled public	String	nama_lengkap	{get;set;}
        @AuraEnabled public	String	nama_merchant	{get;set;}
        @AuraEnabled public	String	nomor_kartu_debit	{get;set;}
        @AuraEnabled public	String	nomor_kontak_pab	{get;set;}
        @AuraEnabled public	String	nomor_ktp	{get;set;}
        @AuraEnabled public	String	nomor_rekening	{get;set;}
        @AuraEnabled public	String	nomor_rekening_pelimpahan	{get;set;}
        @AuraEnabled public	String	nomor_rekening_pinjaman	{get;set;}
        @AuraEnabled public	String	nomor_siup	{get;set;}
        @AuraEnabled public	String	pic_uker	{get;set;}
        @AuraEnabled public	String	region_office_pengelola	{get;set;}
        @AuraEnabled public	String	sharing_fee	{get;set;}
        @AuraEnabled public	String	status	{get;set;}
        @AuraEnabled public	String	tanggal_dibuat	{get;set;}
        @AuraEnabled public	String	tanggal_lahir	{get;set;}
        @AuraEnabled public	String	tanggal_modifikasi	{get;set;}
        @AuraEnabled public	String	telepon	{get;set;}
    }

    public class BRILinkProfileResponse{
        @AuraEnabled public	List<BRILinkProfile>	BRILINK_PROFILE	{get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class BRILinkProfileRequest{
        @AuraEnabled public	String	tid	{get;set;}
        @AuraEnabled public	String	mid	{get;set;}
    }

    public class MerchantProfile{
        @AuraEnabled public	String	cifno	{get;set;}
        @AuraEnabled public	String	tid	{get;set;}
        @AuraEnabled public	String	mid	{get;set;}
        @AuraEnabled public	String	alamat_merchant	{get;set;}
        @AuraEnabled public	String	channel_merchant	{get;set;}
        @AuraEnabled public	String	code_reffnum	{get;set;}
        @AuraEnabled public	String	data_promo	{get;set;}
        @AuraEnabled public	String	detail	{get;set;}
        @AuraEnabled public	String	detail_edc	{get;set;}
        @AuraEnabled public	String	email	{get;set;}
        @AuraEnabled public	String	jenis_merchant	{get;set;}
        @AuraEnabled public	String	jenis_usaha_merchant	{get;set;}
        @AuraEnabled public	String	kantor_wilayah	{get;set;}
        @AuraEnabled public	String	kanwil	{get;set;}
        @AuraEnabled public	String	kode_unit_kerja	{get;set;}
        @AuraEnabled public	String	mcc_master	{get;set;}
        @AuraEnabled public	String	mcc_npg	{get;set;}
        @AuraEnabled public	String	mcc_visa	{get;set;}
        @AuraEnabled public	String	mdr_debit_npg	{get;set;}
        @AuraEnabled public	String	mdr_debit_pl	{get;set;}
        @AuraEnabled public	String	mdr_mastercard	{get;set;}
        @AuraEnabled public	String	mdr_offus	{get;set;}
        @AuraEnabled public	String	mdr_onus	{get;set;}
        @AuraEnabled public	String	mdr_unik	{get;set;}
        @AuraEnabled public	String	modifikasi_oleh	{get;set;}
        @AuraEnabled public	String	nama_merchant_edc	{get;set;}
        @AuraEnabled public	String	nama_merchant_qris	{get;set;}
        @AuraEnabled public	String	nama_pic_unit_kerja	{get;set;}
        @AuraEnabled public	String	no_batch	{get;set;}
        @AuraEnabled public	String	nomor_rekening_penampungan	{get;set;}
        @AuraEnabled public	String	nomor_telepon_merchant	{get;set;}
        @AuraEnabled public	String	perangkat	{get;set;}
        @AuraEnabled public	String	pic_merchant	{get;set;}
        @AuraEnabled public	String	pn_pic_unit_kerja	{get;set;}
        @AuraEnabled public	String	rc	{get;set;}
        @AuraEnabled public	String	regional_office_pengelola	{get;set;}
        @AuraEnabled public	String	status_pemasangan	{get;set;}
        @AuraEnabled public	String	status_ticket	{get;set;}
        @AuraEnabled public	String	tanggal_dibuat	{get;set;}
        @AuraEnabled public	String	tanggal_modifikasi_terakhir	{get;set;}
        @AuraEnabled public	String	tanggal_pasang	{get;set;}
        @AuraEnabled public	String	tanggal_update_data	{get;set;}
        @AuraEnabled public	String	telpon	{get;set;}
        @AuraEnabled public	String	tipe	{get;set;}
        @AuraEnabled public	String	tipe_merchant	{get;set;}
        @AuraEnabled public	String	user_pemrakarsa	{get;set;}
        @AuraEnabled public	String	vendor_pemasang	{get;set;}
    }

    public class MerchantProfileResposne{
        @AuraEnabled public	List<MerchantProfile>	MERCHANT_PROFILE	{get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class MerchantProfileRequest{
        @AuraEnabled public	String	tid	{get;set;}
        @AuraEnabled public	String	mid	{get;set;}
    }

    public class SI_DPLK{
        @AuraEnabled public	String	alamat_email	{get;set;}
        @AuraEnabled public	String	anggota_korporat_individu	{get;set;}
        @AuraEnabled public	String	cif_dplk	{get;set;}
        @AuraEnabled public	String	iuran	{get;set;}
        @AuraEnabled public	String	jenis_investasi	{get;set;}
        @AuraEnabled public	String	kantor_pembukaan_cabang	{get;set;}
        @AuraEnabled public	String	nama_nasabah	{get;set;}
        @AuraEnabled public	String	no_pegawai_korporat	{get;set;}
        @AuraEnabled public	String	nomor_akun_dplk	{get;set;}
        @AuraEnabled public	String	nomor_handphone	{get;set;}
        @AuraEnabled public	String	pengalihan	{get;set;}
        @AuraEnabled public	String	pengembangan	{get;set;}
        @AuraEnabled public	String	sistem_pembayaran_iuran	{get;set;}
        @AuraEnabled public	String	status_dplk	{get;set;}
        @AuraEnabled public	String	tanggal_lahir	{get;set;}
        @AuraEnabled public	String	tgl_registrasi	{get;set;}
        @AuraEnabled public	String	total_saldo	{get;set;}
        @AuraEnabled public	String	nomor_kartu_dplk	{get;set;}
        @AuraEnabled public	String	nomor_rekening_bri	{get;set;}
        @AuraEnabled public	String	nik	{get;set;}
        @AuraEnabled public	String	cifno	{get;set;}
    }

    public class TRX_DPLK{
        @AuraEnabled public	String	branch_code	{get;set;}
        @AuraEnabled public	String	id_transaksi	{get;set;}
        @AuraEnabled public	String	iscommited	{get;set;}
        @AuraEnabled public	String	keterangan	{get;set;}
        @AuraEnabled public	String	kode_jenis_transaksi	{get;set;}
        @AuraEnabled public	String	nama_nasabah	{get;set;}
        @AuraEnabled public	String	nama_transaksi	{get;set;}
        @AuraEnabled public	String	nomor_handphone	{get;set;}
        @AuraEnabled public	String	tanggal_transaksi	{get;set;}
        @AuraEnabled public	String	nomor_kartu_dplk	{get;set;}
        @AuraEnabled public	String	no_rekening	{get;set;}
        @AuraEnabled public	String	nik	{get;set;}
        @AuraEnabled public	String	cifno	{get;set;}
    }

    public class DPLKResponse{
        @AuraEnabled public	List<SI_DPLK>	SI_DPLK	{get;set;}
        @AuraEnabled public	List<TRX_DPLK>	TRX_DPLK	{get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class DPLKRequest{
        @AuraEnabled public	String	idNumber	{get;set;}
        @AuraEnabled public	String	acctNo	{get;set;}
    }

    public class CardActivityData{
        @AuraEnabled public String tanggal {get;set;}
        @AuraEnabled public String jam {get;set;}
        @AuraEnabled public String noRekening {get;set;}
        @AuraEnabled public String noKartu {get;set;}
        @AuraEnabled public String noHandphone {get;set;}
        @AuraEnabled public String groupFitur {get;set;}
        @AuraEnabled public String fiturId {get;set;}
        @AuraEnabled public String namaFitur {get;set;}
        @AuraEnabled public String channelId {get;set;}
        @AuraEnabled public String tellerId {get;set;}
        @AuraEnabled public String terminalId {get;set;}
        @AuraEnabled public String amount {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String journalSeq {get;set;}
    }

    public class CardActivityResponse{
        @AuraEnabled public Integer statusCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public List<String> errors {get;set;}
        @AuraEnabled public List<CardActivityData> data {get;set;}
    }

    public class CardActivityRequest{
        @AuraEnabled public String posisiawal {get;set;}
        @AuraEnabled public String posisiakhir {get;set;}
        @AuraEnabled public Integer fitur {get;set;}
        @AuraEnabled public String nomor {get;set;}
        @AuraEnabled public Integer scope {get;set;}
    }

    public class PCTDdata{
        @AuraEnabled public String detailTransaksi {get;set;}
        @AuraEnabled public String tanggalTransaksi {get;set;}
        @AuraEnabled public String waktuTransaksi {get;set;}
        @AuraEnabled public String nominalTransaksi {get;set;}
        @AuraEnabled public String keteranganTransaksi {get;set;}
        @AuraEnabled public String approvalCode {get;set;}
        @AuraEnabled public String tanggalPostingTransaksi {get;set;}
        @AuraEnabled public String kodeTransaksi {get;set;}
        @AuraEnabled public String refferenceNumber {get;set;}
        @AuraEnabled public String akumulasiJumlahTransaksi {get;set;}
        @AuraEnabled public String tanggalPostingTagihan {get;set;}
        @AuraEnabled public String deskripsiTransaksi {get;set;}
        @AuraEnabled public String tanggalTransaksiMenggantung {get;set;}
        @AuraEnabled public String nominalTransaksiMenggantung {get;set;}
        @AuraEnabled public String waktuSisaPenagihanMerchant {get;set;}
        @AuraEnabled public String jenisTransaksi {get;set;}
    }

    public class PCTDResponse{
        @AuraEnabled public List<PCTDdata> CPAHF {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class PCTDRequest{
        @AuraEnabled public String cardNumber {get;set;}
    }

    public class CardApplicationData{
        @AuraEnabled public String namaNasabahLengkap {get;set;}
        @AuraEnabled public String nik {get;set;}
        @AuraEnabled public String tanggalLahir {get;set;}
        @AuraEnabled public String nomorAplikasiPengajuan {get;set;}
        @AuraEnabled public String tanggalPengajuan {get;set;}
        @AuraEnabled public String channelPengajuan {get;set;}
        @AuraEnabled public String nomorKartuKredit {get;set;}
        @AuraEnabled public String progressPengajuan {get;set;}
    }

    public class CardApplicationResponse{
        @AuraEnabled public List<CardApplicationData> CUSTPERSONAL {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class CardApplicationRequest{
        @AuraEnabled public String idNumber {get;set;}
    }

    public class BRIMolaTrxData{
        @AuraEnabled public String agenName {get;set;}
        @AuraEnabled public String biayaAdmin {get;set;}
        @AuraEnabled public String hargaTabung {get;set;}
        @AuraEnabled public String jenisPembayaran {get;set;}
        @AuraEnabled public String jumlahTabung {get;set;}
        @AuraEnabled public String noBriva {get;set;}
        @AuraEnabled public String orderId {get;set;}
        @AuraEnabled public String pangkalanName {get;set;}
        @AuraEnabled public String statusBayar {get;set;}
        @AuraEnabled public String tanggalOrder {get;set;}
        @AuraEnabled public String totalHarga {get;set;}
    }

    public class BRIMolaTrx{
        @AuraEnabled public List<BRIMolaTrxData> data {get;set;}
    }

    public class BRIMolaData{
        @AuraEnabled public String agenAlamat {get;set;}
        @AuraEnabled public String agenId {get;set;}
        @AuraEnabled public String agenName {get;set;}
        @AuraEnabled public String agenNorek {get;set;}
        @AuraEnabled public String corpBriva {get;set;}
        @AuraEnabled public String corpClientBriva {get;set;}
        @AuraEnabled public String pangkalanName {get;set;}
        @AuraEnabled public String pangkalanId {get;set;}
        @AuraEnabled public BRIMolaTrx BrilinkTrxByIdKeagenan {get;set;}
    }

    public class BRIMolaIdPangkalan{
        @AuraEnabled public BRIMolaData data {get;set;} //List<BRIMolaData> data {get;set;}
        @AuraEnabled public String rc {get;set;}
        @AuraEnabled public String descr {get;set;}
    }

    public class BRIMolaInquiry{
        @AuraEnabled public BRIMolaIdPangkalan inquiryBrimolaPangkalan {get;set;}
    }

    public class BRIMolaResponse{
        @AuraEnabled public BRIMolaInquiry chmGraphql {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }
    
    public class BRIMolaRequest{
        @AuraEnabled public String idPangkalan {get;set;}
        @AuraEnabled public String startDate {get;set;}
        @AuraEnabled public String endDate {get;set;}
    }

    public class CardHistoryData{
        @AuraEnabled public String accNo {get;set;}
        @AuraEnabled public String activeDate {get;set;}
        @AuraEnabled public String blockDate {get;set;}
        @AuraEnabled public String branchCode {get;set;}
        @AuraEnabled public String cardNo {get;set;}
        @AuraEnabled public String cardStatus {get;set;}
        @AuraEnabled public String expDate {get;set;}
        @AuraEnabled public String issueDate {get;set;}
        @AuraEnabled public String lastMaint {get;set;}
        @AuraEnabled public String mbNo {get;set;}
        @AuraEnabled public String mbStatus {get;set;}
        @AuraEnabled public String renewalDate {get;set;}
        @AuraEnabled public String typeCode {get;set;}
        @AuraEnabled public String userBlock {get;set;}
    }

    public class CardHistoryResponseData{
        @AuraEnabled public List<CardHistoryData> data {get;set;}
    }

    public class CardHistoryAccount{
        @AuraEnabled public CardHistoryResponseData responseData {get;set;}
    }

    public class CardData{
        @AuraEnabled public String accNo {get;set;}
        @AuraEnabled public String cardNo {get;set;}
        @AuraEnabled public String type {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String activeDate {get;set;}
        @AuraEnabled public String expDate {get;set;}
        @AuraEnabled public String issueDate {get;set;}
        @AuraEnabled public String cardStatus {get;set;}
        @AuraEnabled public String lastMaint {get;set;}
        @AuraEnabled public String userMaint {get;set;}
        @AuraEnabled public String statusDesc {get;set;}
        @AuraEnabled public String blockDate {get;set;}
        @AuraEnabled public String userBlock {get;set;}
        @AuraEnabled public CardHistoryAccount historyAccount {get;set;}
    }

    public class CardInquiryData{
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseDesc {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public CardData data {get;set;}
    }

    public class CardInquiry{
        @AuraEnabled public CardInquiryData inquiryCardData {get;set;}
    }

    public class CardResponse{
        @AuraEnabled public CardInquiry chmGraphql {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class CardRequest{
        @AuraEnabled public String cardNo {get;set;}
    }

    public class TrxMerchantData{
        @AuraEnabled public String trxDate {get;set;}
        @AuraEnabled public String trxTime {get;set;}
        @AuraEnabled public String midOrMpan {get;set;}
        @AuraEnabled public String tidOrStoreId {get;set;}
        @AuraEnabled public String appCodeReffNum {get;set;}
        @AuraEnabled public String jenisTrx {get;set;}
        @AuraEnabled public Decimal trxAmount {get;set;}
        @AuraEnabled public String mti {get;set;}
        @AuraEnabled public String merchantName {get;set;}

        @AuraEnabled public String noKartuCpan {get;set;}
        @AuraEnabled public String batchNo {get;set;}
        @AuraEnabled public String mdr {get;set;}
        @AuraEnabled public String channelID {get;set;}
        @AuraEnabled public String proccode {get;set;}
        @AuraEnabled public String namaFitur {get;set;}
        @AuraEnabled public String localCrossBorder {get;set;}
        @AuraEnabled public String onUsNotOnUs {get;set;}
        @AuraEnabled public String cardType {get;set;}
        @AuraEnabled public String rc {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public String trxStatus {get;set;}
        @AuraEnabled public String trxType {get;set;}
        @AuraEnabled public String traceNum {get;set;}
        @AuraEnabled public String mcc {get;set;}
        @AuraEnabled public String location {get;set;}
        @AuraEnabled public String address {get;set;}
        @AuraEnabled public String acqBank {get;set;}
        @AuraEnabled public String posEntryMode {get;set;}
        @AuraEnabled public String settleAmount {get;set;}
        @AuraEnabled public String settleDate {get;set;}
        @AuraEnabled public String paymentDate {get;set;}
        @AuraEnabled public String noRekMerchant {get;set;}
        @AuraEnabled public String paymentRemark {get;set;}
        @AuraEnabled public String switchs {get;set;}
    }

    public class TrxMerchantResponse{
        @AuraEnabled public Integer statusCode {get;set;}
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
        @AuraEnabled public List<String> errors {get;set;}
        @AuraEnabled public List<TrxMerchantData> data {get;set;}
    }

    public class TrxMerchantRequest{
        @AuraEnabled public String midOrMpan {get;set;}
        @AuraEnabled public String tidOrStoreId {get;set;}
        @AuraEnabled public String trxDate {get;set;}
        @AuraEnabled public String trxTime {get;set;}
        @AuraEnabled public String appCodeOrReffNum {get;set;}
    }

    public class HoldStatusData{
        @AuraEnabled public String acctNo {get;set;}
        @AuraEnabled public String acctType {get;set;}
        @AuraEnabled public String expdate {get;set;}
        @AuraEnabled public String holdAmt {get;set;}
        @AuraEnabled public String holdBranch {get;set;}
        @AuraEnabled public String holdDate {get;set;}
        @AuraEnabled public String holdRemark {get;set;}
        @AuraEnabled public String holdSeq {get;set;}
        @AuraEnabled public String holdType {get;set;}
        @AuraEnabled public String recordId {get;set;}
    }

    public class HoldStatusResponseData{
        @AuraEnabled public List<HoldStatusData> data {get;set;}
        @AuraEnabled public String errorCode {get;set;}
        @AuraEnabled public String responseCode {get;set;}
        @AuraEnabled public String responseMessage {get;set;}
    }

    public class HoldStatusResponse{
        @AuraEnabled public HoldStatusResponseData inquiryHoldStatus {get;set;}
        @AuraEnabled public String error {get;set;}
        @AuraEnabled public String path {get;set;}
        @AuraEnabled public String code {get;set;}
    }

    public class HoldStatusRequest{
        @AuraEnabled public String acctNo {get;set;}
        @AuraEnabled public String externalId {get;set;}
        @AuraEnabled public String channelId {get;set;}
        @AuraEnabled public String serviceId {get;set;}
        @AuraEnabled public String tellerId {get;set;}
    }
}