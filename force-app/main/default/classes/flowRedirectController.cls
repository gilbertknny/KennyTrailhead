/**
 * @description for redirect code
 * Ensures URL generation logic behaves correctly for valid and invalid inputs.
 */
public with sharing class flowRedirectController {
    
    public class InputParam {
        @InvocableVariable(required=true description='Record Id tujuan redirect')
        public Id recordId;
        
        @InvocableVariable(required=true description='API Name dari object (misal: Account, Case, Opportunity)')
        public String objectApiName;
    }
    
    public class OutputParam {
        @InvocableVariable(description='URL Lightning Record Page')
        public String recordUrl;
    }

    @InvocableMethod(label='Generate Redirect URL' description='Generate Lightning record URL untuk digunakan di Flow')
    public static List<OutputParam> generateRedirectUrl(List<InputParam> inputs) {
        List<OutputParam> results = new List<OutputParam>();
        
        for (InputParam input : inputs) {
            OutputParam output = new OutputParam();

            // Validasi
            if (input.recordId == null || String.isBlank(input.objectApiName)) {
                output.recordUrl = '/lightning/page/home';
            } else {
                // Format URL Lightning Record Page
                output.recordUrl = '/lightning/r/' + input.objectApiName + '/' + input.recordId + '/view';
            }
            
            results.add(output);
        }
        
        return results;
    }
}