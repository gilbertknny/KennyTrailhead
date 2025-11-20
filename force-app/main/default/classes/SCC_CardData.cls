/**
 * @description SCC_CardData class for returning required response values
 */
public class SCC_CardData {
  @AuraEnabled 
    public String cardStatus;
    @AuraEnabled 
    public String cardNo;
    @AuraEnabled 
    public String type;
    @AuraEnabled 
    public String lastMaint;
    @AuraEnabled 
    public String expDate;
    @AuraEnabled 
    public String activeDate;
    @AuraEnabled
    public String statusDesc;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String userMaint;
    @AuraEnabled
    public String branchCode;
    @AuraEnabled
    public String issueDate;
    @AuraEnabled
    public String typeCode;
    @AuraEnabled
    public String renewalDate;
    @AuraEnabled
    public String blockDate;
    @AuraEnabled
    public String userBlock;
    @AuraEnabled
    public String accNo;
    @AuraEnabled
    public String activeDateCard;
    @AuraEnabled
    public String cardNoHis;
    @AuraEnabled
    public String cardStatusHis;
    @AuraEnabled
    public String lastMaintHis;
    @AuraEnabled
    public String issueDateCard;
    @AuraEnabled
    public String expDateCard;
    
        /**
         * @description Constructor for current card data.
         * @param cardNo Card number
         * @param type Card type
         * @param name Card name
         * @param cardStatus Card status
         * @param statusDesc Card status description
         * @param lastMaint Card last maintenance
         * @param userMaint User maintenance
         * @param activeDateCard Card active date
         * @param issueDateCard Card issue date
         * @param expDateCard Card expiry date
         * @param blockDate Card block date
         */
        public SCC_CardData(String cardNo, String type, String name, String cardStatus, String statusDesc, String lastMaint,
                            String userMaint, String activeDateCard, String issueDateCard, String expDateCard, String blockDate) {
            this.cardStatus = cardStatus;
            this.cardNo = cardNo;
            this.type = type;
            this.lastMaint = lastMaint;
            this.expDateCard = expDateCard;
            this.activeDateCard = activeDateCard;
            this.statusDesc = statusDesc;
            this.name = name;
            this.userMaint = userMaint;
            this.issueDateCard = issueDateCard;
            this.blockDate = blockDate;
        }
    
        /**
         * @description Constructor for card history data.
         * @param cardStatusHis Card status of the card history
         * @param cardNoHis Card number of the card history
         * @param lastMaintHis Last maintenance of the card history
         * @param expDate Expiry date of the card
         * @param activeDate Active date of the card
         * @param branchCode Branch code of the card
         * @param issueDate Issue date of the card
         * @param typeCode Type code of the card
         * @param renewalDate Renewal date of the card
         * @param blockDate Block date of the card
         * @param userBlock User block of the card
         * @param accNo Account number of the card
         */
    	public SCC_CardData(String cardStatusHis, String cardNoHis, String lastMaintHis,String expDate,
                            String activeDate, String branchCode, String issueDate, String typeCode, 
                            String renewalDate, String blockDate, String userBlock, String accNo) {
            this.cardStatusHis = cardStatusHis;
            this.cardNoHis = cardNoHis;
            this.lastMaintHis = lastMaintHis;
            this.expDate = expDate;
            this.activeDate = activeDate;
            this.branchCode = branchCode;
            this.issueDate = issueDate;
            this.typeCode = typeCode;
            this.renewalDate = renewalDate;
            this.blockDate = blockDate;
            this.userBlock = userBlock;
            this.accNo = accNo;
        }
}