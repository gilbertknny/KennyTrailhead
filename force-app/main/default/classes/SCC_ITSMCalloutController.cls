public with sharing class SCC_ITSMCalloutController {

    @AuraEnabled
    public static String makeCallout(String caseId) {
        // Fetch the Case record
        Case caseRecord = [SELECT 
                                Id, 
                                CaseNumber, 
                                Subject, 
                                Nomor_Tiket__c, 
                                Case_Number__c, 
                                Account.Name, 
                                SCC_Account_Number__c, 
                                Nomor_Kartu__c, 
                                SCC_Waktu_Transaksi__c 
                            FROM Case 
                            WHERE Id = :caseId LIMIT 1];
        
        // Define static values
        String profileLink = '2B8D636C2B4A411BBE65F05E382B77FD';
        String detectedTime = formatDateTime(System.now());
        String layananTerdampak = 'Not Yet Identified';
        String tipeIncident = 'Not Yet Identified';
        String categorySystem = 'Not Yet Identified';
        String urgency = 'Low'; // Assuming urgency is static as "Low"
        String cidItemukan = 'Tidak';
        
        // Prepare the request body
        Map<String, Object> requestBody = new Map<String, Object>{
            'BRI_DetectedTime' => detectedTime,
            'ProfileLink' => profileLink,
            'Subject' => caseRecord.Subject,
            'Symptom' => 'Terdapat permasalahan IT yang berkaitan dengan Nomor Tiket New BRICAre ' + caseRecord.Nomor_Tiket__c,
            'Source' => 'AutoTicket - CHM',
            'BRI_SourceKey' => caseRecord.Case_Number__c,
            'BRI_LayananTerdampak' => layananTerdampak,
            'BRI_TipeIncident' => tipeIncident,
            'BRI_CategorySystem' => categorySystem,
            'Urgency' => urgency,
            'BRI_CIDITEMUKAN' => cidItemukan,
            'Nama_Nasabah' => caseRecord.Account.Name,
            'Nomor_Rekening' => caseRecord.SCC_Account_Number__c,
            'Nomor_Kartu' => caseRecord.Nomor_Kartu__c,
            'Waktu_Transaksi' => caseRecord.SCC_Waktu_Transaksi__c
        };
        
        // Make the HTTP callout
        String endpointUrl = 'https://api.example.com/endpoint'; // Replace with your endpoint URL
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(requestBody));
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        return res.getBody();
    }
    
    // Method to format DateTime as "M/d/yyyy h:mm:ss a"
    private static String formatDateTime(DateTime dt) {
        String formattedDateTime = dt.format('M/d/yyyy h:mm:ss a');
        return formattedDateTime;
    }
}