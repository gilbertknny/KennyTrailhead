public without sharing class SCC_InvocableDrone {
    @InvocableMethod(label='Invocable Drone' description='Call apex' category='Invocable')
    public static void Invocablevoid(List<InputVariable> inputVariable){
        try {
            for(InputVariable iv: inputVariable){
                if(iv.param == 'Create Ticket Drone') SCC_InvocableDrone.createTicketDrone(iv.recordId);
                if(iv.param == 'Update Ticket Drone') SCC_InvocableDrone.updateTicketDrone(iv.recordId);
            }
        } catch (Exception error) {
            System.debug('Error occured'+error.getMessage());
        } 
    }

    public static void createTicketDrone(id recordId) {
        if(UserInfo.getUserName().contains('Platform Integration User')){
            /*Drone__c d = new Drone__c();
            d.Case__c = recordId;
            d.Status__c = 'Draft';
            d.Method__c = 'Insert';
            insert d;*/
            //sendCreateToDrone(recordId); //call with scheduler
        }else{
            sendCreateToDroneFuture(recordId);
        }
    }
    
    public static void sendCreateToDrone(id recordId){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            //Id recordId = inputVariable.get(0).recordId;

            //List<SCC_DroneAPIWrapper.RequestCreateTicketDrone> jreqList = new List<SCC_DroneAPIWrapper.RequestCreateTicketDrone>();
            SCC_DroneAPIWrapper.RequestCreateTicketDrone jreq = new SCC_DroneAPIWrapper.RequestCreateTicketDrone();
            Case c=[SELECT Id,
                            CaseNumber,
                            ContactId,
                            Description,
                            Account.name,
                    		status,
                    		ownerid,
                            SCC_Account_Number__c,
                            SCC_Transaction_Date__c,
                            SCC_Card_Number__c,
                            SCC_Call_Type__c,
                            SCC_Call_Type__r.Name,
                            SCC_Call_Type__r.External_Id__c,
                            SCC_Branch_Unit__r.Name,
                            SCC_Amount__c,
                            SCC_Remark__c,
                            SCC_Cust_Phone1__c,
                            Cust_Current_Phone__c,
                            SCC_Email__c
                       FROM Case Where Id =:recordId];
                jreq.ticket_no_chm = c.CaseNumber;
                jreq.cust_name = C.Account.name;
                jreq.acct_no = c.SCC_Account_Number__c;
                jreq.card_no = c.SCC_Card_Number__c;
                jreq.call_type = c.SCC_Call_Type__r.External_Id__c;
                jreq.branch = null;
                jreq.trx_date = String.valueOf(DateTime.newInstance(c.SCC_Transaction_Date__c.year(),c.SCC_Transaction_Date__c.month(),c.SCC_Transaction_Date__c.day()).format('yyyy-MM-dd'));
                jreq.amount = String.valueOf(c.SCC_Amount__c);
                jreq.remark = c.SCC_Remark__c;
                jreq.notelp = String.isBlank(c.Cust_Current_Phone__c) ? '000000000000' : c.Cust_Current_Phone__c.replaceAll('[^0-9]', '');
                jreq.email = c.SCC_Email__c;
                jreq.description = c.Description;
            
            SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('CreateTicketDrone', JSON.serialize(jreq),'','SCC_InvocableDrone');
            /*
            SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance('CreateTicketDrone');
            String endpoint = eapi.Named_Credential__C+eapi.Directory__c;
            String method = eapi.Method__c;
            String body = JSON.serialize(jreq);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
            res = http.send(req);
			*/
            Map<String, Object> resultMap =   (Map<String, Object>) JSON.deserializeUntyped(wapi.res.getBody());
			req = wapi.req;
            res = wapi.res;
            //SCC_DroneAPIWrapper.ResponseCreateTicket data = JSON.deserialize(incomingJSON, SCC_DroneAPIWrapper.ResponseCreateTicket.class);

            //get inner child from resultMap ('data')
            Map<String, Object> dataMap = (Map<String, Object>)resultMap.get('data');

            Case caseUpdate = new Case();
            if(res.getStatusCode() == 200){
                    caseUpdate.Id = c.Id;
                	caseUpdate.status = 'Escalated';
                    caseUpdate.SCC_Drone_Ticket_ID__c = String.valueOf(dataMap.get('ticket_no'));

                    update caseUpdate;
            }
        }
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError('','SCC_InvocableDrone')); 
        }
    }

    public static void updateTicketDrone(id recordId) {
        System.debug('updateTicketDrone');
        if(UserInfo.getUserName().contains('Platform Integration User')){
            /*Drone__c d = new Drone__c();
            d.Case__c = recordId;
            d.Status__c = 'Draft';
            d.Method__c = 'Update';
            insert d;*/
            
         
            //sendUpdateToDrone(recordId); //call with scheduler
        }else{
            sendUpdateToDroneFuture(recordId);
        }
        
    }
    
    @future (callout=true)
    public static void sendCreateToDroneFuture(id recordId){
        sendCreateToDrone(recordId);
    }
    
    @future (callout=true)
    public static void sendUpdateToDroneFuture(id recordId){
        sendUpdateToDrone(recordId);
    }
    
    public static void sendUpdateToDrone(id recordId){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            //Id recordId = inputVariable.get(0).recordId;

            //List<SCC_DroneAPIWrapper.RequestUpdateTicketDrone> jreqList = new List<SCC_DroneAPIWrapper.RequestUpdateTicketDrone>();
            SCC_DroneAPIWrapper.RequestUpdateTicketDrone jreq = new SCC_DroneAPIWrapper.RequestUpdateTicketDrone();

            for(Case c:[SELECT Id,
                       SCC_Drone_Ticket_ID__c,
                       Casenumber,
                       Case_Number__c,
                       SCC_Case_Owner__c,
                       SCC_Remark__c
                       FROM Case Where Id =:recordId]){

                jreq.ticket_no_chm = c.Case_Number__c;
                jreq.remark = '['+Datetime.now().addHours(7)+' '+UserInfo.getName()+']'+' '+c.SCC_Remark__c;
            }
			SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('UpdateTicketDrone', JSON.serialize(jreq),'','SCC_InvocableDrone');
            req = wapi.req;
            res = wapi.res;
            /*
            SCC_Endpoint_API__mdt eapi = SCC_Endpoint_API__mdt.getInstance('UpdateTicketDrone');
            String endpoint = eapi.Named_Credential__C+eapi.Directory__c;
            String method = eapi.Method__c;
            String body = JSON.serialize(jreq);
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
            res = http.send(req);
            */
            
		}
        catch(exception exc){
            SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError('','SCC_InvocableDrone')); 
        }
    }

    public class InputVariable {
        @InvocableVariable
        public Id recordId;
        @InvocableVariable
        public String param;
    }

}