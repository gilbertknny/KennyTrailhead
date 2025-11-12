public with sharing class addressDisplayController {
    public class AddressWrapper {
        @AuraEnabled public String Id { get; set; }
        @AuraEnabled public String Name { get; set; }
        @AuraEnabled public String CountryId { get; set; }
        @AuraEnabled public String ProvinceId { get; set; }
        @AuraEnabled public String CityId { get; set; }
        @AuraEnabled public String ZipId { get; set; }
        @AuraEnabled public String BranchId { get; set; }
    }

    @AuraEnabled(cacheable=true)
    public static List<AddressWrapper> searchLocations(String searchKey, String country, String province, String city, String zip, Integer limitSize) {
        if (limitSize == null) limitSize = 10;

        String base = 'SELECT Id, Name, ' +
                      'Country__c, Country__r.Name, ' +
                      'Province__c, Province__r.Name, ' +
                      'City__c, City__r.Name, ' +
                      'Zip_Code__c, Zip_Code__r.Name, Zip_Code__r.Branch_Name__r.BRANCH_ID__c ' +
                      'FROM Location WHERE LocationType = \'Address\'';

        if (String.isNotBlank(searchKey)) {
            String sanitizedKey = '%' + String.escapeSingleQuotes(searchKey) + '%';
            base += ' AND Name LIKE \'' + sanitizedKey + '\'';
        }

        if (String.isNotBlank(country))
            base += ' AND Country__c = :country';
        if (String.isNotBlank(province))
            base += ' AND Province__c = :province';
        if (String.isNotBlank(city))
            base += ' AND City__c = :city';
        if (String.isNotBlank(zip))
            base += ' AND Zip_Code__c = :zip';

        base += ' ORDER BY LastModifiedDate DESC LIMIT ' + String.valueOf(limitSize);

        List<SObject> rows = Database.query(base);
        List<AddressWrapper> out = new List<AddressWrapper>();

        for (SObject r : rows) {
            AddressWrapper w = new AddressWrapper();
            w.Id = (Id)r.get('Id'); 
            w.Name = (String)r.get('Name');

            SObject zipRel = r.getSObject('Zip_Code__r');
            SObject branchRel = zipRel != null ? zipRel.getSObject('Branch_Name__r') : null;
            
            w.CountryId = (String)r.get('Country__c');
            w.ProvinceId = (String)r.get('Province__c');
            w.CityId = (String)r.get('City__c');
            w.ZipId = (String)r.get('Zip_Code__c');
            w.BranchId = (branchRel != null) ? (String)branchRel.get('BRANCH_ID__c') : null;

            out.add(w);
        }
        return out;
    }
}