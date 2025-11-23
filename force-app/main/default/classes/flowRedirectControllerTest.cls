@IsTest
private class flowRedirectControllerTest {
    
    @IsTest
    static void testGenerateRedirectUrl_ValidInput() {
        FlowRedirectController.InputParam input = new FlowRedirectController.InputParam();
        input.recordId = '001MS0000089ymtYAA'; 
        input.objectApiName = 'Account';
        
        List<FlowRedirectController.InputParam> inputs = new List<FlowRedirectController.InputParam>{ input };
        List<FlowRedirectController.OutputParam> results = FlowRedirectController.generateRedirectUrl(inputs);
        
        System.assertEquals(1, results.size(), 'Harusnya 1 output');
        System.assertEquals('/lightning/r/Account/001MS0000089ymtYAA/view', results[0].recordUrl, 'URL tidak sesuai format Lightning');
    }
    
    
    @IsTest
    static void testGenerateRedirectUrl_MissingObjectName() {
        FlowRedirectController.InputParam input = new FlowRedirectController.InputParam();
        input.recordId = '001MS0000089ymtYAA';
        input.objectApiName = null;
        
        List<FlowRedirectController.OutputParam> results = FlowRedirectController.generateRedirectUrl(
            new List<FlowRedirectController.InputParam>{ input }
        );
        
        System.assertEquals('/lightning/page/home', results[0].recordUrl, 'Harus redirect ke home page karena object kosong');
    }
    
    
    @IsTest
    static void testGenerateRedirectUrl_MissingRecordId() {
        FlowRedirectController.InputParam input = new FlowRedirectController.InputParam();
        input.recordId = null; 
        input.objectApiName = 'Account';
        
        List<FlowRedirectController.OutputParam> results = FlowRedirectController.generateRedirectUrl(
            new List<FlowRedirectController.InputParam>{ input }
        );
        
        System.assertEquals('/lightning/page/home', results[0].recordUrl, 'Harus redirect ke home page karena recordId null');
    }
}