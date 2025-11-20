/**
 * @description Utility Class for Integration
 */
public without sharing class SCC_UtilityClassIntegration {   
    /**
     * @description This method will check if the org is Production or Sandbox
     * @return Boolean values true or false
     */
    public static Boolean isProduction(){
        // Get the base URL of the Salesforce organization
        String baseUrl = URL.getOrgDomainURL().toExternalForm();            
        // Parse the base URL to extract the sandbox name
        String boxName = DomainParser.parse(baseUrl).getSandboxName();           
        // Determine if the organization is a production instance
        Boolean isProduction = boxName == null;           
        // Return true if the organization is a production instance, otherwise false
        return isProduction;
    }

    /**
     * @description Retrieves the endpoint URL based on the provided metadata and the current environment (production or sandbox).
     * @param endPointMetaData Metadata used to determine the endpoint URL.
     * @return String The endpoint URL for the given metadata.
     */
    public static String getEndPoint(String endPointMetaData) {
        String endpointUrl = '';  // Initialize the endpoint URL as an empty string.
        
        if (isProduction()) {  // Check if the current environment is production.
            // Retrieve the production endpoint URL from the metadata configuration.
            endpointUrl = SCC_Integration_Endpoints_Config__mdt.getInstance(endPointMetaData).SCC_Production_Endpoint__c;
        } else {
            // Retrieve the sandbox endpoint URL from the metadata configuration.
            endpointUrl = SCC_Integration_Endpoints_Config__mdt.getInstance(endPointMetaData).SCC_Sandbox_Endpoint__c;
        }
        
        return endpointUrl;  // Return the determined endpoint URL.
    }
    
    /**
     * @description Gets the Record Type Id by passing the Record Type Name.
     * @param objectName The API name of the object (e.g., 'Account', 'Contact').
     * @param developerName The name of the record type you want to find.
     * @return The Id of the Record Type if found, otherwise null.
     */
    public static Id getRecordTypeIdByName(String objectName, String developerName) {
        // Describe the object to get its record types
        Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Schema.getGlobalDescribe().get(objectName)
            .getDescribe().getRecordTypeInfosByDeveloperName();
        // Check if the record type exists in the map
        if (recordTypeInfoMap.containsKey(developerName)) {
            // Return the Record Type Id
            return recordTypeInfoMap.get(developerName).getRecordTypeId();
        }
        // If the record type name is not found, return null
        return null;
    }

    /**
     * @description Makes an HTTP callout with the specified method, endpoint metadata, and body values.
     * @param method The HTTP method to use (e.g., "GET", "POST").
     * @param endPointMetaData Metadata used to determine the endpoint URL.
     * @param bodyValueMap The body of the HTTP request in JSON format.
     * @return HttpResponse The response received from the HTTP callout.
     */
    public static HttpResponse makeHttpCallout(String method, String endPointMetaData, String bodyValueMap) {
        HttpRequest request = new HttpRequest();  // Create a new HttpRequest instance.
        request.setMethod(method);  // Set the HTTP method for the request.
        request.setHeader('Content-Type', 'application/json');  // Set the Content-Type header to JSON.
        request.setHeader('X-DATAHUB-CHANNEL', 'CHMS');  // Set a custom header for the DataHub channel.
        request.setHeader('X-DATAHUB-USER', 'user');  // Set a custom header for the DataHub user.
        request.setHeader('x-hasura-admin-secret', 'P@ssw0rd');  // Set a custom header for the DataHub user.
        request.setEndpoint(getEndPoint(endPointMetaData));  // Set the endpoint URL based on the metadata.
        request.setBody(bodyValueMap);  // Set the body of the request with the provided JSON data.

        Http http = new Http();  // Create a new Http instance to send the request.
        HttpResponse response = http.send(request);  // Send the HTTP request and get the response.
        return response;  // Return the response received from the HTTP callout.
    }

}