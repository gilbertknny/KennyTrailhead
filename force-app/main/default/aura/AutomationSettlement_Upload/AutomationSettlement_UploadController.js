({
    doInit : function(component, event, helper) {
        // Listen for the modal close event
        window.addEventListener('keydown', function(event) {
            if (event.key === 'Escape') {
                $A.get('e.force:refreshView').fire();
            }
        });
    },

    handleUploadFinished: function(component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        console.log('Uploaded files:', uploadedFiles);

        // Call Apex method to update Case flag after file upload
        var action = component.get("c.updateCaseAfterUpload");
        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Show a success message when case update is done
                helper.showToast("Success", "File berhasil di upload", "success");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    helper.showToast("Error", "Error updating case: " + errors[0].message, "error");
                }
            }
        });

        // Enqueue the action
        $A.enqueueAction(action);
    }
})