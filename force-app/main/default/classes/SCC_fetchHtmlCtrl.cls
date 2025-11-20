/**
 * @description       : Controller to handle iframe URL generation
 * @author            : Ardyta Yudianto
 * @group             : 
 * @last modified on  : 13-02-2025
 * @last modified by  : Ardyta Yudianto
**/
public with sharing class SCC_fetchHtmlCtrl {
    @AuraEnabled(cacheable=true)
    public static String getIframeUrl() {
        try {
            // Return the URL that will be used in the iframe
            return 'http://172.20.15.69';
        } catch (Exception e) {
            throw new AuraHandledException('Error generating iframe URL: ' + e.getMessage());
        }
    }
}