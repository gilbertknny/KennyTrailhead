({
    searchRecordsAPI : function(component, event, helper) {
        $A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        var trx_date = component.get('v.trx_date');
        component.set('v.message', '');
        component.set('v.recordsList', []);
		// Calling Apex Method
    	var action = component.get('c.getListAPI');
        action.setParams({
            'searchString' : searchString,
            'tgl' : trx_date
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					component.set('v.recordsList',result);
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + "'");
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
    },
    RecordsSelected : function(component, event, helper) {
        var selectedRecord = component.get('v.selectedAPI');
        console.log('selectedRecord',selectedRecord);
        var trx_date = component.get('v.trx_date');
        component.set('v.message', '');
        // Calling Apex Method
    	var action = component.get('c.getDataDetail');
        action.setParams({
            'tgl' : trx_date,
            'termid' : selectedRecord.value
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
            console.log("result",result);
            console.log("state",response.getState());
        	if(response.getState() === 'SUCCESS') {
    			component.set('v.selectedRecordId',result);
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        });
        $A.enqueueAction(action);
    }
})