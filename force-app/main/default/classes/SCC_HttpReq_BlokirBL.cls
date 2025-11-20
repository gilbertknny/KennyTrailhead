public without sharing class SCC_HttpReq_BlokirBL {
    @AuraEnabled
    public static void sendBlokir(string cardNumber,string terminalId){
        System.debug('Nomor Kartu :' + cardNumber);
        System.debug('Terminal ID :' + terminalId);
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            data d = new data();
            d.cardNumber = cardNumber;
            d.terminalId = terminalId;
            SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('BlokirKartuBL', JSON.serialize(d),'','SCC_HttpReq_BlokirBL');
            req = wapi.req;
            res = wapi.res;
            system.debug('req:'+req);
            system.debug('res:'+res);
            SCC_API.InsertErrorLog(null,req,res,new SCC_API.WrapperError('','SCC_HttpReq_BlokirBL')); 
        }catch(exception exc){
            SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError('','SCC_HttpReq_BlokirBL')); 
        }
    }
    
    public class data {
    	public string cardNumber;
        public string terminalId;
    }
}