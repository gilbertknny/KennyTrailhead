({
    // To prepopulate the seleted value pill if value attribute is filled
	doInit : function( component, event, helper ) {
    	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
	},
 
    // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        helper.searchRecordsAPI( component, event, helper);
	},
 
    // When an item is selected
	selectItem : function( component, event, helper ) {
        var recordsList = component.get('v.recordsList');
        console.log('recordsList',recordsList);
        console.log('event.currentTarget.id',event.currentTarget.id);
        var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
        if(index != -1) {
            var selectedRecord = recordsList[index];
        }
        console.log("selectedRecord",selectedRecord);
        component.set("v.selectedAPI",selectedRecord);
        helper.RecordsSelected( component, event, helper);
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
	},
    
    showRecords : function( component, event, helper ) {
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
	},
 
    // To remove the selected item.
	removeItem : function( component, event, helper ){
        component.set('v.selectedRecordId','');
        component.set('v.selectedAPI','');
        component.set('v.searchString','');
        console.log('selectedRecordId',component.get('v.selectedRecordId'));
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
 
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
    	$A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})