/**
 * @description       : Controller for LWC Detail Asset
 * @author            : Ahmad Yazid Munif
 * @last modified on  : 12-18-2025
 * @last modified by  : Ahmad Yazid Munif
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
    }
    /**
     * @description to get AssetRecord is Existing/New
     * @param formData = data Map
     * @param isUpdate = boolean
     * @return Asset object
     */
    private static Asset initializeAssetRecord(Map<String, Object> formData, Boolean isUpdate) {
        if (isUpdate) {
            return [SELECT Id,Opportunity__c FROM Asset WHERE Id = :(String)formData.get('Id') WITH SECURITY_ENFORCED LIMIT 1];
        } else {
            RecordType rt = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = :RECORD_TYPE_NAME
                AND Name = :RECORD_TYPE_NAME
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];
            Asset newRecord = new Asset();
            newRecord.put('RecordTypeId', rt.Id);
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
            if (value == null && fieldApi != 'Declare_Value__c') {
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
        // if (!Schema.sObjectType.Asset.isAccessible()
        //     && !Schema.sObjectType.Asset.isUpdateable()
        //     && !Schema.sObjectType.Asset.isCreateable()){
        //     throw new SecurityException('Insufficient permissions to access or modify Asset record.');
        // }
        if (!checkPermission()) {
            throw new SecurityException('Insufficient permissions to access or modify Asset record.');
        }
        try {
            if (isUpdate) {
                Database.update(record, AccessLevel.USER_MODE);
            } else {
                Decimal newRiskNumber = 1;
                if(record.Opportunity__c != null){
                    // System.debug('record.Opportunity__c'+record.Opportunity__c);
                    String policyId = Aswata_GlobalFunction.createInsurancePolicy(record.Opportunity__c);
                    List<Asset> latestAssetList = [
                        SELECT risk_detail_id__c
                        FROM Asset WHERE Opportunity__c = :record.Opportunity__c
                        AND risk_detail_id__c != null
                        WITH SECURITY_ENFORCED
                        ORDER BY risk_detail_id__c DESC LIMIT 1
                    ];
                    if (!latestAssetList.isEmpty()) {
                        Asset latestAsset = latestAssetList[0];
                        newRiskNumber = latestAsset.risk_detail_id__c + 1;
                    }
                    record.insurance_policy__c = policyId;
                }
                record.risk_detail_id__c = newRiskNumber;
                Database.insert(record, AccessLevel.USER_MODE);
            }
            return record.Id;
        } catch (Exception e) {
            // System.debug('An unexpected error occurred during save: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred during save: ' + e.getMessage());
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
        RecordType rtSection = [
            SELECT Id FROM RecordType
            WHERE SobjectType = 'Master_Data__c' AND Name = 'Asset Section'
            WITH SECURITY_ENFORCED LIMIT 1
        ];
        Set<String> results = new Set<String>();
        List<Master_Data__c> configs = [
            SELECT
            Name, Section__c, BSN__c,
            Asset_Section__c, Asset_Section__r.Section__c, Section_Title__c, RecordType.Name
            FROM Master_Data__c
            WHERE BSN__r.ProductCode = :cobValue AND Name  = :titleValue
            AND RecordTypeId = :rtSection.Id
            WITH SECURITY_ENFORCED
        ];
        for (Master_Data__c master : configs) {
            if (master.Section__c != null) {
                results.add(String.valueOf(master.Section__c));
            }
        }
        List<String> uniqueNamesList = new List<String>(results);
        return uniqueNamesList;
    }
    /**
     * @description get ActiveField for Dynamic Custom UI
     * @param cobValue
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
        result.put('Parent_Asset__c', detailAsset.ParentId);
        result.put('COB__c', detailAsset.Parent.COB__c);
        result.put('Category__c', detailAsset.Category__c);
        result.put('Section__c', detailAsset.Section__c);
        result.put('Section_Name__c', detailAsset.Section__r.Name);
        return result;
    }

    /**
     * @description Get all detail assets for a specific Risk
     * @param riskId Id of the parent Risk record
     * @return List<Asset> List of detail assets under this Risk
     */
    @AuraEnabled(cacheable=false)
    public static List<Asset> getDetailAssetsByRisk(Id riskId) {
        try {
            if (riskId == null) {
                return new List<Asset>();
            }

            List<Asset> assets = [
                SELECT 
                    Id, 
                    Name, 
                    Interest_Insured_Detail_Description__c,
                    Section__c,
                    Section__r.Name,
                    Category__c,
                    Category__r.Name,
                    Amount_IDR__c,
                    Amount__c,
                    Currency__c,
                    Exchange_Rate__c,
                    Indemnity_Type__c,
                    Declare_Value__c,
                    Amount_Insured__c,
                    CreatedDate
                FROM Asset 
                WHERE ParentId = :riskId
                AND RecordType.Name = 'Asset'
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC
            ];
            
            System.debug('✅ Found ' + assets.size() + ' assets for Risk: ' + riskId);
            return assets;
            
        } catch (Exception e) {
            System.debug('❌ Error loading assets: ' + e.getMessage());
            throw new AuraHandledException('Error loading assets: ' + e.getMessage());
        }
    }

    /**
     * @description function for checkPermission Access
     * @return boolean accessible
     */
    public static Boolean checkPermission(){
        Boolean access = true;
        if (!Schema.sObjectType.RecordType.isAccessible() &&
            !Schema.sObjectType.Asset.isAccessible() &&
            !Schema.sObjectType.Master_Data__c.isAccessible() &&
            !Schema.sObjectType.InsurancePolicyCoverage.isCreateable() &&
            !Schema.sObjectType.Asset.isUpdateable()
        ){
            access = false;
        }
        return access;
    }
}