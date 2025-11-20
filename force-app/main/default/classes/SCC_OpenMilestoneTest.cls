@isTest
public class SCC_OpenMilestoneTest {
	@testSetup static void setup(){
        SSC_Call_Type__c callType = new SSC_Call_Type__c(
              Name = 'Test1',
            SCC_Agent_SLA__c = 1,
            SSC_Case_Description__c	 = 'xyz',
            External_Id__c = '8812',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request',
             Active__c = true
        );
        insert callType;
        
        SSC_Call_Type__c callType1 = new SSC_Call_Type__c(
              Name = 'Test2',
            SCC_Agent_SLA__c = 1, 
            SSC_Case_Description__c	 = 'xyz',
            External_Id__c = '1009',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request',
            Active__c = true
        );
        insert callType1;
        
        Case testCase = new Case(
            Priority = 'High',
             SCC_Assigned_Date__c = Date.today().addDays(-1),
            SCC_Case_Type_assigned_time__c = Datetime.now().addMinutes(-30),
                         SCC_Next_Escalation_Level__c = 'SCC_Level1_Escalation_team__c', 
            SCC_Case_Category__c = 'Request',
            SCC_Product_L1__c ='Loans',
            SCC_Product_L2__c='KTA - Digital',
            SCC_Segment__c = 'Individu Umum',
            Description='xyz',
            SCC_Call_Type__c=callType.Id
        );
        insert testCase;
    }
    
    static testMethod void testProcess(){
        SSC_Call_Type__c ct = [SELECT Id FROM SSC_Call_Type__c WHERE External_Id__c = '1009' LIMIT 1];
        Case cs = [SELECT Id FROM Case LIMIT 1];
        cs.SCC_Call_Type__c = ct.Id;
        update cs;
    }
}