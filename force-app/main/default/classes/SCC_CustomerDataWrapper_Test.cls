@isTest
public class SCC_CustomerDataWrapper_Test {

    @isTest
    static void testSCC_CustomerDataWrapper() {
        // Given sample data to initialize the wrapper
        String testAccountNumber = '1234567890';
        String testCifno = '123456789';
        String testProduct = 'Product A';
        String testProductType = 'Type A';
        String testStatus = 'Aktif';
        String testOpenAccountDate = '2020-01-01';

        // Create an instance of SCC_CustomerDataWrapper
        SCC_CustomerDataWrapper wrapper = new SCC_CustomerDataWrapper(
            testAccountNumber, testCifno, testProduct, testProductType, testStatus, testOpenAccountDate
        );

        // Assert that the instance is created and fields are set correctly
        System.assertNotEquals(null, wrapper, 'Wrapper instance should not be null');
        System.assertEquals(testAccountNumber, wrapper.accountNumber, 'Account number should match the input value');
        System.assertEquals(testCifno, wrapper.cifno, 'CIF number should match the input value');
        System.assertEquals(testProduct, wrapper.product, 'Product should match the input value');
        System.assertEquals(testProductType, wrapper.productType, 'Product type should match the input value');
        System.assertEquals(testStatus, wrapper.status, 'Status should match the input value');
        System.assertEquals(testOpenAccountDate, wrapper.openAccountDate, 'Open account date should match the input value');
    }
    
    @isTest
    static void testNullValuesInSCC_CustomerDataWrapper() {
        // Create an instance of SCC_CustomerDataWrapper with null values
        SCC_CustomerDataWrapper wrapper = new SCC_CustomerDataWrapper(
            null, null, null, null, null, null
        );

        // Assert that the instance is created and fields are set to null
        System.assertNotEquals(null, wrapper, 'Wrapper instance should not be null');
        System.assertEquals(null, wrapper.accountNumber, 'Account number should be null');
        System.assertEquals(null, wrapper.cifno, 'CIF number should be null');
        System.assertEquals(null, wrapper.product, 'Product should be null');
        System.assertEquals(null, wrapper.productType, 'Product type should be null');
        System.assertEquals(null, wrapper.status, 'Status should be null');
        System.assertEquals(null, wrapper.openAccountDate, 'Open account date should be null');
    }
}