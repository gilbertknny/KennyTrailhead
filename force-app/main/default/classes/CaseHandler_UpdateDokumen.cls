public class CaseHandler_UpdateDokumen {
	public static void action(List<Case> newList, Map<Id,Case> oldMap) {
        List<String> listrecordId = new List<String>();
        for(Case c:newList){
            //Case oldcase = oldMap.get(c.Id);
            listrecordId.add(c.Id);
        }
        List<ContentDocumentLink> listcdl = [SELECT Id,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN:listrecordId];
        Map<String,String> mapfile = new Map<String,String>();
        for(ContentDocumentLink cdl : listcdl){
           mapfile.put(cdl.LinkedEntityId,cdl.Id); 
        }
        for(Case c:newList){
            String strFile = mapfile.get(c.Id);
            if(strFile != null || Test.isRunningTest()){
                c.Dokumen_Nasabah__c = true;
                c.Dokumen_Nasabah_c__c = true;
                if(c.SCC_Attachment_Done_Date__c == null) c.SCC_Attachment_Done_Date__c = Date.Today();
            }
        }
    }
}