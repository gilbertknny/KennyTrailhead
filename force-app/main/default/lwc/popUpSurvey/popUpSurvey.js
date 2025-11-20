import { LightningElement,track,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCurrentUserId from '@salesforce/apex/SCC_EmployeeFeedbackController.getCurrentUserId';
import checkSurveyDateActive from '@salesforce/apex/SCC_EmployeeFeedbackController.checkSurveyDateActive';
import checkSurveyInvitation from '@salesforce/apex/SCC_EmployeeFeedbackController.checkSurveyInvitation';
import createSurveyInvitation from '@salesforce/apex/SCC_EmployeeFeedbackController.createSurveyInvitation';
import createNewSurveyInvitation from '@salesforce/apex/SCC_EmployeeFeedbackController.createNewSurveyInvitation';
import { NavigationMixin } from 'lightning/navigation';
import RESPONSE_STATUS_FIELD from '@salesforce/schema/SurveyInvitation.ResponseStatus';
import { refreshApex } from '@salesforce/apex';


const SURVEY_INVITATION_FIELDS = [
    RESPONSE_STATUS_FIELD
];

export default class PopUpSurvey extends NavigationMixin(LightningElement) {
    @track isModalOpen = false;
    @track isActiveSurvey = false;
    @track isSurveyCompleted = false;
    @track surveyId;
    @track surveyInvitationId = '';
    @track userId;
    @track userName;
    @track defaultText ='slds-align_absolute-center btn-send-survey slds-visible'
    @track defaultInformation = 'slds-text-heading_small pulse-subtitle slds-hidden'
    @track linkSurvey;
    @track titleSurvey;
    @track subtitleSurvey;
    @track contentSurvey;
    @track isLoading = true;
    error;

    
    
    @wire(getCurrentUserId)
    wireUserId({ data, error }) {
        if (data) {
            let {userId,userName} = data;
            this.userId = userId;
            this.userName = userName;
            console.log('User ID fetched:', this.userId);
            console.log('User Name fetched: ' , this.userName);
            this.loadSurveyData();
        } else if (error) {
            console.log('Error getting userId:', error.body.message);
        }
    }


    //check by date
    async loadSurveyData() {
        try {
            const result = await checkSurveyDateActive();
            console.log('result' , result);
            if (result) {
                let {content, isOpen, subtitle, surveyID, title} = result;
                this.surveyId = surveyID;
                this.isActiveSurvey = isOpen;
                this.titleSurvey = title;
                this.subtitleSurvey = subtitle;
                this.contentSurvey = content
                console.log('Survey ID fetched:', this.surveyId);
                console.log('Survey active status:', this.isActiveSurvey);  
        
                if (this.userId && this.surveyId) {
                    this.checkInvitationStatus();
                }
            }
        } catch (error) {
            console.log('Error loading survey data:', error.body.message);
        }
    }

    //set survey invitation Id
    async checkInvitationStatus() {
        try {
            const result = await checkSurveyInvitation({
                userId: this.userId,
                surveyId: this.surveyId
            });


            this.surveyInvitationId = result.invitationId;
            this.isSurveyCompleted = result.invitationIsCompleted;
            console.log('survey Invitation id' , result.invitationId);
            console.log('Survey completion status:', this.isSurveyCompleted);


            this.isSurveyCompleted = result.invitationIsCompleted;
            console.log('Survey completion status:', this.isSurveyCompleted);
            this.setVisibilitySurvey();
            
        } catch (error) {
            console.error('Error checking invitation:', error);
        }
    }



    setVisibilitySurvey() {
        if (!this.isActiveSurvey) {
            this.isModalOpen = false;
        } else if (this.isActiveSurvey && !this.isSurveyCompleted) {
            this.isModalOpen = true;
        } else if (this.isActiveSurvey && this.isSurveyCompleted) {
            this.isModalOpen = false;
        }
        console.log('Final survey visibility:', this.isModalOpen);
    }


    async handleSurveyClick(event) {
        event.preventDefault();

        console.log('survey id',this.surveyId);
        console.log('user id',this.userId);
        
        let invitationLink;
        
        try {
            const result = await createSurveyInvitation({
                userId: this.userId,
                surveyId: this.surveyId
            });

            console.log('invitation link :',result);

            
            
            if (result.invitationLink != '') {
                invitationLink = result.invitationLink;
                this.surveyInvitationId = result.surveyInvitationID;
            } else {
                console.log('create new survey');
                let resultCreate = await createNewSurveyInvitation({ userId: this.userId,surveyId: this.surveyId, userName:this.userName});
                invitationLink = resultCreate.invitationLink;
                this.surveyInvitationId = resultCreate.surveyInvitationID;
            }


            if(invitationLink){
                const config = {
                    type: 'standard__webPage',
                    attributes: {
                        url: invitationLink
                    }
                };
                this[NavigationMixin.Navigate](config)

                
                this.defaultText = 'slds-align_absolute-center btn-send-survey slds-hidden';
                this.defaultInformation = 'slds-text-heading_small pulse-subtitle slds-visible';
            }



               
        } catch (error) {
            this.error = error;
            console.log('Error message:', error.body.message);
            console.log('Error details:', error.body.detail);
            console.log('Error stack:', error.stack);
        }
    }


    @wire(getRecord, { recordId: '$surveyInvitationId', fields: SURVEY_INVITATION_FIELDS })
    wiredSurveyInvitation({ data, error }) {
        if (data) {

            console.log('data wire' , data);
            const responseStatus = data.fields.ResponseStatus.value;
            console.log('Response Status', responseStatus)

            if (responseStatus === 'Completed' || responseStatus === 'PartiallyCompleted') {
                this.isModalOpen = false;
                console.log('Survey completed. Closing modal.');
            }   
            
        } else if (error) {
            console.error('Error fetching Survey Invitation:', error);
            this.error = error;
        }
    }



    handleCloseButton(){
        console.log('close modal')
        this.isModalOpen = false;
    }
}