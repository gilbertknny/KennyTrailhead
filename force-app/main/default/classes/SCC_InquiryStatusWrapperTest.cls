@isTest
public class SCC_InquiryStatusWrapperTest {

    @isTest
    static void testConstructor() {
        // Test data
        String saldoAkhirMutasi = 'Test Saldo';
        String holdType = 'Test Hold Type';
        String holdAmt = '100'; // holdAmt is represented as a String in the wrapper class
        String holdRemark = 'Test Remark';

        // Instantiate the SCC_InquiryStatusWrapper object
        SCC_InquiryStatusWrapper wrapper = new SCC_InquiryStatusWrapper(saldoAkhirMutasi, holdType, holdAmt, holdRemark);

        // Verify that the object is instantiated correctly
        System.assertEquals(saldoAkhirMutasi, wrapper.saldoAkhirMutasi);
        System.assertEquals(holdType, wrapper.holdType);
        System.assertEquals(holdAmt, wrapper.holdAmt);
        System.assertEquals(holdRemark, wrapper.holdRemark);
    }
}