public with sharing class AsyncQueryUtils {
    public class AsyncQueryException extends Exception {}

    public static List<Case> performAsyncQuery(String query) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;

        // Step 1: Create a job
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/async/60.0/job');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-SFDC-Session', UserInfo.getSessionId());
        req.setBody('{"operation":"query","object":"Case","contentType":"JSON"}');
        
        res = http.send(req);
        if (res.getStatusCode() != 201) {
            throw new AsyncQueryException('Failed to create job. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
        }
        Map<String, Object> jobResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String jobId = (String)jobResponse.get('id');
        
        if (String.isBlank(jobId)) {
            throw new AsyncQueryException('Failed to get job ID. Response: ' + res.getBody());
        }

        System.debug('Job created successfully. Job ID: ' + jobId);

        // Step 2: Submit the query
        req = new HttpRequest();
        req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/async/60.0/job/' + jobId + '/batch');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('X-SFDC-Session', UserInfo.getSessionId());
        req.setBody(query);
        
        res = http.send(req);
        if (res.getStatusCode() != 201) {
            throw new AsyncQueryException('Failed to submit query. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
        }
        
        // Parse the batch response to get the batch ID
        Map<String, Object> batchResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        String batchId = (String)batchResponse.get('id');
        
        if (String.isBlank(batchId)) {
            throw new AsyncQueryException('Failed to get batch ID. Response: ' + res.getBody());
        }
        
        System.debug('Query submitted successfully. Batch ID: ' + batchId);

        // Rest of the code remains the same
        // Step 3: Wait for the batch to complete
        Boolean isCompleted = false;
        Integer retryCount = 0;
        Integer maxRetries = 10;
        while (!isCompleted && retryCount < maxRetries) {
            req = new HttpRequest();
            req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/async/60.0/job/' + jobId + '/batch/' + batchId);
            req.setMethod('GET');
            req.setHeader('X-SFDC-Session', UserInfo.getSessionId());
            
            res = http.send(req);
            System.debug('Batch status check response. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            
            if (res.getStatusCode() != 200) {
                throw new AsyncQueryException('Failed to check batch status. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
            Map<String, Object> batchInfo = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            String state = (String)batchInfo.get('state');
            
            if (state == 'Completed') {
                isCompleted = true;
            } else if (state == 'Failed') {
                throw new AsyncQueryException('Batch failed. Info: ' + JSON.serialize(batchInfo));
            } else {
                System.debug('Batch not yet completed. Current state: ' + state);
                System.debug('Waiting for 30 seconds...');
                Long startTime = System.now().getTime();
                while (System.now().getTime() - startTime < 120000) {
                    // Wait for 30 seconds
                }
                retryCount++;
            }
        }

        if (!isCompleted) {
            throw new AsyncQueryException('Batch did not complete within the expected time.');
        }

        // Step 4: Retrieve the results
        List<Case> cases = new List<Case>();
        Boolean hasMoreResults = true;
        Integer resultId = 0;

        while (hasMoreResults) {
            req = new HttpRequest();
            req.setEndpoint(URL.getOrgDomainUrl().toExternalForm() + '/services/async/60.0/job/' + jobId + '/batch/' + batchId + '/result/' + resultId);
            req.setMethod('GET');
            req.setHeader('X-SFDC-Session', UserInfo.getSessionId());
            
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                List<Object> results = (List<Object>)JSON.deserializeUntyped(res.getBody());
                for (Object result : results) {
                    cases.add((Case)JSON.deserialize(JSON.serialize(result), Case.class));
                }
                resultId++;
            } else if (res.getStatusCode() == 404) {
                // No more results
                hasMoreResults = false;
            } else {
                throw new AsyncQueryException('Failed to retrieve results. Status: ' + res.getStatusCode() + ' Body: ' + res.getBody());
            }
        }

        return cases;
    }
}