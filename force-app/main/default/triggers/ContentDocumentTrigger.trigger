trigger ContentDocumentTrigger on ContentDocument (before insert,after insert,before update,after update,before delete,after delete) {
	if (Trigger.isBefore) {
        if (Trigger.isDelete) {
        	ContentDocument_Class.updateFile(Trigger.old, Trigger.oldMap);	    
        }
    }
}