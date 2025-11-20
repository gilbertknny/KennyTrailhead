trigger deleteSubCaseMasterData on Sub_Case_Reference__c (before delete) {
list<SSC_Call_Type__c> listCaseType=[SELECT id, SCC_Sub_Description__c from SSC_Call_Type__c type LIMIT 10000];
for(Sub_Case_Reference__c SCR:trigger.old)
{
      list<SSC_Call_Type__c> CaseTypeUpdate=new list<SSC_Call_Type__c>();
       for(SSC_Call_type__c CaseType:listCaseType)
       {
              boolean upd=false;
              if(CaseType.SCC_Sub_Description__c!=null && CaseType.SCC_Sub_Description__c!='')
              {
                     
                     if(CaseType.SCC_sub_description__c.contains(';'))
                     {
                            list<String> listSub=CaseType.SCC_sub_description__c.split(';');
                            list<String> joinSub=new list<String>();
                            for(String Sub:listSub)
                            {     
                                   if(Sub!=SCR.sub_case_code__c)
                                   {
                                          joinSub.add(Sub);
                                   }
                                   else
                                   {
                                          upd=true;
                                   }
                            }
                            CaseType.SCC_sub_description__c=String.join(joinSub,';');
                     }
                     else
                     {
                            if(CaseType.SCC_sub_description__c==SCR.sub_case_code__c)
                            {
                                   upd=true;
                                   CaseType.SCC_sub_description__c='';
                            }
                     }
                     if(upd==true)
                     {
                            CaseTypeUpdate.add(CaseType);
                     }
              }
       }
       if(CaseTypeUpdate.size()>0)
       {
              update CaseTypeUpdate;
       }

}


}