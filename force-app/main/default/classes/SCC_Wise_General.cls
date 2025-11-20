public with sharing class SCC_Wise_General {

    public class wrapperWiseGeneral{
        public Map<Integer,String> categorize {get; set;}
        public Integer total {get; set;}
        public wrapperWiseGeneral(Map<Integer,String> categorize, Integer total){
            this.categorize = categorize;
            this.total = total;
        }    
    }

   public static SCC_WiseWrapper.RequestWorkingInstruction reqCons(Integer limits, Integer page){
        SCC_WiseWrapper.RequestWorkingInstruction reqWi = new SCC_WiseWrapper.RequestWorkingInstruction();
        reqWi.limits = limits;
        reqWi.page = page;
        reqWi.search = '';
        reqWi.sort_at = 'desc';
        reqWi.sort_by = 'modified_date';
        reqWi.user = new List<String>{};
        return reqWi;
   } 

   public static SCC_WiseWrapper.RequestProduk reqProds(Integer limits, Integer page){
        SCC_WiseWrapper.RequestProduk reqProduk = new SCC_WiseWrapper.RequestProduk();
        reqProduk.limits = limits;
        reqProduk.page = page;
        reqProduk.search = '';
        reqProduk.sort_at = 'desc';
        reqProduk.sort_by = 'modified_date';
        reqProduk.produk = new List<String>{};
        reqProduk.jenis_produk = new List<String>{};
        return reqProduk;
   }

   public static SCC_WiseWrapper.RequestProgram reqProgs(Integer limits,Integer page){
        SCC_WiseWrapper.RequestProgram reqProgram = new SCC_WiseWrapper.RequestProgram();
        reqProgram.limits = limits;
        reqProgram.page = page;
        reqProgram.search = '';
        reqProgram.sort_at = 'desc';
        reqProgram.sort_by = 'modified_date';
        reqProgram.start_date = null;
        reqProgram.end_date = null;
        return reqProgram;
   }

   public static SCC_WiseWrapper.RequestPromo reqPromos(Integer limits, Integer page){
        SCC_WiseWrapper.RequestPromo reqPromo = new SCC_WiseWrapper.RequestPromo();
        reqPromo.limits = limits;
        reqPromo.page = page;
        reqPromo.search = '';
        reqPromo.sort_at = 'desc';
        reqPromo.sort_by = 'modified_date';
        reqPromo.kategori = new List<Integer>{};
        reqPromo.channel = new List<Integer>{};
        return reqPromo;
   }




   public static SCC_Wise_General.wrapperWiseGeneral getWiseListId(String type){

            List<String> listIdWise = new List<String>();
            Map<Integer,String> categorizedIds = new Map<Integer,String>();
            Integer total = 0 ;


            if(type == 'WI'){
                SCC_WiseWrapper.RequestWorkingInstruction reqWi = reqCons(20, 1);
                SCC_WiseWrapper.ResponseWorkingInstruction resWi = SCC_Wise_List.getWorkingInstructionList(reqWi);
                List<SCC_WiseWrapper.ResponseDataWi> listWi = resWi.data.data;

                
                
                if(listWi != null){
                    Datetime now = System.now();
                    Datetime dt1 = Datetime.newInstance(now.date().addDays(-1), Time.newInstance(21, 0, 0, 0));
                    Datetime dt2 = Datetime.newInstance(now.date(), Time.newInstance(20, 59, 59, 0));
        
                    for(Integer i = 0; i < listWi.size(); i++){
                        String dateApi = listWi[i].modified_date;
                        List<String> formatedModifiedDt = dateApi.split('T');//remove T from modified date
                        Datetime dtApi = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]); 
                        
                        if(dtApi >= dt1 && dtApi <= dt2){
                            System.debug('masuk');
                            listIdWise.add(listWi[i].id_knowledge+'_'+listWi[i].modified_date);
                        } else {
                            System.debug('tidak');
                            System.debug('tanggal wise wi:' + dtApi);
                        }
                    }


                    // for(Integer i = 0; i < listWi.size(); i++){
                    //     listIdWise.add(listWi[i].id_knowledge+'_'+listWi[i].modified_date);
                    // }
                }

                if(listIdWise != null && !listIdWise.isEmpty() ){
                    for(String wi:listIdWise){
                        total++;
                        categorizedIds.put(total , wi + '_Wise_WorkingInstruction');
                    }
                }

            }


            if(type == 'Produk'){
                SCC_WiseWrapper.RequestProduk reqProduk = reqProds(20, 1);
                SCC_WiseWrapper.ResponseProduk resProduk = SCC_Wise_List.getProdukList(reqProduk);
                List<SCC_WiseWrapper.ResponseDataProduk> listProduk = resProduk.data.data;

                if(listProduk != null){
                    Datetime now = System.now();
                    Datetime dt1 = Datetime.newInstance(now.date().addDays(-1), Time.newInstance(21, 0, 0, 0));
                    Datetime dt2 = Datetime.newInstance(now.date(), Time.newInstance(20, 59, 59, 0));
        
                    for(Integer i = 0; i < listProduk.size(); i++){
                        String dateApi = listProduk[i].modified_date;
                        List<String> formatedModifiedDt = dateApi.split('T');//remove T from modified date
                        Datetime dtApi = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]); 
                        
                        if(dtApi >= dt1 && dtApi <= dt2){
                            System.debug('masuk');
                            listIdWise.add(listProduk[i].id+'_'+listProduk[i].modified_date);
                        } else {
                            System.debug('tidak');
                            System.debug('tanggal wise produk:' + dtApi);
                        }
                    }

                    // for(Integer i = 0; i < listProduk.size(); i++){
                    //     listIdWise.add(listProduk[i].id+'_'+listProduk[i].modified_date);
                    // }
                }

                if(listIdWise != null && !listIdWise.isEmpty() ){
                    for(String produk:listIdWise){
                        total++;
                        categorizedIds.put(total,produk + '_Wise_Produk' );
                    }
                }
            }


            if(type == 'Program'){
                SCC_WiseWrapper.RequestProgram reqProgram = reqProgs(20, 1);
                SCC_WiseWrapper.ResponseProgram resProgram = SCC_Wise_List.getProgramList(reqProgram);
                List<SCC_WiseWrapper.ResponseDataProgram> listProgram = resProgram.data.data;

                if(listProgram != null){
                    Datetime now = System.now();
                    Datetime dt1 = Datetime.newInstance(now.date().addDays(-1), Time.newInstance(21, 0, 0, 0));
                    Datetime dt2 = Datetime.newInstance(now.date(), Time.newInstance(20, 59, 59, 0));
        
                    for(Integer i = 0; i < listProgram.size(); i++){
                        String dateApi = listProgram[i].modified_date;
                        List<String> formatedModifiedDt = dateApi.split('T');//remove T from modified date
                        Datetime dtApi = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]); 
                        
                        if(dtApi >= dt1 && dtApi <= dt2){
                            System.debug('masuk');
                            listIdWise.add(listProgram[i].id_knowledge+'_'+listProgram[i].modified_date);
                        } else {
                            System.debug('tidak');
                            System.debug('tanggal wise program:' + dtApi);
                        }
                    }

                    // for(Integer i = 0; i < listProgram.size(); i++){
                    //     listIdWise.add(listProgram[i].id_knowledge+'_'+listProgram[i].modified_date);
                    // }
                }

                if(listIdWise != null && !listIdWise.isEmpty() ){
                    for(String prog:listIdWise){
                        total++;
                        categorizedIds.put(total , prog + '_Wise_Program');
                    }
                }

            }

            if(type == 'Promo'){
                SCC_WiseWrapper.RequestPromo reqPromo = reqPromos(20, 1);
                SCC_WiseWrapper.ResponsePromo resPromo = SCC_Wise_List.getPromoList(reqPromo);
                List<SCC_WiseWrapper.ResponseDataPromo> listPromo = resPromo.data.data;

                if(listPromo != null){
                    Datetime now = System.now();
                    Datetime dt1 = Datetime.newInstance(now.date().addDays(-1), Time.newInstance(21, 0, 0, 0));
                    Datetime dt2 = Datetime.newInstance(now.date(), Time.newInstance(20, 59, 59, 0));
        
                    for(Integer i = 0; i < listPromo.size(); i++){
                        String dateApi = listPromo[i].modified_date;
                        List<String> formatedModifiedDt = dateApi.split('T');//remove T from modified date
                        Datetime dtApi = Datetime.valueOf(formatedModifiedDt[0]+' '+formatedModifiedDt[1]); 
                        
                        if(dtApi >= dt1 && dtApi <= dt2){
                            System.debug('masuk');
                            listIdWise.add(listPromo[i].id_knowledge+'_'+listPromo[i].modified_date);
                        } else {
                            System.debug('tidak');
                            System.debug('tanggal wise promo:' + dtApi);
                        }
                    }
                    // for(Integer i = 0; i < listPromo.size(); i++){
                    //     listIdWise.add(listPromo[i].id_knowledge+'_'+listPromo[i].modified_date);
                    // }
                }

                if(listIdWise != null && !listIdWise.isEmpty() ){
                    for(String promo:listIdWise){
                        total++;
                        categorizedIds.put(total , promo + '_Wise_Promo');
                    }
                }
    
            }

       
            SCC_Wise_General.wrapperWiseGeneral data = new SCC_Wise_General.wrapperWiseGeneral(categorizedIds,total);
            return data;
   }

   public static String formatedRichText(String content) {
        if (String.isBlank(content)) return content;

        content = content.replaceAll('\n', '<br>');
        content = content.replaceAll('\t', '&nbsp');

        // String urlRegex = '\\b(https?://[\\w\\d.-]+\\.[\\w\\d.-]+[\\w\\d./?=#%&_-]*|www\\.[\\w\\d.-]+\\.[\\w\\d.-]+[\\w\\d./?=#%&_-]*)\\b';
        // Pattern urlPattern = Pattern.compile(urlRegex);
        // Matcher urlMatcher = urlPattern.matcher(content);

        // String processedContent = '';
        // Integer lastIndex = 0;

        // while (urlMatcher.find()) {
        //     String url = urlMatcher.group(0);

            
        //     processedContent += content.substring(lastIndex, urlMatcher.start());

        //     String completeUrl = url.startsWith('http') ? url : 'http://' + url;
        //     String anchorTag = '<a href="' + completeUrl + '">' + url + '</a>';
        //     processedContent += anchorTag;
        //     lastIndex = urlMatcher.end();

        // }

        // processedContent += content.substring(lastIndex);

        return content;
  }
  
}