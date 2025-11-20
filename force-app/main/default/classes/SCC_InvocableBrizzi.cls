public with sharing class SCC_InvocableBrizzi {
    // Define the request class properly
    public class FlowInputValues {
        @InvocableVariable(required=true)
        public String tipe;
        
        @InvocableVariable(required=true)
        public String recordId;
    }
    @InvocableMethod(label='Process Brizzi' description='Invocable method to process Brizzi Integration' category='Invocable')
    public static void invocablevoid(List< FlowInputValues > flowinput){
        for(FlowInputValues fi:flowinput){
            // Enqueue the job with the appropriate operation type
            System.enqueueJob(new SCC_BrizziCalloutQueueable(fi.recordId, fi.tipe));
        }
    }
}