/**
 * This class wraps saving statement data and provides functionality
 * to parse JSON into an instance of SCC_SavingStatementWrapper.
 */
public without sharing class SCC_SavingStatementWrapper {
    
    // List to hold Data objects
    public List<Data> data;
    // Object to hold errors, if any
    public Object errors;
    // Response message from the API
    public String responseMessage;
    // Response code from the API
    public String responseCode;
    // Error code, if any
    public String errorCode;
    // Status code of the response
    public Integer statusCode;

    /**
     * Inner class representing individual data entries in the saving statement.
     */
    public class Data {
        public String remarkCustom;     // Custom remark
        public String tlbds2;           // Transaction label 2
        public String tlbds1;           // Transaction label 1
        public String serial;           // Serial number
        public String auxtrc;           // Auxiliary transaction code
        public String trremk;           // Transaction remark
        public String terbilang;        // Amount in words
        public String glsign;           // General ledger sign
        public String truser;           // Transaction user
        public Double saldoAkhirMutasi; // Ending balance of the mutation
        public Integer mutasiKredit;    // Credit mutation amount
        public Integer mutasiDebet;     // Debit mutation amount
        public Double saldoAwalMutasi; // Beginning balance of the mutation
        public String deskTran;         // Transaction description
        public String kodeTran;         // Transaction code
        public Integer jamTran;         // Transaction time
        public String tglEfektif;       // Effective date
        public String tglTran;          // Transaction date
        public Long noRek;              // Account number
        public Integer idNum;           // ID number
        public Integer seq;             // Sequence number
        public Integer idNum2;          // Second ID number
        public Integer idNum3;          // Third ID number
        public String ukerTransaksi;
        public String tid;
        public String channel;        
    }

    /**
     * Parses a JSON string and returns an instance of SCC_SavingStatementWrapper.
     *
     * @param json The JSON string to parse.
     * @return An instance of SCC_SavingStatementWrapper.
     */
    public static SCC_SavingStatementWrapper parse(String json) {
        // Deserialize the JSON string into an SCC_SavingStatementWrapper object
        return (SCC_SavingStatementWrapper) System.JSON.deserialize(json, SCC_SavingStatementWrapper.class);
    }
}