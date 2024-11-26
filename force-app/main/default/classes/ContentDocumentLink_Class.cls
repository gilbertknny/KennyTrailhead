public class ContentDocumentLink_Class {
	public static void updateFile(ContentDocumentLink[] newList, Map<Id, ContentDocumentLink> oldMap) {
        List<Case> listcs = new List<Case>();
        List<String> listcaseid = new List<String>();
        for(ContentDocumentLink cdl : newList){
            String strId = cdl.LinkedEntityId;
            if(strId.startsWith('500')) listcaseid.add(strId);
        }
        List<Case> listcase = [SELECT Id,Dokumen_Nasabah_c__c FROM Case WHERE Id IN:listcaseid];
        for(Case cs : listcase){
            if(cs.Dokumen_Nasabah_c__c == false) listcs.add(cs);
        }
        if(listcs.size()>0) update listcs;
    }
}