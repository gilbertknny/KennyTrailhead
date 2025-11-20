@IsTest
private class EventMonitoring_API_Ctrl_test {
    
    @TestSetup
    static void setupTestData() {
        // FIRST: Create all users (Setup objects)
        User us = Object_Test.setUser('KP00','PS98502','00113','test1@test1user.com','test1@test1user.com');
        System.debug('Test User before insert: ' + us);
        insert us;
        
        // Verify the user after insert
        User insertedUser = [SELECT Id, Name, SCC_Area__c, SCC_Branch__c, SCC_Division__c, SCC_Cost_Center__c 
                            FROM User WHERE Id = :us.Id];
        System.debug('Inserted User details: ' + insertedUser);
        // Use System.runAs to perform non-setup object DML
        System.runAs(us) {
            // Create all non-setup objects
            Orgeh__c og = Object_Test.setOrgeh();
            insert og;
            
            // Create test data
            Orgeh__c og1 = new Orgeh__c(
                Cost_Center__c = 'PS85000',
                Cost_Center_Description__c = 'DIVISI SENTRA OPERASI'
            );
            Orgeh__c og2 = new Orgeh__c(
                Cost_Center__c = 'PS98502',
                Cost_Center_Description__c = 'DIVISI SERVICE & CONTACT CENTER'
            );
            insert new List<Orgeh__c>{og1, og2};

            // Create test branch Unit
            Branch_Unit__c bu1 = Object_Test.setBranchUnit('113','CABANG','113','B');
            Branch_Unit__c bu2 = Object_Test.setBranchUnit('51','KANWIL','51','D');
            Branch_Unit__c bu3 = Object_Test.setBranchUnit('52','KANWIL','52','E');
            Branch_Unit__c bu4 = Object_Test.setBranchUnit('53','KANWIL','53','F');
            Branch_Unit__c bu5 = Object_Test.setBranchUnit('54','CABANG','54','G');
            Branch_Unit__c bu6 = Object_Test.setBranchUnit('55','CABANG','55','H');
            Branch_Unit__c bu7 = Object_Test.setBranchUnit('56','CABANG','56','I');
            insert new List<Branch_Unit__c>{bu1, bu2, bu3, bu4, bu5, bu6, bu7};

            Anomali_Category__c ac = Object_Test.setAnomaly(us.Id);
            insert ac;

            Anomali_Category__c insertedAnomaly = [
                SELECT Id, Name, RecordType.Name, RecordType.DeveloperName 
                FROM Anomali_Category__c 
                WHERE Id = :ac.Id
            ];

            System.debug('Found Anomali_Category__c: ' + ac.RecordType.Name);
            System.debug('Anomaly RecordType Name: ' + insertedAnomaly.RecordType.Name);
            System.debug('Anomaly RecordType DeveloperName: ' + insertedAnomaly.RecordType.DeveloperName);


            // Create test Monitoring Summary
            Monitoring_Summary__c ms = Object_Test.setMonitoringSum(ac.Id, us.Id);
            Monitoring_Summary__c ms1 = Object_Test.setMonitoringSum(ac.Id, us.Id);
            insert new List<Monitoring_Summary__c>{ms, ms1};

            Monitoring_Summary__c queriedMs = [
                SELECT Id, Divisi__c, Anomali_Category__r.RecordType.Name
                FROM Monitoring_Summary__c LIMIT 1
            ];
            // Debug logs to confirm
            System.debug('Anomaly RecordType Name: ' + queriedMs.Anomali_Category__r.RecordType.Name);
        }
    }

    @IsTest
    static void getEvMontMissingMandatoryDate() {
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestKPDateBlankModel();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.evMontResponseKPModel();
        EventMonitoring_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontMissingMandatoryArea() {
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestBlankAreaModel();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontKP() {
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestKPModel();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseKP_Model resrcc = Object_Test.evMontResponseKPModel();
        EventMonitoring_API_Ctrl.returnAPIKP(resrcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontKP1() {
        List<Monitoring_Summary__c> lms = [SELECT Id, Area__c, Anomali_Category__r.Name, Anomali_Category__r.RecordType.Name FROM Monitoring_Summary__c];
        System.debug('List Monitoring :'+ lms);
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestKP1Model();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseKP1_Model resrcc = Object_Test.evMontResponseKP1Model();
        EventMonitoring_API_Ctrl.returnAPIKP1(resrcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontRO() {
        User testUser = [SELECT Id, SCC_Area__c, SCC_Branch__c FROM User WHERE Email = 'test1@test1user.com' LIMIT 1];
        System.debug('Test User before update: ' + testUser);

        // Update User fields
        testUser.SCC_Area__c = 'KW002';
        update testUser;
        User usr = [SELECT Id, SCC_Area__c, SCC_Branch__c, Branch_Unit__c, BranchCode__c, SCC_Cost_Center__c FROM User WHERE Email = 'test1@test1user.com' LIMIT 1];
        System.debug('List User :'+ usr);
        List<Branch_Unit__c> lbu = [SELECT Id, BranchCode__c, Region__c, Kode_Cabang__c, Uker_Type__c FROM Branch_Unit__c];
        System.debug('List Branch Unit :'+ lbu);
        List<Monitoring_Summary__c> lms = [SELECT Id, Area__c, Branch_Code__c, Main_Branch__c, Region__c FROM Monitoring_Summary__c];
        System.debug('Monitoring Sumaary :'+lms);
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestROModel();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseRO_Model resrcc = Object_Test.evMontResponseROModel();
        EventMonitoring_API_Ctrl.returnAPIRO(resrcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontRO1() {
        User testUser = [SELECT Id, SCC_Area__c, SCC_Branch__c FROM User WHERE Email = 'test1@test1user.com' LIMIT 1];
        System.debug('Test User before update: ' + testUser);

        // Update User fields
        testUser.SCC_Area__c = 'KW002';
        update testUser;
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestRO1Model();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseRO1_Model resrcc = Object_Test.evMontResponseRO1Model();
        EventMonitoring_API_Ctrl.returnAPIRO1(resrcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontRO2() {
        User testUser = [SELECT Id, SCC_Area__c, SCC_Branch__c FROM User WHERE Email = 'test1@test1user.com' LIMIT 1];
        System.debug('Test User before update: ' + testUser);

        // Update User fields
        testUser.SCC_Area__c = 'KW002';
        update testUser;
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestRO2Model();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseRO2_Model resrcc = Object_Test.evMontResponseRO2Model();
        EventMonitoring_API_Ctrl.returnAPIRO2(resrcc);
        Test.stopTest();
    }

    @IsTest
    static void getEvMontRO3() {
        User testUser = [SELECT Id, SCC_Area__c, SCC_Branch__c FROM User WHERE Email = 'test1@test1user.com' LIMIT 1];
        System.debug('Test User before update: ' + testUser);

        // Update User fields
        testUser.SCC_Area__c = 'KW002';
        update testUser;
        Test.startTest();
        EventMonitoring_API_Wrapper.GetRequest_Model rcc = Object_Test.evMonRequestRO3Model();
        EventMonitoring_API_Ctrl.getEventMonitoring(rcc);
        EventMonitoring_API_Wrapper.GetResponseRO3_Model resrcc = Object_Test.evMontResponseRO3Model();
        EventMonitoring_API_Ctrl.returnAPIRO3(resrcc);
        Test.stopTest();
    }
}