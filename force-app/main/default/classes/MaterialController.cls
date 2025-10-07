/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-07-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class MaterialController {
    
    @AuraEnabled(cacheable=true)
    public static List<ModuleWrapper> getModules() {
        try {
            List<ModuleWrapper> moduleList = new List<ModuleWrapper>();
            Map<String, Integer> moduleCountMap = new Map<String, Integer>();
            
            // Get all materials with Module__c populated
            List<Material__c> materials = [
                SELECT Id, Modules__c, Modules__r.Name
                FROM Material__c 
                WHERE Modules__c != null
            ];
            
            System.debug('Total materials found: ' + materials.size());
            
            // Count materials per module
            for (Material__c material : materials) {
                String moduleName = material.Modules__r.Name;
                System.debug('Processing material with module: ' + moduleName);
                
                if (String.isNotBlank(moduleName)) {
                    if (moduleCountMap.containsKey(moduleName)) {
                        moduleCountMap.put(moduleName, moduleCountMap.get(moduleName) + 1);
                    } else {
                        moduleCountMap.put(moduleName, 1);
                    }
                }
            }
            
            System.debug('Module count map: ' + moduleCountMap);
            
            // Create wrapper objects
            for (String moduleName : moduleCountMap.keySet()) {
                ModuleWrapper wrapper = new ModuleWrapper();
                wrapper.moduleName = moduleName;
                wrapper.materialCount = moduleCountMap.get(moduleName);
                moduleList.add(wrapper);
                System.debug('Created wrapper - Module: ' + wrapper.moduleName + ', Count: ' + wrapper.materialCount);
            }
            
            // Sort by module name
            moduleList.sort();
            
            System.debug('Final module list size: ' + moduleList.size());
            return moduleList;
            
        } catch (Exception e) {
            System.debug('Error in getModules: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving modules: ' + e.getMessage());
        }
    }

    //Method ambil 5 record terbaru
  @AuraEnabled(cacheable=true)
    public static List<Module__c> getFiveLatestModules() {
        List<Module__c> recentModules = new List<Module__c>();
         try {
             recentModules = [
                 SELECT Id, Name, CreatedDate
                 FROM Module__c
                 ORDER BY CreatedDate DESC
                LIMIT 5
             ];
         } catch (Exception e) {
            throw new AuraHandledException('Error retrieving recent modules: ' + e.getMessage());
         }
        return recentModules;
    }

    //Method ambil 5 Material terbaru 
     @AuraEnabled(cacheable=true)
     public static List<MaterialDetailWrapper> getFiveLatestMaterials() {
        try {
            List<MaterialDetailWrapper> wrappedMaterials = new List<MaterialDetailWrapper>();

            List<Material__c> materials = [
                SELECT Id, Name, Description__c, CreatedDate, 
                       Modules__r.Name, Presenter__r.Name, Presenter__r.Title, Presenter__r.Email
                FROM Material__c
                ORDER BY CreatedDate DESC
                LIMIT 5
            ];

            for (Material__c m : materials) {
                MaterialDetailWrapper wrapper = new MaterialDetailWrapper();
                wrapper.material = m;
                wrapper.moduleName = m.Modules__r != null ? m.Modules__r.Name : null;
                wrapper.presenterName = m.Presenter__r != null ? m.Presenter__r.Name : null;
                wrapper.presenterTitle = m.Presenter__r != null ? m.Presenter__r.Title : null;
                wrapper.presenterEmail = m.Presenter__r != null ? m.Presenter__r.Email : null;
                wrapper.createdDate = m.CreatedDate;
                wrapper.files = new List<MaterialDetailWrapper.FileWrapper>();
                wrappedMaterials.add(wrapper);
            }

        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving recent materials: ' + e.getMessage());
        }

         return wrappedMaterials;
    }


    
    @AuraEnabled(cacheable=true)
    public static List<MaterialWrapper> getMaterialsByModule(String moduleName) {
        try {
            List<MaterialWrapper> wrappedMaterials = new List<MaterialWrapper>();
            
            for (Material__c material : [
                SELECT Id, Name, Modules__c, Modules__r.Name, Description__c, Presenter__c, 
                       Presenter__r.Name, Date__c, CreatedDate
                FROM Material__c 
                WHERE Modules__r.Name = :moduleName 
                ORDER BY Date__c DESC NULLS LAST, CreatedDate DESC
            ]) {
                MaterialWrapper wrapper = new MaterialWrapper();
                wrapper.material = material;
                wrapper.presenterName = material.Presenter__r.Name;
                wrappedMaterials.add(wrapper);
            }
            
            return wrappedMaterials;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving materials: ' + e.getMessage());
        }
    }

    
    
    @AuraEnabled(cacheable=true)
    public static MaterialDetailWrapper getMaterialDetail(Id recordId) {
        try {
            MaterialDetailWrapper wrapper = new MaterialDetailWrapper();
            
            // Query Material with null check
            List<Material__c> materials = [
                SELECT Id, Name, Modules__c, Modules__r.Name, Description__c, Presenter__c, 
                       Presenter__r.Name, Presenter__r.Title, Presenter__r.Email,
                       Date__c
                FROM Material__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            
            if (materials.isEmpty()) {
                throw new AuraHandledException('Material not found');
            }
            
            wrapper.material = materials[0];
            wrapper.presenterName = materials[0].Presenter__r.Name;
            wrapper.presenterTitle = materials[0].Presenter__r.Title;
            wrapper.presenterEmail = materials[0].Presenter__r.Email;
            
            // Query related Files with error handling
            List<MaterialDetailWrapper.FileWrapper> fileList = new List<MaterialDetailWrapper.FileWrapper>();
            
            for (ContentDocumentLink cdl : [
                SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.FileExtension, 
                       ContentDocument.LatestPublishedVersionId, ContentDocument.FileType,
                       ContentDocument.ContentSize, ContentDocument.CreatedDate
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId 
                ORDER BY ContentDocument.CreatedDate DESC
            ]) {
                MaterialDetailWrapper.FileWrapper fw = new MaterialDetailWrapper.FileWrapper();
                fw.Id = cdl.ContentDocument.Id;
                fw.Title = cdl.ContentDocument.Title;
                fw.FileExtension = cdl.ContentDocument.FileExtension;
                fw.FileType = cdl.ContentDocument.FileType;
                fw.LatestPublishedVersionId = cdl.ContentDocument.LatestPublishedVersionId;
                fw.ContentSize = cdl.ContentDocument.ContentSize;
                fw.CreatedDate = cdl.ContentDocument.CreatedDate;
                fw.FormattedSize = formatFileSize(cdl.ContentDocument.ContentSize);
                fileList.add(fw);
            }
            
            wrapper.files = fileList;
            return wrapper;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving material details: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getFileDownloadUrl(Id contentVersionId) {
        try {
            return '/sfc/servlet.shepherd/version/download/' + contentVersionId;
        } catch (Exception e) {
            throw new AuraHandledException('Error generating download URL: ' + e.getMessage());
        }
    }
    
    // Helper method to format file size
    private static String formatFileSize(Integer sizeInBytes) {
        if (sizeInBytes == null) return '0 B';
        
        if (sizeInBytes < 1024) return sizeInBytes + ' B';
        if (sizeInBytes < 1048576) return Math.round(sizeInBytes / 1024.0) + ' KB';
        if (sizeInBytes < 1073741824) return Math.round(sizeInBytes / 1048576.0) + ' MB';
        return Math.round(sizeInBytes / 1073741824.0) + ' GB';
    }
    
    // Wrapper classes
    public class ModuleWrapper implements Comparable {
        @AuraEnabled public String moduleName { get; set; }
        @AuraEnabled public Integer materialCount { get; set; }
        
        public Integer compareTo(Object compareTo) {
            ModuleWrapper compareToWrapper = (ModuleWrapper)compareTo;
            if (moduleName == compareToWrapper.moduleName) return 0;
            if (moduleName > compareToWrapper.moduleName) return 1;
            return -1;
        }
    }
    
    public class MaterialWrapper {
        @AuraEnabled public Material__c material { get; set; }
        @AuraEnabled public String presenterName { get; set; }
    }
}