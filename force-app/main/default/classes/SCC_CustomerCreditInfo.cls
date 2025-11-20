public class SCC_CustomerCreditInfo{
    String customerType;
    String verif_Customer_Name  ;
    String verif_Mother_Name ;
    String verif_Phone_BRINets ;
    String verif_Phone_WBS ;
    String verif_NIK  ;
    String verif_NPWP ;
    Date   verif_Expired_Date ;      
    String verif_Home_Address  ;
    String verif_Email  ;
    String verif_Urgent_Contact ;
    String verif_Credit_Card_Limit  ;

    String verif_PIC_Name  ;
    String verif_PIC_Phone ;
    String verif_Office_Address ;
    String verif_Office_Phone ;
    
    public SCC_CustomerCreditInfo(){}

    public SCC_CustomerCreditInfo(String customerType, String verif_PIC_Name  ,
    String verif_PIC_Phone ,
    String verif_Office_Address ,
    String verif_Office_Phone ,
    Date verif_Expired_Date ){
        this.customerType=customerType;
        this.verif_PIC_Name=verif_PIC_Name;
        this.verif_PIC_Phone=verif_PIC_Phone;
        this.verif_Office_Phone=verif_Office_Phone;
        this.verif_Expired_Date=verif_Expired_Date;
    
    }
    public SCC_CustomerCreditInfo(String customerType,
        String verif_Customer_Name  ,
        String verif_Mother_Name ,
        String verif_Phone_BRINets ,
        String verif_Phone_WBS ,
        String verif_NIK  ,
        String verif_NPWP ,
        Date   verif_Expired_Date ,      
        String verif_Home_Address  ,
        String verif_Email  ,
        String verif_Urgent_Contact ,
        String verif_Credit_Card_Limit  )
        {
            this.customerType= customerType;
            this.verif_Customer_Name  =verif_Customer_Name  ;
            this.verif_Mother_Name = verif_Mother_Name ;
            this.verif_Phone_BRINets = verif_Phone_BRINets ;
            this.verif_Phone_WBS = verif_Phone_WBS ;
            this.verif_NIK  =verif_NIK  ;
            this.verif_NPWP =verif_NPWP ;
            this.verif_Expired_Date =verif_Expired_Date ;      
            this.verif_Home_Address  =verif_Home_Address  ;
            this.verif_Email  =verif_Email  ;
            this.verif_Urgent_Contact =verif_Urgent_Contact ;
            this.verif_Credit_Card_Limit =verif_Credit_Card_Limit  ;
        }


}