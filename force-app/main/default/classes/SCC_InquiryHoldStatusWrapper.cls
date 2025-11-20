/**
 * SCC_InquiryHoldStatusWrapper is a wrapper class for handling inquiry hold status data.
 * It includes an inner class InquiryHoldStatus which contains details about the hold status.
 * 
 * The class provides a method to parse JSON strings into SCC_InquiryHoldStatusWrapper objects.
 */
public class SCC_InquiryHoldStatusWrapper {
    
    /**
     * The InquiryHoldStatus class represents the details of an inquiry hold status.
     * It contains fields for hold date, hold type, hold remark, hold amount, response message,
     * response code, and error code.
     */
    public class InquiryHoldStatus {
        public String holdDate;       // The date when the hold was placed
        public String holdType;       // The type of hold
        public String holdRemark;     // Remarks or comments about the hold
        public String holdAmt;        // The amount associated with the hold
        public String responseMessage; // The message received in response to the inquiry
        public String responseCode;   // The code received in response to the inquiry
        public String errorCode;      // The error code if any error occurred during the inquiry
        public String saldoAkhirMutasi;
    }

    public InquiryHoldStatus inquiryHoldStatus; // Instance of InquiryHoldStatus containing hold details

    /**
     * Parses a JSON string into an SCC_InquiryHoldStatusWrapper object.
     *
     * @param json The JSON string to be parsed
     * @return An SCC_InquiryHoldStatusWrapper object parsed from the JSON string
     */
    public static SCC_InquiryHoldStatusWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_InquiryHoldStatusWrapper object
        return (SCC_InquiryHoldStatusWrapper) System.JSON.deserialize(json, SCC_InquiryHoldStatusWrapper.class);
    }
}