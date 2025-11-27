/**
 * @description Test class for FlowRedirectController
 * Ensures URL generation logic behaves correctly for valid and invalid inputs.
 */
@IsTest
private class FlowRedirectControllerTest {

    /**
     * @description Helper method to create InputParam
     */
    private static FlowRedirectController.InputParam createInput(String recordId, String objectApiName) {
        FlowRedirectController.InputParam input = new FlowRedirectController.InputParam();
        input.recordId = recordId;
        input.objectApiName = objectApiName;
        return input;
    }

    /**
     * @description Test redirect URL generation with valid inputs.
     */
    @IsTest
    static void testGenerateRedirectUrl_ValidInput() {
        // Given
        FlowRedirectController.InputParam input = createInput('001MS0000089ymtYAA', 'Account');
        List<FlowRedirectController.InputParam> inputs = 
            new List<FlowRedirectController.InputParam>{ input };

        // When
        List<FlowRedirectController.OutputParam> results = 
            FlowRedirectController.generateRedirectUrl(inputs);

        // Then
        System.assertEquals(
            1, 
            results.size(), 
            'Expected 1 output object'
        );
        System.assertEquals(
            '/lightning/r/Account/001MS0000089ymtYAA/view',
            results[0].recordUrl,
            'URL should follow Lightning Record Page format'
        );
    }

    /**
     * @description Test behavior when objectApiName is missing.
     */
    @IsTest
    static void testGenerateRedirectUrl_MissingObjectName() {
        // Given
        FlowRedirectController.InputParam input = createInput('001MS0000089ymtYAA', null);

        // When
        List<FlowRedirectController.OutputParam> results =
            FlowRedirectController.generateRedirectUrl(
                new List<FlowRedirectController.InputParam>{ input }
            );

        // Then
        System.assertEquals(
            '/lightning/page/home',
            results[0].recordUrl,
            'Should redirect to home if objectApiName is null/blank'
        );
    }

    /**
     * @description Test behavior when recordId is missing.
     */
    @IsTest
    static void testGenerateRedirectUrl_MissingRecordId() {
        // Given
        FlowRedirectController.InputParam input = createInput(null, 'Account');

        // When
        List<FlowRedirectController.OutputParam> results =
            FlowRedirectController.generateRedirectUrl(
                new List<FlowRedirectController.InputParam>{ input }
            );

        // Then
        System.assertEquals(
            '/lightning/page/home',
            results[0].recordUrl,
            'Should redirect to home if recordId is null'
        );
    }
}