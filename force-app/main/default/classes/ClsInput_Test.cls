@IsTest(SeeAllData=false)
public class ClsInput_Test {
	@TestSetup
    static void setTestData(){
        
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id,ContactId,Contact.Name FROM User WHERE Id =:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            String objectName = 'Location';
            String fieldName = 'LocationType';
            Map<String, String> mapResult = ClsInput.picklistValues(objectName,fieldName); 
            system.assertNotEquals(mapResult.size(),0);
            Test.stopTest();
        }
    }
}