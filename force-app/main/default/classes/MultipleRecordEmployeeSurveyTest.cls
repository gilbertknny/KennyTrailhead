@isTest
private class MultipleRecordEmployeeSurveyTest {
    
    @TestSetup
    static void setupTestData() {
        String surveyId = System.Label.employee_feedback_id;
        Employee_Survey__c inactiveSurvey = new Employee_Survey__c(
            Survey__c = surveyId,
            Active__c = false,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(5)
        );
        insert inactivesurvey;
    }
    
    @isTest
    static void testInsertActiveEmployeeSurvey() {
        String surveyId = System.Label.employee_feedback_id;
        Employee_Survey__c firstActiveSurvey = new Employee_Survey__c(
            Active__c = true,
            Survey__c = surveyId,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(5)
        );
        
        Test.startTest();
        Database.SaveResult result = Database.insert(firstActiveSurvey, false);
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'First active survey should be inserted successfully');
        
        Employee_Survey__c secondActiveSurvey = new Employee_Survey__c(
            Active__c = true,
            Survey__c = surveyId,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(5)
        );
        
        Database.SaveResult result2 = Database.insert(secondActiveSurvey, false);
        
        System.assert(!result2.isSuccess(), 'Second active survey should fail to insert');
        System.assertEquals('Anda tidak boleh memiliki lebih dari 1 employee survey yang aktif', 
                          result2.getErrors()[0].getMessage(), 
                          'Error message should match');
    }
    
    @isTest
    static void testUpdateToActiveEmployeeSurvey() {
        String surveyId = System.Label.employee_feedback_id;
        Employee_Survey__c inactiveSurvey = [SELECT Id, Active__c 
                                           FROM Employee_Survey__c 
                                           WHERE Active__c = false LIMIT 1];
        
        Employee_Survey__c activeSurvey = new Employee_Survey__c(
            Survey__c = surveyId,
            Active__c = false,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(5)
        );
        insert activeSurvey;
        
        inactiveSurvey.Active__c = true;
        
        Test.startTest();
        Database.SaveResult result = Database.update(inactiveSurvey, false);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateToInactiveEmployeeSurvey() {
        
        String surveyId = System.Label.employee_feedback_id;
        Employee_Survey__c activeSurvey = new Employee_Survey__c(
            Active__c = true,
            Survey__c = surveyId,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(5)
        );
        insert activeSurvey;
        
        activeSurvey.Active__c = false;
        
        Test.startTest();
        Database.SaveResult result = Database.update(activeSurvey, false);
        Test.stopTest();
        
        System.assert(result.isSuccess(), 'Update to inactive should succeed');
    }
    
  
}