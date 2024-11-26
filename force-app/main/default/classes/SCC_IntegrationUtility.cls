public with sharing class SCC_IntegrationUtility {
    public class MyException extends Exception { }
    
    // main method to generate the message 
    public static String generateMessage(String mapName, Map<String, Object> source) {
        Map<String, Object> desObject = makeIntMessage(mapName, null, source);
        String tmp = JSON.serialize(desObject) ;
        //System.debug(' JSON.serialize(desObject) ==> ' +  JSON.serializePretty(desObject) );
        return JSON.serialize(desObject);
    }

    // carry out value conversion based on data type set in the Custom Metadata 
    public static object valueConversion(String convType, object input, Boolean nullToZero) {
        Object rtn = input;
        if (convType == 'STR.UPPER') {
            if (input == null) {
                return null;
            }
            rtn = (String.valueOf(input)).toUpperCase();

        } else if (convType == 'STR.LOWER') {
            if (input == null) {
                return null;
            }
            rtn = (String.valueOf(input)).toLowerCase();
        } else if (convType == 'DATE.GMT') {
            if (input == null) {
                return null;
            }
            rtn = (String.valueOfGmt(Date.valueOf(input)));

        } else if (convType == 'NUMBERSTR') {
            rtn = convStr(String.valueOf(input), true);
        }
        if (nullToZero && input == null) {
            input = 0;
        }
        return rtn;
    }
    
    // query the field mapping from Custom Metadata record 
    public static List<SCC_Object_Conversion_Field_Map__mdt> getObjectMapping(String mapName) {
        List<SCC_Object_Conversion_Map__mdt> objMap = [SELECT DeveloperName FROM SCC_Object_Conversion_Map__mdt WHERE DeveloperName = :mapName];
        if (objMap.size() == 0) {
            throw new MyException('Map(' + mapName + ') does not exist');
        }
        // get object conversion field maps 
        List<SCC_Object_Conversion_Field_Map__mdt> convMap = [SELECT Value_Conversion__c,
                                                              Destination_Field__c,
                                                              Same_Field_Name__c,
                                                              Fixed_Value__c,
                                                              Object_Conversion_Map__c,
                                                              Fixed_Value_Type__c,
                                                              Object_Conversion_Map__r.DeveloperName,
                                                              NullToZero__c,Source_Field__c
                                                              from SCC_Object_Conversion_Field_Map__mdt
                                                              WHERE Object_Conversion_Map__r.DeveloperName = :mapName
                                                              AND Inactive__c != true];
        
        return convMap;
    }
   
    // this takes a string parameter and calls the message maker method 
    public static Map<String, Object> makeIntMessage(String mapName, Map<String, Object> desObject, Map<String, Object> source) {
        List<SCC_Object_Conversion_Field_Map__mdt> convMap = getObjectMapping(mapName);
        return makeIntMessage(convMap, desObject, source);
    }
    
    // main method to make the message 
    public static Map<String, Object> makeIntMessage(List<SCC_Object_Conversion_Field_Map__mdt> convMap, Map<String, Object> desObject, Map<String, Object> source) {
        // desObject is passed as null from GenerateMessage() method 
        if (desObject == null) {
            desObject = new Map<String, Object> ();
        }

        for (SCC_Object_Conversion_Field_Map__mdt covField : convMap) {
            Boolean isSetValue = true;
            String sourceField = covField.Source_Field__c;
            if (covField.Same_Field_Name__c) {
                sourceField = covField.Destination_Field__c;
            }

            if (isSetValue) {
                Object variableValue = '';

                try {
                    if (covField.Fixed_Value__c) {
                        variableValue = sourceField;
                        if (covField.Fixed_Value_Type__c == 'Boolean') {
                            variableValue = Boolean.valueOf(sourceField);
                            putValueByPath(desObject, covField.Destination_Field__c, Boolean.valueOf(sourceField));
                        }
                        else if (covField.Fixed_Value_Type__c == 'Date') {
                            Date datevalue = Date.today();
                            if (String.isNotEmpty(sourceField)) {
                                try {
                                    integer gap = integer.valueOf(sourceField);
                                    datevalue = datevalue.addDays(gap);
                                } catch(Exception e) {
                                    datevalue = Date.parse(sourceField);
                                }
                            }
                            variableValue = datevalue;
                        }
                    } else {
                        variableValue = getVariableValue(source, sourceField);
                    }
                    if (covField.Fixed_Value_Type__c != 'Reference') {
                        variableValue = valueConversion(covField.Value_Conversion__c, variableValue, covField.NullToZero__c);

                        putValueByPath(desObject, covField.Destination_Field__c, variableValue);
                    }
                } catch(Exception e) {
                    throw(New MyException('Error during setting ' + sourceField + ' ' + variableValue + ' into ' + covField.Destination_Field__c + ' from Map(' + covField.Object_Conversion_Map__r.DeveloperName + ').  '
                                          + e.getMessage() + ' '
                                          + e.getStackTraceString()));
                }
            }
        }
        
        return desObject;
    }

    // used for dot notation to access nested objects      
    public static Object getVariableValue(Map<String, Object> variables, String variableName)
    {
        Object variableValue = null;
        if(String.isBlank(variableName)) {
            return variableValue;
        }
        if (variableName.contains('.')) {
            String objName = variableName.substringBefore('.');
            String valName = variableName.substringAfter('.');
            Object obj = variables.get(objName);
            if (obj == null) {
                return null;
            }
            if (valName.contains('.')) {
                Map<String, Object> objvariable = (Map<String, Object>) obj;
                return getVariableValue(objvariable, valName);
            } else {
                try {
                    variableValue = ((sObject) obj).get(valName);
                } catch(Exception e) {
                    variableValue = ((Map<String, Object>) obj).get(valName);
                }
            }
        } else {
            variableValue = variables.get(variableName);
        }
        return variableValue;
    }

    public static Map<String, Object> putValueByPath(Map<String, Object> variables, String path, Object value) {
        if (variables == null) {
            variables = new Map<String, Object> ();
        }
        if (path.contains('.')) {
            String objName = path.substringBefore('.');
            String valName = path.substringAfter('.');
            Object obj = variables.get(objName);
            if (obj == null) {
                obj = new Map<String, Object> ();
                variables.put(objName, obj);
            }
            if (valName.contains('.')) {
                //more child
                putValueByPath((Map<String, Object>) obj, valName, value);
                return variables;
            } else {
                ((Map<String, Object>) obj).put(valName, value);
            }
        } else {
            variables.put(path, value);
        }
        return variables;
    }
    
    public static String convStr(String val, Boolean isNum) {
        if (val == null) {
            if (isNum) {
                return '0';
            }
            else {
                return '';
            }
        }
        else {
            return val;
        }
    }
    
    public static String sendData(String childInterfaceName, Map<String,Object> interfaceData) {
        String messageReceived = '';
        // find conversion mapping from child interface
        List<SCC_Interface_Operation_Setting__mdt> findConversionMapList = [SELECT DeveloperName, Msg_Mapping__r.DeveloperName FROM SCC_Interface_Operation_Setting__mdt WHERE SCC_Interface_Operation_Setting__mdt.DeveloperName = :childInterfaceName LIMIT 1];
        if(findConversionMapList.size()>0 ){
        	String findConversionMap = findConversionMapList[0].Msg_Mapping__r.DeveloperName; 
        
        	system.debug('findConversionMap**'+findConversionMap);
         	system.debug('InterfaceData**'+interfaceData);
        	// call the GenerateMessage method to get the message
        
        	String messageGenerated = generateMessage(findConversionMap, interfaceData);
        
			system.debug( ' *** Request ==> ' + messageGenerated);
             
            messageReceived = makeCallout(childInterfaceName, MessageGenerated);
            System.debug('@@@@MessageReceived -->'+messageReceived);
       	}
        return messageReceived;
    }

    public static String makeCallout(string subApiConfig, String requestBodyMsg){
        String rawBody = '';
        SCC_Interface_Operation_Setting__mdt interfaceSetting = [SELECT Interface_Configuration__r.DeveloperName, 
                                                                Interface_Configuration__r.Main_URL__c,
                                                                Test_Mode__c, 
                                                                IDCC_ClientID__c, 
                                                                IDCC_Password__c,
                                                                IDCC_Content_Type__c, 
                                                                response_message_field__c,
                                                                Interface_Configuration__r.test_mode__c, 
                                                                Interface_Configuration__r.test_exception__c,
                                                                DeveloperName, 
                                                                http_code_field__c, 
                                                                Sub_URL__c, 
                                                                Test_Data__c, 
                                                                Update_Method_overwrite__c, 
                                                                HTTP_Method__c,
                                                                Interface_Configuration__r.Named_Credential__c, 
                                                                Correlation_ID__c,
                                                                Timeout__c
                                                                FROM SCC_Interface_Operation_Setting__mdt WHERE DeveloperName=:subApiConfig LIMIT 1];
        
        String urlEndpoint = 'callout:'+interfaceSetting.Interface_Configuration__r.Named_Credential__c + interfaceSetting.Sub_URL__c;
        system.debug('Endpoint >> ' + urlEndpoint);
        
        // check to ensure a callout can be performed using the Limits class
        if (Limits.getCallouts() >= Limits.getLimitCallouts()){
            throw new MyException('The maximum number of callouts has been reached.');
        }   
        // instantiate a new http object 
        Http h = new Http();
        // instantiate a new HTTP request and response 
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        // configure the request
        req.setEndpoint(urlEndpoint);
        req.setTimeout(60000);
        System.debug('Request URL >> ' + urlEndpoint);
        
        req.setMethod(interfaceSetting.HTTP_Method__c);
        System.debug('httpMethod >> ' + interfaceSetting.HTTP_Method__c);

        req.setTimeout(Integer.valueOf(interfaceSetting.Timeout__c));
        System.debug('Timeout >> ' + interfaceSetting.Timeout__c);

        req.setHeader('Content-Type', interfaceSetting.IDCC_Content_Type__c);
        
        if( interfaceSetting.HTTP_Method__c == 'POST'){
            rawBody = JSON.serialize(JSON.deserializeUntyped(requestBodyMsg));
            rawBody = String.Valueof(rawBody);
            req.setBody(rawbody);
        }
        
        system.debug('This is the raw request body: ==> ' + rawBody);
            
        // Attempt the callout - create return error on exception
        String responseBody = '';
        try {
            Integer statusCode;
            String correlationId = '';

            // start of actual http callout if testMode is off 
            if(interfaceSetting.Test_Mode__c) {
                responseBody = interfaceSetting.Test_Data__c;
                statusCode = 200;
            } else {
                res = h.send(req);
                statusCode = res.getStatusCode();
                responseBody = res.getBody();
                if (String.isNotBlank(interfaceSetting.Correlation_ID__c)) {
                    correlationId = res.getHeader(interfaceSetting.Correlation_ID__c);
                }
                System.debug('Correlation ID >> '+correlationId);
            }
            
            system.debug('statusCode: ==> ' + statusCode);
            system.debug('This is the Response Raw body: ==> ' + responseBody);
            SCC_API.InsertErrorLog(null,req,res,new SCC_API.WrapperError(urlEndpoint,'SCC_IntegrationUtility')); 
            if(statusCode >= 300) {
                // errors with HTTP status code for review 
                throw new MyException('Client-side error encountered when sending a request, with HTTP status code:' + statusCode);
            } 
        } catch (System.CalloutException e) {
            SCC_API.InsertErrorLog(e,req,res,new SCC_API.WrapperError(urlEndpoint,'SCC_IntegrationUtility')); 
            throw new MyException('System.CalloutException: ' + e.getMessage());
        } catch (Exception e) {
            // other unexpected exceptions will be caught here
            SCC_API.InsertErrorLog(e,req,res,new SCC_API.WrapperError(urlEndpoint,'SCC_IntegrationUtility')); 
            System.debug('line number: '+e.getLineNumber());
            System.debug('Exception: '+e.getMessage());
        }
        
        return responseBody;
    }
}