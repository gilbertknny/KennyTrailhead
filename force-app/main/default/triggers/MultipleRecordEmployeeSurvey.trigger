trigger MultipleRecordEmployeeSurvey on Employee_Survey__c (before insert,before update) {

    List<Employee_Survey__c> listActiveEmpSurvey =  [SELECT Id,Active__c,Name FROM Employee_Survey__c WHERE Active__c = True ];
    Integer activeCount = listActiveEmpSurvey.size();
    System.debug('active survey : ' + activeCount );

    


    for(Employee_Survey__c emp : Trigger.new){

        if(Trigger.isInsert && emp.Active__c == True ){
            activeCount++;
            System.debug(' add insert active count : ' + activeCount );
        }
        
        if(Trigger.isUpdate && emp.Active__c != Trigger.oldMap.get(emp.Id).Active__c){
            Employee_Survey__c recordBeforeUpdate = Trigger.oldMap.get(emp.Id);
            if(recordBeforeUpdate.Active__c != True){
                activeCount++;
                System.debug(' add update active count : ' + activeCount );
            } 
            
        }

        if(activeCount > 1){
            emp.Active__c.addError('Anda tidak boleh memiliki lebih dari 1 employee survey yang aktif'); 
        }
    }
}