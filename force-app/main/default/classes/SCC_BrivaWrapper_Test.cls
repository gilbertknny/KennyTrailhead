@IsTest
public class SCC_BrivaWrapper_Test {

    @IsTest
    static void testWrapperInitialization() {

    
        SCC_BrivaWrapper.bodyBriva bodyReq = new SCC_BrivaWrapper.bodyBriva();
        bodyReq.brivaNo = '1234567890';
        bodyReq.channelId = 'BRIMO';
        bodyReq.serviceId = 'SERVICE01';
        bodyReq.externalId = 'EXT001';

        SCC_BrivaWrapper.requestBrivaWrapper reqWrapper = new SCC_BrivaWrapper.requestBrivaWrapper();
        reqWrapper.request = bodyReq;

        System.assertEquals('1234567890', reqWrapper.request.brivaNo);

      
        SCC_BrivaWrapper.Brivaco brivacoItem = new SCC_BrivaWrapper.Brivaco();
        brivacoItem.uniqueCode = 'UC001';
        brivacoItem.accountNo = '9876543210';
        brivacoItem.accountName = 'PT Test';
        brivacoItem.description = 'Test Description';

        List<SCC_BrivaWrapper.Brivaco> listBrivaco = new List<SCC_BrivaWrapper.Brivaco>{ brivacoItem };

      
        SCC_BrivaWrapper.dataBriva data = new SCC_BrivaWrapper.dataBriva();
        data.corpId = 'CORP01';
        data.corpName = 'PT BRI';
        data.corpCode = 'BRIVA01';
        data.corpAccountNo = '111222333';
        data.currencys = 'IDR';
        data.isActive = 'Y';
        data.corpFee = '1000';
        data.custFee = '2000';
        data.corpFeeAtm = '3000';
        data.custFeeAtm = '4000';
        data.corpFeeBrilink = '5000';
        data.custFeeBrilink = '6000';
        data.isSplitFee = 'Y';
        data.amountFeeSplitBri = '100';
        data.amountFeeSplit = '200';
        data.amountFeeSplit2 = '300';
        data.isSplitFeeEchannel = 'N';
        data.amountFeeSplitEchannelBri = '150';
        data.amountFeeSplitEchannel = '250';
        data.amountFeeSplitEchannel2 = '350';
        data.isSplitFeeBrilink = 'Y';
        data.amountFeeSplitBrilinkBri = '120';
        data.amountFeeSplitBrilink = '220';
        data.amountFeeSplitBrilink2 = '320';
        data.accountNoFeeSplit = '987654321';
        data.accountNFeeSplit2 = '123456789';
        data.limitMinTrx = '10000';
        data.limitMaxTrx = '1000000';
        data.openPayment = 'YES';
        data.billingPayment = 'NO';
        data.specialFlag = 'S';
        data.cif = 'CIF12345';
        data.brivaService = 'BRIVA_PAYMENT';
        data.specialSegment = 'SEG-A';
        data.startIndexSegment = '0';
        data.lengthIndexSegment = '10';
        data.isKeteranganTambahan = 'N';
        data.itPartnerName = 'Tech Partner';
        data.itPartnerPhoneNo = '08123456789';
        data.itPartnerEmail = 'partner@tech.com';
        data.businessPartnerName = 'Business Partner';
        data.businessPartnerPhoneNo = '08987654321';
        data.businessPartnerEmail = 'business@corp.com';
        data.picRm = 'RM John';
        data.rmPhoneNo = '087711223344';
        data.rmEmail = 'rm@bri.co.id';
        data.profilingType = 'Corporate';
        data.paymentChannel = 'BRIMO';
        data.brivaco = listBrivaco;

        System.assertEquals('CORP01', data.corpId);
        System.assertEquals('PT BRI', data.corpName);
        System.assertEquals('BRIVA01', data.corpCode);
        System.assertEquals('111222333', data.corpAccountNo);
        System.assertEquals('IDR', data.currencys);
        System.assertEquals('Y', data.isActive);
        System.assertEquals('1000', data.corpFee);
        System.assertEquals('2000', data.custFee);
        System.assertEquals('3000', data.corpFeeAtm);
        System.assertEquals('4000', data.custFeeAtm);
        System.assertEquals('5000', data.corpFeeBrilink);
        System.assertEquals('6000', data.custFeeBrilink);
        System.assertEquals('Y', data.isSplitFee);
        System.assertEquals('100', data.amountFeeSplitBri);
        System.assertEquals('200', data.amountFeeSplit);
        System.assertEquals('300', data.amountFeeSplit2);
        System.assertEquals('N', data.isSplitFeeEchannel);
        System.assertEquals('150', data.amountFeeSplitEchannelBri);
        System.assertEquals('250', data.amountFeeSplitEchannel);
        System.assertEquals('350', data.amountFeeSplitEchannel2);
        System.assertEquals('Y', data.isSplitFeeBrilink);
        System.assertEquals('120', data.amountFeeSplitBrilinkBri);
        System.assertEquals('220', data.amountFeeSplitBrilink);
        System.assertEquals('320', data.amountFeeSplitBrilink2);
        System.assertEquals('987654321', data.accountNoFeeSplit);
        System.assertEquals('123456789', data.accountNFeeSplit2);
        System.assertEquals('10000', data.limitMinTrx);
        System.assertEquals('1000000', data.limitMaxTrx);
        System.assertEquals('YES', data.openPayment);
        System.assertEquals('NO', data.billingPayment);
        System.assertEquals('S', data.specialFlag);
        System.assertEquals('CIF12345', data.cif);
        System.assertEquals('BRIVA_PAYMENT', data.brivaService);
        System.assertEquals('SEG-A', data.specialSegment);
        System.assertEquals('0', data.startIndexSegment);
        System.assertEquals('10', data.lengthIndexSegment);
        System.assertEquals('N', data.isKeteranganTambahan);
        System.assertEquals('Tech Partner', data.itPartnerName);
        System.assertEquals('08123456789', data.itPartnerPhoneNo);
        System.assertEquals('partner@tech.com', data.itPartnerEmail);
        System.assertEquals('Business Partner', data.businessPartnerName);
        System.assertEquals('08987654321', data.businessPartnerPhoneNo);
        System.assertEquals('business@corp.com', data.businessPartnerEmail);
        System.assertEquals('RM John', data.picRm);
        System.assertEquals('087711223344', data.rmPhoneNo);
        System.assertEquals('rm@bri.co.id', data.rmEmail);
        System.assertEquals('Corporate', data.profilingType);
        System.assertEquals('BRIMO', data.paymentChannel);
        System.assertEquals(1, data.brivaco.size());

        
        SCC_BrivaWrapper.responseBriva respBriva = new SCC_BrivaWrapper.responseBriva();
        respBriva.corpAccountNo = '123456789';
        respBriva.errorCode = '00';
        respBriva.responseCode = '200';
        respBriva.responseMessage = 'SUCCESS';
        respBriva.data = data;

        SCC_BrivaWrapper.responseBrivaWrapper respWrapper = new SCC_BrivaWrapper.responseBrivaWrapper();
        respWrapper.response = respBriva;

        System.assertEquals('SUCCESS', respWrapper.response.responseMessage);
        System.assertNotEquals(null, respWrapper.response.data);

        
        SCC_BrivaWrapper.responseBrivaCustom respCustom = new SCC_BrivaWrapper.responseBrivaCustom();
        respCustom.corpAccountNo = '999999';
        respCustom.errorCode = '00';
        respCustom.responseCode = '200';
        respCustom.responseMessage = 'CUSTOM SUCCESS';
        respCustom.corpName = 'Corp Test';
        respCustom.brivaco = listBrivaco;
        respCustom.specialSegment = 'SEGMENT-1';

        System.assertEquals('SEGMENT-1', respCustom.specialSegment);

      
        SCC_BrivaWrapper.ReportBrivaRequest reportReq = new SCC_BrivaWrapper.ReportBrivaRequest();
        reportReq.corpCode = 'BRIVACO';
        reportReq.custCode = 'CUST01';
        reportReq.tanggalAwal = '2025-01-01';
        reportReq.tanggalAkhir = '2025-01-31';
        reportReq.uniqcode = 'UC001';
        reportReq.pageNumber = 1;
        reportReq.rowsPerPage = 10;

        System.assertEquals('BRIVACO', reportReq.corpCode);

       
        SCC_BrivaWrapper.DataReportBriva dataReport = new SCC_BrivaWrapper.DataReportBriva();

        dataReport.brivaNo = 'BRIVA123456';
        dataReport.uniqueCode = 'UC999';
        dataReport.custCode = 'CUST001';
        dataReport.nama = 'Cahyo Pambudi';
        dataReport.keterangan = 'Pembayaran tagihan listrik';
        dataReport.amount = 150000;
        dataReport.paymentDate = '2025-10-24';
        dataReport.tellerid = 'TELL001';
        dataReport.norek = '1234567890123456';
        dataReport.seq = 1;
        dataReport.trremk = 'Success';
        dataReport.seqOther = 'SEQ002';
        dataReport.jaringan = 'BRIMO';
        dataReport.trstat = '00';
        dataReport.auxtrc = 'AUX123';
        dataReport.julianDate = '298';
        dataReport.trxID = 'TRX987654';
        dataReport.totalRow = 10;
        dataReport.pageShow = '1';

        System.assertEquals('BRIVA123456', dataReport.brivaNo);
        System.assertEquals('UC999', dataReport.uniqueCode);
        System.assertEquals('CUST001', dataReport.custCode);
        System.assertEquals('Cahyo Pambudi', dataReport.nama);
        System.assertEquals('Pembayaran tagihan listrik', dataReport.keterangan);
        System.assertEquals(150000, dataReport.amount);
        System.assertEquals('2025-10-24', dataReport.paymentDate);
        System.assertEquals('TELL001', dataReport.tellerid);
        System.assertEquals('1234567890123456', dataReport.norek);
        System.assertEquals(1, dataReport.seq);
        System.assertEquals('Success', dataReport.trremk);
        System.assertEquals('SEQ002', dataReport.seqOther);
        System.assertEquals('BRIMO', dataReport.jaringan);
        System.assertEquals('00', dataReport.trstat);
        System.assertEquals('AUX123', dataReport.auxtrc);
        System.assertEquals('298', dataReport.julianDate);
        System.assertEquals('TRX987654', dataReport.trxID);
        System.assertEquals(10, dataReport.totalRow);
        System.assertEquals('1', dataReport.pageShow);

        List<SCC_BrivaWrapper.DataReportBriva> listDataReport = new List<SCC_BrivaWrapper.DataReportBriva>{ dataReport };

       
        SCC_BrivaWrapper.ReportBrivaResponse reportResp = new SCC_BrivaWrapper.ReportBrivaResponse();
        reportResp.statusCode = 200;
        reportResp.errorCode = '00';
        reportResp.responseCode = '200';
        reportResp.responseMessage = 'REPORT OK';
        reportResp.errors = '';
        reportResp.data = listDataReport;

        System.assertEquals(200, reportResp.statusCode);
        System.assertEquals(1, reportResp.data.size());
    }
}