/**
 * @description SCC_SavingStatement
 */
public without sharing class SCC_SavingStatement {
	 
    /**
     * @description getSavingStatement
     * @param accountNumber
     * @param startDate
     * @param endDate
     * @return List<SCC_SavingStateWrapper>
     */
    @AuraEnabled
    public static List<SCC_SavingStateWrapper> getSavingStatement(String accountNumber, String startDate, String endDate) {
        List<SCC_SavingStateWrapper> savingList = new List<SCC_SavingStateWrapper>();
        String endpointUrl = SCC_UtilityClassIntegration.getEndPoint('SCC_Saving_Statement_API');
        HttpRequest request = new HttpRequest();
        HttpResponse response=new HttpResponse();
        try {
            Map<String, String> bodyValueMap = new Map<String, String>{
                'norekVarchar' => accountNumber,
                'tanggalAkhirDatetime' => endDate,
                'tanggalAwalDatetime' => startDate
            };
            bodyValueMap.put('channel', 'CHMS');

            String body = JSON.serialize(bodyValueMap);

          
            request.setEndpoint(endpointUrl);
            request.settimeout(60000);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
            Http http = new Http();
            response = http.send(request);
            SCC_API.InsertErrorLog(null,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_SavingStatement'));  
            if(response.getStatusCode() != 200){
                savingList = null;
            }else if (response.getStatusCode() == 200) {
                SCC_SavingStatementWrapper parsedData = SCC_SavingStatementWrapper.parse(response.getBody());
                if (parsedData != null && parsedData.statusCode == 200) {
                    for (SCC_SavingStatementWrapper.Data savingData : parsedData.data) {
                        // Convert tglTran to the format YYYY-MM-DD
                        String formattedTglTran = null;
                        if (savingData.tglTran != null && savingData.tglTran.length() >= 10) {
                            Date dt = Date.valueOf(savingData.tglTran.substring(0, 10));
                            formattedTglTran = String.valueOf(dt);
                        } else {
                            formattedTglTran = '';
                        }
                        
                        // Convert jamTran to HH:mm:ss format
                        String formattedJamTran = ' ';
                        if (savingData.jamTran != null) {
                                formattedJamTran = convertTimeFormat(String.valueOf(savingData.jamTran));
                        }
                          SCC_SavingStateWrapper savingRecord = new SCC_SavingStateWrapper(
                            savingData.noRek,
                            formattedTglTran,
                            formattedJamTran,
                            savingData.remarkCustom,
                            savingData.glsign,
                            savingData.mutasiDebet,
                            savingData.mutasiKredit,
                            savingData.saldoAkhirMutasi,
                            savingData.truser,
                            savingData.ukerTransaksi,
                            savingData.tid,
                            savingData.channel
                        );
                        savingList.add(savingRecord);
                    }
                }else{
                    savingList = null;
                }
            }else{
                savingList = null;
            }
        } catch (Exception e) {
            SCC_API.InsertErrorLog(e,request,response,new SCC_API.WrapperError(endpointUrl,'SCC_SavingStatement'));  
            throw new AuraHandledException('Terjadi kesalahan saat melakukan panggilan API: ' + e.getMessage());
        }
        return savingList;
    }
    
    // Method to convert numeric time format to HH:mm:ss
    /**
     * @description convertTimeFormat
     * @param numericTime
     * @return string
     */
    public static String convertTimeFormat(String numericTime) {
        if (numericTime == null) {
            return null;
        }
    
        // Manually pad the numericTime with leading zeros to ensure it is 6 digits long
        while (numericTime.length() < 6) {
            numericTime = '0' + numericTime;
        }
    
        String hours = numericTime.substring(0, 2);
        String minutes = numericTime.substring(2, 4);
        String seconds = numericTime.substring(4, 6);
    
        return hours + ':' + minutes + ':' + seconds;
    }
}