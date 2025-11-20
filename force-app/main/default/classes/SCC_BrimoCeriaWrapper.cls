/**
 * @description       : 
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 09-12-2024
 * @last modified by  : Ardyta Yudianto
**/
public without sharing class SCC_BrimoCeriaWrapper {
    public class InsertFileRequestModel {
        public String linkedEntityId { get; set; }
        public String versionData { get; set; }
        public String title { get; set; }
        public String pathOnClient { get; set; }
    }

    public class InsertFileResponseModel {
        public String responseCode { get; set; }
        public String responseMessage { get; set; }
        public String url { get; set; }
    }
}