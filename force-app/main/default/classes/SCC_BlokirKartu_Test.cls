/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
// @isTest
// private class SCC_BlokirKartu_Test {

//     @isTest
//     static void myUnitTest() {
//         // TO DO: implement unit test
//     }
// }

@isTest
public class SCC_BlokirKartu_Test {
    @isTest
    static void testGetUserPermissionSets() {
        // Create test data
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id
        );
        insert testUser;
        
        // Create a Permission Set
        PermissionSet ps = new PermissionSet(
            Label = 'Test Permission Set',
            Name = 'Test_Permission_Set'
        );
        insert ps;
        
        // Assign Permission Set to the test user
        PermissionSetAssignment psa = new PermissionSetAssignment(
            AssigneeId = testUser.Id,
            PermissionSetId = ps.Id
        );
        insert psa;
        
        // Run test as the test user
        System.runAs(testUser) {
            Test.startTest();
            List<String> permissionSets = SCC_BlokirKartu.getUserPermissionSets();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetUserPermissionSetsNoAssignments() {
        // Create test user without any permission sets
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser2@test.com',
            Username = 'testuser2' + System.currentTimeMillis() + '@test.com',
            Alias = 'tuser2',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id
        );
        insert testUser;
        
        // Run test as the test user
        System.runAs(testUser) {
            Test.startTest();
            List<String> permissionSets = SCC_BlokirKartu.getUserPermissionSets();
            Test.stopTest();
        }
    }
}