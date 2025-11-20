/**
 * Class : SOQL_SOBJECT
 * description : This class for dynamic query
 * 
 **/
public class SOQL_SOBJECT {
    Public Static String soql(String fields, String addField, String sObjectName, String condition, String order, String ascdesc, String limits){
        String sortby = 'ASC';
        if(string.isNotBlank(ascdesc)) {
            sortby = ascdesc;
        }
        String soql = 'SELECT '+Fields.toLowerCase();
        if(String.isNotBlank(addField)) {
            soql = soql+addField.toLowerCase(); //addfield = ',xx___c' atau '(select id from xx__r)'
        }
        soql = soql +' FROM '+SObjectName;
        if(String.isNotBlank(condition)) {
            soql = soql+' where '+condition; //condition = 'xx__c = xxx and xx__c = yyyy'
        }
        if(String.isNotBlank(order)) {
            soql = soql+' order by '+order.toLowerCase()+' '+sortby; // order = 'order by xx__c '
        }
        if(String.isNotBlank(limits)) {
            soql = soql+' limit '+limits.toLowerCase(); // limits = '10'
        }
        return soql;
    }
    
    Public Static List<SObject> listSobject(String addField, String sObjectName, String condition, String order, String ascdesc,String limits){
        List<SObject> listsobj;
        String dpFields = getallfield(SobjectName);
        String dpquery = SOQL(dpFields, addField, SObjectName, Condition, Order,ascdesc, limits);
        listsobj = database.query(dpquery);
        return listsobj;
    }
    
    Public Static SObject singleSobject(String addField, String sObjectName, String condition, String order,String ascdesc, String limits){
        SObject sobj;
        String dpFields = getallfield(SobjectName);
        String dpquery = SOQL(dpFields, addField, SObjectName, Condition, Order,ascdesc, limits);
        sobj = database.query(dpquery);
        return sobj;
    }
    
    Public static String getallfield(String sobjectName){
        Schema.DescribeSObjectResult describeResultdpacc = Schema.getGlobalDescribe().get(SobjectName).getDescribe();
        List<String> dpaccFieldList = new List<String>(describeResultdpacc.fields.getMap().keySet());
        String dpaccFields = String.join(dpaccFieldList, ',');
        return dpaccFields;
    }
}