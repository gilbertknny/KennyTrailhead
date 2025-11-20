/** @description
 * Apex class representing a wrapper for detailed transaction data.
 */
public without sharing class SCC_DetailTransactionWrapper {
    
   /** @description // List to hold transaction data */
    @AuraEnabled
    public List<Data> data { get; set; } 
     /** @description // Object to hold error information */
    @AuraEnabled
    public Object errors { get; set; } 
     /** @description // Message indicating the responsea */
    @AuraEnabled
    public String responseMessage { get; set; } 
      /** @description // Code indicating the response */
    @AuraEnabled
    public String responseCode { get; set; } 
      /** @description // Code indicating errors*/
    @AuraEnabled
    public String errorCode { get; set; } 
    /** @description // Status code of the transaction*/
    @AuraEnabled
    public Integer statusCode { get; set; } 
  
    /** @description
 *  Inner class for transaction data
 */
    
    public class Data {
        /** @description // Timestamp from Kafka */
        @AuraEnabled
        public String kafkaTimestamp { get; set; } 
       /** @description // Switch value */
        @AuraEnabled
        public String switchValue { get; set; } 
        /** @description // Payment remark */
        @AuraEnabled
        public String paymentRemark { get; set; } 
        /** @description // Merchant account number */
        @AuraEnabled
        public String noRekMerchant { get; set; } 
       /** @description // Date of payment */
        @AuraEnabled
        public String paymentDate { get; set; } 
      /** @description // Date of settlement */
        @AuraEnabled
        public String settleDate { get; set; } 
      /** @description // Amount settled */
        @AuraEnabled
        public Decimal settleAmount { get; set; } 
       /** @description // Point of sale entry mode */
        @AuraEnabled
        public String posEntryMode { get; set; } 
      /** @description // Acquiring bank */
        @AuraEnabled
        public String acqBank { get; set; } 
       /** @description // Address */
        @AuraEnabled
        public String address { get; set; } 
       /** @description // Location*/
        @AuraEnabled
        public String location { get; set; } 
       /** @description // Merchant category code */
        @AuraEnabled
        public String mcc { get; set; } 
        /** @description // Transaction trace number */
        @AuraEnabled
        public String traceNum { get; set; } 
        /** @description // Message type identifier */
        @AuraEnabled
        public String mti { get; set; } 
       /** @description // Transaction type */
        @AuraEnabled
        public String trxType { get; set; } 
       /** @description // Transaction status */
        @AuraEnabled
        public String trxStatus { get; set; } 
      /** @description // Status */
        @AuraEnabled
        public String status { get; set; } 
       /** @description // Response code */
        @AuraEnabled
        public String rc { get; set; } 
        /** @description // Type of card */
        @AuraEnabled
        public String cardType { get; set; } 
         /** @description // On-us or not-on-us */
        @AuraEnabled
        public String onUsNotOnUs { get; set; } 
         /** @description // Local or cross-border*/
        @AuraEnabled
        public String localCrossBorder { get; set; } 
         /** @description  // Feature name */
        @AuraEnabled
        public String namaFitur { get; set; }
         /** @description // Processing code */
        @AuraEnabled
        public String proccode { get; set; } 
        /** @description // Channel ID*/
        @AuraEnabled
        public String channelID { get; set; } 
       /** @description // Merchant discount rate */
        @AuraEnabled
        public String mdr { get; set; } 
        /** @description // Transaction amount */
        @AuraEnabled
        public Integer trxAmount { get; set; } 
       /** @description // Transaction type */
        @AuraEnabled
        public String jenisTrx { get; set; } 
        /** @description // Batch number */
        @AuraEnabled
        public String batchNo { get; set; } 
         /** @description  // Application code or reference number */
        @AuraEnabled
        public String appCodeReffNum { get; set; }
         /** @description // Name of the merchant */
        @AuraEnabled
        public String merchantName { get; set; } 
         /** @description // Terminal ID or Store ID */
        @AuraEnabled
        public String tidOrStoreId { get; set; } 
       /** @description // Merchant ID or Merchant account number */
        @AuraEnabled
        public String midOrMpan { get; set; } 
        /** @description // Card number */
        @AuraEnabled
        public String noKartuCpan { get; set; } 
        /** @description // Transaction time */
        @AuraEnabled
        public String trxTime { get; set; } 
         /** @description // Transaction date */
        @AuraEnabled
        public String trxDate { get; set; } 
       
    }
 /** @description
     * // Method to parse JSON string into SCC_DetailTransactionWrapper object
     *
     * @param json The JSON string to be parsed
     * @return An SCC_DetailTransactionWrapper object parsed from the JSON string
     */
    
    public static SCC_DetailTransactionWrapper parse(String json) {
        return (SCC_DetailTransactionWrapper) System.JSON.deserialize(json, SCC_DetailTransactionWrapper.class);
    }
    
}