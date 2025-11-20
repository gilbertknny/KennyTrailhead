public class SCC_MachineDataWrapper {
	@AuraEnabled 
    public String tid;
    @AuraEnabled 
    public String alamatMesin;
    @AuraEnabled 
    public String kontakId;
    
    public SCC_MachineDataWrapper(String tid, String alamatMesin, String kontakId) {
            this.tid = tid;
            this.alamatMesin = alamatMesin;
            this.kontakId = kontakId;
    }
}