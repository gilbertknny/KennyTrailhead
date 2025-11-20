/**
 * SCC_CardDataWrapper is a wrapper class for handling card data inquiries.
 * It includes inner classes representing different aspects of card data.
 */
public without sharing class SCC_CardDataWrapper {

    public ChmGraphql chmGraphql;
    
    public class ChmGraphql {
        public InquiryCardData inquiryCardData;
    }

    /**
     * InquiryCardData class represents the data obtained from a card inquiry.
     */
    public class InquiryCardData {
        public Data data; // Card data
        public String status; // Inquiry status
        public String responseDesc; // Description of the inquiry response
        public String responseCode; // Response code of the inquiry
    }

    /**
     * Data class represents detailed card information.
     */
    public class Data {
        public HistoryAccount historyAccount; // Card account history
        public String userBlock; // User blocking status
        public Date blockDate; // Date of blocking
        public String statusDesc; // Description of status
        public String userMaint; // User maintenance
        public Date lastMaint; // Date of last maintenance
        public String cardStatus; // Card status
        public Date issueDate; // Date of issue
        public String expDate; // Expiry date
        public Date activeDate; // Activation date
        public String name; // Cardholder's name
        public String type; // Card type
        public String cardNo; // Card number
        public String accNo; // Account number associated with the card
    }

    /**
     * HistoryAccount class represents the history of card accounts.
     */
    public class HistoryAccount {
        public ResponseData responseData; // Response data of history account
    }

    /**
     * ResponseData class represents the response data of card account history.
     */
    public class ResponseData {
        public List<DataElement> data; // List of data elements
    }

    /**
     * DataElement class represents individual elements of card account history.
     */
    public class DataElement {
        public String userBlock; // User blocking status
        public String typeCode; // Type code
        public Date renewalDate; // Renewal date
        public String mbStatus; // MB status
        public String mbNo; // MB number
        public Date lastMaint; // Date of last maintenance
        public Date issueDate; // Date of issue
        public String expDate; // Expiry date
        public String cardStatus; // Card status
        public String cardNo; // Card number
        public String branchCode; // Branch code
        public Date blockDate; // Date of blocking
        public Date activeDate; // Activation date
        public String accNo; // Account number associated with the card
    }

    /**
     * Parses a JSON string into an SCC_CardDataWrapper object.
     *
     * @param jsonString The JSON string to be parsed
     * @return An SCC_CardDataWrapper object parsed from the JSON string
     */
    public static SCC_CardDataWrapper parse(String jsonString) {
        // Deserialize the JSON string into an SCC_CardDataWrapper object
        return (SCC_CardDataWrapper) JSON.deserialize(jsonString, SCC_CardDataWrapper.class);
    }
}