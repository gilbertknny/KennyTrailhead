@isTest
public class DeleteWorkItemHandlerTest {

     @isTest
    static void testFetchProjects() {
        // Test fetchProjects method
        List<sf_devops__Project__c> projects = DeleteWorkItemHandler.fetchProjects();
        // Perform assertions based on the expected behavior of the fetchProjects method
        System.assertNotEquals(null, projects);
        // Add more assertions as needed
    }

    @isTest
    static void testGetAllWorkItems() {
        // Test getAllWorkItems method
        String projectName = 'TestProject';
        List<sf_devops__Work_Item__c> workItems = DeleteWorkItemHandler.getAllWorkItems(projectName);
        // Perform assertions based on the expected behavior of the getAllWorkItems method
        System.assertNotEquals(null, workItems);
        // Add more assertions as needed
    }

    @isTest
    static void testDeleteSelectedWorkItem() {
        // Test deleteSelectedWorkItem method

        // Create test data (e.g., projects, work items, change submissions) as needed
        // Ensure that the test data includes the work items to be deleted

        // Call the deleteSelectedWorkItem method with the test data
        List<sf_devops__Work_Item__c> testWorkItems = [SELECT Id, Name FROM sf_devops__Work_Item__c LIMIT 5];
        DeleteWorkItemHandler.deleteSelectedWorkItem(testWorkItems);

        // Perform assertions based on the expected behavior of the deleteSelectedWorkItem method
        // Verify that the work items and related records are deleted as expected

        // Add more assertions as needed
    }
}