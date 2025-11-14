public with sharing class Aswata_Async_PremiCalculation {
    @future
    public static void aswataPremiCalculation(String opportunityId) {

        if(String.isNotBlank(opportunityId)){
            List<InsurancePolicyCoverage> lstAllCoverage = [Select id, Premi_Amount__c, Risk_ID__c from InsurancePolicyCoverage 
                                                            Where Risk_ID__r.Opportunity__c =: opportunityId and Premi_Amount__c != null 
                                                            With Security_Enforced];
            System.debug('lstAllCoverage:' + lstAllCoverage.size());
         // Sum the Premi_Amount__c
            Decimal totalPremi = 0;
            for (InsurancePolicyCoverage cov : lstAllCoverage) {
                totalPremi += cov.Premi_Amount__c;
            }
            
            System.debug('totalPremi:' + totalPremi);

            // Update Opportunity if there are any coverage records
            if (!lstAllCoverage.isEmpty()) {
                Opportunity opp = new Opportunity(
                    Id = opportunityId,
                    Premium__c = totalPremi
                );
                update opp;
            }
        }


    }
}