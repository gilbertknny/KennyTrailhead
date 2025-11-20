trigger updateMessagingUserAccount on MessagingSession (after insert, after update) {
    List<MessagingEndUser> messagingUsersToUpdate = new List<MessagingEndUser>();

    for (MessagingSession session : Trigger.new) {
        if (session.CaseId != null) {
            Case relatedCase = [
                SELECT AccountId
                FROM Case
                WHERE Id = :session.CaseId
                LIMIT 1
            ];

            if (relatedCase.AccountId != null) {
                MessagingEndUser relatedUser = [
                    SELECT Id, AccountId
                    FROM MessagingEndUser
                    WHERE Id = :session.MessagingEndUserId
                    LIMIT 1
                ];

                if (relatedUser.AccountId != relatedCase.AccountId) {
                    relatedUser.AccountId = relatedCase.AccountId;
                    messagingUsersToUpdate.add(relatedUser);
                }
            }
        }
    }

    if (!messagingUsersToUpdate.isEmpty()) {
        try {
            update messagingUsersToUpdate;
        } catch (DmlException e) {
            System.debug('Error updating Messaging Users: ' + e.getMessage());
        }
    }
}