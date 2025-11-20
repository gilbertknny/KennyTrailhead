global with sharing class SCC_InvocableWise  {

    @InvocableMethod(label='Process Wise' description='Invocable method to process Wise data.')
    public static void invocablevoid(){
        processWise();
    }

    private static void processWise(){
        System.enqueueJob(new SCC_Wise1st());
       
    }
   
}