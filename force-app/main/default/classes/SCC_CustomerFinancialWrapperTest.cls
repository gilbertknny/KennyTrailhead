@isTest
public class SCC_CustomerFinancialWrapperTest {
    @isTest
    static void testParse_NullJSON() {
        // Test parsing with null JSON input
        SCC_CustomerFinancialWrapper result = SCC_CustomerFinancialWrapper.parse(null);
        System.assertEquals(null, result, 'Parsing null JSON should return null');
    }

    @isTest
    static void testParse_EmptyJSON() {
        // Test parsing with empty JSON input
        SCC_CustomerFinancialWrapper result = SCC_CustomerFinancialWrapper.parse('{}');
        System.assertNotEquals(null, result, 'Parsing empty JSON should not return null');
        System.assertEquals(null, result.data, 'Parsing empty JSON should not populate data');
    }

    @isTest
    static void testParse_ValidJSON() {
        // Test parsing with valid JSON input
        String jsonString = '{"data":[{"demografi":{"namaSesuaiIdentitas":"John Doe"},"cifno":"123456"}],"statusCode":200}';
        SCC_CustomerFinancialWrapper result = SCC_CustomerFinancialWrapper.parse(jsonString);
        System.assertNotEquals(null, result, 'Parsing valid JSON should not return null');
        System.assertNotEquals(null, result.data, 'Parsing valid JSON should populate data');
        System.assertEquals(200, result.statusCode, 'Parsing valid JSON should set status code');
    }

    @isTest
    static void testParse_InvalidJSON() {
        // Test parsing with invalid JSON input
        String invalidJsonString = 'Invalid JSON';
        SCC_CustomerFinancialWrapper result = SCC_CustomerFinancialWrapper.parse(invalidJsonString);
        System.assertEquals(null, result, 'Parsing invalid JSON should return null');
    }
}