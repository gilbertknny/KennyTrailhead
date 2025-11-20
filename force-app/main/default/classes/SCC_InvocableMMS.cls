public with sharing class SCC_InvocableMMS {


    @InvocableMethod(label='Invocable MMS' description='Create ticket mms' category='Invocable')
    public static List<FlowResponseValues> createTicketMMS(List<FlowInputValues> req){

        FlowInputValues inputReq = new FlowInputValues();
        List<FlowResponseValues> outputRes = new List<FlowResponseValues>();
        FlowResponseValues resOutput = new FlowResponseValues();
        

        try{

            for(FlowInputValues f : req){
                inputReq.id_ticket_bricare = f.id_ticket_bricare;
                inputReq.mid = f.mid;
                inputReq.tid = f.tid;
                inputReq.kode_uker = f.kode_uker;
                inputReq.call_type = f.call_type;
                inputReq.nama_pic = f.nama_pic;
                inputReq.telp_pic = f.telp_pic;
                inputReq.attachment = f.attachment;
                inputReq.remark = f.remark;
                inputReq.reff_number  = f.reff_number;
                inputReq.jumlah_transaksi = f.jumlah_transaksi;
                inputReq.nominal_transaksi = f.nominal_transaksi;
                inputReq.tanggal_transaksi = f.tanggal_transaksi;
                inputReq.merchant_type = f.merchant_type;                
            }

            //cm settlement assigment
            SCC_MMSWrapper.cmSettlement cmSet = new SCC_MMSWrapper.cmSettlement();
            cmSet.jumlah_transaksi = inputReq.jumlah_transaksi;
            cmSet.nominal_transaksi = inputReq.nominal_transaksi;
            cmSet.reff_number = inputReq.reff_number;
            cmSet.tanggal_transaksi = inputReq.tanggal_transaksi;


            //request body
            SCC_MMSWrapper.RequestCreateMMS reqBody = new SCC_MMSWrapper.RequestCreateMMS();
            reqBody.ticket_type = 'settlement';
            reqBody.merchant_type = inputReq.merchant_type;
            reqBody.id_ticket_bricare = inputReq.id_ticket_bricare;
            reqBody.mid = inputReq.mid;
            reqBody.tid = inputReq.tid;
            reqBody.kode_uker = inputReq.kode_uker;
            reqBody.call_type = inputReq.call_type;
            reqBody.nama_pic = inputReq.nama_pic;
            reqBody.telp_pic = inputReq.telp_pic;
            reqBody.attachment = inputReq.attachment;
            reqBody.remark = inputReq.remark;
            reqBody.cm_settlement = cmSet;

            //Setup response 
            SCC_MMSWrapper.ResponseCreateMMS resTicket = SCC_MMS.createTicketMMS(reqBody);

            
              
                resOutput.rc = resTicket.rc;
                resOutput.descs = resTicket.descs;
                resOutput.msg = resTicket.msg;


                if(resTicket.rc == '00' && resTicket.data != null) {
                    resOutput.id_ticket = resTicket.data.id_tiket;
                    resOutput.id_tiket_bricare = resTicket.data.id_tiket_bricare;
                } else {
                    // Jika error atau data null, set nilai default
                    resOutput.id_ticket = null;
                    resOutput.id_tiket_bricare = '';
                }
                
                

                outputRes.add(resOutput);



        } catch(Exception e){
            System.debug('Error occured'+e.getMessage());
            System.debug('Error occured: ' + e.getMessage());
            // Set error response values
            resOutput.rc = '99';
            resOutput.msg = e.getMessage();
            resOutput.descs = 'Error: ' + e.getMessage();
            resOutput.id_ticket = null;
            resOutput.id_tiket_bricare = '';
            outputRes.add(resOutput);
        }

        return outputRes;

    }

    


    public class FlowResponseValues{
        @invocablevariable public String rc;
        @invocablevariable public String descs;
        @invocablevariable public String msg;
        @invocablevariable public Integer id_ticket;
        @invocablevariable public String id_tiket_bricare;
    }

    public class FlowInputValues {

        @invocablevariable public String id_ticket_bricare;
        @invocablevariable public String mid;
        @invocablevariable public String tid;
        @invocablevariable public String kode_uker;
        @invocablevariable public String call_type;
        @invocablevariable public String nama_pic;
        @invocablevariable public String telp_pic;
        @invocablevariable public String attachment;
        @invocablevariable public String remark;
        @invocablevariable public String reff_number;
        @invocablevariable public Integer jumlah_transaksi;
        @invocablevariable public Integer nominal_transaksi;
        @invocablevariable public String tanggal_transaksi;  
        @invocablevariable public String merchant_type;

    }


}