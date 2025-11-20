({
	init : function(component, event, helper) {
		var recordid = component.get("v.recordId");
        window.open('/lightning/r/Case/'+recordid+'/view','_self');
	}
})