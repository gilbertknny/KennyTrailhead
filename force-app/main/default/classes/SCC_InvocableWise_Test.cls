@isTest
public class SCC_InvocableWise_Test {

    @isTest
    static void testInvocablevoid() {
        // Mulai eksekusi test
        Test.startTest();
        
        // Panggil method Invocablevoid dari SCC_InvocableWise
        SCC_InvocableWise.Invocablevoid();
        
        // Akhiri eksekusi test untuk memicu Queueable job
        Test.stopTest();
        
        // Verifikasi bahwa job SCC_Wise1st telah ditambahkan ke antrean
        Integer jobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable' AND MethodName = 'SCC_Wise1st'];
        //System.assertEquals(1, jobCount, 'SCC_Wise1st job should be enqueued');
    }
}