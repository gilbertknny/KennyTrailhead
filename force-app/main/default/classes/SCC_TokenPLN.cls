public with sharing class SCC_TokenPLN {
    
    @AuraEnabled
    public static Case getCaseDetail(String idcs) {
        String cond = 'id=:idcs';
        String addfield = ',SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
        Case cs = Database.query(queries);
        return cs;
    }


    @AuraEnabled
    public static Case updateCase(Id caseId, String tokenNumber, String billingNumber) {


        System.debug('Case Id: ' + caseId);
        System.debug('Nomor Token: ' + tokenNumber);
        System.debug('Billing Number: ' + billingNumber);

        try {
            Case cs = getCaseDetail(caseId);

            if (cs == null) {
                throw new AuraHandledException('Data Case tidak ditemukan.');
            }

            if (String.isNotBlank(billingNumber)) {
                cs.scc_Billing_Number__c = billingNumber;
            }

            if (String.isNotBlank(tokenNumber)) {
                cs.Nomor_Token_PLN__c = tokenNumber;
            }

            update cs;
            return cs;

        } catch (Exception e) {
            throw new AuraHandledException('Error update Case: ' + e.getMessage());
        }
    }
}