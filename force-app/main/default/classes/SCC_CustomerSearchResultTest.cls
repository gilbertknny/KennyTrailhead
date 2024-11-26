@isTest
public class SCC_CustomerSearchResultTest {

    @isTest
    static void testConstructor_NoErrorMessage() {
        // Test constructor without error message
        String demographicInfo = 'Demographic Info';
        Id accountId = '00128000009aBCDAA2';
        String handphone = '08123456789';

        SCC_CustomerSearchResult result = new SCC_CustomerSearchResult(demographicInfo, accountId,handphone);

        System.assertEquals(demographicInfo, result.demographicInfo, 'Demographic info should be set correctly');
        System.assertEquals(accountId, result.accountId, 'Account ID should be set correctly');
        System.assertEquals(null, result.errorMessage, 'Error message should be null');
    }

    @isTest
    static void testConstructor_WithErrorMessage() {
        // Test constructor with error message
        String demographicInfo = 'Demographic Info';
        Id accountId = '00128000009aBCDAA2';
        String handphone = '08123456789';
        String errorMessage = 'Error Message';

        SCC_CustomerSearchResult result = new SCC_CustomerSearchResult(demographicInfo, accountId, handphone, errorMessage);

        System.assertEquals(demographicInfo, result.demographicInfo, 'Demographic info should be set correctly');
        System.assertEquals(accountId, result.accountId, 'Account ID should be set correctly');
        System.assertEquals(errorMessage, result.errorMessage, 'Error message should be set correctly');
    }
}