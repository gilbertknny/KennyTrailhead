public class ContentDocument_Class {
	public static void updateFile(ContentDocument[] newList, Map<Id, ContentDocument> oldMap) {
        List<String> listids = new List<String>();
        for(ContentDocument cd : newList){
        	listids.add(cd.Id);	    
        }
        List<ContentDocumentLink> listcdl = [SELECT Id,LinkedEntityId 
                                             FROM ContentDocumentLink WHERE ContentDocumentId IN:listids];
        List<String> liststr = new List<String>();
        for(ContentDocumentLink cdl : listcdl){
            String caseid = cdl.LinkedEntityId;
            if(caseid != null){
                if(caseid.startsWith('500')) liststr.add(caseid);
            }
        }
        if(liststr.size()>0) updateCase(liststr);
    }
    
    @future
    public static void updateCase(List<String> liststr){
        Set<Case> setcs = new Set<Case>();
        List<Case> listcs = new List<Case>();
        List<Case> result = new List<Case>();
        for(String str : liststr){
            Case cs = new Case();
            cs.Id = str;
            listcs.add(cs);
        }
        setcs.addAll(listcs);
        result.addAll(setcs);
        if(result.size()>0) update result;
    }
}