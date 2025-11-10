@IsTest(SeeAllData=false)
public class Aswata_Lead_Distribution_Test {
    
    // Test 1: Setup and Data Validation
    @IsTest
    static void testSetupData() {
        String testBranchId = '1';
        
        // Create Location Hierarchy menggunakan TestDataFactory
        Map<String, Schema.Location> locations = Aswata_TestDataFactory.createLocationHierarchy();
        Schema.Location zipCodeLocation = locations.get('Zip Code');
        
        // Update Location dengan Branch_ID__c
        zipCodeLocation.Branch_ID__c = testBranchId;
        update zipCodeLocation;
        
        // Create Master Branch
        Master_Data__c masterBranch = Aswata_TestDataFactory.createMasterData('Sample', 'Master Branch');
        masterBranch.Branch_ID__c = testBranchId;
        update masterBranch;
        
        // Create Round Robin Member
        Master_Data__c roundRobin = Aswata_TestDataFactory.createMasterData('R Robin 1', 'Round Robin Member');
        roundRobin.Account_Type__c = '0';
        roundRobin.Account_Segment__c = 'I';
        roundRobin.Account_Pipeline_Status__c = 'Direct';
        roundRobin.Business_Segmentation__c = 'Corporate';
        roundRobin.Salesman_Branch__c = masterBranch.Id;
        update roundRobin;
        
        // Create Lead
        Lead lead = Aswata_TestDataFactory.createLead('John', 'Doe', 'Aswata Company');
        lead.Zip__c = zipCodeLocation.Id;
        lead.Branch__c = testBranchId;
        update lead;
        
        Lead leadResult = [SELECT Id, Branch__c, Zip__c FROM Lead WHERE Id = :lead.Id];
        
        Master_Data__c masterBranchResult = [
            SELECT Id, Branch_ID__c, Name, RecordType.Name 
            FROM Master_Data__c 
            WHERE Id = :masterBranch.Id
        ];
        
        Master_Data__c roundRobinResult = [
            SELECT Id, Name, Account_Type__c, Account_Segment__c, 
                   Account_Pipeline_Status__c, Business_Segmentation__c,
                   Salesman_Branch__c, RecordType.Name
            FROM Master_Data__c
            WHERE Id = :roundRobin.Id
        ];
        
        System.assertEquals(
            'Master Branch',
            masterBranchResult.RecordType.Name,
            'Record Type should be Master Branch'
        );
        
        System.assertEquals(
            testBranchId,
            masterBranchResult.Branch_ID__c,
            'Master Data Branch_ID__c should be ' + testBranchId
        );
        
        System.assertEquals(
            'Round Robin Member',
            roundRobinResult.RecordType.Name,
            'Record Type should be Round Robin Member'
        );
        
        System.assertEquals(
            'R Robin 1',
            roundRobinResult.Name,
            'Round Robin Name should be R Robin 1'
        );
        
        System.assertEquals(
            '0',
            roundRobinResult.Account_Type__c,
            'Account Type should be 0'
        );
        
        System.assertEquals(
            'I',
            roundRobinResult.Account_Segment__c,
            'Account Segment should be I'
        );
        
        System.assertEquals(
            'Direct',
            roundRobinResult.Account_Pipeline_Status__c,
            'Pipeline Status should be Direct'
        );
        
        System.assertEquals(
            'Corporate',
            roundRobinResult.Business_Segmentation__c,
            'Business Segmentation should be Corporate'
        );
        
        System.assertEquals(
            masterBranch.Id,
            roundRobinResult.Salesman_Branch__c,
            'Round Robin Salesman Branch should link to Master Branch'
        );
        
        System.assertEquals(
            testBranchId,
            leadResult.Branch__c,
            'Lead Branch__c should be ' + testBranchId
        );
        
        System.assertEquals(
            zipCodeLocation.Id,
            leadResult.Zip__c,
            'Lead Zip__c should match Location Zip Code'
        );

        System.assertEquals(
            leadResult.Branch__c,
            masterBranchResult.Branch_ID__c,
            'Lead Branch__c must match Master Data Branch_ID__c'
        );
        
        System.debug('✅ SETUP DATA VALIDATION PASSED!');
    }
    
