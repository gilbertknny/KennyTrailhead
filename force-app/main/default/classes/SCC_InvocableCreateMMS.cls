public with sharing class SCC_InvocableCreateMMS {
    
  public static List<ResponseCreateMMS> createTicketMMS(List<RequestCreateMMS> req){

    RequestCreateMMS inputReq = new RequestCreateMMS();
    List<ResponseCreateMMS> outputRes = new List<ResponseCreateMMS>();
    SCC_MMSWrapper.cmSettlement cmSet = new SCC_MMSWrapper.cmSettlement();

    try {

        for(RequestCreateMMS r : req){
            inputReq.attachment = r.attachment;
            inputReq.call_type = r.call_type;
            inputReq.id_ticket_bricare = r.id_ticket_bricare;
            inputReq.jumlah_transaksi = r.jumlah_transaksi;
            inputReq.kode_uker = r.kode_uker;
            inputReq.merchant_type = r.merchant_type;
            inputReq.mid = r.mid;
            inputReq.nama_pic = r.nama_pic;
            inputReq.nominal_transaksi = r.nominal_transaksi;
            inputReq.reff_number = r.reff_number;
            inputReq.remark = r.remark;
            inputReq.tanggal_transaksi = r.tanggal_transaksi;
            inputReq.telp_pic = r.telp_pic;
            inputReq.ticket_type = r.ticket_type;
            inputReq.tid = r.tid;
        }

        //map cm_settlement
        cmSet.jumlah_transaksi = inputReq.jumlah_transaksi;
        cmSet.nominal_transaksi = inputReq.nominal_transaksi;
        cmSet.reff_number = inputReq.reff_number;
        cmSet.tanggal_transaksi = inputReq.tanggal_transaksi;

        //map request
        SCC_MMSWrapper.RequestCreateMMS reqBody = new SCC_MMSWrapper.RequestCreateMMS();
        reqBody.attachment = inputReq.attachment;
        reqBody.call_type = inputReq.call_type;
        reqBody.cm_settlement = cmSet;
        reqBody.id_ticket_bricare = inputReq.id_ticket_bricare;
        reqBody.kode_uker = inputReq.kode_uker;
        reqBody.merchant_type = inputReq.merchant_type;
        reqBody.mid = inputReq.mid;
        reqBody.nama_pic = inputReq.nama_pic;
        reqBody.remark = inputReq.remark;
        reqBody.telp_pic = inputReq.telp_pic;
        reqBody.ticket_type = inputReq.ticket_type;
        reqBody.tid = inputReq.tid;

        // send create mms
        SCC_MMSWrapper.ResponseCreateMMS resTicket = SCC_MMS.createTicketMMS(reqBody);


        //map invoker response
        ResponseCreateMMS resOutput = new ResponseCreateMMS(); 
        if(resTicket.data !=null){
           resOutput.rc = resTicket.rc; 
           resOutput.descs = resTicket.descs;
           resOutput.msg = resTicket.msg;
           resOutput.id_ticket = resTicket.data.id_tiket;
           resOutput.id_ticket_bricare = resTicket.data.id_tiket_bricare;
        }

        if(resTicket.data == null){
           resOutput.rc = resTicket.rc;
           resOutput.descs = resTicket.descs;
           resOutput.msg = null;
        }



    } catch (Exception e){
        SCC_API.insertErrorLog(e, null, null, new SCC_API.WrapperError('flow create ticket','SCC_InvocableCreateMMS'));
        System.debug('Error occured'+e.getMessage());
    }

    return outputRes;

  }   

  public class RequestCreateMMS {

    @InvocableVariable(required=true)
    public String ticket_type;

    @InvocableVariable(required=true) 
    public String merchant_type; 

    @InvocableVariable(required=true)
    public String id_ticket_bricare; 

    @InvocableVariable(required=true)
    public String mid;

    @InvocableVariable(required=true)
    public String tid;

    @InvocableVariable(required=true)
    public String kode_uker;

    @InvocableVariable(required=true)
    public String call_type; 

    @InvocableVariable(required=true)
    public String nama_pic;

    @InvocableVariable(required=true)
    public String telp_pic;

    @InvocableVariable(required=true) 
    public String attachment; 

    @InvocableVariable(required=true)
    public String remark;

    @InvocableVariable(required=true)
    public String reff_number;

    @InvocableVariable(required=true)
    public String jumlah_transaksi;

    @InvocableVariable(required=true)
    public Integer nominal_transaksi;
    
    @InvocableVariable(required=true)
    public String tanggal_transaksi;

  }  


  public class ResponseCreateMMS {

    @InvocableVariable
    public String rc;

    @InvocableVariable 
    public String descs;

    @InvocableVariable
    public String msg;

    @InvocableVariable
    public Integer id_ticket;

    @InvocableVariable
    public String id_ticket_bricare;
    
  }


}