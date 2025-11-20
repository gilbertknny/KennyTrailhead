/**
* @description Test class for SBX_BatchMaskSandboxData.
*/
@isTest
public class SBX_BatchMaskSandboxDataTest {
    @TestSetup
    static void setup()
    {
        //Setting up test data
        
        //Step 2: create sample Account
        Account accnt = New Account();
        accnt.Name = 'TestCreativeAccount';
         accnt.Description = 'Test Desc';
        insert accnt; 
        //Step 3: create sample Contacts
        List<Contact> testContacts = new List<Contact>();
        Contact c1 = New Contact();
        c1.FirstName = 'TestFirst1';
        c1.LastName = 'TestLast1';
        c1.Email = 'testcontact1@test.com';
        c1.AccountId = accnt.Id;
        c1.MobilePhone = '1234561001';
        c1.HomePhone = '1234561001';
        c1.Birthdate = Date.newInstance(1920,1,1);
        testContacts.add(c1);
        Contact c2 = New Contact();
        c2.FirstName = 'TestFirst2';
        c2.LastName = 'TestLast2';
        c2.Email = 'testcontact2@test.com';
        c2.AccountId = accnt.Id;
        c2.MobilePhone = '1234561002';
        c2.Birthdate = Date.newInstance(1920,2,2);
        testContacts.add(c2);
        insert testContacts;
    }
    
    static testMethod void testSBX_BatchMaskSandboxData(){
        Test.startTest();
        SBX_BatchMaskSandboxData batchEdit = new SBX_BatchMaskSandboxData();
        DataBase.executeBatch(batchEdit);
        Test.stopTest();
    }    
}