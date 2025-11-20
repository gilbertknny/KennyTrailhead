trigger RestrictCaseOwnerChange on Case (before update) {
    // Get the Ids of case owners whose ownership is being changed
    Set<Id> newOwnerIds = new Set<Id>();
    for (Case c : Trigger.new) {
        if (c.OwnerId != Trigger.oldMap.get(c.Id).OwnerId) {
            newOwnerIds.add(c.OwnerId);
        }
    }
    
    // Only query if there are new owner Ids
    if (!newOwnerIds.isEmpty()) {
        // Query users with their ManagerId and check if they have the Supervisor permission set
        Map<Id, Id> managerMap = new Map<Id, Id>();
        Set<Id> supervisorIds = new Set<Id>();
        for (User u : [SELECT Id, ManagerId, 
                       (SELECT AssigneeId FROM PermissionSetAssignments WHERE PermissionSet.Name = 'Supervisor') 
                       FROM User WHERE Id IN :newOwnerIds]) {
            managerMap.put(u.Id, u.ManagerId);
            if (!u.PermissionSetAssignments.isEmpty()) {
                supervisorIds.add(u.Id);
            }
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
}