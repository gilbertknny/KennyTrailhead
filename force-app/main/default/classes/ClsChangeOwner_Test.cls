@IsTest(SeeAllData=false)
public class ClsChangeOwner_Test {
	@TestSetup
    static void setTestData(){
        String userId = UserInfo.getUserId();
        
		Product2 pd = new Product2();
        pd.Name = 'Home Owner';
        pd.ProductCode = '20101';
        //pd.Product_Segment__c = ps.Id;
        //pd.Product_Line__c = pl.Id;
        insert pd;
        
        String strRTIndividual = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Insurance').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'ACCOUNTA';
        acc.RecordTypeId = strRTIndividual;
        acc.OwnerId = userId;
        insert acc;      
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.AccountId = acc.Id;
        opp.StageName = 'Proposal';
        opp.CloseDate = Date.Today();
        opp.Sum_Insured__c = 100000;
        opp.OwnerId = userId;
        insert opp;
        
        InsurancePolicy ip = new InsurancePolicy();
        ip.Name = 'Test';
        ip.ProductId = pd.Id;
        ip.Branch__c = '28';
        ip.NameInsuredId = acc.Id;
        ip.OwnerId = userId;
        insert ip;
        
        Lead ld = new Lead();
        ld.FirstName = 'A';
        ld.LastName = 'B';
        ld.OwnerId = userId;
        insert ld;
        
        Claim cm = new Claim();
        cm.Name = 'Test';
        cm.OwnerId = userId;
        insert cm;
        
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.OwnerId = userId;
        insert cs;
        
        Task ts = new Task();
        ts.Subject = 'Test';
        ts.WhatId = cs.Id;
        ts.Status = 'Open';
        insert ts;
        
        Task ts2 = new Task();
        ts2.Subject = 'TestTest';
        ts2.WhoId = ld.Id;
        ts2.Status = 'Open';
        insert ts2;
    }
    
    @IsTest
    static void setTestMethod(){
        User u = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId()];
        System.runAs(u){
            Test.startTest();
            String userId = UserInfo.getUserId();
            User us = ClsChangeOwner.getUser(userId); 
            List<Account> listacc = ClsChangeOwner.getAccounts(userId);
            List<Opportunity> listopp = ClsChangeOwner.getOpportunity(userId);
            List<InsurancePolicy> listip = ClsChangeOwner.getInsurancePolicy(userId);
            List<Lead> listld = ClsChangeOwner.getLead(userId);
            List<Claim> listcm = ClsChangeOwner.getClaim(userId);
            List<Case> listcs = ClsChangeOwner.getCase(userId);
            system.assertNotEquals(us.Id,null);
            system.assertNotEquals(listacc.size(),0);
            system.assertNotEquals(listopp.size(),0);
            system.assertNotEquals(listip.size(),0);
            system.assertNotEquals(listld.size(),0);
            system.assertNotEquals(listcm.size(),0);
            system.assertNotEquals(listcs.size(),0);
            String data = '{';
            data += '"account":'+JSON.serialize(listacc)+',';
            data += '"opportunity":'+JSON.serialize(listopp)+',';
            data += '"insurancepolicy":'+JSON.serialize(listip)+',';
            data += '"lead":'+JSON.serialize(listld)+',';
            data += '"claim":'+JSON.serialize(listcm)+',';
            data += '"case":'+JSON.serialize(listcs)+'';
            data += '}';
            string result = ClsChangeOwner.saveData(data);
            system.assertEquals(result,'Sukses');
            ClsChangeOwner.getPermission();
            Test.stopTest();
        }
    }
}