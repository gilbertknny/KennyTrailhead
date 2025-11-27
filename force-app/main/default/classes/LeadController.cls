/**
 * @author [Marco Lie]
 * @date [2025-11-26]
 * @description Controller class for Lead management operations including location lookup,
 * customer type options, and lead creation functionality for web-to-lead processes
 */
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
   * @throws AuraHandledException if query fails or CRUD/FLS violation occurs
   */
  @AuraEnabled(cacheable=true)
  public static List<LocationWrapper> findCities(String searchKey) {
    // Check CRUD permission for Location object
    if (!Schema.sObjectType.Location.isAccessible()) {
      throw new AuraHandledException('Insufficient access to Location object');
    }
    
    // Check FLS permission for specific fields
    if (!Schema.sObjectType.Location.fields.Id.isAccessible() ||
        !Schema.sObjectType.Location.fields.Name.isAccessible() ||
        !Schema.sObjectType.Location.fields.Province__c.isAccessible()) {
      throw new AuraHandledException('Insufficient field-level access to Location fields');
    }

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
   * @throws AuraHandledException if query fails or CRUD/FLS violation occurs
   */
  @AuraEnabled(cacheable=true)
  public static List<LocationWrapper> getZipCodes(String cityId) {
    // Check CRUD permission for Location object
    if (!Schema.sObjectType.Location.isAccessible()) {
      throw new AuraHandledException('Insufficient access to Location object');
    }
    
    // Check FLS permission for specific fields
    if (!Schema.sObjectType.Location.fields.Id.isAccessible() ||
        !Schema.sObjectType.Location.fields.Name.isAccessible() ||
        !Schema.sObjectType.Location.fields.Village__c.isAccessible()) {
      throw new AuraHandledException('Insufficient field-level access to Location fields');
    }

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
  public static List<Map<String,String>> getCustomerTypeOptions() {
    // Check if Lead object is accessible
    if (!Schema.sObjectType.Lead.isAccessible()) {
      return new List<Map<String,String>>();
    }
    
    // Check if Account_Segment__c field is accessible
    if (!Schema.sObjectType.Lead.fields.Account_Segment__c.isAccessible()) {
      return new List<Map<String,String>>();
    }

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
   * @return Id of the newly created Lead record
   * @throws AuraHandledException if lead creation fails or CRUD/FLS violation occurs
   */
  @AuraEnabled
  @SuppressWarnings('PMD.ExcessiveParameterList')
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
  ) {
    // Check CRUD permission for Lead object - create access
    if (!Schema.sObjectType.Lead.isCreateable()) {
      throw new AuraHandledException('Insufficient access to create Lead records');
    }
    
    // Check FLS permission for each field being created
    String[] fieldsToCheck = new String[]{
      'FirstName', 'LastName', 'Email', 'Phone', 'Company', 
      'City__c', 'Province__c', 'Zip__c', 'Village__c', 
      'Account_Type__c', 'Account_Segment__c', 'Status', 
      'LeadSource', 'Account_Pipeline_Status__c', 'User_Description__c'
    };
    
    for (String fieldName : fieldsToCheck) {
      if (!Schema.sObjectType.Lead.fields.getMap().get(fieldName).getDescribe().isCreateable()) {
        throw new AuraHandledException('Insufficient field-level access to create Lead field: ' + fieldName);
      }
    }

    try {
      Lead newLead = new Lead(
        FirstName        = firstName,
        LastName         = lastName,
        Email            = email,
        Phone            = phone,
        Company          = company,
        City__c          = cityId,
        Province__c      = provinceId,
        Zip__c           = zipCodeId,
        Village__c       = villageId,
        //Account_Type__c  = 'General',
        Account_Type__c  = '0', // General
        Account_Segment__c = customerType,
        Status           = 'New',
        LeadSource       = 'Website', // web to lead site
        Account_Pipeline_Status__c = 'Direct',
        User_Description__c = userDescription
      );
      insert newLead;
      return newLead.Id;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}

/*
 -- Draft solution if Location object simplyfied structure --

// 1. Query the database ONE time.
// The database does all the hard work and returns only 514 aggregate results.
List<AggregateResult> uniqueCityResults = [SELECT City__c
                                         FROM Master_Location__c
                                         WHERE City__c != null
                                         GROUP BY City__c];

// 2. Loop IN MEMORY.
// This is perfectly safe and fast. It doesn't use any more queries.
// It will run 514 times, which takes less than 2 milliseconds.
List<String> uniqueCities = new List<String>();
for (AggregateResult ar : uniqueCityResults) {
    uniqueCities.add((String)ar.get('City__c'));
}

 */