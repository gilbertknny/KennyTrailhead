/** @description SFAWT05Queueable   */
public with sharing class SFAWT05Queueable implements Queueable, Database.AllowsCallouts {
    public Queueableparam qp = new Queueableparam();
     /** @description VlocityMapping  @param qp */
    public SFAWT05Queueable(QueueableParam qp) {
        this.qp = qp;
    }
     /** @description VlocityMapping  @param context */
    public void execute(QueueableContext context) {
        Map<String,Object> mapin = new Map<String,Object>();
        List<Object> listobj = new List<Object>();
        integer i = qp.start;
        for(i = qp.start; i < qp.start + qp.chunk; i++){
            if(qp.mapobj.containsKey(i)){
                listobj.add(qp.mapobj.get(i));
            }
        }
        mapin.put(qp.varout,listobj);
        mapin.put('recordtypeId',qp.recordtypeId);
        mapin.put('externalId',qp.externalId);
        system.debug(JSON.serialize(mapin));
        VlocityMapping.callIP(qp.ipname,JSON.serialize(mapin));
        if(qp.mapobj.size()>i){
            qp.start = i;
            ID jobID = System.enqueueJob(new SFAWT05Queueable(qp));
        }
    }    
    /** @description RequestAPI */
    public class QueueableParam{
         /** @description RequestAPI */
        public Integer start;
         /** @description RequestAPI */
        public Integer chunk;
        /** @description RequestAPI */
        public String ipname;
        /** @description RequestAPI */
        public String varout;
        /** @description RequestAPI */
        public Id recordtypeId;
        /** @description RequestAPI */
        public String externalId;
        /** @description RequestAPI */
        public Map<Integer,Object> mapobj = new Map<Integer,Object>();
    }
}