@isTest
public class SCC_Sch_NotificationCaseTest {
	static testMethod void testProcess(){
        system.schedule('BRIStar Notification', '0 0 0 * * ?', new SCC_Sch_NotificationCase());
        system.schedule('BRIStar Notification Monitoring', '0 10 0 * * ?', new SCC_Sch_NotificationMonitoring());
        system.schedule('BRIStar Summary', '0 15 0 * * ?', new SCC_Sch_BristarSummary());
    }
}