@IsTest
public class HTTPMockFactory implements HttpCalloutMock {
  protected Integer code;
  protected String status;
  protected String body;
  protected Map<String, String> responseHeaders;
  
  public HTTPMockFactory(
    Integer code,
    String status,
    String body,
    Map<String, String> responseHeaders
  ) {
    this.code = code;
    this.status = status;
    this.body = body;
    this.responseHeaders = responseHeaders;
  }
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse response = new HttpResponse();
    for(String key : this.responseHeaders.keySet()) {
      response.setHeader(key, this.responseHeaders.get(key));
    }
    response.setBody(this.body);
    response.setStatusCode(this.code);
    response.setStatus(this.status);
    return response;
  }
}