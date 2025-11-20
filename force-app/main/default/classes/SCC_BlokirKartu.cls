public with sharing class SCC_BlokirKartu {
    @AuraEnabled(cacheable=true)
    public static List<String> getUserPermissionSets() {
        List<String> permissionSetNames = new List<String>();
        
        for (PermissionSetAssignment psa : [SELECT PermissionSet.Label 
                                            FROM PermissionSetAssignment 
                                            WHERE AssigneeId = :UserInfo.getUserId()]) {
            permissionSetNames.add(psa.PermissionSet.Label);
        }
        
        return permissionSetNames;
    }
}