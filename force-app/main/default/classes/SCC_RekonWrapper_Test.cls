@IsTest
private class SCC_RekonWrapper_Test {

    @IsTest
    static void testRekonWrapperClasses() {
        // RequestRekon
        SCC_RekonWrapper.RequestRekon reqRekon = new SCC_RekonWrapper.RequestRekon();
        reqRekon.TerminalID = 'T123';
        reqRekon.TransactionDate = '2025-09-15';
        reqRekon.AccountNumber = '123456';
        reqRekon.Amount = '50000';
        reqRekon.Page = 1;
        System.assertEquals('T123', reqRekon.TerminalID);

        // ResponseRekon
        SCC_RekonWrapper.ResponseRekon resRekon = new SCC_RekonWrapper.ResponseRekon();
        resRekon.ERROR_CODE = '00';
        resRekon.RESPONSE_CODE = '200';
        resRekon.RESPONSE_MESSAGE = 'OK';
        resRekon.RESPONSE_DATA = new SCC_RekonWrapper.ResponseRekonData();
        resRekon.RESPONSE_DATA.result = new List<SCC_RekonWrapper.ResponseRekonResult>();

        SCC_RekonWrapper.ResponseRekonResult rekonResult = new SCC_RekonWrapper.ResponseRekonResult();
        rekonResult.uuid = 'UUID123';
        rekonResult.amount = 1000;
        resRekon.RESPONSE_DATA.result.add(rekonResult);

        System.assertEquals('UUID123', resRekon.RESPONSE_DATA.result[0].uuid);

        // RequestBeritaAcaraOpname
        SCC_RekonWrapper.RequestBeritaAcaraOpname reqBA = new SCC_RekonWrapper.RequestBeritaAcaraOpname();
        reqBA.TerminalID = 'ATM001';
        reqBA.TanggalTransaksi = '2025-09-15';
        reqBA.Page = 2;
        System.assertEquals('ATM001', reqBA.TerminalID);

        // ResponseBeritaAcaraOpname
        SCC_RekonWrapper.ResponseBeritaAcaraOpname resBA = new SCC_RekonWrapper.ResponseBeritaAcaraOpname();
        resBA.ERROR_CODE = '00';
        resBA.RESPONSE_CODE = '200';
        resBA.RESPONSE_MESSAGE = 'OK';
        resBA.RESPONSE_DATA = new SCC_RekonWrapper.ResponseBeritaAcaraOpnameData();
        resBA.RESPONSE_DATA.result = new List<SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult>();

        SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult baResult = new SCC_RekonWrapper.ResponseBeritaAcaraOpnameResult();
        baResult.id_terminal = 'ATM001';
        baResult.branch = 101;
        baResult.StatusName = 'Closed';
        resBA.RESPONSE_DATA.result.add(baResult);

        System.assertEquals('Closed', resBA.RESPONSE_DATA.result[0].StatusName);

        // RequestFlagDataRekon
        SCC_RekonWrapper.RequestFlagDataRekon reqFlag = new SCC_RekonWrapper.RequestFlagDataRekon();
        reqFlag.Status = 'Done';
        reqFlag.TransactionDate = '2025-09-15';
        reqFlag.NoTicket = 'TICK123';
        reqFlag.UUID = new List<String>{'UUID123'};
        System.assertEquals('TICK123', reqFlag.NoTicket);

        // ResponseFlagDataRekon
        SCC_RekonWrapper.ResponseFlagDataRekon resFlag = new SCC_RekonWrapper.ResponseFlagDataRekon();
        resFlag.ERROR_CODE = '00';
        resFlag.RESPONSE_CODE = '200';
        resFlag.RESPONSE_MESSAGE = 'OK';
        resFlag.RESPONSE_DATA = new SCC_RekonWrapper.DataFlagDataRekon();
        resFlag.RESPONSE_DATA.message = 'Success';
        System.assertEquals('Success', resFlag.RESPONSE_DATA.message);

        // RekonToken*
        SCC_RekonWrapper.RekonTokenDetailData tokenDetail = new SCC_RekonWrapper.RekonTokenDetailData();
        tokenDetail.BillingCode = '14361525604';
        tokenDetail.Fee = '3000.00';
        tokenDetail.ID = 251019;
        tokenDetail.NoToken = '86080980807';
        tokenDetail.Nominal = '20000';
        tokenDetail.RekDebet = '123';
        tokenDetail.Remark = 'Remark here';

        SCC_RekonWrapper.RekonTokenResponseData tokenResData = new SCC_RekonWrapper.RekonTokenResponseData();
        tokenResData.detailData = new List<SCC_RekonWrapper.RekonTokenDetailData>{tokenDetail};
        tokenResData.statusScheduler = 'Done';

        SCC_RekonWrapper.RekonTokenResponse tokenRes = new SCC_RekonWrapper.RekonTokenResponse();
        tokenRes.errorCode = 'RE-00';
        tokenRes.responseCode = '00';
        tokenRes.responseMessage = 'Success';
        tokenRes.responseData = tokenResData;
        System.assertEquals('Success', tokenRes.responseMessage);

        // RekonTokenRequest
        SCC_RekonWrapper.RekonTokenRequest tokenReq = new SCC_RekonWrapper.RekonTokenRequest();
        tokenReq.featureId = 'PLNPR001';
        tokenReq.transactionDate = '2025-09-15';
        tokenReq.billingNumber = '11007550109';
        System.assertEquals('PLNPR001', tokenReq.featureId);
    }
}