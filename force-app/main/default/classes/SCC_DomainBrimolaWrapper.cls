/**
 * @description SCC_DomainBrimolaWrapper is a wrapper class for handling domain data related to Brimola.
 *              It includes inner classes representing different aspects of Brimola data.
 */
public without sharing class SCC_DomainBrimolaWrapper {

    /**
     * @description Inner class representing ChmGraphql data
     */
    @AuraEnabled
    public ChmGraphql chmGraphql { get; set; }

    /**
     * @description Inner class representing different aspects of Brimola data
     */
    public class ChmGraphql {
        /**
         * @description inquiryBrimolaPangkalan
         */
        @AuraEnabled
        public InquiryBrimolaPangkalan inquiryBrimolaPangkalan { get; set; }
    }

    /**
     * @description Inner class representing inquiry data related to Brimola Pangkalan
     */
    public class InquiryBrimolaPangkalan {
        /**
         * @description Data related to Brimola Pangkalan
         */
        @AuraEnabled
        public Data data { get; set; }
    }

    /**
     * @description Inner class representing data structure for Brimola inquiry
     */
    public class Data { 
        /**
         * @description Brilink transactions by agent
         */
        @AuraEnabled
        public BrilinkTrxByIdKeagenan BrilinkTrxByIdKeagenan { get; set; }
        /**
         * @description Pangkalan ID
         */
        @AuraEnabled
        public String pangkalanId { get; set; } 
        /**
         * @description Pangkalan name
         */
        @AuraEnabled
        public String pangkalanName { get; set; } 
        /**
         * @description Corporate client BRIVA
         */
        @AuraEnabled
        public String corpClientBriva { get; set; }  
        /**
         * @description Corporate BRIVA
         */
        @AuraEnabled
        public String corpBriva { get; set; } 
        /**
         * @description Agent account number
         */
        @AuraEnabled
        public String agenNorek { get; set; } 
        /**
         * @description Agent name
         */
        @AuraEnabled
        public String agenName { get; set; } 
        /**
         * @description Agent ID
         */
        @AuraEnabled
        public String agenId { get; set; } 
        /**
         * @description Agent address
         */
        @AuraEnabled
        public String agenAlamat { get; set; }
    }

    /**
     * @description Inner class representing Brilink transaction data
     */

    public class BrilinkTrxByIdKeagenan {
        /**
         * @description List of Brilink transactions
         */
        @AuraEnabled
        public List<BrilinkTrx> data { get; set; }
    }

    /**
     * @description Inner class representing Brilink transaction details
     */

    public class BrilinkTrx {
        /**
         * @description Total price
         */
        @AuraEnabled
        public String totalHarga { get; set; }
        /**
         * @description Order date
         */
        @AuraEnabled
        public String tanggalOrder { get; set; }
        /**
         * @description Payment status
         */
        @AuraEnabled
        public String statusBayar { get; set; }
        /**
         * @description Pangkalan name
         */
        @AuraEnabled
        public String pangkalanName { get; set; }
        /**
         * @description Order ID
         */
        @AuraEnabled
        public String orderId { get; set; }
        /**
         * @description BRIVA number
         */
        @AuraEnabled
        public String noBriva { get; set; }
        /**
         * @description Number of cylinders
         */
        @AuraEnabled
        public String jumlahTabung { get; set; }
        /**
         * @description Payment type
         */
        @AuraEnabled
        public String jenisPembayaran { get; set; }
        /**
         * @description Cylinder price
         */
        @AuraEnabled
        public String hargaTabung { get; set; }
        /**
         * @description Administrative fee
         */
        @AuraEnabled
        public String biayaAdmin { get; set; }
        /**
         * @description Agent name
         */
        @AuraEnabled
        public String agenName { get; set; }
    }

    /**
     * @description Method to parse JSON string into SCC_DomainBrimolaWrapper object.
     * 
     * @param jsonString The JSON string to parse.
     * @return SCC_DomainBrimolaWrapper object parsed from JSON.
     */
    public static SCC_DomainBrimolaWrapper parse(String jsonString) {
        return (SCC_DomainBrimolaWrapper) System.JSON.deserialize(jsonString, SCC_DomainBrimolaWrapper.class);
    }
}