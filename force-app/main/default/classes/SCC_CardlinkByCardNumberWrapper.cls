/** @description
 * SCC_CardlinkByCardNumberWrapper is a wrapper class for handling customer data retrieved by card number.
 * It includes multiple inner classes representing various aspects of customer data, such as additional data,
 * response details, cardholder data, and customer data.
 * 
 * The class provides a method to parse JSON strings into SCC_CardlinkByCardNumberWrapper objects.
 */
public without sharing class SCC_CardlinkByCardNumberWrapper {

    /** @description
     * Response class represents the response structure containing customer data.
     */
    public class Response {
        /**
     * @description customerData
     // List of customer data objects
     */
        @AuraEnabled
        public List<CustomerData> customerData { get; set; } 
    }

    /** @description
     * AdditionalDataByAcctNumber class represents extra details about the customer for a specific account.
     */
    public class AdditionalDataByAcctNumber {
         /** @description nominalPendapatanPerBulan
         Monthly income
         */
        @AuraEnabled
        public String nominalPendapatanPerBulan { get; set; } 
        /** @description namaLengkapIbuKandung
         Mother's full name
         */
        @AuraEnabled
        public String namaLengkapIbuKandung { get; set; } 
    }

    /** @description
     * CardHolderData class represents the details of the cardholder.
     */
    public class CardHolderData {
         /** @description namaCetakKartu Name printed on the card */
        @AuraEnabled
        public String namaCetakKartu { get; set; } 
        /** @description tanggalTerakhirMaintenanceKartu Last maintenance date of the card */
        @AuraEnabled
        public String tanggalTerakhirMaintenanceKartu { get; set; } 
        /** @description customerNumber Customer number */
        @AuraEnabled
        public String customerNumber { get; set; } 
        /** @description sisaLimitCicilanKartu  Remaining installment limit of the card */
        @AuraEnabled
        public String sisaLimitCicilanKartu { get; set; } 
         /** @description limitCicilanKartu Installment limit of the card */
        @AuraEnabled
        public String limitCicilanKartu { get; set; } 
        /** @description sisaLimitTarikTunaiKartu Remaining cash withdrawal limit of the card */
        @AuraEnabled
        public String sisaLimitTarikTunaiKartu { get; set; } 
        /** @description limitTarikTunaiKartu Cash withdrawal limit of the card */
        @AuraEnabled
        public String limitTarikTunaiKartu { get; set; } 
       /** @description sisaLimitKartu Remaining limit of the card */
        @AuraEnabled
        public String sisaLimitKartu { get; set; } 
          /** @description Due date */
        @AuraEnabled
        public String tanggalJatuhTempo { get; set; } 
        /** @description Cycle print date */
        @AuraEnabled
        public String tanggalCetakCycle { get; set; } 
       /** @description Card expiration date */
        @AuraEnabled
        public String expiredKartu { get; set; } 
       /** @description  Credit card limit*/
        @AuraEnabled
        public String limitKartuKredit { get; set; } 
    }

    /** @description
     * CustomerData class represents the customer's detailed information.
     */
    public class CustomerData {
          /** @description  List of additional data objects by account number*/
        @AuraEnabled
        public List<AdditionalDataByAcctNumber> additionalDataByAcctNumber { get; set; } 
       /** @description  // List of cardholder data objects*/
        @AuraEnabled
        public List<CardHolderData> cardHolderData { get; set; } 
        /** @description  // Email address*/
        @AuraEnabled
        public String alamatEmail { get; set; } 
       /** @description  // Home address (back part)*/
        @AuraEnabled
        public String alamatRumahBelakang { get; set; } 
       /** @description  // Home address (front part)*/
        @AuraEnabled
        public String alamatRumahDepan { get; set; } 
       /** @description  // Office address (back part)*/
        @AuraEnabled
        public String alamatKantorBelakang { get; set; } 
       /** @description  // Office address (middle part)*/
        @AuraEnabled
        public String alamatKantorTengah { get; set; } 
      /** @description  // Office address (front part)*/
        @AuraEnabled
        public String alamatKantorDepan { get; set; } 
       /** @description // Job position*/
        @AuraEnabled
        public String jabatanKerja { get; set; } 
       /** @description // Gender*/
        @AuraEnabled
        public String jenisKelamin { get; set; } 
       /** @description // Remaining installment limit of the customer*/
        @AuraEnabled
        public String sisaLimitCicilanNasabah { get; set; } 
      /** @description // Installment limit of the customer*/
        @AuraEnabled
        public String limitCicilanNasabah { get; set; } 
        /** @description // Remaining cash withdrawal limit of the customer*/
        @AuraEnabled
        public String sisaLimitTarikTunaiNasabah { get; set; } 
      /** @description // Cash withdrawal limit of the customer*/
        @AuraEnabled
        public String limitTarikTunaiNasabah { get; set; } 
       /** @description // Remaining limit of the customer*/
        @AuraEnabled
        public String sisaLimitNasabah { get; set; } 
       /** @description // Tax identification number*/
        @AuraEnabled
        public String nomorNpwp { get; set; } 
      /** @description // National identification number*/
        @AuraEnabled
        public String nomorNik { get; set; } 
       /** @description // Non-residential relative's name*/
        @AuraEnabled
        public String namaKerabatTidakSerumah { get; set; } 
        /** @description // Office phone number*/
        @AuraEnabled
        public String nomorTelephoneKantor { get; set; } 
       /** @description // Home phone number*/
        @AuraEnabled
        public String nomorTelephoneRumah { get; set; } 
       /** @description // Non-residential relative's phone number*/
        @AuraEnabled
        public String nomorTelephoneKerabatTidakSerumah { get; set; } 
       /** @description // Registered mobile phone number*/
        @AuraEnabled
        public String nomorHandphoneTerdaftar { get; set; } 
        /** @description // Last name*/
        @AuraEnabled
        public String namaBelakang { get; set; } 
       /** @description // Middle name*/
        @AuraEnabled
        public String namaTengah { get; set; } 
        /** @description // First name*/
        @AuraEnabled
        public String namaDepan { get; set; } 
    }
  /** @description // Instance of Response containing the response details*/
    @AuraEnabled
    public Response response { get; set; } 

    /** @description
     * Parses a JSON string into an SCC_CardlinkByCardNumberWrapper object.
     *
     * @param json The JSON string to be parsed
     * @return An SCC_CardlinkByCardNumberWrapper object parsed from the JSON string
     */
    public static SCC_CardlinkByCardNumberWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_CardlinkByCardNumberWrapper object
        return (SCC_CardlinkByCardNumberWrapper) System.JSON.deserialize(json, SCC_CardlinkByCardNumberWrapper.class);
    }
}