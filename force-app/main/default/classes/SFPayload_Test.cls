@IsTest
public class SFPayload_Test {
    @IsTest
    static void testCreateSfPayloadWithAccount() {
        // --- Step 1: Prepare test data ---
        Account acc = BFI_TestDataFactory.createAccount('Test Account');

        // --- Step 2: Build ParamIn ---
        SfPayload.ParamIn param = new SfPayload.ParamIn();
        param.objApiName = 'Account';
        param.recordId = acc.Id;
        param.objArray = false; // test non-array style

        // --- Step 3: Call the method ---
        Test.startTest();
        List<String> results = SfPayload.createSfPayload(new List<SfPayload.ParamIn>{ param });
        Test.stopTest();

        // --- Step 4: Assertions ---
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one JSON payload');
        System.assert(results[0].contains('Account'), 'Payload should include the object name');
        System.assert(results[0].contains('Test Account'), 'Payload should include the Account Name');
        System.assert(results[0].contains('1234567890'), 'Payload should include the Phone');
    }

    @IsTest
    static void testCreateSfPayloadAsArray() {
        // --- Step 1: Prepare test data ---
       Account c = BFI_TestDataFactory.createAccount('Test Account');

        // --- Step 2: Build ParamIn ---
        SfPayload.ParamIn param = new SfPayload.ParamIn();
        param.objApiName = 'Account';
        param.recordId = c.Id;
        param.objArray = true; // test array style

        // --- Step 3: Call the method ---
        Test.startTest();
        List<String> results = SfPayload.createSfPayload(new List<SfPayload.ParamIn>{ param });
        Test.stopTest();

        // --- Step 4: Assertions ---
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return one JSON payload');
        System.assert(results[0].startsWith('{'), 'When objArray = true, payload should start with {');
        //System.assert(results[0].contains('Tester'), 'Payload should contain Contact LastName');
    }

    @IsTest
    static void testCreateSfPayloadNullParams() {
        // --- Step 1: Call with empty list ---
        Test.startTest();
        List<String> results = SfPayload.createSfPayload(new List<SfPayload.ParamIn>());
        Test.stopTest();

        // --- Step 2: Assertions ---
        System.assertEquals(0, results.size(), 'Empty param list should return empty results');
    }
}