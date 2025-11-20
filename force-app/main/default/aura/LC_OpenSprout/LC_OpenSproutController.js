({
	doInit : function(component, event, helper) {
        //console.log("event:"+JSON.stringify(event));
        component.set("v.loaded","true");
        var openWindow;
        setTimeout(function() {
            openWindow = window.open("https://app.sproutsocial.com/login?salesforceframe=true","_blank"); 
        }, 0);
        
        setTimeout(function() { 
            openWindow.close();
        }, 2000);
        
        setTimeout(function() { 
            openWindow = window.open("https://bankbri--sitest.sandbox.my.salesforce.com/idp/login?app=0spMR000000001d","_blank");
        }, 4000);
        
        setTimeout(function() {
            component.set("v.loaded","false");
            component.set("v.info","LOGIN SUCCESSFULLY, PLEASE FINISH THE PROCESS...");
            //openWindow = location.reload();
            //helper.onCloseTab(component);
        }, 6000);
	},
})