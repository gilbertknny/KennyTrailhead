/**
 * @description ContentVersion_Manager
 */
public with sharing class ContentVersion_Manager {
    /**
     * @description crud
     * @param listdoc
     */
    public static void crud(List<ContentVersion> listdoc){
        List<ContentDocumentLink> listcdl = new List<ContentDocumentLink>();
        List<Map<String,Object>> listmap = new List<Map<String,Object>>();
        
        for(ContentVersion conVer:listdoc){
            Map<String,Object> mapsobj = new Map<String,Object>();
            mapsobj.put('id',conVer.Id);
            mapsobj.put('success',true);
            mapsobj.put('error', new List<String>());
            listmap.add(mapsobj);
            if(trigger.isbefore){
                if(trigger.isinsert){
                    ContentVersion_Manager.beforeinsert(conVer);
                }
            }
            if(trigger.isafter){
                if(trigger.isinsert){
                    ContentVersion_Manager.afterinsert(conVer,listcdl);
                }
            }
        }

        if(!listcdl.isEmpty()){
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                insert listcdl;
            }
            String jsonbd = JSON.serialize(listdoc);
            ErrorLogRecord.DebugLog dl = new ErrorLogRecord.DebugLog();
            dl.classname = 'ContentVersion_Manager';
            dl.statusCode = 200;
            dl.typeApi = 'Inbound';
            dl.iduser = UserInfo.getUserId();
            dl.body = jsonbd;
            dl.responseBody = JSON.serialize(listmap);
            ErrorLogRecord.inserterrorAPI(JSON.serialize(dl));
        }
    }
    /**
     * @description crud
     * @param conVer
     */
    private static void beforeinsert(ContentVersion conVer){
        if(String.isNotBlank(conver.fieldtype__c) && String.isNotBlank(conver.LinkedEntityId__c)){
            conVer.SyncFile__c = true;   
        }
    }

    /**
     * @description crud
     * @param conVer
     * @param listcdl
     */
    private static void afterinsert(ContentVersion conVer,List<ContentDocumentLink> listcdl){
        String fieldtype = conver.fieldtype__c;
        String linkedEntityId = conver.LinkedEntityId__c;
        if(String.isNotBlank(fieldtype) && String.isNotBlank(LinkedEntityId)){
            ContentDocumentLink cdl = new ContentDocumentLink();
            Id recordId ;
            if(fieldtype=='Salesforce'){
                recordId = linkedEntityId;
            }
            else{
                Upload_File_Mapping__mdt ufm = Upload_File_Mapping__mdt.getInstance(String.escapeSingleQuotes(conver.fieldtype__c));
                SObject sobj = database.query('Select Id from '+String.escapeSingleQuotes(ufm.Object__c)+' where '+String.escapeSingleQuotes(ufm.Field__c)+' = : linkedEntityId');
                recordId = (String) sobj.get('Id');
            }
            cdl.ContentDocumentId = conVer.ContentDocumentId;
            cdl.LinkedEntityId = recordId; // you can use objectId,GroupId etc
            cdl.ShareType = 'V'; // Inferred permission, checkout description of ContentDocumentLink object for more details
            cdl.Visibility = 'AllUsers';
            listcdl.add(cdl);
        }
    }
}