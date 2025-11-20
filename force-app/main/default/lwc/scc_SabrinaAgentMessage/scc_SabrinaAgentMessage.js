import { LightningElement, api, track } from 'lwc';
import getSessionDetails from '@salesforce/apex/scc_SabrinaMilestoneCtrl.getSessionDetails';
import sendMessage from '@salesforce/apex/scc_SabrinaMilestoneCtrl.sendMessage';
import getPublicLink from '@salesforce/apex/scc_SabrinaMilestoneCtrl.getPublicLink';

export default class Scc_SabrinaAgentMessage extends LightningElement {
    @api recordId;
    @track isProcessing = false;
    @track uploadedMedia = '';

    connectedCallback() {
        this.registerMessageHandler();
    }

    registerMessageHandler() {
        // Subscribe to conversation events
        window.addEventListener('lightning__conversationagentsend', this.handleAgentSend.bind(this));
        window.addEventListener('lightning__conversationfileupload', this.handleFileUpload.bind(this));
    }

    disconnectedCallback() {
        // Cleanup event listeners
        window.removeEventListener('lightning__conversationagentsend', this.handleAgentSend.bind(this));
        window.removeEventListener('lightning__conversationfileupload', this.handleFileUpload.bind(this));
    }

    async handleFileUpload(event) {
        try {
            console.log('File upload detected');
            // Add small delay to ensure file is processed
            await this.delay(1000);
            
            const publicUrl = await getPublicLink({ sessionId: this.recordId });
            if (publicUrl) {
                console.log('Retrieved public URL:', publicUrl);
                this.uploadedMedia = publicUrl;
            }
        } catch (error) {
            console.error('Error handling file upload:', error);
        }
    }

    async handleAgentSend(event) {
        if (this.isProcessing) {
            console.log('Message processing in progress, preventing double send');
            return;
        }

        try {
            this.isProcessing = true;
            const messagePayload = event.detail.content;

            const sessionDetails = await getSessionDetails({ 
                sessionId: this.recordId 
            });

            if (!sessionDetails) {
                throw new Error('Invalid session details');
            }

            // Send message with any uploaded media
            await this.sendMessageWithMedia(
                sessionDetails.Conversation.ConversationIdentifier,
                messagePayload,
                sessionDetails.MessagingEndUser.Name
            );

            console.log('Message sent successfully');
            // Clear media after successful send
            this.uploadedMedia = '';

        } catch (error) {
            console.error('Error sending message:', error);
        } finally {
            this.isProcessing = false;
        }
    }

    async sendMessageWithMedia(ticketNumber, message, customerName) {
        try {
            const mediaLink = this.uploadedMedia || '';
            console.log('Sending message with media:', mediaLink);

            await sendMessage({
                ticketNumber: ticketNumber,
                message: message,
                customerName: customerName,
                mediaLink: mediaLink
            });
        } catch (error) {
            console.error('Error in sendMessageWithMedia:', error);
            throw error;
        }
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}