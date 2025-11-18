public with sharing class LeadController {

  public class LocationWrapper {
    @AuraEnabled public String Id   { get; set; }
    @AuraEnabled public String Name { get; set; }
    @AuraEnabled public String Province { get; set; }
    @AuraEnabled public String Village { get; set; }
    public LocationWrapper(Id id, String name, String province, String Village) {
      this.Id   = String.valueOf(id);
      this.Name = name;
      this.Province = province;
      this.Village  = village;
    }
  }
    
    @AuraEnabled(cacheable=true)
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
        system.debug('result City='+results);
      return results;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
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
        system.debug('result Zip Code='+results);
      return results;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
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
      
      system.debug('result Customer Type='+options);
    return options;
  }

  @AuraEnabled
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
        system.debug('created Data='+newLead);
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