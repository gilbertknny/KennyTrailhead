public class aa {

    public static String test(String prm){
        return prm;

    }
    /*    List<ParamIn> l = new List<ParamIn>();
        ParamIn p = new ParamIn();
        p.MaxLoad=30;
        l.add(p);
        getUserLoad(l);
    }
    

    public class ParamIn{
        @InvocableVariable public Id UserId=null;
        @InvocableVariable public Integer MaxLoad=999;
    }
 
    @InvocableMethod (label = 'Get User Load' description = 'Returns the load of the user')
    public static List<List<User>> getUserLoad(List<ParamIn> prm){
        AggregateResult[] rst = null;
        
        if(prm<>null && !prm.isEmpty() && prm[0].UserId<>null){
            rst = [
				SELECT Approver_CA_Cabang__c, COUNT(Id) Load__c
                FROM Opportunity
                WHERE Approver_CA_Cabang__r.isactive = true and Approver_CA_Cabang__c=:prm[0].UserId
                GROUP BY Approver_CA_Cabang__c
                //Having Count(Id) < :prm[0].MaxLoad
            ];
        }else{
            rst = [
                SELECT Approver_CA_Cabang__c, COUNT(Id) Load__c
                FROM Opportunity
                WHERE Approver_CA_Cabang__r.isactive = true 
                GROUP BY Approver_CA_Cabang__c
                //Having Count(Id) < :prm[0].MaxLoad
            ];
        }
        
        
		Map<String,Integer> mds = new Map<String,Integer>();
        //List<String> ids = new List<String>();
        List<User> tbl = new List<User>();
        if(!rst.isEmpty()){
            for(AggregateResult i : rst) {
                String uid = (String)i.get('Approver_CA_Cabang__c');
                Integer uload =(Integer)i.get('Load__c');
                if(uload<=prm[0].MaxLoad) {
                    //ids.add(uid);
                    mds.put(uid, uload);
                }

               	System.debug('tmp Id = ' + uid + ' | tmp Load__c = ' + uload);
            }
        }
        System.debug('isi MDS:'+mds);
        System.debug('============'+prm[0].MaxLoad+'===============');
        
        List<User> tbl1 = [SELECT Id, Name, Load__c FROM User where isactive = true];
        for (User u1 : tbl1) {
            if(mds.containsKey(u1.Id)){
                u1.Load__c = mds.get(u1.Id);
            }else{
                u1.Load__c = 0;
            }
            
            tbl.add(u1);
            System.debug('Id = ' + u1.get('Id'));
            System.debug('Name = ' + u1.get('Name'));
            System.debug('Load__c = ' + u1.get('Load__c'));
            System.debug('===========================');
        }   
        
        //returning the result
        List<List<User>> retval = new List<List<User>>();
        retval.add(tbl);
        return retval;
    }
*/
}