public class testinsert implements Database.Batchable<String> {
    public List<String> activePersonalNumbers;
    public List<User> chmUsers;
    List<String> hilfmAgentList;
    public Id agentProfileId;
    public Id backOfficeProfileId;
    
    public testinsert(List<String> activePersonalNumbers, List<User> chmUsers, List<String> hilfmAgentList, Id agentProfileId, Id backOfficeProfileId){
        this.activePersonalNumbers = activePersonalNumbers;
        this.chmUsers = chmUsers;
        this.hilfmAgentList = hilfmAgentList;
        this.agentProfileId = agentProfileId;
        this.backOfficeProfileId = backOfficeProfileId;
    }
    
    public List<String> start(Database.BatchableContext bc) {
        return this.activePersonalNumbers;
    }
    
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
    
    public void execute(Database.BatchableContext bc, List<String> activePersonalNumbers) {
        String separateBy = '\\|';
        Integer colPersonalNumber = 1;
        
        // create active users if not exist
        List<User> newUsers = new List<User>();
        for(String activeUser : activePersonalNumbers){
            List<String> userDetail = activeUser.split(separateBy);
            String personalNumber = userDetail[colPersonalNumber];
            User isExist = isUserExist(personalNumber, chmUsers);
            if(isExist == null){
                // create new user
                System.debug('Create new user: ' + userDetail[1] + Label.New_Email_Synced_User);
                User newUser = new User();
                newUser.LastName = userDetail[2];
                newUser.Title = userDetail[3];
                newUser.EmployeeNumber = userDetail[1];
                newUser.FederationIdentifier = userDetail[1];
                newUser.Username = userDetail[1] + Label.New_Email_Synced_User;
                newUser.Email = userDetail[1] + Label.New_Email_Synced_User;
                newUser.Alias = userDetail[1];
                // mapping hilfm agent. other than hilfm agent will be assigned to back office profile
                if(hilfmAgentList.contains(userDetail[4])){
                    newUser.ProfileId = agentProfileId;
                } else {
                    newUser.ProfileId = backOfficeProfileId;
                }
                newUser.IsActive = true;
                newUser.LocaleSidKey = 'en_US';
                newUser.TimeZoneSidKey = 'Asia/Jakarta';
                newUser.EmailEncodingKey = 'UTF-8';
                newUser.LanguageLocaleKey = 'en_US';
                // set custom field
                newUser.SCC_HILFM__c = userDetail[4];
                newUser.SCC_HTEXT__c = userDetail[5];
                newUser.SCC_Tipe_Unit_Kerja__c = userDetail[6];
                newUser.SCC_Area__c = userDetail[7];
                newUser.SCC_Sub_Area__c = userDetail[8];
                newUser.SCC_Cost_Center__c = userDetail[9];
                newUser.SCC_Orgeh__c = userDetail[10];
                newUser.SCC_Area_Description__c = userDetail[11];
                newUser.SCC_Sub_Area_Description__c = userDetail[12];
                newUser.SCC_Cost_Center_Description__c = userDetail[13];
                newUser.SCC_Orgeh_Description__c = userDetail[14];
                newUser.SCC_Branch__c = userDetail[15];

                newUsers.add(newUser);
            }
        }
        if (newUsers.size() > 0) {
            insert newUsers;
        }        
    }
    
    public static User isUserExist(String personalNumber, List<User> chmUsers){
        for(User user : chmUsers){
            if(user.EmployeeNumber == personalNumber){
                return user;
            }
        }
        return null;
    }
}