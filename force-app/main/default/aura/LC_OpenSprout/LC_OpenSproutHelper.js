({
    onCloseTab : function(component) {
        var workspaceAPI = component.find("workspace");
        console.log('workspaceAPI:'+workspaceAPI);
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            console.log('response:'+response);
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log('error:'+error);
        });
	}
})