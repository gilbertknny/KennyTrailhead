@isTest
public class TaskUtilTest {
    @isTest
    static void testTaskPriority(){
        String pri = TaskUtil.getTaskPriority('NY');
    	System.assertEquals('Norma;l',pri);
    }
    
    @isTest
    static void testTaskHighPriority(){
        String pri = TaskUtil.getTaskPriority('CA');
        System.assertEquals('High',pri);
    }
    
    @isTest
    static void testTaskPriorityInvalid(){
        String pri = TAskUtil.getTaskPriority('Montana');
        System.assertEquals(null,pri);
        
    }
}