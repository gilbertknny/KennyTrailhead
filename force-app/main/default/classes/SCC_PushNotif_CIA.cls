/**
 * @description       : Apex Class for Integration push notification to BRIMO (Queueable)
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 07-03-2025
 * @last modified by  : Christian Vieri
**/

public without sharing class SCC_PushNotif_CIA implements Queueable, Database.AllowsCallouts {
    
    // List of BRIMOStatusRequest passed from Flow
    private List<BRIMOStatusRequest> requestList;
    
    // Constructor to pass data into the Queueable job
    public SCC_PushNotif_CIA(List<BRIMOStatusRequest> requestList) {
        this.requestList = requestList;
    }

    // The execute method of the Queueable interface
    public void execute(QueueableContext context) {
        Http http = new Http();        
        for (BRIMOStatusRequest request : requestList) {
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            try {
                // Convert Timestamp
                Long timestamp = DateTime.now().getTime();
                system.debug('ini timestamp: ' + timestamp);
                
                // Request Body
                String requestBody = '{' +
                    '"client": "CHMCIA",' + //seharusnya nanti di adjust CHM
                    '"channelId": "CHM",' +
                    '"timestamp": "' + timestamp + '",' +
                    '"requestRefnum": "' + request.requestRefNum + '",' +
                    '"accountNumber": "' + request.accountNumber + '",' +
                    '"troubleTicketId": "' + request.troubleTicketId + '",' +
                    '"ticketStatus": "' + request.ticketStatus + '"' +
                '}';
                
                SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('Push_Notification_CIA', requestBody, '', 'SCC_PushNotif_CIA');
                req = wapi.req;
                res = wapi.res;
                
                system.debug('request: ' + req);
                system.debug('response: ' + res);
                
                if (res.getStatusCode() == 200) {
                    System.debug('API call successful for Case: ' + request.troubleTicketId);
                    SCC_API.InsertErrorLog(null, req, res, new SCC_API.WrapperError('', 'SCC_PushNotif_CIA'));  
                } else {
                    System.debug('API call failed for Case: ' + request.troubleTicketId + ' with status: ' + res.getStatus());
                    SCC_API.InsertErrorLog(null, req, res, new SCC_API.WrapperError('', 'SCC_PushNotif_CIA')); 
                }
                
            } catch (Exception e) {
                System.debug('Error during API call: ' + e.getMessage());
                SCC_API.InsertErrorLog(e, req, res, new SCC_API.WrapperError('', 'SCC_PushNotif_CIA')); 
            }
        }
    }

    // Invocable method for Flow integration
    @InvocableMethod(label='Call BRIMO API Queueable' description='Method to call BRIMO API based on Status asynchronously')
    public static void callBRIMOAPIQueueable(List<BRIMOStatusRequest> requestList) {
        System.enqueueJob(new SCC_PushNotif_CIA(requestList));
    }

    // Data dari Flow
    public class BRIMOStatusRequest {
        @InvocableVariable(label='Account Number' description='Account number from Case')
        public String accountNumber;
        
        @InvocableVariable(label='Trouble Ticket ID' description='Case Number')
        public String troubleTicketId;
        
        @InvocableVariable(label='Ticket Status' description='The status from Status_BRIMO__c field')
        public String ticketStatus;

        @InvocableVariable(label='RequestRefNum' description='Random Number for Request Ref Num')
        public String requestRefNum;
    }
}

//testinggg