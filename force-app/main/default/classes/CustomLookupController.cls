public with sharing class CustomLookupController {
 
    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String ft) {
        try {
            List<RecordsData> recordsDataList = new List<RecordsData>();
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            query += ' WHERE '+filterField+' LIKE ' + '\'%' + String.escapeSingleQuotes(searchString.trim()) + '%\'';
            
            if(String.isNotBlank(ft)) {
                query += ' AND '+ft;
            }
            query += ' LIMIT 15';
	        for(SObject s : Database.query(query)) {
	            recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
	        }
            return recordsDataList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }

    @AuraEnabled
    public static List<RecordsData> getListAPI(String searchString,String tgl) {
        List<RecordsData> recordsDataList = new List<RecordsData>();
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse res = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListResponse();
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListRequest req = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDListRequest();
        req.input_text = searchString;
        req.dates = tgl;
        if(label.Dummy_Response=='true'){
            res = Object_Test.TerminalIDListResponse(searchString);
        } 
        else{
            res = SCC_CaseResolution_CHMSupport.SearchTerminalIDList(req);
        }
        if(res.data!=null){
            for(String str:res.data){
                recordsDataList.add(new RecordsData(str,str));
            }   
        }
        return recordsDataList;
    }

    @AuraEnabled
    Public static RecordsData getDataDetail(String tgl,String termid){
        RecordsData rd;
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse res = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDResponse();
        SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDRequest req = new SCC_CaseResolution_CHMSupport_Wrapper.TerminalIDRequest();
        req.terminal_id = termid;
        req.dates = tgl;
        if(label.Dummy_Response=='true'){
            res = Object_Test.TerminalIDResponse(termid);
        } 
        else{
            res = SCC_CaseResolution_CHMSupport.SearchTerminalID(req);
        }
        if(res?.data!=null){
            SCC_Terminal_ID__c tid = new SCC_Terminal_ID__c();
            tid.SCC_Account_Number__c = res?.data?.acct_no;
            tid.SCC_Add_Time__c = res?.data?.add_time;
            tid.SCC_Branch_Code__c = res?.data?.branch_code;
            tid.SCC_Teller_Id__c = res?.data?.teller_id;
            tid.Name = termid;
            tid.ext_id__c = res?.data?.terminal_id+'-'+res?.data?.acct_no+'-'+res?.data?.branch_code+'-'+res?.data?.teller_id;
            upsert tid ext_id__c;
            rd = new RecordsData(termid,tid?.id);
        }
        return rd;
    }
 
    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}