/** @description
 * SCC_CardlinkByPhoneWrapper is a wrapper class for handling customer data retrieved by phone number.
 * It includes multiple inner classes representing various aspects of customer data, such as additional data,
 * response details, cardholder data, and customer data.
 * 
 * The class provides a method to parse JSON strings into SCC_CardlinkByPhoneWrapper objects.
 */
public class SCC_CardlinkByPhoneWrapper {
/** @description status */
    @AuraEnabled
    public String status { get; set; }
   /** @description productType */
    @AuraEnabled
    public String productType { get; set; }
  /** @description productDescription */
    @AuraEnabled
    public String productDescription { get; set; }
   /** @description product */
    @AuraEnabled
    public String product { get; set; }
   /** @description cifno */
    @AuraEnabled
    public String cifno { get; set; }
    /** @description cardNumber */
    @AuraEnabled
    public String cardNumber { get; set; }
    /** @description namaBelakang */
    @AuraEnabled
    public String namaBelakang { get; set; }
    /** @description namaTengah */
    @AuraEnabled
    public String namaTengah { get; set; }
   /** @description namaDepan */
    @AuraEnabled
    public String namaDepan { get; set; }
    /**
     *  @description Constructs an instance of SCC_CardlinkByPhoneWrapper with the specified parameters.
     * 
     * @param status The status of the customer data.
     * @param productType The type of product associated with the customer.
     * @param productDescription The description of the product associated with the customer.
     * @param product Specific product information.
     * @param cifno The CIF number of the customer.
     * @param cardNumber The card number of the customer.
     * @param namaBelakang The last name of the customer.
     * @param namaTengah The middle name of the customer.
     * @param namaDepan The first name of the customer.
     */
    public SCC_CardlinkByPhoneWrapper(String status, String productType, String productDescription,
                                      String product, String cifno, String cardNumber,String namaBelakang,String namaTengah,
                                     String namaDepan) {
        this.status = status;
        this.productType = productType;
        this.productDescription = productDescription;
        this.product = product;
        this.cifno = cifno;
        this.cardNumber = cardNumber;
        this.namaBelakang = namaBelakang;
        this.namaTengah = namaTengah;
        this.namaDepan = namaDepan;
       
                                         
                                         
    }
        
}