/**
* Class for Trigger_Opportunity
* TC : GS
* DATE : 03/11/25
*/
 
public class Aswata_TriggerHandler_Opportunity extends TriggerHandler {
    public override void beforeUpdate(){ 
        Map<String,Master_Data__c> mapMd = getPolicyDistribution();
        Map<String,Product2> mapPd = getProduct();
        List<String> listrecordid = new List<String>();
        for(Opportunity data : (List<Opportunity>) Trigger.new) {
            listrecordid.add(data.id);
        }
        
        List<OpportunityLineItem> listOpl = [SELECT Id,OpportunityId,Product2Id 
                                             FROM OpportunityLineItem 
                                             WHERE OpportunityId IN:listrecordid];
        Map<String,String> mapOpl = new Map<String,String>();
        for(OpportunityLineItem opl:listOpl){
            mapOpl.put(opl.OpportunityId,opl.Product2Id);
        }
        
        for(Opportunity data : (List<Opportunity>) Trigger.new) {
            assignPIC(data,mapMd,mapPd,mapOpl);
        }
    } 
    
    public static Map<String,Master_Data__c> getPolicyDistribution(){
        Map<String,Master_Data__c> mapMd = new Map<String,Master_Data__c>();
        List<Master_Data__c> listmd = [SELECT Id,Product_Segment__c,Product_Line__c,Product_Type__c,
                                       Area__c,Branch_Name__c,USER_PIC__c
                                       FROM Master_Data__c 
                                       WHERE RecordType.Name = 'Policy Distribution'
                                       AND Status__c = 'Approved' 
                                       AND USER_PIC__c != NULL];
        for(Master_Data__c md : listmd){
            //Product_Segment__c-Product_Line__c-Product_Type__c-Branch_Name__c (Master Data)
            String strMDExtId = md.Product_Segment__c+'-'+md.Product_Line__c+'-'+md.Product_Type__c+'-'+md.Branch_Name__c;
            system.debug('strMDExtId:'+strMDExtId);
            mapMd.put(strMDExtId,md);
        }
        return mapMd;
    }
    
    public static Map<String,Product2> getProduct(){
        List<Product2> listpd = [SELECT Id,Name,Product_Segment__c,Product_Segment__r.Name,
                                 Product_Line__c,Product_Line__r.ProductCode 
                                 FROM Product2];
        Map<String,Product2> mapPd = new Map<String,Product2>();
        for(Product2 pd : listpd){
            mapPd.put(pd.Id,pd);
        }
        return mapPd;
    }
    
    public static Opportunity assignPIC(Opportunity data,Map<String,Master_Data__c> mapMd,Map<String,Product2> mapPd,Map<String,String> mapOpl){
        String branchName = data.Office_Teritory__c;
        //if(BranchName.indexOf('-') > 0) BranchName = BranchName.substringAfter('- ');
        String productSegment;
        String productLine;
        String productType;
        String strProductId = mapOpl.get(data.Id);
        if(strProductId != null && branchName != null){
            Product2 pd = mapPd.get(strProductId);
            system.debug(LoggingLevel.WARN,'pd:'+pd);
            if(pd != null){
                if(pd.Product_Segment__c != null){productSegment = pd.Product_Segment__r.Name;}
                if(pd.Product_Line__c != null){productLine = pd.Product_Line__r.ProductCode;}
                productType = pd.Name;
                //Product_Segment__r.Name-Product_Line__r.ProductCode-Name-Office_Teritory__c (PRODUCT)
                String strIPExtId = productSegment+'-'+productLine+'-'+productType+'-'+branchName;
                system.debug(LoggingLevel.WARN,'strIPExtId:'+strIPExtId);
                Master_Data__c md = mapMd.get(strIPExtId);
                system.debug(LoggingLevel.WARN,'md:'+md);
                data.User_PIC__c = NULL;
                data.Policy_Distribution__c = NULL;
                if(md != null){
                    if(md.USER_PIC__c != null){data.User_PIC__c = md.USER_PIC__c;}
                    data.Policy_Distribution__c = md.Id;
                }
            }
        }
        return data;
    } 
}