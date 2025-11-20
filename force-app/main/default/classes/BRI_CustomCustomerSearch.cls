/**
 * Class : BRI_CustomCustomerSearch
 * description : This class contains method to search Customers .
 * 				 Referenced under LWC - 'cfCustomerSearch'
 * 
 **/
public inherited sharing class BRI_CustomCustomerSearch {
    
    @AuraEnabled(Cacheable = true)
    public static list<Account> retriveAccounts(String strMobileNumber, String strNIK) {
        String searchString = '';
        if(!String.isEmpty(strMobileNumber)){
            searchString = ' PersonMobilePhone =: strMobileNumber ';
        }
        if(!String.isEmpty(strNIK)){
            if(String.isEmpty(searchString)){
            	searchString = ' SCC_NIK__c =: strNIK ';
            }
            else{
                searchString += ' AND SCC_NIK__c =: strNIK ';
            }
        }
        system.debug('strAccNumber -' + searchString);
        String query = 'SELECT Id,Name, PersonMobilePhone, SCC_NIK__c FROM Account WHERE ' + searchString;
        system.debug(query);
		list<Account> lstAccs = Database.Query(query);
        /*list<Account> lstAccs = [SELECT  Id, Name, PersonMobilePhone, SCC_NIK__c 
                                 FROM Account 
                                 WHERE Name 
                                 LIKE :strAccNumber];*/
        system.debug('lstAccs -' + lstAccs);
        if(lstAccs.isEmpty()) {
            system.debug('come into aura error');
            throw new AuraHandledException('Tidak Ada Catatan / Record yang Ditemukan..'); //No Record Found..
            
        }
        return lstAccs; 
    }
}