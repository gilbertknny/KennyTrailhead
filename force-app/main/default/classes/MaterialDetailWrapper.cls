/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-29-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class MaterialDetailWrapper {
    @AuraEnabled public Material__c material { get; set; }
    @AuraEnabled public List<FileWrapper> files { get; set; }
    @AuraEnabled public String presenterName { get; set; }
    @AuraEnabled public String presenterTitle { get; set; }
    @AuraEnabled public String presenterEmail { get; set; }
    
    public class FileWrapper {
        @AuraEnabled public Id Id { get; set; }
        @AuraEnabled public String Title { get; set; }
        @AuraEnabled public String FileExtension { get; set; }
        @AuraEnabled public String FileType { get; set; }
        @AuraEnabled public Id LatestPublishedVersionId { get; set; }
        @AuraEnabled public Integer ContentSize { get; set; }
        @AuraEnabled public DateTime CreatedDate { get; set; }
        @AuraEnabled public String FormattedSize { get; set; }
    }
}