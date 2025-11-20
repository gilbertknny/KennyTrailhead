public with sharing class SCC_Brizzi_AdjustDeposit_UI {
    @TestVisible
    private static Boolean useDummyResponseInTest = false;

    @AuraEnabled
    public static CardInfo getCardInfo(Id recordId) {
        // Add your logic to fetch card details based on recordId
        CardInfo info = new CardInfo();
        // Populate the info object
        return info;
    }

    @AuraEnabled
    public static SCC_BrizziWrapper.AdjustDepositResponse retryAdjust(String csid){
        System.debug('Case ID = '+csid);
        Adjust_Deposit__c dtcs = [SELECT Id, Nomor_Kartu_Brizzi__c, Reduce_Balance__c, Saldo_Deposit__c, Saldo_Kartu__c, Nominal_Adjust__c, Description__c FROM Adjust_Deposit__c WHERE Case__c = :csid AND Status_Adjust__c = false LIMIT 1];
        Case cs = [SELECT Id, Maker__r.Name, Maker__r.EmployeeNumber, Signer__r.Name, Signer__r.EmployeeNumber, SCC_Result_Adjust_Deposit__c, SCC_Result_Replace_Card__c, SCC_Result_Pembukuan__c, Count_Replace_Card__c, Count_Adjust_Deposit__c, SCC_Count_Queuetrans__c FROM Case WHERE Id = :csid LIMIT 1];
        
        SCC_BrizziWrapper.AdjustDepositRequest req = new SCC_BrizziWrapper.AdjustDepositRequest();
    
        // Initialize the data list
        req.data = new List<SCC_BrizziWrapper.AdjustDepositDataRequest>();

        // Create a new CardInquiryRequestData object
        SCC_BrizziWrapper.AdjustDepositDataRequest requestData = new SCC_BrizziWrapper.AdjustDepositDataRequest();
        requestData.cardNumber = dtcs.Nomor_Kartu_Brizzi__c;
        requestData.amount = Decimal.valueOf(dtcs.Nominal_Adjust__c);
        // requestData.userMaker = UserInfo.getName();
        requestData.userMaker = cs.Maker__r.EmployeeNumber;
        requestData.userSigner = cs.Signer__r.EmployeeNumber;
        requestData.hostBalanceCorrection = dtcs.Reduce_Balance__c;

        // Add the request data to the list
        req.data.add(requestData);
        System.debug('request Adjust deposit = '+req);
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_BrizziWrapper.AdjustDepositResponse res = new SCC_BrizziWrapper.AdjustDepositResponse();     
        
        // Check if a dummy response should be used
        if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
            res = Object_Test_Brizzi.adjustDepositResponse();
        } 
        else{
            res = SCC_Brizzi_AdjustDeposit.adjustDeposit(req,menu,recid);
        }
        if(res.responseDesc == 'success'){
            Adjust_Deposit__c ad = new Adjust_Deposit__c();
            ad.Id = dtcs.Id;
            ad.Status_Adjust__c = true;
            ad.Description__c = res.responseDesc;
            update ad;

            if(cs.SCC_Count_Queuetrans__c > 0 && cs.SCC_Result_Pembukuan__c.contains('Successfully')){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = csid;
                caseToUpdate.Status = 'Closed';
                caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
                caseToUpdate.SCC_Result_Adjust_Deposit__c = res.responseDesc;
                update caseToUpdate;
            }
            else if (cs.SCC_Count_Queuetrans__c == 0){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = csid;
                caseToUpdate.Status = 'Closed';
                caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
                caseToUpdate.SCC_Result_Adjust_Deposit__c = res.responseDesc;
                update caseToUpdate;
            }
            else{
                Case caseToUpdate = new Case();
                caseToUpdate.Id = csid;
                caseToUpdate.SCC_Result_Adjust_Deposit__c = res.responseDesc;
                update caseToUpdate;
            }
        }
        else {
            Adjust_Deposit__c ad = new Adjust_Deposit__c();
            ad.Id = dtcs.Id;
            ad.Status_Adjust__c = false;
            ad.Description__c = res.responseDesc;
            update ad;

            // Update Case record for failure
            Case caseToUpdate = new Case();
            caseToUpdate.Id = csid;
            caseToUpdate.SCC_Result_Adjust_Deposit__c = res.responseDesc;
            update caseToUpdate;
        }
        return res;
    }

    @AuraEnabled
    public static void adjustDepositBrizzi(String csid){
        Adjust_Deposit__c dtcs = [SELECT Id, Nomor_Kartu_Brizzi__c, Reduce_Balance__c, Saldo_Deposit__c, Saldo_Kartu__c, Nominal_Adjust__c, Description__c FROM Adjust_Deposit__c WHERE Case__c = :csid AND Status_Adjust__c = false LIMIT 1];
        Case cs = [SELECT Id, Maker__r.Name, Maker__r.EmployeeNumber, Signer__r.EmployeeNumber, Signer__r.Name, SCC_Result_Adjust_Deposit__c, SCC_Result_Replace_Card__c, SCC_Result_Pembukuan__c, Count_Replace_Card__c, Count_Adjust_Deposit__c, SCC_Count_Queuetrans__c FROM Case WHERE Id = :csid LIMIT 1];
        try {
            SCC_BrizziWrapper.AdjustDepositRequest req = new SCC_BrizziWrapper.AdjustDepositRequest();
        
            // Initialize the data list
            req.data = new List<SCC_BrizziWrapper.AdjustDepositDataRequest>();

            // Create a new CardInquiryRequestData object
            SCC_BrizziWrapper.AdjustDepositDataRequest requestData = new SCC_BrizziWrapper.AdjustDepositDataRequest();
            requestData.cardNumber = dtcs.Nomor_Kartu_Brizzi__c;
            requestData.amount = Decimal.valueOf(dtcs.Nominal_Adjust__c);
            // requestData.userMaker = UserInfo.getName();
            requestData.userMaker = cs.Maker__r.EmployeeNumber;
            requestData.userSigner = cs.Signer__r.EmployeeNumber;
            requestData.hostBalanceCorrection = dtcs.Reduce_Balance__c;

            // Add the request data to the list
            req.data.add(requestData);
            System.debug('request Adjust deposit = '+req);
            String menu = 'Case - Resolution Center';
            String recid = cs.id;

            // Initialize the response object
            SCC_BrizziWrapper.AdjustDepositResponse res = new SCC_BrizziWrapper.AdjustDepositResponse();     
            
            // Check if a dummy response should be used
            if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
                res = Object_Test_Brizzi.adjustDepositResponse();
            } 
            else{
                res = SCC_Brizzi_AdjustDeposit.adjustDeposit(req,menu,recid);
            }
            System.debug('Response Adjust deposit = '+res);
            System.debug('ResponseDesc Adjust deposit = '+res.responseDesc);
            if(res.responseDesc == 'success'){
                Adjust_Deposit__c ad = new Adjust_Deposit__c();
                ad.Id = dtcs.Id;
                ad.Status_Adjust__c = true;
                ad.Description__c = res.responseDesc;
                update ad;

                if(cs.SCC_Count_Queuetrans__c == 0){
                    Case caseToUpdate = new Case();
                    caseToUpdate.Id = csid;
                    caseToUpdate.Status = 'Closed';
                    caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                    caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
                    caseToUpdate.SCC_Result_Adjust_Deposit__c = res.responseDesc;
                    update caseToUpdate;
                }
                
            }
            else {
                Adjust_Deposit__c ad = new Adjust_Deposit__c();
                ad.Id = dtcs.Id;
                ad.Status_Adjust__c = false;
                ad.Description__c = res.responseDesc;
                update ad;
            }
            if(cs.SCC_Count_Queuetrans__c > 0){
                makePembukuanCallout(recid, res.responseDesc);
            }
        }
        catch(Exception exc){
            SCC_API.InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),new SCC_API.WrapperError('','SCC_Brizzi_AdjustDeposit'));
        }
    }

    @AuraEnabled
    public static SCC_BrizziWrapper.AdjustDepositResponse adjustDeposit(Case cs, String cardNumber, Decimal amount, Boolean reduceBalance) {
        // Create a new request object
        SCC_BrizziWrapper.AdjustDepositRequest req = new SCC_BrizziWrapper.AdjustDepositRequest();
        
        // Initialize the data list
        req.data = new List<SCC_BrizziWrapper.AdjustDepositDataRequest>();

        // Create a new CardInquiryRequestData object
        SCC_BrizziWrapper.AdjustDepositDataRequest requestData = new SCC_BrizziWrapper.AdjustDepositDataRequest();
        requestData.cardNumber = cardNumber;
        requestData.amount = amount;
        // requestData.userMaker = UserInfo.getName();
        requestData.userMaker = cs.Maker__r.EmployeeNumber;
        requestData.userSigner = cs.Signer__r.EmployeeNumber;
        requestData.hostBalanceCorrection = reduceBalance;

        // Add the request data to the list
        req.data.add(requestData);
        System.debug('request Adjust deposit = '+req);
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_BrizziWrapper.AdjustDepositResponse res = new SCC_BrizziWrapper.AdjustDepositResponse();     
        
        // Check if a dummy response should be used
        if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
            res = Object_Test_Brizzi.adjustDepositResponse();
        } 
        else{
            res = SCC_Brizzi_AdjustDeposit.adjustDeposit(req,menu,recid);
        }
        System.debug('Response kartu brizzi = '+res);

        return res; 
    }
    
    // Wrapper class for card information
    public class CardInfo {
        @AuraEnabled public String cardNumber { get; set; }
        @AuraEnabled public Decimal cardBalance { get; set; }
        @AuraEnabled public Decimal depositBalance { get; set; }
    }

    @AuraEnabled
    public static Case getCaseDetails(Id caseId) {
        return [SELECT Id, Status, SCC_Brizzi_Card_Number__c, SCC_Result_Adjust_Deposit__c FROM Case WHERE Id = :caseId LIMIT 1];
    }

    @AuraEnabled 
    public static SCC_BrizziWrapper.CardInquiryResponse getBrizziCardInquiry(Case cs){
        
        // Create a new request object
        SCC_BrizziWrapper.CardInquiryRequest req = new SCC_BrizziWrapper.CardInquiryRequest();
        
        // Initialize the data list
        req.data = new List<SCC_BrizziWrapper.CardInquiryRequestData>();

        // Create a new CardInquiryRequestData object
        SCC_BrizziWrapper.CardInquiryRequestData requestData = new SCC_BrizziWrapper.CardInquiryRequestData();
        requestData.cardNumber = cs.SCC_Brizzi_Card_Number__c;
        requestData.userMaker = cs.Maker__r.Name;

        // Add the request data to the list
        req.data.add(requestData);
        System.debug('request kartu brizzi = '+req);
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_BrizziWrapper.CardInquiryResponse res = new SCC_BrizziWrapper.CardInquiryResponse();     
        
        // Check if a dummy response should be used
        if((Test.isRunningTest() && useDummyResponseInTest) || (!Test.isRunningTest() && label.Dummy_Response == 'true')){
            res = Object_Test_Brizzi.cardInquiryResponse();
        } 
        else{
            String mtd = SCC_Endpoint_API__mdt.getInstance('Brizzi_Inquiry').MasterLabel;
            res = SCC_Brizzi_CardInquiry.searchCard(req,mtd,menu,recid);
        }
        System.debug('Response kartu brizzi = '+res);

        return res; 
    }

    @AuraEnabled 
    public static Adjust_Deposit__c insertDataAdjustment(Case cs, String cardNumber, Decimal cardBalance, Decimal depositBalance, Decimal adjustAmount, Boolean reduceBalance) {
        try {
            // Look for existing record
            List<Adjust_Deposit__c> existingRecords = [
                SELECT Id, Case__c, Nomor_Kartu_Brizzi__c, 
                    Nominal_Adjust__c, Reduce_Balance__c, 
                    Saldo_Deposit__c, Saldo_Kartu__c
                FROM Adjust_Deposit__c 
                WHERE Case__c = :cs.Id 
                AND Nomor_Kartu_Brizzi__c = :cardNumber
                LIMIT 1
            ];

            Adjust_Deposit__c adjustRecord;
            
            if (!existingRecords.isEmpty()) {
                adjustRecord = existingRecords[0];
            } else {
                adjustRecord = new Adjust_Deposit__c(
                    Case__c = cs.Id,
                    Nomor_Kartu_Brizzi__c = cardNumber
                );
            }
            
            // Update fields
            adjustRecord.Saldo_Kartu__c = String.valueOf(cardBalance);
            adjustRecord.Saldo_Deposit__c = String.valueOf(depositBalance);
            adjustRecord.Nominal_Adjust__c = String.valueOf(adjustAmount);
            adjustRecord.Reduce_Balance__c = reduceBalance;
            
            upsert adjustRecord;

            Case caseToUpdate = new Case();
            caseToUpdate.Id = cs.Id;
            caseToUpdate.Maker__c = UserInfo.getUserId();

            system.debug('caseToUpdate = ' + caseToUpdate);
            update caseToUpdate;
            
            return adjustRecord;
        } catch (Exception e) {
            throw new AuraHandledException('Error processing adjustment: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<Adjust_Deposit__c> getListAdjustment(String idcs, String cardNumber) {
        String cond = 'case__c=:idcs and Nomor_Kartu_Brizzi__c = :cardNumber and Status_Adjust__c = false';
        String allfield = SOQL_SOBJECT.getallfield('Adjust_Deposit__c');
        String queries = SOQL_SOBJECT.SOQL(allfield, '', 'Adjust_Deposit__c', cond, '', '', '');
        List<Adjust_Deposit__c> listrk = Database.query(queries);
        return listrk;
    }

    @future(callout=true)
    private static void makePembukuanCallout(Id caseId, String responseDesc){
        String msg = responseDesc;
        SCC_Brizzi_Pembukuan.pembukuanBrizzi(caseId, msg, false);
    }

}