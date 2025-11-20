public with sharing class SCC_Drone_UpdateNomorToken_Invoc {
    // Inner class to define input parameters from Flow
    public class FlowInput {
        @InvocableVariable(required=true)
        public Id recordId;
        
        @InvocableVariable(required=true)
        public String remark;

        @InvocableVariable(required=true)
        public String caseType;
    }

    // Constants
    private static final Pattern PATTERN_8808 = Pattern.compile('PLN-PRA\\s(\\d+)(?=NBMB)');
    private static final Pattern PATTERN_8809 = Pattern.compile('PLN-POST\\s(\\d+)(?=NBMB)');
    private static final Pattern PATTERN_8433 = Pattern.compile('BRIVA\\s(\\d+)(?=NBMB)');
    
    // Invocable method that can be called from Flow
    @InvocableMethod(label='Invocable Case Update Nomor Token' category='Invocable')
    public static void updateNomorToken(List<FlowInput> inputs) {
        try {
            if (inputs == null || inputs.isEmpty()) {
                throw new AuraHandledException('No input received from Flow');
            }

            FlowInput input = inputs[0];

            if (String.isBlank(input.remark)) {
                throw new AuraHandledException('Remark field cannot be empty');
            }

            String paymentNumber = extractPaymentNumber(input.remark, input.casetype, input.recordId);

            if (paymentNumber == null || paymentNumber.trim() == '') {
                System.debug('No valid payment number extracted. Skipping update.');
                return; // gracefully stop the method without error
            }

            Case caseRecord = [SELECT Id, SCC_Nomor_Briva_Tagihan__c, scc_Billing_Number__c,SCC_Case_Type_for_Suggested_Article__c,SCC_Sub_Case__c FROM Case WHERE Id = :input.recordId LIMIT 1];
            if (paymentNumber != null) {
                if (paymentNumber.endsWith('BRIVA')) {
                    String billingNumber = paymentNumber.substring(0, paymentNumber.length() - 'BRIVA'.length());
                    caseRecord.SCC_Nomor_Briva_Tagihan__c = billingNumber;

                    if(caseRecord.SCC_Case_Type_for_Suggested_Article__c == '8433'){
                        caseRecord.SCC_Sub_Case__c = 'Pembayaran Briva';
                    }

                } else {
                    caseRecord.scc_Billing_Number__c = paymentNumber;

                    if(caseRecord.SCC_Case_Type_for_Suggested_Article__c == '8433'){
                        caseRecord.SCC_Sub_Case__c = 'Pembayaran Non-Briva';
                    }
                }
            }
            System.debug('paymentNumber: ' + paymentNumber);
            System.debug('caseRecord: ' + caseRecord);
            if (caseRecord.SCC_Nomor_Briva_Tagihan__c != null || caseRecord.scc_Billing_Number__c != null) {
                update caseRecord;
            }
        } 
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // Helper method to extract Brizzi number from remark
    public static String extractPaymentNumber(String remark, String caseType, Id cs) {
        try {
            String sanitizedRemark = remark.replace('\r', '').replace('\n', '').trim();
            System.debug('Sanitized Remark: ' + sanitizedRemark);
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(sanitizedRemark);
            System.debug('Parsed JSON Data: ' + jsonData);
            String remarkField = (String) jsonData.get('Remark');
            if (String.isBlank(remarkField)) {
                return null;
            }
            if(caseType == '8809'){
                String numberBilling = (String) jsonData.get('Nomor Pembayaran');
                if (String.isNotBlank(numberBilling)){
                    return numberBilling;
                }
                else{
                    Matcher matcher = PATTERN_8809.matcher(remarkField);
                    if (matcher.find()) {
                        return matcher.group(1); // the Nomor Token
                    }
                }
            }
            else if(caseType == '8808'){
                String numberBilling = (String) jsonData.get('Nomor Pembayaran');
                if (String.isNotBlank(numberBilling)){
                    return numberBilling;
                }
                else{
                    System.debug('Parsed JSON Data 8808');
                    Matcher matcher = PATTERN_8808.matcher(remarkField);
                    System.debug('Parsed JSON Data matcher 1: '+matcher);
                    if (matcher.find()) {
                        System.debug('Parsed JSON Data matcher 2: '+matcher);
                        return matcher.group(1); // the Nomor Token
                    }
                }
            }
            else if(caseType == '8434'){
                System.debug('Parsed JSON Data 8434 1');
                if(jsonData.containsKey('Nomor HP')){
                    System.debug('Parsed JSON Data 8434 2');
                    String phoneNUmber = (String) jsonData.get('Nomor HP');
                    if(String.isNotBlank(phoneNUmber)){
                        return phoneNUmber;
                    }
                }
            }
            else if(caseType == '8433'){
                //cek jika ada field nomor pembayaran
                if(jsonData.containsKey('Nomor Pembayaran')){
                    Case caseRecord = [SELECT Id, SCC_Nomor_Briva_Tagihan__c FROM Case WHERE Id = :cs LIMIT 1];
                    if(String.isBlank(caseRecord.SCC_Nomor_Briva_Tagihan__c)){
                        Object numberBillingObj = jsonData.get('Nomor Pembayaran');
                        String numberBilling = numberBillingObj != null ? String.valueOf(numberBillingObj).trim() : null;
                        if (String.isNotBlank(numberBilling)){
                            //transaksi briva
                            if(remarkField.contains('BRIVA')){
                                String nomor_briva = numberBilling+'BRIVA';
                                return nomor_briva;
                            }
                            //transaksi non briva
                            else{
                                return numberBilling;
                            }
                        }
                        else{
                            System.debug('Parsed JSON Data 8433');
                            Matcher matcher = PATTERN_8433.matcher(remarkField);
                            System.debug('Parsed JSON Data matcher 1: '+matcher);
                            //transaksi briva
                            if (matcher.find()) {
                                System.debug('Parsed JSON Data matcher 2: '+matcher);
                                return matcher.group(1)+'BRIVA';
                            }
                            //transaksi non briva
                            // else{

                            // }
                        }                                                   
                    }else{
                        return null;
                    }
                }
                //cek jika ada field nomor pembayaran
                else{
                    System.debug('Parsed JSON Data 8433');
                    Matcher matcher = PATTERN_8433.matcher(remarkField);
                    System.debug('Parsed JSON Data matcher 1: '+matcher);
                    //transaksi briva
                    if (matcher.find()) {
                        System.debug('Parsed JSON Data matcher 2: '+matcher);
                        return matcher.group(1)+'BRIVA';
                    }
                    //transaksi non briva
                    else{
                        return null;
                    }
                }
            }
            return null;
        } catch (Exception e) {
            return null;
        }
    }
}