@IsTest
private class Aswata_Lead_Convert_Test {

    @IsTest
    static void testLeadConvert_Success() {
       
        // 🔹 Create a Lead using factory
        Lead lead = Aswata_TestDataFactory.createLead('John', 'Doe', 'Aswata Company');

        // 🔹 Prepare wrapper input for the invocable method
        Aswata_Lead_Convert.LeadIdWrapper wrapper = new Aswata_Lead_Convert.LeadIdWrapper();
        wrapper.leadId = lead.Id;

        List<Aswata_Lead_Convert.LeadIdWrapper> wrappers = new List<Aswata_Lead_Convert.LeadIdWrapper>{ wrapper };

        // 🔹 Execute conversion inside test context
        Test.startTest();
        List<Aswata_Lead_Convert.LeadConvertResultWrapper> results =
            Aswata_Lead_Convert.convertLeads(wrappers);
        Test.stopTest();

        // 🔹 Verify results
        System.assertEquals(1, results.size(), 'There should be one result');
        System.assertEquals(true, results[0].success, 'Lead conversion should succeed');
        System.assertNotEquals(null, results[0].convertedAccountId, 'Account should be created');
        System.assertNotEquals(null, results[0].convertedContactId, 'Contact should be created');

        // 🔹 Validate created records
        Account acc = [SELECT Id, Name, RecordTypeId, Phone, Email__c FROM Account WHERE Id = :results[0].convertedAccountId];
        Contact con = [SELECT Id, FirstName, LastName, Email, AccountId FROM Contact WHERE Id = :results[0].convertedContactId];

        System.assertEquals(lead.Email, acc.Email__c, 'Account email should match Lead email');
        System.assertEquals(acc.Id, con.AccountId, 'Contact should be linked to Account');
    }

    @IsTest
    static void testLeadConvert_NoRecordTypeFound() {
        // 🔹 Create lead without inserting record types
        Lead lead = Aswata_TestDataFactory.createLead('Jane', 'Smith', 'Test Company');

        Aswata_Lead_Convert.LeadIdWrapper wrapper = new Aswata_Lead_Convert.LeadIdWrapper();
        wrapper.leadId = lead.Id;

        Test.startTest();
        List<Aswata_Lead_Convert.LeadConvertResultWrapper> results =
            Aswata_Lead_Convert.convertLeads(new List<Aswata_Lead_Convert.LeadIdWrapper>{ wrapper });
        Test.stopTest();

        // 🔹 Validate conversion still runs but no Account record type set
        System.assertEquals(1, results.size(), 'Should still return one result');
        System.assertEquals(true, results[0].success, 'Conversion should succeed even without RecordType');
    }

    @IsTest
    static void testLeadConvert_MultipleLeads() {
        // 🔹 Create multiple Leads
        Lead lead1 = Aswata_TestDataFactory.createLead('Alice', 'Johnson', 'Company A');
        Lead lead2 = Aswata_TestDataFactory.createLead('Bob', 'Lee', 'Company B');

        lead1.Phone = '+62813121211';
        update lead1;
        lead2.Phone = '62812312311';
        update lead2;
        // 🔹 Properly instantiate wrapper objects (no name=value syntax)
        List<Aswata_Lead_Convert.LeadIdWrapper> wrappers = new List<Aswata_Lead_Convert.LeadIdWrapper>();

        Aswata_Lead_Convert.LeadIdWrapper wrap1 = new Aswata_Lead_Convert.LeadIdWrapper();
        wrap1.LeadId = lead1.Id;

        Aswata_Lead_Convert.LeadIdWrapper wrap2 = new Aswata_Lead_Convert.LeadIdWrapper();
        wrap2.LeadId = lead2.Id;

        wrappers.add(wrap1);
        wrappers.add(wrap2);

        // 🔹 Execute conversion
        Test.startTest();
        List<Aswata_Lead_Convert.LeadConvertResultWrapper> results =
            Aswata_Lead_Convert.convertLeads(wrappers);
        Test.stopTest();

        // 🔹 Validate both conversions succeeded
        System.assertEquals(2, results.size(), 'Two results expected');
        for (Aswata_Lead_Convert.LeadConvertResultWrapper r : results) {
            System.assert(r.success, 'Lead should be converted successfully');
        }
    }
}