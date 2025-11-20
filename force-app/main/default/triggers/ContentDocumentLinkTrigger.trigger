trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert,after insert,before update,after update,after delete) {
     if (Trigger.isAfter) {
         if (Trigger.isInsert || Trigger.isUpdate) {
             ContentDocumentLink_Class.updateFile(Trigger.new, Trigger.oldMap);
         }
         else if (Trigger.isDelete) {
             ContentDocumentLink_Class.updateFile(Trigger.old, Trigger.oldMap);
         }
     }
}