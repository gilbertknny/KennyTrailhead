global with sharing class SCC_WiseLookupQueueable3 implements Queueable, Database.AllowsCallouts  {
    
    public Integer start { get; set; }
    public Map<Integer, String> mapIdStr { get; set; }
    public Integer ends { get; set; }

    @testVisible
    private static Boolean doChainJob = true;



    global SCC_WiseLookupQueueable3(Integer startIdx, Map<Integer, String> mapStr, Integer endIdx) {
        this.start = startIdx;
        this.mapIdStr = mapStr;
        this.ends = endIdx;
    }

    global void execute(QueueableContext context) {
        try {
            String idKnowledge = mapIdStr.get(start);
            if (idKnowledge.contains('Wise_Promo')) {
                List<RecordType> listId = [SELECT Id,Name FROM RecordType WHERE Name = 'Promotion'];
                List<String> splitId = idKnowledge.split('_');
                String id = splitId[0];
                String modifiedDt = splitId[1]; //modified date
                List<String> formatedModifiedDt = modifiedDt.split('T');//remove T from modified date
                Datetime updatedDt = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                SCC_WiseWrapper.ResponsePromoLookup detailPromo = SCC_Wise_Lookup.getPromoLookup(id);
                List<String> startDate = detailPromo.data.start.split('T');
                List<String> endDate = detailPromo.data.ends.split('T');

                String idWise = detailPromo.data.id;
                List<Knowledge__kav> knowledges = [SELECT Id,KnowledgeArticleId,SCC_Modified_Time__c FROM Knowledge__kav WHERE UrlName =:idWise LIMIT 1];

                Knowledge__kav newPromoRecord = new Knowledge__kav();
                newPromoRecord.Title = detailPromo.data.kategori;
                newPromoRecord.UrlName = detailPromo.data.id;
                newPromoRecord.SCC_Category__c = detailPromo.data.kategori;
                newPromoRecord.SCC_Merchant__c = detailPromo.data.merchant;
                newPromoRecord.SCC_Term_Condition__c = SCC_Wise_General.formatedRichText(detailPromo.data.syarat_dan_ketentuan);
                newPromoRecord.SCC_Location__c = detailPromo.data.lokasi;
                newPromoRecord.SCC_Benefit__c =  SCC_Wise_General.formatedRichText(detailPromo.data.benefit);
                newPromoRecord.SCC_Channel__c = String.join(detailPromo.data.channel, ', ');
                newPromoRecord.RecordTypeId = listId[0].Id;
                newPromoRecord.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                newPromoRecord.Hasil_Integrasi__c = True;
                newPromoRecord.SCC_Start__c = Date.valueOf(startDate[0]);
                newPromoRecord.SCC_End__c = Date.valueOf(endDate[0]);
                if(detailPromo.data.image != null){
                    newPromoRecord.Image__c = detailPromo.data.image[0].url;
                } else {
                    newPromoRecord.Image__c = '-';
                }


                if(!knowledges.isEmpty()){
                    Datetime lastDt = knowledges[0].SCC_Modified_Time__c;
                    if(lastDt != updatedDt){
                        String articleId = knowledges[0].KnowledgeArticleId;
                        String ids = KbManagement.PublishingService.editOnlineArticle (articleId, true);
                            if(ids != null){
                            Knowledge__kav kn = new Knowledge__kav();
                            List<Knowledge__kav> k = [SELECT Id, KnowledgeArticleId,PublishStatus FROM knowledge__kav WHERE Id =: ids];
                            String kId = k[0].Id;

                            //update data
                            kn.Id = kId;
                            kn.Title = detailPromo.data.kategori ;
                            kn.UrlName = detailPromo.data.id;
                            kn.SCC_Category__c = detailPromo.data.kategori;
                            kn.SCC_Merchant__c = detailPromo.data.merchant;
                            kn.SCC_Term_Condition__c = SCC_Wise_General.formatedRichText(detailPromo.data.syarat_dan_ketentuan);
                            kn.SCC_Location__c = detailPromo.data.lokasi;
                            kn.SCC_Benefit__c =  SCC_Wise_General.formatedRichText(detailPromo.data.benefit);
                            kn.SCC_Channel__c = String.join(detailPromo.data.channel, ', ');
                            kn.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                            kn.SCC_Start__c = Date.valueOf(startDate[0]);
                            kn.SCC_End__c = Date.valueOf(endDate[0]);
                            if(detailPromo.data.image != null){
                                kn.Image__c = detailPromo.data.image[0].url;
                            } else {
                                kn.Image__c = '-';
                            }
                            
                            update kn;
                            String idDraft = k[0].KnowledgeArticleId;
                            KbManagement.PublishingService.publishArticle(idDraft, true);      
                        }    
                    }else {
                        System.debug('date is same, no last modified');
                    }
                } else {
                        System.debug('Insert Data');
                        insert newPromoRecord;
                        
                        String newId = newPromoRecord.Id;
                        List<Knowledge__kav> draftPromo = [SELECT Id, KnowledgeArticleId FROM knowledge__kav WHERE Id =: newId];

                        String articleDraftId = draftPromo[0].KnowledgeArticleId;
                        KbManagement.PublishingService.publishArticle(articleDraftId, true); 
                }
            }

        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        } finally {
            start++;
            if (start <= ends) {
                ID jobID = System.enqueueJob(new SCC_WiseLookupQueueable3(start, mapIdStr, ends));
                System.debug('Enqueued next job with ID: ' + jobID);
            } else {
                if(doChainJob){
                    ID jobID4 = System.enqueueJob(new SCC_Wise4th());
                    System.debug('Go to 4nd produk');
                }
            }
        }
    }
}