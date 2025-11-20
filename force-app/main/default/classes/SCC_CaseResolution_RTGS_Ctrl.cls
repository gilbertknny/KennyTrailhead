/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 27-02-2025, 03-03-2025
 * @last modified by  : Ardyta Yudianto, herbing
**/
public with sharing class SCC_CaseResolution_RTGS_Ctrl {

    @TestVisible
    private static Boolean useDummyResponseInTest = false;
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
        dt.paymentData = reqId;
        
        SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest req = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest();
        req.request = dt;

        String menu = 'Case - Bricare';
        String recid = String.valueOf(csId);

        SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse res = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse();     
        
        // Check if a dummy response should be used
        if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
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
            system.debug('billingNumber = '+billingNumber);
            Case caseToUpdate = new Case();
            caseToUpdate.Id = caseId;
            caseToUpdate.scc_Billing_Number__c = billingNumber;
            caseToUpdate.SCC_Nomor_Remittence__c = remittanceNo;
            system.debug('caseToUpdate ='+caseToUpdate);
            update caseToUpdate;
        } catch (Exception e) {  
            throw new AuraHandledException('Error updating Case No Remintance RTGS: ' + e.getMessage());  
        }  
    }  

    // Helper method to extract Brizzi number from remark
    public static String extractBillingNumber(String remark) {
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