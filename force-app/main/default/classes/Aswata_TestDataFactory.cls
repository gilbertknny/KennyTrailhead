/**
 * -------------------------------------------------------------------------------
 * Class Name   : Aswata_TestDataFactory
 * Description  : Centralized factory class for creating test data such as
 *                Account, Contact, and Opportunity records.
 * Author       : Fikri
 * -------------------------------------------------------------------------------
 */
@IsTest
public class Aswata_TestDataFactory {


   // 🔹 Create a Lead record
    public static Lead createLead(String firstName, String lastName, String company) {
        Lead lead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Company = company,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@test.com',
            Phone = '08123456789',
            Status = 'New',
            Account_Segment__c = 'I',
            Account_Type__c = '	0',
            Account_Sub_Segment__c = 'Y',
            Account_Pipeline_Status__c = 'Direct',
            //Channel__c = 'Broker',
            Business_Segmentation__c = 'Retail'
        );
        insert lead;
        return lead;
    }

    public static Lead createLeadCustom(String firstName, String lastName, String company) {
        Lead lead = new Lead(
            FirstName = firstName,
            LastName = lastName,
            Company = company,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@test.com',
            Phone = '08123456789',
            Status = 'New',
            Account_Segment__c = 'I',
            Account_Type__c = '	0',
            Account_Sub_Segment__c = 'Y',
            Account_Pipeline_Status__c = 'Direct',
            //Channel__c = 'Broker',
            Business_Segmentation__c = 'Retail'
        );
        return lead;
    }

    // Create a standard Account
    public static Account createAccount(String name) {
        Account acc = new Account(
            Name = name,
            Phone = '0211234567',
            Email__c = 'account@test.com'
        );
        insert acc;
        return acc;
    }

    // Create a Contact linked to an Account
    public static Contact createContact(Account acc, String firstName, String lastName) {
        Contact con = new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = firstName.toLowerCase() + '.' + lastName.toLowerCase() + '@test.com',
            Phone = '08123456789',
            AccountId = acc.Id,
            Status__c = 'CP'
        );
        insert con;
        return con;
    }

    // Create an Opportunity linked to an Account
    public static Opportunity createOpportunity(Account acc, String name) {
        Opportunity opp = new Opportunity(
            Name = name,
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Amount = 50000
        );
        insert opp;
        return opp;
    }

    public static Quote createQuote(Opportunity opp, String name) {
        Quote quo = new Quote(
            Name = name,
            //AccountId = acc.Id,
            OpportunityId = opp.id
        );
        insert quo;
        return quo;
    }

    public static Asset createRisk(Opportunity oppty, String name) {
    
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Asset' 
            AND Name = 'Risk' 
            LIMIT 1
        ];

        // Create Asset record
        Asset risk = new Asset(
            Name = name,
            Opportunity__c = oppty.Id,
            COB__c = '201',
            RecordTypeId = rt.Id
        );
        insert risk;
        return risk;
    }

    public static Asset createAsset(Opportunity oppty,Asset risk, String name) {
    
        RecordType rt = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Asset' 
            AND Name = 'Asset' 
            LIMIT 1
        ];

        // Create Asset record
        Asset ast = new Asset(
            Name = name,
            Opportunity__c = oppty.Id,
            ParentId = risk.Id,
            COB__c = '201',
            RecordTypeId = rt.Id
        );
        insert ast;
        return ast;
    }


    // Combined convenience method
    public static Map<String, SObject> createStandardDataSet() {
        Map<String, SObject> data = new Map<String, SObject>();
        Account acc = createAccount('Test Account');
        Contact con = createContact(acc, 'John', 'Doe');
        Opportunity opp = createOpportunity(acc, 'Test Opportunity');
        
        data.put('Account', acc);
        data.put('Contact', con);
        data.put('Opportunity', opp);

        return data;
    }

    // 🔹 Create Master_Data__c record (generic for Coverage, City, Province, etc.)
    public static Master_Data__c createMasterData(String name, String recordTypeName) {
        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Master_Data__c' AND Name = :recordTypeName
            LIMIT 1
        ];

        Master_Data__c md = new Master_Data__c(
            Name = name,
            RecordTypeId = rt.Id
        );
        insert md;
        return md;
    }

    // 🔹 Create Exchange Rate record
    public static Master_Data__c createExchangeRate(String name, Decimal rate) {
        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Master_Data__c' AND Name = 'Exchange Rate'
            LIMIT 1
        ];

        Master_Data__c ex = new Master_Data__c(
            Name = name,
            Exchange_Rate__c = rate,
            RecordTypeId = rt.Id
        );
        insert ex;
        return ex;
    }

    // 🔹 Create linked Province → City → Address hierarchy
    public static Map<String, Schema.Location> createLocationHierarchy() {
        RecordType rtProvince = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Province' LIMIT 1
        ];
        RecordType rtCity = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'City' LIMIT 1
        ];
        RecordType rtVillage = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Village' LIMIT 1
        ];
        RecordType rtZipCode = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Zip Code' LIMIT 1
        ];

        RecordType rtAddress = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Address' LIMIT 1
        ];

        Schema.Location province = new Schema.Location(Name = 'Jakarta', RecordTypeId = rtProvince.Id, LocationType = 'Province');
        insert province;

        Schema.Location city = new Schema.Location(Name = 'Jakarta Selatan', RecordTypeId = rtCity.Id, Province__c = province.Id, LocationType = 'City');
        insert city;
        
        Schema.Location village = new Schema.Location(Name = 'Setiabudi', RecordTypeId = rtVillage.Id, Province__c = province.Id, City__c = city.Id, LocationType = 'Village');
        insert village;

        Schema.Location zipCode = new Schema.Location(Name = '1171', RecordTypeId = rtZipCode.Id, City__c = city.Id, Province__c = province.Id, Village__c = village.Id, LocationType = 'Zip Code');
        insert zipCode;

        Schema.Location address = new Schema.Location(Name = 'Jl. Sudirman No. 10', Address_Name__c = 'Jl. Sudirman No. 10' , RecordTypeId = rtAddress.Id, City__c = city.Id, Province__c = province.Id, Village__c = village.Id, Zip_Code__c = zipCode.Id);
        insert address;

        return new Map<String, Schema.Location>{
            'Province' => province,
            'City' => city,
            'Village' => village,
            'Zip Code' => zipCode,
            'Address' => address
        };
    }

    public static Schema.Location createZipCode() {
        RecordType rtZipCode = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Zip Code' LIMIT 1
        ];


        Schema.Location zipCode = new Schema.Location(Name = '1171', RecordTypeId = rtZipCode.Id, LocationType = 'Zip Code');
        return  zipCode;

    }

    public static Schema.Location createAddress() {
        RecordType rtAddress = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Address' LIMIT 1
        ];


        Schema.Location address = new Schema.Location(Name = 'Jl. Sudirman No. 10', RecordTypeId = rtAddress.Id);
        return address;

    }

    // 🔹 Overloaded version (reusable)
    public static InsurancePolicy createInsurancePolicy(Account acc, Opportunity opp) {
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Insurance Policy',
            NameInsuredId = acc.Id,
            SourceOpportunityId = opp.Id
        );
        insert policy;

        return policy;
    }

    
    public static Transaction_Data__c createTransactionData(String recordTypeName, String recordName) {
        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Transaction_Data__c' AND Name =: recordTypeName
            LIMIT 1
        ];
        
        Transaction_Data__c transactionData = new Transaction_Data__c(
            Name = recordName,
            RecordTypeId = rt.Id
        );
        insert transactionData;

        return transactionData;
    }
}