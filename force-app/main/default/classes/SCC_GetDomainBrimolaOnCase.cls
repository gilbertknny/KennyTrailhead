/**
 * Class: SCC_GetDomainBrimolaOnCase
 * @description This class handles the retrieval of domain information from the Brimola API 
 *              based on given parameters such as idPangkalan, startDate, and endDate.
 * Author: Abhinav Sharma
 * Created Date: 2024-05-30
 */

 public without sharing class SCC_GetDomainBrimolaOnCase {
    /**
    * @description Makes an HTTP POST call to the Brimola API to retrieve domain information.
    * @param idPangkalan Example: 923749273982743
    * @param startDate Example: 2024-01-01
    * @param endDate Example: 2024-12-30
    * @return An SCC_ParentDomainBrimolaWrapper containing the retrieved data.
    */
   @AuraEnabled
   public static SCC_ParentDomainBrimolaWrapper getDomainBrimola(String idPangkalan, String startDate, String endDate) {
       SCC_ParentDomainBrimolaWrapper parentWrapper = new SCC_ParentDomainBrimolaWrapper();
       HttpRequest request = new HttpRequest();  
       HttpResponse response=new HttpResponse();
       String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Domain_Brimola_API');
       try {
           // Create a map to hold the request body parameters
           Map<String, String> bodyValueMap = new Map<String, String>();
           bodyValueMap.put('idPangkalan', idPangkalan); // Example: 923749273982743
           bodyValueMap.put('startDate', startDate); // Example: 2024-01-01
           bodyValueMap.put('endDate', endDate); // Example: 2024-12-30
           request.setMethod('POST');  
           request.setHeader('Content-Type', 'application/json'); 
           request.setHeader('X-DATAHUB-CHANNEL', 'CHMS');  
           request.setHeader('X-DATAHUB-USER', 'user'); 
           request.setEndpoint(endpointUrl);  
           request.setBody(JSON.serialize(bodyValueMap));  
           // Make the HTTP callout to the Brimola API
           response = SCC_UtilityClassIntegration.makeHttpCallout('POST', 'SCC_Domain_Brimola_API', JSON.serialize(bodyValueMap));
           SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetDomainBrimolaOnCase'));
           // Check if the response status code is 200 (OK)
           if (response.getStatusCode() == 200) {
               SCC_DomainBrimolaWrapper parsedData = SCC_DomainBrimolaWrapper.parse(response.getBody());
               
               // Verify if the parsed data and required nested objects are not null
               if (parsedData != null && parsedData.chmGraphql != null && parsedData.chmGraphql.inquiryBrimolaPangkalan != null) {
                   SCC_DomainBrimolaWrapper.InquiryBrimolaPangkalan inquiry = parsedData.chmGraphql.inquiryBrimolaPangkalan;
                   
                   if (inquiry.data != null) {
                       // Populate the parentWrapper with data from the inquiry object
                       parentWrapper.agenName = inquiry.data.agenName; 
                       parentWrapper.pangkalanName = inquiry.data.pangkalanName;
                       parentWrapper.pangkalanId = inquiry.data.pangkalanId;
                       parentWrapper.agenId = inquiry.data.agenId;
                       parentWrapper.agenAlamat = inquiry.data.agenAlamat;
                       parentWrapper.agenNorek = inquiry.data.agenNorek;
                       parentWrapper.corpBriva = inquiry.data.corpBriva;
                       parentWrapper.corpClientBriva = inquiry.data.corpClientBriva;
                       parentWrapper.errorMessage = 'No Error';
                       // Check if the transaction data exists and populate it
                       if (inquiry.data.brilinkTrxByIdKeagenan != null && inquiry.data.brilinkTrxByIdKeagenan.data != null) {
                           parentWrapper.data = inquiry.data.brilinkTrxByIdKeagenan.data;
                       }
                   }
               } else {
                   parentWrapper.errorMessage = 'No Data Found';
               }
           }
       } catch (Exception e) {
           // Handle any exceptions that occur during the API call
           SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetDomainBrimolaOnCase'));
           parentWrapper.errorMessage = 'Error during API call: ' + e.getMessage();
       }
       return parentWrapper; // Return the populated wrapper object
   }
}