@IsTest(SeeAllData=false)
public class ClsNewRequest_Test {
	@TestSetup
    static void setTestData(){
        Product2 pd = new Product2(); 
        pd.Name = 'Test';
        pd.ProductCode = '123';
        insert pd;
        
        Product2 pd2 = new Product2();
        pd2.Name = '2';
        pd2.ProductCode = '2';
        pd2.Product_Line__c = pd.Id;
        pd2.IsActive = true; 
        pd2.Type__c = 'Product Type';
        insert pd2;
        
        PriceBook2 pb = new PriceBook2();
        pb.name = 'test';
        pb.IsActive = TRUE;
        insert pb;
        
        Id standardPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPriceEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id = pd.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert standardPriceEntry;
        
        PricebookEntry customPriceEntry = new PricebookEntry(
            Pricebook2Id = pb.Id,
            Product2Id = pd.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert customPriceEntry;
        
        String strRTIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ACC12345';
        acc.RecordTypeId = strRTIndividual;
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'QQ';
        acc2.RecordTypeId = strRTIndividual;
        insert acc2;
        
        String RT1 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Field COB').getRecordTypeId();
        Master_Data__c md = new Master_Data__c();
        md.RecordTypeId = RT1;
        md.BSN_ID__c = '201';
        md.Status__c = 'Active';
        md.Name = '1';
        md.Description__c = 'test';
        md.Wording__c = 'A,B,C';
        insert md;
        
        Master_Data__c md3 = new Master_Data__c();
        md3.RecordTypeId = RT1;
        md3.BSN_ID__c = '201';
        md3.Status__c = 'Active';
        md3.Name = 'Address__c';
        md3.Lookup_Object__c = 'Location';
        md3.showData__c = '[{"param1" : "Eq_Zone__c", "param2": "Earthquake_Zone__c"}]';
        insert md3;
        
        String RT2 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Master Policy Wording').getRecordTypeId();
        Master_Data__c md2 = new Master_Data__c();
        md2.RecordTypeId = RT2;
        md2.Name = '2';
        md2.Product_Type_Id__c = pd.ProductCode;
        insert md2;
        
        String RT3 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Exchange Rate').getRecordTypeId();
        Master_Data__c md4 = new Master_Data__c();
        md4.RecordTypeId = RT3;
        md4.Name = 'USD';
        md4.Exchange_Rate__c = 15000;
        insert md4;
        
        String RT4 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Double Prospect').getRecordTypeId();
        Master_Data__c md5 = new Master_Data__c();
        md5.RecordTypeId = RT4;
        md5.Name = 'Test';
        md5.Risk_Description__c = 'Name';
        md5.Risk_Situation__c = 'Address__c,City__c,Zip_Code__c,N_K_R__c';
        md5.BSN_ID__c = '201';
        insert md5;
        
        String RT5 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Asset Section').getRecordTypeId();
        Master_Data__c md6 = new Master_Data__c();
        md6.RecordTypeId = RT5;
        md6.Name = 'Test';
        md6.BSN_Id__c = '201';
        md6.Section__c = 1;
        insert md6;
        
        String RT6 = Schema.SObjectType.Master_Data__c.getRecordTypeInfosByName().get('Detail Asset').getRecordTypeId();
        Master_Data__c md7 = new Master_Data__c();
        md7.RecordTypeId = RT6;
        md7.Name = 'Test';
        md7.BSN_Id__c = '201';
        md7.Section__c = 1;
        md7.Status__c = 'Active';
        insert md7;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),            
            IsMajorVersion = true);
        insert contentVersion;
        
