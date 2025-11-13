/**
 *  @description APILogMock
 */
@isTest
public with sharing class APILogMock {
    /**
     *  @description ResponseAPILog
     */
    public class ResponseAPILog implements HttpCalloutMock {
        /**
         *  @description respond
         * @return respond
         * @param req
         */
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('"code" : "00","message" : "Success"');
            res.setStatusCode(200);
            return res;
        }
    }
    /**
     *  @description LintaswataOauth
     */
    public class LintaswataOauth implements HttpCalloutMock {
        /**
         *  @description respond
         * @param req
         * @return respond
         */
        public HTTPResponse respond(HTTPRequest req) {
            Map<String, Object> jsonData = new Map<String, Object>{
                'accessToken' => 'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzYWxlc2ZvcmNlIiwiZXhwIjoxNzU2OTU2MzUyLCJpYXQiOjE3NTY4Njk5NTIsInNjb3BlIjoiUE9MSUNZX0lORk8gQlJBTkNIX0dFVCBET0NVTUVOVF9QT1NUIFdIQVRTQVBQX1BPU1QgQ0xJRU5UX1BBUlRORVJfUE9TVCJ9.YhYFTnM3t3ofInvkHi5xsQQuAr4sRQEUn1HK40eMGc_OVtYfC8ozR0xYjenNpCL_6AOxaG2-yYyWNRlLttMLew',
                'tokenType' => 'bearer',
                'expiresIn' => '86400',
                'status' => '00',
                'message' => 'Success'
            };
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(jsonData));
            res.setStatusCode(200);
            return res;
        }
    }
}