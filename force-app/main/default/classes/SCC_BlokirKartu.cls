public with sharing class SCC_BlokirKartu {
    @AuraEnabled(cacheable=true)
    public static List<String> getUserPermissionSets() {
        List<String> permissionSetNames = new List<String>();
        
        for (PermissionSetAssignment psa : [SELECT PermissionSet.Name 
                                            FROM PermissionSetAssignment 
                                            WHERE AssigneeId = :UserInfo.getUserId()]) {
            permissionSetNames.add(psa.PermissionSet.Name);
        }
        
        return permissionSetNames;
    }
}