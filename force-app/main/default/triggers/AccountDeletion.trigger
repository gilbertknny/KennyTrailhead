trigger AccountDeletion on Account (before delete) {
  // Prevent the deletion of accounts if they have related opportunities.
  List<Account> listAccount= new List<Account>();
  listAccount = [SELECT Id FROM Account
				 WHERE Id IN (SELECT AccountId FROM Opportunity) AND Id IN :Trigger.old];
    
  for(Account a : listAccount) {
    Trigger.oldMap.get(a.Id).addError('Cannot delete account with related opportunities.');
  }
}