@IsTest
public with sharing class ExportObjectsToMarkdown_Test {
     @IsTest
    static void testToMarkdownCreatesContentVersion() {
        Test.startTest();
        ExportObjectsToMarkdown.toMarkdown();
        Test.stopTest();

        // Query the ContentVersion created
        List<ContentVersion> cvs = [
            SELECT Id, Title, PathOnClient, VersionData
            FROM ContentVersion
            WHERE Title = 'Salesforce_Objects_Fields.md'
        ];

        System.assert(!cvs.isEmpty(), 'ContentVersion should have been created');
        System.assertEquals('Salesforce_Objects_Fields.md', cvs[0].Title, 'File title should match');
        System.assertEquals('Salesforce_Objects_Fields.md', cvs[0].PathOnClient, 'File path should match');
        System.assertNotEquals(null, cvs[0].VersionData, 'File content should not be null');
    }
}