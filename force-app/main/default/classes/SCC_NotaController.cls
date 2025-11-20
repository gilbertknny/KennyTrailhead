public with sharing class SCC_NotaController {
    public Id caseId { get; set; }
    public SCC_Nota_Manual__c nota { get; set; }

    // Properti untuk data
    public String JENISTRX { get; set; }
    public String NOTT { get; set; }
    public String KETERANGAN1 { get; set; }
    public String KETERANGAN2 { get; set; }
    public String KETERANGAN3 { get; set; }
    public String UNIT_KERJA { get; set; }
    public String NOREK { get; set; }
    public String NO_TELP { get; set; }
    public String NAMA_NASABAH { get; set; }
    public String NOMOR_KARTU { get; set; }
    public String NOMINAL { get; set; }
    public String BRANCH_CODE { get; set; }
    public String TID { get; set; }
    public Decimal TOTAL { get; set; }
    public Decimal AMOUNTKREDIT { get; set; }
    public Decimal AMOUNTDEBIT { get; set; }
    public String REKTITIPAN { get; set; }
    public String REKFEE { get; set; }
    public String CreatedDate { get; set; }
    public String DateChecker { get; set; }
    public String DateSigner { get; set; }
    public String Maker { get; set; }
    public String Checker { get; set; }
    public String Signer { get; set; }
    public Boolean is8713 {get; set;}

    public SCC_NotaController(ApexPages.StandardController controller) {
        caseId = ApexPages.CurrentPage().getParameters().get('id');
        if (caseId != null) {
            try {
                nota = [SELECT Id, Case__c, Case__r.CaseNumber, Case__r.SCC_Terminal_ID__c, Case__r.SCC_Transaction_Date__c, 
                               Case__r.CreatedDate, Case__r.Description, Case__r.Approved_Date_Checker__c, 
                               Case__r.Approved_Date_Signer__c, Case__r.Maker__c, Case__r.Checker__c, Case__r.Signer__c, 
                               Case__r.Unit_Kerja__c, SCC_Nama_Nasabah__c, SCC_Branchcode__c, SCC_No_Rekening__c, 
                               SCC_No_Kartu__c, SCC_Keterangan__c, SCC_Rekening_Titipan__c, SCC_Rekening_Fee__c, 
                               SCC_Jumlah_Kredit__c, SCC_Jumlah_Debit__c, SCC_Total__c, SCC_No_Telepon__c, 
                               SCC_Jenis_Transaksi__c, Case__r.Signer__r.Name, Case__r.Checker__r.Name, Case__r.Maker__r.Name, 
                        	   Case__r.SSC_Call_Type_Description__c, Case__r.Cust_Current_Phone__c
                        FROM SCC_Nota_Manual__c
                        WHERE Case__c = :caseId
                        LIMIT 1];

                if (nota != null) {
                    NOTT = nota.Case__r.CaseNumber;
                    DateChecker = nota.Case__r.Approved_Date_Checker__c != null ? 
                                  DateTime.newInstance(nota.Case__r.Approved_Date_Checker__c.year(), nota.Case__r.Approved_Date_Checker__c.month(), nota.Case__r.Approved_Date_Checker__c.day()).format('dd-MM-yyyy') : '';
                    DateSigner = nota.Case__r.Approved_Date_Signer__c != null ? 
                                 DateTime.newInstance(nota.Case__r.Approved_Date_Signer__c.year(), nota.Case__r.Approved_Date_Signer__c.month(), nota.Case__r.Approved_Date_Signer__c.day()).format('dd-MM-yyyy') : '';
                    BRANCH_CODE = nota.SCC_Branchcode__c;
                    NAMA_NASABAH = nota.SCC_Nama_Nasabah__c;
                    NO_TELP = nota.Case__r.Cust_Current_Phone__c;
                    JENISTRX = nota.SCC_Jenis_Transaksi__c;
                    NOREK = nota.SCC_No_Rekening__c;
                    NOMOR_KARTU = nota.SCC_No_Kartu__c;
                    TID = nota.Case__r.SCC_Terminal_ID__c;
                    KETERANGAN1 = nota.Case__r.Description; 
                    KETERANGAN2 = nota.SCC_Keterangan__c; 
                    KETERANGAN3 = nota.Case__r.SSC_Call_Type_Description__c; 
                    Maker = nota.Case__r.Maker__r.Name;
                    Checker = nota.Case__r.Checker__r.Name;
                    Signer = nota.Case__r.Signer__r.Name;
                    REKTITIPAN = nota.SCC_Rekening_Titipan__c;
                    
                    AMOUNTKREDIT = nota.SCC_Jumlah_Kredit__c;
                    AMOUNTDEBIT = nota.SCC_Jumlah_Debit__c;
                    TOTAL = nota.SCC_Total__c;
                    UNIT_KERJA = nota.Case__r.Unit_Kerja__c;
                    CreatedDate = nota.Case__r.CreatedDate.format('dd-MM-yyyy');
                    
                    if(nota.SCC_Jenis_Transaksi__c == '8713'){
                        REKFEE = '-' ;
                    }else {
                        REKFEE = nota.SCC_Rekening_Fee__c;
                    }


                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Nota not found.'));
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: ' + e.getMessage()));
                System.debug(e.getMessage());
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Case ID is missing.'));
        }
    }
}