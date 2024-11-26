@isTest
public class SCC_CustomerVerificationWrapperTest {
    
    @isTest
    static void testParseNullJSON() {
        // Test parsing with null JSON input
        SCC_CustomerVerificationWrapper result = SCC_CustomerVerificationWrapper.parse(null);
        System.assertEquals(null, result, 'Parsing null JSON should return null');
    }

    @isTest
    static void testParseEmptyJSON() {
        // Test parsing with empty JSON input
        SCC_CustomerVerificationWrapper result = SCC_CustomerVerificationWrapper.parse('{}');
        System.assertNotEquals(null, result, 'Parsing empty JSON should not return null');
        System.assertEquals(null, result.data, 'Parsing empty JSON should not populate data');
    }

    @isTest
    static void testParseValidJSON() {
        // Test parsing with valid JSON input
        String jsonString = '{"data":[{"demografi":{"namaSesuaiIdentitas":"John Doe"},"cifno":"123456"}],"statusCode":200}';
        SCC_CustomerVerificationWrapper result = SCC_CustomerVerificationWrapper.parse(jsonString);
        System.assertNotEquals(null, result, 'Parsing valid JSON should not return null');
        System.assertNotEquals(null, result.data, 'Parsing valid JSON should populate data');
        System.assertEquals(200, result.statusCode, 'Parsing valid JSON should set status code');
    }

    @isTest
    static void testParseInvalidJSON() {
        // Test parsing with invalid JSON input
        String invalidJsonString = 'Invalid JSON';
        SCC_CustomerVerificationWrapper result = SCC_CustomerVerificationWrapper.parse(invalidJsonString);
        System.assertEquals(null, result, 'Parsing invalid JSON should return null');
    }
}