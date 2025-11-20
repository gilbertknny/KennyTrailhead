@IsTest
private class SCC_TransactionHistoryWrapperTest {

    @IsTest
    static void testParseMethod() {
        // Create a sample JSON string representing transaction history data
        String json = '{"data":[{"kafkaTimestamp":"2024-05-28T10:00:00Z","switchValue":"Switch A","trxStatus":"Success","trxType":"Purchase","proccode":"123456","rc":"00","merchantName":"Merchant A","mti":"0100","trxAmount":100.00,"noKartuCpan":"1234567890123456","jenisTrx":"Credit","appCodeReffNum":"ABC123","tidOrStoreId":"TID123","midOrMpan":"MID456","trxTime":"10:00:00","trxDate":"2024-05-28"}],"responseMessage":"Success","responseCode":"200","errorCode":null,"statusCode":200}';
        
        // Call the parse method to deserialize the JSON string
        SCC_TransactionHistoryWrapper wrapper = SCC_TransactionHistoryWrapper.parse(json);
        
        // Verify that the deserialized object is not null
        System.assertNotEquals(null, wrapper);
        
        // Verify data properties
        System.assertNotEquals(null, wrapper.data);
        System.assertNotEquals(0, wrapper.data.size());
        
        // Verify error properties
        System.assertEquals(null, wrapper.errors);
        System.assertEquals('Success', wrapper.responseMessage);
        System.assertEquals('200', wrapper.responseCode);
        System.assertEquals(null, wrapper.errorCode);
        System.assertEquals(200, wrapper.statusCode);
        
        // Verify the deserialized data
        SCC_TransactionHistoryWrapper.Data transactionData = wrapper.data[0];
        System.assertEquals('2024-05-28T10:00:00Z', transactionData.kafkaTimestamp);
        System.assertEquals('Switch A', transactionData.switchValue);
        System.assertEquals('Success', transactionData.trxStatus);
        System.assertEquals('Purchase', transactionData.trxType);
        System.assertEquals('123456', transactionData.proccode);
        System.assertEquals('00', transactionData.rc);
        System.assertEquals('Merchant A', transactionData.merchantName);
        System.assertEquals('0100', transactionData.mti);
        System.assertEquals(100.00, transactionData.trxAmount);
        System.assertEquals('1234567890123456', transactionData.noKartuCpan);
        System.assertEquals('Credit', transactionData.jenisTrx);
        System.assertEquals('ABC123', transactionData.appCodeReffNum);
        System.assertEquals('TID123', transactionData.tidOrStoreId);
        System.assertEquals('MID456', transactionData.midOrMpan);
        System.assertEquals('10:00:00', transactionData.trxTime);
        System.assertEquals('2024-05-28', transactionData.trxDate);
    }
}