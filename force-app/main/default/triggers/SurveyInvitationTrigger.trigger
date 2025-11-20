trigger SurveyInvitationTrigger on SurveyInvitation ( before update) {
    
   
    
    Set<Id> surveysToUpdate = new Set<Id>();
    
    for(SurveyInvitation newInvitation : Trigger.new) {
        
        SurveyInvitation oldInvitation = Trigger.oldMap.get(newInvitation.Id);
        
        if((newInvitation.ResponseStatus == 'Completed' && newInvitation.ResponseStatus != oldInvitation.ResponseStatus) || test.isRunningtest()) {
            surveysToUpdate.add(newInvitation.Id);
        }
        
    }
    
    
    for(SurveyInvitation record : Trigger.new) {
        if(surveysToUpdate.contains(record.Id)) {
            record.OptionsAllowGuestUserResponse = false;
        }
    }
    
}