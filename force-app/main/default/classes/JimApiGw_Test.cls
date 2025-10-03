@IsTest
public class JimApiGw_Test {


    public class MockFlowInterview implements System.StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            switch on stubbedMethodName {
                when 'getVariableValue' {
                    // Return nilai simulasi 
                    return (Object)'{"isSuccess:true"}';
                }
                when 'createInterview' {
                    return null;
                }
                when 'start' {
                    return null;
                }
            }
            return 'catchall';
        }
    }
    
   @isTest
    static void testJimApiGw_Lead_Expose_Agent() {
        RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf('{"key": "value"}');
            req.httpMethod = 'POST';
            req.requestURI = '/apigw/' + 'Lead_Expose_Agent';
            req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = new RestResponse();

        //Pasang Mock ke FlowHelper di JimApiGw
        JimApiGw.myFlow = (JimFlow)Test.createStub(JimFlow.class, new MockFlowInterview());

        Test.startTest();
            JimApiGw.doPost();
        Test.stopTest();
    }

    @isTest
    static void testJimApiGw_noFlow() {
        RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf('{"key": "value"}');
            req.httpMethod = 'POST';
            req.requestURI = '/apigw';
            req.addHeader('Content-Type', 'application/json');
        RestContext.request = req;
        RestContext.response = new RestResponse();
        
        //Pasang Mock ke FlowHelper di JimApiGw
        JimApiGw.myFlow = (JimFlow)Test.createStub(JimFlow.class, new MockFlowInterview());
        
        Test.startTest();
            JimApiGw.doPost();
        Test.stopTest();
    }

    //--------------------------

    @isTest
    static void testJimFlow() {
        // Arrange
        String flowName = 'Lead_Expose_Agent';
        Map<String, Object> inputVariables = new Map<String, Object>{
            'inputVar' => 'testValue'
        };
        
        Test.startTest();
        
        // Act
        JimFlow jimFlow = new JimFlow();
        jimFlow.createInterview(flowName, inputVariables);
        jimFlow.start();
        Object result = jimFlow.getVariableValue('response_message');
        
        Test.stopTest();
        
        // Assert
        //System.assertNotEquals(null, result, 'Output variable should not be null');
    }

    @isTest
    static void testJimFlowWithEmptyInput() {
        // Arrange
        String flowName = 'Lead_Expose_Agent';
        Map<String, Object> inputVariables = new Map<String, Object>();
        
        Test.startTest();
        
        // Act
        JimFlow jimFlow = new JimFlow();
        jimFlow.createInterview(flowName, inputVariables);
        jimFlow.start();
        Object result = jimFlow.getVariableValue('response_message');
        
        Test.stopTest();
        
        // Assert
        //System.assertNotEquals(null, result, 'Output variable should not be null even with empty input');
    }

    @isTest
    static void testJimFlowWithInvalidFlowName() {
        // Arrange
        String flowName = 'InvalidFlow';
        Map<String, Object> inputVariables = new Map<String, Object>{
            'inputVar' => 'testValue'
        };
        
        Test.startTest();
        
        // Act & Assert
        try {
            JimFlow jimFlow = new JimFlow();
            jimFlow.createInterview(flowName, inputVariables);
            jimFlow.start();
            //System.assert(false, 'Exception should have been thrown for invalid flow name');
        } catch (Exception e) {
            //System.assert(true, 'Exception correctly thrown for invalid flow name');
        }
        
        Test.stopTest();
    }
}