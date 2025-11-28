/**
* Controller for LWC "lwcNewRequest"
* TC : GS
* DATE : 10/10/25
*/

public without sharing class ClsNewRequest {
    @AuraEnabled(cacheable=false)
    public static Opportunity getOpportunity(Id recordId) {
        Opportunity result = new Opportunity();
        if(recordId != null){
            result = [SELECT Id,Opportunity_Type__c,Name,AccountId,COB__c,Description,The_Insured_Name__c,
                      Product_Type_Id__c,Product_Type__c
                      FROM Opportunity 
                      WHERE Id =:recordId WITH SECURITY_ENFORCED];
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static Account getAccountDetail(Id accountId) {
        system.debug(LoggingLevel.WARN,'start, accID='+accountId);
        Account result = new Account();
        if(accountId != null){ 
            result = [SELECT Name,FinServ__Status__c,BillingStreet,
                      BillingCity,BillingState,BillingPostalCode,BillingCountry,
                      Type,Account_Segment__c,Account_Sub_Segment__c,Business_Segmentation__c,
                      Account_Pipeline_Status__c,Account_Channel__c,Address__c
                      FROM Account
                      WHERE Id = :accountId WITH SECURITY_ENFORCED
                     ];
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Account> searchQQAccounts(String searchKey) {
        return [
            SELECT Id, Name, Industry, Phone, Additional__c,Address__c,toLabel(Type) Type
            FROM Account
            WHERE Name LIKE :(searchKey + '%') WITH SECURITY_ENFORCED
            ORDER BY Id ASC
            LIMIT 10
        ];
    }
    
    @AuraEnabled(cacheable=false)
    public static List<data> getMasterData(String cob, String description, String contracttype) {
        List<data> listdata = new List<data>();
        if(contracttype == NULL || contracttype == ''){ contracttype = NULL; }
        List<Master_Data__c> listmd = [SELECT Id,Name,Object__c,Label__c,Data_Type__c,Lookup_Object__c,
                                       Filter__c,ShowData__c,Required__c 
                                       FROM Master_Data__c 
                                       WHERE BSN_ID__c =:cob
                                       AND RecordType.DeveloperName = 'Field_COB'
                                       AND Status__c = 'Active'
                                       AND Contract_Type__c =:contracttype 
                                       AND Description__c =:description WITH SECURITY_ENFORCED
                                       ORDER BY Order__c ASC];
        if(listmd.size()==0){
            listmd = [SELECT Id,Name,Object__c,Label__c,Data_Type__c,Lookup_Object__c,
                      Filter__c,ShowData__c,Required__c 
                      FROM Master_Data__c 
                      WHERE BSN_ID__c =:cob
                      AND RecordType.DeveloperName = 'Field_COB'
                      AND Status__c = 'Active'
                      AND Contract_Type__c = NULL 
                      AND Description__c =:description WITH SECURITY_ENFORCED
                      ORDER BY Order__c ASC];
        }
        for(Master_Data__c md : listmd){
            Data d = new Data();
            d.dataobject = md.Object__c;
            d.datafield = md.Name;
            d.datatype = md.Data_Type__c;
            d.datalabel = md.Label__c;
            d.datalookup = md.Lookup_Object__c;
            d.datafilter = md.Filter__c;
            d.showdata = md.ShowData__c;
            d.datarequired = md.Required__c;
            listdata.add(d);
        }
        system.debug(LoggingLevel.WARN,listdata);
        return listdata;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<section> getMasterDataSection(String cob, String contracttype) {
        List<section> listsection = new List<section>();
        List<AggregateResult> listar = [SELECT Description__c Section FROM Master_Data__c
                                        WHERE BSN_ID__c =:cob
                                        AND RecordType.DeveloperName = 'Field_COB'
                                        AND Status__c = 'Active'
                                        AND Contract_Type__c =:contracttype
                                        GROUP BY Description__c
                                        ORDER BY Description__c ASC];
        if(listar.size()==0){
            listar = [SELECT Description__c Section FROM Master_Data__c
                      WHERE BSN_ID__c =:cob
                      AND RecordType.DeveloperName = 'Field_COB'
                      AND Status__c = 'Active'
                      AND Contract_Type__c = NULL
                      GROUP BY Description__c
                      ORDER BY Description__c ASC];
        }
        for(AggregateResult ar : listar){
            String strName = (String)ar.get('Section');
            if(strName != null){
                section sc = new section();
                sc.name = strName; 
                List<data> listdata = new List<data>();
                if(contracttype == NULL || contracttype == ''){ contracttype = NULL; }
                List<Master_Data__c> listmd = [SELECT Id,Name,Object__c,Label__c,Data_Type__c,Lookup_Object__c,
                                               Filter__c,ShowData__c,Required__c 
                                               FROM Master_Data__c 
                                               WHERE BSN_ID__c =:cob
                                               AND RecordType.DeveloperName = 'Field_COB'
                                               AND Status__c = 'Active'
                                               AND Contract_Type__c =:contracttype 
                                               AND Description__c =:strName WITH SECURITY_ENFORCED
                                               ORDER BY Order__c ASC];
                if(listmd.size()==0){
                    listmd = [SELECT Id,Name,Object__c,Label__c,Data_Type__c,Lookup_Object__c,
                              Filter__c,ShowData__c,Required__c 
                              FROM Master_Data__c 
                              WHERE BSN_ID__c =:cob
                              AND RecordType.DeveloperName = 'Field_COB'
                              AND Status__c = 'Active'
                              AND Contract_Type__c = NULL
                              AND Description__c =:strName WITH SECURITY_ENFORCED
                              ORDER BY Order__c ASC];
                }
                for(Master_Data__c md : listmd){
                    Data d = new Data();
                    d.dataobject = md.Object__c;
                    d.datafield = md.Name;
                    d.datatype = md.Data_Type__c;
                    d.datalabel = md.Label__c;
                    d.datalookup = md.Lookup_Object__c;
                    d.datafilter = md.Filter__c;
                    d.showdata = md.ShowData__c;
                    d.datarequired = md.Required__c;
                    listdata.add(d);
                }
                sc.data = listdata;
                listsection.add(sc);
                system.debug(LoggingLevel.WARN,listdata);
            }
        }
        return listsection;
    }

    @AuraEnabled(cacheable=false) 
    public static Object getObject(String fieldname,String cob,String recordId){
        String query = '';
        List<Master_Data__c> listmd = [SELECT Id,showData__c,Lookup_Object__c
                                       FROM Master_Data__c 
                                       WHERE Name =:fieldname
                                       AND BSN_ID__c =:cob WITH SECURITY_ENFORCED
                                       LIMIT 1];
        if(listmd.size()>0){
            query += 'SELECT Id,Name ';
            Master_Data__c md = listmd[0];
            String strField = md.showData__c;
            List<Object> untypedList = (List<Object>) JSON.deserializeUntyped(strField);
            String queryfield = '';
            for (Object item : untypedList) {
                Map<String, Object> itemMap = (Map<String, Object>) item;
                String param1 = (String)itemMap.get('param1');
                String param2 = (String)itemMap.get('param2');
                system.debug(LoggingLevel.WARN,'param1:'+param1);
                system.debug(LoggingLevel.WARN,'param2:'+param2);
                if(param2 != '' && param2 != 'Name'){queryfield += ','+param2;}
            }
            query += queryfield;
            query += ' FROM '+md.Lookup_Object__c;
            query += ' WHERE Id =:recordId';
            query += ' LIMIT 1';
        }
        system.debug(LoggingLevel.WARN,'query:'+query);
        return Database.query(query);
    }
    
    @AuraEnabled
    public static void deleteFile(String documentId) {
        if(documentId != null){
            ContentDocument cd = [SELECT Id FROM ContentDocument WHERE Id=:documentId WITH SECURITY_ENFORCED];
            Database.DeleteResult dr = Database.delete(cd);
        }
    }
    
    @AuraEnabled
    public static void deleteFiles(String data) {
        
        try{
            List<String> listdatanew = new List<String>();
            List<Object> listdata = (List<Object>)JSON.deserializeUntyped(data);
            system.debug(LoggingLevel.WARN,'listdata:'+listdata);
            for (Object obj : listdata) {
                String documentId = (String)obj;
                system.debug(LoggingLevel.WARN,'documentId:'+documentId);
                listdatanew.add(documentId);
            }
            if(listdatanew.size()>0){
                List<ContentDocument> listcd = [SELECT Id FROM ContentDocument WHERE Id IN:listdatanew WITH SECURITY_ENFORCED];
                if(listcd.size()>0){ List<Database.DeleteResult> dr = Database.delete(listcd); }
            }
        }catch(Exception e){
            system.debug(LoggingLevel.WARN,'error:'+e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getPolicyWording(string filter,string producttype) {
        Map<String, String> values = new Map<String, String>();
        List<Product2> listpd = [SELECT ProductCode FROM Product2 
                                 WHERE Id =:producttype
                                 AND Id != null WITH SECURITY_ENFORCED];
        
        if(listpd.size()>0){
            Product2 pd = listpd[0];
            List<Master_Data__c> listmd = [SELECT Id,Name 
                                           FROM Master_Data__c
                                           WHERE RecordType.DeveloperName = 'Master_Policy_Wording'
                                           AND Product_Type_Id__c =:pd.ProductCode WITH SECURITY_ENFORCED];
            for(Master_Data__c md : listmd){
                values.put(md.Id,md.Name);
            }
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAssetSection(string cob) {
        Map<String, String> values = new Map<String, String>();
        List<Master_Data__c> listmd = [SELECT Id,Name 
                                       FROM Master_Data__c
                                       WHERE RecordType.DeveloperName = 'Asset_Section'
                                       AND BSN__r.ProductCode =:cob WITH SECURITY_ENFORCED
                                       ORDER BY Section__c ASC];
        for(Master_Data__c md : listmd){
            values.put(md.Id,md.Name);
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAssetCategory(string cob,string assetsection) {
        Map<String, String> values = new Map<String, String>();
        List<Master_Data__c> listmd = [SELECT Id,Name 
                                       FROM Master_Data__c
                                       WHERE RecordType.DeveloperName = 'Asset_Category'
                                       AND BSN__r.ProductCode =:cob 
                                       AND Asset_Section__c =:assetsection WITH SECURITY_ENFORCED
                                       ORDER BY Name ASC];
        for(Master_Data__c md : listmd){
            values.put(md.Id,md.Name);
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getProductType(String filter) {
        Map<String, String> values = new Map<String, String>();
        List<Product2> listpd = [SELECT Id,Name FROM Product2 
                                 WHERE Product_Line__r.ProductCode =:filter
                                 AND Type__c = 'Product Type'
                                 AND isActive = TRUE WITH SECURITY_ENFORCED];
        for(Product2 pd : listpd){
            values.put(pd.Id,pd.Name);
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getWording(String recordId){
        Map<String, String> values = new Map<String, String>();
        List<Master_Data__c> listmd = [SELECT Id,Wording__c 
                                       FROM Master_Data__c 
                                       WHERE Id =:recordId WITH SECURITY_ENFORCED];
        if(listmd.size()>0){
            Master_Data__c md = listmd[0];
            String wording = md.Wording__c;
            if(wording != null && wording != ''){
                List<String> listdata = wording.split(',');
                for(String data : listdata){
                    List<String> listvalue = data.trim().split('-');
                    if(listvalue.size() == 2){
                        String value = listvalue[0];
                        String name = listvalue[1];
                        values.put(value,name);
                    }
                }
            }
        }
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getPicklist(String objectName, String fieldName) {
        Map<String, String> values = new Map<String, String>{};
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<String>{objectName});
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(fieldName).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {  
                    values.put(entry.getValue(), entry.getLabel());
                }
            }
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Decimal getRate(string curr){
        Decimal result = 1;
        if(curr != 'IDR'){
            List<Master_Data__c> listmd = [SELECT Id,Exchange_Rate__c 
                                           FROM Master_Data__c 
                                           WHERE RecordType.Name = 'Exchange Rate'
                                           AND Name =: curr WITH SECURITY_ENFORCED
                                           ORDER BY Id DESC
                                           LIMIT 1];
            if(listmd.size()>0){
                Master_Data__c md = listmd[0];
                result = md.Exchange_Rate__c;
            }
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getCurrency(){
        Map<String, String> values = new Map<String, String>{};
        List<AggregateResult> listar = [SELECT Name,Id 
                                        FROM Master_Data__c 
                                        WHERE RecordType.Name = 'Exchange Rate'
                                        GROUP BY Name,Id 
                                        ORDER BY Name ASC];
        for(AggregateResult ar : listar){
            values.put((String)ar.get('Id'),(String)ar.get('Name'));
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean getValidateDouble(String data){
        Boolean result = false;
        Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
        String strRisk1 = (String)dataMap.get('risksituation1');
        String riskName = (String)dataMap.get('riskName');
        String lineCOB;
        Asset ass = new Asset();
        if(strRisk1 != null){
            ass.Name = riskName;
            Map<String,Object> mapRisk1 = (Map<String,Object>)JSON.deserializeUntyped(strRisk1);
            Set<String> setRisk1 = mapRisk1.keySet();
            for(String key:setRisk1){
                String value = String.valueOf(mapRisk1.get(key));
                if(key == 'COB__c'){
                    lineCOB = value;
                    //ass.COB__c = value;
                }else{
                    if(value.indexOf('{')!=-1){
                        String sKey = key.substringBefore('__c');
                        Map<String,Object> mapObj = (Map<String,Object>)mapRisk1.get(key);
                        Set<String> setObj = mapObj.keySet();
                        for(String key2:setObj){
                            String value2 = (String)mapObj.get(key2);
                            if(key2 == 'latitude'){ ass.put(sKey+'__Latitude__s',Integer.ValueOf(value2)); }
                            else if(key2 == 'longitude'){ ass.put(sKey+'__Longitude__s',Integer.ValueOf(value2)); }
                        }
                    }else{
                        if(value != ''){ 
                            String strType = getFieldType('Asset', key);
                            if(strType == 'DOUBLE'){ ass.put(key,DOUBLE.valueOf(value)); }
                            else{ ass.put(key,value); }
                            if(key == 'Address__c'){
                                Schema.Location lc = [SELECT Id,Name FROM Location WHERE Id=:value LIMIT 1];
                                ass.Address_Description__c = lc.Name;
                            }
                        }
                    }    
                }
            }
        }
        String strDescription,strSituation;
        List<String> listDescription = new List<String>();
        List<String> listSituation = new List<String>();
        //GET MASTER VALIDATE
        List<Master_Data__c> listmd = [SELECT Risk_Description__c,Risk_Situation__c FROM Master_Data__c 
                                       WHERE BSN_Id__c =:lineCOB 
                                       AND RecordType.Name = 'Double Prospect' WITH SECURITY_ENFORCED  
                                       LIMIT 1];
        if(listmd.size()>0){
            Master_Data__c md = listmd[0];
            strDescription = md.Risk_Description__c;
            strSituation = md.Risk_Situation__c;
            listDescription = strDescription.split(',');
            listSituation = strSituation.split(',');
            
            Map<String,List<dataDuplicate>> mapDuplicate = new Map<String,List<dataDuplicate>>();
            String sQueryValidate = 'SELECT Id,COB__c';
            if(strDescription != null) sQueryValidate += ','+strDescription;
            if(strSituation != null) sQueryValidate += ','+strSituation;
            sQueryValidate += ' FROM Asset WHERE COB__c=:lineCOB ';
            List<Asset> listValidate = Database.query(sQueryValidate);
            if(listValidate.size()>0){
                List<dataDuplicate> listdd = new List<dataDuplicate>();
                for(Asset at : listValidate){
                    dataDuplicate dd = new dataDuplicate();
                    dd.cob= lineCOB;
                    dd.description = setData(listDescription,at);
                    dd.situation = setData(listSituation,at);
                    listdd.add(dd);
                }
                mapDuplicate.put(lineCOB,listdd);
            }
            String riskDescription = setData(listDescription,ass);
            String riskSituation = setData(listSituation,ass);
            List<dataDuplicate> listnewdd = mapDuplicate.get(lineCOB);
            if(listnewdd.size()>0){
                for(dataDuplicate dd : listnewdd){
                    if(dd.description == riskDescription && dd.description != ''){result=true; break;}
                    else if(dd.situation == riskSituation && dd.situation != ''){result=true; break;}
                }
            }
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static Boolean getContract(String recordId){
        Boolean result = false;
        List<Contract> listcontract = [SELECT Id FROM Contract WHERE AccountId=:recordId];
        if(listcontract.size()>0){result = true;}
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAssetSectionMOU(string contractid) {
        Map<String, String> values = new Map<String, String>();
        String opptyId;
        List<Contract> listct = [SELECT Id,SourceOpportunityId FROM Contract WHERE Id=:contractid];
        if(listct.size()>0){opptyId = listct[0].SourceOpportunityId; }
        
        List<AggregateResult> listar = [SELECT Section__c Id,Section__r.name Name FROM Asset 
                                        WHERE Opportunity__c =: opptyId 
                                        AND Opportunity__c != NULL
                                        AND RecordType.Name = 'Asset' WITH SECURITY_ENFORCED
                                        GROUP BY Section__c,Section__r.name
                                       ORDER BY Section__c ASC];
        for(AggregateResult ar : listar){
            values.put((String)ar.get('Id'),(String)ar.get('Name'));
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getAssetCategoryMOU(string contractid,string assetsection) {
        Map<String, String> values = new Map<String, String>();
        String opptyId;
        List<Contract> listct = [SELECT Id,SourceOpportunityId FROM Contract WHERE Id=:contractid];
        if(listct.size()>0){opptyId = listct[0].SourceOpportunityId; }
        
        List<AggregateResult> listar = [SELECT Category__c Id,Category__r.name Name FROM Asset 
                                        WHERE Opportunity__c =: opptyId 
                                        AND Opportunity__c != NULL
                                        AND Section__c =:assetsection
                                        AND RecordType.Name = 'Asset' WITH SECURITY_ENFORCED
                                        GROUP BY Category__c,Category__r.name
                                       ORDER BY Category__c ASC];
        for(AggregateResult ar : listar){
            values.put((String)ar.get('Id'),(String)ar.get('Name'));
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getCoverage(string contractid){
        Map<String, String> values = new Map<String, String>();
        String opptyId;
        List<Contract> listct = [SELECT Id,SourceOpportunityId FROM Contract WHERE Id=:contractid];
        if(listct.size()>0){opptyId = listct[0].SourceOpportunityId; }
        List<AggregateResult> listar = [SELECT Coverage_Name__c Id,Coverage_Name__r.Name Name
                                        FROM InsurancePolicyCoverage 
                                        WHERE Opportunity__c =: opptyId
                                        AND Opportunity__c != NULL
                                        AND Coverage_Name__r.Name != 'CASCO' WITH SECURITY_ENFORCED
                                        GROUP BY Coverage_Name__r.Name,Coverage_Name__c 
                                        ORDER BY Coverage_Name__r.Name ASC];
        for(AggregateResult ar : listar){
            values.put((String)ar.get('Id'),(String)ar.get('Name'));
        }
        system.debug(LoggingLevel.WARN,'values:'+values);
        return values;
    }
    
    @AuraEnabled(cacheable=false)
    public static Object getCoverageDetail(string contractid,string coverageid){
        InsurancePolicyCoverage result = new InsurancePolicyCoverage();
        String opptyId;
        List<Contract> listct = [SELECT Id,SourceOpportunityId FROM Contract WHERE Id=:contractid];
        if(listct.size()>0){opptyId = listct[0].SourceOpportunityId; }
        List<InsurancePolicyCoverage> listipc = [SELECT Id,Proposed_Fixed_Amount__c, 
                                                 Deductible_PCT__c, Deductible__c, Minimum_Cur_ID__c, Minimum_Amount__c, 
                                                 Banks_Fee__c, Agent_Comission__c, Broker_Comission__c, 
                                                 General_RPremium_PCT__c,Overdng_Comission__c,Max_Person__c 
                                                 FROM InsurancePolicyCoverage
                                                WHERE Opportunity__c =: opptyId
                                                 AND Opportunity__c != null
                                                 AND Coverage_Name__c =:coverageid
                                                LIMIT 1];
        if(listipc.size()>0){
        	result = listipc[0];
        }
        return result;
    }
    
    @AuraEnabled
    public static string saveData(String data){
        String result = '';
        Savepoint sp = Database.setSavepoint();
        system.debug(LoggingLevel.WARN,'data:'+data);
        try{
            String strRTAsset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
            String strRTRisk = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
            //system.debug(dataMap.get('sumInsuredIDR'));
            opty opty = new opty();
            opty.Id = (String)dataMap.get('id');
            opty.opportunityType = (String)dataMap.get('opportunitytype');
            opty.accountId = (String)dataMap.get('accountId');
            opty.requestorTypeId = (String)dataMap.get('requestorTypeId');
            opty.requestorSegmentId = (String)dataMap.get('requestorSegmentId');
            opty.requestorSubSegmentId = (String)dataMap.get('requestorSubSegmentId');
            opty.requestorBusinessSegmentationId = (String)dataMap.get('requestorBusinessSegmentationId');
            opty.requestorPipelineStatusId = (String)dataMap.get('requestorPipelineStatusId');
            opty.requestorChannelId = (String)dataMap.get('requestorChannelId');
            opty.requestorAddress = (String)dataMap.get('requestorAddress');
            opty.insuredId = (String)dataMap.get('insuredId');
            opty.insuredAddress = (String)dataMap.get('insuredAddress');
            String risk = (String)dataMap.get('risk');
            String riskName = (String)dataMap.get('riskName');
            opty.contractType = (String)dataMap.get('contracttype');
            String policywordingId = (String)dataMap.get('policywordingId');
            if(policywordingId != null){
                List<Master_Data__c> listmd = [SELECT Id,Id__c FROM Master_Data__c 
                                               WHERE Id=:policywordingId 
                                               AND Id__c != null WITH SECURITY_ENFORCED];
                if(listmd.size()>0){
                    Master_Data__c md = listmd[0];
                    opty.policywording = md.Id__c;
                }
            }
            opty.premiumcalculation = (String)dataMap.get('premiumcalculation');
            opty.policywordingname = (String)dataMap.get('policywording');
            opty.firetype = (String)dataMap.get('firetype');
            opty.wording = (String)dataMap.get('wording');
            opty.wordingname = (String)dataMap.get('wordingname');
            opty.insuranceperiod = (String)dataMap.get('insuranceperiod');
            opty.startdateperiod = isDate((String)dataMap.get('startdateperiod'));
            opty.enddateperiod = isDate((String)dataMap.get('enddateperiod'));
            opty.yearperiod = Integer.valueOf(dataMap.get('yearperiod'));
            opty.shortperiod = (String)dataMap.get('shortperiod');
            opty.percentageperiod = Integer.valueOf(dataMap.get('percentageperiod'));
            opty.rateperiod = (Decimal)dataMap.get('rateperiod');
            opty.totalyear = (Integer)dataMap.get('totalyear');
            opty.totalmonth = (Integer)dataMap.get('totalmonth');
            String schematype = (String)dataMap.get('schematype');
            String strRisk1 = (String)dataMap.get('risksituation1');
            opty.producttype = (String)dataMap.get('producttype');
            opty.producttypename = (String)dataMap.get('producttypename');
            opty.description = (String)dataMap.get('description');
            opty.format = (String)dataMap.get('format1');
            opty.curr = (String)dataMap.get('currency');
            String lineCOB;
            //RISK
            Asset at1 = new Asset();
            if(strRisk1 != null){
                at1.RecordTypeId = strRTRisk;
                at1.Name = riskName;
                at1.Risk_ID__c = '1';
                if(opty.sumInsuredIDR != null){ at1.Amount_Insured__c = opty.sumInsuredIDR; }
                Map<String,Object> mapRisk1 = (Map<String,Object>)JSON.deserializeUntyped(strRisk1);
                Set<String> setRisk1 = mapRisk1.keySet();
                for(String key:setRisk1){
                    String value = String.valueOf(mapRisk1.get(key));
                    if(key == 'COB__c'){
                        lineCOB = value;
                        //at1.COB__c = value;
                    }else{
                        if(value.indexOf('{')!=-1){
                            String sKey = key.substringBefore('__c');
                            Map<String,Object> mapObj = (Map<String,Object>)mapRisk1.get(key);
                            Set<String> setObj = mapObj.keySet();
                            for(String key2:setObj){
                                String value2 = (String)mapObj.get(key2);
                                if(key2 == 'latitude'){ at1.put(sKey+'__Latitude__s',Integer.ValueOf(value2)); }
                                else if(key2 == 'longitude'){ at1.put(sKey+'__Longitude__s',Integer.ValueOf(value2)); }
                            }
                        }else{
                            if(value != ''){ 
                                String strType = getFieldType('Asset', key);
                                if(strType == 'DOUBLE'){ at1.put(key,DOUBLE.valueOf(value)); }
                                else{ at1.put(key,value); }
                                if(key == 'Address__c'){
                                    Schema.Location lc = [SELECT Id,Name FROM Location WHERE Id=:value LIMIT 1];
                                    at1.Address_Description__c = lc.Name;
                                }
                            }
                        }    
                    }
                    system.debug(key+':'+value);
                }
                if(opty.curr != null && lineCOB == '301'){at1.Currency__c = opty.curr;}
            }
            opty.lineCOB = lineCOB;
            String assetSection = (String)dataMap.get('assetsection');
            String assetCategory = (String)dataMap.get('assetcategory');
            Decimal rate = Decimal.valueOf((Long)dataMap.get('rate'));
            String strSumInsured = (String)dataMap.get('sumInsured');
            if(strSumInsured != null){opty.sumInsured = Long.valueOf(strSumInsured);}
            opty.sumInsuredIDR = Decimal.valueOf((Long)dataMap.get('sumInsuredIDR'));
            String strPremium = (String)dataMap.get('premium');
            Long premium;
            if(strPremium != null){ premium = Long.valueOf(strPremium);}
            opty.premiumIDR = (Long)dataMap.get('premiumIDR');
            String strSummary1 = (String)dataMap.get('summary1');
            if(strSummary1 != null){
                Map<String,Object> mapSummary1 = (Map<String,Object>)JSON.deserializeUntyped(strSummary1);
                Set<String> setSummary1 = mapSummary1.keySet();
                for(String key:setSummary1){
                    String value = (String)mapSummary1.get(key);
                    //system.debug(key+':'+value);
                    at1.put(key,value);
                }
            }
            opty.numberOfRisk = Integer.valueOf(dataMap.get('numberOfRisk'));
            opty.closedDate = isDate((String)dataMap.get('closedDate'));
            
            if(opty.accountId != null && riskName != null){
                Account acc = [SELECT Id,Name FROM Account WHERE Id=:opty.accountId WITH SECURITY_ENFORCED];
                opty.oppName = acc.Name + ' - ' + riskName;
            }
            
            PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE isActive = TRUE WITH SECURITY_ENFORCED LIMIT 1];
            opty.recTypeIdOpt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('General').getRecordTypeId();
            
            system.debug('opty:'+opty);
            system.debug('opty-sumInsured:'+opty.sumInsured);
            system.debug('opty-sumInsuredIDR:'+opty.sumInsuredIDR);
            Opportunity opp = createOpportunity(opty);
            if(opp.Id == null){ Database.SaveResult sr = Database.insert(opp); }
            else{ Database.SaveResult sr = Database.update(opp); }
            
            //PERIOD
            List<Object> listtransRow = (List<Object>) dataMap.get('transactionRows');
            Id insurancePeriodRecordTypeId = Schema.SObjectType.Transaction_Data__c.getRecordTypeInfosByDeveloperName().get('Insurance_Period').getRecordTypeId();
            List<Transaction_Data__c> transactionsToInsert = new List<Transaction_Data__c>();
            Integer i = 0;
            system.debug(LoggingLevel.WARN,'listtransRow:'+listtransRow);
            for(Object trans : listtransRow){
                Map<String,Object> mapTrans = (Map<String, Object>)trans;
                String transactionPeriodType;
                Integer iYear = (Integer)mapTrans.get('year');
                //String sPercentage = (String)mapTrans.get('percentage');
                String sType = (String)mapTrans.get('type');
                String sPercentage = String.valueOf(mapTrans.get('percentage'));
                
                if('3'.equals(opty.insuranceperiod)) {
                    if (i == listtransRow.size() - 1){ transactionPeriodType = '2'; }
                    else{ transactionPeriodType = '1'; }
                }else{ transactionPeriodType = opty.insuranceperiod; }
                transactionsToInsert.add(createPeriod(opp.Id,insurancePeriodRecordTypeId,schematype,iYear,sPercentage,sType,transactionPeriodType));
                i++;
            }
            if (!transactionsToInsert.isEmpty()){ List<Database.SaveResult> sr = Database.insert(transactionsToInsert); }
            
            //QQ
            List<Transaction_Data__c> listtrans = new List<Transaction_Data__c>();
            List<Object> listQQ = (List<Object>) dataMap.get('qqmember');
            for(Object qq : listQQ){
                Map<String,Object> mapQQ = (Map<String, Object>)qq;
                String qqId = (String)mapQQ.get('Id');
                if(qqId != NULL){
                    Transaction_Data__c td = createQQ(qqId,opp.Id);
                    listtrans.add(td);
                }
            }
            if(listtrans.size()>0){ List<Database.SaveResult> sr = Database.insert(listtrans); }
            
            //PRODUCT
            List<OpportunityLineItem> listopl = new List<OpportunityLineItem>();
            List<OpportunityLineItem> listoplupdate = new List<OpportunityLineItem>();
            if(lineCOB != NULL && opty.producttype != NULL){
                Product2 pd = [SELECT Id,Name FROM Product2 WHERE Id =:opty.producttype WITH SECURITY_ENFORCED LIMIT 1];
                List<PricebookEntry> listpbe = [SELECT Id FROM PricebookEntry 
                                                WHERE Pricebook2Id =:pb.Id 
                                                AND Product2Id =:pd.Id 
                                                AND isActive = TRUE WITH SECURITY_ENFORCED
                                                LIMIT 1];
                if(listpbe.size() == 0){
                    return 'Pricebook must be mantain to this product - ' + pd.Name + '!';
                }else{
                    PricebookEntry pbe = listpbe[0];
                    OpportunityLineItem opl = createOpportunityLineItem(opp.Id,premium,opty.premiumIDR,pd.Id,pbe.Id);
                    List<OpportunityLineItem> checkOPL = [SELECT Id FROM OpportunityLineItem 
                                                          WHERE OpportunityId =:opl.OpportunityId
                                                          AND Product2Id =:opl.Product2Id WITH SECURITY_ENFORCED
                                                          LIMIT 1];
                    if(checkOPL.size()==0){listopl.add(opl);}
                    else{listoplupdate.add(opl);}
                }
            }
            if(listopl.size()>0){ List<Database.SaveResult >sr = Database.insert(listopl); }
            if(listoplupdate.size()>0){ List<Database.SaveResult> sr = Database.update(listoplupdate); }
            
            //RISK
            if(lineCOB != NULL && opp.Id != null){
                at1.Opportunity__c = opp.Id; 
                List<Asset> checkAT = [SELECT Id FROM Asset 
                                       WHERE Name =:at1.Name 
                                       AND RecordTypeId =:strRTRisk
                                       AND Opportunity__c =:at1.Opportunity__c WITH SECURITY_ENFORCED 
                                       LIMIT 1];
                if(checkAT.size()>0){
                    at1.Id = checkAT[0].Id;
                    Database.SaveResult sr = Database.update(at1);
                }else{Database.SaveResult sr = Database.insert(at1);}
            }
            
            //ASSET
            if(assetSection != null){
                Asset asset1 = new Asset();
                asset1.RecordTypeId = strRTAsset;
                asset1.Opportunity__c = opp.Id;
                asset1.Name = riskName;
                asset1.Risk_ID__c = '1';
                asset1.ParentId = at1.Id;
                if(rate != null){asset1.Exchange_Rate__c = rate;}
                if(opty.curr != null){ asset1.Currency__c = opty.curr; }
                if(opty.sumInsured != null){ asset1.Amount__c = opty.sumInsured; }
                if(opty.sumInsuredIDR != null){ asset1.Amount_Insured__c = opty.sumInsuredIDR; }
                asset1.Section__c = assetSection;
                if(assetCategory != null){ asset1.Category__c = assetCategory; }
                system.debug('asset1:'+asset1);
                List<Asset> checkAT = [SELECT Id FROM Asset 
                                       WHERE Name =:asset1.Name 
                                       AND RecordTypeId =:strRTAsset
                                       AND Opportunity__c =:opp.Id WITH SECURITY_ENFORCED 
                                       LIMIT 1];
                if(checkAT.size()>0){
                    asset1.Id = checkAT[0].Id;
                    Database.SaveResult sr = Database.update(asset1);
                }else{ Database.SaveResult sr = Database.insert(asset1);}
            }
            
            //FILE 
            List<ContentDocument> listcd = new List<ContentDocument>();
            List<ContentDocumentLink> listcdl = new List<ContentDocumentLink>();
            List<Object> listFileQuote1 = (List<Object>) dataMap.get('filequote1');
            listfile file1 = createFile(listFileQuote1,'QuotationSlip-',opp.Id);
            if(file1 != null){
                if(file1.listcd != null){ listcd.addAll(file1.listcd); }
                if(file1.listcdl != null){ listcdl.addAll(file1.listcdl); }
            }
            List<Object> listFileClosing1 = (List<Object>) dataMap.get('fileclosing1');
            file1 = createFile(listFileClosing1,'ClosingSlip-',opp.Id);
            if(file1 != null){
                if(file1.listcd != null){ listcd.addAll(file1.listcd); }
                if(file1.listcdl != null){ listcdl.addAll(file1.listcdl); }
            }
            List<Object> listFileSurvey1 = (List<Object>) dataMap.get('filesurvey1');
            file1 = createFile(listFileSurvey1,'SurveyReport-',opp.Id);
            if(file1 != null){
                if(file1.listcd != null){ listcd.addAll(file1.listcd); }
                if(file1.listcdl != null){ listcdl.addAll(file1.listcdl); }
            }
            if(listcd.size()>0){
                List<ContentDocument> listnewcd = new List<ContentDocument>();
                Set<String> setcd = new Set<String>();
                for(ContentDocument cd : listcd){
                    if(setcd.add(cd.Id)){
                        listnewcd.add(cd);
                    }
                }
                if(listnewcd.size()>0){ List<Database.SaveResult> sr = Database.update(listnewcd);}
            }
            if(listcdl.size()>0){
                List<ContentDocumentLink> listnewcdl = new List<ContentDocumentLink>();
                Set<ContentDocumentLink> setcdl = new Set<ContentDocumentLink>();
                setcdl.addAll(listcdl);
                listnewcdl.addAll(setcdl);
                if(listnewcdl.size()>0){ List<Database.SaveResult> sr = Database.insert(listnewcdl);}
            }
            
            //MULTIPLE
            if(risk == 'multiple'){
                String riskName2 = (String)dataMap.get('riskName2');
                opty.contractType = (String)dataMap.get('contracttype2');
                opty.policywording = NULL;
                String policywordingId2 = (String)dataMap.get('policywordingId2');
                if(policywordingId2 != null){
                    List<Master_Data__c> listmd = [SELECT Id,Id__c FROM Master_Data__c 
                                                   WHERE Id=:policywordingId2 
                                                   AND Id__c != null WITH SECURITY_ENFORCED];
                    if(listmd.size()>0){
                        Master_Data__c md = listmd[0];
                        opty.policywording = md.Id__c;
                    }
                }
                opty.premiumcalculation = (String)dataMap.get('premiumcalculation2');
                opty.policywordingname = (String)dataMap.get('policywording2');
                opty.firetype = (String)dataMap.get('firetype2');
                opty.wording = (String)dataMap.get('wording2');
                opty.wordingname = (String)dataMap.get('wordingname2');
                opty.insuranceperiod = (String)dataMap.get('insuranceperiod2');
                opty.startdateperiod = isDate((String)dataMap.get('startdateperiod2'));
                opty.enddateperiod = isDate((String)dataMap.get('enddateperiod2'));
                opty.yearperiod = Integer.valueOf(dataMap.get('yearperiod2'));
                opty.shortperiod = (String)dataMap.get('shortperiod2');
                opty.percentageperiod = Integer.valueOf(dataMap.get('percentageperiod2'));
                //opty.rateperiod = Integer.valueOf(dataMap.get('rateperiod2'));
                opty.rateperiod = (Decimal)dataMap.get('rateperiod2');
                String schematype2 = (String)dataMap.get('schematype2');
                String strRisk2 = (String)dataMap.get('risksituation2');
                String productType2 = (String)dataMap.get('producttype2');
                opty.producttypename = (String)dataMap.get('producttypename2');
                opty.description = (String)dataMap.get('description2');
                opty.format = (String)dataMap.get('format2');
                opty.curr = (String)dataMap.get('currency2');
                String lineCOB2;
                Asset at2 = new Asset();
                if(strRisk2 != null){
                    at2.RecordTypeId = strRTRisk;
                    at2.Name = riskName2;
                    at2.Risk_ID__c = '1';
                    if(opty.sumInsuredIDR != null){ at2.Amount_Insured__c = opty.sumInsuredIDR; }
                    Map<String,Object> mapRisk2 = (Map<String,Object>)JSON.deserializeUntyped(strRisk2);
                    Set<String> setRisk2 = mapRisk2.keySet();
                    for(String key:setRisk2){
                        String value = String.valueOf(mapRisk2.get(key));
                        if(key == 'COB__c'){
                            lineCOB2 = value;
                            //at2.COB__c = value;
                        }else{
                            if(value.indexOf('{')!=-1){
                                String sKey = key.substringBefore('__c');
                                Map<String,Object> mapObj = (Map<String,Object>)mapRisk2.get(key);
                                Set<String> setObj = mapObj.keySet();
                                for(String key2:setObj){
                                    String value2 = (String)mapObj.get(key2);
                                    if(key2 == 'latitude'){ at2.put(sKey+'__Latitude__s',Integer.ValueOf(value2)); }
                                    else if(key2 == 'longitude'){ at2.put(sKey+'__Longitude__s',Integer.ValueOf(value2)); }
                                }
                            }else{
                                if(value != ''){
                                    String strType = getFieldType('Asset', key);
                                    if(strType != null){
                                        if(strType == 'DOUBLE'){ at2.put(key,DOUBLE.valueOf(value)); }
                                        else{ at2.put(key,value); }
                                        if(key == 'Address__c'){
                                            Schema.Location lc = [SELECT Id,Name FROM Location WHERE Id=:value LIMIT 1];
                                            at2.Address_Description__c = lc.Name;
                                        }    
                                    }
                                }
                            }    
                        }
                    }
                    if(opty.curr != null && lineCOB2 == '301'){ at2.Currency__c = opty.curr; }
                }
                opty.lineCOB = lineCOB2;
                String assetSection2 = (String)dataMap.get('assetsection2');
                String assetCategory2 = (String)dataMap.get('assetcategory2');
                
                Decimal rate2 = Decimal.valueOf((Long)dataMap.get('rate2'));
                opty.sumInsured = null;
                String strSumInsured2 = (String)dataMap.get('sumInsured2');
                if(strSumInsured2 != null) opty.sumInsured = Long.valueOf(strSumInsured2);
                opty.sumInsuredIDR = Decimal.valueOf((Long)dataMap.get('sumInsuredIDR2'));
                String strPremium2 = (String)dataMap.get('premium2');
                Long premium2;
                if(strPremium2 != null) premium2 = Long.valueOf(strPremium2);
                opty.premiumIDR = (Long)dataMap.get('premiumIDR2');
                String strSummary2 = (String)dataMap.get('summary2');
                if(strSummary2 != null){
                    Map<String,Object> mapSummary2 = (Map<String,Object>)JSON.deserializeUntyped(strSummary2);
                    Set<String> setSummary2 = mapSummary2.keySet();
                    for(String key:setSummary2){
                        String value = (String)mapSummary2.get(key);
                        at2.put(key,value);
                    }
                }
                opty.numberOfRisk = Integer.valueOf(dataMap.get('numberOfRisk2'));
                opty.closedDate = isDate((String)dataMap.get('closedDate2'));
                
                String oppName2;
                if(opty.accountId != null && riskName2 != null){
                    Account acc = [SELECT Id,Name FROM Account WHERE Id=:opty.accountId WITH SECURITY_ENFORCED];
                    oppName2 = acc.Name + ' - ' + riskName2;
                }
                opty.oppName = oppName2;
                
                Opportunity opp2 = createOpportunity(opty);
                if(opp2 != null){ Database.SaveResult sr = Database.insert(opp2);}
                
                List<Object> listtransRow2 = (List<Object>) dataMap.get('transactionRows2');
                transactionsToInsert = new List<Transaction_Data__c>();
                i = 0;
                for(Object trans : listtransRow2){
                    Map<String,Object> mapTrans = (Map<String, Object>)trans;
                    String transactionPeriodType;
                    Integer iYear = (Integer)mapTrans.get('year');
                    String sPercentage = (String)mapTrans.get('percentage');
                    String sType = (String)mapTrans.get('type');
                    
                    if ('3'.equals(opty.insuranceperiod)) {
                        if (i == listtransRow.size() - 1){ transactionPeriodType = '2'; }
                        else{ transactionPeriodType = '1'; }
                    }else{ transactionPeriodType = opty.insuranceperiod; }
                    transactionsToInsert.add(createPeriod(opp2.Id,insurancePeriodRecordTypeId,schematype2,iYear,sPercentage,sType,transactionPeriodType));
                    i++;
                }
                if (!transactionsToInsert.isEmpty()){ List<Database.SaveResult> sr = Database.insert(transactionsToInsert);}
                
                listtrans = new List<Transaction_Data__c>();
                for(Object qq : listQQ){
                    Map<String,Object> mapQQ = (Map<String, Object>)qq;
                    String qqId = (String)mapQQ.get('Id');
                    if(qqId != NULL){
                        Transaction_Data__c td = createQQ(qqId,opp2.Id);
                        listtrans.add(td);
                    }
                }
                if(listtrans.size()>0){ List<Database.SaveResult> sr = Database.insert(listtrans);}
                
                listopl = new List<OpportunityLineItem>();
                if(lineCOB2 != NULL && productType2 != NULL){
                    Product2 pd = [SELECT Id FROM Product2 WHERE Id =:productType2 WITH SECURITY_ENFORCED LIMIT 1];
                    List<PricebookEntry> listpbe = [SELECT Id FROM PricebookEntry 
                                                    WHERE Pricebook2Id =:pb.Id 
                                                    AND Product2Id =:pd.Id 
                                                    AND isActive = TRUE WITH SECURITY_ENFORCED
                                                    LIMIT 1];
                    if(listpbe.size() == 0){
                        return 'Pricebook must be mantain to this product - ' + pd.Name + '!';
                    }else{
                        PricebookEntry pbe = listpbe[0];
                        OpportunityLineItem opl = createOpportunityLineItem(opp2.Id,premium2,opty.premiumIDR,pd.Id,pbe.Id);
                        listopl.add(opl);
                    }
                }
                if(listopl.size()>0){ List<Database.SaveResult> sr = Database.insert(listopl);}
                
                //RISK -->PARENT
                if(lineCOB2 != NULL && opp2.Id != null){
                    at2.Opportunity__c = opp2.Id;
                    Database.SaveResult sr = Database.insert(at2);
                }
                
                //ASSET 2
                if(assetSection2 != null && opp2.Id != null){
                    Asset asset2 = new Asset();
                    asset2.Opportunity__c = opp2.Id;
                    asset2.Name = riskName2;
                    asset2.ParentId = at2.Id;
                    if(rate2 != null){asset2.Exchange_Rate__c = rate2;}
                    if(opty.curr != null){ asset2.Currency__c = opty.curr;}
                    if(opty.sumInsured != null){ asset2.Amount__c = opty.sumInsured; }
                    if(opty.sumInsuredIDR != null){ asset2.Amount_Insured__c = opty.sumInsuredIDR; }
                    asset2.Section__c = assetSection2;
                    if(assetCategory2 != null){ asset2.Category__c = assetCategory2; }
                    Database.SaveResult sr = Database.insert(asset2);
                }
                
                List<ContentDocument> listcd2 = new List<ContentDocument>();
                List<ContentDocumentLink> listcdl2 = new List<ContentDocumentLink>();
                List<Object> listFileQuote2 = (List<Object>) dataMap.get('filequote2');
                file1 = createFile(listFileQuote2,'QuotationSlip-',opp2.Id);
                if(file1 != null){
                    if(file1.listcd != null){ listcd2.addAll(file1.listcd); }
                    if(file1.listcdl != null){ listcdl2.addAll(file1.listcdl); }
                }
                List<Object> listFileClosing2 = (List<Object>) dataMap.get('fileclosing2');
                file1 = createFile(listFileClosing2,'ClosingSlip-',opp2.Id);
                if(file1 != null){
                    if(file1.listcd != null){ listcd2.addAll(file1.listcd); }
                    if(file1.listcdl != null){ listcdl2.addAll(file1.listcdl); }
                }
                List<Object> listFileSurvey2 = (List<Object>) dataMap.get('filesurvey2');
                file1 = createFile(listFileSurvey2,'SurveyReport-',opp2.Id);
                if(file1 != null){
                    if(file1.listcd != null){ listcd2.addAll(file1.listcd); }
                    if(file1.listcdl != null){ listcdl2.addAll(file1.listcdl); }
                }
                if(listcd2.size()>0){
                    List<ContentDocument> listnewcd2 = new List<ContentDocument>();
                    Set<String> setcd2 = new Set<String>();
                    for(ContentDocument cd2 : listcd2){
                        if(setcd2.add(cd2.Id)){
                            listnewcd2.add(cd2);
                        }
                    }
                    if(listnewcd2.size()>0){ List<Database.SaveResult> sr = Database.update(listnewcd2);}
                }
                if(listcdl2.size()>0){
                    List<ContentDocumentLink> listnewcdl2 = new List<ContentDocumentLink>();
                    Set<ContentDocumentLink> setcdl2 = new Set<ContentDocumentLink>();
                    setcdl2.addAll(listcdl2);
                    listnewcdl2.addAll(setcdl2);
                    if(listnewcdl2.size()>0){ List<Database.SaveResult> sr = Database.insert(listnewcdl2); }
                }
            }
            result = opp.Id;
        }catch(Exception e){
            Database.rollback(sp); 
            result = e.getMessage();
        }
        system.debug(LoggingLevel.WARN,'result:'+result);
        return result;
    }
    
    @AuraEnabled
    public static string saveDataMOU(string data){
    	String result = '';
        Savepoint sp = Database.setSavepoint();
        system.debug(LoggingLevel.WARN,'data:'+data);
        /*try{
            String strRTAsset = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Asset').getRecordTypeId();
            String strRTRisk = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Risk').getRecordTypeId();
            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
            opty opty = new opty();
            opty.Id = (String)dataMap.get('id');
            opty.opportunityType = (String)dataMap.get('opportunitytype');
            opty.accountId = (String)dataMap.get('accountId');
            opty.requestorTypeId = (String)dataMap.get('requestorTypeId');
            opty.requestorSegmentId = (String)dataMap.get('requestorSegmentId');
            opty.requestorSubSegmentId = (String)dataMap.get('requestorSubSegmentId');
            opty.requestorBusinessSegmentationId = (String)dataMap.get('requestorBusinessSegmentationId');
            opty.requestorPipelineStatusId = (String)dataMap.get('requestorPipelineStatusId');
            opty.requestorChannelId = (String)dataMap.get('requestorChannelId');
            opty.requestorAddress = (String)dataMap.get('requestorAddress');
            opty.insuredId = (String)dataMap.get('insuredId');
            opty.insuredAddress = (String)dataMap.get('insuredAddress');
            opty.lineCOB = (String)dataMap.get('cob');
            String riskName = (String)dataMap.get('riskName');
            opty.contractType = (String)dataMap.get('contracttype');
            String policywordingId = (String)dataMap.get('policywordingId');
			if(policywordingId != null){
                List<Master_Data__c> listmd = [SELECT Id,Id__c FROM Master_Data__c 
                                               WHERE Id=:policywordingId 
                                               AND Id__c != null WITH SECURITY_ENFORCED];
                if(listmd.size()>0){
                    Master_Data__c md = listmd[0];
                    opty.policywording = md.Id__c;
                }
            }
            opty.premiumcalculation = (String)dataMap.get('premiumcalculation');
            opty.policywordingname = (String)dataMap.get('policywording');
            opty.wording = (String)dataMap.get('wording');
            opty.wordingname = (String)dataMap.get('wordingname');
            opty.insuranceperiod = (String)dataMap.get('insuranceperiod');
            opty.startdateperiod = isDate((String)dataMap.get('startdateperiod'));
            opty.enddateperiod = isDate((String)dataMap.get('enddateperiod'));
            opty.yearperiod = Integer.valueOf(dataMap.get('yearperiod'));
            opty.shortperiod = (String)dataMap.get('shortperiod');
            opty.percentageperiod = Integer.valueOf(dataMap.get('percentageperiod'));
            opty.rateperiod = (Decimal)dataMap.get('rateperiod');
            opty.totalyear = (Integer)dataMap.get('totalyear');
            opty.totalmonth = (Integer)dataMap.get('totalmonth');
            String schematype = (String)dataMap.get('schematype');
            opty.producttype = (String)dataMap.get('producttype');
            opty.producttypename = (String)dataMap.get('producttypename');
            String strRisk1 = (String)dataMap.get('risk1');
            opty.curr = (String)dataMap.get('currency');
            String assetSection = (String)dataMap.get('assetsection');
            String assetCategory = (String)dataMap.get('assetcategory');
            Decimal rate = Decimal.valueOf((Long)dataMap.get('rate'));
            String strSumInsured = (String)dataMap.get('sumInsured');
            if(strSumInsured != null){opty.sumInsured = Long.valueOf(strSumInsured);}
            opty.sumInsuredIDR = Decimal.valueOf((Long)dataMap.get('sumInsuredIDR'));
            if(opty.accountId != null && riskName != null){
                Account acc = [SELECT Id,Name FROM Account WHERE Id=:opty.accountId WITH SECURITY_ENFORCED];
                opty.oppName = acc.Name + ' - ' + riskName;
            }
            PriceBook2 pb = [SELECT Id FROM PriceBook2 WHERE isActive = TRUE WITH SECURITY_ENFORCED LIMIT 1];
            opty.recTypeIdOpt = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('General').getRecordTypeId();
            Opportunity opp = createOpportunity(opty);
            if(opp.Id == null){ Database.SaveResult sr = Database.insert(opp); }
            else{ Database.SaveResult sr = Database.update(opp); }
            
            if(opp.Id != null){
                //RISK
                Asset at1 = new Asset();
                if(strRisk1 != null){
                    at1.RecordTypeId = strRTRisk;
                    at1.Name = riskName;
                    at1.Risk_ID__c = '1';
                    if(opty.sumInsuredIDR != null){ at1.Amount_Insured__c = opty.sumInsuredIDR; }
                    Map<String,Object> mapRisk1 = (Map<String,Object>)JSON.deserializeUntyped(strRisk1);
                    Set<String> setRisk1 = mapRisk1.keySet();
                    for(String key:setRisk1){
                        String value = String.valueOf(mapRisk1.get(key));
                        if(value.indexOf('{')!=-1){
                            String sKey = key.substringBefore('__c');
                            Map<String,Object> mapObj = (Map<String,Object>)mapRisk1.get(key);
                            Set<String> setObj = mapObj.keySet();
                            for(String key2:setObj){
                                String value2 = (String)mapObj.get(key2);
                                if(key2 == 'latitude'){ at1.put(sKey+'__Latitude__s',Integer.ValueOf(value2)); }
                                else if(key2 == 'longitude'){ at1.put(sKey+'__Longitude__s',Integer.ValueOf(value2)); }
                            }
                        }else{
                            if(value != ''){ 
                                String strType = getFieldType('Asset', key);
                                if(strType == 'DOUBLE'){ at1.put(key,DOUBLE.valueOf(value)); }
                                else{ at1.put(key,value); }
                                if(key == 'Address__c'){
                                    Schema.Location lc = [SELECT Id,Name FROM Location WHERE Id=:value LIMIT 1];
                                    at1.Address_Description__c = lc.Name;
                                }
                            }
                        }   
                    }
                    if(opty.curr != null && opty.lineCOB == '301'){ at1.Currency__c = opty.curr;}
                    at1.Opportunity__c = opp.Id; 
                    List<Asset> checkAT = [SELECT Id FROM Asset 
                                           WHERE Name =:at1.Name 
                                           AND RecordTypeId =:strRTRisk
                                           AND Opportunity__c =:at1.Opportunity__c WITH SECURITY_ENFORCED 
                                           LIMIT 1];
                    if(checkAT.size()>0){
                        at1.Id = checkAT[0].Id;
                        Database.SaveResult sr = Database.update(at1);
                    }else{Database.SaveResult sr = Database.insert(at1);}
                }
                
                //PERIOD
                List<Object> listtransRow = (List<Object>) dataMap.get('transactionRows');
                Id insurancePeriodRecordTypeId = Schema.SObjectType.Transaction_Data__c.getRecordTypeInfosByDeveloperName().get('Insurance_Period').getRecordTypeId();
                List<Transaction_Data__c> transactionsToInsert = new List<Transaction_Data__c>();
                Integer i = 0;
                system.debug(LoggingLevel.WARN,'listtransRow:'+listtransRow);
                for(Object trans : listtransRow){
                    Map<String,Object> mapTrans = (Map<String, Object>)trans;
                    String transactionPeriodType;
                    Integer iYear = (Integer)mapTrans.get('year');
                    String sType = (String)mapTrans.get('type');
                    String sPercentage = String.valueOf(mapTrans.get('percentage'));
                    
                    if('3'.equals(opty.insuranceperiod)) {
                        if (i == listtransRow.size() - 1){ transactionPeriodType = '2'; }
                        else{ transactionPeriodType = '1'; }
                    }else{ transactionPeriodType = opty.insuranceperiod; }
                    transactionsToInsert.add(createPeriod(opp.Id,insurancePeriodRecordTypeId,schematype,iYear,sPercentage,sType,transactionPeriodType));
                    i++;
                }
                if (!transactionsToInsert.isEmpty()){ List<Database.SaveResult> sr = Database.insert(transactionsToInsert); }
                
                //QQ
                List<Transaction_Data__c> listtrans = new List<Transaction_Data__c>();
                List<Object> listQQ = (List<Object>) dataMap.get('qqmember');
                for(Object qq : listQQ){
                    Map<String,Object> mapQQ = (Map<String, Object>)qq;
                    String qqId = (String)mapQQ.get('Id');
                    if(qqId != NULL){
                        Transaction_Data__c td = createQQ(qqId,opp.Id);
                        listtrans.add(td);
                    }
                }
                if(listtrans.size()>0){ List<Database.SaveResult> sr = Database.insert(listtrans); }
                
                //ASSET
                if(assetSection != null){
                    Asset asset1 = new Asset();
                    asset1.RecordTypeId = strRTAsset;
                    asset1.Opportunity__c = opp.Id;
                    asset1.Name = riskName;
                    asset1.Risk_ID__c = '1';
                    asset1.ParentId = at1.Id;
                    if(rate != null){asset1.Exchange_Rate__c = rate;}
                    if(opty.curr != null){ asset1.Currency__c = opty.curr;}
                    if(opty.sumInsured != null){ asset1.Amount__c = opty.sumInsured; }
                    if(opty.sumInsuredIDR != null){ asset1.Amount_Insured__c = opty.sumInsuredIDR; }
                    asset1.Section__c = assetSection;
                    if(assetCategory != null){ asset1.Category__c = assetCategory; }
                    system.debug('asset1:'+asset1);
                    List<Asset> checkAT = [SELECT Id FROM Asset 
                                           WHERE Name =:asset1.Name 
                                           AND RecordTypeId =:strRTAsset
                                           AND Opportunity__c =:opp.Id WITH SECURITY_ENFORCED 
                                           LIMIT 1];
                    if(checkAT.size()>0){
                        asset1.Id = checkAT[0].Id;
                        Database.SaveResult sr = Database.update(asset1);
                    }else{ Database.SaveResult sr = Database.insert(asset1);}
                }
                
                //COVERAGE
                List<Object> listCoverage = (List<Object>) dataMap.get('coverage1');
                system.debug(LoggingLevel.WARN,'listCoverage:'+listCoverage);
                for(Object obj : listCoverage){
                    Map<String,Object> mapObj = (Map<String, Object>)obj;
                    String coverageId = (String)mapObj.get('coverageId');
                }
            }
            result = opp.Id;
                
        }catch(Exception e){
            Database.rollback(sp); 
            result = e.getMessage();
        }*/
        system.debug(LoggingLevel.WARN,'result:'+result);
        return result;
    }
    
    public static Opportunity createOpportunity(opty opty)
    {
        Decimal periodRateFinal = opty.rateperiod;
        Integer numberOfYear = opty.yearperiod;
        if(opty.insuranceperiod == '3'){
            if(opty.totalmonth > 0 && opty.rateperiod > 0){
                periodRateFinal += opty.totalyear;
            }else{
                periodRateFinal = opty.totalyear;
                numberOfYear = opty.totalyear;
            }
        }
        
        Opportunity opp = new Opportunity();
        if(opty.id != null){ opp.Id = opty.id; }
        if(opp.Id == null){
            opp.StageName = 'Opportunity';
            opp.RecordTypeId = opty.recTypeIdOpt;
            if(opty.oppName != null){ opp.Name = opty.oppName; }
            if(opty.accountId != null){ opp.AccountId = opty.accountId; }
        }
        if(opty.opportunityType != null){opp.Opportunity_Type__c = opty.opportunityType;}
        if(opty.requestorTypeId != null){opp.Requestor_Type__c = opty.requestorTypeId;}
        if(opty.requestorSegmentId != null){opp.Requestor_Segment__c = opty.requestorSegmentId;}
        if(opty.requestorSubSegmentId != null){opp.Requestor_Sub_Segment__c = opty.requestorSubSegmentId;}
        if(opty.requestorBusinessSegmentationId != null){opp.Requestor_Business_Segmentation__c = opty.requestorBusinessSegmentationId;}
        if(opty.requestorPipelineStatusId != null){opp.Requestor_Pipeline_Status__c = opty.requestorPipelineStatusId;}
        if(opty.requestorChannelId != null){opp.Requestor_Channel__c = opty.requestorChannelId;}
        if(opty.requestorAddress != null){opp.Requestor_Address__c = opty.requestorAddress;}
        if(opty.policywording != null){opp.COVERAGE_GROUP_ID__c = opty.policywording;} //opp.Policy_Wording__c = policywording;
        if(opty.policywordingname != null){opp.Wording_Name__c = opty.policywordingname;}
        if(opty.firetype != null){opp.FIRE_TYPE__c = opty.firetype;}
        if(opty.wording != null){opp.Policy_Wording__c = opty.wording;}
        if(opty.wordingname != null){opp.Policy_Wording_Name__c = opty.wordingname;} //WORDING NAME
        if(opty.contractType == null){ opty.contractType = '1'; } //DEFAULT CONTRACT TYPE IF NONE
        if(opty.contractType != null){opp.Policy_Closing_Type__c = opty.contractType;}
        if(opty.insuredId != null){opp.The_Insured_Name__c = opty.insuredId;}
        if(opty.insuredAddress != null){opp.The_Insured_Address__c = opty.insuredAddress;}
        if(opty.lineCOB != null){opp.COB__c = opty.lineCOB;}
        if(opty.insuranceperiod != null){opp.Insurance_Period_Type__c = opty.insuranceperiod;}
        if(opty.startdateperiod != null){opp.Start_Date_Periode__c = opty.startdateperiod;}
        if(opty.enddateperiod != null){opp.End_Date_Periode__c = opty.enddateperiod;}
        if(numberOfYear != null){opp.Number_of_Years__c = numberOfYear;}
        if(opty.shortperiod != null){opp.Short_Period_Basis__c = opty.shortperiod;}
        if(opty.percentageperiod != null){opp.Percentage__c = opty.percentageperiod;}
        if(periodRateFinal != null){opp.Period_Rate__c = periodRateFinal;}
        if(opty.curr != null){opp.Currency__c = opty.curr;} //curr__c -> Currency__c
        if(opty.sumInsured != null){opp.Sum_Insured__c = opty.sumInsured;}
        if(opty.sumInsuredIDR != null){opp.Total_Sum_Insured__c = opty.sumInsuredIDR;}
        if(opty.numberOfRisk != null){opp.Number_Of_Risk__c = opty.numberOfRisk;}
        else{ opp.Number_Of_Risk__c = 1; }
        if(opty.closedDate == null){opp.CloseDate = Date.Today()+30;}
        else{
            opp.Expected_Close_Date__c = opty.closedDate;
            opp.CloseDate = opty.closedDate;
        }
        if(opty.description != null){opp.Description = opty.description;}
        if(opty.format != null){opp.Submission_Format__c = opty.format;}
        if(opty.premiumIDR != null){opp.Premium__c = opty.premiumIDR;}
        else{opp.Premium__c = 0;}
        opp.Pricebook2Id = opty.idPb;
        if(opty.producttype != null){opp.Product_Type_Id__c = opty.producttype;}
        if(opty.producttypename != null){opp.Product_Type__c = opty.producttypename;}
        if(opty.premiumcalculation != null){opp.premium_calculation__c = opty.premiumcalculation;}
        //DEFAULT
        opp.Closing_Class__c = '1'; //Non MOU
        opp.Type_Of_Business__c = 'D'; //Direct
        return opp;
    }
    
    public static Transaction_Data__c createPeriod(String oppId,String insurancePeriodRecordTypeId,String schematype,
                                                   Integer iYear,String sPercentage,String sType,String transactionPeriodType)
    {
        Transaction_Data__c trans = new Transaction_Data__c();
        trans.Opportunity__c = oppId;
        trans.RecordTypeId = insurancePeriodRecordTypeId;
        trans.Schema_Type__c = schematype;
        trans.Year__c = iYear;
        trans.Value__c = Decimal.valueOf(sPercentage);
        trans.Short_Period_Type__c = sType;
        trans.Insurance_Period_Type__c = transactionPeriodType;
        return trans;
    }
    
    public static Transaction_Data__c createQQ(String qqId,String optId){
        Account acc = [SELECT Id,Address__c,Name FROM Account WHERE Id=:qqId WITH SECURITY_ENFORCED];
        String recTypeIdQQ = Schema.SObjectType.Transaction_Data__c.getRecordTypeInfosByName().get('Member of QQ').getRecordTypeId();
        Transaction_Data__c td = new Transaction_Data__c();
        td.Name = acc.Name;
        td.QQ_Name__c = acc.Id;
        td.QQ_Address__c = acc.Address__c;
        td.Opportunity__c = optId;
        td.RecordTypeId = recTypeIdQQ;
        return td;
    }
    
    public static OpportunityLineItem createOpportunityLineItem(String optId,Long premium,Long premiumIDR,String pdId,String pbeId){
        OpportunityLineItem opl = new OpportunityLineItem();
        opl.OpportunityId = optId;
        if(premiumIDR == null){opl.UnitPrice = 0;}
        else{opl.UnitPrice = premiumIDR;}
        if(premium == null){opl.Price__c = 0;}
        else{opl.Price__c = premium;}
        opl.Quantity = 1;
        opl.Product2Id = pdId;
        opl.PricebookEntryId = pbeId;
        return opl;
    }
    
    public static listfile createFile(List<Object> objFile,String title,String oppId){
        listfile result = new listfile();
        List<ContentDocument> listcd = new List<ContentDocument>();
        List<ContentDocumentLink> listcdl = new List<ContentDocumentLink>();
        result.listcd = listcd;
        result.listcdl = listcdl;
        if(objFile != NULL){
            for(Object datafile : objFile){
                Map<String,Object> mapFile = (Map<String, Object>)datafile; 
                String documentId = (String)mapFile.get('documentId');
                String name = (String)mapFile.get('name');
                
                ContentDocument cd = new ContentDocument();
                cd.Id = documentId;
                cd.Title = title+name;
                listcd.add(cd);
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = documentId;
                cdl.LinkedEntityId = oppId;
                listcdl.add(cdl);
            }
        }
        result.listcd.addAll(listcd);
        result.listcdl.addAll(listcdl);
        return result;
    }
    
    public static string getFieldType(String objectName, String fieldName) {
        String result = '';
        try {
            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType == null) {
                System.debug('Object ' + objectName + ' not found.');
                return result;
            }
            
            DescribeSObjectResult objectDescribe = objectType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objectDescribe.fields.getMap();
            
            Schema.SObjectField sObjectField = fieldMap.get(fieldName);
            if (sObjectField == null) {
                System.debug('Field ' + fieldName + ' not found on object ' + objectName + '.');
                return result;
            }
            
            DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
            Schema.DisplayType fieldDataType = fieldDescribe.getType();
            result = String.valueOf(fieldDataType);
            //System.debug('Data type of ' + objectName + '.' + fieldName + ': ' + fieldDataType);
            
        } catch (Exception e) {
            System.debug('An error occurred: ' + e.getMessage());
        }
        return result;
    }
    
    public static Date isDate(string data){
        Date myDate;
        if(data != null && data != ''){
            List<String> dateParts = data.split('-');
            myDate = Date.newInstance(
                Integer.valueOf(dateParts[0]), // Year
                Integer.valueOf(dateParts[1]), // Month
                Integer.valueOf(dateParts[2])  // Day
            );
        }
        return myDate;
    }
    
    public static String setData(List<String> listdata,Asset ass){
        String result = '';
        if(listdata.size()>0){
            for(String str : listdata){
                String value = (String)ass.get(str);
                if(value != null){result += value;}
            }
        }
        return result;
    }
    
    public class section{
        @AuraEnabled public string name;
        @AuraEnabled public List<Data> data;
    }
    
    public class Data{
        @AuraEnabled public string dataobject;
        @AuraEnabled public string datafield;
        @AuraEnabled public string datatype;
        @AuraEnabled public string datalabel;
        @AuraEnabled public string datalookup;
        @AuraEnabled public string datafilter;
        @AuraEnabled public string showdata;
        @AuraEnabled public boolean datarequired;
    }
    
    public class Listfile{
        public List<ContentDocument> listcd;
        public List<ContentDocumentLink> listcdl;
    }
    
    private class dataDuplicate{
        private string cob;
        private string description;
        private string situation;
    }
    
    private class Opty{
        private String id;
        private String recTypeIdOpt;
        private String opportunityType;
        private String oppName;
        private String accountId;
        private String requestorTypeId;
        private String requestorSegmentId;
        private String requestorSubSegmentId;
        private String requestorBusinessSegmentationId;
        private String requestorPipelineStatusId;
        private String requestorChannelId;
        private String requestorAddress;
        private String policywording;
        private String policywordingname;
        private String contractType;
        private String insuredId;
        private String insuredAddress;
        private String lineCOB; 
        private String insuranceperiod;
        private Date startdateperiod; 
        private Date enddateperiod;
        private Integer yearperiod;
        private String shortperiod;
        private Integer percentageperiod;
        private Decimal rateperiod; 
        private Integer totalyear;
        private Integer totalmonth;
        private String curr;
        private Long sumInsured;
        private Decimal sumInsuredIDR;
        private Integer numberOfRisk;
        private Date closedDate;
        private String idPb;
        private String description;
        private String firetype;
        private String wording;
        private String wordingname;
        private Long premiumIDR;
        private String format;
        private String producttypename;
        private String producttype;
        private String premiumcalculation;
    }
}