// MockedURL class for simulating different org types
public class MockedURL {
    public static String mockReturnUrl;
    
    public static URL getOrgDomainURL() {
        return new URL(mockReturnUrl);
    }
}