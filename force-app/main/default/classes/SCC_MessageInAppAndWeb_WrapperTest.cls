/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Christian Vieri
**/
@isTest
public class SCC_MessageInAppAndWeb_WrapperTest {
    @isTest
    public static void testRequestModelCreateConversation() {
        // Create a new instance of RequestModelCreateConversation
        SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation requestModel = new SCC_MessageInAppAndWeb_Wrapper.RequestModelCreateConversation(
            '12345',
            new Map<String, String>{'key1' => 'value1'},
            'Sabrina'
        );
        
        // Assert that the values are correctly set
        System.assertEquals('12345', requestModel.conversationId);
        System.assertEquals('value1', requestModel.routingAttributes.get('key1'));
        System.assertEquals('Sabrina', requestModel.esDeveloperName);
    }
    
    @isTest
    public static void testRequestModelSendMessage() {
        // Create a new instance of RequestModelSendMessage
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage requestModel = new SCC_MessageInAppAndWeb_Wrapper.RequestModelSendMessage();
        
        // Create a new message and set values
        SCC_MessageInAppAndWeb_Wrapper.Message message = new SCC_MessageInAppAndWeb_Wrapper.Message();
        message.inReplyToMessageId = 'message123';
        message.id = 'msg456';
        message.messageType = 'text';
        message.staticContent = new SCC_MessageInAppAndWeb_Wrapper.StaticContent();
        message.staticContent.formatType = 'plain';
        message.staticContent.text = 'Test message content';
        
        // Set the values for the RequestModelSendMessage
        requestModel.esDeveloperName = 'Sabrina';
        requestModel.message = message;
        requestModel.isNewMessagingSession = true;
        requestModel.language = 'en';
        
        // Assert that the values are correctly set
        System.assertEquals('Sabrina', requestModel.esDeveloperName);
        System.assertEquals('message123', requestModel.message.inReplyToMessageId);
        System.assertEquals('plain', requestModel.message.staticContent.formatType);
        System.assertEquals('Test message content', requestModel.message.staticContent.text);
        System.assertEquals(true, requestModel.isNewMessagingSession);
        System.assertEquals('en', requestModel.language);
    }
    
    @isTest
    public static void testRequestModelSendFile() {
        // Create a new instance of MessageForSendFile
        SCC_MessageInAppAndWeb_Wrapper.MessageForSendFile messageForSendFile = new SCC_MessageInAppAndWeb_Wrapper.MessageForSendFile();
        messageForSendFile.inReplyToMessageId = 'message123';
        messageForSendFile.id = 'msg789';
        messageForSendFile.fileId = 'file123';
        messageForSendFile.text = 'Test file content';
        
        // Create a new instance of RequestModelSendFile
        SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile requestModel = new SCC_MessageInAppAndWeb_Wrapper.RequestModelSendFile('TestDeveloper', messageForSendFile, true, 'en');
        
        // Assert that the values are correctly set
        System.assertEquals('TestDeveloper', requestModel.esDeveloperName);
        System.assertEquals('message123', requestModel.message.inReplyToMessageId); 
        System.assertEquals('file123', requestModel.message.fileId); 
        System.assertEquals('Test file content', requestModel.message.text); 
        System.assertEquals(true, requestModel.isNewMessagingSession);
        System.assertEquals('en', requestModel.language);
    }
    
    @isTest
    public static void testResponseModel() {
        // Create a new instance of ResponseModel
        SCC_MessageInAppAndWeb_Wrapper.ResponseModel responseModel = new SCC_MessageInAppAndWeb_Wrapper.ResponseModel();
        
        // Set values for the response model fields
        responseModel.responseCode = '200';
        responseModel.responseMessage = 'Success';
        responseModel.conversationId = '12345';
        responseModel.conversationEntries = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntry>{
            new SCC_MessageInAppAndWeb_Wrapper.ConversationEntry()
        };
        
        // Assert that the values are correctly set
        System.assertEquals('200', responseModel.responseCode);
        System.assertEquals('Success', responseModel.responseMessage);
        System.assertEquals('12345', responseModel.conversationId);
        System.assertNotEquals(0, responseModel.conversationEntries.size());
    }
    
    @isTest
    public static void testResponseModelGM() {
        // Create a new instance of ResponseModelGM
        SCC_MessageInAppAndWeb_Wrapper.ResponseModelGM responseModelGM = new SCC_MessageInAppAndWeb_Wrapper.ResponseModelGM();
        
        // Set values for the response model fields
        responseModelGM.responseCode = '200';
        responseModelGM.responseMessage = 'Success';
        responseModelGM.conversationId = '12345';
        responseModelGM.conversationEntries = new List<SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM>{
            new SCC_MessageInAppAndWeb_Wrapper.ConversationEntryGM()
        };
        
        // Assert that the values are correctly set
        System.assertEquals('200', responseModelGM.responseCode);
        System.assertEquals('Success', responseModelGM.responseMessage);
        System.assertEquals('12345', responseModelGM.conversationId);
        System.assertNotEquals(0, responseModelGM.conversationEntries.size());
    }
}