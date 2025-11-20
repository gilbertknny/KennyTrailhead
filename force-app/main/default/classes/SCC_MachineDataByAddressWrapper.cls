/**
 * This class wraps machine data by address and provides functionality
 * to parse JSON into an instance of SCC_MachineDataByAddressWrapper.
 */
public without sharing class SCC_MachineDataByAddressWrapper {
    
    // List to hold MachineDataByAddress objects
    public List<MachineDataByAddress> machineDataByAddress;

    /**
     * Inner class representing machine data by address.
     */
    public class MachineDataByAddress {
        public String kontakId;     // Contact ID
        public String status;       // Status of the machine
        public String alamatMesin;  // Machine address
        public String nomorMesin;   // Machine number
        public String jenisMesin;   // Type of machine
        public String tid;          // Terminal ID
    }

    /**
     * Parses a JSON string and returns an instance of SCC_MachineDataByAddressWrapper.
     *
     * @param json The JSON string to parse.
     * @return An instance of SCC_MachineDataByAddressWrapper.
     */
    public static SCC_MachineDataByAddressWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_MachineDataByAddressWrapper object
        return (SCC_MachineDataByAddressWrapper) System.JSON.deserialize(json, SCC_MachineDataByAddressWrapper.class);
    }
}