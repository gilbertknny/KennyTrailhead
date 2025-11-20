global with sharing class SCC_WiseLookupQueueable2 implements Queueable, Database.AllowsCallouts  {
    
    public Integer start { get; set; }
    public Map<Integer, String> mapIdStr { get; set; }
    public Integer ends { get; set; }

    @testVisible
    private static Boolean doChainJob = true;
    global SCC_WiseLookupQueueable2(Integer startIdx, Map<Integer, String> mapStr, Integer endIdx) {
        this.start = startIdx;
        this.mapIdStr = mapStr;
        this.ends = endIdx;
    }

    global void execute(QueueableContext context) {
        try {
            String idKnowledge = mapIdStr.get(start);
            if (idKnowledge.contains('Wise_Produk')) {
                List<RecordType> listId = [SELECT Id,Name FROM RecordType WHERE Name = 'Product'];
                List<String> splitId = idKnowledge.split('_');
                String id = splitId[0];
                String modifiedDt = splitId[1]; //modified date
                List<String> formatedModifiedDt = modifiedDt.split('T');//remove T from modified date
                Datetime updatedDt = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                SCC_WiseWrapper.ResponseProdukLookup detailProduk = SCC_Wise_Lookup.getProdukLookup(id);
                String idWise = detailProduk.data.id;
                Boolean biayaFlag = detailProduk.data.biaya_flag;
                Boolean bungaFlag = detailProduk.data.bunga_flag;
                Boolean limitsFlag = detailProduk.data.limits_flag;
                List<Knowledge__kav> knowledges = [SELECT Id,KnowledgeArticleId,SCC_Modified_Time__c FROM Knowledge__kav WHERE UrlName =:idWise LIMIT 1];

                Knowledge__kav newProdukRecord = new Knowledge__kav();
                newProdukRecord.Title = detailProduk.data.jenis_produk + ' - ' + detailProduk.data.produk + ' - ' + detailProduk.data.varian_produk;
                newProdukRecord.UrlName = detailProduk.data.id;
				newProdukRecord.SCC_Category__c = SCC_Wise_General.formatedRichText(detailProduk.data.jenis_produk);
                newProdukRecord.Record_Type__c = 'Produk';
                newProdukRecord.SCC_Produk__c = SCC_Wise_General.formatedRichText(detailProduk.data.produk);
                newProdukRecord.SCC_Opening_Requirements__c = SCC_Wise_General.formatedRichText(detailProduk.data.syarat_pembukaan);
                newProdukRecord.SCC_Withdrawal_Closing_Requirements__c = SCC_Wise_General.formatedRichText(detailProduk.data.syarat_pencairan_penutupan);
                newProdukRecord.SCC_Feature__c = SCC_Wise_General.formatedRichText(detailProduk.data.fitur);
                // newProdukRecord.SCC_Limit__c = SCC_Wise_General.formatedRichText(detailProduk.data.limits);
                // newProdukRecord.SCC_Interest__c = SCC_Wise_General.formatedRichText(detailProduk.data.bunga);
                // newProdukRecord.SCC_Fee__c = SCC_Wise_General.formatedRichText(detailProduk.data.biaya);
                newProdukRecord.SCC_Product_Variant__c =SCC_Wise_General.formatedRichText(detailProduk.data.varian_produk);
                newProdukRecord.SCC_Product_Type__c = SCC_Wise_General.formatedRichText(detailproduk.data.jenis_produk);
                newProdukRecord.SCC_Definition__c = SCC_Wise_General.formatedRichText(detailproduk.data.definisi);
                newProdukRecord.Panduan_Penggunaan__c = SCC_Wise_General.formatedRichText(detailproduk.data.panduan_penggunaan);
                newProdukRecord.RecordTypeId = listId[0].Id;
                newProdukRecord.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                newProdukRecord.Hasil_Integrasi__c = True;
                newProdukRecord.Bunga_Flag__c = detailProduk.data.bunga_flag;
                newProdukRecord.Limit_Flag__c = detailProduk.data.limits_flag;
                newProdukRecord.Biaya_Flag__c = detailProduk.data.biaya_flag;

                if(!bungaFlag){
                    newProdukRecord.SCC_Interest__c =  SCC_Wise_General.formatedRichText(detailProduk.data.bunga);
                }

                if(!limitsFlag){
                    newProdukRecord.SCC_Limit__c =  SCC_Wise_General.formatedRichText(detailProduk.data.limits);
                }

                if(!biayaFlag){
                    newProdukRecord.SCC_Fee__c =  SCC_Wise_General.formatedRichText(detailProduk.data.biaya);
                }

                if(detailProduk.data.image != null){
                    newProdukRecord.Image__c = detailProduk.data.image[0].url;
                } else {
                    newProdukRecord.Image__c = '-';
                }

                if(!knowledges.isEmpty()){
                    Datetime lastDt = knowledges[0].SCC_Modified_Time__c;
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
                                kn.Title = detailProduk.data.jenis_produk + ' - ' + detailProduk.data.produk + ' - ' + detailProduk.data.varian_produk;
                                kn.UrlName = detailProduk.data.id;
                                kn.SCC_Category__c = SCC_Wise_General.formatedRichText(detailProduk.data.jenis_produk);
                                kn.SCC_Produk__c = SCC_Wise_General.formatedRichText(detailProduk.data.produk);
                                kn.SCC_Opening_Requirements__c = SCC_Wise_General.formatedRichText(detailProduk.data.syarat_pembukaan);
                                kn.SCC_Withdrawal_Closing_Requirements__c = SCC_Wise_General.formatedRichText(detailProduk.data.syarat_pencairan_penutupan);
                                kn.SCC_Feature__c = SCC_Wise_General.formatedRichText(detailProduk.data.fitur);
                                kn.SCC_Limit__c	 = SCC_Wise_General.formatedRichText(detailProduk.data.limits);
                                kn.SCC_Interest__c = SCC_Wise_General.formatedRichText(detailProduk.data.bunga);
                                kn.SCC_Fee__c = SCC_Wise_General.formatedRichText(detailProduk.data.biaya);
                                kn.SCC_Product_Variant__c =SCC_Wise_General.formatedRichText(detailProduk.data.varian_produk);
                                kn.SCC_Product_Type__c = SCC_Wise_General.formatedRichText(detailproduk.data.jenis_produk);
                                kn.SCC_Definition__c = SCC_Wise_General.formatedRichText(detailproduk.data.definisi);
                                kn.Panduan_Penggunaan__c = SCC_Wise_General.formatedRichText(detailproduk.data.panduan_penggunaan);
                                kn.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                                kn.Bunga_Flag__c = detailProduk.data.bunga_flag;
                                kn.Limit_Flag__c = detailProduk.data.limits_flag;
                                kn.Biaya_Flag__c = detailProduk.data.biaya_flag;

                                if(!bungaFlag){
                                    kn.SCC_Interest__c =  SCC_Wise_General.formatedRichText(detailProduk.data.bunga);
                                }
                
                                if(!limitsFlag){
                                    kn.SCC_Limit__c =  SCC_Wise_General.formatedRichText(detailProduk.data.limits);
                                }
                
                                if(!biayaFlag){
                                    kn.SCC_Fee__c =  SCC_Wise_General.formatedRichText(detailProduk.data.biaya);
                                }

                                if(detailProduk.data.image != null){
                                kn.Image__c = detailProduk.data.image[0].url;
                                } else {
                                    kn.Image__c = '-';
                                }

                                update kn;
                                String idDraft = k[0].KnowledgeArticleId;
                                KbManagement.PublishingService.publishArticle(idDraft, true);              
                        }  
                    } else {
                        System.debug('date is same, no last modified');
                    }
                } else {
                        System.debug('Insert Data');
                        insert newProdukRecord;
                        
                        String newId = newProdukRecord.Id;
                        List<Knowledge__kav> draftProduk = [SELECT Id, KnowledgeArticleId FROM knowledge__kav WHERE Id =: newId];

                        String articleDraftId = draftProduk[0].KnowledgeArticleId;
                        KbManagement.PublishingService.publishArticle(articleDraftId, true);
                }
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        } finally {
            start++;
            if (start <= ends) {
                ID jobID = System.enqueueJob(new SCC_WiseLookupQueueable2(start, mapIdStr, ends));
                System.debug('Enqueued next job with ID: ' + jobID);
            } 
            else {
                if(doChainJob){
                    ID jobID2 = System.enqueueJob(new SCC_Wise3rd());
                }   
            }
        }
    }
}