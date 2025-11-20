@IsTest
private class SCC_DetailTransactionWrapperTest {

    @IsTest
    static void testParseMethod() {
        // Create a sample JSON string representing detailed transaction data
        String json = '{"data":[{"kafkaTimestamp":"2024-05-28T10:00:00Z","switchValue":"Switch A","paymentRemark":"Remark A","noRekMerchant":"1234567890","paymentDate":"2024-05-28","settleDate":"2024-05-28","settleAmount":100.00,"posEntryMode":"POS Mode A","acqBank":"Bank A","address":"Address A","location":"Location A","mcc":"MCC A","traceNum":"Trace Number A","mti":"MTI A","trxType":"Type A","trxStatus":"Status A","status":"Status A","rc":"RC A","cardType":"Card Type A","onUsNotOnUs":"On-us","localCrossBorder":"Local","namaFitur":"Feature A","proccode":"Proccode A","channelID":"Channel ID A","":1.5,"trxAmount":100,"jenisTrx":"Transaction Type A","batchNo":"Batch Number A","appCodeReffNum":"App Code Ref Num A","merchantName":"Merchant Name A","tidOrStoreId":"TID/Store ID A","midOrMpan":"MID/MPAN A","noKartuCpan":"1234567890123456","trxTime":"10:00:00","trxDate":"2024-05-28"}],"responseMessage":"Success","responseCode":"200","errorCode":null,"statusCode":200}';
        
        // Call the parse method to deserialize the JSON string
        SCC_DetailTransactionWrapper wrapper = SCC_DetailTransactionWrapper.parse(json);
        
        // Verify that the deserialized object is not null
        System.assertNotEquals(null, wrapper);
        
        // Verify data properties
        System.assertNotEquals(null, wrapper.data);
        System.assertEquals(1, wrapper.data.size());
        
        // Verify error properties
        System.assertEquals(null, wrapper.errors);
        System.assertEquals('Success', wrapper.responseMessage);
        System.assertEquals('200', wrapper.responseCode);
        System.assertEquals(null, wrapper.errorCode);
        System.assertEquals(200, wrapper.statusCode);
        
        // Verify the deserialized data
        SCC_DetailTransactionWrapper.Data detailTransaction = wrapper.data[0];
        System.assertEquals('2024-05-28T10:00:00Z', detailTransaction.kafkaTimestamp);
        System.assertEquals('Switch A', detailTransaction.switchValue);
        System.assertEquals('Remark A', detailTransaction.paymentRemark);
        System.assertEquals('1234567890', detailTransaction.noRekMerchant);
        System.assertEquals('2024-05-28', detailTransaction.paymentDate);
        System.assertEquals('2024-05-28', detailTransaction.settleDate);
        System.assertEquals(100.00, detailTransaction.settleAmount);
        System.assertEquals('POS Mode A', detailTransaction.posEntryMode);
        System.assertEquals('Bank A', detailTransaction.acqBank);
        System.assertEquals('Address A', detailTransaction.address);
        System.assertEquals('Location A', detailTransaction.location);
        System.assertEquals('MCC A', detailTransaction.mcc);
        System.assertEquals('Trace Number A', detailTransaction.traceNum);
        System.assertEquals('MTI A', detailTransaction.mti);
        System.assertEquals('Type A', detailTransaction.trxType);
        System.assertEquals('Status A', detailTransaction.trxStatus);
        System.assertEquals('Status A', detailTransaction.status);
        System.assertEquals('RC A', detailTransaction.rc);
        System.assertEquals('Card Type A', detailTransaction.cardType);
        System.assertEquals('On-us', detailTransaction.onUsNotOnUs);
        System.assertEquals('Local', detailTransaction.localCrossBorder);
        System.assertEquals('Feature A', detailTransaction.namaFitur);
        System.assertEquals('Proccode A', detailTransaction.proccode);
        System.assertEquals('Channel ID A', detailTransaction.channelID);
   //     System.assertEquals('Rp.0', detailTransaction.mdr);
        System.assertEquals(100, detailTransaction.trxAmount);
        System.assertEquals('Transaction Type A', detailTransaction.jenisTrx);
        System.assertEquals('Batch Number A', detailTransaction.batchNo);
        System.assertEquals('App Code Ref Num A', detailTransaction.appCodeReffNum);
        System.assertEquals('Merchant Name A', detailTransaction.merchantName);
        System.assertEquals('TID/Store ID A', detailTransaction.tidOrStoreId);
        System.assertEquals('MID/MPAN A', detailTransaction.midOrMpan);
        System.assertEquals('1234567890123456', detailTransaction.noKartuCpan);
        System.assertEquals('10:00:00', detailTransaction.trxTime);
        System.assertEquals('2024-05-28', detailTransaction.trxDate);
    }
}