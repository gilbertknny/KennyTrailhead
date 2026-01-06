/**
 * -------------------------------------------------------------------------------
 * Class Name   : Aswata_TestDataFactory
 * Description  : Centralized factory class for creating test data such as
 *                Account, Contact, and Opportunity records.
 * Author       : Fikri
 * -------------------------------------------------------------------------------
 */
/**
 * @description Centralized factory class for creating test data
 */
@IsTest
public class Aswata_TestDataFactory {
   /**
     * @description Create a Lead record
     * @param firstName
     * @param lastName
     * @param company
     * @return Lead
     */
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
    /**
     * @description Create a Lead record
     * @param firstName
     * @param lastName
     * @param company
     * @return Lead
     */
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
    /**
     * @description Create a standard Account
     * @param name
     * @return Account
     */
    public static Account createAccount(String name) {
       	Account acc = new Account(
            Name = name,
            Phone = '0211234567',
            Email__c = 'account@test.com'
        );
    
        Database.DMLOptions opts = new Database.DMLOptions();
        opts.DuplicateRuleHeader.allowSave = true;
    
        Database.insert(acc, opts);
        return acc;
    }
    /**
     * @description Create a Contact linked to an Account
     * @param acc
     * @param firstName
     * @param lastName
     * @return Contact
     */
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
    /**
     * @description Create an Opportunity linked to an Account
     * @param acc
     * @param name
     * @return Contact
     */
    public static Opportunity createOpportunity(Account acc, String name) {
        
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'System Administrator'
            LIMIT 1
        ];
    
        String branchValue;

