@isTest
public class SCC_MonitoringTest {
	@testSetup static void setup(){
        Id IdExtremely = Schema.SObjectType.Anomali_Category__c.getRecordTypeInfosByDeveloperName().get('extremely_frequency').getRecordTypeId();
        Id IdBusiness = Schema.SObjectType.Anomali_Category__c.getRecordTypeInfosByDeveloperName().get('Outside_Business_Hours').getRecordTypeId();
        Id IdNotCreate = Schema.SObjectType.Anomali_Category__c.getRecordTypeInfosByDeveloperName().get('Access_Not_Create_Case').getRecordTypeId();
        List<BusinessHours> bhs=[SELECT id FROM BusinessHours WHERE IsDefault=true];
        
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        
        Anomali_Category__c ac = new Anomali_Category__c();
        ac.Active__c = true;
        ac.Profile__c = 'System Administrator';
        ac.RecordTypeId = IdExtremely;
        ac.Frequency__c = 0;
        insert ac;
        
        Anomali_Category__c ac1 = new Anomali_Category__c();
        ac1.Active__c = true;
        ac1.Business_Hours__c = bhs[0].Id;
        ac1.Profile__c = 'System Administrator';
        ac1.RecordTypeId = IdBusiness;
        insert ac1;
        
        Anomali_Category__c ac2 = new Anomali_Category__c();
        ac2.Name = 'Access Datahub Not Create Case';
        ac2.Active__c = true;
        ac2.RecordTypeId = IdNotCreate;
        insert ac2;
        
        Error_Log__c el = new Error_Log__c();
        el.Menu__c = 'Account';
        el.Response_Status_Code__c = 200;
        el.Error_Datetime__c = DateTime.Now().addDays(-1);
        el.User_Run__c = UserInfo.getUserId();
        el.RelatedId__c = acc.Id;
        el.Destination__c = 'Data Hub';
        insert el;
    }
    
    static testMethod void testProcess(){
        system.schedule('Monitoring Summary', '0 0 0 * * ?', new SCC_Sch_Monitoring());
        system.schedule('Monitoring Summary 1', '0 0 0 * * ?', new SCC_Sch_Monitoring1());
        system.schedule('Monitoring Summary 2', '0 0 0 * * ?', new SCC_Sch_Monitoring2());
        SCC_Monitoring.execute(null,null,'Extremely');
        SCC_Monitoring.execute(null,null,'Business_Hours');
        SCC_Monitoring.execute(null,null,'Not_Create_Case');
        List<Monitoring_Summary__c> recordset = new List<Monitoring_Summary__c>();
        database.executebatch(new SCC_Batch_ActionMonitoring(recordset,'update'),200);
    }
}