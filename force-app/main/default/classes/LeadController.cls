/**
 * @author: Marco Lie
 * @date 2025-11-26
 * @description Controller class for Lead management operations including location lookup,
 * customer type options, and lead creation functionality for web-to-lead processes
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class LeadController {

  /**
   * @description Wrapper class to hold location data for Aura-enabled response
   */
  @SuppressWarnings('PMD.PropertyNamingConventions')
  public class LocationWrapper {
    @AuraEnabled public String Id { get; set; }
    @AuraEnabled public String Name { get; set; }
    @AuraEnabled public String Province { get; set; }
    @AuraEnabled public String Village { get; set; }
    
    /**
     * @description Constructor for LocationWrapper class
     * @param id Location record Id
     * @param name Location name
     * @param province Province name
     * @param village Village name
     */
    public LocationWrapper(Id id, String name, String province, String village) {
      this.Id   = String.valueOf(id);
      this.Name = name;
      this.Province = province;
      this.Village  = village;
    }
  }
    
  /**
   * @description Searches for cities based on search key pattern
   * @param searchKey Search term for city name lookup
   * @return List of LocationWrapper objects containing city information
   * @throws AuraHandledException if query fails
   */
  @AuraEnabled(cacheable=true)
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static List<LocationWrapper> findCities(String searchKey) {
      List<LocationWrapper> results = new List<LocationWrapper>();
    String pattern = '%' + String.escapeSingleQuotes(searchKey) + '%';
    try {
      List<SObject> rows = [
        SELECT Id, Name, Province__c
        FROM Location
        WHERE LocationType = 'City'
            AND RecordType.Name = 'City'
            AND Name LIKE :pattern
          ORDER BY Name
          LIMIT 10
      ];
      for (SObject row : rows) {
        results.add(new LocationWrapper(
          (Id)row.get('Id'),
          (String)row.get('Name'),
          (String)row.get('Province__c'),
            null
        ));
      }
      return results;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Retrieves zip codes for a given city ID
   * @param cityId The ID of the city to get zip codes for
   * @return List of LocationWrapper objects containing zip code information
   * @throws AuraHandledException if query fails
   */
  @AuraEnabled(cacheable=true)
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static List<LocationWrapper> getZipCodes(String cityId) {
    List<LocationWrapper> results = new List<LocationWrapper>();
    try {
      List<SObject> rows = [
        SELECT Id, Name, Village__c
        FROM Location
        WHERE LocationType = 'Zip Code'
          AND RecordType.Name = 'Zip Code'
          AND City__c = :cityId
        ORDER BY Name
      ];
      for (SObject row : rows) {
        results.add(new LocationWrapper(
          (Id)row.get('Id'),
          (String)row.get('Name'),
            null,
            (String)row.get('Village__c')
        ));
      }
      return results;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Retrieves customer type options from Lead Account_Segment__c picklist
   * @return List of Maps containing label-value pairs for customer type options
   */
  @AuraEnabled(cacheable=true)
  @SuppressWarnings('PMD.ApexCRUDViolation')
  public static List<Map<String,String>> getCustomerTypeOptions() {
    List<Map<String,String>> options = new List<Map<String,String>>();
    for (Schema.PicklistEntry ple 
         : Lead.Account_Segment__c.getDescribe().getPicklistValues()) {
        
        if (ple.getValue() == 'G') {
            continue;
        }
        
        options.add(new Map<String, String>{
            'label' => ple.getLabel(),
            'value' => ple.getValue()
        });
    }
    return options;
  }

  /**
   * @description Creates a new Lead record with the provided information
   * @param firstName Lead's first name
   * @param lastName Lead's last name
   * @param email Lead's email address
   * @param phone Lead's phone number
   * @param company Lead's company name
   * @param provinceId Province location ID
   * @param cityId City location ID
   * @param zipCodeId Zip code location ID
   * @param villageId Village location ID
   * @param customerType Customer segment type
   * @param userDescription User-provided description
   * @param leadReferralName Referral name for enterprise leads
   * @return Id of the newly created Lead record
   * @throws AuraHandledException if lead creation fails
   */
  @AuraEnabled
  @SuppressWarnings('PMD.ExcessiveParameterList, PMD.ApexCRUDViolation')
  public static Id createLead(
      String firstName,
      String lastName,
      String email,
      String phone,
      String company,
      String provinceId,
      String cityId,
      String zipCodeId,
      String villageId,
      String customerType,
      String userDescription
      //,String leadReferralName
  ) {
      
    try {
      Lead newLead = new Lead(
        FirstName        = firstName,
        LastName         = lastName,
        Email            = email,
        Phone            = phone,
        City__c          = cityId,
        Province__c      = provinceId,
        Zip__c           = zipCodeId,
        Village__c       = villageId,
        Account_Type__c  = '0', // General
        Account_Segment__c = customerType,
        Status           = 'New',
        LeadSource       = 'Website', // web to lead site
        Account_Pipeline_Status__c = 'Direct',
        User_Description__c = userDescription
      );
      
      // Set Lead_Referral_Name__c if provided (for Enterprise leads)
      // Note: Only set referral name, not email/phone since they're already captured in main fields
      /*if (String.isNotBlank(leadReferralName)) {
          newLead.Lead_Referral_Name__c = leadReferralName;
          newLead.Lead_Referral_Email__c = email;
          newLead.Lead_Referral_Phone__c = phone;
      }*/
        // Set Company Email and Phone if provided (for Business/Enterprise leads)
        if (String.isNotBlank(company)) {
            newLead.Company = company;
            newLead.Company_Email__c = email;
            newLead.Company_Phone__c = phone;
        }
      
      insert newLead;
      return newLead.Id;
    } catch (Exception e) {
      throw new AuraHandledException('Error creating lead: ' + e.getMessage());
    }
  }
}