        Schema.DescribeFieldResult dfr =
            User.Branch__c.getDescribe();
        
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            if (ple.isActive()) {
                branchValue = ple.getValue(); // API VALUE
                break;
            }
        }
        
        User u = new User(
            Alias = 'tusr',
            Email = 'user@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            //UserType = 'Standard',
            IsActive = true,
            Area__c = '71',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Asia/Jakarta',
            UserName = 'user' + System.currentTimeMillis() + '@test.com',
            Branch__c = branchValue   // ✅ SAFE
        );
        insert u;
            
        Opportunity opp = new Opportunity(
            Name = name,
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today().addDays(30),
            Amount = 50000,
            COB__c = '201',
            OwnerId = u.Id
        );
        insert opp;
        return opp;
    }
    /**
     * @description Create an Quote linked to an Opportunity
     * @param opp
     * @param name
     * @return Quote
     */
    public static Quote createQuote(Opportunity opp, String name) {
        Quote quo = new Quote(
            Name = name,
            //AccountId = acc.Id,
            OpportunityId = opp.id
        );
        insert quo;
        return quo;
    }
    /**
     * @description Create an Risk linked to an Opportunity
     * @param oppty
     * @param name
     * @return Asset
     */
    public static Asset createRisk(Opportunity oppty, String name) {
        RecordType rt = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Asset'
            AND Name = 'Risk'
            LIMIT 1
        ];
        Opportunity op = [Select id from Opportunity where id =: oppty.Id];

        // Create Asset record
        Asset risk = new Asset(
            Name = name,
            Opportunity__c = oppty.Id,
            //COB__c = '201',
            RecordTypeId = rt.Id
        );
        insert risk;
        return risk;
    }

    /**
     * @description Create an Asset linked to an Opportunity and Risk
     * @param oppty
     * @param risk
     * @param name
     * @return Asset
     */
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
            //COB__c = '201',
            RecordTypeId = rt.Id
        );
        insert ast;
        return ast;
    }

    /**
     * @description Combined convenience method
     * @return Map<String, SObject>
     */
    public static Map<String, SObject> createStandardDataSet() {
        Map<String, SObject> data = new Map<String, SObject>();
        Account acc = createAccount('Test Account Opty');
        Contact con = createContact(acc, 'John', 'Doe');
        Opportunity opp = createOpportunity(acc, 'Test Opportunity');
        data.put('Account', acc);
        data.put('Contact', con);
        data.put('Opportunity', opp);

        return data;
    }
    /**
     * @description 🔹 Create Master_Data__c record (generic for Coverage, City, Province, etc.)
     * @param name
     * @param recordTypeName
     * @return Master_Data__c
     */
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
    /**
     * @description 🔹 Create Exchange Rate record
     * @param name
     * @param rate
     * @return Master_Data__c
     */
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
    /**
     * @description 🔹 Create linked Province → City → Address hierarchy
     * @return Map<String, Schema.Location>
     */
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
    /**
     * @description 🔹 createZipCode
     * @return Schema.Location
     */
    public static Schema.Location createZipCode() {
        RecordType rtZipCode = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Zip Code' LIMIT 1
        ];


        Schema.Location zipCode = new Schema.Location(Name = '1171', RecordTypeId = rtZipCode.Id, LocationType = 'Zip Code');
        return  zipCode;

    }
    /**
     * @description 🔹 createAddress
     * @return Schema.Location
     */
    public static Schema.Location createAddress() {
        RecordType rtAddress = [
            SELECT Id FROM RecordType WHERE SObjectType = 'Location' AND Name = 'Address' LIMIT 1
        ];


        Schema.Location address = new Schema.Location(Name = 'Jl. Sudirman No. 10', RecordTypeId = rtAddress.Id);
        return address;

    }
    /**
     * @description 🔹 createInsurancePolicy
     * @param acc
     * @param opp
     * @return InsurancePolicy
     */
    public static InsurancePolicy createInsurancePolicy(Account acc, Opportunity opp) {
        InsurancePolicy policy = new InsurancePolicy(
            Name = 'Test Insurance Policy',
            NameInsuredId = acc.Id,
            SourceOpportunityId = opp.Id
        );
        insert policy;

        return policy;
    }
    /**
     * @description createTransactionData
     * @param recordTypeName
     * @param recordName
     * @return Transaction_Data__c
     */
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
    /**
     * @description createTestUser
     * @param aliasPrefix
     * @return User
     */
    public static User createTestUser(String aliasPrefix) {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'Standard User'
            LIMIT 1
        ];

        User u = new User(
            FirstName = aliasPrefix,
            LastName  = 'Tester',
            Alias     = aliasPrefix.substring(0, Math.min(8, aliasPrefix.length())),
            Email     = aliasPrefix + '@test.com',
            Username  = aliasPrefix + '@test.com.' + System.currentTimeMillis(),
            TimeZoneSidKey = 'Asia/Singapore',
            LocaleSidKey   = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = p.Id,
            isActive = true
        );
        insert u;
        return u;
    }
    /**
     * @description function for create with Profile Admin
     * @return User return usercreated
     */
    public static User createTestAdmin(String aliasPrefix){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = new User(
            Alias = aliasPrefix,
            Email = aliasPrefix + System.currentTimeMillis() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'AdminTest',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = aliasPrefix + System.currentTimeMillis() + '@testorg.com' // Unique Username
        );
        insert adminUser;
        return adminUser;
    }

    /**
     * @description function for Folder Facultative
     * @return Returning Facultative_Share__c
     */
    public static Facultative_Share__c createFacultativeShare(String folderName) {
        
        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Facultative_Share__c' AND Name =: 'Folder'
            LIMIT 1
        ];
        
        Facultative_Share__c share = new Facultative_Share__c(
            Name = folderName,
            RecordTypeId = rt.Id
        );
        insert share;
        return share;
    }

    public static Facultative_Share__c createOfferingShare(String name) {
        
        RecordType rt = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Facultative_Share__c' AND Name =: 'Facultative Share'
            LIMIT 1
        ];
        
        Facultative_Share__c share = new Facultative_Share__c(
            Name = name,
            RecordTypeId = rt.Id
        );
        insert share;
        return share;
    }
    
    /* =========================
       GET STANDARD PRICEBOOK
    ========================= */
    public static Id getStandardPricebookId() {
        return Test.getStandardPricebookId();
    }

    /* =========================
       CREATE PRODUCT
    ========================= */
    public static Product2 createProduct(String name) {
        Product2 p = new Product2(
            Name = name,
            IsActive = true
        );
        insert p;
        return p;
    }
    
     /* =========================
       CREATE PRICEBOOK ENTRY
    ========================= */
    public static PricebookEntry createPricebookEntry(
        Product2 product,
        Decimal unitPrice
    ) {
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = getStandardPricebookId(),
            Product2Id   = product.Id,
            UnitPrice    = unitPrice,
            IsActive     = true
        );
        insert pbe;
        return pbe;
    }

    /* =========================
       CREATE PRODUCT + PBE
    ========================= */
    public static Product2 createProductWithPrice(
        String name,
        Decimal unitPrice
    ) {
        Product2 p = createProduct(name);
        createPricebookEntry(p, unitPrice);
        return p;
    }
}