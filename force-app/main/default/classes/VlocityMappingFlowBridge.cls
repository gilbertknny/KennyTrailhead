public with sharing class VlocityMappingFlowBridge {
    // Flow input wrapper (Flow passes a List of these)
    public class Request {
        @InvocableVariable(label='Integration Procedure Name' description='IP name, e.g. SFAWT15')
        public String ipName;

        @InvocableVariable(label='Input JSON' description='Raw JSON string to pass to the IP')
        public String jsonInput;
    }

    // Flow output wrapper (one Response returned)
    public class Response {
        @InvocableVariable(label='Result JSON' description='Serialized JSON result returned from the IP')
        public String resultJson;

        @InvocableVariable(label='Error Message' description='Error message when execution failed')
        public String errorMessage;
    }

    @InvocableMethod(label='Call VlocityMapping.callIP' description='Bridges Flow to VlocityMapping.callIP using the first item from the Flow list')
    public static List<Response> invoke(List<Request> requests) {
        List<Response> results = new List<Response>();
        Response resp = new Response();
        results.add(resp);

        if (requests == null || requests.isEmpty()) {
            resp.errorMessage = 'No input provided';
            return results;
        }

        Request r = requests[0];

        if (String.isBlank(r.ipName)) {
            resp.errorMessage = 'ipName is required';
            return results;
        }

        // Default empty JSON to object if caller passes blank
        String inputJson = String.isBlank(r.jsonInput) ? '{}' : r.jsonInput;

        System.debug('inputJson: ' + inputJson);
        try {
            // Call the existing static method that expects (String, String)
            Map<String, Object> outMap = VlocityMapping.callIP(r.ipName, inputJson);

            // Serialize to JSON for Flow consumption
            resp.resultJson = outMap == null ? null : JSON.serialize(outMap);
        } catch (Exception ex) {
            // Return the error message so Flow can surface it
            resp.errorMessage = ex.getMessage();
        }

        return results;
    }
}