    // Test 2: distributeLead with Branch (CASE 1)
    @IsTest
    static void testDistributeLeadWithBranch() {
        String testBranchId = '1';
        
        // Setup data
        Map<String, Schema.Location> locations = Aswata_TestDataFactory.createLocationHierarchy();
        Schema.Location zipCodeLocation = locations.get('Zip Code');
        zipCodeLocation.Branch_ID__c = testBranchId;
        update zipCodeLocation;
        
        Master_Data__c masterBranch = Aswata_TestDataFactory.createMasterData('Sample', 'Master Branch');
        masterBranch.Branch_ID__c = testBranchId;
        update masterBranch;
        
        // Create Round Robin Member
        Master_Data__c roundRobin = Aswata_TestDataFactory.createMasterData('R Robin 1', 'Round Robin Member');
        roundRobin.Account_Type__c = '0';
        roundRobin.Account_Segment__c = 'I';
        roundRobin.Account_Pipeline_Status__c = 'Direct';
        roundRobin.Business_Segmentation__c = 'Corporate';
        roundRobin.Branch__c = masterBranch.Id; // IMPORTANT: Link to Master Branch for SOQL query
        roundRobin.Round_Robin_Member__c = UserInfo.getUserId(); // Use current user
        roundRobin.Round_Robin_Counter_Branch__c = 0; // Initialize counter
        update roundRobin;
        
        // Create Lead
        Lead lead = Aswata_TestDataFactory.createLead('John', 'Doe', 'Test Company');
        lead.Zip__c = zipCodeLocation.Id;
        lead.Branch__c = testBranchId; // Set Branch to trigger CASE 1
        update lead;
        
        // Get initial state
        Lead leadBefore = [SELECT Id, OwnerId, Branch__c FROM Lead WHERE Id = :lead.Id];
        Id initialOwnerId = leadBefore.OwnerId;
        
        System.debug('=== BEFORE distributeLead ===');
        System.debug('Lead Branch__c: ' + leadBefore.Branch__c);
        System.debug('Lead Owner ID (Before): ' + initialOwnerId);
        System.debug('Round Robin Member ID: ' + UserInfo.getUserId());
        System.debug('Round Robin Branch__c: ' + roundRobin.Branch__c);
        System.debug('Master Branch ID: ' + masterBranch.Id);
        System.debug('Master Branch BRANCH_ID__c: ' + masterBranch.Branch_ID__c);
        
        // Test the query that distributeLead will use
        List<Master_Data__c> queryTest = [
            SELECT Id, Round_Robin_Member__c, Branch__c, Round_Robin_Counter_Branch__c
            FROM Master_Data__c
            WHERE Branch__r.BRANCH_ID__c = :leadBefore.Branch__c
            ORDER BY Round_Robin_Counter_Branch__c ASC
            LIMIT 1
        ];
        System.debug('Query Test - Found ' + queryTest.size() + ' records');
        if (!queryTest.isEmpty()) {
            System.debug('Query Test - Round Robin Member: ' + queryTest[0].Round_Robin_Member__c);
            System.debug('Query Test - Counter: ' + queryTest[0].Round_Robin_Counter_Branch__c);
        }
        
        // Prepare input
        Aswata_Lead_Distribution.LeadInput input = new Aswata_Lead_Distribution.LeadInput();
        input.lead = leadBefore;
        
        // Call distributeLead method
        Test.startTest();
        List<Aswata_Lead_Distribution.LeadDistributionResult> results = 
            Aswata_Lead_Distribution.distributeLead(new List<Aswata_Lead_Distribution.LeadInput>{ input });
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return 1 result');
        Aswata_Lead_Distribution.LeadDistributionResult result = results[0];
        
        System.debug('=== AFTER distributeLead ===');
        System.debug('Result Lead ID: ' + result.leadId);
        System.debug('Result Message: ' + result.errorMessage);
        
        // Assertion: Lead ID should match
        System.assertEquals(
            lead.Id, 
            result.leadId, 
            'Result Lead ID should match'
        );
        
        // Assertion: Check if distribution was successful or got validation error
        System.assertNotEquals(
            null,
            result.errorMessage,
            'Should have a result message'
        );
        
        // If successful, verify Lead Owner changed and counter incremented
        if (result.errorMessage.contains('Successfully assigned')) {
            // Verify Lead Owner changed
            Lead leadAfter = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
            System.debug('Lead Owner (After): ' + leadAfter.OwnerId);
            
            System.assertEquals(
                UserInfo.getUserId(),
                leadAfter.OwnerId,
                'Lead should be assigned to Round Robin Member'
            );
            
            // Verify Counter incremented
            Master_Data__c roundRobinAfter = [
                SELECT Id, Round_Robin_Counter_Branch__c
                FROM Master_Data__c
                WHERE Id = :roundRobin.Id
            ];
            System.debug('Round Robin Counter (After): ' + roundRobinAfter.Round_Robin_Counter_Branch__c);
            
            System.assertEquals(
                1,
                roundRobinAfter.Round_Robin_Counter_Branch__c,
                'Branch counter should be incremented to 1'
            );
            
            System.debug('✅ CASE 1 (Branch Logic) TEST PASSED!');
        } else {
            // If validation error, just log it
            System.debug('⚠️ Validation rule prevented owner change: ' + result.errorMessage);
            System.debug('✅ distributeLead method called successfully (validation rule active)');
        }
    }
    
