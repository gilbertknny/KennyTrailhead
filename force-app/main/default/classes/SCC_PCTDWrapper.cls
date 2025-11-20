/** @description
 * SCC_PCTDWrapper is a wrapper class for handling pending credit transactions data.
 * It includes an inner class representing individual transaction details and a method to parse JSON strings
 * into SCC_PCTDWrapper objects.
 */
public without sharing class SCC_PCTDWrapper {
    @AuraEnabled
    public List<CPAHF> CPAHF; // List of CPAHF objects representing pending credit transactions

    /** @description
     * CPAHF class represents the details of an individual pending credit transaction.
     */
    public class CPAHF {
        /** @description // Type of transaction */
        @AuraEnabled
        public String jenisTransaksi { get; set; } 
       /** @description // Remaining merchant billing time */
        @AuraEnabled
        public String waktuSisaPenagihanMerchant { get; set; } 
      /** @description // Pending transaction amount */
        @AuraEnabled
        public String nominalTransaksiMenggantung { get; set; } 
      /** @description // Pending transaction date */
        @AuraEnabled
        public String tanggalTransaksiMenggantung { get; set; } 
       /** @description // Transaction description */
        @AuraEnabled
        public String deskripsiTransaksi { get; set; } 
       /** @description / Billing posting date */
        @AuraEnabled
        public String tanggalPostingTagihan { get; set; } 
       /** @description // Accumulated transaction amount */
        @AuraEnabled
        public String akumulasiJumlahTransaksi { get; set; } 
      /** @description // Reference number */
        @AuraEnabled
        public String refferenceNumber { get; set; } 
     /** @description // Transaction code*/
        @AuraEnabled
        public String kodeTransaksi { get; set; } 
     /** @description // Transaction posting date*/
        @AuraEnabled
        public String tanggalPostingTransaksi { get; set; } 
      /** @description // Approval code */
        @AuraEnabled
        public String approvalCode { get; set; } 
      /** @description // Transaction remarks */
        @AuraEnabled
        public String keteranganTransaksi { get; set; } 
      /** @description // Transaction amount */
        @AuraEnabled
        public String nominalTransaksi { get; set; } 
       /** @description // Transaction time */
        @AuraEnabled
        public String waktuTransaksi { get; set; } 
       /** @description // Transaction date */
        @AuraEnabled
        public String tanggalTransaksi { get; set; } 
    }

    /** @description
     * Parses a JSON string into an SCC_PCTDWrapper object.
     *
     * @param json The JSON string to be parsed
     * @return An SCC_PCTDWrapper object parsed from the JSON string
     */
    public static SCC_PCTDWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_PCTDWrapper object
        return (SCC_PCTDWrapper) System.JSON.deserialize(json, SCC_PCTDWrapper.class);
    }
}