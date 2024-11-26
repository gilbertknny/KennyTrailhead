@isTest
public with sharing class SCC_Drone_Object_Test {
    
    public static SCC_DroneAPIWrapper.CheckManualReconRequestModel CheckManualReconRequestModel(){
        SCC_DroneAPIWrapper.CheckManualReconRequestModel req = new SCC_DroneAPIWrapper.CheckManualReconRequestModel();
        req.transaction_date = Date.newInstance(2024, 01, 01);
        req.amount = 3000000;
        req.call_type = '1002';
        req.nomor_rekening = '91299999912';
        req.nomor_kartu = '01219291929129912';
        req.terminal_id = '100012';
        return req;
    }

    public static SCC_DroneAPIWrapper.CheckManualReconRequestModel CheckManualReconRequestModelFalse(){
        SCC_DroneAPIWrapper.CheckManualReconRequestModel req = new SCC_DroneAPIWrapper.CheckManualReconRequestModel();
        req.amount = 3000000;
        req.call_type = '1002';
        return req;
    }

    public static SCC_DroneAPIWrapper.CheckManualReconResponseModel CheckManualReconResponseModel() {
        SCC_DroneAPIWrapper.CheckManualReconResponseModel res = new SCC_DroneAPIWrapper.CheckManualReconResponseModel();
        List<SCC_DroneAPIWrapper.DataManualRecon> dataList = new List<SCC_DroneAPIWrapper.DataManualRecon>();
     
        SCC_DroneAPIWrapper.DataManualRecon data = new SCC_DroneAPIWrapper.DataManualRecon();
        data.caseId = '01231239123122';
        data.caseNumber = 'TICKET00001223';
        data.manualRekonFlag = true;
        data.pembukuanSukses = true;
        data.status = 'New';

        dataList.add(data);

        res.data = dataList; 
        res.responseCode = '00';
        res.responseMessage = 'Success';
        res.totalSize = 1;

        return res;
    }


    public static SCC_DroneAPIWrapper.UpdateCaseRequestModel UpdateCaseRequestModel(String csnumber, Integer ft, String ct, Boolean cd, String process){
        SCC_DroneAPIWrapper.UpdateCaseRequestModel req = new SCC_DroneAPIWrapper.UpdateCaseRequestModel();
  
        req.case_number = csnumber;
        req.closed_by = '';
        req.closure_comments = '';
        req.fitur_id = ft;
        req.process = process;
        req.remark = 'tes remark';
        req.update_call_type = ct;
        req.closed_drone = cd;

        return req;
    }

    public static SCC_DroneAPIWrapper.UpdateCaseResponseModel UpdateCaseResponseModel(){
        SCC_DroneAPIWrapper.UpdateCaseResponseModel res = new SCC_DroneAPIWrapper.UpdateCaseResponseModel();

        res.responseCode = '00';
        res.responseMessage = 'Success';

        return res;
    }


    public static SCC_DroneAPIWrapper.RequestCreateTicketDrone RequestCreateTicketDrone(){
        SCC_DroneAPIWrapper.RequestCreateTicketDrone req = new SCC_DroneAPIWrapper.RequestCreateTicketDrone();
        req.acct_no = '12000012';
        req.amount = '100000';
        req.branch = 'Padang';
        req.call_type = '1001';
        req.card_no = '12012001202';
        req.cust_name = 'Test Name';
        req.email = 'test@mail.co';
        req.notelp = '081299930001';
        req.remark = 'remark';
        req.ticket_no_chm = 'TICKET1012931';
        req.trx_date = '2024-01-01';
        req.description = 'test desc';
        return req;
    }

    public static SCC_DroneAPIWrapper.ResponseCreateTicket ResponseCreateTicket(){
        SCC_DroneAPIWrapper.Data dt = new SCC_DroneAPIWrapper.Data();
        dt.ticket_no = 'TICKET191200';
        dt.ticket_no_chm = '11111574';

        SCC_DroneAPIWrapper.ResponseCreateTicket res = new SCC_DroneAPIWrapper.ResponseCreateTicket();
        res.status = 'true';
        res.code = '00';
        res.message = 'Berhasil';
        res.data = dt;

        return res;
    }
    
    public static SCC_DroneAPIWrapper.RequestUpdateTicketDrone RequestUpdateTicketDrone(){
        SCC_DroneAPIWrapper.RequestUpdateTicketDrone req = new SCC_DroneAPIWrapper.RequestUpdateTicketDrone();
        req.remark = 'test remark';
        req.ticket_no_chm = 'TICKET00129399';
        return req;
    }
}