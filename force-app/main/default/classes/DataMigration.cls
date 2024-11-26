public class DataMigration {

    // Method to find the matching Branch Unit record in Salesforce based on the SCC_User_Group__c value
    /*public static Branch_Unit__c findBranchUnit(String userGroupName) {
        List<Branch_Unit__c> branchUnits = [
            SELECT Id, Name 
            FROM Branch_Unit__c 
            WHERE Name = :userGroupName
        ];
        if (!branchUnits.isEmpty()) {
            return branchUnits[0];
        }
        return null;
    }*/

    // Method to update the Unit_Kerja_2__c field for specific Case records
    /*public static void updateUnitKerjaFieldForCases(List<Case> casesToUpdate) {
        system.debug('casesToUpdate');
        system.debug(casesToUpdate);
        // Query the specific Case records
        //List<Case> casesToUpdate = [SELECT Id, SCC_User_Group__c FROM Case WHERE SCC_User_Group__c != NULL];

        List<Case> updatedCases = new List<Case>();
        
        // Compile a regex pattern to check if the string starts with a number
        Pattern pattern = Pattern.compile('^[0-9].*');

        for (Case caseRecord : casesToUpdate) {
            String userGroupName = caseRecord.SCC_User_Group__c;
            
            if (userGroupName != null) {
                Matcher matcher = pattern.matcher(userGroupName);
                if (matcher.matches()) {
                    System.debug('User Group Name: ' + userGroupName);
                    Branch_Unit__c branchUnit = findBranchUnit(userGroupName);
                    
                    if (branchUnit != null) {
                        System.debug('Found Branch Unit: ' + branchUnit.Id + ' - ' + branchUnit.Name);
                        caseRecord.Unit_Kerja_2__c = branchUnit.Id;
                        updatedCases.add(caseRecord);
                    } else {
                        System.debug('No Branch Unit found for: ' + userGroupName);
                    }
                } else {
                    System.debug('Skipping User Group Name: ' + userGroupName + ' as it does not start with a number');
                }
            }
        }

        if (!updatedCases.isEmpty()) {
            update updatedCases;
        } else {
            System.debug('No cases to update.');
        }
    }*/
}