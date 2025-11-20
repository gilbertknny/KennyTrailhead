public with sharing class SCC_Brizzi_CardReplace_UI {
    @AuraEnabled
    public static CardInfo getCardInfo(Id recordId) {
        // Add your logic to fetch card details based on recordId
        CardInfo info = new CardInfo();
        // Populate the info object
        return info;
    }

    @AuraEnabled
    public static SCC_BrizziWrapper.CardChangeResponse retryReplace(String csid){
        System.debug('request Card Replace called');
        Brizzi_Card__c dtcs = [SELECT Id, Nomor_Kartu_Brizzi__c, Nomor_Kartu_Brizzi_Baru__c, Saldo__c, Saldo_Deposit__c, Status_Replace__c, Description__c FROM Brizzi_Card__c WHERE Case__c = :csid AND Status_Replace__c = false LIMIT 1];
        System.debug('request Card Replace dtcs ='+dtcs);
        Case cs = [SELECT Id, Maker__r.Name, Signer__r.Name, Maker__r.EmployeeNumber, Signer__r.EmployeeNumber, SCC_Result_Adjust_Deposit__c, SCC_Result_Replace_Card__c, Count_Replace_Card__c, SCC_Result_Pembukuan__c, Count_Adjust_Deposit__c, SCC_Count_Queuetrans__c FROM Case WHERE Id = :csid LIMIT 1];
        Integer oldCardBalance = Integer.valueOf(dtcs.Saldo__c) + Integer.valueOf(dtcs.Saldo_Deposit__c);
        System.debug('request Card Replace oldCardBalance ='+oldCardBalance);
        System.debug('request o ='+oldCardBalance);

        SCC_BrizziWrapper.cardChangeRequest req = new SCC_BrizziWrapper.cardChangeRequest();
    
        // Initialize the data list
        req.data = new List<SCC_BrizziWrapper.CardChangeRequestData>();

        // Create a new CardInquiryRequestData object
        SCC_BrizziWrapper.CardChangeRequestData requestData = new SCC_BrizziWrapper.CardChangeRequestData();
        requestData.oldCardNumber = dtcs.Nomor_Kartu_Brizzi__c;
        requestData.newCardNumber = dtcs.Nomor_Kartu_Brizzi_Baru__c;
        requestData.oldCardBalance = Integer.valueOf(dtcs.Saldo__c);
        requestData.userMaker = cs.Maker__r.EmployeeNumber;
        requestData.userSigner = cs.Signer__r.EmployeeNumber;

        // Add the request data to the list
        req.data.add(requestData);
        System.debug('request Card Replace = '+req);
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_BrizziWrapper.cardChangeResponse res = new SCC_BrizziWrapper.cardChangeResponse();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
            res = Object_Test_Brizzi.cardChangeResponse();
        } 
        else{
            res = SCC_Brizzi_CardChange.changeCard(req,menu,recid);
        }
        System.debug('request success = '+res.responseDesc);
        if(res.responseDesc == 'success'){
            Brizzi_Card__c bc = new Brizzi_Card__c();
            bc.Id = dtcs.Id;
            bc.Status_Replace__c = true;
            bc.Description__c = res.responseDesc;
            update bc;

            if(cs.SCC_Count_Queuetrans__c > 0 && cs.SCC_Result_Pembukuan__c.contains('Successfully')){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = csid;
                caseToUpdate.Status = 'Closed';
                caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
                caseToUpdate.SCC_Result_Replace_Card__c = res.responseDesc;
                update caseToUpdate;
            }
            else if (cs.SCC_Count_Queuetrans__c == 0){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = csid;
                caseToUpdate.Status = 'Closed';
                caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
                caseToUpdate.SCC_Result_Replace_Card__c = res.responseDesc;
                update caseToUpdate;
            }
            else{
                Case caseToUpdate = new Case();
                caseToUpdate.Id = csid;
                caseToUpdate.SCC_Result_Replace_Card__c = res.responseDesc;
                update caseToUpdate;
            }
        }
        else{
            Brizzi_Card__c bc = new Brizzi_Card__c();
            bc.Id = dtcs.Id;
            bc.Status_Replace__c = false;
            bc.Description__c = res.responseDesc;
            update bc;

            // Update Case record for failure
            Case caseToUpdate = new Case();
            caseToUpdate.Id = csid;
            caseToUpdate.SCC_Result_Replace_Card__c = res.responseDesc;
            update caseToUpdate;
        }
        return res;
    }

    @AuraEnabled
    public static void replaceCard(String csid){
        Brizzi_Card__c dtcs = [SELECT Id, Nomor_Kartu_Brizzi__c, Nomor_Kartu_Brizzi_Baru__c, Saldo__c, Saldo_Deposit__c, Status_Replace__c, Description__c FROM Brizzi_Card__c WHERE Case__c = :csid AND Status_Replace__c = false LIMIT 1];
        Case cs = [SELECT Id, Maker__r.Name, Signer__r.Name, Signer__r.EmployeeNumber, Maker__r.EmployeeNumber, SCC_Result_Adjust_Deposit__c, SCC_Result_Replace_Card__c, Count_Replace_Card__c, Count_Adjust_Deposit__c, SCC_Result_Pembukuan__c, SCC_Count_Queuetrans__c FROM Case WHERE Id = :csid LIMIT 1];
        Integer oldCardBalance = Integer.valueOf(dtcs.Saldo__c) + Integer.valueOf(dtcs.Saldo_Deposit__c);
        try {
            SCC_BrizziWrapper.cardChangeRequest req = new SCC_BrizziWrapper.cardChangeRequest();
        
            // Initialize the data list
            req.data = new List<SCC_BrizziWrapper.CardChangeRequestData>();

            // Create a new CardInquiryRequestData object
            SCC_BrizziWrapper.CardChangeRequestData requestData = new SCC_BrizziWrapper.CardChangeRequestData();
            requestData.oldCardNumber = dtcs.Nomor_Kartu_Brizzi__c;
            requestData.newCardNumber = dtcs.Nomor_Kartu_Brizzi_Baru__c;
            requestData.oldCardBalance = Integer.valueOf(dtcs.Saldo__c);
            requestData.userMaker = cs.Maker__r.EmployeeNumber;
            requestData.userSigner = cs.Signer__r.EmployeeNumber;

            // Add the request data to the list
            req.data.add(requestData);
            System.debug('request Card Replace = '+req);
            String menu = 'Case - Resolution Center';
            String recid = cs.id;

            // Initialize the response object
            SCC_BrizziWrapper.cardChangeResponse res = new SCC_BrizziWrapper.cardChangeResponse();     
            
            // Check if a dummy response should be used
            if(label.Dummy_Response=='true'){
                res = Object_Test_Brizzi.cardChangeResponse();
            } 
            else{
                res = SCC_Brizzi_CardChange.changeCard(req,menu,recid);
            }
            if(res.responseDesc == 'success'){
                Brizzi_Card__c bc = new Brizzi_Card__c();
                bc.Id = dtcs.Id;
                bc.Status_Replace__c = true;
                bc.Description__c = res.responseDesc;
                update bc;

                if(cs.SCC_Count_Queuetrans__c == 0){
                    Case caseToUpdate = new Case();
                    caseToUpdate.Id = csid;
                    caseToUpdate.Status = 'Closed';
                    caseToUpdate.SCC_Resolution_Category__c ='Tidak Mengirimkan Notifikasi';
                    caseToUpdate.SCC_Closure_Comments__c = label.Closed_CHM;
                    caseToUpdate.SCC_Result_Replace_Card__c = res.responseDesc;
                    update caseToUpdate;
                }
            }
            else{
                Brizzi_Card__c bc = new Brizzi_Card__c();
                bc.Id = dtcs.Id;
                bc.Status_Replace__c = false;
                bc.Description__c = res.responseDesc;
                update bc;
            }

            if(cs.SCC_Count_Queuetrans__c > 0){
                makePembukuanCallout(recid, res.responseDesc);
            }

        }
        catch(Exception exc){
            SCC_API.InsertErrorLog(exc,new HttpRequest(),new HTTPResponse(),new SCC_API.WrapperError('','SCC_Brizzi_CardCahange'));
        }
    }
    
    @AuraEnabled
    public static SCC_BrizziWrapper.CardChangeResponse replaceBrizziCard(Case cs, String oldCard, String newCard, Integer obc) {
        // Create a new request object
        SCC_BrizziWrapper.cardChangeRequest req = new SCC_BrizziWrapper.cardChangeRequest();
        
        // Initialize the data list
        req.data = new List<SCC_BrizziWrapper.CardChangeRequestData>();

        // Create a new CardInquiryRequestData object
        SCC_BrizziWrapper.CardChangeRequestData requestData = new SCC_BrizziWrapper.CardChangeRequestData();
        requestData.oldCardNumber = oldCard;
        requestData.newCardNumber = newCard;
        requestData.oldCardBalance = obc;
        requestData.userMaker = cs.Maker__r.EmployeeNumber;
        requestData.userSigner = cs.Signer__r.EmployeeNumber;

        // Add the request data to the list
        req.data.add(requestData);
        System.debug('request Card Replace = '+req);
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_BrizziWrapper.cardChangeResponse res = new SCC_BrizziWrapper.cardChangeResponse();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
            res = Object_Test_Brizzi.cardChangeResponse();
        } 
        else{
            res = SCC_Brizzi_CardChange.changeCard(req,menu,recid);
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
        return [SELECT Id, Status, SCC_Brizzi_Card_Number__c, SCC_Result_Adjust_Deposit__c, SCC_Result_Replace_Card__c FROM Case WHERE Id = :caseId LIMIT 1];
    }

    @AuraEnabled 
    public static SCC_BrizziWrapper.CardInquiryResponse getBrizziCardInquiry(Case cs, String cnumber){
        system.debug('cnumber ='+cnumber);
        // Create a new request object
        SCC_BrizziWrapper.CardInquiryRequest req = new SCC_BrizziWrapper.CardInquiryRequest();
        
        // Initialize the data list
        req.data = new List<SCC_BrizziWrapper.CardInquiryRequestData>();

        // Create a new CardInquiryRequestData object
        SCC_BrizziWrapper.CardInquiryRequestData requestData = new SCC_BrizziWrapper.CardInquiryRequestData();
        requestData.cardNumber = cnumber;
        User currentUser = [SELECT EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId()];
        requestData.userMaker = currentUser.EmployeeNumber != null ? currentUser.EmployeeNumber : '';

        // Add the request data to the list
        req.data.add(requestData);
        System.debug('request kartu brizzi = '+req);
        String menu = 'Case - Resolution Center';
        String recid = cs.id;

        // Initialize the response object
        SCC_BrizziWrapper.CardInquiryResponse res = new SCC_BrizziWrapper.CardInquiryResponse();     
        
        // Check if a dummy response should be used
        if(label.Dummy_Response=='true'){
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
    public static Brizzi_Card__c insertDataReplaceCard(Case cs, String oldCard, String newCard, Decimal saldoKartu, Decimal saldoDeposit) {
        try {
            // Look for existing record
            List<Brizzi_Card__c> existingRecords = [
                SELECT Id, Case__c, Nomor_Kartu_Brizzi__c, Nomor_Kartu_Brizzi_Baru__c, Saldo__c, Saldo_Deposit__c
                FROM Brizzi_Card__c 
                WHERE Case__c = :cs.Id 
                AND Nomor_Kartu_Brizzi__c = :oldCard
                LIMIT 1
            ];
            System.debug('Existing records found: ' + existingRecords.size());
            Brizzi_Card__c ReplaceRecord;
            
            if (!existingRecords.isEmpty()) {
                // Update existing record
                ReplaceRecord = existingRecords[0];
                ReplaceRecord.Nomor_Kartu_Brizzi_Baru__c = newCard;  // Update new card
                ReplaceRecord.Saldo__c = String.valueOf(saldoKartu);                 // Update saldo kartu
                ReplaceRecord.Saldo_Deposit__c = String.valueOf(saldoDeposit);       // Update saldo deposit
                System.debug('Updating existing record with new values');
            } else {
                // Create new record
                ReplaceRecord = new Brizzi_Card__c(
                    Case__c = cs.Id,
                    Nomor_Kartu_Brizzi__c = oldCard,
                    Nomor_Kartu_Brizzi_Baru__c = newCard,
                    Saldo__c = String.valueOf(saldoKartu),
                    Saldo_Deposit__c = String.valueOf(saldoDeposit)
                ); 
                System.debug('Creating new record');
            }
            
            upsert ReplaceRecord;

            Case caseToUpdate = new Case();
            caseToUpdate.Id = cs.Id;
            caseToUpdate.Maker__c = UserInfo.getUserId();
            update caseToUpdate;
            
            return ReplaceRecord;
        } catch (Exception e) {
            throw new AuraHandledException('Error processing Replace Card: ' + e.getMessage());
        }
    }

    @future(callout=true)
    private static void makePembukuanCallout(Id caseId, String responseDesc){
        String msg = responseDesc;
        SCC_Brizzi_Pembukuan.pembukuanBrizzi(caseId, msg, false);
    }
}