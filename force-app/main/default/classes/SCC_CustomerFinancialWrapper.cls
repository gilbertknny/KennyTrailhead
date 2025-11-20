public class SCC_CustomerFinancialWrapper {
        
    public class Demografi {       
    }
 
    public class PortofolioPerbankan {
        @AuraEnabled
        public List<Simpanan> simpanan;
        @AuraEnabled
        public List<Pinjaman> pinjaman;
        @AuraEnabled
        public List<Investasi> investasi;
        @AuraEnabled
        public List<Cardlink> cardlink;
    }

    @AuraEnabled
    public List<Data> data;
    @AuraEnabled
    public Object errors;
    @AuraEnabled
    public String responseMessage;
    @AuraEnabled
    public String responseCode;
    @AuraEnabled
    public String errorCode;
    @AuraEnabled
    public Integer statusCode;

   
    public class Data {
        @AuraEnabled
        public PortofolioPerbankan portofolioPerbankan;
        @AuraEnabled
        public Demografi demografi;
        @AuraEnabled
        public String cifno;
    }

    
    public class Pinjaman {
         
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public String accountNumber; 
    }

    
    public class Simpanan {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public String accountNumber; 
    }

    
    public class Investasi {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
        @AuraEnabled
        public Double balance;
        @AuraEnabled
        public String accountNumber; 
    }

  
    public class Cardlink {
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String productType;
        @AuraEnabled
        public String productDescription;
        @AuraEnabled
        public String product;
        @AuraEnabled
        public String cifno;
    
        @AuraEnabled
        public String cardNumber; 
    }

    public static SCC_CustomerFinancialWrapper parse(String json) {
        if (json == null) {
        	return null;
    	}

        try{
            return (SCC_CustomerFinancialWrapper) System.JSON.deserialize(json, SCC_CustomerFinancialWrapper.class);
        }catch (JSONException e) {
            System.debug('Error parsing JSON: ' + e.getMessage());
            return null; 
    	} 
    }  
}