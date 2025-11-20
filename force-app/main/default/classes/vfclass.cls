public class vfclass {
    public String htmltext {get;set;}
    public vfclass(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:ClosedDevBRI/gateway/apiCHM/1.0/token');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        htmltext = res.getbody();
        //htmltext = 'callout:ClosedDevBRI/gateway/apiCHM/1.0/token';
        //htmltext = '<!DOCTYPE html><html><body><h2>HTML Iframes</h2><p>You can use the height and width attributes to specify the size of the iframe:</p><iframe src="https://www.suzuki.co.id/eparts" height="720" width="1024" title="Iframe Example"></iframe></body></html>';
    }
}