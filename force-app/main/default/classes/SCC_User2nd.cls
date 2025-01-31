global with sharing class SCC_User2nd implements Queueable, Database.AllowsCallouts {
    public integer mulai {get;set;}
    public Map<Integer,List<String>> mapstr {get;set;}
    public integer akhir {get;set;}
    
    global SCC_User2nd(integer num,Map<Integer,List<String>> mapabc,Integer numlast){
        this.mulai = num;
        this.mapstr = mapabc;
        this.akhir = numlast;
    }
    
    global void execute(QueueableContext context) {
        try{
            List<String> userDetail  = mapstr.get(mulai);
            List<String> hilfmAgentList = Label.HILFM_Agent_Contact_Center.split(';');
            List<user> listuser = [select id from user where EmployeeNumber=:userDetail[2] or FederationIdentifier=:userDetail[1] limit 1];
            String orgName = System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName() == null ? '' : '.'+System.DomainParser.parse(URL.getOrgDomainUrl()).getSandboxName() ;
            User us = new User();
            us.LastName = userDetail[3];
            us.Title = userDetail[4];
            us.EmployeeNumber = userDetail[2];
            us.FederationIdentifier = userDetail[1];
            //us.Username = userDetail[2] + Label.New_Email_Synced_User;
            //us.Email = userDetail[2] + Label.New_Email_Synced_User;
            us.Username = us.FederationIdentifier+ orgName; //REPLACE FederationId -> 12.07.24 GS
            us.Email = us.FederationIdentifier+ orgName; //REPLACE FederationId -> 12.07.24 GS
            us.Alias = userDetail[2];
            
            //CHANGE BY ORGEH -> 11.07.24 GS
            String orgeh = userDetail[11];
            String branch = userDetail[16];
            String profileid;
            if(orgeh != null && orgeh != '' && branch == '00299'){ //00299 - KANTOR PUSAT
                List<Orgeh__c> listorg = [SELECT Id,Profile_Id__c FROM Orgeh__c WHERE External_Id__c =:orgeh LIMIT 1];
                if(listorg.size()>0){
                    Orgeh__c org = listorg[0];
                    if(org.Profile_Id__c != null && org.Profile_Id__c != '') {
                        profileid = org.Profile_Id__c;
                    }
                }
            }
            
            if(profileid != null) {
                us.ProfileId = profileid;
            }
            else{
                us.ProfileId = [SELECT Id FROM Profile WHERE Name = :label.Profile_Branch]?.Id;
            }
            /*if(hilfmAgentList.contains(userDetail[4])){
                us.ProfileId = [SELECT Id FROM Profile WHERE Name = :label.Agent_Profile_Name]?.Id;
            } else {
                us.ProfileId = [SELECT Id FROM Profile WHERE Name = :label.Back_Office_Profile_Name]?.Id;
            }*/
            //END CHANGE
            
            if(userDetail[0]=='A' || userDetail[0]=='C'){
                us.IsActive = true;
            }
            else{
                us.IsActive = false;
            }   

            us.LocaleSidKey = 'in_ID';
            us.TimeZoneSidKey = 'Asia/Jakarta';
            us.EmailEncodingKey = 'UTF-8';
            us.LanguageLocaleKey = 'en_US';
            us.EMAILPREFERENCESAUTOBCC = false;
            us.SCC_HILFM__c = userDetail[5];
            us.SCC_HTEXT__c = userDetail[6];
            us.SCC_Tipe_Unit_Kerja__c = userDetail[7];
            us.SCC_Area__c = userDetail[8];
            us.SCC_Sub_Area__c = userDetail[9];
            us.SCC_Cost_Center__c = userDetail[10];
            us.SCC_Orgeh__c = userDetail[11];
            us.SCC_Area_Description__c = userDetail[12];
            us.SCC_Sub_Area_Description__c = userDetail[13];
            us.SCC_Cost_Center_Description__c = userDetail[14];
            us.SCC_Orgeh_Description__c = userDetail[15];
            us.SCC_Branch__c = userDetail[16];
            us.SCC_Job_Position_Date__c = String.isBlank(userDetail[17]) ? null : Date.valueOf(userDetail[17]);    
            if(!listuser.isEmpty()){
                us.id = listuser[0].id;
                update us;
            }
            else{
                insert us;   
            }
        }
        catch(Exception exc){
            SCC_User1st.InsertErrorLog(exc, 'SCC_User2nd');
        }
        finally {
            mulai++;
            if(mulai<=akhir){
                ID jobID = System.enqueueJob(new SCC_User2nd(mulai,mapstr,akhir));
            }
        }
    }   
}