public with sharing class SCC_EmployeeFeedbackController {

    public class surveyDataWrapper{
        @AuraEnabled
        public String surveyID {get;set;}
        @AuraEnabled
        public Boolean isOpen {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String subtitle {get;set;}
        @AuraEnabled
        public String content {get;set;}

        public surveyDataWrapper(String surveyID, Boolean isOpen, String title, String subtitle, String content){
            this.surveyID = surveyID;
            this.isOpen = isOpen;
            this.title = title;
            this.subtitle = subtitle;
            this.content = content;
        }
    }


    public class userInfoWrapper {
        @AuraEnabled
        public String userId {get;set;}
        @AuraEnabled
        public String userName {get;set;}

        public userInfoWrapper(String userId, String userName){
            this.userId = userId;
            this.userName = userName;
        }
    }

    public class surveyInvitationDataWrapper{
        @AuraEnabled
        public String surveyInvitationID {get; set;}
        @AuraEnabled
        public Boolean invitationIsCompleted {get;set;}
        @AuraEnabled
        public String invitationLink {get;set;}
        

        public surveyInvitationDataWrapper(String surveyInvitationID, Boolean invitationIsCompleted,String invitationLink ){
            this.surveyInvitationID = surveyInvitationID;
            this.invitationIsCompleted = invitationIsCompleted;
            this.invitationLink = invitationLink;
        }
    }



    @AuraEnabled(cacheable=true)
    public static userInfoWrapper getCurrentUserId() {
        try{

            String userId = UserInfo.getUserId();
            String userName = UserInfo.getUserName();

            userInfoWrapper usr = new userInfoWrapper(userId,userName);

            return usr;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static surveyDataWrapper checkSurveyDateActive(){

        Boolean isOpen = false;
        String surveyId;
        String title;
        String subtitle;
        String content;



        List<Employee_Survey__c> employeeSurvey = [
            SELECT Id, Start_Date__c, End_Date__c,Survey__c,Title__c,Subtitle__c,Content__c
            FROM Employee_Survey__c 
            WHERE Active__c = true
        ] ;
        

        if(employeeSurvey.size() > 0){
            Employee_Survey__c emp = employeeSurvey[0];
            surveyId = emp.Survey__c;

            Date startDate = emp.Start_Date__c;
            Date endDate = emp.End_Date__c;
            Date todayDate = Date.today();
            title = emp.Title__c;
            subtitle = emp.Subtitle__c;
            content = emp.Content__c;


            // if(todayDate >= startDate && todayDate != endDate  && todayDate < endDate){
            //     isOpen = true;
            // }

            if(todayDate >= startDate && todayDate <= endDate){
                isOpen = true;
            }
        }
        

        surveyDataWrapper resultSurvey = new surveyDataWrapper(surveyId,isOpen,title,subtitle,content);

        return resultSurvey;
    }

    @AuraEnabled(cacheable=true)
    public static surveyInvitationDataWrapper checkSurveyInvitation(String userId, String surveyId){

        String invitationStatus;
        Boolean invitationIsCompleted = false;
        String invitationId = '';

        List<SurveyInvitation> surveyInvitation = [SELECT Id,Name,Responden__c , ResponseStatus,InvitationLink FROM SurveyInvitation WHERE Responden__c = :userId AND SurveyId =: surveyId]; 

        if(surveyInvitation.size() > 0){
            SurveyInvitation invitationUser = surveyInvitation[0];
            invitationStatus = invitationUser.ResponseStatus;
            invitationId = invitationUser.Id;

            if(invitationStatus == 'NotStarted' || invitationStatus == 'Started' || invitationStatus == 'Paused') {
                invitationIsCompleted = false;
            }

            if(invitationStatus == 'Completed' || invitationStatus == 'PartiallyCompleted'){
                invitationIsCompleted = true;
            }
        }

        surveyInvitationDataWrapper si = new surveyInvitationDataWrapper(invitationId,invitationIsCompleted,'');

        return si;
    }

    @AuraEnabled(cacheable=true)
    public static SurveyInvitationDataWrapper createSurveyInvitation(String userId,String surveyId){

        String invitationLink = '';
        String invitationId = '';
        
        List<SurveyInvitation> surveyInvitation = [SELECT Id,Name,Responden__c , ResponseStatus,InvitationLink FROM SurveyInvitation WHERE Responden__c = :userId AND SurveyId =: surveyId]; 
        
        if(surveyInvitation.size() > 0){
            SurveyInvitation invitationUser = surveyInvitation[0];
            invitationLink = invitationUser.InvitationLink;
            invitationId = invitationUser.Id;
        }   

        SurveyInvitationDataWrapper si = new surveyInvitationDataWrapper(invitationId,false,invitationLink);

        
        return si;
    
    }

    @AuraEnabled(cacheable=false)
    public static SurveyInvitationDataWrapper createNewSurveyInvitation(String userId, String surveyId, String userName) {
    try {
        SurveyInvitation newInvitation = new SurveyInvitation(
            Name = 'Feedback Survey - ' + userName + ' - ' + userId,
            SurveyId = surveyId,
            CommunityId = System.Label.CommunityId,
            OptionsAllowGuestUserResponse = True,
            Responden__c = userId
        );

        insert newInvitation;
  
        SurveyInvitation invitationWithLink = [
            SELECT InvitationLink, Id 
            FROM SurveyInvitation 
            WHERE Id = :newInvitation.Id 
            LIMIT 1
        ];

        String link = invitationWithLink.InvitationLink;
        String id = invitationWithLink.Id;

        SurveyInvitationDataWrapper si = new surveyInvitationDataWrapper(id,false,link);

        
        return si;

    } catch (Exception e) {
        throw new AuraHandledException('Failed to create survey invitation: ' + e.getMessage());
    }
}

}