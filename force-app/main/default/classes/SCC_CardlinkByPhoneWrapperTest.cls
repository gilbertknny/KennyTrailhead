@isTest
public class SCC_CardlinkByPhoneWrapperTest {

    @isTest
    static void testWrapperClass() {
        // Create test data
        String status = 'Active';
        String productType = 'Credit Card';
        String productDescription = 'Gold Credit Card';
        String product = 'Gold';
        String cifno = '123456789';
        String cardNumber = '1234-5678-9012-3456';
        String namaBelakang = 'Doe';
        String namaTengah = 'John';
        String namaDepan = 'Johny';

        // Instantiate the wrapper class
        SCC_CardlinkByPhoneWrapper wrapperInstance = new SCC_CardlinkByPhoneWrapper(
            status, productType, productDescription, product, cifno, cardNumber, 
            namaBelakang, namaTengah, namaDepan
        );

        // Verify that the properties are set correctly
        System.assertEquals(status, wrapperInstance.status);
        System.assertEquals(productType, wrapperInstance.productType);
        System.assertEquals(productDescription, wrapperInstance.productDescription);
        System.assertEquals(product, wrapperInstance.product);
        System.assertEquals(cifno, wrapperInstance.cifno);
        System.assertEquals(cardNumber, wrapperInstance.cardNumber);
        System.assertEquals(namaBelakang, wrapperInstance.namaBelakang);
        System.assertEquals(namaTengah, wrapperInstance.namaTengah);
        System.assertEquals(namaDepan, wrapperInstance.namaDepan);
    }
}