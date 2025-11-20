@istest
private class ErrorLogRecord_Test {
	@istest
    static void errorrecord(){
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@bri.co.id';
        User u = new User(Alias = 'stdad', Email='testadmin@bri.co.id',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = userinfo.getProfileId(),
                            TimeZoneSidKey='Asia/Jakarta',
                            UserName=uniqueUserName);
        System.runAs(u) {
            test.startTest();
            ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
            dl.message ='a';
            dl.trace = 'a';
            dl.typename = 'a';
            dl.linenumber = '1'; 
            dl.errorcause = 'a'; 
            dl.classname = 'SCC_CaseCreateLegacyAPI';
            dl.header = 'a';
            dl.body = 'a';
            dl.iprequest = 'a'; 
            dl.statuscode = 1; 
            dl.responsebody = '{"a":"a"}'; 
            dl.urLendpoint = '/xxx/'; 
            dl.typeapi = 'Inbound';
            dl.menu = 'System';
            dl.recid = '';
            dl.objnm = '';
            dl.iduser = UserInfo.getUserId();
            dl.sorc = 'CHM';
            dl.dest = 'CHM';
            ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
            ErrorLogRecord.inserterror(JSON.serialize(dl));
            
            Account acc = new Account();
            dl.cs = acc;
            Savepoint sp = Database.setSavepoint();
            try{
                insert acc;
            }
            catch(exception exc){
                ErrorLogRecord.errorexception(dl, sp,exc);
            }
            System.assertNotEquals(acc, null, 'account not found');
            test.stopTest();
        }   
    }
}