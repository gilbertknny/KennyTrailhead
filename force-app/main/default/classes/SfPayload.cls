public with sharing class SfPayload {

    public static void test(){
        ParamIn p = new ParamIn();
        	//p.objApiName ='Application__c';
        	//p.recordId = 'a0YMR0000001lT72AI'; //UAT : 'a0uF3000003fqLuIAI'
        	
        	//p.objApiName ='Opportunity';
        	//p.recordId = '006MR000005gvGjYAI';
        
        	p.objApiName ='Operation__c';
        	p.recordId = 'a1CMS0000008cOJ2AY';
        
        	//p.objApiName ='Legal_Document__c';
        	//p.recordId = 'a1OMR0000000SFd2AM'; //UAT : 'a1LF3000002gdxSMAQ'
        	
        	//p.objApiName ='Contact';
        	//p.recordId = '003MR000004utE1YAI';
        	
        List<ParamIn> l = new List<ParamIn>();	
        l.add(p);
        List<String> tmp = createSfPayload(l);
        String jsonBody = tmp[0];
        System.debug('hasil = ' + jsonBody );        
    }
    
	public class ParamIn{
        @InvocableVariable public String objApiName='';
        @InvocableVariable public Id recordId=null;
        @InvocableVariable public Boolean objArray=false;
    }
    
    @InvocableMethod (label = 'Generate SfPayload' description = 'Returns the payload')
    public static List<String> createSfPayload(List<ParamIn> prm){
        List<String> retval = new List<String>();
        
        if(prm<>null && !prm.isEmpty() && prm[0].objApiName<>null && prm[0].objArray == false){
            retval.add('"'+prm[0].objApiName+'" : {"fields" : ' + genPayload(prm[0].objApiName,prm[0].recordId,true) + ', "readonly_fields" : ' + genPayload(prm[0].objApiName,prm[0].recordId,false)+' }');
        }
        if(prm<>null && !prm.isEmpty() && prm[0].objApiName<>null && prm[0].objArray == true){
            retval.add('{"fields" : ' + genPayload(prm[0].objApiName,prm[0].recordId,true) + ', "readonly_fields" : ' + genPayload(prm[0].objApiName,prm[0].recordId,false)+' }');
        }
        
        return retval;
    }
    
    public static String genPayload(String objApiName, Id recordId, Boolean IsUpdatable){
        String retval;
        String strPayload;
        
        //--------------------------
        String strSoql = 'SELECT Id';
        List<EntityParticle> rst = [SELECT EntityDefinitionId,Name, DataType, EntityDefinition.QualifiedApiName, FieldDefinition.QualifiedApiName FROM EntityParticle WHERE EntityDefinition.QualifiedApiName= :objApiName and IsUpdatable = :IsUpdatable ORDER BY DataType];
        for (EntityParticle i : rst) {
            //System.debug( i.Name );
            if(i.Name == 'Id'){
            	//skip
            }else {
                strSoql += (', ' + i.Name);
            }
        }
        strSoql += ' FROM ' + objApiName + ' WHERE Id = :id';
        System.debug( strSoql );
        
         
        //--------------------------
        sObject obj;
        Map<String, Object> acctBinds = new Map<String, Object>{'id' => recordId};
        List<sObject> rstObject = Database.queryWithBinds(strSoql,acctBinds,AccessLevel.SYSTEM_MODE);
        if(!rstObject.isEmpty()){
        	obj = rstObject[0];
        	System.debug('dapat = ' + obj);
        }else {
            System.debug('Error rstObject');
        }
       	
        //----------------------------
        List<String> lstTmp = new List<String>();
        for (EntityParticle i : rst) {
            String strDataType = i.DataType;
            
            if(obj.get(i.Name)==null){
                lstTmp.add('"'+i.Name +'" : null ');
                /*
                if(strDataType=='string'){
                	lstTmp.add('"'+i.Name +'" : "Test123" ');
                }else if(strDataType=='currency' || strDataType=='double' || strDataType=='integer' || strDataType=='percent'){
                    lstTmp.add('"'+i.Name +'" : 0 ');
                }else if(strDataType=='datetime' || strDataType=='date'){
                    Datetime dt = Datetime.newInstance(
               			Date.newInstance(2011, 3, 22),
               			Time.newInstance(1, 15, 18, 0)
                    ); 
                    String dtmVal = JSON.serialize(dt);
                    lstTmp.add('"'+i.Name +'" : '+dtmVal+' ');
                }else if(strDataType=='boolean'){
                    Boolean bolVal = false;
                    lstTmp.add('"'+i.Name +'" : '+bolVal+' ');
                }else{
                    lstTmp.add('"'+i.Name +'" : "Test456" ');
                }*/
            }else{
                
                if(
                	(i.EntityDefinition.QualifiedApiName=='Operation__c' && i.Name=='customer_bank_name__c') ||
                	(i.EntityDefinition.QualifiedApiName=='Legal_Document__c' && i.Name=='bank_notaris__c') ||
                    (i.EntityDefinition.QualifiedApiName=='Legal_Document__c' && i.Name=='bank_hold__c') ||
                    (i.EntityDefinition.QualifiedApiName=='Legal_Document__c' && i.Name=='bank_imb__c')
                ){
                    //start: Bank case
                    String bankCode = String.valueOf(obj.get(i.Name));
                    sObject rstRef = Database.query('SELECT Name,code__c,id__c FROM Master_Bank__c WHERE code__c = :bankCode');
                    String strRef = '{"Name":"'+rstRef.get('Name')+'", "code__c":"'+rstRef.get('code__c')+'","id__c":'+rstRef.get('id__c')+', "Id":"'+rstRef.get('Id')+'"}';
                    lstTmp.add('"'+i.Name +'" : '+strRef);
                    System.debug('Bank Case : '+i.EntityDefinition.QualifiedApiName+'.'+ i.Name + ' = '+strRef);         
                	//end: Bank case
                	
                }else if(strDataType=='reference'){
                    String strId = String.valueOf(obj.get(i.Name));
                    Id theId = Id.valueOf(strId);
                    String objectName = theId.getSObjectType().getDescribe().getName();
					
                   	String strRef;
                    if(i.Name.indexOf('Provinces')<>-1 || i.Name.indexOf('Kabupaten')<>-1 || i.Name.indexOf('Kecamatan')<>-1 ){
                        //strRef = genPayload(objectName,theId,true);
                        sObject rstRef = Database.query('SELECT Name,code__c FROM ' + objectName + ' WHERE Id = :theId');
                    	strRef = '{"Name":"'+rstRef.get('Name')+'", "code__c":"'+rstRef.get('code__c')+'", "Id":"'+strId+'"}';
                    }else if( i.Name.indexOf('Kelurahan')<>-1){
                        sObject rstRef = Database.query('SELECT Name,code__c, zip_code__c  FROM ' + objectName + ' WHERE Id = :theId');
                    	strRef = '{"Name":"'+rstRef.get('Name')+'", "code__c":"'+rstRef.get('code__c')+'", "zip_code__c":"'+rstRef.get('zip_code__c')+'", "Id":"'+strId+'"}';
                    }else{
                        /*
                        sObject rstRef = Database.query('SELECT Name FROM ' + objectName + ' WHERE Id = :theId');
                    	strRef = '{"Name":"'+rstRef.get('Name')+'", "Id":"'+strId+'"}';
						*/
                        strRef = '{"Id":"'+strId+'"}';
                    }
					lstTmp.add('"'+i.Name +'" : '+strRef);                    
                    System.debug(strDataType+' : '+ i.Name + ' -> '+strRef);
                }else if(strDataType=='boolean'){
                    Boolean bolVal = Boolean.valueOf(obj.get(i.Name));
                    lstTmp.add('"'+i.Name +'" : '+bolVal+' ');
                    //System.debug(strDataType+' : '+ i.Name + ' -> '+bolVal);
                }else if(strDataType=='date'){
                    String dtVal = JSON.serialize(obj.get(i.Name));
                    lstTmp.add('"'+i.Name +'" : '+dtVal+' ');
                    //System.debug(strDataType+' : '+ i.Name + ' -> '+dtVal);
                }else if(strDataType=='datetime'){
                    String dtmVal = JSON.serialize(obj.get(i.Name));
                    lstTmp.add('"'+i.Name +'" : '+dtmVal+' ');
                    //System.debug(strDataType+' : '+ i.Name + ' -> '+dtmVal);
                }else if(strDataType=='currency'){
                    String curVal = String.valueOf(obj.get(i.Name));
                    lstTmp.add('"'+i.Name +'" : '+curVal+' ');
                    //System.debug(strDataType+' : '+ i.Name + ' -> '+curVal);
                }else if(strDataType=='double'){
                    Double dbVal = Double.valueOf(obj.get(i.Name));
                    lstTmp.add('"'+i.Name +'" : '+dbVal+' ');
                    //System.debug(strDataType+' : '+ i.Name + ' -> '+dbVal);
                }else if(strDataType=='integer' || strDataType=='percent'){
                    Integer intVal = Integer.valueOf(obj.get(i.Name));
                    lstTmp.add('"'+i.Name +'" : '+intVal+' ');
                    //System.debug(strDataType+' : '+ i.Name + ' -> '+intVal);
                }else if(strDataType=='string'){
                	String strVal = String.valueOf(obj.get(i.Name));
                    if(strVal.indexOf('"')<>-1){
                        System.debug('SKIP : '+ i.Name + ' = '+strVal);
                    }else{
                        lstTmp.add('"'+i.Name +'" : "'+strVal+'" ');
                    }
                }else {
                	String strVal = String.valueOf(obj.get(i.Name));
                    if(strVal.indexOf('"')<>-1){
                        System.debug('SKIP : '+ i.Name + ' = '+strVal);
                    }else{
                        lstTmp.add('"'+i.Name +'" : "'+strVal+'" ');
                    }
                    System.debug(strDataType+' : "'+ i.Name + '" : "'+strVal+'" ');
                }
                
                
                
            }
        }
        strPayload = '{';
        strPayload += String.join(lstTmp, ', ');
        strPayload += '}';
        /**/
        
        retval = strPayload;
        return retval;
    }
}



/*
 	Map<String, Object> bindVariablesMap = new Map<String, Object>{'varS_name' => 'Acme Corporation'};
	String strSoql = 'SELECT Id FROM Account WHERE Name = :varS_name';
	List<sObject> rst = Database.queryWithBinds(strSoql, bindVariablesMap, AccessLevel.USER_MODE);
    for (sObject i : rst) {
        System.debug(i);
    }
*/