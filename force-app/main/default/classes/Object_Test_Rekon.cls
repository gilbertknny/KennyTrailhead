public with sharing class Object_Test_Rekon {
    public static SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse getDummySavingMutationResponse() {
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse response = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationResponse();
    
        response.statusCode = 200;
        response.responseCode = '00';
        response.responseMessage = 'Success';
        response.errorCode = null;
        response.errors = new List<String>();
    
        // Prepare dummy data
        List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData> dataList = new List<SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData>();
    
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data1 = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data1.idNum3 = 1001;
        data1.idNum2 = 2001;
        data1.seq = 1;
        data1.idNum = 3001;
        data1.noRek = 1234567890;
        data1.tglTran = '2025-05-01';
        data1.tglEfektif = '2025-05-02';
        data1.jamTran = 91500; // 09:15:00
        data1.kodeTran = 'D01';
        data1.deskTran = 'Setoran Tunai';
        data1.saldoAwalMutasi = 500000;
        data1.mutasiDebet = 100000;
        data1.mutasiKredit = 0;
        data1.saldoAkhirMutasi = 600000;
        data1.truser = 'user01';
        data1.glsign = 'D';
        data1.terbilang = 'Seratus Ribu Rupiah';
        data1.trremk = 'PLN-PRA 14311959879NBMB5221843172141348 ESB:NBMB:20006PLN:782659607996';
        data1.auxtrc = 'ATM123';
        data1.serial = 'TXN001';
        data1.tlbds1 = 'Loket 1';
        data1.tlbds2 = 'Cabang Jakarta';
        data1.remarkCustom = 'Sukses';
    
        SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData data2 = new SCC_CaseResoultion_DataHub_Wrapper.SavingMutationData();
        data2.idNum3 = 1002;
        data2.idNum2 = 2002;
        data2.seq = 2;
        data2.idNum = 3002;
        data2.noRek = 1234567890;
        data2.tglTran = '2025-05-03';
        data2.tglEfektif = '2025-05-03';
        data2.jamTran = 113000; // 11:30:00
        data2.kodeTran = 'W01';
        data2.deskTran = 'Penarikan Tunai';
        data2.saldoAwalMutasi = 600000;
        data2.mutasiDebet = 0;
        data2.mutasiKredit = 150000;
        data2.saldoAkhirMutasi = 450000;
        data2.truser = 'user02';
        data2.glsign = 'K';
        data2.terbilang = 'Seratus Lima Puluh Ribu Rupiah';
        data2.trremk = 'Kor-PLN:601301110645xxxx:11/11/24:174942';
        data2.auxtrc = 'ATM456';
        data2.serial = 'TXN002';
        data2.tlbds1 = 'ATM Center';
        data2.tlbds2 = 'Mall ABC';
        data2.remarkCustom = 'Berhasil';
    
        dataList.add(data1);
        dataList.add(data2);
    
        response.data = dataList;
    
        return response;
    }

    @AuraEnabled
    public static SCC_RekonWrapper.RekonTokenResponse getDummyResponse() {
        List<SCC_RekonWrapper.RekonTokenDetailData> detailList = new List<SCC_RekonWrapper.RekonTokenDetailData>();

        SCC_RekonWrapper.RekonTokenDetailData detail1 = new SCC_RekonWrapper.RekonTokenDetailData();
        detail1.BillingCode = '14361525601';
        detail1.Fee = '3001.00';
        detail1.ID = 251001;
        detail1.NoToken = '86080980801';
        detail1.Nominal = '21000';
        detail1.RekDebet = '473701026064531';
        detail1.RekDebetFee = '473701026064531';
        detail1.RekKredit = '';
        detail1.Remark = 'PLN-PRA  14361525601 NBMB521';
        detail1.Seq = '504101';
        detail1.StatusMCS = '';
        detail1.StatusMCSDesc = '';
        detail1.StatusRecon = 'Unmatch BRI';
        detail1.TanggalTrans = '2024-10-21T00:00:00Z';

        SCC_RekonWrapper.RekonTokenDetailData detail2 = new SCC_RekonWrapper.RekonTokenDetailData();
        detail2.BillingCode = '14361525602';
        detail2.Fee = '3002.00';
        detail2.ID = 251002;
        detail2.NoToken = '86080980802';
        detail2.Nominal = '1075089';
        detail2.RekDebet = '473701026064532';
        detail2.RekDebetFee = '473701026064532';
        detail2.RekKredit = '123456789012345';
        detail2.Remark = 'PLN-PRA  14361525602 NBMB522';
        detail2.Seq = '504102';
        detail2.StatusMCS = '';
        detail2.StatusMCSDesc = '';
        detail2.StatusRecon = 'Match';
        detail2.TanggalTrans = '2024-10-22T00:00:00Z';

        SCC_RekonWrapper.RekonTokenDetailData detail3 = new SCC_RekonWrapper.RekonTokenDetailData();
        detail3.BillingCode = '14361525603';
        detail3.Fee = '3003.00';
        detail3.ID = 251003;
        detail3.NoToken = '';
        detail3.Nominal = '23000';
        detail3.RekDebet = '473701026064533';
        detail3.RekDebetFee = '473701026064533';
        detail3.RekKredit = '';
        detail3.Remark = 'PLN-PST  14361525603 NBMB523';
        detail3.Seq = '504103';
        detail3.StatusMCS = '';
        detail3.StatusMCSDesc = '';
        detail3.StatusRecon = 'Unmatch BRI';
        detail3.TanggalTrans = '2024-10-23T00:00:00Z';

        SCC_RekonWrapper.RekonTokenDetailData detail4 = new SCC_RekonWrapper.RekonTokenDetailData();
        detail4.BillingCode = '14361525604';
        detail4.Fee = '3003.00';
        detail4.ID = 251004;
        detail4.NoToken = '';
        detail4.Nominal = '23000';
        detail4.RekDebet = '473701026064534';
        detail4.RekDebetFee = '473701026064534';
        detail4.RekKredit = '';
        detail4.Remark = 'PLN-PST  14361525604 NBMB524';
        detail4.Seq = '504104';
        detail4.StatusMCS = '';
        detail4.StatusMCSDesc = '';
        detail4.StatusRecon = 'Unmatch BRI';
        detail4.TanggalTrans = '2024-10-23T00:00:00Z';

        // Add all detail records to list
        detailList.add(detail1);
        detailList.add(detail2);
        detailList.add(detail3);
        detailList.add(detail4);

        // Create response data
        SCC_RekonWrapper.RekonTokenResponseData responseData = new SCC_RekonWrapper.RekonTokenResponseData();
        responseData.detailData = detailList;
        responseData.statusScheduler = 'Done';

        // Create main response
        SCC_RekonWrapper.RekonTokenResponse response = new SCC_RekonWrapper.RekonTokenResponse();
        response.errorCode = 'RE-00';
        response.responseCode = '00';
        response.responseMessage = 'Transaction Successful';
        response.responseData = responseData;

        return response;
    }
}