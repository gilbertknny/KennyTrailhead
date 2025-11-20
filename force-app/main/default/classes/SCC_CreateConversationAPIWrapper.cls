/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 20-11-2024
 * @last modified by  : Christian Vieri
**/
public class SCC_CreateConversationAPIWrapper {
    
    // RequestModel untuk Create Conversation
    public class RequestModelCreateConversation {
        public String conversationId;
        public Map<String, String> routingAttributes;
        public String esDeveloperName;
    }

    // RequestModel untuk Send Message
    public class RequestModelSendMessage {
        public String esDeveloperName;
        public Message message;
        public Boolean isNewMessagingSession;
        public String language;
    }

    // RequestModel untuk Send File
    public class RequestModelSendFile {
        public String esDeveloperName;
        public MessageForSendFile message;
        // public Map<String, String> routingAttributes;
        public Boolean isNewMessagingSession;
        public String language;
        
        // Constructor to initialize fields
        public RequestModelSendFile(String esDeveloperName, MessageForSendFile message, /*Map<String, String> routingAttributes,*/ Boolean isNewMessagingSession, String language) {
            this.esDeveloperName = esDeveloperName;
            this.message = message;
            // this.routingAttributes = routingAttributes;
            this.isNewMessagingSession = isNewMessagingSession;
            this.language = language;
        }
    }

    // Kelas MessageForSendMessage
    public class Message {
        public String inReplyToMessageId;
        public String id;
        public String messageType;
        public StaticContent staticContent;  
    }

    // Kelas MessageForSendFile, digunakan oleh RequestModelSendFile dan tidak memiliki staticContent
    public class MessageForSendFile {
        public String inReplyToMessageId;
        public String id;
        public String fileId;  //file id untuk file yang dikirim
        public String text;
    }

    // Kelas StaticContent dideklarasikan terpisah, digunakan oleh MessageForSendMessage
    public class StaticContent {
        public String formatType;
        public String text;
    }

    // ResponseModel untuk response API
    public class ResponseModel {
        public String responseCode;
        public String responseMessage;
        public String conversationId;
        public List<ConversationEntry> conversationEntries;
    }

    // Kelas ConversationEntry
    public class ConversationEntry {
        public String id;
        public Long clientTimestamp;
    }

    private final static string Boundary = '----------------------------551612556338371171594181';
    
    public static string WriteBoundary() {
        string value = Boundary + '\r\n';
        blob valueBlob = blob.valueOf(value);
        return EncodingUtil.base64Encode(valueBlob);
    }

    public static string WriteBoundaryBody(String body){
        blob blobBody = blob.valueOf(body);
        return EncodingUtil.base64Encode(blobBody);
    }

    public static string WriteBoundaryFooter(){
        string value = Boundary + '--';
        blob valueBlob = blob.valueOf(value);
        return EncodingUtil.base64Encode(valueBlob);
    }

    public static String WriteFile(Blob file){
        String file64 = EncodingUtil.base64Encode(file);
        integer file64Length = file64.length();
        string file64Ending = file64.substring(file64Length - 3, file64Length);

        if (file64Ending.endsWith('==')) {

            file64Ending = file64Ending.substring(0, 1) + '0K';//   0K = \r\n

            file64 = file64.substring(0, file64Length - 3) + file64Ending;

        } else if (file64Ending.endsWith('=')) {

            file64Ending = file64Ending.substring(0, 2) + 'N';//    N = \r

            file64 = file64.substring(0, file64Length - 3) + file64Ending;

        }
        return file64;
    }

    // public class WriteFileResult {
    //     public final string Content { get; private set; }
    //     public final EndingType EndingType { get; private set; }
    //     public WriteFileResult(string content, EndingType ending) {
    //         this.Content = content;
    //         this.EndingType = ending;
    //     }
    // }

}