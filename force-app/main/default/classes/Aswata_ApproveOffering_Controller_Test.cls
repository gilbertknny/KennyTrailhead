@isTest(seeAllData=false)
public with sharing class Aswata_ApproveOffering_Controller_Test {
    @TestSetup
    static void setupData() {

        // Create base dataset
        Map<String, SObject> data =
            Aswata_TestDataFactory.createStandardDataSet();

        Account acc = (Account) data.get('Account');
        Opportunity opp = (Opportunity) data.get('Opportunity');
        opp.Offering_Status__c = 'Offering';
        update opp;

        Quote quote = Aswata_TestDataFactory.createQuote(opp, 'Test Quote');
        Facultative_Share__c share1 =
            Aswata_TestDataFactory.createOfferingShare('Share 1');
        share1.Facultative_Opportunity__c = opp.Id;
        update share1;

    }

      // -------------------------------------------
    // Test getShares method
    // -------------------------------------------
    @IsTest
    static void testGetShares() {
        // Get the quote created in setup
        Quote quote = [SELECT Id, OpportunityId FROM Quote LIMIT 1];

        Test.startTest();
        List<Facultative_Share__c> shares = 
            Aswata_ApproveOffering_Controller.getShares(quote.Id);
        Test.stopTest();

        System.assertNotEquals(null, shares, 'Shares list should not be null');
        System.assert(shares.size() > 0, 'There should be at least 1 share returned');
    }

    // -------------------------------------------
    // Test approveOffering method
    // -------------------------------------------
    @IsTest
    static void testApproveOffering() {
        // Get the quote and share from setup
        Quote quote = [SELECT Id, OpportunityId, Status FROM Quote LIMIT 1];
        Facultative_Share__c share = [SELECT Id, Share_Accepted_Approved__c, Rate__c, Commission__c, Subjectivity_Clauses__c
                                      FROM Facultative_Share__c LIMIT 1];

        // Prepare payload like LWC would send
        List<Map<String, Object>> draftShares = new List<Map<String, Object>>();
        draftShares.add(new Map<String, Object>{
            'Id' => share.Id,
            'Share_Accepted_Approved__c' => 10,
            'Rate__c' => 5,
            'Commission__c' => 2,
            'Subjectivity_Clauses__c' => 'Test clause'
        });

        Test.startTest();
        Aswata_ApproveOffering_Controller.approveOffering(quote.Id, draftShares);
        Test.stopTest();

        // Reload records from DB
        Facultative_Share__c updatedShare = [SELECT Share_Accepted_Approved__c, Rate__c, Commission__c, Subjectivity_Clauses__c
                                             FROM Facultative_Share__c
                                             WHERE Id = :share.Id];
        Quote updatedQuote = [SELECT Status, OpportunityId FROM Quote WHERE Id = :quote.Id];
        Opportunity updatedOpp = [SELECT Offering_Status__c FROM Opportunity WHERE Id = :quote.OpportunityId];

        // Validate shares updated
        System.assertEquals(10, updatedShare.Share_Accepted_Approved__c, 'Share Accepted should be updated');
        System.assertEquals(5, updatedShare.Rate__c, 'Rate should be updated');
        System.assertEquals(2, updatedShare.Commission__c, 'Commission should be updated');
        System.assertEquals('Test clause', updatedShare.Subjectivity_Clauses__c, 'Subjectivity clause should be updated');

        // Validate Quote + Opportunity updated
        System.assertEquals('Approved', updatedQuote.Status, 'Quote status should be Approved');
        System.assertEquals('Accepted', updatedOpp.Offering_Status__c, 'Opportunity Offering Status should be Accepted');
    }
}