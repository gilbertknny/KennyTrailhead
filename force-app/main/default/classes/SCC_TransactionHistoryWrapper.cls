/** @description
 * Apex class representing a wrapper for transaction history data.
 */
public without sharing class SCC_TransactionHistoryWrapper {
    
    // Wrapper properties
    @AuraEnabled
    public List<Data> data; // List to hold transaction data
    @AuraEnabled
    public Object errors { get; set; } // Object to hold error information
    @AuraEnabled
    public String responseMessage { get; set; } // Message indicating the response
    @AuraEnabled
    public String responseCode { get; set; } // Code indicating the response
    @AuraEnabled
    public String errorCode { get; set; } // Code indicating errors
    @AuraEnabled
    public Integer statusCode { get; set; } // Status code of the transaction

    // @description Inner class for transaction data
    public class Data {
        @AuraEnabled
        public String kafkaTimestamp { get; set; } // Timestamp from Kafka
        @AuraEnabled
        public String switchValue { get; set; } // Switch value
        @AuraEnabled
        public String trxStatus { get; set; } // Transaction status
        @AuraEnabled
        public String trxType { get; set; } // Type of transaction
        @AuraEnabled
        public String proccode { get; set; } // Processing code
        @AuraEnabled
        public String rc { get; set; } // Response code
        @AuraEnabled
        public String merchantName { get; set; } // Name of the merchant
        @AuraEnabled
        public String mti { get; set; } // Message type identifier
        @AuraEnabled
        public Decimal trxAmount { get; set; } // Transaction amount
        @AuraEnabled
        public String noKartuCpan { get; set; } // Card number
        @AuraEnabled
        public String jenisTrx { get; set; } // Transaction type
        @AuraEnabled
        public String appCodeReffNum { get; set; } // Application code or reference number
        @AuraEnabled
        public String tidOrStoreId { get; set; } // Terminal ID or Store ID
        @AuraEnabled
        public String midOrMpan { get; set; } // Merchant ID or Merchant account number
        @AuraEnabled
        public String trxTime { get; set; } // Transaction time
        @AuraEnabled
        public String trxDate { get; set; } // Transaction date
    }

    /** @description
     * Method to parse JSON string into SCC_TransactionHistoryWrapper object.
     * @param json JSON string to deserialize.
     * @return SCC_TransactionHistoryWrapper instance deserialized from JSON.
     */
    public static SCC_TransactionHistoryWrapper parse(String json) {
        return (SCC_TransactionHistoryWrapper) System.JSON.deserialize(json, SCC_TransactionHistoryWrapper.class);
    }
    
}