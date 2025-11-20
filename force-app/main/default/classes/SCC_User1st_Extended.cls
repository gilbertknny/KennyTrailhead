global with sharing class SCC_User1st_Extended implements Queueable, Database.AllowsCallouts {
    public List<String> liststr {get;set;}
    global SCC_User1st_Extended(List<String> liststr){
        this.liststr = liststr; //0/1
    }
    
    global void execute(QueueableContext context) {
        Map<Integer,List<String>> mapstr = new Map<Integer,List<String>>();
        Integer i  = 0;
        try{
            for(String x : liststr){
                String str = x.unescapeHtml4();
                if(!str.contains('Type|FederationId|Pernr|Nama|CorpTitle|Hilfm|Htext|TipeUker|Area|SubArea|CostCenter|Orgeh|AreaDesc|SubAreaDesc|CostCenterDesc|OrgehDesc|Branch|DatePosition')){
                    i++;
                    List<String> listval = str.split('\\|');
                    mapstr.put(i, listval);
                }
            }
            if(!mapstr.isEmpty()){
                ID jobID = System.enqueueJob(new SCC_User2nd(1,mapstr,i));
            }
        }
        catch(Exception exc){
            SCC_User1st.InsertErrorLog(exc, 'SCC_User1st_Extended');
        }
    }
}