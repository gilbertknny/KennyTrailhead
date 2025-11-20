/**
 * @description SCC_GetCardDetails
 */
public without sharing class SCC_GetCardDetails {
    /**
     * @description getCardData
     * @param cardNumber
     * @return SCC_CardData
     */
    @AuraEnabled
    public static SCC_CardData getCardData(String cardNumber) {
        SCC_CardData cardDataList;  
        HttpResponse response=new HttpResponse();
        HttpRequest request = new HttpRequest();
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Card_Data_API');
            
        try {
            Map<String, String> bodyMap = new Map<String, String>{
                'cardNo' => cardNumber
            };
            String body = JSON.serialize(bodyMap);
          
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.settimeout(60000);
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetCardDetails'));
            if (response.getStatusCode() == 200) {
                // Parse the JSON response using SCC_CardDataWrapper
                if((response.getBody()).contains('Data not Found') || (response.getBody()).contains('unexpected')){
                    cardDataList = null;
                }else{
                    SCC_CardDataWrapper parsedData = SCC_CardDataWrapper.parse((response.getBody()).replace('data ', 'data'));
                    if (parsedData != null && parsedData.chmGraphql != null && parsedData.chmGraphql.inquiryCardData != null && parsedData.chmGraphql.inquiryCardData.data != null) {
                        SCC_CardDataWrapper.Data cardData = parsedData.chmGraphql.inquiryCardData.data;
                        
                        // Extract the required fields
                        String cardNo = formatCardNumber(cardData.cardNo);
                        String type = cardData.type;
                        String name = cardData.name;
                        String cardStatus = cardData.cardStatus;
                        String statusDesc = cardData.statusDesc;
                        String lastMaint = String.valueOf(cardData.lastMaint);
                        String userMaint = cardData.userMaint;
                        String activeDateCard = String.valueOf(cardData.activeDate);
                        String issueDateCard = String.valueOf(cardData.issueDate);
                        String expDateCard = formatExpDate(cardData.expDate);
                        String blockDate = String.valueOf(cardData.blockDate);
                        
                        cardDataList = new SCC_CardData(
                                    cardNo, type, name, cardStatus, statusDesc,lastMaint,
                                    userMaint, activeDateCard, issueDateCard, expDateCard, blockDate
                                );
                    } else {
                        cardDataList = null;
                        throw new AuraHandledException('Parsed data or its required properties are null.');
                    }
                }
            } else {
                cardDataList = null;
                throw new AuraHandledException('Response status code is not 200.');
            }
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetCardDetails'));
            cardDataList = null;
            //throw new AuraHandledException('Exception: ' + e.getMessage());
        }
        return cardDataList;
    }
    
    /**
     * @description getHistoryData
     * @param cardNumber
     * @return List of SCC_CardData
     */
    @AuraEnabled
    public static List<SCC_CardData> getHistoryData(String cardNumber) {
        List<SCC_CardData> cardDataList = new List<SCC_CardData>();  
        HttpRequest request = new HttpRequest();
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Card_Data_API');
        HttpResponse response=new HttpResponse();
        try {
            Map<String, String> bodyMap = new Map<String, String>{
                'cardNo' => cardNumber
            };
            String body = JSON.serialize(bodyMap);
               
            request.setEndpoint(endpointUrl);
            request.setMethod('POST');
            request.settimeout(60000);
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetCardDetails'));
            if (response.getStatusCode() == 200) {
                // Parse the JSON response using SCC_CardDataWrapper
                if((response.getBody()).contains('Data not Found')){
                    cardDataList = null;
                }else{
                    SCC_CardDataWrapper parsedData = SCC_CardDataWrapper.parse((response.getBody()).replace('data ', 'data'));
                    if (parsedData != null && parsedData.chmGraphql != null && parsedData.chmGraphql.inquiryCardData != null && parsedData.chmGraphql.inquiryCardData.data != null) {
                        SCC_CardDataWrapper.Data cardData = parsedData.chmGraphql.inquiryCardData.data;
                        SCC_CardDataWrapper.HistoryAccount historyAccount = cardData.historyAccount;
                        List<SCC_CardDataWrapper.DataElement> responseDataList = (historyAccount != null && historyAccount.responseData != null) ? historyAccount.responseData.data : null;
                        
                        if (responseDataList != null) {
                            for (SCC_CardDataWrapper.DataElement responseData : responseDataList) {
                                String cardNoHis = responseData != null ? formatCardNumber(responseData.cardNo) : null;
                                String cardStatusHis = responseData != null ? String.valueOf(responseData.cardStatus) : null;
                                String expDate = responseData != null ? formatExpDate(responseData.expDate) : null;
                                String activeDate = responseData != null ? String.valueOf(responseData.activeDate) : null;
                                String branchCode = responseData != null ? String.valueOf(responseData.branchCode) : null;
                                String issueDate =  responseData != null ? String.valueOf(responseData.issueDate) : null;
                                String typeCode =  responseData != null ? String.valueOf(responseData.typeCode) : null;
                                String renewalDate =  responseData != null ? String.valueOf(responseData.renewalDate) : null;
                                String blockDate =  responseData != null ? String.valueOf(responseData.blockDate) : null;
                                String userBlock =  responseData != null ? String.valueOf(responseData.userBlock) : null;
                                String accNo =  responseData != null ? String.valueOf(responseData.accNo) : null;
                                String lastMaintHis = responseData != null ? String.valueOf(responseData.lastMaint) : null;
                                
                                // Create a new instance of SCC_CardData and add it to the list
                                SCC_CardData newHisData = new SCC_CardData(
                                    cardStatusHis, cardNoHis, lastMaintHis, expDate, activeDate, 
                                    branchCode, issueDate, typeCode, renewalDate, blockDate,
                                    userBlock, accNo
                                );
                                cardDataList.add(newHisData);
                            }
                        }
                    } else {
                        throw new AuraHandledException('Parsed data or its required properties are null.');
                    }
                }
            } else {
                throw new AuraHandledException('Response status code is not 200.');
            }
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_GetCardDetails'));
            throw new AuraHandledException('Exception: ' + e.getMessage());
        }
        return cardDataList;
    }
    
    /**
     * @description formatCardNumber
     * @param cardNo
     * @return Card No String
     */
    private static String formatCardNumber(String cardNo) {
        if (cardNo != null && cardNo.length() == 16) {
            return cardNo.substring(0, 4) + '-' + cardNo.substring(4, 8) + '-' + cardNo.substring(8, 12) + '-' + cardNo.substring(12);
        }
        return cardNo;
    }
    
    /**
     * @description formatExpDate
     * @param expDate
     * @return Expiry Date String
     */
    private static String formatExpDate(String expDate) {
        if (expDate != null && expDate.length() == 4) {
            return expDate.substring(2, 4) + '/' + expDate.substring(0, 2);
        }
        return expDate;
    }
}