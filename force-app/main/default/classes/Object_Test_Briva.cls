public with sharing class Object_Test_Briva {

    public static SCC_BrivaWrapper.requestBrivaWrapper requestBriva(){
        
        SCC_BrivaWrapper.bodyBriva bodyBriva =  new SCC_BrivaWrapper.bodyBriva();
        bodyBriva.brivaNo = '12345678';
        bodyBriva.channelId = 'CHMS';
        bodyBriva.serviceId = '12345678';
        bodyBriva.externalId = '12345678910';

        SCC_BrivaWrapper.requestBrivaWrapper reqBriva = new SCC_BrivaWrapper.requestBrivaWrapper();
        reqBriva.request = bodyBriva;

        return reqBriva;
    }

    public static SCC_BrivaWrapper.responseBrivaWrapper responseBriva(){
        SCC_BrivaWrapper.responseBrivaWrapper res = new SCC_BrivaWrapper.responseBrivaWrapper();
        res.response = responseBodyBriva();

        return res;
    }

    public static SCC_BrivaWrapper.responseBriva responseBodyBriva(){

        SCC_BrivaWrapper.responseBriva responseBriva = new SCC_BrivaWrapper.responseBriva();
        responseBriva.data = dataBriva();
        responseBriva.errorCode = 'VA-619';
        responseBriva.responseCode = '00';
        responseBriva.responseMessage = 'Success';

        return responseBriva;
    }


    public static SCC_BrivaWrapper.dataBriva dataBriva(){
        List<SCC_BrivaWrapper.Brivaco> listBrivaco = new List<SCC_BrivaWrapper.Brivaco>();
        SCC_BrivaWrapper.Brivaco brivaco1 = brivaco('1', '123', 'david', 'deskripsi');
        listBrivaco.add(brivaco1);

        SCC_BrivaWrapper.dataBriva data = new SCC_BrivaWrapper.dataBriva();
        data.corpId = 'test';
        data.corpName = 'test';
        data.corpCode = 'test';
        data.corpAccountNo = '777777666666';
        data.currencys = 'test';
        data.isActive = 'test';
        data.corpFee = 'test';
        data.custFee = 'test';
        data.corpFeeAtm = 'test';
        data.custFeeAtm = 'test';
        data.corpFeeBrilink = 'test';
        data.custFeeBrilink = 'test';
        data.isSplitFee = 'test';
        data.amountFeeSplitBri = 'test';
        data.amountFeeSplit = 'test';
        data.amountFeeSplit2 = 'test';
        data.isSplitFeeEchannel = 'test';
        data.amountFeeSplitEchannelBri = 'test';
        data.amountFeeSplitEchannel = 'test';
        data.amountFeeSplitEchannel2 = 'test';
        data.isSplitFeeBrilink = 'test';
        data.amountFeeSplitBrilinkBri = 'test';
        data.amountFeeSplitBrilink = 'test';
        data.amountFeeSplitBrilink2 = 'test';
        data.accountNoFeeSplit = 'test';
        data.accountNFeeSplit2 = 'test';
        data.limitMinTrx = 'test';
        data.limitMaxTrx = 'test';
        data.openPayment = 'test';
        data.billingPayment = 'test';
        data.specialFlag = 'test';
        data.cif = 'test';
        data.brivaService = 'test';
        data.specialSegment = 'test';
        data.startIndexSegment = 'test';
        data.lengthIndexSegment = 'test';
        data.isKeteranganTambahan = 'test';
        data.itPartnerName = 'test';
        data.itPartnerPhoneNo = 'test';
        data.itPartnerEmail = 'test';
        data.businessPartnerName = 'test';
        data.businessPartnerPhoneNo = 'test';
        data.businessPartnerEmail = 'test';
        data.picRm = 'test';
        data.rmPhoneNo = 'test';
        data.rmEmail = 'test';
        data.profilingType = 'test';
        data.paymentChannel = 'test';
        data.brivaco = listBrivaco;   

        

        return data;
        
    }

    public static SCC_BrivaWrapper.Brivaco brivaco(String uniqueCode ,  String accNo, String accName , String dec){
        SCC_BrivaWrapper.Brivaco brivacoData = new SCC_BrivaWrapper.Brivaco();
        brivacoData.uniqueCode = uniqueCode;
        brivacoData.accountNo = accNo;
        brivacoData.accountName = accName;
        brivacoData.description = dec;

        return brivacoData;
    }
}