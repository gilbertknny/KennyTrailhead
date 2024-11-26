/**
 * @description
 * Class representing a wrapper for Cardlink customer data by phone number.
 * This class provides methods to parse JSON into structured customer and financial data objects.
 */
public class SCC_CardlinkByPhoneNumberWrapper {
    /**
     * @description
     * Inner class representing additional data associated with a customer.
     */
    public class AdditionalData {
        public String nominalPendapatanPerBulan; // Monthly income
        public String namaLengkapIbuKandung; // Mother's full name
    }

    /**
     * @description
     * Inner class representing the response structure containing customer data.
     */
    public class Response {
        public List<CustomerData> customerData; // List of customer data objects
    }
 /**
     * @description
     * Inner class representing detailed cardholder information.
     */
    public class CardHolderData {
        public String namaCetakKartu; // Name printed on the card
        public String tanggalTerakhirMaintenanceKartu; // Last maintenance date of the card
        public String customerNumber; // Customer number
        public String sisaLimitCicilanKartu; // Remaining installment limit of the card
        public String limitCicilanKartu; // Installment limit of the card
        public String sisaLimitTarikTunaiKartu; // Remaining cash withdrawal limit of the card
        public String limitTarikTunaiKartu; // Cash withdrawal limit of the card
        public String sisaLimitKartu; // Remaining limit of the card
        public String tanggalJatuhTempo; // Due date
        public String tanggalCetakCycle; // Cycle print date
        public String expiredKartu; // Card expiration date
        public String limitKartuKredit; // Credit card limit
    }
  /**
     * @description
     * Inner class representing the response structure containing customer data.
     */
    public Response response; // Instance of Response containing the response details
/**
     * @description
     * Inner class representing comprehensive customer data.
     */
    public class CustomerData {
        public Portofolio portofolio; // Portfolio information of the customer
        public List<AdditionalData> additionalData; // List of additional data objects
        public List<CardHolderData> cardHolderData; // List of cardholder data objects
        public String alamatEmail; // Email address
        public String alamatRumahBelakang; // Home address (back part)
        public String alamatRumahDepan; // Home address (front part)
        public String alamatKantorBelakang; // Office address (back part)
        public String alamatKantorTengah; // Office address (middle part)
        public String alamatKantorDepan; // Office address (front part)
        public String jabatanKerja; // Job position
        public String jenisKelamin; // Gender
        public String sisaLimitCicilanNasabah; // Remaining installment limit of the customer
        public String limitCicilanNasabah; // Installment limit of the customer
        public String sisaLimitTarikTunaiNasabah; // Remaining cash withdrawal limit of the customer
        public String limitTarikTunaiNasabah; // Cash withdrawal limit of the customer
        public String sisaLimitNasabah; // Remaining limit of the customer
        public String nomorNpwp; // Tax identification number
        public String nomorNik; // National identification number
        public String namaKerabatTidakSerumah; // Non-residential relative's name
        public String nomorTelephoneKantor; // Office phone number
        public String nomorTelephoneRumah; // Home phone number
        public String nomorTelephoneKerabatTidakSerumah; // Non-residential relative's phone number
        public String nomorHandphoneTerdaftar; // Registered mobile phone number
        public String namaBelakang; // Last name
        public String namaTengah; // Middle name
        public String namaDepan; // First name
    }
/**
     * @description
     * Inner class representing a customer's financial portfolio.
     */
    public class Portofolio {
        public List<Saving> saving; // List of savings
        public List<Saving> loan; // List of loans
        public List<Investasi> investasi; // List of investments
        public List<CreditCard> creditCard; // List of credit cards
    }

    /**
     * @description
     * Inner class representing a savings account.
     */
    public class Saving {
        public String status; // Account status
        public String productType; // Type of product
        public String productDescription; // Product description
        public String product; // Product name
        public String cifno; // Customer Information File number
        public Decimal balance; // Account balance
        public String acctno; // Account number
    }
 /**
     * @description
     * Inner class representing an investment account.
     */
    public class Investasi {
        public String status; // Investment status
        public String productType; // Type of investment product
        public String productDescription; // Investment product description
        public String product; // Investment product name
        public String cifno; // Customer Information File number
        public decimal balance; // Investment balance
        public String acctno; // Account number
    }

    /**
     * @description
     * Inner class representing a credit card account.
     */
    public class CreditCard {
        public String status; // Credit card status
        public String productType; // Type of credit card product
        public String productDescription; // Credit card product description
        public String product; // Credit card product name
        public String cifno; // Customer Information File number
        public String cardNumber; // Credit card number
    }
/**
     * @description
     * Parses a JSON string into an instance of SCC_CardlinkByPhoneNumberWrapper.
     * 
     * @param json The JSON string to parse.
     * @return An instance of SCC_CardlinkByPhoneNumberWrapper parsed from the JSON string.
     */
    public static SCC_CardlinkByPhoneNumberWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_CardlinkByPhoneNumberWrapper object
        return (SCC_CardlinkByPhoneNumberWrapper) System.JSON.deserialize(json, SCC_CardlinkByPhoneNumberWrapper.class);
    }
}