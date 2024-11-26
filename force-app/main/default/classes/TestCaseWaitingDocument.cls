@istest
public class TestCaseWaitingDocument {
    /**
     * @description createGetCase
     */
    @IsTest
    static void testCaseWaitingDocument(){
        Account acc = new Account();
        acc.Name='Test account';
        insert acc;
        
        Case sce = new Case();
        sce.Subject='test Case';
        sce.Origin='Phone';
        sce.SCC_Email__c='TestEmail@gmail.com';
        sce.Status='New';
        sce.Priority='Low';
        sce.AccountId=acc.Id;
        insert sce;
        
        Case_Waiting_Document__c CWS=new Case_Waiting_Document__c();
        CWS.startdate__c=system.today();
        CWS.startdatetime__c=system.now();
        CWS.case__c =sce.id;
        insert CWS;
        CWS.enddate__c=system.today().adddays(1);
        CWS.enddatetime__c=system.now().adddays(1);
        update CWS;
        }
        
 }