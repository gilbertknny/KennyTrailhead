public class SCC_EditNotaController {
    @AuraEnabled
    public static SCC_Nota_Manual__c getNotaManual(Id caseId) {
        return [SELECT Id, 
                SCC_Jenis_Transaksi__c, 
                SCC_No_Rekening__c, 
                SCC_No_Telepon__c, 
                SCC_Nama_Nasabah__c, 
                SCC_No_Kartu__c, 
                SCC_Branchcode__c, 
                SCC_Keterangan__c, 
                SCC_Rekening_Titipan__c, 
                SCC_Jumlah_Debit__c, 
                SCC_Rekening_Fee__c, 
                SCC_Jumlah_Fee__c,
                SCC_Jumlah_Kredit__c,
                SCC_Rekening_Nasabah__c,
                Case__c
                FROM SCC_Nota_Manual__c WHERE Case__c = :caseId LIMIT 1];
    }

    @AuraEnabled
    public static SCC_Nota_Manual__c updateNotaManualFromForm(SCC_Nota_Manual__c notaManual) {
        try {
            Decimal jumlahDebit = notaManual.SCC_Jumlah_Debit__c;
            Decimal jumlahKredit = notaManual.SCC_Jumlah_Debit__c;
            Id caseId = notaManual.Case__c;

            System.debug('Jumlah Debit: ' + jumlahDebit);
            System.debug('Jumlah Kredit: ' + jumlahKredit);
            System.debug('Case Id: ' + caseId);
            
            update notaManual;
            System.debug('Nota Manual updated: ' + notaManual);

            List<SCC_Queuetrans__c> queuetransList = [SELECT Id, scc_amt_debet1__c, scc_amt_kredit1__c
                                                      FROM SCC_Queuetrans__c
                                                      WHERE scc_case__c = :caseId];

            System.debug('QueueTrans records found: ' + queuetransList.size());

            for (SCC_Queuetrans__c queuetrans : queuetransList) {
                System.debug('Before update QueueTrans record: ' + queuetrans);
                queuetrans.scc_amt_debet1__c = String.valueOf(jumlahDebit);
                queuetrans.scc_amt_kredit1__c = String.valueOf(jumlahDebit);
                System.debug('After update QueueTrans record: ' + queuetrans);
            }

            if (!queuetransList.isEmpty()) {
                update queuetransList;
                System.debug('QueueTrans records updated: ' + queuetransList);
            }

            return notaManual;
        } catch(Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException('Gagal memperbarui / mengupdate manual nota: ' + e.getMessage());
        }
    }
}