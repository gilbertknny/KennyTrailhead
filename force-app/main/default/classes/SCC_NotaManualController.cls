public class SCC_NotaManualController {
    @AuraEnabled
    public static SCC_Nota_Manual__c createNotaManualFromForm(SCC_Nota_Manual__c notaManual, Case cs) {
        try {
            // Check if required fields are null
            System.debug('list notaManual = '+notaManual);
            if (notaManual == null) {
                AuraHandledException ae = new AuraHandledException('Nota Manual is null');
                ae.setMessage('Nota Manual is null');
                throw ae;
            }
            if (cs == null) {
                AuraHandledException ae = new AuraHandledException('Case details are null');
                ae.setMessage('Case details are null');
                throw ae;
            }
            
            // Prepare queue transaction list
            List<SCC_Queuetrans__c> listque = new List<SCC_Queuetrans__c>();
            List<SCC_Queuetrans__c> listdelque = [SELECT Id FROM SCC_Queuetrans__c WHERE scc_case__c = :cs.Id];
            
            SCC_Queuetrans__c que = new SCC_Queuetrans__c();
            System.debug('list delete queue = '+listdelque);
            // Handle potential null references
            que.scc_no_tt__c = cs.CaseNumber != null ? cs.CaseNumber : '';
            que.scc_fitur_id__c = cs.SCC_Call_Type_Feature__r != null ? cs.SCC_Call_Type_Feature__r.Fitur_ID__c : '';
            que.scc_acct_kredit1__c = notaManual.SCC_No_Rekening__c != null ? notaManual.SCC_No_Rekening__c : '';
            que.scc_amt_debet1__c = notaManual.SCC_Jumlah_Debit__c != null ? String.valueOf(notaManual.SCC_Jumlah_Debit__c) : '0';
            que.scc_amt_kredit1__c = notaManual.SCC_Jumlah_Debit__c != null ? String.valueOf(notaManual.SCC_Jumlah_Debit__c) : '0';
            que.scc_calltype__c = notaManual.SCC_Jenis_Transaksi__c != null ? notaManual.SCC_Jenis_Transaksi__c : '';
            que.scc_case__c = notaManual.Case__c;



            listque.add(que);
            System.debug('list insert queue = '+listque);
            // Insert notaManual and handle potential null references
            insert notaManual;

            // Update Case Maker__c field
            Case updatedCase = new Case(Id = cs.Id, Maker__c = UserInfo.getUserId());
            update updatedCase;

            if (!listdelque.isEmpty()) {
                delete listdelque;
            }
            if (!listque.isEmpty()) {
                insert listque;
            }

            return notaManual;
        } catch(Exception e) {
            String message = e.getMessage();
            System.debug('message error nota :' + message);
            if (message.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')){
                message = message.substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION, ');
                message = message.substringBefore(': ');
                message = message.replaceAll('&amp;', '&');
            }
            
            AuraHandledException ae = new AuraHandledException('Harap isi TID & Fitur ID sebelum membuat nota');
            ae.setMessage('Gagal membuat manual nota: ' + message);
            throw ae;
        }
    }

    @AuraEnabled
    public static Case getCaseDetails(Id caseId) {
        try {
            // Fetch and return case details
            return [SELECT Id, SCC_Call_Type__c, SCC_Call_Type__r.Name, SCC_Call_Type__r.External_Id__c, SCC_Account_Number__c, SCC_Card_Number__c, 
                           Account.Phone, Account.SCC_Nama_Nasabah__c, Account.Name, SCC_Amount__c, 
                           Terminal_ID__c, Terminal_ID__r.SCC_Branch_Code__c, Terminal_ID__r.SCC_Account_Number__c, SCC_Call_Type_Feature__r.Fitur_ID__c, Cust_Current_Phone__c
                    FROM Case WHERE Id = :caseId LIMIT 1];
        } catch(Exception e) {
            throw new AuraHandledException('Failed to retrieve case details: ' + e.getMessage());
        }
    }
}