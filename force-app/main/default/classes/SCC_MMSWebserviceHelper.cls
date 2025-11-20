public class SCC_MMSWebserviceHelper {
    /**
     * Returns the request's content type for JSON requests.
     */
    public static string GetContentType() {
        return 'application/json';
    }
    
    /**
     * Converts file content to base64 string for JSON body
     */
    public static string ConvertFileToBase64(Blob fileBlob) {
        return EncodingUtil.base64Encode(fileBlob);
    }
    
    /**
     * Creates a JSON request body with file and metadata
     */
    public static String CreateJsonBody(String objectId, String fileName, Blob fileContent) {
        String fileExtension = fileName.substringAfterLast('.').toLowerCase();
        
        String contentType = 'application/octet-stream';
        if (fileExtension == 'jpeg') {
            contentType = 'image/jpeg';
        } else if (fileExtension == 'png') {
            contentType = 'image/png';
        } else if (fileExtension == 'pdf') {
            contentType = 'application/pdf';
        } else if (fileExtension == 'jpg') {
            contentType = 'application/jpg';
        }
       
        String base64Data = 'data:' + contentType + ';base64,' + EncodingUtil.base64Encode(fileContent);
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'ObjectID' => objectId,
            'appId' => '0',
            'name' => fileName,
            'file' => base64Data
        };
        
        return JSON.serialize(requestBody);
    }
}