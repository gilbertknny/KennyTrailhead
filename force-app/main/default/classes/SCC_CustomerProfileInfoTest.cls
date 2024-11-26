@isTest
private class SCC_CustomerProfileInfoTest {

    @isTest
    static void testConstructor() {
        // Creating a sample Demografi object
        SCC_CustomerProfileWrapper.Demografi demographicInfo = new SCC_CustomerProfileWrapper.Demografi();
        demographicInfo.umur = 30;
        demographicInfo.tipeNasabahDesc = 'Description';
        // Initialize other fields as needed...
        
        // Defining a CIF number
        String cifno = '1234567890';
        
        // Creating an instance of SCC_CustomerProfileInfo
        SCC_CustomerProfileInfo customerProfileInfo = new SCC_CustomerProfileInfo(demographicInfo, cifno);
        
        // Asserting that the instance is not null
        System.assertNotEquals(null, customerProfileInfo);
        
        // Asserting that the demographicInfo and cifno are set correctly
        System.assertEquals(demographicInfo, customerProfileInfo.demographicInfo);
        System.assertEquals(cifno, customerProfileInfo.cifno);
    }
}