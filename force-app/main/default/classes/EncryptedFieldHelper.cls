public with sharing class EncryptedFieldHelper {
    
    @InvocableMethod(label='Compare Encrypted Field' description='Compares an encrypted field value with a plain text input.')
    public static List<Boolean> compareEncryptedField(List<Request> requests) {
        List<Boolean> results = new List<Boolean>();
        for (Request req : requests) {
            // Query untuk mengambil nilai field terenkripsi
            String encryptedValue = [SELECT Pass_Phrase__c FROM User WHERE Id = :req.userId LIMIT 1].Pass_Phrase__c;

            // Bandingkan nilai terenkripsi dengan nilai yang dimasukkan pengguna
            Boolean isMatch = encryptedValue == req.plainTextValue;
            results.add(isMatch);
        }
        return results;
    }

    public class Request {
        @InvocableVariable(required=true)
        public String userId; // ID record yang berisi field terenkripsi

        @InvocableVariable(required=true)
        public String plainTextValue; // Nilai yang dimasukkan pengguna
    }
}