public with sharing class ContactController { 
    public static String test(){
        return 'test';
    }
    
   /*
    @AuraEnabled(cacheable=true)
    public static List<Contact> getContacts() {
        return [SELECT Id, FirstName, LastName, Email FROM Contact ORDER BY CreatedDate DESC LIMIT 10];
        //throw new AuraHandledException('Forced error');
    }
     */
}