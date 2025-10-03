@isTest
public class TestRestrictContactByName {
      
    @isTest
    static void testInsertInvalidName() {
        Contact invalidContact = new Contact(FirstName = 'Test', LastName = 'INVALIDNAME');

        Test.startTest();
        try {
            insert invalidContact;
            System.assert(false, 'Insert should have failed due to invalid LastName');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The Last Name'), 'Expected error for invalid LastName');
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertValidName() {
        Contact validContact = new Contact(FirstName = 'Test', LastName = 'ValidName');

        Test.startTest();
        insert validContact;
        Test.stopTest();

        System.assertNotEquals(null, validContact.Id, 'Valid contact should be inserted');
    }

    @isTest
    static void testUpdateInvalidName() {
        Contact c = new Contact(FirstName = 'Test', LastName = 'OkName');
        insert c;

        c.LastName = 'INVALIDNAME';

        Test.startTest();
        try {
            update c;
            System.assert(false, 'Update should have failed due to invalid LastName');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('The Last Name'), 'Expected error during update');
        }
        Test.stopTest();
    }

}