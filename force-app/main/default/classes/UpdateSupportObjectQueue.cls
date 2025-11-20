public class UpdateSupportObjectQueue {
    public static void proses(){
        List<QueueSobject> listdata = new List<QueueSobject>();
        List<String> listqueueid = new List<String>();
		List<QueueSobject> listqueue = [SELECT Id,QueueId FROM QueueSobject WHERE SobjectType = 'Case'];
        for(QueueSobject qs : listqueue){
            listqueueid.add(qs.QueueId);
        }
        List<String> liststringbu = new List<String>();
        List<BranchUnit> listbu = [SELECT Id,Name FROM BranchUnit WHERE BranchCode != null ORDER BY BranchCode__c ASC];
        for(BranchUnit bu : listbu){
            liststringbu.add(bu.Name);
        }
        for(Group gp : [SELECT Id FROM Group WHERE Type = 'Queue' AND Name IN:liststringbu AND Id NOT IN:listqueueid]){
            QueueSobject qs = new QueueSobject();
            qs.QueueId = gp.Id;
            qs.SobjectType = 'Case';
            listdata.add(qs);
        }
        system.debug('listdata:'+listdata);
        if(listdata.size()>0) insert listdata;
    }
    
    public static void updateQueueGroup(){
        List<GroupMember> listgm = new List<GroupMember>();
        List<String> liststringbu = new List<String>();
        List<BranchUnit> listbu = [SELECT Id,Name FROM BranchUnit WHERE BranchCode != null ORDER BY BranchCode__c ASC];
        for(BranchUnit bu : listbu){
            liststringbu.add(bu.Name);
        }
        List<Group> listgroup = [SELECT Id,Name FROM Group WHERE Type='Regular' AND Name IN:liststringbu];
        Map<String,String> mapgroup = new Map<String,String>();
        Map<String,String> mapgroupname = new Map<String,String>();
        for(Group g : listgroup){
            mapgroup.put(g.Id,g.Name);
            mapgroupname.put(g.Name,g.Id);
        }
        List<String> listgroupid = new List<String>();
        List<GroupMember> listqueue = [SELECT Id,UserOrGroupId,Group.Name FROM GroupMember WHERE Group.Type = 'Queue'];
        for(GroupMember gm : listqueue){
            string str = gm.UserOrGroupId;
            if(str.startsWith('00G')){
                string strgp = mapgroup.get(gm.UserOrGroupId);
                if(strgp != null){
                    if(gm.Group.Name == strgp){
                        listgroupid.add(gm.GroupId);
                    }
                }
            }
        }
        
        system.debug('listgroupid:'+listgroupid);
        system.debug('liststringbu:'+liststringbu);
        List<GroupMember> listdata = new List<GroupMember>();
        for(Group gp : [SELECT Id,Name FROM Group WHERE Type = 'Queue' AND Name IN:liststringbu AND Id NOT IN:listgroupid]){
            string groupid = mapgroupname.get(gp.Name);
            if(groupid != null){
                GroupMember gm = new GroupMember();
                gm.GroupId = gp.Id;
                gm.UserOrGroupId = groupid;
                listdata.add(gm);
            }
        }
        system.debug('listdata:'+listdata);
        if(listdata.size()>0) insert listdata;
    }
}