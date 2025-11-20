({
    init : function(component, event, helper) {
        console.log("[TabHighlighter] init() called");

        var workspaceAPI = component.find("workspace");

        if (!workspaceAPI) {
            console.error("[TabHighlighter] workspaceAPI not found");
            return;
        }

        // window.setInterval(
        //     $A.getCallback(function () {
        //         console.log("[TabHighlighter] Tick");

        //         workspaceAPI.getAllTabInfo().then(function(tabs) {
        //             console.log("[TabHighlighter] Tabs fetched:", tabs);

        //             tabs.forEach(function(tab) {
        //                 if (tab && tab.tabId) {
        //                     workspaceAPI.setTabHighlighted({
        //                         tabId: tab.tabId,
        //                         highlighted: true,
        //                         options: {
        //                             pulse: true,
        //                             state: "success"
        //                         }
        //                     }).then(() => {
        //                         console.log(`[TabHighlighter] Tab highlighted: ${tab.tabLabel}`);
        //                     }).catch(function(error) {
        //                         console.error("[TabHighlighter] Highlight error", error);
        //                     });
        //                 }
        //             });
        //         }).catch(function(error) {
        //             console.error("[TabHighlighter] getAllTabInfo error", error);
        //         });
        //     }),
        //     3000
        // );

        // console.log("[TabHighlighter] Interval started");
    }
});