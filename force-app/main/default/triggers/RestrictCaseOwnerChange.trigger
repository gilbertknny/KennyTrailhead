trigger RestrictCaseOwnerChange on Case (before update) {
    // Get the Ids of case owners whose ownership is being changed
    Set<Id> newOwnerIds = new Set<Id>();
    for (Case c : Trigger.new) {
        if (c.OwnerId != Trigger.oldMap.get(c.Id).OwnerId) {
            newOwnerIds.add(c.OwnerId);
        }
    }
    
    // Get the Ids of users with the Supervisor permission set
    Set<Id> supervisorIds = new Set<Id>();
    for (PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Supervisor']) {
        supervisorIds.add(psa.AssigneeId);
    }
    
    // Query users to get their manager Ids
    Map<Id, Id> managerMap = new Map<Id, Id>();
    for (User u : [SELECT Id, ManagerId FROM User WHERE Id IN :newOwnerIds]) {
        managerMap.put(u.Id, u.ManagerId);
    }
    
    for (Case c : Trigger.new) {
        // Check if the owner is being changed
        if (c.OwnerId != Trigger.oldMap.get(c.Id).OwnerId) {
            // Check if the current user is a manager of the new owner or has Supervisor permission
            if (!managerMap.containsKey(c.OwnerId) && !supervisorIds.contains(UserInfo.getUserId())) {
                c.addError('Anda tidak memiliki izin untuk mengubah pemilik Case.');
            }
        }
    }
}