        Schema.Location l = new Schema.Location();
        l.name = 'Hawai';
        insert l;
    }
    
    @IsTest
    static void setTestMethod(){
       	Schema.Location l = [SELECT Id FROM Location LIMIT 1];
        Master_Data__c md = [SELECT Id FROM Master_Data__c WHERE Name = '1' LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'ACC12345' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE Name = 'QQ' LIMIT 1];
        Account acc1 = ClsNewRequest.getAccountDetail(acc.Id);
        List<Account> listacc = ClsNewRequest.searchQQAccounts('ACC');
        String cob = '201';
        String description = 'test';
        List<ClsNewRequest.data> listdata = ClsNewRequest.getMasterData(cob,description,'1');
        system.assertEquals(listdata.size(),1);
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        Product2 pd = [SELECT Id,ProductCode FROM Product2 LIMIT 1];
        string filter = pd.ProductCode;
        string producttype = pd.Id;
        ClsNewRequest.getPolicyWording(filter,producttype);
        ClsNewRequest.getProductType('123');
        ClsNewRequest.getPicklist('Product2','Type__c');
        ClsNewRequest.getObject('Address__c',cob,l.Id);
        ClsNewRequest.getWording(md.Id);
        ClsNewRequest.getRate('USD');
        Map<String, String> mapAssetSection = ClsNewRequest.getAssetSection(cob);
        List<String> keysAssetSection = new List<String>(mapAssetSection.keySet());
        ClsNewRequest.getAssetCategory(cob,null);
        ClsNewRequest.getMasterDataSection(cob,'1');
        ClsNewRequest.getCurrency();
        ClsNewRequest.getContract(acc.Id);
        ClsNewRequest.getAssetSectionMOU(null,'mou');
        ClsNewRequest.getAssetCategoryMOU(null,null,'mou');
        List<String> assetsection = new List<String>();
        assetsection.add('Material Damage');
        ClsNewRequest.getCoverage(null,assetsection,null,null,'mou');
        ClsNewRequest.getCoverageDetail(null,null,assetsection,'mou');
        Map<String,Object> mapObj = new Map<String,Object>();
        mapObj.put('section',1);
        InsurancePolicyCoverage ipc = new InsurancePolicyCoverage();
        ClsNewRequest.createCoverage(mapObj,ipc);
        mapObj.put('section',2);
        ClsNewRequest.createCoverage(mapObj,ipc);
        mapObj.put('section',3);
        ClsNewRequest.createCoverage(mapObj,ipc);
        mapObj.put('section',4);
        ClsNewRequest.createCoverage(mapObj,ipc);
        
        Master_Data__c mdSection = [SELECT Id FROM Master_Data__c WHERE Name = 'Test' AND RecordType.Name = 'Asset Section' LIMIT 1];
        ClsNewRequest.getMasterDataDetailAsset('1',mdSection.Id);
        List<String> listSectionids = new List<String>();
        listSectionids.add(mdSection.Id);
        ClsNewRequest.getSectionDetail(listSectionids);

        List<String> listdata1 = new List<String>();
        listdata1.add('Name'); 
        Asset ass = new Asset();
        ass.Name = 'Test';
        ClsNewRequest.setData(listdata1, ass);        
        
        String situation1 = '{';
        situation1 += '"COB__c":"'+cob+'"';
        situation1 += ',"Eq_Zone__c":"Test"';
        situation1 += ',"Coordinate__c":{"latitude":"10","longitude":"20"}';
        situation1 += '}';
        
        String summary1 = '{';
        summary1 += '"Occupation_Code__c":"'+md.Id+'"';
        summary1 += '}';
        
        String data = '{';
        data += '"opportunitytype":"NB"';
        data += ',"accountId":"'+acc.Id+'"';
        data += ',"insuredId":"'+acc.Id+'"';
        data += ',"qqmember":[{"Id":"'+acc2.Id+'"}]';
        data += ',"risk":"multiple"';
        data += ',"cob":"201"';
        data += ',"riskName":"Test"';
        data += ',"policywording":"Test"';
        data += ',"insuranceperiod":"1"';
        data += ',"startdateperiod":"2025-01-01"';
        data += ',"enddateperiod":"2026-01-01"';
        data += ',"yearperiod":"1"';
        data += ',"schematype":"Sum Insured Adjustment"';
        data += ',"transactionRows":[{"year":1,"percentage":"100","type":"1"}]';
        data += ',"description":"Test"';
        data += ',"annualperiod":"1"';
        data += ',"shortperiod":""';
        data += ',"percentageperiod":"1"';
        data += ',"rateperiod":1';
        data += ',"type":"Standard"';
        data += ',"contracttype":"1"';
        data += ',"risksituation1":' + JSON.serialize(situation1);
        data += ',"risk1":' + JSON.serialize(situation1);
        data += ',"producttype":"'+pd.Id+'"';
        data += ',"assetsection":"'+keysAssetSection.get(0)+'"';
        data += ',"asset1":[{"assetSectionId":"'+keysAssetSection.get(0)+'","coverage":[{"proposedFixedAmount":10000,"agentComission":"0","brokerComission":"0","maxPerson":"0"}]}]';
        data += ',"sumInsured":"1"';
        data += ',"premium":"1"';
        data += ',"summary1":' + JSON.serialize(summary1);
        data += ',"numberOfRisk":"1"';
        data += ',"closedDate":"2026-01-01"';
        data += ',"filequote1":[{"documentId":"'+cd.Id+'","name":"Test"}]';
        data += ',"fileclosing1":[{"documentId":"'+cd.Id+'","name":"Test"}]';
        data += ',"filesurvey1":[{"documentId":"'+cd.Id+'","name":"Test"}]';
        data += ',"riskName2":"Test"';
        data += ',"cob2":"201"';
        data += ',"policywording2":"Test"';
        data += ',"insuranceperiod2":"1"';
        data += ',"startdateperiod2":"2025-01-01"';
        data += ',"enddateperiod2":"2026-01-01"';
        data += ',"schematype2":"Sum Insured Adjustment"';
        data += ',"transactionRows2":[{"year":1,"percentage":"100","type":"1"}]';
        data += ',"description2":"Test"';
        data += ',"yearperiod2":"1"';
        data += ',"annualperiod2":"1"';
        data += ',"shortperiod2":""';
        data += ',"percentageperiod2":"1"';
        data += ',"rateperiod2":1';
        data += ',"type2":"Standard"';
        data += ',"contracttype2":"1"'; 
        data += ',"risksituation2":' + JSON.serialize(situation1);
        data += ',"producttype2":"'+pd.Id+'"';
        data += ',"assetsection2":"'+keysAssetSection.get(0)+'"';
        data += ',"sumInsured2":"1"';
        data += ',"premium2":"1"';
        data += ',"summary2":' + JSON.serialize(summary1);
        data += ',"numberOfRisk2":"1"';
        data += ',"closedDate2":"2026-01-01"';
        data += ',"filequote2":[{"documentId":"'+cd.Id+'","name":"Test"}]';
        data += ',"fileclosing2":[{"documentId":"'+cd.Id+'","name":"Test"}]';
        data += ',"filesurvey2":[{"documentId":"'+cd.Id+'","name":"Test"}]';
        data += '}';
        ClsNewRequest.getValidateDouble(data);
        string result = ClsNewRequest.saveData(data);
        system.debug('result:'+result);
        system.assertNotEquals(result,null);
        String data2 = data.replaceAll('Standard','MOU');
        string result2 = ClsNewRequest.saveData(data2);
        String data3 = data.replaceAll('Standard','Realisasi');
        string result3 = ClsNewRequest.saveData(data3);
        ClsNewRequest.deleteFile(cd.Id);
        ClsNewRequest.getOpportunity(result); 
        ClsNewRequest.getSectionAmount(result,'Material Damage',null);
    }
    
    @IsTest
    static void setTestMethod2(){
        ContentDocument cd = [SELECT Id FROM ContentDocument LIMIT 1];
        List<String> listData = new List<String>();
        listData.add(cd.Id);
        ClsNewRequest.deleteFiles(JSON.serialize(listData));
    }
}