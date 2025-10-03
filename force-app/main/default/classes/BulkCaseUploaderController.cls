/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-18-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class BulkCaseUploaderController {
    @AuraEnabled
    public static void uploadCases(String caseData) {
        try {
            List<Map<String, Object>> rows = (List<Map<String, Object>>) JSON.deserializeUntyped(caseData);
            List<Case> caseList = new List<Case>();

            for (Map<String, Object> row : rows) {
                Case c = new Case();
                c.Subject = (String) row.get('Subject');
                c.Status = (String) row.get('Status');
                c.Priority = (String) row.get('Priority');
                caseList.add(c);
            }

            if (!caseList.isEmpty()) {
                insert caseList;
            }
        } catch (Exception e) {
            throw new AuraHandledException('Upload gagal: ' + e.getMessage());
        }
    }
}