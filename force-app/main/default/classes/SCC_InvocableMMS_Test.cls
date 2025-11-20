@isTest
private class SCC_InvocableMMS_Test {

    @isTest
    static void testCreateTicketMMS_Success() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_MMS_Mock.ResponseCreateTicketMMSSuccess());

        List<SCC_InvocableMMS.FlowInputValues> reqList = new List<SCC_InvocableMMS.FlowInputValues>();
        SCC_InvocableMMS.FlowInputValues req = new SCC_InvocableMMS.FlowInputValues();
        req.id_ticket_bricare = 'TTB000001683863';
        req.mid = '000012596382';
        req.tid = '18551749';
        req.kode_uker = '00000';
        req.call_type = '8630';
        req.nama_pic = 'andi';
        req.telp_pic = '08123456789';
        req.attachment = 'TEMP/0_PJf88gv_small_pdf.pdf_mEDZA8lS8.pdf';
        req.remark = 'Test remark';
        req.reff_number = '1999569819219271';
        req.jumlah_transaksi = 1;
        req.nominal_transaksi = 500000;
        req.tanggal_transaksi = '2025-03-01';
        req.merchant_type = 'EDC';
        reqList.add(req);

        List<SCC_InvocableMMS.FlowResponseValues> responseList = SCC_InvocableMMS.createTicketMMS(reqList);
        Test.stopTest();

        System.assertEquals(1, responseList.size());
        System.assertEquals('00', responseList[0].rc);
        System.assertEquals('Success', responseList[0].descs);
        System.assertEquals('BRI12345', responseList[0].id_tiket_bricare);
    }

    @isTest
    static void testCreateTicketMMS_Error() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SCC_MMS_Mock.ResponseCreateTicketMMSError());

        List<SCC_InvocableMMS.FlowInputValues> reqList = new List<SCC_InvocableMMS.FlowInputValues>();
        SCC_InvocableMMS.FlowInputValues req = new SCC_InvocableMMS.FlowInputValues();
        req.id_ticket_bricare = 'TTB000001683863';
        req.mid = '000012596382';
        req.tid = '18551749';
        req.kode_uker = '00000';
        req.call_type = '8630';
        req.nama_pic = 'andi';
        req.telp_pic = '08123456789';
        req.attachment = '"TEMP/0_PJf88gv_small_pdf.pdf_mEDZA8lS8.pdf"';
        req.remark = 'Test remark';
        req.reff_number = '1999569819219271';
        req.jumlah_transaksi = 1;
        req.nominal_transaksi = 500000;
        req.tanggal_transaksi = '2025-03-01';
        req.merchant_type = 'Retail';
        reqList.add(req);

        List<SCC_InvocableMMS.FlowResponseValues> responseList = SCC_InvocableMMS.createTicketMMS(reqList);
        Test.stopTest();

        System.assertEquals(1, responseList.size());
        System.assertEquals('99', responseList[0].rc);
        System.assertEquals('Error', responseList[0].descs);
        System.assertEquals('', responseList[0].id_tiket_bricare);
    }
}