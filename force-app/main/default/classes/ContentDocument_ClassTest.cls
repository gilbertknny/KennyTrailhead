@isTest
public class ContentDocument_ClassTest {
	@testSetup static void setup(){
        Case cs = new Case();
        insert cs;
    }
    
    static testMethod void testProcess(){
        Case cs = [SELECT Id FROM Case LIMIT 1];
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.origin = 'H';
        insert content;

        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=cs.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        delete cd;
    }
}