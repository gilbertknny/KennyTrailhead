/**
 * @description       : Wrapper class for request and response models
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 28-01-2025
 * @last modified by  : Christian Vieri
**/
public class SCC_MessageInAppAndWeb_Wrapper {
    
    // Kelas untuk model request create conversation dengan chatbotConversation
    public class RequestModelCreateConversationFull {
        public String conversationId;
        public Map<String, String> routingAttributes;
        public String esDeveloperName;
        public String chatbotConversation;  
    }

    // Kelas untuk model request create conversation tanpa chatbotConversation
    public class RequestModelCreateConversation {
        public String conversationId;
        public Map<String, String> routingAttributes;
        public String esDeveloperName;

        public RequestModelCreateConversation(String conversationId, Map<String, String> routingAttributes, String esDeveloperName) {
            this.conversationId = conversationId;
            this.routingAttributes = routingAttributes;
            this.esDeveloperName = esDeveloperName;
        }
    }
    
    // ResponseModel for API responses
    public class ResponseModel {
        public String responseCode;
        public String responseMessage;
        public String conversationId;
        public List<ConversationEntry> conversationEntries;
    }

    public class ConversationEntry {
        public String id;
        public Long clientTimestamp;
    }

    public class RequestModelSendMessage {
        public String esDeveloperName;
        public Message message;
        public Boolean isNewMessagingSession;
        public String language;
    }

    public class RequestModelSendFile {
        public String esDeveloperName;
        public MessageForSendFile message;
        public Boolean isNewMessagingSession;
        public String language;

        public RequestModelSendFile(String esDeveloperName, MessageForSendFile message, Boolean isNewMessagingSession, String language) {
            this.esDeveloperName = esDeveloperName;
            this.message = message;
            this.isNewMessagingSession = isNewMessagingSession;
            this.language = language;
        }
    }

    public class Message {
        public String inReplyToMessageId;
        public String id;
        public String messageType;
        public StaticContent staticContent;  
    }

    public class MessageForSendFile {
        public String inReplyToMessageId;
        public String id;
        public String fileId;  
        public String text;
    }

    public class StaticContent {
        public String formatType;
        public String text;
    }

    public class ResponseModelGM {
        public String responseCode;
        public String responseMessage;
        public String conversationId;
        public List<ConversationEntryGM> conversationEntries;
    }

    public class ConversationEntryGM {
        public Integer clientDuration;
        public Long clientTimestamp;
        public String identifier;
        public String messageText;
        public Sender sender;
        public Long serverReceivedTimestamp;
    }

    public class Sender {
        public String appType;
        public String role;
        public String subject;
    }
}