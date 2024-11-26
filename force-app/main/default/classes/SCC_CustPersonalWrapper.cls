/** @description
 * SCC_CustPersonalWrapper is a wrapper class for handling customer personal data.
 * It includes an inner class representing customer personal details and a method to parse JSON strings
 * into SCC_CustPersonalWrapper objects.
 */
public without sharing class SCC_CustPersonalWrapper {

    /** @description
     * CUSTPERSONAL class represents the personal details of a customer.
     */
    public class CUSTPERSONAL {
        public String progressPengajuan; // Application progress
        public String nomorKartuKredit; // Credit card number
        public String channelPengajuan; // Application channel
        public String tanggalPengajuan; // Application date
        public String nomorAplikasiPengajuan; // Application number
        public String tanggalLahir; // Date of birth
        public String nik; // National Identification Number
        public String namaNasabahLengkap; // Full name of the customer
    }

    public List<CUSTPERSONAL> CUSTPERSONAL; // List of CUSTPERSONAL objects

    /** @description
     * Parses a JSON string into an SCC_CustPersonalWrapper object.
     *
     * @param json The JSON string to be parsed
     * @return An SCC_CustPersonalWrapper object parsed from the JSON string
     */
    public static SCC_CustPersonalWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_CustPersonalWrapper object
        return (SCC_CustPersonalWrapper) System.JSON.deserialize(json, SCC_CustPersonalWrapper.class);
    }
}