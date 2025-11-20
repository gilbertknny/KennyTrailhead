public class Ctrl_PDF_ReportBranch {
    public Case cs {get;set;}
    public List<history> listremark {get;set;}
    public List<history> listhistory {get;set;}
    public String tgltransaksi {get;set;}
    public String tglbuat {get;set;}
    public string agentname {get;set;}
    public string gic {get;set;}
    public string amount {get;set;}
    public boolean isBOUser {get;set;}
    
    public Ctrl_PDF_ReportBranch(){
        isBOUser = false;
        String profileName = '';
        if(UserInfo.getUserType() == 'Standard'){
            Id profileId = userinfo.getProfileId();
            profileName = [SELECT Id, Name FROM Profile WHERE Id =: profileId].Name;
        }
        if(profileName == 'Back Office Users' || profileName == 'System Administrator'){
            isBOUser = true;
        }
        
        cs = new Case();
        listhistory = new List<history>();
        string recordid = ApexPages.currentPage().getParameters().get('recordid');
        system.debug(recordid);
        if(recordid == null) recordid = [SELECT Id FROM Case ORDER BY Id DESC LIMIT 1].Id;
        if(recordid != null){
            String allfieldCase = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfieldCase, ',Owner.UserRole.Name,Owner.Name,SCC_Call_Type__r.External_Id__c,Account.Name', 'Case', 'Id=:recordid', '', '', '');
            cs = Database.query(queries);
            system.debug(cs);
            /*
            cs = [SELECT Id,CaseNumber,Case_Number__c,SCC_Call_Type__r.External_Id__c,Description,Account.Name,SCC_Waktu_Transaksi__c,
                  CreatedDate,SCC_Cust_Phone1__c,SCC_Amount__c,SCC_Card_Number__c,SCC_Account_Number__c,SSC_Call_Type_Description__c,
                  Owner.Name,OwnerId,Owner.UserRole.Name
                  FROM Case WHERE Id=:recordid];
            */
			tgltransaksi = '';
            tglbuat = '';
            gic = '';
            agentname = '';
            amount = '';
            string ownerid = cs.OwnerId;
            if(cs.SCC_Waktu_Transaksi__c != null) tgltransaksi = cs.SCC_Waktu_Transaksi__c.format('MMM dd, yyyy HH:mm a');
            if(cs.CreatedDate != null) tglbuat = cs.CreatedDate.format('MMM dd, yyyy HH:mm a');
            if(ownerid.startsWith('00G')) gic = cs.Owner.Name;
            else agentname = cs.Owner.Name;
            if(gic == '') gic = cs.Owner.UserRole.Name;
            amount = isCurrency(cs.SCC_Amount__c);
            
            List<CaseHistory> listch = [SELECT Id, Field, DataType, OldValue, NewValue, CreatedDate 
                      FROM CaseHistory WHERE CaseId =:recordid AND DataType != 'EntityId' ORDER BY CreatedDate ASC];
            for(CaseHistory ch : listch){
                history h = new history();
                h.id = ch.Id;
                h.tanggal = ch.CreatedDate.format('MMM dd, yyyy HH:mm a');
                h.tanggalDT = ch.CreatedDate;
                String strold = '';
                String strnew = '';
                String deskripsi = ch.Field;
                system.debug(ch);
                if(ch.Field == 'created'){
                }else if(ch.DataType == 'DateTime'){
                    if(ch.OldValue != null && ch.OldValue != '') strold = DateTime.valueOf(ch.OldValue).format('MMM dd, yyyy HH:mm a');
                    if(ch.NewValue != null && ch.NewValue != '') strnew = DateTime.valueOf(ch.NewValue).format('MMM dd, yyyy HH:mm a');
                    deskripsi += joindeskripsi(strold,strnew);
                }else{
                    if(ch.OldValue != null) {
                        strold = String.valueof(ch.OldValue);
                    }
                    if(ch.NewValue != null) {
                        strnew = String.valueof(ch.NewValue);
                    }
                    deskripsi += joindeskripsi(strold,strnew);
                }
                h.deskripsi = deskripsi;
                listhistory.add(h);
            }
            
            listremark = new List<history>();
            if(!String.isBlank(cs.SCC_Drone_Remark_Update__c)){
                Pattern rmPattern = Pattern.compile('\\[(\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}) (.+)\\] (.+)');
                Matcher rmMatcher = rmPattern.matcher(cs.SCC_Drone_Remark_Update__c);
                while(rmMatcher.find()){
                    history h = new history();
                    h.tanggal = DateTime.valueOf(rmMatcher.group(1)).format('MMM dd, yyyy HH:mm a');
                    h.tanggalDT = DateTime.valueOf(rmMatcher.group(1));
                    h.deskripsi = rmMatcher.group(2) + ' : ' + rmMatcher.group(3);
                    listremark.add(h);
                }
            }
            
            listremark.sort(new HistoryComparator());
            listhistory.sort(new HistoryComparator());
        }
    }
    
    public class HistoryComparator implements Comparator<history> {
        public Integer compare(history h1, history h2) {
            Integer returnValue = 0;
            if (h1.tanggalDT < h2.tanggalDT) {
                returnValue = -1;
            } else if (h1.tanggalDT > h2.tanggalDT) {
                returnValue = 1;
            }
            return returnValue;
        }
    }
    
    public  string joindeskripsi(string join1,string join2){
        string result = '';
        if(join1 == '' && join2 == '') result = ' : updated.';
        else if(join1 == '' && join2 != '') result = ' : ' + join2;
        else result = ' : ' + join1 + ' -> '+join2;
        return result;
    }
    
    public string isCurrency(decimal dec){
        string result = '';
        if(dec != null){
            result = 'Rp ' + dec.format().replace('.','+').replace(',','.').replace('+',',');
        }
        return result;
    }
    
    public class history{
        public string id {get;set;}
        public string tanggal {get;set;}
        public datetime tanggalDT {get;set;}
        public string deskripsi {get;set;}
    } 
}