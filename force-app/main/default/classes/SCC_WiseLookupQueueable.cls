/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SCC_WiseLookupQueueable implements Queueable, Database.AllowsCallouts {
    
    public Integer start { get; set; }
    public Map<Integer, String> mapIdStr { get; set; }
    public Integer ends { get; set; }

    @testVisible
    private static Boolean doChainJob = true;
    global SCC_WiseLookupQueueable(Integer startIdx, Map<Integer, String> mapStr, Integer endIdx) {
        this.start = startIdx;
        this.mapIdStr = mapStr;
        this.ends = endIdx;
    }

    global void execute(QueueableContext context) {
        try {
            String idKnowledge = mapIdStr.get(start);
            if (idKnowledge.contains('Wise_WorkingInstruction')) {
                List<RecordType> listId = [SELECT Id,Name FROM RecordType WHERE Name = 'Working Instructions'];
                List<String> splitId = idKnowledge.split('_');
                String id = splitId[0]; //id
                String modifiedDt = splitId[1]; //modified date
                List<String> formatedModifiedDt = modifiedDt.split('T');//remove T from modified date
                Datetime updatedDt = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                SCC_WiseWrapper.ResponseWiLookup detailWi = SCC_Wise_Lookup.getWorkingInstructionLookup(id);
                String idWise = detailWi.data.id;
                List<Knowledge__kav> knowledges = [SELECT Id,KnowledgeArticleId,SCC_Modified_Time__c FROM Knowledge__kav WHERE UrlName =:idWise LIMIT 1];

                Knowledge__kav newWiRecord = new Knowledge__kav();
                newWiRecord.Title = detailWi.data.calltype + ' - ' + detailWi.data.kategori + ' - ' + detailWi.data.sub_kategori;
                newWiRecord.UrlName = detailWi.data.id;
                newWiRecord.Record_Type__c = 'Working Instruction';
                newWiRecord.SCC_Call_Type__c = detailWi.data.calltype;
                newWiRecord.SCC_Category__c = SCC_Wise_General.formatedRichText(detailWi.data.kategori);
                newWiRecord.SCC_Sub_Category__c = SCC_Wise_General.formatedRichText(detailWi.data.sub_kategori);
                newWiRecord.SCC_Section__c = SCC_Wise_General.formatedRichText(detailWi.data.section);
				newWiRecord.SCC_Greeting__c = SCC_Wise_General.formatedRichText(detailWi.data.content.greeting);
                newWiRecord.SCC_Emphaty__c = SCC_Wise_General.formatedRichText(detailWi.data.content.empati);
                newWiRecord.SCC_Confirmation__c = SCC_Wise_General.formatedRichText(detailWi.data.content.konfirmasi);
                newWiRecord.SCC_Verification__c = SCC_Wise_General.formatedRichText(detailWi.data.content.verifikasi);
                newWiRecord.SCC_Checking__c = SCC_Wise_General.formatedRichText(detailWi.data.content.cek_laporan);
                newWiRecord.SCC_Get_Information__c = SCC_Wise_General.formatedRichText(detailWi.data.content.gali_informasi);
                newWiRecord.SCC_Create_Report__c = SCC_Wise_General.formatedRichText(detailWi.data.content.pembuatan_laporan);
                newWiRecord.SCC_Solution_Information__c = SCC_Wise_General.formatedRichText(detailWi.data.content.solusi);
                newWiRecord.SCC_Reconfirm__c = SCC_Wise_General.formatedRichText(detailWi.data.content.konfirmasi_ulang);
                newWiRecord.SCC_Education__c = SCC_Wise_General.formatedRichText(detailWi.data.content.edukasi_cross_selling);
                newWiRecord.SCC_Closing__c = SCC_Wise_General.formatedRichText(detailWi.data.content.closing);
                newWiRecord.SCC_User__c = convertCodeUser(detailWi.data.user);
                newWiRecord.RecordTypeId = listId[0].Id;
                newWiRecord.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
                newWiRecord.Hasil_Integrasi__c = True;


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
                            kn.Title = detailWi.data.calltype + ' - ' + detailWi.data.kategori + ' - ' + detailWi.data.sub_kategori;
                            kn.SCC_Call_Type__c = detailWi.data.calltype;
                            kn.Record_Type__c = 'Working Instruction';
                            kn.SCC_Category__c = SCC_Wise_General.formatedRichText(detailWi.data.kategori);
                            kn.SCC_Sub_Category__c = SCC_Wise_General.formatedRichText(detailWi.data.sub_kategori);
                            kn.SCC_Section__c = SCC_Wise_General.formatedRichText(detailWi.data.section);
                            kn.SCC_Greeting__c = SCC_Wise_General.formatedRichText(detailWi.data.content.greeting);
                            kn.SCC_Emphaty__c = SCC_Wise_General.formatedRichText(detailWi.data.content.empati);
                            kn.SCC_Confirmation__c = SCC_Wise_General.formatedRichText(detailWi.data.content.konfirmasi);
                            kn.SCC_Verification__c = SCC_Wise_General.formatedRichText(detailWi.data.content.verifikasi);
                            kn.SCC_Checking__c = SCC_Wise_General.formatedRichText(detailWi.data.content.cek_laporan);
                            kn.SCC_Get_Information__c = SCC_Wise_General.formatedRichText(detailWi.data.content.gali_informasi);
                            kn.SCC_Create_Report__c = SCC_Wise_General.formatedRichText(detailWi.data.content.pembuatan_laporan);
                            kn.SCC_Solution_Information__c = SCC_Wise_General.formatedRichText(detailWi.data.content.solusi);
                            kn.SCC_Reconfirm__c = SCC_Wise_General.formatedRichText(detailWi.data.content.konfirmasi_ulang);
                            kn.SCC_Education__c = SCC_Wise_General.formatedRichText(detailWi.data.content.edukasi_cross_selling);
                            kn.SCC_Closing__c = SCC_Wise_General.formatedRichText(detailWi.data.content.closing);
                            kn.SCC_User__c = convertCodeUser(detailWi.data.user);
                            kn.SCC_Modified_Time__c = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]);
    
                            update kn;
                            String idDraft = k[0].KnowledgeArticleId;
                            KbManagement.PublishingService.publishArticle(idDraft, true);       
                        } 
                    } else {
                        System.debug('date is same, no last modified');
                    }  

                } else {
                    System.debug('Insert Data');
                    insert newWiRecord;
                        
                    String newId = newWiRecord.Id;
                    List<Knowledge__kav> draftWi = [SELECT Id, KnowledgeArticleId FROM knowledge__kav WHERE Id =: newId];

                    String articleDraftId = draftWi[0].KnowledgeArticleId;
                    KbManagement.PublishingService.publishArticle(articleDraftId, true);
                }                
            }
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
        } finally {
            start++;
            if (start <= ends) {
                ID jobID = System.enqueueJob(new SCC_WiseLookupQueueable(start, mapIdStr, ends));
                System.debug('Enqueued next job with ID: ' + jobID);
            } 
            else {
                if(doChainJob){
                    ID jobID2 = System.enqueueJob(new SCC_Wise2nd());
                }   
            }         
        }
    }

    public static String convertCodeUser(string codeUser){
        Map <String,String> cdUser = new Map <String,String>();
        cdUser.put('cs','Customer Service');
        cdUser.put('agent', 'Agent Contact BRI');
        cdUser.put('satpam', 'Satpam');
        cdUser.put('teller', 'Teller');

        String userWi = cdUser.get(codeUser);

        return userWi;

    }
}