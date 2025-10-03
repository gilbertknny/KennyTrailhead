@isTest
public with sharing class BFI_TestDataFactory {


    /////////////////////////////////////////////////
    public static User createSysAdminUser(String alias) {
        Profile sysAdminProfile = [
            SELECT Id 
            FROM Profile 
            WHERE Name = 'System Administrator' 
            LIMIT 1
        ];

        User u = new User(
            Alias = alias,
            Email = alias + '@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Tester',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = sysAdminProfile.Id,
            Username = alias + '@test.com.' + System.currentTimeMillis()
        );
        insert u;
        return u;
    }

     public static User createUserWithPassPhrase(String passPhrase) {
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'Standard' LIMIT 1];

        User u = new User(
            Alias = 'tuser',
            Email = 'testuser' + System.currentTimeMillis() + '@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'TestUser',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            ProfileId = p.Id,
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com',
            Pass_Phrase__c = passPhrase
        );
        insert u;
        return u;
    }

    public static Application__c createApplication(String name, String agreementNo, String branchManager) {
        
        User usr = createSysAdminUser('adBFI');
        Account acc = createAccount('Testing');

        // Step 2: Create an Opportunity linked to the Account
        Opportunity opp = createOpportunity(acc, name + ' Opp', 5000, 'Prospecting', null);

        // Step 3: Create a Survey
        Survey__c survey = createSurvey(opp.id);

        Application__c app = new Application__c(
            Name = name,
            //Customer_Name__c = customerName,
            agreement_number__c = agreementNo,
            Branch_Manager__c = branchManager,
            Loan_Information__c = opp.id,
            Survey__c = survey.id, 
            Approval_Assigned__c = usr.id
        );
        insert app;
        return app;
    }

    public static FKD_Marketing__c createFKDMarketing_approval(String name, String agreementNo, String branchManager) {
        
        User usr = createSysAdminUser('adBFI');
        Account acc = createAccount('Testing');

        // Step 2: Create an Opportunity linked to the Account
        Opportunity opp = createOpportunity(acc, name + ' Opp', 5000, 'Prospecting', null);

        // Step 3: Create a Survey
        Survey__c survey = createSurvey(opp.id);

       
        Application__c app = new Application__c(
            Name = name,
            //Customer_Name__c = customerName,
            agreement_number__c = agreementNo,
            Branch_Manager__c = branchManager,
            Loan_Information__c = opp.id,
            Survey__c = survey.id, 
            Approval_Assigned__c = usr.id,
            CAA_Step__c = 0
        );
        insert app;

         Operation__c opr = new Operation__c(
            Name = 'Test',
            Application__c = app.Id
        );

        insert opr;

        FKD_Marketing__c fkm = new FKD_Marketing__c(
            Name = 'test FKD Marketing',
            Operation__c = opr.Id,
            Approval_Assigned__c = usr.id,
            Approval_Submitter__c = usr.id
        );
        insert fkm;

        

        return fkm;
    }

    public static List<API_Loan_Amortization__c> createAmortizations(Application__c app, Integer count, Decimal installment, Decimal principal, Decimal interest) {
        List<API_Loan_Amortization__c> amortList = new List<API_Loan_Amortization__c>();
        for (Integer i = 1; i <= count; i++) {
            amortList.add(new API_Loan_Amortization__c(
                Name = 'Amort ' + i,
                //Loan_Information__c = app.Id,
                related_id__c = app.Id,
                sequence__c = i,
                installment__c = installment,
                principal__c = principal,
                interest__c = interest
            ));
        }
        insert amortList;
        return amortList;
    }


    public static Account createAccount(String name) {

        Id personalRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Personal').getRecordTypeId();

        Account acc = new Account(Name = name != null ? name : 'Test Account', 
        RecordTypeId = personalRtId,
        ID_Number__c = '1234567890123456',
        Mobile_Phone_1__c = '628129319121',
        Mobile_Phone_2__c = '628129319122',
        NPWP_Number__c  = '1234567890123456',
        Date_of_Birth__c = Date.newInstance(1990, 1, 1)
        );
        insert acc;
        return acc;
    }

    // Create a test Opportunity with default Pricebook
    public static Opportunity createOpportunity(Account acc, String name, Decimal amount, String stage, Date closeDate) {
        //Pricebook2 pb = getStandardPricebook();

        Opportunity opp = new Opportunity(
            Name = name != null ? name : 'Test Opportunity',
            AccountId = acc.Id,
            StageName = stage != null ? stage : 'Prospecting',
            CloseDate = closeDate != null ? closeDate : Date.today().addDays(30),
            Amount = amount != null ? amount : 10000
            //Pricebook2Id = pb.Id
        );
        insert opp;
        return opp;
    }

    public static Survey__c createSurvey(String optyId) {
        Survey__c survey = new Survey__c(
            Name = 'testing',
            Opportunity__c = optyId
            
        );
        insert survey;
        return survey;
    }

}