public without sharing class SCC_SavingStateWrapper {
    @AuraEnabled
    public Long noRek { get; set; }
    @AuraEnabled
    public String tglTran { get; set; }
    @AuraEnabled
    public String jamTran { get; set; }
    @AuraEnabled
    public String remarkCustom { get; set; }
    @AuraEnabled
    public String glsign { get; set; }
    @AuraEnabled
    public Integer mutasiDebet { get; set; }
    @AuraEnabled
    public Integer mutasiKredit { get; set; }
    @AuraEnabled
    public Double saldoAkhirMutasi { get; set; }
    @AuraEnabled
    public String truser { get; set; }
    @AuraEnabled
    public String ukerTransaksi { get; set; }
    @AuraEnabled
    public String tid { get; set; }
    @AuraEnabled
    public String channel { get; set; }
    
    public SCC_SavingStateWrapper(Long noRek, String tglTran, String jamTran, String remarkCustom, String glsign,
                                  Integer mutasiDebet, Integer mutasiKredit, Double saldoAkhirMutasi, String truser,
                                 String ukerTransaksi, String tid, String channel) {
        this.noRek = noRek;
        this.tglTran = tglTran;
        this.jamTran = jamTran;
        this.remarkCustom = remarkCustom;
        this.glsign = glsign;
        this.mutasiDebet = mutasiDebet;
        this.mutasiKredit = mutasiKredit;
        this.saldoAkhirMutasi = saldoAkhirMutasi;
		this.truser = truser;
        this.ukerTransaksi = ukerTransaksi;
        this.tid = tid;
        this.channel = channel;                             
    }
}