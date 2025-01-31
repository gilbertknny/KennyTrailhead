/**
* @description       : Queue Notification to Leader Every Hour
* @last modified on  : 03/12/2024
* @last modified by  : Alvin Vigo, Lucas Kalasuvich
**/


public with sharing class SCC_CaseResolution_Invoc {
    @InvocableMethod(label='Invocable Case Resolution' description='Invocable code model can call from apex/flow' category='Invocable')    
    public static void invocablevoid(List< FlowInputValues > flowinput) {
        for(FlowInputValues fi:flowinput){
            if(fi.source=='CHM Support'){
                CHMSupport(fi);
            }
            else if(fi.source=='BRI Notification'){
                BRINotification(fi);
            }
            else if(fi.source=='Rekon'){
                Rekon(fi);
            }
        }
    }
    
    public static void chmSupport(FlowInputValues fi){
        if(fi.tipe=='Pembukuan'){
            System.enqueueJob(new SCC_CaseResolution_Pembukuan(fi.csid));
        }
        else if(fi.tipe=='User'){
            System.enqueueJob(new SCC_User1st(''));
        }
        else if(fi.tipe=='TID'){
            SCC_CaseResolution_CHMSupport.checkTerminal(fi.csid);
        }
    }

    public static void rekon(FlowInputValues fi){
        if(fi.tipe=='Flag Data Rekon'){
            //SCC_Rekon.FlagDataRekonFuture(fi.csid);
        }
        else if(fi.tipe=='Auto Closed Rekon'){
            String cond = '(isclosed = false OR IsClosed__c = false) and (SCC_Call_Type__r.external_id__c='+'\'8812'+'\' or SCC_Call_Type__r.external_id__c='+'\'8915'+'\') and IsLocked__c=false and SCC_Account_Number__c != null and Status = '+'\'Escalated'+'\' and (Approval_Status__c='+'\'draft'+'\' or Approval_Status__c='+'\'rejected'+'\')';
            String addfield = ',SCC_Call_Type__r.name,SCC_Call_Type__r.External_id__c,SCC_Call_Type_Feature__r.Fitur_ID__c,Terminal_ID__r.name,account.name';
            String allfield = SOQL_SOBJECT.getallfield('Case');
            String queries = SOQL_SOBJECT.SOQL(allfield, addfield, 'Case', cond, '', '', '');
            Database.executeBatch(new SCC_Batch_AutoClosed_RekeningKoran(queries), 1);
        }
    }
    
    public static void briNotification(FlowInputValues fi){
        if(fi.tipe=='Whatsapp Notification'){
            if(system.isBatch() || system.isFuture()){
                SCC_BRINotif.sendWANotifCase(fi.csid);
            }
            else{
                SCC_BRINotif.sendWANotifFuture(fi.csid);
            }
        }
    }

    public class FlowInputvalues{
        //PARAM
        @invocablevariable public String source;
        @invocablevariable public String tipe;
        @invocablevariable public String csid;
    }
}