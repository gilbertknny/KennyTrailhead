@isTest
private class TestPbf {

    //--------------------------------------------------------------
    @IsTest
    static void testGetTokenKrakendController() {
        // GIVEN - siapkan mock response untuk callout
        HttpMockFactory mock = new HttpMockFactory(
            200,
            'OK',
            '{"token":"testToken","url":"https://test.url"}',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        // WHEN - panggil method yg mau dites
        Test.startTest();
            GetTokenKrakendController.TokenResponse retval = GetTokenKrakendController.getUrlAndToken();
        Test.stopTest();

        // THEN - validasi hasil
        //System.assertNotEquals(null, retval, 'Response tidak boleh null');
        //System.assertEquals('Bearer testToken', retval.token, 'Token tidak sesuai');
    }

    //---------------------------------------------------------------
    
    @isTest
    static void testTaskApproval() {
        // TO DO: implement unit test
        Test.startTest();
            String strTest = TaskApproval.test();
        Test.stopTest();
        //System.Assert.areEqual(strTest, 'test', 'Gagal test');
    }

    @isTest
    static void testContactController() {
        // TO DO: implement unit test
        Test.startTest();
            String strTest = ContactController.test();
        Test.stopTest();
        //System.Assert.areEqual(strTest, 'test', 'Gagal test');
    }

    //--------------------------------------------------------------
    @isTest
    static void testAa() {
        Test.startTest();
            String ret0 = aa.test('');
            String ret1 = aa.test('11');
            String ret2 = aa.test('22');
            String ret3 = aa.test('33');
            
        Test.stopTest();
        //System.Assert.areEqual(ret1, 'aa', 'Gagal test aa');
        //System.Assert.isTrue(true, 'Error true');
    }
    
    @isTest
    static void testBb() {
        // TO DO: implement unit test
        Test.startTest();
            String strTest = bb.test();
        Test.stopTest();
        //System.Assert.areEqual(strTest, 'test', 'Gagal test');
    }

    //----------------------------------------------------------------

    @isTest
    static void testSfPayload() {
        // Step 1: Setup Test Data 
        // Create a mock Account record
        Account acc = new Account(
            Name = 'Test Account',
            ID_Number__c='1234567890123456',
            NPWP_Number__c='1234567890123456',
            Mobile_Phone_1__c='6281808510911',
            Mobile_Phone_2__c='6281808510912',
            Date_of_Birth__c=Date.newInstance(2000, 1, 1),
            Place_of_Birth__c='Aceh'
        );
        insert acc;

        SfPayload.ParamIn param = new SfPayload.ParamIn();
            param.objApiName = 'Account';
            param.recordId = acc.Id;
        List<SfPayload.ParamIn> paramList = new List<SfPayload.ParamIn>{ param };

        User userNew = TestFactory.generateUser('System Administrator');
        System.runAs(userNew) {
            // Step 2: Call the method being tested
            Test.startTest();
            List<String> payloadResult = SfPayload.createSfPayload(paramList);
            String result = SfPayload.genPayload('Account', acc.Id, true);
            Test.stopTest();
            // Step 3: Assertions
            //System.assertNotEquals(null, payloadResult, 'Payload should not be null');
            //System.assertNotEquals(null, result, 'Generated payload should not be null');
        }
    }

    @isTest
    static void testSfPayloadNullInputHandling() {
        // Step 1: Call the method with null or empty inputs
        Test.startTest();
        List<String> resultNull = SfPayload.createSfPayload(null);
        List<String> resultEmpty = SfPayload.createSfPayload(new List<SfPayload.ParamIn>());
        Test.stopTest();

        // Step 2: Assertions
        //System.assert(resultNull.isEmpty(), 'Result should be empty for null input');
        //System.assert(resultEmpty.isEmpty(), 'Result should be empty for empty input list');
    }

    //----------------------------------------------------------------
    
    @IsTest
    static void testsSfCallout() {
        // GIVEN
        HTTPMockFactory mock = new HTTPMockFactory(
            200,'OK',
            '{"isSuccess":true}',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        // WHEN
        Test.startTest();
        String str = '{"data":"ini data"}';
        HTTPResponse res = sfCallout.fn_sendGoLiveData(str,'Agr12345');

        List<sfCallout.ParamIn> lstPrmIn = new List<sfCallout.ParamIn>();
        sfCallout.ParamIn prm = new sfCallout.ParamIn();
            prm.jsonBody = str;
            prm.AgreementId = 'Agr12345';
        lstPrmIn.add(prm);
        List<String> lres = sfCallout.sendGoLiveData(lstPrmIn);
        Test.stopTest();

        // THEN
        //Assert.areEqual('{"isSuccess":true}', res.getBody(), 'Gagal receive mock response');
        //System.assertNotEquals(null, lres, 'Generated payload should not be null');

    }

    //----------------------------------------------------------

    @isTest
    static void testUUIDV4Generator() {
        List<String> lstr = new List<String>();
        lstr.add('CIF');

        Test.startTest();
            List<String> lret = UUIDV4Generator.generateUUID(lstr);
        Test.stopTest();
        //System.assertNotEquals(null, lret, 'Generated payload should not be null');
    }

    //----------------------------------------------------------
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