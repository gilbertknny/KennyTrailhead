@isTest
public class EncryptedFieldHelperTest {

    @isTest
    static void testCompareEncryptedField_Match() {
        // Arrange
        User u = BFI_TestDataFactory.createUserWithPassPhrase('MySecret123');

        EncryptedFieldHelper.Request req = new EncryptedFieldHelper.Request();
        req.userId = u.Id;
        req.plainTextValue = 'MySecret123';

        List<EncryptedFieldHelper.Request> reqs = new List<EncryptedFieldHelper.Request>{ req };

        // Act
        Test.startTest();
        List<Boolean> results = EncryptedFieldHelper.compareEncryptedField(reqs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0], 'Should return true when values match');
    }

    @isTest
    static void testCompareEncryptedField_NotMatch() {
        // Arrange
        User u = BFI_TestDataFactory.createUserWithPassPhrase('MySecret123');

        EncryptedFieldHelper.Request req = new EncryptedFieldHelper.Request();
        req.userId = u.Id;
        req.plainTextValue = 'WrongValue';

        List<EncryptedFieldHelper.Request> reqs = new List<EncryptedFieldHelper.Request>{ req };

        // Act
        Test.startTest();
        List<Boolean> results = EncryptedFieldHelper.compareEncryptedField(reqs);
        Test.stopTest();

        // Assert
        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0], 'Should return false when values do not match');
    }

    @isTest
    static void testCompareEncryptedField_BulkRequests() {
        // Arrange
        User u1 = BFI_TestDataFactory.createUserWithPassPhrase('Secret1');
        User u2 = BFI_TestDataFactory.createUserWithPassPhrase('Secret2');

        EncryptedFieldHelper.Request req1 = new EncryptedFieldHelper.Request();
        req1.userId = u1.Id;
        req1.plainTextValue = 'Secret1'; // match

        EncryptedFieldHelper.Request req2 = new EncryptedFieldHelper.Request();
        req2.userId = u2.Id;
        req2.plainTextValue = 'WrongValue'; // not match

        List<EncryptedFieldHelper.Request> reqs = new List<EncryptedFieldHelper.Request>{ req1, req2 };

        // Act
        Test.startTest();
        List<Boolean> results = EncryptedFieldHelper.compareEncryptedField(reqs);
        Test.stopTest();

        // Assert
        System.assertEquals(2, results.size());
        System.assertEquals(true, results[0], 'First should match');
        System.assertEquals(false, results[1], 'Second should not match');
    }
}