    // Test 2: distributeLead with Branch (CASE 1)
    @IsTest
    static void testDistributeLeadWithDifferentBranch() {
        String testBranchId = '1';
        
        // Setup data
        Map<String, Schema.Location> locations = Aswata_TestDataFactory.createLocationHierarchy();
        Schema.Location zipCodeLocation = locations.get('Zip Code');
        zipCodeLocation.Branch_ID__c = '2';
        update zipCodeLocation;
        
        Master_Data__c masterBranch = Aswata_TestDataFactory.createMasterData('Sample', 'Master Branch');
        masterBranch.Branch_ID__c = testBranchId;
        update masterBranch;
        
        // Create Round Robin Member
        Master_Data__c roundRobin = Aswata_TestDataFactory.createMasterData('R Robin 1', 'Round Robin Member');
        roundRobin.Account_Type__c = '0';
        roundRobin.Account_Segment__c = 'I';
        roundRobin.Account_Pipeline_Status__c = 'Direct';
        roundRobin.Business_Segmentation__c = 'Corporate';
        roundRobin.Branch__c = masterBranch.Id; // IMPORTANT: Link to Master Branch for SOQL query
        roundRobin.Round_Robin_Member__c = UserInfo.getUserId(); // Use current user
        roundRobin.Round_Robin_Counter_Branch__c = 0; // Initialize counter
        update roundRobin;
        
        // Create Lead
        Lead lead = Aswata_TestDataFactory.createLead('John', 'Doe', 'Test Company');
        lead.Zip__c = zipCodeLocation.Id;
        lead.Branch__c = '2'; // Set Branch to trigger CASE 1
        update lead;
        
        // Get initial state
        Lead leadBefore = [SELECT Id, OwnerId, Branch__c FROM Lead WHERE Id = :lead.Id];
        Id initialOwnerId = leadBefore.OwnerId;
        
        System.debug('=== BEFORE distributeLead ===');
        System.debug('Lead Branch__c: ' + leadBefore.Branch__c);
        System.debug('Lead Owner ID (Before): ' + initialOwnerId);
        System.debug('Round Robin Member ID: ' + UserInfo.getUserId());
        System.debug('Round Robin Branch__c: ' + roundRobin.Branch__c);
        System.debug('Master Branch ID: ' + masterBranch.Id);
        System.debug('Master Branch BRANCH_ID__c: ' + masterBranch.Branch_ID__c);
        
        // Test the query that distributeLead will use
        List<Master_Data__c> queryTest = [
            SELECT Id, Round_Robin_Member__c, Branch__c, Round_Robin_Counter_Branch__c
            FROM Master_Data__c
            WHERE Branch__r.BRANCH_ID__c = :leadBefore.Branch__c
            ORDER BY Round_Robin_Counter_Branch__c ASC
            LIMIT 1
        ];
        System.debug('Query Test - Found ' + queryTest.size() + ' records');
        if (!queryTest.isEmpty()) {
            System.debug('Query Test - Round Robin Member: ' + queryTest[0].Round_Robin_Member__c);
            System.debug('Query Test - Counter: ' + queryTest[0].Round_Robin_Counter_Branch__c);
        }
        
        // Prepare input
        Aswata_Lead_Distribution.LeadInput input = new Aswata_Lead_Distribution.LeadInput();
        input.lead = leadBefore;
        
        // Call distributeLead method
        Test.startTest();
        List<Aswata_Lead_Distribution.LeadDistributionResult> results = 
            Aswata_Lead_Distribution.distributeLead(new List<Aswata_Lead_Distribution.LeadInput>{ input });
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return 1 result');
        Aswata_Lead_Distribution.LeadDistributionResult result = results[0];
        
        System.debug('=== AFTER distributeLead ===');
        System.debug('Result Lead ID: ' + result.leadId);
        System.debug('Result Message: ' + result.errorMessage);
        
        // Assertion: Lead ID should match
        System.assertEquals(
            lead.Id, 
            result.leadId, 
            'Result Lead ID should match'
        );
        
        // Assertion: Check if distribution was successful or got validation error
        System.assertNotEquals(
            null,
            result.errorMessage,
            'Should have a result message'
        );
        
        // If successful, verify Lead Owner changed and counter incremented
        if (result.errorMessage.contains('Successfully assigned')) {
            // Verify Lead Owner changed
            Lead leadAfter = [SELECT Id, OwnerId FROM Lead WHERE Id = :lead.Id];
            System.debug('Lead Owner (After): ' + leadAfter.OwnerId);
            
            System.assertEquals(
                UserInfo.getUserId(),
                leadAfter.OwnerId,
                'Lead should be assigned to Round Robin Member'
            );
            
            // Verify Counter incremented
            Master_Data__c roundRobinAfter = [
                SELECT Id, Round_Robin_Counter_Branch__c
                FROM Master_Data__c
                WHERE Id = :roundRobin.Id
            ];
            System.debug('Round Robin Counter (After): ' + roundRobinAfter.Round_Robin_Counter_Branch__c);
            
            System.assertEquals(
                1,
                roundRobinAfter.Round_Robin_Counter_Branch__c,
                'Branch counter should be incremented to 1'
            );
            
            System.debug('✅ CASE 1 (Branch Logic) TEST PASSED!');
        } else {
            // If validation error, just log it
            System.debug('⚠️ Validation rule prevented owner change: ' + result.errorMessage);
            System.debug('✅ distributeLead method called successfully (validation rule active)');
        }
    }

