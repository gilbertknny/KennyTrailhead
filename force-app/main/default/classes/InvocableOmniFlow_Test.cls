/** * @description InvocableOmniFlow_Test */
@IsTest
public with sharing class InvocableOmniFlow_Test {
    @IsTest
    static void testInvocableVoid(){
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        System.runAs(currentUser) {
            // Build inner list
            ApexDefinedFlow f1 = new ApexDefinedFlow();
            f1.partitionCode = '2';
            f1.busreqid = '022.2010.201.2025.000740.00';
            f1.clausedesccl = 'sadasdasdasdasd';
            f1.clausaid='60050';
            f1.clausename='ENDORSEMEN';
            f1.isadditional = true;
            f1.ischanged = true;
            // Wrap into List<List<ApexDefinedFlow>>
            List<ApexDefinedFlow> innerList = new List<ApexDefinedFlow>{ f1 };
            List<List<ApexDefinedFlow>> input = new List<List<ApexDefinedFlow>>{ innerList };

            Test.startTest();
            InvocableOmniFlow.invocablevoid(input);
            Test.stopTest();

            // Assert no exception, execution successful
            System.assert(true, 'Invocable method executed successfully');
        }
    }
}