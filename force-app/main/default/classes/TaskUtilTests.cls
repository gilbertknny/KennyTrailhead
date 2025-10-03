@IsTest
private class TaskUtilTests {
    
    @IsTest
    static void testTaskPriorityNormal() {
        //GIVEN
        String state = 'NY';

        //WHEN
        Test.startTest();
            String priority = TaskUtil.getTaskPriority(state);
        Test.stopTest();

        //THEN
        Assert.areEqual('Normal', priority,'Gagal Normal');
    }

    @IsTest
    static void testTaskPriorityHigh() {
        //GIVEN
        String state = 'CA';

        //WHEN
        Test.startTest();
            String priority = TaskUtil.getTaskPriority(state);
        Test.stopTest();

        //THEN
        Assert.areEqual('High', priority,'Gagal High');
    }

    @IsTest static void testTaskPriorityInvalid() {
        //GIVEN
        String state = '';

        //WHEN
        Test.startTest();
            String priority = TaskUtil.getTaskPriority(state);
        Test.stopTest();

        //THEN
        Assert.areEqual(null, priority, 'Gagal Null');
    }
    
}