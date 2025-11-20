/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 27-02-2025
 * @last modified by  : Ardyta Yudianto
**/
public with sharing class SCC_Batch_AutoClosed_RTGS implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String query;

    public SCC_Batch_AutoClosed_RTGS(String q) {
        this.query = q;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope) {
        try {
            system.debug('execute autoclose RTGS'+scope);
            List<Case> casesToUpdate = new List<Case>();
            BRIMO__c br = BRIMO__c.getInstance('extId RTGS');
            
            // Fetch these values once outside the loop for better efficiency
            String channel = BrizziChannel__mdt.getInstance('CHMS')?.MasterLabel;
            String serviceId = BrizziChannel__mdt.getInstance('serviceId')?.MasterLabel;
            
            for (Case caseRecord : scope) {
                system.debug('looping case');
                if (String.isBlank(caseRecord.scc_Billing_Number__c)) {
                    continue; // Skip cases without a billing number
                }
                // if (!String.isBlank(caseRecord.SCC_Nomor_Remittence__c)){
                //     system.debug('langsung update case');
                //     // Update case fields
                //     caseRecord.Status = 'Closed';
                //     caseRecord.SCC_Status_Transaksi__c = 'Sukses';
                //     String formattedAmount = caseRecord.SCC_Amount__c != null ? 
                //     caseRecord.SCC_Amount__c.format() : '0';
                //     caseRecord.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                //     caseRecord.SCC_Closure_Comments__c = Label.Closed_Rekon;
                //     caseRecord.SCC_Drone_Remark_Update__c = 'Closed by System';
                //     caseRecord.SCC_Nomor_Remittence__c = caseRecord.SCC_Nomor_Remittence__c;
                    
                //     casesToUpdate.add(caseRecord);
                // }
                if(!String.isBlank(caseRecord.scc_Billing_Number__c)){
                    system.debug('Hit RTGS dulu');
                    // Create payment data request
                    SCC_CaseResolution_FindRTGSWrapper.PaymentDataRequest paymentDataRequest = new SCC_CaseResolution_FindRTGSWrapper.PaymentDataRequest();
                    paymentDataRequest.idTransaction = caseRecord.scc_Billing_Number__c;
        
                    // Update external ID reference number
                    Integer extIdRTGS = Integer.valueOf(br.request_refnum__c);
                    String externalId = SCC_Brimo.setreffnum(extIdRTGS);
                    
                    // Create data request
                    SCC_CaseResolution_FindRTGSWrapper.DataRequest dataRequest = new SCC_CaseResolution_FindRTGSWrapper.DataRequest();
                    dataRequest.kodePembayaran = '01';
                    dataRequest.channelId = channel;
                    dataRequest.serviceId = serviceId;
                    dataRequest.externalId = externalId;
                    dataRequest.paymentData = paymentDataRequest;
                    
                    // Create FindRTGS request
                    SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest request = new SCC_CaseResolution_FindRTGSWrapper.FindRTGSRequest();
                    request.request = dataRequest;
                    
                    system.debug('request RTGS'+request);
                    String menu = 'Case - Bricare';
                    String recordId = String.valueOf(caseRecord.Id);
                    
                    // Make API call
                    SCC_CaseResolution_FindRTGSWrapper.FindRTGSResponse response = 
                        SCC_CaseResolution_FindRTGS.searchRTGS(request, menu, recordId);
                    
                    // Increment the reference number for each request
                    br.request_refnum__c += 1;
                    String amountCreditStr = response.response.data.amountCredit;
                    // Process successful responses
                    system.debug('response RTGS'+response);
                    system.debug('amountCreditStr RTGS'+amountCreditStr);
                    system.debug('amount Case'+caseRecord.SCC_Amount__c);

                    if (response != null && 
                        response.response != null && 
                        response.response.responseCode == '00' && 
                        response.response.data != null &&
                        String.isNotBlank(response.response.data.referenceTransaction) &&
                        String.isNotBlank(amountCreditStr) &&
                        caseRecord.SCC_Amount__c != null) {
                        try {
                            // Konversi ke Decimal dan buang pecahan desimal
                            Decimal amountCredit = Decimal.valueOf(amountCreditStr).setScale(0);
                            Decimal amountFromCase = caseRecord.SCC_Amount__c.setScale(0);
                            system.debug('amountCredit RTGS ='+amountCredit);
                            system.debug('amountFromCase Case ='+amountFromCase);
                            system.debug('case number ='+caseRecord.Case_Number__c);
                            if (amountCredit == amountFromCase) {
                                system.debug('masuk kondisi kedua');
                                // Update case fields
                                caseRecord.Status = 'Closed';
                                caseRecord.SCC_Status_Transaksi__c = 'Berhasil';
                                String formattedAmount = caseRecord.SCC_Amount__c.format();
                                caseRecord.SCC_Resolution_Category__c = 'Tidak Mengirimkan Notifikasi'; 
                                caseRecord.SCC_Closure_Comments__c = Label.Closed_Rekon;
                                caseRecord.SCC_Drone_Remark_Update__c = 'Transaksi sukses dengan nomor remitance : '+response.response.data.referenceTransaction;
                                caseRecord.SCC_Nomor_Remittence__c = response.response.data.referenceTransaction;
                                
                                casesToUpdate.add(caseRecord);
                            }
                        } catch (Exception e) {
                            System.debug('Invalid amountCredit format: ' + amountCreditStr);
                        }
                    }
                }                
            }
            system.debug('casesToUpdate'+casesToUpdate);
            // Update cases in bulk
            if (!casesToUpdate.isEmpty()) {
                system.debug('casesToUpdate'+casesToUpdate);
                update casesToUpdate;
            }
            
            // Update BRIMO custom setting
            system.debug('br'+br);
            update br;
            
        } catch (Exception ex) {
            InsertErrorLog(ex);
        }
    }

    public void finish(Database.BatchableContext bc) {
        if (!Test.isRunningTest()) {
            String cond = '(isclosed = false OR IsClosed__c = false) and SCC_Call_Type__r.external_id__c=\'8412\' and IsLocked__c=false and SCC_Account_Number__c != null and Status = \'Escalated\' and (Approval_Status__c=\'draft\' or Approval_Status__c=\'rejected\') and CreatedDate = LAST_WEEK';
            String addfield = ', SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Database.executeBatch(new SCC_Batch_AutoClosed_EDC(queries), 200);
        }
    }
   
    public static void insertErrorLog(Exception exc){
        ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
        dl.message = exc?.getMessage();
        dl.trace = exc?.getStackTraceString();
        dl.typename = exc?.getTypeName();
        dl.linenumber = string.valueOf(exc?.getLineNumber()); 
        dl.errorcause = string.valueOf(exc?.getCause()); 
        dl.classname = 'SCC_Batch_AutoClosed_RTGS';
        dl.iduser = UserInfo.getUserId();
        ErrorLogRecord.inserterror(JSON.serialize(dl));
    }
}