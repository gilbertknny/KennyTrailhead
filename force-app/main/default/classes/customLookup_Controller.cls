public with sharing class customLookup_Controller {
    @AuraEnabled(cacheable=true)
    public static List<LookupResult> searchRecords(String objectApiName, String fields, String searchKey, String recordTypeName, String provinceId, String cityId, String sectionName, String showData) {
        System.debug('showData:' + showData);
        List<Object> parsedShowData = new List<Object>();
        if (String.isNotBlank(showData)) {
            parsedShowData = (List<Object>) JSON.deserializeUntyped(showData);
        }
        Set<String> extraFields = new Set<String>();

        for (Object obj : parsedShowData) {
            Map<String, Object> fieldMap = (Map<String, Object>) obj;
            if (fieldMap.containsKey('param2') && String.isNotBlank((String)fieldMap.get('param2'))) {
                extraFields.add((String)fieldMap.get('param2'));
            }
        }

        // 🔹 Merge fields + extra param2 fields
        String fullFields = fields;
        if (!extraFields.isEmpty()) {
            fullFields += ', ' + String.join(new List<String>(extraFields), ', ');
        }
        
        String likePattern = '%' + searchKey + '%';

        String query = 'SELECT Id,' + fullFields  +
                    ' FROM ' + objectApiName +
                    ' WHERE';

        if (recordTypeName == 'Object Insured' && objectApiName == 'Master_Data__c') {
            if(String.isBlank(sectionName)){
                query += ' Section_Title__c LIKE :likePattern';
            } else {
                query += ' Name LIKE :likePattern AND Section_Title__c = :sectionName';
            }
        } else {
            query += ' Name LIKE :likePattern';
        }

        if (String.isNotBlank(recordTypeName)) {
            query += ' AND RecordType.Name = :recordTypeName';
        }
        
        if (recordTypeName == 'City' && provinceId != null) {
            query += ' AND Province__c = :provinceId';
        }

        if (recordTypeName == 'Address' && cityId != null) {
            query += ' AND City__c = :cityId';
        }

        query += ' LIMIT 10';

        System.debug('Dynamic Query: ' + query);

        List<sObject> sobjs = Database.query(query);


        System.debug('recordTypeName: ' + recordTypeName);
        if (recordTypeName == 'City') {
            return formatLookupSubtitle_City(sobjs, showData);
        } else if (recordTypeName == 'Address') {
            return formatLookupSubtitle_Address(sobjs, showData);
        } else if (recordTypeName == 'Province') {
            return formatLookupSubtitle_Province(sobjs, showData);
        } else if (recordTypeName == 'Exchange Rate') {
            return formatLookupSubtitle_ExchangeRate(sobjs, showData);
        } else if (recordTypeName == 'Coverage' && objectApiName == 'Master_Data__c') {
            return formatLookupSubtitle_Coverage(sobjs, showData);
        }

        else {
            // Default generic formatter (just Name)
            return formatLookupSubtitle_Default(sobjs, showData, objectApiName);
        } 
    }

    public class LookupResult {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String Subtitle { get; set; }
        @AuraEnabled public Map<String, Object> fieldMap { get; set; } 
    }

    private static List<LookupResult> formatLookupSubtitle_Province(List<sObject> sobjs, String showData) {
        List<LookupResult> results = new List<LookupResult>();

        for (sObject sobj : sobjs) {
            LookupResult res = new LookupResult();
            res.Id = (Id)sobj.get('Id');
            res.Name = (String)sobj.get('Name');

            String country  = sobj.getSObject('Country__r') != null 
                                ? (String)sobj.getSObject('Country__r').get('Name') 
                                : null;

            List<String> parts = new List<String>();
            if (country != null) parts.add(country);

            res.Subtitle = String.join(parts, ' • ');
            if(String.isNotBlank(showData)){
                res.fieldMap = extractFieldMap(sobj, showData);
            }
            results.add(res);
        }

        return results;
    }

    private static List<LookupResult> formatLookupSubtitle_City(List<sObject> sobjs, String showData) {
        List<LookupResult> results = new List<LookupResult>();

        for (sObject sobj : sobjs) {
            LookupResult res = new LookupResult();
            res.Id = (Id)sobj.get('Id');
            res.Name = (String)sobj.get('Name');

            String country  = sobj.getSObject('Country__r') != null 
                                ? (String)sobj.getSObject('Country__r').get('Name') 
                                : null;
            String province = sobj.getSObject('Province__r') != null 
                                ? (String)sobj.getSObject('Province__r').get('Name') 
                                : null;

            List<String> parts = new List<String>();
            if (province != null) parts.add(province);
            if (country != null) parts.add(country);

            res.Subtitle = String.join(parts, ' • ');
            if(String.isNotBlank(showData)){
                res.fieldMap = extractFieldMap(sobj, showData);
            }
            results.add(res);
        }

        return results;
    }

    private static List<LookupResult> formatLookupSubtitle_Address(List<sObject> sobjs, String showData) {
        List<LookupResult> results = new List<LookupResult>();

        System.debug('Show Data Address: ' + showData);
        for (sObject sobj : sobjs) {
            LookupResult res = new LookupResult();
            res.Id = (Id)sobj.get('Id');
            res.Name = (String)sobj.get('Name');

            String cityId  = sobj.getSObject('City__r') != null 
                                ? (String)sobj.getSObject('City__r').get('Name') 
                                : null;
            String zipCode = sobj.getSObject('Zip_Code__r') != null 
                                ? (String)sobj.getSObject('Zip_Code__r').get('Name') 
                                : null;

            List<String> parts = new List<String>();
            if (cityId != null) parts.add(cityId);
            if (zipCode != null) parts.add(zipCode);

            res.Subtitle = String.join(parts, ' • ');
            if(String.isNotBlank(showData)){
                res.fieldMap = extractFieldMap(sobj, showData);
            }
            System.debug('Show Data Address: ' + results);
            results.add(res);
        }

        return results;
    }

    private static List<LookupResult> formatLookupSubtitle_Coverage(List<sObject> sobjs, String showData) {
        List<LookupResult> results = new List<LookupResult>();
        for (sObject sobj : sobjs) {
            LookupResult res = new LookupResult();
            res.Id = (Id)sobj.get('Id');
            res.Name = (String)sobj.get('Name');
            res.Subtitle = (String)sobj.get('COVERAGE_REF_ID__c');
            if(String.isNotBlank(showData)){
                res.fieldMap = extractFieldMap(sobj, showData);
            }
            results.add(res);
        }
        return results;
    }

    // Default (only Name)
    private static List<LookupResult> formatLookupSubtitle_Default(List<sObject> sobjs, String showData, String objectApiName) {
        List<LookupResult> results = new List<LookupResult>();
        for (sObject sobj : sobjs) {
            LookupResult res = new LookupResult();
            res.Id = (Id)sobj.get('Id');
            res.Name = (String)sobj.get('Name');
            res.Subtitle = objectApiName;
            if(String.isNotBlank(showData)){
                res.fieldMap = extractFieldMap(sobj, showData);
            }
            results.add(res);
        }
        return results;
    }

    private static List<LookupResult> formatLookupSubtitle_ExchangeRate(List<sObject> sobjs, String showData) {
        List<LookupResult> results = new List<LookupResult>();
        System.debug('formatLookupSubtitle_ExchangeRate');
        
        for (sObject sobj : sobjs) {
            LookupResult res = new LookupResult();
            res.Id = (Id)sobj.get('Id');
            res.Name = (String)sobj.get('Name');
            res.Subtitle = String.valueOf(sobj.get('Exchange_rate__c'));
            if(String.isNotBlank(showData)){
                res.fieldMap = extractFieldMap(sobj, showData);
            }
            results.add(res);
        }

        return results;
    }

    @AuraEnabled(cacheable=true)
    public static SObject getRecordById(String objectApiName, Id recordId, String recordTypeName) {
        system.debug('objectApiName: ' + objectApiName);
        system.debug('recordId: ' + recordId);
        system.debug('recordTypeName: ' + recordTypeName);
        String query = 'SELECT Id, Name, RecordType.Name FROM ' + objectApiName + ' WHERE Id = :recordId LIMIT 1';
        SObject rec = Database.query(query);

        if (recordTypeName != null && ((String)rec.getSObject('RecordType').get('Name')) != recordTypeName) {
            System.debug('Masuk Sini' + (String)rec.getSObject('RecordType').get('Name'));
            return null; // prevent mixing Province/City/Address
        }
        return rec;
    }

    private static Map<String, Object> extractFieldMap(sObject sobj, String showData) {
        Map<String, Object> result = new Map<String, Object>();

        // Parse once per record
        List<Object> parsedShowData = (List<Object>) JSON.deserializeUntyped(showData);

        for (Object obj : parsedShowData) {
            Map<String, Object> fieldDef = (Map<String, Object>) obj;
            String param1 = (String) fieldDef.get('param1');
            String param2 = (String) fieldDef.get('param2');

            if (String.isNotBlank(param1) && String.isNotBlank(param2)) {
                if (sobj.get(param2) != null) {
                    result.put(param1, sobj.get(param2)); // ✅ Use param1 as the key
                }
            }
        }
        return result;
    }
}