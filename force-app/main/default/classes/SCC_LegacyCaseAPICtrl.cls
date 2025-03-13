public with sharing class SCC_LegacyCaseAPICtrl {
    Public Static SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel createCase(SCC_LegacyCaseAPIWrapper.CreateCaseRequestModel jreq){
        Map<String,String> mapcsori = new Map<String,String>();
        SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel jres = new SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel();
        Boolean isdrone = false;
        String calltypeid = jreq.CallTypeID;
        String cond = '( Name=:calltypeid or External_Id__c =:calltypeid ) and active__c=true';
        String allfield = SOQL_SOBJECT.getallfield('SSC_Call_Type__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'SSC_Call_Type__c', cond, '', '', '1');
        List<SSC_Call_Type__c> listct = Database.query(queries);
        Account acc = new Account();
        Case cs = new Case();
        String origin = jreq.Gateway;
        Boolean cekct = false;
        String telp = jreq.NoTelpPIC;
        if(String.isNotBlank(jreq.TipeIntegrasi)) {
            origin = jreq.TipeIntegrasi;
        }
        String notelp = jreq.NoTelpPIC; 
        cs.Subject = 'Case from '+jreq.TipeIntegrasi;
        cs.Description = jreq.Notes;
        cs.SCC_Notes__c = jreq.Notes; 
        cs.Status = 'New';
        cs.Origin = origin;
        cs.SuppliedName = jreq.NamaPIC;
        cs.SuppliedEmail = jreq.Email;
        cs.SCC_Email__c = jreq.Email;
        cs.SCC_Terminal_ID__c = jreq.TID;
        cs.SCC_Brigate_Transaction_ID__c = jreq.UniqueID;
        cs.SCC_Assignee__c = jreq.Assignee;
        cs.SCC_Card_Number__c = jreq.NomorKartu;
        cs.SCC_Account_Number__c = jreq.NoRekening;
        cs.SCC_Channel__c   = jreq.TipeIntegrasi;
        cs.SCC_Merchant_ID__c = jreq.MID;
        cs.SCC_Nama_Merchant__c = jreq.NamaMerchant;
        SCC_Legacy_Case__mdt sclc = SCC_Legacy_Case__mdt.getInstance(origin);
        if(sclc!=null){
            cs.Status = sclc?.status__c;
            cs.SCC_Closure_Comments__c = sclc?.Closure_Comment__c;
            cs.SCC_Resolution_Category__c = sclc?.SCC_Resolution_Category__c;
        }
        if(!listct.isempty()) {
            cs.SCC_Call_Type__c = listct[0]?.id;
            cs.SCC_Segment__c = listct[0]?.SCC_Customer_Segment__c;
            cs.SCC_Product_L1__c = listct[0]?.SSC_Product_L1__c;
            cs.SCC_Product_L2__c = listct[0]?.SSC_Product_L2__c;
            cs.SCC_Case_Category__c = listct[0]?.SSC_Case_Category__c;
            cs.Description = jreq.Notes+'\n\n'+listct[0]?.SCC_Additional_Details__c;
            cs.SSC_Call_Type_Description__c = listct[0]?.SSC_Case_Description__c;
            cs.SCC_List_of_Required_Documents__c = listct[0]?.SCC_List_of_Required_Documents__c;
            isdrone = listct[0].Send_to_Drone__c;
        }
        else{
            jres = setResponse('CallTypeNotFound');
            cekct = true;
        }
        if(String.isNotBlank(jreq.TID)){
            if(!jreq.TID.isAlphanumeric()){
                jres = setResponse('TID');
                cekct = true;
            }
        }
        if(String.isBlank(jreq.TID)){
            cs.SCC_Terminal_ID__c = label.tid;
        }
        if(String.isNotBlank(jreq.TglTransaksi)) {
            try{
                cs.SCC_Transaction_Date__c = Date.valueOf(jreq.TglTransaksi.substringBefore('T'));
                cs.SCC_Waktu_Transaksi__c = Datetime.valueof(jreq.TglTransaksi.replace('T',' '));
            }
            catch(Exception exc){
                jres = setResponse('TglTransaksi');
                cekct = true;
            }
        }
        if(String.isNotBlank(jreq.Nominal)) {
            if(jreq.Nominal.isNumeric()){
                cs.SCC_Amount__c = Decimal.valueOf(jreq.Nominal);
            }
            else{
                jres = setResponse('Nominal');
                cekct = true;
            }
        }
        if(String.isNotBlank(jreq.NomorKartu)){
            if(jreq.TipeIntegrasi == 'MMS'){
                cs.SCC_Card_Number__c = jreq.NomorKartu;
            }
            else if(!jreq.NomorKartu.isNumeric() || jreq.NomorKartu.length()>16){
                jres = setResponse('NomorKartu');
                cekct = true;
            }
            else if(jreq.NomorKartu.length()<16){
                cs.SCC_Card_Number__c = label.Nomor_Kartu;
            }
        }
        else {
            cs.SCC_Card_Number__c = label.Nomor_Kartu;
        }
        if(string.isNotBlank(jreq.NoTelpPIC)){
            telp = telp.replaceAll('[|,|.|\\,||"||:|~|!|@|#|$|%|^|&|*|_|+|-|=|<|>|?|\\(|\\)|\\{|\\}|\\;|\\\'"]', '').deleteWhitespace();
            telp = telp.replace('-', '');
            if(telp.isNumeric() && telp.length()>=10 && telp.length()<=14){
                cs.SuppliedPhone = telp;
                cs.SCC_Cust_Phone1__c = telp;
                cs.Cust_Current_Phone__c = telp;
            }
            else {
                jres = setResponse('NoTelpPIC');
                cekct = true;
            }
        }
        if(String.isNotBlank(cs.SCC_Account_Number__c)){
            if(!jreq.NoRekening.isNumeric() || jreq.NoRekening.length()<15 || jreq.NoRekening.length()>18){
                jres = setResponse('NoRekening');
                cekct = true;
            }
            else{
                SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse res = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponse();
                SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest req = new SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileRequest();
                req.acctNo = cs.SCC_Account_Number__c;
                req.channelId = 'CHMS';
                req.personalNumber = label.Personal_Number;
                res = SCC_CaseResoultion_DataHub.SearchCustomerProfile(req,'System','');
                if(res?.data!=null){
                    for(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileResponseData dt:res?.data){
                        String cifno = dt.cifno;
                        String condacc = 'SCC_cifno__c=:cifno';
                        String allfieldacc = SOQL_SOBJECT.getallfield('Account');
                        String queriesacc = SOQL_SOBJECT.SOQL(allfieldacc, '', 'Account', condacc, '', '', '1');
                        List<Account> listacc = Database.query(queriesacc);
                        SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi demographicInfo = dt?.demografi;
                        if(!listacc.isEmpty()){
                            acc = returnAccount(demographicInfo, listacc[0].id, dt?.cifno);
                        }
                        else{   
                            acc = returnAccount(demographicInfo, null, dt?.cifno);
                        }
                    } 
                    cs.AccountId = acc?.id;
                }
            }
        }
        if(!cekct){
            insert cs;
            Case css = [select id,createddate,CaseNumber,case_number__c from case where id=:cs.id];
            jres = setResponse('Success');
            jres.CreateDate =  css.createddate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
            jres.TroubleTicketID = css.case_number__c;
            //System.enqueueJob(new SCC_Channel(cs.id,'Escalation'));
        	if(listct[0].Send_to_Drone__c && !Test.isRunningTest()){
                System.enqueueJob(new SCC_Channel(cs.id,'Send To Drone'),1);
            }
        }
        return jres;
    }

    public static SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel setResponse(String resnm){
        SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel jres = new SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel();
        SCC_Custom_API_Response_Code__mdt rc = SCC_Custom_API_Response_Code__mdt.getInstance(resnm);
        jres.Response = rc.Description__c;
        if(resnm=='Success'){
            jres.Response = 'Tiket berhasil dibuat';
        }
        jres.responseCode = rc.Response_Code__c;
        jres.responseMessage = rc.masterlabel;
        return jres;
    }

    Public Static String returnAPI(SCC_LegacyCaseAPIWrapper.CreateCaseResponseModel jres){
        String returnjson = '';
        returnjson = (String) JSON.serialize(jres,false);
        returnjson = returnjson.normalizeSpace().trim(); 
        return returnjson;
    }

    Public Static String getCase(SCC_LegacyCaseAPIWrapper.GetCaseRequestModel jreq){
        Map<String, SCC_Legacy_API_Mapping_Query__mdt> mapmfc = SCC_Legacy_API_Mapping_Query__mdt.getAll();
        Map<String, SCC_Custom_API_Response_Code__mdt> maprc = SCC_Custom_API_Response_Code__mdt.getAll();
        SCC_Custom_API_Response_Code__mdt rc = new SCC_Custom_API_Response_Code__mdt();
        String cond = jreq.Qualification;
        for(SCC_Legacy_API_Mapping_Query__mdt mfc:mapmfc.values()){
            cond = cond.replace(mfc.MasterLabel,mfc.Field_API__c);
        }
        cond = cond.unescapeHtml4();
        String cnc = 'Cancelled';
        String dc = 'Disconnected';
        if(String.isBlank(cond)) {
            cond = '(status!=:cnc AND status!=:dc)';
        }
        if(String.isnotBlank(cond)) {
            cond = cond+' AND (status!=:cnc AND status!=:dc)';
        }
        String addfield = ',SCC_Call_Type__r.Name,SCC_Call_Type__r.External_id__c,SCC_Call_Type__r.SSC_Case_Description__c';
        String allfield = SOQL_SOBJECT.getallfield('Case');
        String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, 'Status_BRICARE_Priority__c,Createddate', 'ASC', '5000');
        List<Case> listcs = Database.query(queries);
        SCC_LegacyCaseAPIWrapper.GetCaseResponseModel jres = new SCC_LegacyCaseAPIWrapper.GetCaseResponseModel();
        List<SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel> tiketlist = new List<SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel>();
        Integer i = 0;
        Integer j = 0;
        Integer x = Integer.valueOf(jreq.startRecord);
        Integer y = Integer.valueOf(jreq.maxLimit);
        if(!listcs.isEmpty()){
            for(Case cs:listcs){
                String ctnum = '';
                if(String.isnotblank(cs.SCC_Call_Type__c)){
                    ctnum = cs?.SCC_Call_Type__r?.Name?.substringbefore('-').trim();
                }
                if(String.isNotBlank(cs.SCC_Call_Type__r.External_Id__c)){
                    ctnum = cs.SCC_Call_Type__r.External_Id__c;
                }
                Datetime dt = cs.SCC_Waktu_Transaksi__c;
                if(cs.SCC_Transaction_Date__c!=null && dt==null) {
                    dt = Datetime.newInstance(cs.SCC_Transaction_Date__c.year(),cs.SCC_Transaction_Date__c.month(),cs.SCC_Transaction_Date__c.day());
                }
                SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel tkt = new SCC_LegacyCaseAPIWrapper.GetCaseTicketDetailModel();
                tkt.TicketId = cs.Case_Number__c;
                tkt.Create_Date = cs.createddate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
                tkt.Calltype = cs.SCC_Call_Type__r.SSC_Case_Description__c;
                tkt.CalltypeID = ctnum;
                tkt.Status_Ticket = cs.SCC_Status_BRICARE__c;
                tkt.Status_SLA = cs.Status_SLA__c;
                tkt.TglTransaksi = '';
                if(dt!=null) {
                    tkt.TglTransaksi = dt.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
                }
                tkt.Nominal = String.valueOf(cs.SCC_Amount__c);
                tkt.NoTelpNasabah = cs.SuppliedPhone;
                tkt.Details = cs.SCC_Notes__c;
                if(cs.ClosedDate!=null){
                    tkt.close_date = cs.ClosedDate.format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
                }
                if(i>=x && j<y) {
                    tiketlist.add(tkt);
                    j++;
                }
                i++;
            }
            rc = maprc?.get('Success');
        }
        else{
            rc = maprc?.get('Data_Not_Found');
        }
        jres.TicketList = tiketlist;
        jres.responseCode = rc?.Response_Code__c;
        jres.responseMessage = rc?.Description__c;
        String returnjson = SCC_LegacyCaseAPICtrl.returnAPIGetCase(jres);
        return returnjson;
    }

    Public Static String returnAPIGetCase(SCC_LegacyCaseAPIWrapper.GetCaseResponseModel jres){
        String returnjson = '';
        returnjson = (String) JSON.serialize(jres,false);
        returnjson = returnjson.normalizeSpace().trim(); 
        return returnjson;
    }

    public static string validateAndSetEmail(String email) {        
        String emailPattern = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
        Pattern p = Pattern.compile(emailPattern);
        Matcher m = p.matcher(email);
        String validatedEmail = '';
        if (m.matches()) {
            validatedEmail = email;
        }
        return validatedEmail;
    }

    public static String calculateAge(String tanggalLahir){
        String age = '';
        Date dateOfBirth = Date.valueOf(tanggalLahir);
        Date birthDate = dateOfBirth.day() <= System.today().day() ? dateOfBirth : dateOfBirth.addMonths(-1);
        Integer years = System.today().year() - birthDate.year();
        age = String.valueOf(years);
        return age;
    }

    public static Account returnAccount(SCC_CaseResoultion_DataHub_Wrapper.CustomerProfileDemografi demographicInfo,id accid,String cifNumber){
        Account acc = new Account();
        String nasabah = '';
        try{
            if(demographicInfo.namaSesuaiId!=null){
                nasabah = demographicInfo.namaSesuaiId;
            }
            if(demographicInfo.namaSesuaiIdentitas!=null){
                nasabah = demographicInfo.namaSesuaiIdentitas;
            }
            if(String.isBlank(nasabah) && (String.isNotBlank(demographicInfo.nama1) || String.isNotBlank(demographicInfo.nama2) || String.isNotBlank(demographicInfo.nama3))){
                nasabah = demographicInfo.nama1+' '+demographicInfo.nama2+' '+demographicInfo.nama3;
            }
            if(demographicInfo.tipeNasabah == 'P'|| String.isBlank(demographicInfo.tipeNasabah) || demographicInfo.tipeNasabah == null){
                acc.LastName = nasabah;
                acc.SCC_Tipe_Nasabah__c = 'Individu';
                if(!String.isBlank(demographicInfo.email)) { 
                    acc.PersonEmail = validateAndSetEmail(demographicInfo.email); 
                    acc.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
                }
                acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            }else{ //if(demographicInfo.tipeNasabah == 'O'){
                acc.Name = nasabah;      
                acc.SCC_Tipe_Nasabah__c = 'Non-Individu';
                if(!String.isBlank(demographicInfo.email)) { 
                    acc.SCC_Primary_Email__c = validateAndSetEmail(demographicInfo.email);
                }
                acc.RecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
            }
            acc.SCC_TanggalLahir__c = calculateAge(demographicInfo?.tanggalLahir);
            acc.Provinsi__c = demographicInfo?.propinsiSesuaiID;
            acc.SCC_cifno__c = cifNumber;
            acc.Phone = demographicInfo?.handphone;
            acc.SCC_Jenis_Nasabah__c = (String.isnotBlank(demographicInfo?.nasabahPrioritas) || String.isNotBlank(demographicInfo?.prioritas)) ? 'Prioritas' : 'Non-Prioritas';
            
            if(String.isNotBlank(accid)){
                acc.id = accid;
                update acc;
            }
            else{
                insert acc;
            }
        }
        catch(exception exc){
            ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
            dl.message = exc?.getMessage();
            dl.trace = exc?.getStackTraceString();
            dl.typename = exc?.getTypeName();
            dl.linenumber = string.valueOf(exc?.getLineNumber()); 
            dl.errorcause = string.valueOf(exc?.getCause()); 
            dl.classname = 'SCC_LegacyCaseAPICtrl';
            ErrorLogRecord.inserterror(JSON.serialize(dl));
        }
        return acc;
    }
}