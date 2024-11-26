/**
 * @description CaseRelatedAccountInfoControllerTest
 */
@istest
public class CaseRelatedAccountInfoControllerTest {
    /**
     * @description createGetCase
     */
    @IsTest
    static void createGetCase(){
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
        
        Test.startTest();
        Case caseList = caseRelatedAccountInfoController.getCaseAssociatedAccount(sce.Id);
        System.assertequals(caseList.AccountId,sce.AccountId,'Matched');
        Test.stopTest();
    }    
}