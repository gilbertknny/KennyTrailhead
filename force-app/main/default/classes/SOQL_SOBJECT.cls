/**
 * @description SOQL_SOBJECT
 */
public without sharing class SOQL_SOBJECT {
    /**
     * @description SOQL_SOBJECT
     * @param sp
     * @return String
     */
    public static String soql(SOQL_Param sp){
        String sortby = 'ASC';
        if(string.isNotBlank(sp?.ascdesc)) {
            sortby = sp?.ascdesc;
        }
        String soql = 'SELECT '+sp?.fields.toLowerCase();
        if(String.isNotBlank(sp?.addField)) {
            soql = soql+sp?.addField.toLowerCase(); //addfield = ',xx___c' atau '(select id from xx__r)'
        }
        soql = soql +' FROM '+sp?.sobjectName;
        if(String.isNotBlank(sp?.condition)) {
            soql = soql+' where '+sp?.condition.toLowerCase(); //condition = 'xx__c = xxx and xx__c = yyyy'
        }
        if(String.isNotBlank(sp?.order)) {
            soql = soql+' order by '+sp?.order.toLowerCase()+' '+sortby; // order = 'order by xx__c '
        }
        if(String.isNotBlank(sp?.limits)) {
            soql = soql+' limit '+sp?.limits.toLowerCase(); // limits = '10'
        }
        return soql;
    }
    /**
     * @description ListSobject
     * @param sp
     * @return List<SObject>
     */
    public static List<SObject> listSobject(SOQL_Param sp){
        List<SObject> listsobj;
        String dpFields = getallfield(sp?.sobjectName);
        String dpquery = SOQL(sp);
        listsobj = database.query(dpquery);
        return listsobj;
    }
    /**
     * @description SingleSobject
     * @param sp
     * @return SObject
     */
    public static SObject singleSobject(SOQL_Param sp){
        SObject sobj;
        String dpFields = getallfield(sp?.sobjectName);
        String dpquery = SOQL(sp);
        sobj = database.query(dpquery);
        return sobj;
    }
    /**
     * @description getallfield
     * @param sobjectName
     * @return String
     */
    public static String getallfield(String sobjectName){
        Schema.DescribeSObjectResult describeResultdpacc = Schema.getGlobalDescribe().get(sobjectName).getDescribe();
        List<String> dpaccFieldList = new List<String>(describeResultdpacc.fields.getMap().keySet());
        String dpaccFields = String.join(dpaccFieldList, ',');
        return dpaccFields;
    }
    /** @description getRecordTypeIdbyDevName  @param objectName @param strRecordTypeName  @return id */
    public static Id getRecordTypeIdbyDevName(String objectName, String strRecordTypeName){
        return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByDeveloperName().get(strRecordTypeName).getRecordTypeId();
    }
    /** @description SOQL_Param */
    public class SOQL_Param{
        /** @description SOQL_Param */
        public String fields {get;set;}
        /** @description SOQL_Param */
        public String addField {get;set;}
        /** @description SOQL_Param */
        public String sobjectName {get;set;}
        /** @description SOQL_Param */
        public String condition {get;set;}
        /** @description SOQL_Param */
        public String order {get;set;}
        /** @description SOQL_Param */
        public String ascdesc {get;set;}
        /** @description SOQL_Param */
        public String limits {get;set;}
    }
}