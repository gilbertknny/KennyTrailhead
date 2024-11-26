global with sharing class SCC_WiseLookupQueueable4 implements Queueable, Database.AllowsCallouts  {
    
    public Integer start { get; set; }
    public Map<Integer, String> mapIdStr { get; set; }
    public Integer ends { get; set; }

    global SCC_WiseLookupQueueable4(Integer startIdx, Map<Integer, String> mapStr, Integer endIdx) {
        this.start = startIdx;
        this.mapIdStr = mapStr;
        this.ends = endIdx;
    }

    global void execute(QueueableContext context) {
        try {
            String idKnowledge = mapIdStr.get(start);
            if (idKnowledge.contains('Wise_Program')) {
                List<RecordType> listId = [SELECT Id,Name FROM RecordType WHERE Name = 'Program'];
                List<String> splitId = idKnowledge.split('_');
                String id = splitId[0];
                String modifiedDt = splitId[1]; //modified date
                List<String> formatedModifiedDt = modifiedDt.split('T');//remove T from modified date
                Datetime updatedDt = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                SCC_WiseWrapper.ResponseProgramLookup detailProgram = SCC_Wise_Lookup.getProgramLookup(id);
                List<String> startDate = detailProgram.data.start.split('T');
                List<String> endDate = detailProgram.data.ends.split('T');

                String idWise = detailProgram.data.id;
                List<Knowledge__kav> knowledges = [SELECT Id,KnowledgeArticleId,SCC_Modified_Time__c FROM Knowledge__kav WHERE UrlName =:idWise LIMIT 1];

                Knowledge__kav newProgramRecord = new Knowledge__kav();
                newProgramRecord.Title = detailProgram.data.nama;
                newProgramRecord.UrlName = detailProgram.data.id;
                newProgramRecord.SCC_Program_Name__c = detailProgram.data.nama;
                newProgramRecord.Description__c = SCC_Wise_General.formatedRichText(detailProgram.data.deskripsi);
                newProgramRecord.SCC_Benefit__c = SCC_Wise_General.formatedRichText(detailProgram.data.benefit);
                newProgramRecord.SCC_Term_Condition__c = SCC_Wise_General.formatedRichText(detailProgram.data.syarat_ketentuan);
                newProgramRecord.RecordTypeId = listId[0].Id;
                newProgramRecord.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                newProgramRecord.Hasil_Integrasi__c = True;
                newProgramRecord.SCC_Start__c = Date.valueOf(startDate[0]); 
                newProgramRecord.SCC_End__c = Date.valueOf(endDate[0]);
                if(detailProgram.data.image != null){
                    newProgramRecord.Image__c = detailProgram.data.image[0].url;
                } else {
                    newProgramRecord.Image__c = '-';
                }

                if(!knowledges.isEmpty()){
                    Datetime lastDt =  knowledges[0].SCC_Modified_Time__c;
                    if(lastDt != updatedDt){
                        String articleId = knowledges[0].KnowledgeArticleId;
                        String ids = KbManagement.PublishingService.editOnlineArticle (articleId, true);
                        System.debug('new article id : ' + ids);  

                        if(ids != null){
                            Knowledge__kav kn = new Knowledge__kav();
                            List<Knowledge__kav> k = [SELECT Id, KnowledgeArticleId,PublishStatus FROM knowledge__kav WHERE Id =: ids];
                            String kId = k[0].Id;
                            //update data
                            kn.Id = kId;
                            kn.Title = detailProgram.data.nama;
                            kn.UrlName = detailProgram.data.id;
                            kn.SCC_Program_Name__c = detailProgram.data.nama;
                            kn.Description__c = SCC_Wise_General.formatedRichText(detailProgram.data.deskripsi);
                            kn.SCC_Benefit__c = SCC_Wise_General.formatedRichText(detailProgram.data.benefit);
                            kn.SCC_Term_Condition__c = SCC_Wise_General.formatedRichText(detailProgram.data.syarat_ketentuan);
                            kn.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                            kn.SCC_Start__c = Date.valueOf(startDate[0]); 
                            kn.SCC_End__c = Date.valueOf(endDate[0]);
                            if(detailProgram.data.image != null){
                                kn.Image__c = detailProgram.data.image[0].url;
                            } else {
                                kn.Image__c = '-';
                            }

                            update kn;
                            String idDraft = k[0].KnowledgeArticleId;
                            KbManagement.PublishingService.publishArticle(idDraft, true);          
                        }
                    }else{
                        System.debug('date is same, no last modified');
                    }
                } else {
                        System.debug('Insert Data');
                        insert newProgramRecord;
                        
                        String newId = newProgramRecord.Id;
                        List<Knowledge__kav> draftProgram = [SELECT Id, KnowledgeArticleId FROM knowledge__kav WHERE Id =: newId];

                        String articleDraftId = draftProgram[0].KnowledgeArticleId;
                        KbManagement.PublishingService.publishArticle(articleDraftId, true);
                        
                    
                }
                
            }


        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        } finally {
            start++;
            if (start <= ends) {
                ID jobID = System.enqueueJob(new SCC_WiseLookupQueueable4(start, mapIdStr, ends));
            } 
        }
    }
}