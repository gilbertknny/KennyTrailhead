trigger OnChange_OutOfOffice on OutOfOffice (after insert, after update) {
    /*
    for (OutOfOffice ooo : Trigger.new) { 
        // Check if the Start Date has been updated or a new record has been created
        if (Trigger.isInsert || ooo.StartDate != Trigger.oldMap.get(ooo.Id).StartDate) {
            User usr = [Select Id,isCuti__c from User where Id=:ooo.UserId];
            if(ooo.StartDate <= Date.today()){
                usr.isCuti__c = true;
            }else{
                usr.isCuti__c = false;
            }            
            update usr;
        }
    }
    */
}