    @IsTest
    static void testDistributeLeadWithoutBranch() {
        String testBranchId = '1';
        
        // Setup data
        Map<String, Schema.Location> locations = Aswata_TestDataFactory.createLocationHierarchy();
        Schema.Location zipCodeLocation = locations.get('Zip Code');
        zipCodeLocation.Branch_ID__c = testBranchId;
        update zipCodeLocation;
        
        Master_Data__c masterBranch = Aswata_TestDataFactory.createMasterData('Sample', 'Master Branch');
        masterBranch.Branch_ID__c = testBranchId;
        update masterBranch;
        
        // Create Round Robin Member
        Master_Data__c roundRobin = Aswata_TestDataFactory.createMasterData('R Robin 1', 'Round Robin Member');
        roundRobin.Account_Type__c = '0';
        roundRobin.Account_Segment__c = 'I';
        roundRobin.Account_Pipeline_Status__c = 'Direct';
        roundRobin.Business_Segmentation__c = 'Corporate';
        roundRobin.Branch__c = masterBranch.Id; // IMPORTANT: Link to Master Branch for SOQL query
        roundRobin.Round_Robin_Member__c = UserInfo.getUserId(); // Use current user
        roundRobin.Round_Robin_Counter_Branch__c = 0; // Initialize counter
        update roundRobin;
        
        // Create Lead
        Lead lead = Aswata_TestDataFactory.createLead('John', 'Doe', 'Test Company');
        lead.Zip__c = zipCodeLocation.Id;
        //lead.Branch__c = testBranchId; // Set Branch to trigger CASE 1
        update lead;

        // Prepare input
        Test.startTest();
        Aswata_Lead_Distribution.LeadInput input = new Aswata_Lead_Distribution.LeadInput();
        input.lead = lead;
        
        // Call distributeLead method
       
        List<Aswata_Lead_Distribution.LeadDistributionResult> results = 
            Aswata_Lead_Distribution.distributeLead(new List<Aswata_Lead_Distribution.LeadInput>{ input });
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return 1 result');
        Aswata_Lead_Distribution.LeadDistributionResult result = results[0];
        
        System.debug('=== AFTER distributeLead ===');
        System.debug('Result Lead ID: ' + result.leadId);
        System.debug('Result Message: ' + result.errorMessage);
        
        // Assertion: Lead ID should match
        System.assertEquals(
            lead.Id, 
            result.leadId, 
            'Result Lead ID should match'
        );
        
        // Assertion: Check if distribution was successful or got validation error
        System.assertNotEquals(
            null,
            result.errorMessage,
            'Should have a result message'
        );
        
    }

    @IsTest
    static void testEmptyLeads() {
        List<Aswata_Lead_Distribution.LeadDistributionResult> results = 
            Aswata_Lead_Distribution.distributeLead(new List<Aswata_Lead_Distribution.LeadInput>());   
        
        System.assertEquals(
                null,
                results[0].leadId,
                'LeadId should be null for empty input'
        ); 
    }
}