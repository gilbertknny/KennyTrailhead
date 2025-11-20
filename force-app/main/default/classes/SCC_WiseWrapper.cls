/**
 * @description       : 
 * @author            : Dwiki Cahyo
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SCC_WiseWrapper {

    //Working Instruction
    public class RequestWorkingInstruction{
        public String search{get;set;}
        public List<String> user {get;set;}
        public Integer page {get;set;}
        public Integer limits {get;set;}
        public String sort_at {get;set;}
        public String sort_by {get;set;}
    }

    public class ResponseWorkingInstruction{
        public String status_code{get;set;}
        public String status_desc {get;set;}
        public String message {get;set;}
        public ResponseListWi data {get;set;}   
        public String errors {get; set;}
        public String request_id {get;set;}
      }   

      public class ResponseListWi{
        public List<ResponseDataWi> data {get;set;}  
     }

     public class ResponseDataWi{
        public String id_knowledge {get;set;}
        public String calltype {get;set;}
        public String user {get;set;}
        public String section {get;set;}
        public String kategori {get;set;}
        public String sub_kategori {get;set;}
        public String modified_date {get;set;}
     }

     //Produk
     public class RequestProduk{
        public String search{get;set;}
        public List<String> produk {get;set;}
        public List<String> jenis_produk{get;set;}
        public Integer page {get;set;}
        public Integer limits {get;set;}
        public String sort_at {get;set;}
        public String sort_by {get;set;}
    }

    public class ResponseProduk{
        public String status_code{get;set;}
        public String status_desc {get;set;}
        public String message {get;set;}
        public ResponseListProduk data {get;set;}   
        public String errors {get; set;}
        public String request_id {get;set;}
    } 

    public class ResponseListProduk {
        public List<ResponseDataProduk> data{get;set;}
    }

    public class ResponseDataProduk{
        public String id {get;set;} 
		public String jenis_produk {get;set;} 
		public String produk {get;set;} 
		public String definisi {get;set;} 
		public String varian_produk {get;set;} 
		public String syarat_pembukaan {get;set;} 
		public String syarat_pencairan_penutupan {get;set;} 
		public String panduan_penggunaan {get;set;} 
		public String bunga {get;set;} 
		public String fitur {get;set;} 
		public String limits {get;set;} // in json: limit
		public String biaya {get;set;} 
		public String image {get;set;} 
		public String modified_date {get;set;} 
        public Integer counter {get;set;}
    }


    //Program
    public class RequestProgram{
        public String search {get; set;}
        public Object start_date {get;set;} 
        public Object end_date {get;set;} 
        public Integer page {get;set;} 
        public Integer limits {get;set;} // in json: limit
        public String sort_at {get;set;} 
        public String sort_by {get;set;} 
    }

    public class ResponseProgram{
        public String status_code{get;set;}
        public String status_desc {get;set;}
        public String message {get;set;}
        public ResponseListProgram data {get;set;}   
        public String errors {get; set;}
        public String request_id {get;set;}
    }
    
    public class ResponseListProgram{
        public List<ResponseDataProgram> data {get; set;}
    }

    public class ResponseDataProgram{
        public String id_knowledge {get; set;}	
		public String nama {get; set;}	
		public String deskripsi {get; set;}	 
		public String benefit {get; set;}
        public String syarat_ketentuan {get; set;}
        public String start {get; set;}	
		public String ends {get; set;}	
		public String modified_date {get; set;}
    }

    //Promo
    public class RequestPromo{
        public String search {get; set;}
        public List<Integer> kategori {get; set;}
        public List<Integer> channel {get; set;}
        public Integer page {get;set;} 
        public Integer limits {get;set;} 
        public String sort_at {get;set;} 
        public String sort_by {get;set;} 
    }

    public class ResponsePromo {
        public String status_code{get;set;}
        public String status_desc {get;set;}
        public String message {get;set;}
        public ResponseListPromo data {get;set;}   
        public String errors {get; set;}
        public String request_id {get;set;}
    }

    public class ResponseListPromo{
        public List<ResponseDataPromo> data {get; set;}
    }

    public class ResponseDataPromo{
        public String id_knowledge {get; set;}
		public String kategori {get;set;}	
		public String merchant {get;set;}	
		public String channel {get;set;}
        public String benefit_program {get; set;}
        public String syarat_dan_ketentuan {get;set;}
        public String start {get;set;}	
		public String ends {get;set;}	
		public String modified_date {get;set;}
    }

    //Lookup WI
    public class ResponseWiLookup{
        public String status_code{get;set;}
        public String status_desc {get;set;}
        public String message {get;set;}
        public ResponseDataWiLookup data {get;set;}   
        public String errors {get; set;}
        public String request_id {get;set;}
        public String deskripsi {get; set;}	 // update 11 September di hilangkan
    }

     public class ResponseDataWiLookup {
        public String id {get;set;}
        public String user {get;set;}
        public String calltype {get;set;}
        public String section {get;set;}
        public String kategori {get;set;}
        public String sub_kategori {get;set;}
        public ContentWi content {get;set;}
        public String reaction {get;set;}
     }

     public class ContentWi {
        public String greeting {get;set;}	
        public String empati {get;set;}	
        public String konfirmasi {get;set;}	
        public String verifikasi {get;set;}	
        public String cek_laporan {get;set;}	
        public String gali_informasi {get;set;}	
        public String pembuatan_laporan {get;set;}	
        public String solusi {get;set;}	
        public String konfirmasi_ulang {get;set;}	
        public String edukasi_cross_selling {get;set;}	
        public String closing {get;set;}
     }

     //Lookup Produk
     public class ResponseProdukLookup{
        @AuraEnabled
        public String status_code{get;set;}
        @AuraEnabled
        public String status_desc {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public ResponseDataProdukLookup data {get;set;}  
        @AuraEnabled
        public String errors {get; set;}
        @AuraEnabled
        public String request_id {get;set;}
    }

     public class ResponseDataProdukLookup {
        @AuraEnabled
        public String biaya {get;set;}
        @AuraEnabled
        public String bunga {get;set;}
		@AuraEnabled
        public String limits {get;set;}
		@AuraEnabled
        public List<Table> biaya_table{get;set;}
		@AuraEnabled
        public List<Table> bunga_table{get;set;}
		@AuraEnabled
        public String definisi {get;set;}
		@AuraEnabled
        public String fitur {get;set;}
		@AuraEnabled
        public String id {get;set;}
		@AuraEnabled
        public String jenis_produk {get;set;}
		@AuraEnabled
        public List<Table> limits_table{get;set;}
        @AuraEnabled
        public List<DataImage> image {get;set;}
        @AuraEnabled
        public String panduan_penggunaan {get;set;}
        @AuraEnabled
        public String produk {get;set;}
        @AuraEnabled
        public String syarat_pembukaan {get;set;}
        @AuraEnabled
        public String syarat_pencairan_penutupan {get;set;}
        @AuraEnabled
        public String varian_produk {get;set;}
        @AuraEnabled
        public Boolean bunga_flag {get;set;}
        @AuraEnabled
        public Boolean limits_flag {get;set;}
        @AuraEnabled
        public Boolean biaya_flag {get;set;}
     }

     //Lookup Program
     public class ResponseProgramLookup{
        @AuraEnabled
        public String status_code{get;set;}
        @AuraEnabled
        public String status_desc {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public ResponseDataProgramLookup data {get;set;}   
        @AuraEnabled
        public String errors {get; set;}
        @AuraEnabled
        public String request_id {get;set;}
    }

     public class ResponseDataProgramLookup {
        @AuraEnabled
        public String id {get; set;}	
		@AuraEnabled
        public String nama {get; set;}	
		@AuraEnabled
        public String deskripsi {get; set;}	 
		@AuraEnabled
        public String benefit {get; set;}
        @AuraEnabled
        public List<DataImage> image {get;set;}
        @AuraEnabled
        public String syarat_ketentuan {get; set;}
        @AuraEnabled
        public String start {get; set;}	
		@AuraEnabled
        public String ends {get; set;}	
    }

    //Lookup Promo
    public class ResponsePromoLookup{
        @AuraEnabled
        public String status_code{get;set;}
        @AuraEnabled
        public String status_desc {get;set;}
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public ResponseDataPromoLookup data {get;set;} 
        @AuraEnabled
        public String errors {get; set;}
        @AuraEnabled
        public String request_id {get;set;}
    }

    public class ResponseDataPromoLookup {
        @AuraEnabled
        public String benefit {get;set;}
        @AuraEnabled
        public List<Table> benefit_table{get;set;}
        @AuraEnabled
        public Boolean benefit_flag {get;set;}
        @AuraEnabled
        public List<String> channel {get;set;}
        @AuraEnabled
        public String ends {get;set;}
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public List<DataImage> image {get;set;}
        @AuraEnabled
        public String kategori {get;set;}
        @AuraEnabled
        public String lokasi {get;set;}
        @AuraEnabled
        public String merchant {get;set;}
        @AuraEnabled
        public String start {get;set;}
        @AuraEnabled
        public String syarat_dan_ketentuan {get;set;}
        @AuraEnabled
        public List<Table> syarat_dan_ketentuan_table {get;set;}
        @AuraEnabled
        public Boolean syarat_dan_ketentuan_flag {get;set;}
    }


    public class Table{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public List<List<TableData>> table_data {get;set;}

    }

    public class TableData {
        @AuraEnabled
        public String key {get;set;}
        @AuraEnabled
        public String value { get; set; }
		@AuraEnabled
        public Integer row_span { get; set; }
		@AuraEnabled
        public Integer col_span { get; set; }
    }

    
    public class DataImage {
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String size {get;set;}
        @AuraEnabled
        public String url {get;set;}
    }

}