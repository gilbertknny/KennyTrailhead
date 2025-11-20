@istest
public with sharing class Object_Test_Wise {
    public static SCC_WiseWrapper.RequestWorkingInstruction requestWi(){
        SCC_WiseWrapper.RequestWorkingInstruction req = new SCC_WiseWrapper.RequestWorkingInstruction();
        req.limits = 1;
        req.page = 1;
        req.search = '';
        req.sort_at = 'desc';
        req.sort_by = 'modified_date';
        req.user = new List<String>{};
        return req;
    }

    public static SCC_WiseWrapper.RequestProduk requestProduk(){
        SCC_WiseWrapper.RequestProduk reqProduk = new SCC_WiseWrapper.RequestProduk();
        reqProduk.limits = 1;
        reqProduk.page = 1;
        reqProduk.search = '';
        reqProduk.sort_at = 'desc';
        reqProduk.sort_by = 'modified_date';
        reqProduk.produk = new List<String>{};
        reqProduk.jenis_produk = new List<String>{};
        return reqProduk;
    }

    public static SCC_WiseWrapper.RequestPromo requestPromo(){
        SCC_WiseWrapper.RequestPromo reqPromo = new SCC_WiseWrapper.RequestPromo();
        reqPromo.limits = 1;
        reqPromo.page = 1;
        reqPromo.search = '';
        reqPromo.sort_at = 'desc';
        reqPromo.sort_by = 'modified_date';
        reqPromo.kategori = new List<Integer>{};
        reqPromo.channel = new List<Integer>{};
        return reqPromo;
    }

    public static SCC_WiseWrapper.RequestProgram requestProgram(){
        SCC_WiseWrapper.RequestProgram reqProgram = new SCC_WiseWrapper.RequestProgram();
        reqProgram.limits = 1;
        reqProgram.page = 1;
        reqProgram.search = '';
        reqProgram.sort_at = 'desc';
        reqProgram.sort_by = 'modified_date';
        reqProgram.start_date = null;
        reqProgram.end_date = null;
        return reqProgram;
    }

    public static SCC_WiseWrapper.ResponseWorkingInstruction responseWi(){

        SCC_WiseWrapper.ResponseDataWi data1 = ResponseWorkingInstructionData('001', '1000', 'cs', 'Banking', 'ceria', 'sub-ceria', '2024-06-27T10:00:00+07:00');
        SCC_WiseWrapper.ResponseDataWi data2 = ResponseWorkingInstructionData('002', '2000', 'cs', 'Banking', 'ceria', 'sub-ceria', '2024-06-26T10:00:00+07:00');
        
    
        List<SCC_WiseWrapper.ResponseDataWi> listData = new List<SCC_WiseWrapper.ResponseDataWi>();
        listData.add(data1);
        listData.add(data2);
        

        SCC_WiseWrapper.ResponseListWi responseListWi = new SCC_WiseWrapper.ResponseListWi();
        responseListWi.data = listData;
        
    
        SCC_WiseWrapper.ResponseWorkingInstruction response = new SCC_WiseWrapper.ResponseWorkingInstruction();
        response.status_code = '200';
        response.status_desc = 'Success';
        response.message = 'Data retrieved successfully';
        response.errors = null;
        response.request_id = '123456789';
        response.data = responseListWi;
        
        return response;

    }

    public static SCC_WiseWrapper.ResponseDataWi responseWorkingInstructionData(String idKnowledge, String calltype, String user, String section, String kategori, String sub_kategori, String modifiedDate) {
        SCC_WiseWrapper.ResponseDataWi data = new SCC_WiseWrapper.ResponseDataWi();
        data.id_knowledge = idKnowledge;
        data.calltype = calltype;
        data.user = user;
        data.section = section;
        data.kategori = kategori;
        data.sub_kategori = sub_kategori;
        data.modified_date = modifiedDate;
        return data;
    }
    
    public static SCC_WiseWrapper.ResponseProduk responseProduk(){
        SCC_WiseWrapper.ResponseDataProduk data1 = ResponseProdukData('001', 'jenis1', 'produk1', 'definisi1', 'varian1', 'syarat1', 'penutupan1', 'panduan1', 'bunga1', 'fitur1', 'limit1', 'biaya1', 'image1', '2024-06-27T10:00:00+07:00', 1);
        SCC_WiseWrapper.ResponseDataProduk data2 = ResponseProdukData('002', 'jenis2', 'produk2', 'definisi2', 'varian2', 'syarat2', 'penutupan2', 'panduan2', 'bunga2', 'fitur2', 'limit2', 'biaya2', 'image2', '2024-06-27T10:00:00+07:00', 2);

        List<SCC_WiseWrapper.ResponseDataProduk> listData = new List<SCC_WiseWrapper.ResponseDataProduk>();
        listData.add(data1);
        listData.add(data2);

        SCC_WiseWrapper.ResponseListProduk responseListProduk = new SCC_WiseWrapper.ResponseListProduk();
        responseListProduk.data = listData;

        SCC_WiseWrapper.ResponseProduk response = new SCC_WiseWrapper.ResponseProduk();
        response.status_code = '200';
        response.status_desc = 'Success';
        response.message = 'Data retrieved successfully';
        response.errors = null;
        response.request_id = '123456789';
        response.data = responseListProduk;

        return response;
    }

    public static SCC_WiseWrapper.ResponseDataProduk responseProdukData(String id, String jenis_produk, String produk, String definisi, String varian_produk, String syarat_pembukaan, String syarat_pencairan_penutupan, String panduan_penggunaan, String bunga, String fitur, String limits, String biaya, String image, String modifiedDate, Integer counter){
        SCC_WiseWrapper.ResponseDataProduk data = new SCC_WiseWrapper.ResponseDataProduk();
        data.id = id;
        data.jenis_produk = jenis_produk;
        data.produk = produk;
        data.definisi = definisi;
        data.varian_produk = varian_produk;
        data.syarat_pembukaan = syarat_pembukaan;
        data.syarat_pencairan_penutupan = syarat_pencairan_penutupan;
        data.panduan_penggunaan = panduan_penggunaan;
        data.bunga = bunga;
        data.fitur = fitur;
        data.limits = limits;
        data.biaya = biaya;
        data.image = image;
        data.modified_date = modifiedDate;
        data.counter = counter;
        return data;
    }

    public static SCC_WiseWrapper.ResponseProgram responseProgram(){
        SCC_WiseWrapper.ResponseDataProgram data1 = responseProgramData('0001', 'program', 'deskripsi', 'benefits', 'syarat_ketentuan', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0');
        SCC_WiseWrapper.ResponseDataProgram data2 = responseProgramData('0002', 'program', 'deskripsi', 'benefits', 'syarat_ketentuan', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0');

        List<SCC_WiseWrapper.ResponseDataProgram> listData =new List<SCC_WiseWrapper.ResponseDataProgram>();
        listData.add(data1);
        listData.add(data2);

        SCC_WiseWrapper.ResponseListProgram responseListProgram = new SCC_WiseWrapper.ResponseListProgram();
        responseListProgram.data = listData;

        SCC_WiseWrapper.ResponseProgram response = new SCC_WiseWrapper.ResponseProgram();
        response.status_code = '200';
        response.status_desc = 'Success';
        response.message = 'Data retrieved successfully';
        response.errors = null;
        response.request_id = '123456789';
        response.data = responseListProgram;

        return response;
    }

    public static SCC_WiseWrapper.ResponseDataProgram responseProgramData(String id_knowledge, String nama, String deskripsi, String benefit, String syarat_ketentuan,String start, String ends, String modified_date ){
        SCC_WiseWrapper.ResponseDataProgram data = new SCC_WiseWrapper.ResponseDataProgram();
        data.id_knowledge = id_knowledge;
        data.nama = nama;
        data.deskripsi = deskripsi;
        data.benefit = benefit;
        data.syarat_ketentuan = syarat_ketentuan;
        data.start = start;
        data.ends = ends;
        data.modified_date = modified_date;
        return data;
    }

    public static SCC_WiseWrapper.ResponsePromo responsePromo(){
        SCC_WiseWrapper.ResponseDataPromo data1 = responsePromoData('001', 'kategori', 'merchant', 'channel', 'benefit', 'sk', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0');
        SCC_WiseWrapper.ResponseDataPromo data2 = responsePromoData('002', 'kategori', 'merchant', 'channel', 'benefit', 'sk', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0', '2024-06-27T10:00:00+07:0');

        List<SCC_WiseWrapper.ResponseDataPromo> listData = new List<SCC_WiseWrapper.ResponseDataPromo>();
        listData.add(data1);
        listData.add(data2);

        SCC_WiseWrapper.ResponseListPromo responseListPromo = new SCC_WiseWrapper.ResponseListPromo();
        responseListPromo.data = listData;

        SCC_WiseWrapper.ResponsePromo response = new SCC_WiseWrapper.ResponsePromo();
        response.status_code = '200';
        response.status_desc = 'Success';
        response.message = 'Data retrieved successfully';
        response.errors = null;
        response.request_id = '123456789';
        response.data = responseListPromo;

        return response;
    }
    
    public static SCC_WiseWrapper.ResponseDataPromo responsePromoData(String id_knowledge, String kategori, String merchant, String channel, String benefit_program,String syarat_dan_ketentuan, String start, String ends , String modified_date  ){
        SCC_WiseWrapper.ResponseDataPromo data = new SCC_WiseWrapper.ResponseDataPromo();
        data.id_knowledge = id_knowledge;
        data.kategori = kategori;
        data.merchant = merchant;
        data.channel = channel;
        data.benefit_program = benefit_program;
        data.syarat_dan_ketentuan = syarat_dan_ketentuan;
        data.start = start;
        data.ends = ends;
        data.modified_date = modified_date;
        return data;
    }

    public static SCC_WiseWrapper.ResponseWiLookup responseWiLookup(){
        SCC_WiseWrapper.ResponseWiLookup wiLookup = new SCC_WiseWrapper.ResponseWiLookup();
        wiLookup.deskripsi = 'deskrips';
        wiLookup.errors = null;
        wiLookup.data = responseDataWiLookup();
        wiLookup.message='message';
        wiLookup.request_id='1234';
        wiLookup.status_code='200';
        wiLookup.status_desc = 'descc';
        return wiLookup;

    }

    public static SCC_WiseWrapper.ResponseDataWiLookup responseDataWiLookup(){
        SCC_WiseWrapper.ResponseDataWiLookup dataWi = new SCC_WiseWrapper.ResponseDataWiLookup();
        dataWi.calltype = '1000';
        dataWi.id='123';
        dataWi.content = contentWi();
        dataWi.kategori='kategori';
        dataWi.reaction='reaction';
        dataWi.section='section';
        dataWi.sub_kategori='sub';
        dataWi.user = 'cs';
        return dataWi;
    }

    public static SCC_WiseWrapper.ContentWi contentWi(){
        SCC_WiseWrapper.ContentWi content = new SCC_WiseWrapper.ContentWi();
         content.greeting = 'mock-test';	
         content.empati = 'mock-test';	
         content.konfirmasi = 'mock-test';	
         content.verifikasi = 'mock-test';	
         content.cek_laporan = 'mock-test';	
         content.gali_informasi = 'mock-test';	
         content.pembuatan_laporan = 'mock-test';	
         content.solusi = 'mock-test';	
         content.konfirmasi_ulang = 'mock-test';	
         content.edukasi_cross_selling = 'mock-test';	
         content.closing = 'mock-test';
        return content;
    }

    //produk
    public static SCC_WiseWrapper.ResponseProdukLookup responseProdukLookup(){
        SCC_WiseWrapper.ResponseProdukLookup produkLookup = new SCC_WiseWrapper.ResponseProdukLookup();
        produkLookup.errors = null;
        produkLookup.data = responseDataProdukLookup();
        produkLookup.message='message';
        produkLookup.request_id='1234';
        produkLookup.status_code='200';
        produkLookup.status_desc = 'descc';
        return produkLookup;
    }
    
    public static SCC_WiseWrapper.ResponseDataProdukLookup responseDataProdukLookup(){
        SCC_WiseWrapper.ResponseDataProdukLookup dataProduk = new SCC_WiseWrapper.ResponseDataProdukLookup();
         dataProduk.biaya = '5000';
         //dataProduk.biaya_flag = false;
         dataProduk.bunga = '10';
         //dataProduk.bunga_flag = false;
         dataProduk.definisi = 'definisi';
         dataProduk.fitur = 'fitur';
         dataProduk.id ='123';
         //dataProduk.image ='image';
         dataProduk.jenis_produk ='jenis produk';
         dataProduk.limits ='limit';
         //dataProduk.limit_flag = false;
         dataProduk.panduan_penggunaan ='pandua';
         dataProduk.produk ='produk';
         dataProduk.syarat_pembukaan ='pembukaan';
         dataProduk.syarat_pencairan_penutupan ='penutupan';
         dataProduk.varian_produk ='varian produk';
         return dataProduk;
    }

    //program
    public static SCC_WiseWrapper.ResponseProgramLookup responseProgramLookup(){
        SCC_WiseWrapper.ResponseProgramLookup programLookup = new SCC_WiseWrapper.ResponseProgramLookup();
        programLookup.errors = null;
        programLookup.data = responseDataProgramLookup();
        programLookup.message='message';
        programLookup.request_id='1234';
        programLookup.status_code='200';
        programLookup.status_desc = 'descc';
        return programLookup;

    }

    public static SCC_WiseWrapper.ResponseDataProgramLookup responseDataProgramLookup(){
        SCC_WiseWrapper.ResponseDataProgramLookup dataProgram = new SCC_WiseWrapper.ResponseDataProgramLookup();
         dataProgram.id = '123';	
		 dataProgram.nama = 'nama';	
		 dataProgram.deskripsi = 'deskripsi';	 
		 dataProgram.benefit = 'benefit';
         dataProgram.syarat_ketentuan = 'syarat_ketentuan';
         dataProgram.start = '2024-06-27T10:00:00+07:0'	;
		 dataProgram.ends = '2024-06-27T10:00:00+07:0'	;
         return dataProgram;
    }

    //promo

    public static SCC_WiseWrapper.ResponsePromoLookup responsePromoLookup(){
        SCC_WiseWrapper.ResponsePromoLookup promoLookup = new SCC_WiseWrapper.ResponsePromoLookup();
        promoLookup.errors = null;
        promoLookup.data = responseDatapromoLookup();
        promoLookup.message='message';
        promoLookup.request_id='1234';
        promoLookup.status_code='200';
        promoLookup.status_desc = 'descc';
        return promoLookup;
    }

    public static SCC_WiseWrapper.ResponseDataPromoLookup responseDataPromoLookup(){

        SCC_WiseWrapper.DataImage dataImage = img('name', '10kb', 'www.test.com');

        List<SCC_WiseWrapper.DataImage> listImage = new List<SCC_WiseWrapper.DataImage>();
        listImage.add(dataImage);

        SCC_WiseWrapper.ResponseDataPromoLookup dataPromo = new SCC_WiseWrapper.ResponseDataPromoLookup();
        dataPromo.benefit = 'benefit' ; 
        dataPromo.benefit_flag = true; 
        dataPromo.channel = new List<String>{}; 
        dataPromo.ends ='2024-06-27T10:00:00+07:0' ; 
        dataPromo.id = '123' ; 
        dataPromo.image =  listImage ; 
        dataPromo.kategori = 'kategori' ; 
        dataPromo.lokasi = 'lokasi'; 
        dataPromo.merchant = 'merchant' ; 
        dataPromo.start = '2024-06-27T10:00:00+07:0'; 
        dataPromo.syarat_dan_ketentuan ='ketentuan' ; 
        dataPromo.syarat_dan_ketentuan_flag =true ; 
        return dataPromo;
    }

    public static SCC_WiseWrapper.DataImage img(String name, string size, string url){
        SCC_WiseWrapper.DataImage data = new SCC_WiseWrapper.DataImage();
        data.name = name;
        data.size= size;
        data.url = url;
        return data;
    }
}