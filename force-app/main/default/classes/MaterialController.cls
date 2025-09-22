public with sharing class MaterialController {
    
    @AuraEnabled(cacheable=true)
    public static List<ModuleWrapper> getModules() {
        try {
            List<ModuleWrapper> moduleList = new List<ModuleWrapper>();
            Map<String, Integer> moduleCountMap = new Map<String, Integer>();
            
            // Get all materials with Module__c populated
            List<Material__c> materials = [
                SELECT Id, Module__c
                FROM Material__c 
                WHERE Module__c != null
            ];
            
            System.debug('Total materials found: ' + materials.size());
            
            // Count materials per module
            for (Material__c material : materials) {
                String moduleName = material.Module__c;
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
    
    @AuraEnabled(cacheable=true)
    public static List<Material__c> getMaterialsByModule(String moduleName) {
        try {
            return [
                SELECT Id, Name, Module__c, Description__c, Presenter__c, Date__c, CreatedDate
                FROM Material__c 
                WHERE Module__c = :moduleName 
                ORDER BY Date__c DESC NULLS LAST, CreatedDate DESC
            ];
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
                SELECT Id, Name, Module__c, Description__c, Presenter__c, Date__c
                FROM Material__c 
                WHERE Id = :recordId 
                LIMIT 1
            ];
            
            if (materials.isEmpty()) {
                throw new AuraHandledException('Material not found');
            }
            
            wrapper.material = materials[0];
            
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
}