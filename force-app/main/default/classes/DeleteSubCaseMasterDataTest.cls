@isTest
public with sharing class DeleteSubCaseMasterDataTest {
    @isTest
    public static void testdelete()
    {
        SSC_Call_Type__c callTypeRecord = new SSC_Call_Type__c(
            Name = 'Test Call Type',
            SCC_Sub_Description__c = 'SCR1',
             SCC_Level1_OLA__c = 1,
            SSC_Case_Description__c	 = 'xyz',
            External_Id__c = '8812',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request'//
        );
        insert callTypeRecord;

        SSC_Call_Type__c callTypeRecord2 = new SSC_Call_Type__c(
            Name = 'Test Call Type 2',
            SCC_Sub_Description__c = 'SCR1;SCR2',
             SCC_Level1_OLA__c = 1,
            SSC_Case_Description__c	 = 'xyz',
            External_Id__c = '88126',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request'//
        );
        insert callTypeRecord2;
    Sub_Case_Reference__c SCR=new Sub_Case_Reference__c();
    SCR.name='Nama';
    SCR.sub_case_code__c='SCR1';
    insert SCR;
    delete SCR;
    }
}