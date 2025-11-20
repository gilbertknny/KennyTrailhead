/**
 * @description       : 
 * @author            : Christian Vieri
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Christian Vieri
**/
public without sharing class scc_Sabrina_GetAccDatahub {
    @InvocableMethod(label='Search Customer Profile by Phone Number' description='Fetch Customer Profile details based on Phone Number from Flow')
    public static List<ResponseWrapper> getCustomerProfileByPhoneNumber(List<RequestWrapper> requestList) {
        List<ResponseWrapper> responseList = new List<ResponseWrapper>();
        for (RequestWrapper req : requestList) {
            try {
                System.debug('Starting search for phone number: ' + req.phoneNumber);
                SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest profileRequest = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
                profileRequest.phoneNumber = req.phoneNumber;

                List<SCC_HomePageSearch.CustomerProfile> customerProfiles = SCC_HomePageSearch.getCustomerProfile(profileRequest);
                System.debug('Number of customer profiles retrieved: ' + customerProfiles.size());
                system.debug('detail customer profile'+customerProfiles);

                for (SCC_HomePageSearch.CustomerProfile customerProfile : customerProfiles) {
                    ResponseWrapper response = new ResponseWrapper();
                    response.accountId = customerProfile.acc != null ? customerProfile.acc.Id : null;
                    response.customerName = customerProfile.acc != null ? customerProfile.acc.Name : 'No Account Found';
                    response.phone = customerProfile.acc != null ? customerProfile.acc.Phone : 'No Phone Found';
                    response.message = customerProfile.msg != null ? customerProfile.msg : 'Success';

                    System.debug('Customer Profile Details - Account ID: ' + response.accountId + ', Name: ' + response.customerName + ', Phone: ' + response.phone);
                    responseList.add(response);
                }
            } catch (Exception e) {
                System.debug('Error occurred: ' + e.getMessage());
                System.debug('Stack trace: ' + e.getStackTraceString());
                ResponseWrapper errorResponse = new ResponseWrapper();
                errorResponse.message = 'Error: ' + e.getMessage();
                responseList.add(errorResponse);
            }
        }
        System.debug('Final response list size: ' + responseList.size());
        return responseList;
    }

    public class RequestWrapper {
        @InvocableVariable(required=true label='Phone Number' description='Phone Number to search the customer profile')
        public String phoneNumber;
    }

    public class ResponseWrapper {
        @InvocableVariable(label='Account ID' description='ID of the Account retrieved')
        public Id accountId;
        @InvocableVariable(label='Customer Name' description='Name of the customer')
        public String customerName;
        @InvocableVariable(label='Phone Number' description='Phone number of the customer')
        public String phone;
        @InvocableVariable(label='Message' description='Response message from the system')
        public String message;
    }
}