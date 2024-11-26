@isTest
public class SCC_CaseMilestoneServiceTest {
	@testSetup static void setup(){
        Account acc = new Account(
            Name= 'test');
        Insert acc;
        
        BusinessHours bh = [SELECT Id FROM BusinessHours LIMIT 1];
        SlaProcess esc = [SELECT Id, Name, VersionNumber FROM SlaProcess where name = 'Case Entitlement' order by VersionNumber desc limit 1];
        Entitlement entitlement = new Entitlement(
            Name = 'Agent SLA With Level 4 OLA',
            AccountId = acc.id,
            BusinessHoursId = bh.Id,
            SlaProcessId = esc.Id // Assuming there's a relationship
        );
        insert entitlement;
        
        Case cs = new Case();
        cs.Subject = 'Test';
        cs.Description = 'Test';
        cs.EntitlementId = entitlement.Id; 
        cs.OwnerId = UserInfo.getUserId();
        cs.Status = 'New';
        cs.SCC_Assigned_Date__c = DateTime.Now();
        insert cs;
        
        SSC_Call_Type__c callType = new SSC_Call_Type__c(
            Name = '1003',
            SCC_Agent_SLA__c = 60,
            SCC_Sub_Description__c = 'Initial Value',
            SSC_Case_Description__c = 'xyz',
            External_Id__c = '8812',
            SCC_Customer_Segment__c = 'UMKM',
            SSC_Product_L1__c = 'Servicing',
            SSC_Product_L2__c = 'Cash Management',
            SSC_Case_Category__c = 'Request',
            SSC_Level_1_Escalation_Team__c = 'CDD - Coll Card & Digital Lending-CERIA',
            SSC_Level_2_Escalation_Team__c = 'ORD - Fraud Management & Recovery Desk',
            SSC_Level_3_Escalation_Team__c = 'CDD - Business Partnership Team - PRN',
            SSC_Level_4_Escalation_Team__c = 'CDD - Clf-1 Credit Card Init - SSU',
            SCC_Level1_OLA__c = 5,
            SCC_Level2_OLA__c = 10,
            SCC_Level3_OLA__c = 15,
            SCC_Level4_OLA__c = 20,
            Active__c = true
        );
        insert callType;
        
        Case cs1 = new Case();
        cs1.Subject = 'Test';
        cs1.Description = 'Test';
        cs1.EntitlementId = entitlement.Id;
        cs1.OwnerId = UserInfo.getUserId();
        cs1.Status = 'New';
        cs1.SCC_Assigned_Date__c = DateTime.Now();
        cs1.SCC_Call_Type__c = callType.Id;
        insert cs1;
    }
    
    static testMethod void testProcess(){
        Case cs = [SELECT Id,Branch_Code__c,Status,SCC_Assigned_Date__c,EntitlementId,Entitlement.BusinessHoursId,SCC_Sub_Escalation_Level__c,IsClosed FROM Case WHERE SCC_Call_Type__c = NULL LIMIT 1];
        system.debug('cs:'+cs);
        Case cs1 = [SELECT Id,Branch_Code__c,Status,SCC_Assigned_Date__c,EntitlementId,Entitlement.BusinessHoursId,SCC_Sub_Escalation_Level__c,IsClosed FROM Case WHERE SCC_Call_Type__c != NULL LIMIT 1];
        system.debug('cs1:'+cs1);
        Entitlement et = [SELECT Id,BusinessHoursId FROM Entitlement LIMIT 1];
        system.debug('et:'+et);
        cs1.EntitlementId = et.Id;
        update cs1;
        system.debug('cs1:'+cs1);
        List<CaseMilestone> listcm = [SELECT Id,TimeRemainingInMins,TargetResponseInMins,ElapsedTimeInMins,
                            MilestoneType.Name,IsViolated,IsCompleted,TargetDate,TimeSinceTargetInMins,BusinessHoursId
                            FROM CaseMilestone WHERE CaseId =:cs1.Id];
        system.debug('listcm:'+listcm);
        CaseMilestone cm = new CaseMilestone();
        if(listcm.size()>0){
            cm = listcm[0];
        }
        Test.startTest();
        SCC_CaseMilestoneService.CaseMilestoneWrapper cms = new SCC_CaseMilestoneService.CaseMilestoneWrapper(false,
                                                                                     false,
                                                                                     '',
                                                                                     '',
                                                                                     false,
                                                                                     false,
                                                                                     null,
                                                                                     '0',
                                                                                     1,
                                                                                     '00:00',
                                                                                     '00:00',
                                                                                     false,
                                                                                     false,
                                                                                     1);
        SCC_CaseMilestoneService.addMilestone(cs,null,false,false,true,'',0,'',null); //CaseMilestone NULL
        SCC_CaseMilestoneService.addMilestone(cs,cm,false,false,false,'',0,'',null); //CaseMilestone 
        SCC_CaseMilestoneService.getCaseMilestonesWithCallTypeDetails(cs.Id); //Case no Call Type
        SCC_CaseMilestoneService.getCaseMilestonesWithCallTypeDetails(cs1.Id); //Case with Call Type
        Test.stopTest();
    }
}