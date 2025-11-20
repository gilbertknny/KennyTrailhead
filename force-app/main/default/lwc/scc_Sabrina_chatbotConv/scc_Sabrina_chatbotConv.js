// import { LightningElement, api, wire, track } from 'lwc';
// import { getRecord } from 'lightning/uiRecordApi';
// import CHATBOT_CONVERSATION_FIELD from '@salesforce/schema/MessagingSession.Chatbot_Conversation__c';

// export default class scc_Sabrina_chatbotConv extends LightningElement {
//     @api recordId;
//     @track formattedConversations = [];

//     @wire(getRecord, { recordId: '$recordId', fields: [CHATBOT_CONVERSATION_FIELD] })
//     wiredRecord({ error, data }) {
//         if (data) {
//             this.formatConversations(data.fields.Chatbot_Conversation__c.value);
//             console.log("test format Conversation:" + data.fields.Chatbot_Conversation__c.value);
//             console.log("format Conversation:" + this.formattedConversations);
//         } else if (error) {
//             console.error('Error retrieving record:', error);
//         }
//     }

//     formatConversations(rawInput) {
//         if (!rawInput) return;
    
//         console.log("Before Processing:", rawInput);
    
//         // Pecah data berdasarkan '//'
//         const lines = rawInput.split('//').map(line => line.trim()).filter(line => line);
//         this.formattedConversations = [];
    
//         lines.forEach((line, index) => {
//             try {
//                 console.log(`Processing line ${index + 1}:`, line);
    
//                 // Menambahkan kurung kurawal jika belum ada
//                 let validJson = `{${line}}`;
    
//                 console.log(`Formatted JSON at line ${index + 1}:`, validJson);
    
//                 // Parsing JSON
//                 const json = JSON.parse(validJson);
    
//                 // Tambahkan ke array formattedConversations
//                 this.formattedConversations.push({
//                     id: index,
//                     sender: json.sender || 'Unknown',
//                     messageText: json.messageText || ''
//                 });
//             } catch (error) {
//                 console.error(`Invalid JSON format at line ${index + 1}:`, line, error);
//             }
//         });
    
//         console.log("Formatted Conversations:", this.formattedConversations);
//     }
    
    
// }

import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import CHATBOT_CONVERSATION_FIELD from '@salesforce/schema/MessagingSession.Chatbot_Conversation__c';

export default class scc_Sabrina_chatbotConv extends LightningElement {
    @api recordId;
    @track formattedConversations = [];

    @wire(getRecord, { recordId: '$recordId', fields: [CHATBOT_CONVERSATION_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            this.formatConversations(data.fields.Chatbot_Conversation__c.value);
        } else if (error) {
            console.error('Error retrieving record:', error);
        }
    }

    formatConversations(rawInput) {
        if (!rawInput) return;
        
        console.log("Processing conversation data");
        this.formattedConversations = [];

        const conversationRegex = /"sender":"([^"]*)"\s*,\s*"messageText":"([^"]*)"/g;
        let match;
        let index = 0;
        
        while ((match = conversationRegex.exec(rawInput)) !== null) {
            const sender = match[1];
            const messageText = this.processMessageText(match[2]);
            
            this.formattedConversations.push({
                id: index++,
                sender: sender || 'Unknown',
                messageText: messageText || ''
            });
        }
        
        console.log(`Processed ${this.formattedConversations.length} conversation messages`);
    }
    
    processMessageText(text) {
        if (!text) return '';
        
        // Convert URLs to anchor tags for clickability
        const urlRegex = /(https?:\/\/[^\s]+)/g;
        return text.replace(urlRegex, '<a href="$1" target="_blank">$1</a>');
    }
}