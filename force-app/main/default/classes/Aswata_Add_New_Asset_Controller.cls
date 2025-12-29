/**
 * -------------------------------------------------------------------------------
 * Class Name   : Aswata_Add_New_Asset_Controller
 * Author       : Fikri
 * -------------------------------------------------------------------------------
 */

public with sharing class Aswata_Add_New_Asset_Controller {
    @AuraEnabled
    public static List<AssetWrapper> getAssetsByOpportunity(String opportunityId) {
        Integer sequenceNumber = 1;

        List<AssetWrapper> results = new List<AssetWrapper>();
        List<Asset> assets = [
            SELECT 
                Id, 
                Name, 
                risk_address__c,
                Address__r.Name,
                Risk_ID__c, 
                City__r.Name, 
                Zip_Code__r.Name, 
                RecordType.Id,
                RecordType.Name
            FROM Asset 
            WHERE Opportunity__c = :opportunityId 
            AND RecordType.Name = 'Risk'
            WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];
        
        System.debug('Found ' + assets.size() + ' Risk records for Opportunity: ' + opportunityId);
        
        for (Asset a : assets) {
            AssetWrapper wrap = new AssetWrapper();
            wrap.id = a.Id;

            // ✅ Risk ID with fallback
            if(String.isNotBlank(a.Risk_ID__c)){
                wrap.riskId = a.Risk_ID__c;
            } else if (String.isNotBlank(a.Name)){
                wrap.riskId = a.Name;
            } else {
                wrap.riskId = 'RISK-' + sequenceNumber;
                sequenceNumber++;
            }

            wrap.riskName = a.Name;
            
            // ✅ Address with proper priority
            if (a.Address__r != null && String.isNotBlank(a.Address__r.Name)) {
                wrap.address = a.Address__r.Name;  // Primary: Address lookup Name
            } else if (String.isNotBlank(a.risk_address__c)) {
                wrap.address = a.risk_address__c; 
            } else {
                wrap.address = null; 
            }
            
            wrap.cityName = (a.City__r != null) ? a.City__r.Name : null;
            wrap.zipName = (a.Zip_Code__r != null) ? a.Zip_Code__r.Name : null;
            wrap.recordTypeId = a.RecordType.Id;
            
            System.debug('Wrapper created: ' + JSON.serialize(wrap));
            
            results.add(wrap);
        }

        System.debug('Returning ' + results.size() + ' Risk wrappers');
        return results;
    }

    @AuraEnabled
    public static String upsertAsset(Map<String, Object> fieldValues) {       
        List<RecordType> lstRt = [Select id from RecordType where SObjectType = 'Asset' and DeveloperName = 'Risk' WITH SECURITY_ENFORCED limit 1];
        
        if(lstRt.size() == 0){
            throw new AuraHandledException('Record Type Risk not found');
        }
        
        Asset a = new Asset();

        Map<String, Schema.SObjectField> assetFieldMap = Schema.SObjectType.Asset.fields.getMap();

        //System.debug('fieldValues: ' + fieldValues);
        for (String key : fieldValues.keySet()) {
            Schema.SObjectField field = assetFieldMap.get(key);
            
            if (field != null) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                 
                if (fieldDescribe.isCalculated() || fieldDescribe.isAutoNumber() || !fieldDescribe.isUpdateable()){
                   continue;
                }
            }

            a.put(key, fieldValues.get(key));
        }
        a.RecordTypeId = lstRt[0].Id;
        System.debug('🎯 Asset object prepared: ' + a);
        
        //Auto-generate Risk_ID__c for new records
        if(String.isBlank((String)a.get('Id'))){
            // This is INSERT (new record)
            System.debug('📝 Creating new Asset (INSERT)');
            String opportunityId = (String)a.get('Opportunity__c');
            //Tambahan Fikri untuk membuat Insurance Policy otomatis saat buat Risk baru
            String policyId = Aswata_GlobalFunction.createInsurancePolicy(opportunityId);
            a.Insurance_Policy__c = policyId;
            System.debug('Policy Id: ' + policyId);
            if(String.isNotBlank(opportunityId)) {
                a.Risk_ID__c = generateNextRiskId(opportunityId);
                System.debug('Generated Risk_ID__c: ' + a.Risk_ID__c);
            } else {
                System.debug('⚠️ No Opportunity__c provided, Risk_ID__c will be null');
            }
            
            if (Schema.sObjectType.Asset.isCreateable()) {
                insert a;
                System.debug('✅ Asset created successfully with Id: ' + a.Id);
            }
        } else {
            // This is UPDATE (existing record)
            System.debug('Updating existing Asset (UPDATE)');
            System.debug('Risk_ID__c will NOT be changed');
            
            if (Schema.sObjectType.Asset.isUpdateable()) {
                update a;
                System.debug('✅ Asset updated successfully');
            }
        }
        
        return a.Id;
    }

    /**
     * Generate next Risk ID for an Opportunity
     * Finds highest Risk_ID__c number for this Opportunity and increments by 1
     * @param opportunityId - The Opportunity Id
     * @return String - Next Risk ID (e.g., "1", "2", "3")
     */
    private static String generateNextRiskId(String opportunityId) {
        System.debug('🔍 Generating next Risk ID for Opportunity: ' + opportunityId);
        
        // Get all existing Risk IDs for this Opportunity, ordered by Risk_ID__c DESC
        List<Asset> existingAssets = [
            SELECT Risk_ID__c 
            FROM Asset 
            WHERE Opportunity__c = :opportunityId 
            AND Risk_ID__c != null 
            WITH SECURITY_ENFORCED
            ORDER BY Risk_ID__c DESC
            LIMIT 1
        ];
        
        Integer nextNumber = 1; // Default: start from 1
        
        if (!existingAssets.isEmpty() && String.isNotBlank(existingAssets[0].Risk_ID__c)) {
            String lastRiskId = existingAssets[0].Risk_ID__c;
            System.debug('📊 Found highest existing Risk_ID__c: ' + lastRiskId);
            
            try {
                // Extract digits from the Risk ID
                String digitsOnly = lastRiskId.replaceAll('\\D', '');
                
                if (String.isNotBlank(digitsOnly)) {
                    Integer currentNumber = Integer.valueOf(digitsOnly);
                    nextNumber = currentNumber + 1;
                    System.debug('Extracted number: ' + currentNumber + ' → Next: ' + nextNumber);
                } else {
                    System.debug('No digits found in Risk_ID, defaulting to 1');
                }
            } catch (Exception e) {
                System.debug('Error parsing Risk ID: ' + lastRiskId + ', defaulting to 1');
                System.debug('   Error: ' + e.getMessage());
                nextNumber = 1;
            }
        } else {
            System.debug('📊 No existing Assets found, starting from 1');
        }
        
        // ✅ FORMAT OPTIONS - Choose one:
        
        // Option 1: Simple number (DEFAULT)
        String result = String.valueOf(nextNumber);
        
        // Option 2: Padded number (uncomment to use)
        // String result = String.valueOf(nextNumber).leftPad(3, '0');
        
        // Option 3: With prefix (uncomment to use)
        // String result = 'RISK-' + String.valueOf(nextNumber).leftPad(3, '0');
        
        // Option 4: Short prefix (uncomment to use)
        // String result = 'R-' + String.valueOf(nextNumber).leftPad(3, '0');
        
        System.debug('✅ Generated Risk ID: ' + result);
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getAssetCountByOpportunity(Id oppId) {
        return [
            SELECT COUNT() 
            FROM Asset 
            WHERE Opportunity__c = :oppId WITH SECURITY_ENFORCED
        ];
    }

////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////// DYNAMIC CUSTOM UI/////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////
    @AuraEnabled(cacheable=true)
    public static List<DynamicFieldConfig> getActiveFields(String objectName, String interestCob, String contractType) {
        List<DynamicFieldConfig> results = new List<DynamicFieldConfig>();
        // System.debug('objectName:' + objectName);
        // System.debug('interestCob:' + interestCob);
       
        if(contractType == '1'){
            contractType = '';
        }
        // System.debug('contractType:' + contractType);

        List<Master_Data__c> configs = [
            SELECT Name, Label__c, Data_Type__c, Lookup_Object__c, Filter__c, 
                   Status__c, Object__c, Order__c, showData__c
            FROM Master_Data__c
            WHERE Status__c = 'Active'
              AND Object__c = :objectName
              AND BSN_ID__c = :interestCob
              AND Contract_Type__c = :contractType WITH SECURITY_ENFORCED
            ORDER BY Order__c ASC
        ];

        for (Master_Data__c cfg : configs) {
            results.add(new DynamicFieldConfig(
                cfg.Name,
                cfg.Label__c,
                cfg.Data_Type__c,
                cfg.Lookup_Object__c,
                cfg.Filter__c,
                cfg.showData__c 
            ));
        }

        //System.debug('Results: ' + results);
        return results;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getRequiredFieldsByCob(String cobValue) {
        List<String> requiredFields = new List<String>();
        
        if (String.isBlank(cobValue)) {
            return requiredFields;
        }
        
        try {
            // Query Master_Data__c for required fields
            List<Master_Data__c> requiredMasterData = [
                SELECT Id, Name
                FROM Master_Data__c 
                WHERE BSN_ID__c = :cobValue 
                AND Required__c = true
                WITH SECURITY_ENFORCED
                ORDER BY Name
            ];
            
            // Extract field API names
            for (Master_Data__c md : requiredMasterData) {
                if (String.isNotBlank(md.Name)) {
                    requiredFields.add(md.Name);
                }
            }
            
            System.debug('✅ Required fields for COB ' + cobValue + ': ' + requiredFields);
            
        } catch (Exception e) {
            System.debug('❌ Error fetching required fields: ' + e.getMessage());
            throw new AuraHandledException('Error fetching required fields: ' + e.getMessage());
        }
        
        return requiredFields;
    }

    public class DynamicFieldConfig {
        @AuraEnabled public String apiName {get;set;}
        @AuraEnabled public String label {get;set;}
        @AuraEnabled public String dataType {get;set;}
        @AuraEnabled public String lookupObject {get;set;}
        @AuraEnabled public String filter {get;set;}
        @AuraEnabled public String showData;

        public DynamicFieldConfig(String apiName, String label, String dataType, String lookupObject, String filter, String showData){
            this.apiName = apiName;
            this.label = label;
            this.dataType = dataType;
            this.lookupObject = lookupObject;
            this.filter = filter;
            this.showData = showData;
        }
    }


    @AuraEnabled(cacheable=true)
    public static Id getRecordTypeIdByCob(String objectName, String cobValue) {
        //System.debug('getRecordTypeIdByCob: ' + objectName + ' : COB: ' + cobValue );
        if (String.isBlank(objectName) || String.isBlank(cobValue))
        { 
            return null;
        }
        // Try to get by COB
        List<RecordType> rts = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = :objectName
            AND DeveloperName LIKE :('%' + cobValue + '%') WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!rts.isEmpty()) {
            return rts[0].Id;
        }

        // If none found, fallback to Master record type
        List<RecordType> masterRt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = :objectName
            AND DeveloperName = 'Master' WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!masterRt.isEmpty()) {
            return masterRt[0].Id;
        }

        return null;
    }

    @AuraEnabled(cacheable=true)
    public static Id getRecordTypeIdByObject(String objectName) {
        if (String.isBlank(objectName)) return null;
        
        // Try to get by COB
        List<RecordType> rts = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = :objectName
            AND DeveloperName = 'Risk' WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!rts.isEmpty()) {
            return rts[0].Id;
        }

        // If none found, fallback to Master record type
        List<RecordType> masterRt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = :objectName
            AND DeveloperName = 'Master' WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (!masterRt.isEmpty()) {
            return masterRt[0].Id;
        }

        return null;
    }

    public class AssetWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String riskId;
        @AuraEnabled public String riskName;
        @AuraEnabled public String address;
        @AuraEnabled public String cityName;
        @AuraEnabled public String zipName;
        @AuraEnabled public String recordTypeId;
    }

}