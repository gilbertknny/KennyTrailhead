@isTest
public with sharing class SCC_RekeningKoran_Mock {
    /* public class ResponseRekeningKoran_MatchedConditions implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            String mockBody = '{ "data": [ { "trremk": "KOR3", "mutasiKredit": 50000 } ] }';
            res.setBody(mockBody);
            return res;
        }
    } */
    
    /*public class ResponseRekeningKoran_MatchedConditions implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String mockBody = '{ "data": [ { "kodeTran": "ABC123", "mutasiDebet": 10000, "mutasiKredit": 50000, "noRek": "326301020301234", "saldoAkhirMutasi": 20000, "saldoAwalMutasi": 15000, "seq": "001", "serial": "ABC001", "terbilang": "Sepuluh Ribu", "tglEffektif": "2024-11-05", "tglTran": "2024-11-05", "tlbds1": "Detail 1", "tlbds2": "Detail 2", "trremk": "KOR3", "truser": "UserA" } ] }';
            res.setBody(mockBody);
            return res;
        }
    }*/
    
    public class ResponseRekeningKoran_MatchedConditions implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            String mockBody = '{' +
                '"data": [' +
                    '{' +
                        '"auxtrc": "AUX123",' +
                        '"deskTran": "Transfer Credit",' +
                        '"glsign": "C",' +
                        '"idNum": 12345,' +
                        '"idNum2": 67890,' +
                        '"idNum3": 11223,' +
                        '"jamTran": 1435,' +
                        '"kodeTran": "ABC123",' +
                        '"mutasiDebet": 0,' +
                        '"mutasiKredit": 50000,' +
                        '"noRek": "326301020301234",' +
                        '"saldoAkhirMutasi": 75000,' +
                        '"saldoAwalMutasi": 25000,' +
                        '"seq": 1,' +
                        '"serial": "SER123",' +
                        '"terbilang": "Lima Puluh Ribu Rupiah",' +
                        '"tglEfektif": "' + Date.today().format() + '",' +
                        '"tglTran": "' + Date.today().format() + '",' +
                        '"tlbds1": "Additional Detail 1",' +
                        '"tlbds2": "Additional Detail 2",' +
                        '"trremk": "KOR3 Transfer Credit",' +
                        '"truser": "SYSTEM"' +
                    '}' +
                '],' +
                '"status": "SUCCESS",' +
                '"message": "Data found"' +
            '}';
            res.setBody(mockBody);
            return res;
        }
    }
    
    public class ResponseRekeningKoran implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.ResponseRekon()));
            res.setStatusCode(200);
            return res;
        }
    }

    /*
    public class ResponseBeritaAcaraOpname implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.ResponseBeritaAcaraOpname()));
            res.setStatusCode(200);
            return res;
        }
    }

    public class ResponseFlagDataRekeningKoran implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(JSON.serialize(Object_Test.ResponseFlagDataRekon()));
            res.setStatusCode(200);
            return res;
        }
    }
	*/

    public class ResponseError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody('{}');
            res.setStatusCode(200);
            return res;
        }
    }
}