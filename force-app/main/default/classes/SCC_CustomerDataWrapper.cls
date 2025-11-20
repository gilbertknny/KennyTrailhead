public without sharing class SCC_CustomerDataWrapper {
    @AuraEnabled
    public String accountNumber { get; set; }
    @AuraEnabled
    public String cifno { get; set; }
    @AuraEnabled
    public String product { get; set; }
    @AuraEnabled
    public String productType { get; set; }
    @AuraEnabled
    public String status { get; set; }
    @AuraEnabled
    public String openAccountDate { get; set; }
    
    public SCC_CustomerDataWrapper(String accountNumber, String cifno, String product, String productType, String status, String openAccountDate) {
        this.accountNumber = accountNumber;
        this.cifno = cifno;
        this.product = product;
        this.productType = productType;
        this.status = status;
        this.openAccountDate = openAccountDate;
    }
}