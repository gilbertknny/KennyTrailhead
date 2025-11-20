@IsTest
private class SCC_MerchantProfileByMIDWrapperTest {

    @IsTest
    static void testParseMethod() {
        // Create a sample JSON string representing merchant profile data
        String json = '{"MERCHANT_PROFILE":[{"vendor_pemasang":"Vendor A","user_pemrakarsa":"User A","tipe_merchant":"Type A","tid":"T1234567890"}]}';
        
        // Call the parse method to deserialize the JSON string
        SCC_MerchantProfileByMIDWrapper wrapper = SCC_MerchantProfileByMIDWrapper.parse(json);
        
        // Verify that the deserialized object is not null
        System.assertNotEquals(null, wrapper);
        
        // Verify that the MERCHANT_PROFILE list is not empty
        System.assertNotEquals(null, wrapper.MERCHANT_PROFILE);
        System.assertNotEquals(0, wrapper.MERCHANT_PROFILE.size());
        
        // Verify the deserialized data
        SCC_MerchantProfileByMIDWrapper.MERCHANT_PROFILE profile = wrapper.MERCHANT_PROFILE[0];
        System.assertEquals('Vendor A', profile.vendor_pemasang);
        System.assertEquals('User A', profile.user_pemrakarsa);
        System.assertEquals('Type A', profile.tipe_merchant);
        System.assertEquals('T1234567890', profile.tid);
    }
}