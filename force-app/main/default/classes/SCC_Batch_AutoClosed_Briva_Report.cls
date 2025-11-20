public with sharing class SCC_Batch_AutoClosed_Briva_Report implements Database.Batchable<SObject>,Database.AllowsCallouts {

    public String Query;

    public SCC_Batch_AutoClosed_Briva_Report(String q){
        this.Query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext bc , List<Case> scope){

        String brivaNumber = '';
        List<Case> listCase = new List<Case>();
        SCC_BrivaWrapper.ReportBrivaRequest reqBrivaReport = new SCC_BrivaWrapper.ReportBrivaRequest();

        try {

            for(Case s : scope){

                Integer matchedCondition = 0;

                reqBrivaReport.pageNumber = 1; //label
                reqBrivaReport.rowsPerPage = 999999; //label
                reqBrivaReport.tanggalAkhir =  DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                reqBrivaReport.tanggalAkhir = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                reqBrivaReport.uniqcode = 'ALL'; //label
                reqBrivaReport.corpCode = getCorpCode(s.SCC_Nomor_Briva_Tagihan__c);

                SCC_BrivaWrapper.ReportBrivaResponse resBrivaReport = SCC_InquiryBriva.getReportBriva(reqBrivaReport, 'Auto Close Briva Report', s.Id);
                List<SCC_BrivaWrapper.DataReportBriva> listDataReportBriva = resBrivaReport.data;

                if(listDataReportBriva != null){
                    
                    for(SCC_BrivaWrapper.DataReportBriva dataReport : listDataReportBriva){

                        if(String.isNotBlank(s.SCC_Nomor_Briva_Tagihan__c)){
                            SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper resultReport = checkReportBriva(s, dataReport);
                            Boolean matchedBrivaNumber = resultReport.matchedNumberBriva;
                            Boolean matchedAmountBriva = resultReport.matchedConditionAmount;

                            if(matchedBrivaNumber && matchedAmountBriva){
                                matchedCondition++;
                            }

                            if(matchedCondition > 1){
                                break;
                            }
                        }

                    }

                    if(matchedCondition == 1){
                        
                        //add case record to list
                        String tglTransaksi = DateTime.newInstance(s.SCC_Transaction_Date__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');
                        s.Status = 'Closed';
                        s.SCC_Status_Transaksi__c = 'Gagal';
                        String amountFormated = s.SCC_Amount__c.format();
                        s.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                        s.SCC_Closure_Comments__c = Label.Closed_Rekon;
                        s.SCC_Drone_Remark_Update__c = 'Berdasarkan penelitian yang kami lakukan, transaksi yang di komplainkan nasabah gagal. '
                            + 'Pengembalian dana telah terkredit ke Rekening Nasabah pada tanggal ' + tglTransaksi
                            + ' sebesar Rp' + amountFormated
                            + ' Mohon nasabah melakukan pengecekan Mutasi Rekening Koran.';


                        listCase.add(s);
                    }

                    if(!listCase.isEmpty()){
                        update listCase;
                    }
                }

            }
            
        } catch(Exception e) {
            System.debug(e.getMessage());
        }

    }

    public void finish(Database.BatchableContext bc){
        System.debug('Auto close Briva report');
    }


    public class BrivaReportWrapper{
        public Boolean matchedNumberBriva {get;set;}
        public Boolean matchedConditionAmount {get;set;}
        public BrivaReportWrapper(Boolean matchedNumberBriva , Boolean matchedConditionAmount){
            this.matchedConditionAmount = matchedConditionAmount;
            this.matchedNumberBriva = matchedNumberBriva;
        }
    }


    public static String getCorpCode(String brivaNumber) {
        if (String.isBlank(brivaNumber) || brivaNumber.length() < 5) {
            return null;
        }
        return brivaNumber.substring(0, 5);
    }




private SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper checkReportBriva(Case cs ,SCC_BrivaWrapper.DataReportBriva data ){
    String brivaNumber = cs.SCC_Nomor_Briva_Tagihan__c;
    Boolean matchedBrivaNumber = false;
    Boolean matchedConditionAmount = false;
    String tremkBriva = data.trremk;



    if(brivaNumber != null){
        if(tremkBriva.contains(brivaNumber)){
            matchedBrivaNumber = true;

            if(cs.SCC_Amount__c == data.amount){
                matchedConditionAmount = true;
            }
        }
    }

    SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper result = new SCC_Batch_AutoClosed_Briva_Report.BrivaReportWrapper(matchedBrivaNumber,matchedConditionAmount);
    return result;

}


    
}