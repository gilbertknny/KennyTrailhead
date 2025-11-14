/**
 * Controller for LWC "input"
 * TC : GS
 * DATE : 10/10/25
 */

public without sharing class ClsInput {
    @AuraEnabled(cacheable=false)
    public static Map<String, String> picklistValues(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};
     	List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {  
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
}