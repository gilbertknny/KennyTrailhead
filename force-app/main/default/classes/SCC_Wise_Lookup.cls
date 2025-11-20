/**
 * @description       : 
 * @author            : Dwiki Cahyo
 * @group             : 
 * @last modified on  : 09-11-2024
 * @last modified by  : Dwiki Cahyo
**/
public with sharing class SCC_Wise_Lookup {
    public static SCC_WiseWrapper.ResponseWiLookup getWorkingInstructionLookup(String path){
        String metaWi = 'Lookup_WI';
        String classWi = 'SCC_Wise_Lookup_WI';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseWiLookup resWi = new SCC_WiseWrapper.ResponseWiLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                resWi = (SCC_WiseWrapper.ResponseWiLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseWiLookup.class);
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }

    @AuraEnabled
    public static SCC_WiseWrapper.ResponseProgramLookup getProgramLookup(String path){
        String metaWi = 'Lookup_Program';
        String classWi = 'SCC_Wise_Lookup_Program';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseProgramLookup resWi = new SCC_WiseWrapper.ResponseProgramLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
           
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                Map<String, Object> dataMap = (Map<String, Object>) mapResponse.get('data');
                resWi = (SCC_WiseWrapper.ResponseProgramLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseProgramLookup.class);
                //get end date
                if (dataMap.containsKey('end')) {
                    resWi.data.ends = (String) dataMap.get('end');
                }
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }
	
    @AuraEnabled
    public static SCC_WiseWrapper.ResponsePromoLookup getPromoLookup(String path){
        String metaWi = 'Lookup_Promo';
        String classWi = 'SCC_Wise_Lookup_Promo';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponsePromoLookup resWi = new SCC_WiseWrapper.ResponsePromoLookup();
        SCC_WiseWrapper.ResponseDataPromoLookup resPromoData = new SCC_WiseWrapper.ResponseDataPromoLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                Map<String, Object> dataMap = (Map<String, Object>) mapResponse.get('data');
                //resWi = (SCC_WiseWrapper.ResponsePromoLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponsePromoLookup.class);
                resPromoData.id = (String) dataMap.get('id');
                resPromoData.kategori = (String) dataMap.get('kategori');
                resPromoData.merchant = (String) dataMap.get('merchant');
                system.debug ('valuemap :' + dataMap.get('channel'));
                resPromoData.channel = convertList((List<Object>) dataMap.get('channel'));
                resPromoData.lokasi = (String) dataMap.get('lokasi');
                resPromoData.benefit_flag = (Boolean) dataMap.get('benefit_flag');
                resPromoData.syarat_dan_ketentuan_flag = (Boolean) dataMap.get('syarat_dan_ketentuan_flag');

                System.debug('Benefit table' + dataMap.get('benefit'));
                System.debug('Syarat ketentuan' +dataMap.get('syarat_dan_ketentuan') );
                //System.debug('Benefit convert' + convertTable((List<Object>) dataMap.get('benefit')));

                if(resPromoData.benefit_flag){
                    resPromoData.benefit_table = convertTable((List<Object>) dataMap.get('benefit'));
                }else{
                    resPromoData.benefit = (String) dataMap.get('benefit');
                }


                if(resPromoData.syarat_dan_ketentuan_flag){
                    resPromoData.syarat_dan_ketentuan_table = convertTable((List<Object>) dataMap.get('syarat_dan_ketentuan'));
                } else {
                    resPromoData.syarat_dan_ketentuan = (String) dataMap.get('syarat_dan_ketentuan');
                }

                resPromoData.start = (String) dataMap.get('start');
                resPromoData.ends = (String) dataMap.get('end');
                
                if(dataMap.get('image') != null){
                    resPromoData.image = convertImage((List<Object>) dataMap.get('image'));
                }
                
                //resPromoData.image = convertImage((List<Object>) dataMap.get('image'));

                resWi.data = resPromoData;
                
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }

            System.debug('response promo :' + resWi);

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }
	
    @AuraEnabled
    public static SCC_WiseWrapper.ResponseProdukLookup getProdukLookup(String path){
        String metaWi = 'Lookup_Produk';
        String classWi = 'SCC_Wise_Lookup_Produk';
        SCC_Wise_API.WrapperAPI resultApi;
        SCC_WiseWrapper.ResponseProdukLookup resWi = new SCC_WiseWrapper.ResponseProdukLookup();
        SCC_WiseWrapper.ResponseDataProdukLookup resProdukData = new SCC_WiseWrapper.ResponseDataProdukLookup();
        
        resultApi = SCC_Wise_API.getResponseWise(metaWi, '', '', classWi, path);

        try{
            Map<String,Object> mapResponse = (Map<String,Object>) JSON.deserializeUntyped(resultApi.res.getBody());
            if(String.isNotBlank(String.valueOf(mapResponse.get('data')))){
                Map<String, Object> dataMap = (Map<String, Object>) mapResponse.get('data');
                // resWi = (SCC_WiseWrapper.ResponseProdukLookup) JSON.deserialize(resultApi.res.getBody(), SCC_WiseWrapper.ResponseProdukLookup.class);
                //resProdukData.biaya = (String) dataMap.get('biaya');
                //resProdukData.bunga = (String) dataMap.get('bunga');
                resProdukData.definisi = (String) dataMap.get('definisi');
                resProdukData.fitur = (String) dataMap.get('fitur');
                resProdukData.id = (String) dataMap.get('id');
                
                if(dataMap.get('image') != null){
                    resProdukData.image = convertImage((List<Object>) dataMap.get('image'));
                }

               
                //resProdukData.image = convertImage((List<Object>) dataMap.get('image'));
                resProdukData.jenis_produk = (String) dataMap.get('jenis_produk');
                //resProdukData.limits = (String) dataMap.get('limit');
                resProdukData.panduan_penggunaan = (String) dataMap.get('panduan_penggunaan');
                resProdukData.produk = (String) dataMap.get('produk');
                resProdukData.syarat_pembukaan = (String) dataMap.get('syarat_pembukaan');
                resProdukData.syarat_pencairan_penutupan = (String) dataMap.get('syarat_pencairan_penutupan');
                resProdukData.varian_produk = (String) dataMap.get('varian_produk');

                resProdukData.bunga_flag = (Boolean) dataMap.get('bunga_flag');
                resProdukData.limits_flag = (Boolean) dataMap.get('limit_flag');
                resProdukData.biaya_flag = (Boolean) dataMap.get('biaya_flag');
                
                system.debug('bunga' + resProdukData.bunga_flag);
                if(resProdukData.bunga_flag){
                    system.debug('bungatrue');
                    resProdukData.bunga_table = convertTable((List<Object>) dataMap.get('bunga'));
                }else{
                    system.debug('bungafalse');
                    resProdukData.bunga = (String) dataMap.get('bunga');
                }

                if(resProdukData.limits_flag){
                    resProdukData.limits_table = convertTable((List<Object>) dataMap.get('limit'));
                }else{
                    resProdukData.limits = (String) dataMap.get('limit');
                }

                if(resProdukData.biaya_flag){
                    resProdukData.biaya_table = convertTable((List<Object>) dataMap.get('biaya'));
                }else{
                    resProdukData.biaya = (String) dataMap.get('biaya');
                }
                resWi.data = resProdukData;
            } 
            else {
                resWi.status_code = String.valueOf(mapResponse.get('status_code'));
                resWi.errors = String.valueOf(mapResponse.get('errors'));
                resWi.status_desc = String.valueOf(mapResponse.get('status_desc'));
                resWi.message = String.valueOf(mapResponse.get('message'));
            }
            
            System.debug('response produk :' + resWi);

        } catch (exception e){
            SCC_Wise_API.insertErrorLog(e, resultApi.req, resultApi.res, new SCC_Wise_API.WrapperError(resultApi.urlCurrent,classWi));
        }

        return resWi;
    }
    
    public static List<String> convertList(List<Object> listobj){
        List<String> liststr = new List<String>();
        for(Object obj:listobj){
            liststr.add((String) obj);
        }
        return liststr;
    }

    public static List<SCC_WiseWrapper.DataImage> convertImage(List<Object> listImageObj){
        List<SCC_WiseWrapper.DataImage> listImage = new List<SCC_WiseWrapper.DataImage>();
        for(Object imageObj : listImageObj){
            SCC_WiseWrapper.DataImage dataImage = new SCC_WiseWrapper.DataImage();
            Map<String, Object> img = (Map<String, Object>) imageObj;

            dataImage.name = (String) img.get('name');
            dataImage.size = (String) img.get('size');
            dataImage.url = (String) img.get('url');
            
            listImage.add(dataImage);
        }

        return listImage;
    }

    public static List<SCC_WiseWrapper.Table> convertTable(List<Object> knowledgeList){
        List<SCC_WiseWrapper.Table> results = new List<SCC_WiseWrapper.Table>();

        for(Object knowledgeObj : knowledgeList){
            Map<String, Object> knowledgeData = (Map<String, Object>) knowledgeObj;
            SCC_WiseWrapper.Table knowledTable = parseKnowledgeData(knowledgeData);
            results.add(knowledTable);
        }

        return results;
    }
    
    public static SCC_WiseWrapper.Table parseKnowledgeData(Map<String,Object> knowledgeData){
            SCC_WiseWrapper.Table knowledgeTable = new SCC_WiseWrapper.Table();
            knowledgeTable.name = (String) knowledgeData.get('name');
            knowledgeTable.table_data = new List<List<SCC_WiseWrapper.TableData>>();

            List<Object> tableDataRows = (List<Object>) knowledgeData.get('table_data');

            if(tableDataRows != null){
                for(Object row : tableDataRows ){
                    List<Object> rowData = (List<Object>) row;
                    List<SCC_WiseWrapper.TableData> tableDataRow = new List<SCC_WiseWrapper.TableData>();

                    for(Object col : rowData){
                        Map<String, Object> colData = (Map<String, Object>) col;

                        SCC_WiseWrapper.TableData tableData = new SCC_WiseWrapper.TableData();
                        tableData.key = (String) colData.get('key');
                        tableData.value = String.valueOf(colData.get('value'));
                        tableData.row_span = (Integer) colData.get('row_span');
                        tableData.col_span = (Integer) colData.get('col_span');

                        tableDataRow.add(tableData);
                    }

                    knowledgeTable.table_data.add(tableDataRow);
                }
            }

            return knowledgeTable;
    }

    @AuraEnabled
    public static String getRecordName(String idRecord){
        String recordName = '';
        RecordType recType = [SELECT Id, Name , SobjectType FROM RecordType WHERE Id =: idRecord];
        if(recType.Id != null){
            recordName = recType.Name;
        }

        return recordName;
    }


}