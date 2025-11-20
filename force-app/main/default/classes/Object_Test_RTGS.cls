@istest
public with sharing class Object_Test_RTGS {
    public static SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest findRTGSRequest(){
        SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest rtgsRequest = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest();
        rtgsRequest.request = new SCC_CaseResolution_FindRTGSWrapper.DataRequest();
        rtgsRequest.request.paymentData = new SCC_CaseResolution_FindRTGSWrapper.PaymentDataRequest();

        // Set the values
        rtgsRequest.request.kodePembayaran = '01';
        rtgsRequest.request.channelId = 'CHMS';
        rtgsRequest.request.serviceId = '000MD';
        rtgsRequest.request.externalId = '0000000000013';
        rtgsRequest.request.userName = '';
        rtgsRequest.request.tellerId = '';
        rtgsRequest.request.supervisorId = '';
        rtgsRequest.request.paymentData.idTransaction = '5014162923583778';

        return rtgsRequest;
    }

    public static SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse findRTGSResponse(){
        SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse rtgsResponse = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse();
        rtgsResponse.response = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSDataResponse();
        rtgsResponse.response.data = new SCC_CaseResolution_FindRTGSWrapper.DataResponse();

        // Set thge value
        rtgsResponse.response.responseCode = '00';
        rtgsResponse.response.errorCode = 'CHMS-000';
        rtgsResponse.response.responseMessage = 'Transaction Success - Success Get Data';
        rtgsResponse.response.data.originalTransaction = '261658850754';
        rtgsResponse.response.data.referenceTransaction = '5014162923583778';
        rtgsResponse.response.data.mt = '103';
        rtgsResponse.response.data.ttc = '100';
        rtgsResponse.response.data.dateTransaction = '14012025';
        rtgsResponse.response.data.amountDebit = '130000000.00';
        rtgsResponse.response.data.debitCurrency = 'IDR';
        rtgsResponse.response.data.amountCredit = '130000000.00';
        rtgsResponse.response.data.creditCurrency = 'IDR';
        rtgsResponse.response.data.feeAmount = '9500.00';
        rtgsResponse.response.data.feeCurrency = 'IDR';
        rtgsResponse.response.data.ppn = '0.00';
        rtgsResponse.response.data.toMemberBIC = '261658850754';
        rtgsResponse.response.data.orderingCustomerAccount = '20601157047501';
        rtgsResponse.response.data.orderingCustomerName = 'REKENING KAS UMUM DAERAH KAB POLEWA SEHUBUNGAN DENGAN TRANSAKSI KAS';
        rtgsResponse.response.data.beneficiaryCustomerAccount = '2571075557';
        rtgsResponse.response.data.beneficiaryCustomerName = 'REKENING KAS UMUM DAERAH PROV POLEWA SEHUBUNGAN DENGAN TRANSAKSI KAS';
        rtgsResponse.response.data.remittanceInformation = 'PembayaranProyek';
        rtgsResponse.response.data.noSakti = '';
        rtgsResponse.response.data.isNotPool = 'false';
        rtgsResponse.response.data.isWic = 'false';
        rtgsResponse.response.data.bankOwnReference = '';
        rtgsResponse.response.data.saranaTransaksi = '';
        rtgsResponse.response.data.channel = 'CHMS';
        rtgsResponse.response.data.insertDate = '2025-01-14T16:29:24Z';
        rtgsResponse.response.data.returnDate = '';
        rtgsResponse.response.data.userMaker = '0206051';
        rtgsResponse.response.data.makerDate = '2025-01-14 04:29:23 +0000 UTC';
        rtgsResponse.response.data.userApprove = '0206051';
        rtgsResponse.response.data.approveDate = '2025-01-14 04:29:23 +0000 UTC';
        rtgsResponse.response.data.status = '3';
        rtgsResponse.response.data.statusDesc = 'Success Insert Transaction Non STP';

        return rtgsResponse;
    }

    public static SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponseError findRTGSResponseError(){
        SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponseError rtgsResponseError = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponseError();
        rtgsResponseError.response = new SCC_CaseResolution_FindRTGSWrapper.ErrorResponse();

        // Set the value
        rtgsResponseError.response.errorCode = 'ES-005';
        rtgsResponseError.response.responseMessage = 'Duplicate External ID';
        rtgsResponseError.response.responseCode = '02';

        return rtgsResponseError;
    }

    public static Master_Mapping_Feature__c setMappingFeature(String nm, Id ct, Id feature, String rm, String rm2, String pd){
        Master_Mapping_Feature__c mf = new Master_Mapping_Feature__c();
        mf.Name = nm;
        mf.CurrencyIsoCode = 'IDR';
        mf.Case_Type__c = ct;
        mf.Feature__c = feature;
        mf.Remark_2__c = rm;
        mf.Remark__c = rm2;
        mf.Provider__c = pd;
        return mf ;
    }

    public static Master_Kor__c setMasterKor(String nm, Id ct, String pd){
        Master_Kor__c mmf = new Master_Kor__c();
        mmf.Name = nm;
        mmf.Case_Type__c = ct;
        mmf.Provider__c = pd;
        mmf.CurrencyIsoCode = 'IDR';
        return mmf ;
    }
}