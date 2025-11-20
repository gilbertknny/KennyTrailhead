public class SCC_HttpReq_BlokirPL {
    @AuraEnabled
	public static void sendBlokir(string ChannelID,string Password,string Action,string CardNo,string UserMaintain){
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HTTPResponse res = new HTTPResponse();
        try{
            data d = new data();
            d.ChannelID = ChannelID;
            d.Password = Password;
            d.Action = Action;
            d.CardNo = CardNo;
            d.UserMaintain = UserMaintain;
            SCC_API.WrapperAPI wapi = SCC_API.getResponseAPI('BlokirKartuPL', JSON.serialize(d),'','SCC_HttpReq_BlokirPL');
            req = wapi.req;
            res = wapi.res;
            SCC_API.InsertErrorLog(null,req,res,new SCC_API.WrapperError('','SCC_HttpReq_BlokirPL')); 
        }catch(exception exc){
            SCC_API.InsertErrorLog(exc,req,res,new SCC_API.WrapperError('','SCC_HttpReq_BlokirBL')); 
        }
    }
    
    public class data {
    	public string ChannelID;
        public string Password;
        public string Action;
        public string CardNo;
        public string UserMaintain;
    }
}