/**
* 
* @description Batchable class for Data Masking utilizing the SBX_DataMaskIterator
* to query all the fields configured for masking in Data_Masking_Configuration__mdt and 
* performing the masking according to their masking rule.
*/
global with sharing class SBX_BatchMaskSandboxData implements Database.Batchable<SObject>,Database.Stateful {
    
    List<String> queryList { get; set; }
    //Map to store object + field name as key and its masking rule as value
    Map<String, Data_Masking_Configuration__mdt> fieldMaskingRules { get; set; }
    Integer runCount { get; set; }
    
    global SBX_BatchMaskSandboxData() {
        
        //Logic to populate Rules
        fieldMaskingRules = new Map<String, Data_Masking_Configuration__mdt> ();
        runCount=0;
        queryList = new List<String>();
        
        //Iterate over custom metadata records
        for (Data_Masking_Configuration__mdt config :[SELECT MasterLabel, QualifiedApiName, ObjectName__r.QualifiedAPIName, FieldName__r.QualifiedAPIName, MaskingRule__c, MaskingText__c FROM Data_Masking_Configuration__mdt limit 10000]) {
            fieldMaskingRules.put(config.ObjectName__r.QualifiedAPIName + '_' + config.FieldName__r.QualifiedAPIName, config);
        }
        //System.debug('<<<fieldMaskingRules>>>' + fieldMaskingRules);
        
    }
    
    /**
    * @description gets invoked when the batch job starts
    * @param context contains the job ID
    * @returns the record set as a QueryLocator object that will be batched for execution
    */
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        queryList = getSOQLQueries();
        //System.debug('<<<<runCount in start>>>>'+runCount);
        //System.debug('<<<<queryList in start>>>>'+queryList.size());
        return Database.getQueryLocator(queryList.get(runCount));
    }
    
    global List<String> getSOQLQueries(){
        List<String> queries = new List<String>();
        // Map from SObject to List of Fields from Custom Metadata that needs to be data masked.
        Map<String, List<Data_Masking_Configuration__mdt>> dataMaskFieldMap = new  Map<String, List<Data_Masking_Configuration__mdt>>();
        dataMaskFieldMap = getDataMaskFields();
        // Iterate over the SObject to Fields collection
        for (String objectName : dataMaskFieldMap.keySet()) {
            // Build a list of all fields that need to be queried
            List<Data_Masking_Configuration__mdt> dataMaskConfig = dataMaskFieldMap.get(objectName);
            List<String> fieldList = new List<String> ();
            Map<String, Data_Masking_Configuration__mdt> fieldMaskingRules = new Map<String, Data_Masking_Configuration__mdt> ();
            for (Data_Masking_Configuration__mdt config : dataMaskConfig) {
                fieldList.add(config.FieldName__r.QualifiedAPIName);
                dataMaskFieldMap.put(config.ObjectName__r.QualifiedAPIName + '_' + config.FieldName__r.QualifiedAPIName, new List<Data_Masking_Configuration__mdt> {
                    config
                        });
                
            }
            // Generate a SOQL query to get records with non null emails
            String soql = getSOQL(objectName, fieldList);
            System.debug(soql);
            queries.add(soql);
        }
        return queries;
    }
    
    /*
    * Helper method to iterate over all fields and return Sobject
    */
    global static String getSOQL(String objectTypeName, List<String> fieldList) {
        List<String> conditionals = new List<String> ();
        
        String soql = 'SELECT {!fieldList} FROM {!objectTypeName}';
        return soql
            .replace('{!fieldList}', String.join(fieldList, ','))
            .replace('{!objectTypeName}', objectTypeName)
            .replace('{!conditionals}', String.join(conditionals, ' OR '));
    }
    
    /*
    * Helper method to query Data Masking COnfigurations
    */
    private static Map<String, List<Data_Masking_Configuration__mdt>> getDataMaskFields() {
        Map<String, List<Data_Masking_Configuration__mdt>> dataMaskFieldMap = new Map<String, List<Data_Masking_Configuration__mdt>> ();
        //Iterate over custom metadata records
        for (Data_Masking_Configuration__mdt config :[SELECT MasterLabel, QualifiedApiName, ObjectName__r.QualifiedAPIName, FieldName__r.QualifiedAPIName, MaskingRule__c, MaskingText__c FROM Data_Masking_Configuration__mdt limit 10000]) {
            if (dataMaskFieldMap.containsKey(config.ObjectName__r.QualifiedAPIName)) {
                dataMaskFieldMap.get(config.ObjectName__r.QualifiedAPIName).add(config);
            } else {
                dataMaskFieldMap.put(config.ObjectName__r.QualifiedAPIName, new List<Data_Masking_Configuration__mdt> {
                    config
                        });
            }
        }
        return dataMaskFieldMap;
    }
    /**
    * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
    * @param context contains the job ID
    * @param scope contains the batch of records to process.
    */
    global void execute(Database.BatchableContext context, List<sobject> scope) {
        List<SObject> recordsToUpdate = new List<SObject>();
        scope.sort();
        // Iterate over queried SObject records
        for (SObject record : scope) {
            //Get the list of fields in the Sobject
            Map<String, Object> fieldsToValue = record.getPopulatedFieldsAsMap();
            //System.debug('<<<<fieldsToValue>>>>' + fieldsToValue);
            // Iterate over data masking fields found on SObject and invalidate values
            for (String field : fieldsToValue.keySet()) {
                if (field != 'Id') {
                    String fieldValue = String.valueOf(record.get(field));
                    String fieldObjectLabel = record.getSObjectType().getDescribe().getName();
                    //System.debug('<<<<fieldObjectLabel>>>>' + fieldObjectLabel);
                    //System.debug('<<<<fieldValue>>>>' + fieldValue);
                    
                    if (String.isEmpty(fieldValue)) continue;
                    //From the map of masking rule, obtain the rule and the text that needs to be applied to the data.
                    String maskingRule = fieldMaskingRules.get(fieldObjectLabel + '_' + field).MaskingRule__c;
                    String maskingText = fieldMaskingRules.get(fieldObjectLabel + '_' + field).MaskingText__c;
                    
                    //System.debug('<<<<field value before replace>>>>' + fieldValue);
                    String replacedContent = '';
                    
                    switch on maskingRule {
                        when 'Random String' {
                            String scrambledText = generateRandomString(fieldValue.SubStringBefore(' ').length());
                            //Logic to set Contact First and Last Name
                            //This is needed since custom metadata type doesn't support selecting Contact First and Last Name fields.
                            if (fieldObjectLabel == 'Contact' && field == 'Name') {
                                record.put('FirstName', scrambledText);
                                record.put('LastName', scrambledText);
                            }
                            else {
                                record.put(field, scrambledText);
                            }
                            replacedContent = scrambledText;
                        }
                        when 'Random Date' {
                            //System.debug('Random Date');
                            //Generate Random Integers to Add to a Date
                            Integer daysToAdd = Math.round(Math.random() * 1000);
                            Integer monthsToAdd = Math.mod(Math.round(Math.random() * 1000), 12);
                            Integer yearToAdd = Math.mod(Math.round(Math.random() * 1000), 50);
                            
                            //Get the current Date value 
                            Date currentDateValue = (Date) record.get(field);
                            
                            //Generate Random dates by adding random numbers to the date
                            Date randomDate;
                            randomDate = currentDateValue.addDays(daysToAdd);
                            randomDate = randomDate.addMonths(monthsToAdd);
                            randomDate = randomDate.addYears(yearToAdd);
                            record.put(field, randomDate);
                            replacedContent = String.valueof(randomDate);
                        }
                        when 'Random Phone' {
                            //System.debug('Random Phone');
                            //Generate a Random 10 digit phone number
                            String randomPhoneNum = String.valueof(Math.abs(crypto.getRandomLong())).substring(0, 10);
                            //Logic to set Contact Phone Field as well. 
                            //This is needed since custom metadata type doesn't support selecting Contact Phone field.
                            if (fieldObjectLabel == 'Contact' && field == 'MobilePhone') {
                                record.put('MobilePhone', randomPhoneNum);
                                record.put('Phone', randomPhoneNum);
                            }
                            else {
                                record.put(field, randomPhoneNum);
                            }
                            replacedContent = randomPhoneNum;
                        }
                        when 'Random Email' {
                            String scrambledText = generateRandomEmail(10,fieldValue);
                            record.put(field, scrambledText +'@'+scrambledText+'.data');
                            replacedContent = scrambledText +'@'+scrambledText+'.data';
                        }
                        when else { // default block, optional
                            System.debug('Custom String');
                            if(fieldObjectLabel == 'Contact' && field == 'MailingAddress'){
                                record.put('MailingStreet', maskingText);
                            }
                            else if(fieldObjectLabel == 'Contact' &&  field=='OtherAddress'){
                                record.put('OtherStreet', maskingText);
                            }
                            else{
                                record.put(field, maskingText);
                            }
                            replacedContent = maskingText;
                        }
                    }
                    //System.debug('<<<<field value after replace>>>>' + replacedContent);
                }
                
            }
            recordsToUpdate.add(record);
        }
        recordsToUpdate.sort();
        //System.debug('<<<<update set size>>>'+recordsToUpdate.size());
        update recordsToUpdate;
    }
    
    /**
    * @description gets invoked when the batch job finishes. Place any clean up code in this method.
    * @param context contains the job ID
    */
    global void finish(Database.BatchableContext context) {
        //System.debug('<<<<Completed Data Masking>>>');
        runCount ++;
        if(runCount < queryList.size()) {
            Database.executeBatch(this, 200);
            //System.debug('<<<<queryList in finish>>>'+queryList.get(0));
        }
        else{
            SBX_PostCopyUtil.createLogObj('SBX_BatchMaskSandboxData', null);
        }
    }
    /**
    * @description Helper method to generate a random character sequence for the specified Length.
    * @param Length on the random string needed.
    */
    public String generateRandomString(Integer len) {
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String[] result = new String[len];
        Integer idx = 0;
        while (idx<len) {
            Integer chr = Math.mod(Math.abs(Crypto.getRandomInteger()), 52);
            result[idx++] = chars.substring(chr, chr + 1);
        }
        return String.join(result, '');
    }
    
    /**
    * @description Helper method to generate a random character sequence for the specified Length.
    * @param Length on the random string needed.
    */
    public String generateRandomEmail(Integer len, String emailId) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        String randomEmail = key.substring(0,len);
        return randomEmail;
    }    
    
}