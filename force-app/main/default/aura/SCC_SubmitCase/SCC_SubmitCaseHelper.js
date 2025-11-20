({
    showToast : function(params) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams(params);
            toastEvent.fire();
        } else {
            // Fallback for console or other contexts
            console.log("Toast:", params.title, "-", params.message);
        }
    }
})