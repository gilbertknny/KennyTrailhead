/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 27-02-2025, 03-03-2025
 * @last modified by  : Ardyta Yudianto, herbing
**/
public with sharing class SCC_CaseResolution_RTGS_Ctrl {

    // Constants defined at class level
    private static final String REMARK_KEY = 'Remark';
    private static final String NBMB_PATTERN = 'NBMB';

    @AuraEnabled//(cacheable=true)  
    public static SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse searchRtgs( String idTransaction, String kd, Id csId) {  
        // Create a new request object
        SCC_CaseResolution_FindRTGSWrapper.PaymentDataRequest reqId = new SCC_CaseResolution_FindRTGSWrapper.PaymentDataRequest();
        reqId.idTransaction = idTransaction;

        String channel = BrizziChannel__mdt.getInstance('CHMS').MasterLabel;
        String serviceId = BrizziChannel__mdt.getInstance('serviceId').MasterLabel;
        BRIMO__c br = BRIMO__c.getinstance('extId RTGS');
        System.debug('br: ' + br);
        Integer extIdRTGS = Integer.valueOf(br.request_refnum__c);
        String externalId = SCC_Brimo.setreffnum(extIdRTGS);
        SCC_CaseResolution_FindRTGSWrapper.DataRequest dt = new SCC_CaseResolution_FindRTGSWrapper.DataRequest();
        dt.kodePembayaran = kd;
        dt.channelId = channel;
        dt.serviceId = serviceId;
        dt.externalId = externalId;
        //dt.tellerId = '9994198'; //optional
        //User currentUser = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];
        //dt.userName = currentUser.EmployeeNumber != null ? currentUser.EmployeeNumber : ''; // optional
        //dt.supervisorId //optional
        dt.paymentData = reqId;
        
        SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest req = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest();
        req.request = dt;

        String menu = 'Case - Bricare';
        String recid = String.valueOf(csId);

        SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse res = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
            res = Object_Test_RTGS.findRTGSResponse();
        } 
        else{
            res = SCC_CaseResolution_FindRTGS.searchRTGS(req,menu,recid);
        }
        br.request_refnum__c += 1;
        update br;
        return res;
    }

    @AuraEnabled  
    public static void updateCaseRemittance(Id caseId, String remittanceNo, String billingNumber ) {  
        try {  
            // Case caseToUpdate = [SELECT Id, SCC_Nomor_Remittence__c, scc_Billing_Number__c  FROM Case WHERE Id = :caseId LIMIT 1];  
            // if (caseToUpdate != null) {  
            //     caseToUpdate.SCC_Nomor_Remittence__c  = remittanceNo;
            //     caseToUpdate.scc_Billing_Number__c = billingNumber;
            //     update caseToUpdate;  
            // } 
            system.debug('billingNumber = '+billingNumber);
            Case caseToUpdate = new Case();
            caseToUpdate.Id = caseId;
            caseToUpdate.scc_Billing_Number__c = billingNumber;
            caseToUpdate.SCC_Nomor_Remittence__c = remittanceNo;
            // if(remittanceNo != null && !String.isEmpty(remittanceNo)){
            //     caseToUpdate.Id = caseId;
            //     // caseToUpdate.Status = 'Closed';
            //     // caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
            //     // caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
            //     caseToUpdate.SCC_Nomor_Remittence__c = remittanceNo;
            //     caseToUpdate.scc_Billing_Number__c = billingNumber;
            // } 
            // else{
            //     caseToUpdate.Id = caseId;
            //     caseToUpdate.scc_Billing_Number__c = billingNumber;
            //     caseToUpdate.SCC_Nomor_Remittence__c = remittanceNo;
            // }
            system.debug('caseToUpdate ='+caseToUpdate);
            update caseToUpdate;
        } catch (Exception e) {  
            throw new AuraHandledException('Error updating Case No Remintance RTGS: ' + e.getMessage());  
        }  
    }  

    public static void updateBillingNumber (Id caseId){
        Case cs = [SELECT Id, scc_Billing_Number__c, SCC_Notes__c FROM Case WHERE Id = :caseId LIMIT 1];

        // Extract Brizzi number from remark
        String billingNumber = extractBillingNumber(cs.SCC_Notes__c);
        
        if (String.isBlank(billingNumber)) {
            throw new AuraHandledException('Unable to extract valid Billing number from note RTGS');
        }
        
        cs.scc_Billing_Number__c = billingNumber;
        update cs;
    }

    // Helper method to extract Brizzi number from remark
    private static String extractBillingNumber(String remark) {
        try {
            // Clean up the input to remove unnecessary characters (carriage returns, newlines)
            String sanitizedRemark = remark.replace('\r', '').replace('\n', '').trim();

            // Parse the cleaned JSON string
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(sanitizedRemark);
            
            // Get the Remark value from the parsed JSON
            String remarkValue = (String) jsonData.get(REMARK_KEY);
            
            // Find NBMB in the remark and extract all digits after it
            if (String.isNotBlank(remarkValue)) {
                Integer nbmbIndex = remarkValue.indexOf(NBMB_PATTERN);
                
                if (nbmbIndex != -1) {
                    // Calculate start position (NBMB + 4 characters)
                    Integer startPos = nbmbIndex + NBMB_PATTERN.length();
                    
                    // Extract from NBMB to the end of the string
                    String remainingText = remarkValue.substring(startPos);
                    
                    // Use regex to extract all digits
                    Pattern digitPattern = Pattern.compile('(\\d+)');
                    Matcher matcher = digitPattern.matcher(remainingText);
                    
                    if (matcher.find()) {
                        String extractedNumber = matcher.group(1);
                        return extractedNumber;
                    }
                }
            }

            return null;

        } catch (Exception e) {
            // If JSON parsing fails, return null
            return null;
        }
    }
}