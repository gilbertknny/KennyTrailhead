public with sharing class SCC_InvocableBriva {
    @InvocableMethod(label='Process Briva' description='Invocable method to process Briva data.')
    public static void invocablevoid(){
        processWise();
    }

    private static void processWise(){
        System.enqueueJob(new SCC_Wise1st());
       
    }
   
}