/**
 * @description SFAWT17Queueable
 */
public with sharing class SFAWT17Queueable implements Queueable, Database.AllowsCallouts {
    public Integer curr;
    public Map<Integer,Id> mapcurr = new Map<Integer,Id>();
    /**
     * @description SFAWT17Queueable
     * @param i
     * @param mapacc
     */
    public SFAWT17Queueable(Integer i , Map<Integer,Id> mapacc) {
        curr = i;
        mapcurr = mapacc;
    }
    /**
     * @description execute
     * @param context
     */
    public void execute(QueueableContext context) {
        if(mapcurr.containsKey(curr)){
            Id recId = mapcurr.get(curr);
            Map<String,Object> mapstr = new Map<String,Object>();
            mapstr.put('recId',recId);
            VlocityMapping.callIP('SFAWT17_Outbound', json.serialize(mapstr));
            if(mapcurr.containsKey(curr+1)){
                ID jobID = System.enqueueJob(new SFAWT17Queueable(curr+1,mapcurr));
            }
        }
    }
}