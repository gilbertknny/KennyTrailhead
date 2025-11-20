@IsTest
public class MockedURLTest {

    @IsTest
    static void testGetOrgDomainURL_forEducationDomain() {
        MockedURL.mockReturnUrl = 'http://www.example.edu';
        Url expectedUrl = new Url('http://www.example.edu');
        Url actualUrl = MockedURL.getOrgDomainURL();
        System.assertEquals(expectedUrl.toExternalForm(), actualUrl.toExternalForm());
    }

    @IsTest
    static void testGetOrgDomainURL_forGovernmentDomain() {
        MockedURL.mockReturnUrl = 'http://www.example.gov';
        Url expectedUrl = new Url('http://www.example.gov');
        Url actualUrl = MockedURL.getOrgDomainURL();
        System.assertEquals(expectedUrl.toExternalForm(), actualUrl.toExternalForm());
    }

    @IsTest
    static void testGetOrgDomainURL_forCommercialDomain() {
        MockedURL.mockReturnUrl = 'http://www.example.com';
        Url expectedUrl = new Url('http://www.example.com');
        Url actualUrl = MockedURL.getOrgDomainURL();
        System.assertEquals(expectedUrl.toExternalForm(), actualUrl.toExternalForm());
    }

    @IsTest
    static void testGetOrgDomainURL_forNonProfitDomain() {
        MockedURL.mockReturnUrl = 'http://www.example.org';
        Url expectedUrl = new Url('http://www.example.org');
        Url actualUrl = MockedURL.getOrgDomainURL();
        System.assertEquals(expectedUrl.toExternalForm(), actualUrl.toExternalForm());
    }

    @IsTest
    static void testGetOrgDomainURL_forInvalidURL() {
        MockedURL.mockReturnUrl = 'invalid-url';
        try {
            MockedURL.getOrgDomainURL();
            System.assert(false, 'Expected an exception for invalid URL');
        } catch (System.StringException e) {
            // Expected exception for invalid URL
            System.assertEquals('no protocol: invalid-url', e.getMessage());
        } catch (Exception e) {
            // Catch any other exception to ensure the test fails properly
            System.assert(false, 'Expected a System.StringException but got: ' + e.getMessage());
        }
    }
}