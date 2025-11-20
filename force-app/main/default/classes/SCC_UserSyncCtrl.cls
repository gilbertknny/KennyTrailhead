public with sharing class SCC_UserSyncCtrl implements Queueable, Database.AllowsCallouts{
    public void execute(QueueableContext context) { 
        String separateBy = '\\|';
        Integer colType = 0;
        Integer colPersonalNumber = 1;
        String agentProfileName = Label.Agent_Profile_Name;
        Id agentProfileId = [SELECT Id FROM Profile WHERE Name = :agentProfileName]?.Id;
        String backOfficeProfileName = Label.Back_Office_Profile_Name;
        Id backOfficeProfileId = [SELECT Id FROM Profile WHERE Name = :backOfficeProfileName]?.Id;
        Map<String, Object> params = new Map<String, Object>();
        String reqBody = '';
        if(Test.isRunningTest()){
            reqBody = '{"status": true,"code": 200,"message": "Success to get Users Data","data": ["Type|Pernr|Nama|CorpTitle|Hilfm|Htext|TipeUker|Area|SubArea|CostCenter|Orgeh|AreaDesc|SubAreaDesc|CostCenterDesc|OrgehDesc|Branch|DatePosition","T|10002613|Tetty Siagian|A|066|Customer Service|UN|KW02|RB02|WB33670|50562519|Regional Office Medan|Medan Iskandar|UNIT MEDAN LABUHAN|TERAS PASAR RAMBE|05321|2024-05-07T00:00:00+07:00","C|10002813|Netty Herawaty Sitorus|A|066|Customer Service|KCP|KW02|RB17|WB36706|70360336|Regional Office Medan|Sisingamangarja|KCP SUKARAMAI|FUNGSI OPERASIONAL & LAYANAN|01086|2024-05-07T00:00:00+07:00","A|10002815|Elizabeth Riris Siagian|A|066|Customer Service|KC|KW02|RB20|WB40410|50415410|Regional Office Medan|Medan Gatsu|KK RS HELVETIA|KANTOR KAS RS HELVETIA|00404|2024-05-07T00:00:00+07:00"]}';
        } else {
            reqBody = SCC_IntegrationUtility.sendData('Get_Update_User', params);
        }
        system.debug('reqbody');
        System.debug(reqBody);

        Map<String, Object> untypedMap = (Map<String, Object>)JSON.deserializeUntyped(reqBody);
        // convert untypedMap to list of string
        List<String> dataUser = new List<String>();
        for(Object obj : (List<Object>)untypedMap.get('data')){
            dataUser.add((String)obj);
        }
        System.debug('dataUser: ' + dataUser);
        // List<String> dataUser = (List<String>)untypedMap.get('data');
        // get all users from User object
        List<User> chmUsers = [
            SELECT Id, 
                    LastName, 
                    Title, 
                    EmployeeNumber, 
                    ProfileId, 
                    FederationIdentifier, 
                    UserName, 
                    Email, 
                    Alias, 
                    IsActive,
                    SCC_HILFM__c,
                    SCC_HTEXT__c,
                    SCC_Tipe_Unit_Kerja__c,
                    SCC_Area__c,
                    SCC_Sub_Area__c,
                    SCC_Cost_Center__c,
                    SCC_Orgeh__c,
                    SCC_Area_Description__c,
                    SCC_Sub_Area_Description__c,
                    SCC_Cost_Center_Description__c,
                    SCC_Orgeh_Description__c,
                    SCC_Branch__c
                FROM User WHERE Profile.Name = :agentProfileName OR Profile.Name = :backOfficeProfileName];
        List<String> activePersonalNumbers = new List<String>();
        List<String> inactivePersonalNumbers = new List<String>();
        List<String> changedUsers = new List<String>();

        // mapping hilfm agent. other than hilfm agent will be assigned to back office profile
        String hilfmAgent = Label.HILFM_Agent_Contact_Center;
        List<String> hilfmAgentList = hilfmAgent.split(';');
        System.debug('hilfmAgentList: ' + hilfmAgentList);
        for(String user : dataUser){
            //System.debug('user: ' + user);
            // skip the first line
            if(user.contains('Type|Pernr|Nama|CorpTitle')){
                continue;
            }
            List<String> userDetail = user.split(separateBy);
            //System.debug('userDetail: ' + userDetail);
            String type = userDetail[colType];
            if(type == 'A'){
                // active user
                activePersonalNumbers.add(user);
            } else if(type == 'T') {
                // inactive user
                inactivePersonalNumbers.add(user);
            } else if(type == 'C') {
                // changed user
                changedUsers.add(user);
            } else {
                // unknown type
                continue;
            }
        }
        
        //test
        Id jobId = Database.executeBatch(new testinsert(activePersonalNumbers, chmUsers, 
                                         hilfmAgentList, agentProfileId, backOfficeProfileId), 2000);

            
        /*
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

        // update changed users
        List<User> updatedUsers = new List<User>();
        for(String changedUser : changedUsers){
            System.debug('changedUser: ' + changedUser);
            List<String> userDetail = changedUser.split(separateBy);
            String personalNumber = userDetail[colPersonalNumber];
            User existUser = isUserExist(personalNumber, chmUsers);
            System.debug('existUser: ' + existUser);
            if(existUser != null){
                existUser.LastName = userDetail[2];
                existUser.Title = userDetail[3];
                existUser.FederationIdentifier = userDetail[1];
                // mapping hilfm agent. other than hilfm agent will be assigned to back office profile
                if(hilfmAgentList.contains(userDetail[4])){
                    existUser.ProfileId = agentProfileId;
                } else {
                    existUser.ProfileId = backOfficeProfileId;
                }
                // set custom field
                existUser.SCC_HILFM__c = userDetail[4];
                existUser.SCC_HTEXT__c = userDetail[5];
                existUser.SCC_Tipe_Unit_Kerja__c = userDetail[6];
                existUser.SCC_Area__c = userDetail[7];
                existUser.SCC_Sub_Area__c = userDetail[8];
                existUser.SCC_Cost_Center__c = userDetail[9];
                existUser.SCC_Orgeh__c = userDetail[10];
                existUser.SCC_Area_Description__c = userDetail[11];
                existUser.SCC_Sub_Area_Description__c = userDetail[12];
                existUser.SCC_Cost_Center_Description__c = userDetail[13];
                existUser.SCC_Orgeh_Description__c = userDetail[14];
                existUser.SCC_Branch__c = userDetail[15];

                updatedUsers.add(existUser);
            }
        }

        if (updatedUsers.size() > 0) {
            System.debug('updatedUsers: ' + updatedUsers);
            update updatedUsers;
        }

        // deactivate inactive users
        List<User> deactivatedUsers = new List<User>();
        for(String inactiveUser : inactivePersonalNumbers){
            List<String> userDetail = inactiveUser.split(separateBy);
            String personalNumber = userDetail[colPersonalNumber];
            User existUser = isUserExist(personalNumber, chmUsers);
            if(existUser != null){
                existUser.IsActive = false;
                deactivatedUsers.add(existUser);
            }
        }

        if (deactivatedUsers.size() > 0) {
            update deactivatedUsers;
        }*/
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