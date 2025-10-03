trigger DefaultEntitlement on Case (Before Insert, Before Update) {
    Set<Id> contactIds = new Set<Id>();
    Set<Id> acctIds = new Set<Id>();
    for (Case c : Trigger.new) {
        contactIds.add(c.ContactId);
        acctIds.add(c.AccountId);
    }
    List <EntitlementContact> entlContacts =
                [Select e.EntitlementId,e.ContactId,e.Entitlement.AssetId
                From EntitlementContact e
                Where e.ContactId in :contactIds
                And e.Entitlement.EndDate >= Today
                And e.Entitlement.StartDate <= Today];
    if(entlContacts.isEmpty()==false){
        for(Case c : Trigger.new){
            if(c.EntitlementId == null && c.ContactId != null){
                for(EntitlementContact ec:entlContacts){
                    if(ec.ContactId==c.ContactId){
                        c.EntitlementId = ec.EntitlementId;
                        if(c.AssetId==null && ec.Entitlement.AssetId!=null)
                            c.AssetId=ec.Entitlement.AssetId;
                        break;
                    }
                }
            }
        }
    } else{
        List <Entitlement> entls = [Select e.StartDate, e.Id, e.EndDate,
                e.AccountId, e.AssetId
                From Entitlement e
                Where e.AccountId in :acctIds And e.EndDate >= Today
                And e.StartDate <= Today];
        if(entls.isEmpty()==false){
            for(Case c : Trigger.new){
                if(c.EntitlementId == null && c.AccountId != null){
                    for(Entitlement e:entls){
                        if(e.AccountId==c.AccountId){
                            c.EntitlementId = e.Id;
                            if(c.AssetId==null && e.AssetId!=null)
                                c.AssetId=e.AssetId;
                            break;
                        }
                    }
                }
            }
        }
    }
}