@isTest
public with sharing class SCC_AVAYA_Mock {
    public class ResponseToken implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test3.setResponseToken()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ReportHistorical implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test3.setResponseReportHistorical()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ReportAgent implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test3.setResponseReportAgent()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ReportSkills implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test3.setResponseReportSkills()));
            res.setStatusCode(200);
            return res;
        }
    }
}