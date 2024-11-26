public class SCC_InquiryStatusWrapper {
	@AuraEnabled 
    public String saldoAkhirMutasi;
    @AuraEnabled 
    public String holdType;
    @AuraEnabled 
    public String holdAmt;
    @AuraEnabled 
    public String holdRemark;
    @AuraEnabled 
    public String holdDate;
    
    public SCC_InquiryStatusWrapper(String saldoAkhirMutasi, String holdType, String holdAmt, String holdRemark,String holdDate) {
            this.saldoAkhirMutasi = saldoAkhirMutasi;
            this.holdType = holdType;
            this.holdAmt = holdAmt;
        	this.holdRemark = holdRemark;
            this.holdDate = holdDate;
    }
}