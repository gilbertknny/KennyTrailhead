public class SCC_CustomerSearchResult {
	 	
        @AuraEnabled
        public String accountId { get; private set; }
    	@AuraEnabled
        public String demographicInfo { get; private set; }
    	@AuraEnabled
        public String errorMessage { get; private set; }
   		@AuraEnabled
        public String handphone { get; private set; }

        public SCC_CustomerSearchResult(String demographicInfo, Id accountId, String handphone) {
            this.demographicInfo = demographicInfo;
            this.accountId = accountId != null ? accountId : null;
            this.handphone = handphone;
            this.errorMessage = null;
        }
    
        public SCC_CustomerSearchResult(String demographicInfo, Id accountId, String handphone, String errorMessage) {
            this.demographicInfo = demographicInfo;
            this.accountId = accountId != null ? accountId : null;
            this.handphone = handphone;
            this.errorMessage = errorMessage != null ? errorMessage : null;
        }
}