/**
 * @description       : Controller for LWC Detail Asset
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 11-10-2025
 * @last modified by  : Williams
**/
public with sharing class Aswata_Add_New_DetailAsset_Controller {
    private static final String MASTER_DATA_OBJECT_API = 'Master_Data__c';
    private static final String DETAIL_ASSET_NAME = 'Detail Asset';
    private static final String RECORD_TYPE_NAME = 'Asset';
    /**
     * @description function for save data asset
     * @param formData contains data from LWC
     * @return String Id asset
     */
    @AuraEnabled
    public static String saveDetailAsset(Map<String, Object> formData) {
        if (formData == null || formData.isEmpty()) {
            throw new AuraHandledException('No data provided to save.');
        }
        String recordId = (formData.containsKey('Id')) ? (String)formData.get('Id') : null;
        Boolean isUpdate = (recordId != null && recordId != '');
        // Get Record Type (if needed for new record) and Asset
        Asset record = initializeAssetRecord(formData, isUpdate);
        // Map fields from formData
        record = mapFormDataToAsset(formData, record);
        // InsertorUpdate Asset
        return performDML(record, isUpdate);
        // RecordType recordType;
        // if (!isUpdate) {
        //     recordType = [
        //         SELECT Id
        //         FROM RecordType
        //         WHERE SobjectType = :RECORD_TYPE_NAME
        //         AND Name = :RECORD_TYPE_NAME
        //         WITH SECURITY_ENFORCED
        //         LIMIT 1
        //     ];
        // }
        // Asset record;
        // if (isUpdate) {
        //     record = [SELECT Id FROM Asset WHERE Id = :recordId WITH SECURITY_ENFORCED LIMIT 1];
        // } else {
        //     record = new Asset();
        //     record.put('RecordTypeId', recordType.Id);
        // }
        // Map fields from formData
        // for (String fieldApi : formData.keySet()) {
        //     if (fieldApi == 'Id') {
        //         continue; // Skip Id field
        //     }
        //     Object value = formData.get(fieldApi);
        //     if (value == null) {
        //         continue;
        //     }
        //     try {
        //         // Handle numeric conversion for String values
        //         if ((fieldApi == 'Exchange_Rate__c'
        //             || fieldApi == 'Amount__c'
        //             || fieldApi == 'Amount_IDR__c'
        //             || fieldApi == 'Declare_Value__c'
        //             || fieldApi == 'Amount_Insured__c')
        //             && value instanceof String) {
        //             record.put(fieldApi, Decimal.valueOf((String)value));
        //         } else {
        //             record.put(fieldApi, value);
        //         }
        //     } catch (Exception e) {
        //         throw new AuraHandledException('Failed to set field: ' + fieldApi + ': ' + e.getMessage());
        //     }
        // }
        
        // try {
        //     if (!Schema.sObjectType.Asset.isAccessible()) {
        //         throw new SecurityException('Insufficient permissions to access Master_Data__c');
        //     }
        //     if (isUpdate) {
        //         update record;
        //     } else {
        //         insert record;
        //     }
        //     return record.Id;
        // } catch (Exception e) {
        //     throw new AuraHandledException('Error saving Asset: ' + e.getMessage());
        // }
    }
    /**
     * @description to get AssetRecord is Existing/New
     * @param formData = data Map
     * @param isUpdate = boolean
     * @return Asset object
     */
    private static Asset initializeAssetRecord(Map<String, Object> formData, Boolean isUpdate) {
        if (isUpdate) {
            return [SELECT Id FROM Asset WHERE Id = :(String)formData.get('Id') WITH SECURITY_ENFORCED LIMIT 1]; // NCSS: 1
        } else {
            RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = :RECORD_TYPE_NAME
                AND Name = :RECORD_TYPE_NAME
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            String mdId = (String)formData.get('Section__c');
            Master_Data__c getCategory = [
                SELECT Id,name,Section__c,Asset_Category_Value__c
                FROM Master_Data__c
                WHERE id = :mdId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Asset newRecord = new Asset();
            newRecord.put('RecordTypeId', rt.Id);
            newRecord.put('Risk_Detail_Flag__c', getCategory.Asset_Category_Value__c);
            return newRecord;
        }
    }
    /**
     * @description to generate record Asset
     * @param formData = data Map
     * @param record = Asset record will be update
     * @return Asset object
     */
    private static Asset mapFormDataToAsset(Map<String, Object> formData, Asset record) {
        // Asset updateData = record;
        Set<String> numericFields = new Set<String>{
            'Exchange_Rate__c', 'Amount__c', 'Amount_IDR__c', 'Declare_Value__c', 'Amount_Insured__c'
        };

        for (String fieldApi : formData.keySet()) {
            if (fieldApi == 'Id') {
                continue;
            }
            Object value = formData.get(fieldApi);
            if (value == null) {
                continue;
            }
            try {
                if (numericFields.contains(fieldApi) && value instanceof String) {
                    // Handle numeric conversion for String values
                    record.put(fieldApi, Decimal.valueOf((String)value));
                } else {
                    record.put(fieldApi, value);
                }
            } catch (Exception e) {
                throw new AuraHandledException('Failed to set field: ' + fieldApi + ': ' + e.getMessage()); // NCSS: 11
            }
        }
        return record;
    }
    /**
     * @description to perform DML Insert or Update data Asset
     * @param record = Asset record will be update
     * @param isUpdate = boolean
     * @return String Id Asset
     */
    private static String performDML(Asset record, Boolean isUpdate) {
        if (!Schema.sObjectType.Asset.isAccessible()
            && !Schema.sObjectType.Asset.isUpdateable()
            && !Schema.sObjectType.Asset.isCreateable()){
            throw new SecurityException('Insufficient permissions to access or modify Asset record.');
        }
        try {
            if (isUpdate) {
                Database.update(record, AccessLevel.USER_MODE);
            } else {
                Database.insert(record, AccessLevel.USER_MODE);
            }
            return record.Id;
        } catch (Exception e) {
            throw new AuraHandledException('An unexpected error occurred during save: ' + e.getMessage()); // NCSS: 14
        }
    }
    /**
     * @description get section based on title and COB
     * @param titleValue = Title Section
     * @param cobValue = COB
     * @return List<String> return list section
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getSections(String titleValue,String cobValue) {
        String assetSection = 'Asset Section';
        RecordType rtSection = [
            SELECT Id FROM RecordType
            WHERE SobjectType = 'Master_Data__c' AND Name = :assetSection
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        // Get Product2 Id COB
        Product2 idProductCob = [SELECT Id, Name FROM product2 WHERE ProductCode = :cobValue WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('idProductCob'+idProductCob);
        // Get AssetSection Id titleValue
        Master_Data__c idAssetSection = [SELECT Id, Name FROM Master_Data__c WHERE Name = :titleValue WITH SECURITY_ENFORCED LIMIT 1];
        System.debug('idAssetSection'+idAssetSection);
        
        // Master_Data__c Section Get
        RecordType recordType = [SELECT Id, Name FROM RecordType where SobjectType = :MASTER_DATA_OBJECT_API and Name = :DETAIL_ASSET_NAME WITH SECURITY_ENFORCED LIMIT 1];
        // List<DynamicFieldConfig> results = new List<DynamicFieldConfig>();
        // List<Master_Data__c> listField = [
        //     SELECT Name,Section__c,BSN_ID__c , Label__c, Data_Type__c, Lookup_Object__c, Filter__c,
        //            Status__c, Object__c, Order__c, showData__c
        //     FROM Master_Data__c
        //     WHERE Status__c = 'Active'AND RecordTypeId = :recordType.Id
        //     AND BSN_ID__c = :cobValue
        //     WITH SECURITY_ENFORCED
        //     ORDER BY Order__c ASC
        // ];

        Set<String> results = new Set<String>();
        List<Master_Data__c> configs = [
            SELECT 
            Section__c, Name, BSN__c,
            Asset_Section__c, Asset_Section__r.Section__c
            FROM Master_Data__c
            WHERE BSN__c = :idProductCob.Id AND  Asset_Section__c = :idAssetSection.Id
        ];
        System.debug('configs'+configs[0].Asset_Section__r.Section__c);
        for (Master_Data__c master : configs) {
            if (master.Asset_Section__r.Section__c != null) {
                results.add(String.valueOf(master.Asset_Section__r.Section__c));
            }
        }
        // List<Master_Data__c> configs = [
        //     SELECT Section__c
        //     FROM Master_Data__c
        //     WHERE Section_Title__c = :titleValue AND BSN_ID__c = :cobValue
        //     WITH SECURITY_ENFORCED
        // ];
        // for (Master_Data__c master : configs) {
        //     if (master.Section__c != null) {
        //         results.add(String.valueOf(master.Section__c));
        //     }
        // }
        List<String> uniqueNamesList = new List<String>(results);
        return uniqueNamesList;
    }
    /**
     * @description get ActiveField for Dynamic Custom UI
     * @return List<DynamicFieldConfig> return object
     */
    @AuraEnabled(cacheable=true)
    public static List<DynamicFieldConfig> getActiveFields(String cobValue) {
        // RecordType SB : 012MS000000DSMfYAO
        RecordType recordType = [SELECT Id, Name FROM RecordType where SobjectType = :MASTER_DATA_OBJECT_API and Name = :DETAIL_ASSET_NAME WITH SECURITY_ENFORCED LIMIT 1];
        List<DynamicFieldConfig> results = new List<DynamicFieldConfig>();
        List<Master_Data__c> configs = [
            SELECT Name,Section__c,BSN_ID__c , Label__c, Data_Type__c, Lookup_Object__c, Filter__c,
                   Status__c, Object__c, Order__c, showData__c
            FROM Master_Data__c
            WHERE Status__c = 'Active'AND RecordTypeId = :recordType.Id
            AND BSN_ID__c = :cobValue
            WITH SECURITY_ENFORCED
            ORDER BY Order__c ASC
        ];
        
        for (Master_Data__c cfg : configs) {
            DynamicFieldConfig dcf = new DynamicFieldConfig();
            dcf.apiName = cfg.Name;
            dcf.section = cfg.Section__c;
            dcf.label = cfg.Label__c;
            dcf.dataType = cfg.Data_Type__c;
            dcf.lookupObject = cfg.Lookup_Object__c;
            dcf.filter = cfg.Filter__c;
            dcf.showData = cfg.showData__c;
            results.add(dcf);
        }
        return results;
    }
    /**
     * @description Class for dynamicFieldConfig
     */
    public class DynamicFieldConfig {
        /**
         * @description ApiName
         */
        @AuraEnabled public String apiName {get;set;}
        /**
         * @description Section
         */
        @AuraEnabled public Decimal section {get;set;}
        /**
         * @description Label
         */
        @AuraEnabled public String label {get;set;}
        /**
         * @description dataType
         */
        @AuraEnabled public String dataType {get;set;}
        /**
         * @description lookupObject
         */
        @AuraEnabled public String lookupObject {get;set;}
        /**
         * @description filter
         */
        @AuraEnabled public String filter {get;set;}
        /**
         * @description showData
         */
        @AuraEnabled public String showData {get;set;}
    }

    /**
     * @description function for get detail asset
     * @param detailAssetId id of asset
     * @return Map<String, Object>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDetailAssetData(String detailAssetId) {
        if (detailAssetId == null) {
            return new Map<String, Object>();
        }
        Asset detailAsset = [
            SELECT Id,
                Name,
                Currency__c,
                Exchange_Rate__c,
                Amount__c,
                Amount_IDR__c,
                Category_ID__c,
                Section_ID__c,
                Interest_Insured_Detail_Description__c,
                Declare_Value__c,
                Indemnity_Type__c,
                Amount_Insured__c,
                ParentId,
                Parent.COB__c,
                Category__c,
                Section__c,
                Section__r.Name,
                Section__r.Section__c,
                Section__r.Section_Title__c
            FROM Asset
            WHERE Id = :detailAssetId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        // Convert the Asset record into a map for easy use in LWC
        Map<String, Object> result = new Map<String, Object>();
        result.put('Id', detailAsset.Id);
        result.put('Name', detailAsset.Name);
        result.put('Currency__c', detailAsset.Currency__c);
        result.put('Exchange_Rate__c', detailAsset.Exchange_Rate__c);
        result.put('Amount__c', detailAsset.Amount__c);
        result.put('Amount_IDR__c', detailAsset.Amount_IDR__c);
        result.put('Category_ID__c', detailAsset.Category_ID__c);
        result.put('Section_ID__c', detailAsset.Section_ID__c);
        result.put('Interest_Insured_Detail_Description__c', detailAsset.Interest_Insured_Detail_Description__c);
        result.put('Declare_Value__c', detailAsset.Declare_Value__c);
        result.put('Indemnity_Type__c', detailAsset.Indemnity_Type__c);
        result.put('Amount_Insured__c', detailAsset.Amount_Insured__c);
        result.put('ParentId', detailAsset.ParentId);
        result.put('COB__c', detailAsset.Parent.COB__c);
        result.put('Category__c', detailAsset.Category__c);
        result.put('Section__c', detailAsset.Section__c);

        if (detailAsset.Section__c != null) {
            result.put('Section_Name__c', detailAsset.Section__r.Name);
            result.put('Section_Title__c', detailAsset.Section__r.Section_Title__c);
        }
        
        return result;
    }
}